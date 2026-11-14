#!/usr/bin/env python3
from pathlib import Path
import re,json,collections,csv
import argparse
p = argparse.ArgumentParser(description='Inventory pinned Harbour RTL text APIs against current hbc source')
p.add_argument('--harbour-tree', type=Path, required=True)
p.add_argument('--source-inventory', type=Path, required=True)
p.add_argument('--repo', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
core = a.harbour_tree.resolve()
repo = a.repo.resolve()
out = a.output.resolve()
out.mkdir(parents=True, exist_ok=False)
hbc = (repo / 'src/hbc.rs').read_text()
exportmap={}
for p in (core/'src').rglob('*'):
 if not p.is_file()or p.suffix not in ['.c','.prg']or 'obj'in p.parts:continue
 s=p.read_text(errors='replace')
 for n in re.findall(r'^HB_FUNC(?:_TRANSLATE)?\(\s*(\w+)',s,re.M):exportmap.setdefault(n.upper(),set()).add(str(p.relative_to(core)))
 for n in re.findall(r'^\s*(?:FUNCTION|PROCEDURE)\s+(\w+)\s*\(',s,re.I|re.M):exportmap.setdefault(n.upper(),set()).add(str(p.relative_to(core)))
groups={
'Core slicing, search, editing':['at.c','ati.c','rat.c','left.c','right.c','substr.c','stuff.c','strtran.c','strrepl.c'],
'Case, classification, trimming, padding':['strcase.c','is.c','trim.c','replic.c','space.c','pad.c','padx.c','hbascii.c'],
'Numeric conversion and formatting':['str.c','strzero.c','val.c','hbntos.c','hbstrfmt.c','transfrm.c','round.c'],
'Byte, Unicode and codepage text':['chrasc.c','chruni.c','strutf8.c','cdpapihb.c','cdpbox.c'],
'Token, multiline and phonetic text':['hbtoken.c','mlcfunc.c','soundex.c','hardcr.c','mtran.c'],
'Escaping, serialization and byte transforms':['strc.c','strclear.c','strtoexp.c','strxor.c','hbstrsh.c','valtostr.c','valtoexp.prg','valtoexp.c'],
'Wildcard and regular expressions':['strmatch.c','hbregex.c'],
'Binary text encodings and numeric bytes':['hbhex.c','base64c.c','base64d.c','binnum.c'],
'Checksums and string digests (adjacent)':['hbcrc.c','hbmd5.c','hbsha1.c','hbsha2.c','hbsha2hm.c'],
'Memo text I/O (adjacent)':['memofile.c'],
'Length, emptiness, type and output boundaries':['len.c','empty.c','valtype.c'],
}
# Curated export-file families plus every documentation entry categorized Strings.
namegroup={}
for group,files in groups.items():
 for n,paths in exportmap.items():
  if n.startswith('__'):continue
  if any(Path(p).name in files and p.startswith('src/rtl/')for p in paths):namegroup.setdefault(n,group)
for p in (core/'doc/en').glob('*.txt'):
 for block in p.read_text(errors='replace').split('$DOC$')[1:]:
  def field(n):
   m=re.search(r'\$'+n+r'\$\s*([^$]+)',block);return m.group(1).strip()if m else''
  if field('SUBCATEGORY')=='Strings':
   n=field('NAME').split('(')[0].upper();assert n in exportmap,(n,p);namegroup.setdefault(n,'Other documented string API')
for n in ['HB_ISSTRING','HB_EOL','QOUT','QQOUT','OUTSTD','OUTERR']:
 namegroup[n]='Length, emptiness, type and output boundaries'
known={
'ASC':'typed strings only; empty string -> 0; byte/codepage limits',
'CHR':'integer only; byte modulo 256; numeric truncation/codepages not general',
'SUBSTR':'typed byte strings, integer start/count, 2/3 args; owned TRY error-path leak',
'STR':'integer value and optional integer width only; no decimal-formatting third arg',
'HB_NTOS':'integer and selected Dyn integer cell only; float conversion not general',
'PADR':'typed string and integer width only; no custom pad or general numeric conversion',
'REPLICATE':'typed string and integer count only; no numeric truncation/Dyn',
'LTRIM':'typed string only; bounded whitespace/codepage behavior',
'RTRIM':'typed string only; bounded whitespace/codepage behavior',
'TRIM':'typed string only; bounded whitespace/codepage behavior',
'ALLTRIM':'typed string only; no general optional extra trim-character handling',
'LEN':'selected string/array/hash/Dyn shapes; parameter and temporary limits',
'EMPTY':'bounded scalar/variable aggregate shapes; literal aggregate restrictions',
'VALTYPE':'selected expressions/cells only; many owned-call forms rejected',
'HB_ISSTRING':'selected scalar/Dyn/cell shapes; not unrestricted Harbour values',
'ROUND':'bounded typed numeric inputs/metadata; not full Dyn numeric dispatch',
'HB_ISARRAY':'selected scalar/Dyn/cell shapes only',
'HB_ISNUMERIC':'selected scalar/Dyn/cell shapes only',
'HB_EOL':'platform newline helper; full API audit not repeated here',
'QOUT':'bounded output-value shapes; no general object/error/terminal behavior',
'QQOUT':'bounded output-value shapes; no general object/error/terminal behavior',
'OUTSTD':'bounded output-value shapes; not unrestricted runtime values',
'OUTERR':'bounded output-value shapes; not unrestricted runtime values',
}
# Inventory scope removes printer/file-only helpers that merely share files.
for n in ['HB_MD5FILE','HB_FILEMATCH']:namegroup.pop(n,None)
inv=json.loads(a.source_inventory.read_text());files=[x['path']for x in inv['files']if x['path'].endswith('.prg')];assert len(files)==1041
# Lexical function-call mentions, stripping comments and quoted literals. This
# is a prioritization signal, not a parser/semantic call graph or admission test.
def clean(s):
 s=re.sub(r'/\*.*?\*/',' ',s,flags=re.S)
 s=re.sub(r'(?m)^\s*\*.*$',' ',s)
 s=re.sub(r'''"(?:[^"\n]|"")*"|'(?:[^'\n]|'')*'|//[^\n]*|&&[^\n]*''',' ',s)
 return s
counts=collections.defaultdict(int);filehits=collections.defaultdict(set)
for f in files:
 s=clean((core/f).read_text(errors='replace'))
 for n in re.findall(r'\b([A-Za-z_]\w*)\s*\(',s):
  n=n.upper()
  if n in namegroup:counts[n]+=1;filehits[n].add(f)
rows=[]
for n in sorted(namegroup,key=lambda n:(list(groups).index(namegroup[n])if namegroup[n]in groups else 99,n)):
 # No absence decision from an isolated memory record: inspect the full current
 # checker/parser source and identify all typed builtin admissions separately.
 status='partial'if n in known else'not implemented'
 if status=='not implemented':assert not re.search(r'is_builtin\(\s*id\s*,\s*"'+re.escape(n.lower())+'"\s*\)',hbc,re.I),n
 rows.append({'name':n,'family':namegroup[n],'status':status,'scope':known.get(n,'no native builtin admission found in current hbc parser/checker/emitter'), 'lexical_calls':counts[n],'source_files':len(filehits[n]),'harbour_sources':'; '.join(sorted(exportmap.get(n,set())))})
(out/'inventory.json').write_text(json.dumps({'harbour':'694428e1c12f726675b19324d62167fa77d68185','hbc_base':'76d027ccdc0717318ddcf3a3bce58c2a353556bd','original_prg_files':1041,'functions':rows},indent=2)+'\n')
with(out/'inventory.csv').open('w')as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
s=['# Harbour string-function inventory - 14 November 2026','',
'Reference: Harbour `694428e1c12f726675b19324d62167fa77d68185` and HarbourRust',
'`76d027ccdc0717318ddcf3a3bce58c2a353556bd` (SubStr published). This is a source',
'inventory, not a complete-library compatibility or upstream-admission claim.','',
'## Scope and status','',
'Included: every `doc/en` entry categorized Strings, public exports from the',
'core RTL text families listed below, and named adjacent conversion/encoding,',
'checksum/digest, memo-I/O and output-boundary families. Internal `__*` helpers',
'are excluded. Contrib libraries (for example hbct/xhb), network/file protocols,',
'GT/input UI, general date formatting and arbitrary functions that happen to',
'return text are separate inventories. Their absence here is not completion.',
'Runtime source paths below make the boundary reproducible. Aliases count as',
'API names, not as independent implementations. Optional build/codepage/regex',
'features may need additional Harbour build dependencies.','',
'`partial` means an implemented bounded native path with limits, not full',
'Harbour arity/polymorphism/codepage/error behavior. `not implemented` means no',
'current native builtin admission found in the complete compiler source;',
'linked user-provided C extensions are not native builtin implementations.',
'No entry is promoted to fully implemented without a complete API audit.','',
'Frequency columns are lexical call-like mentions after removing comments',
'and quoted strings in the pinned 1,041 `.prg` sources. They are prioritization',
'signals, not executed calls, a semantic call graph, or proof that implementing',
'one function admits the enclosing program. Declarations/macros/methods may',
'contribute lookalike names; all 1,041 files are counted, including contrib.',
'The 268 originals directly under `tests/` are a separate admission denominator.','',
'## Counts','']
s+=[f'- {len(rows)} named APIs in this explicit scope.',f'- {sum(x["status"]=="partial"for x in rows)} partial native paths; {sum(x["status"]=="not implemented"for x in rows)} not implemented.', '- 0 declared fully implemented by this inventory.','', '## Suggested order','',
'1. Fix the independently reproduced post-TRY trace-chain crash first. Keep',
'   general owned-temporary exception cleanup a separate audited change.',
'2. Left/Right/At/RAt and Int/Val, followed by Upper/Lower/Space/StrTran/Stuff',
'   and complete Str/StrZero/padding conversions. Rank within a family by the',
'   source-hit columns and real ERP probes rather than claiming universal use.',
'3. Token/multiline, matching/regex, Unicode/codepage and serialization families.',
'   Encodings/digests/memo I/O remain explicit adjacent groups, not forgotten.',
'4. Contrib string libraries and remaining date/IO/terminal surfaces need their',
'   own inventories before any claim of all Harbour strings being complete.','',
'Every future code package needs fresh Harbour differential output, final',
'ownership checks, honest limits and a representative microbenchmark reporting',
'ns/call or MB/s against Harbour. Include an equivalent C/Rust reference where',
'fair; preserve mutation safety, explain unavoidable copies, and optimize clear',
'losses before publishing. Benchmarks live outside the main regression manifest.','']
for group in list(groups)+['Other documented string API']:
 group_rows=[x for x in rows if x['family']==group]
 if not group_rows:continue
 s+=['## '+group,'','| API | Status | Call mentions / files | Harbour source | Scope |','| --- | --- | ---: | --- | --- |']
 for x in sorted(group_rows,key=lambda x:(-x['source_files'],x['name'])):s.append('| `'+x['name']+'` | '+x['status']+' | '+str(x['lexical_calls'])+' / '+str(x['source_files'])+' | `'+x['harbour_sources']+'` | '+x['scope']+' |')
 s+=['']
s+=['## Refresh protocol','',
'Re-run export/doc extraction and lexical counts on the pinned Harbour tree,',
'validate any newer main source admissions, and retain the exact base hashes.',
'An implemented name moving to partial/full requires behavior evidence, not',
'just a symbol or a successful compile. Microbenchmarks are not compatibility',
'proof and exact output is not proof of leak-free exception cleanup.','']
(out/'STRING-INVENTORY-2026-11-14.md').write_text('\n'.join(s));print(len(rows),'APIs',sum(x['status']=='partial'for x in rows),'partial');print('top missing',[(x['name'],x['source_files'])for x in sorted(rows,key=lambda x:-x['source_files'])if x['status']=='not implemented'][:20])
