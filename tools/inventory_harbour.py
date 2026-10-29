#!/usr/bin/env python3
"""Metadata inventory only. Never executes or copies reference source bodies."""
import argparse,collections,hashlib,json,pathlib,re
p=argparse.ArgumentParser();p.add_argument('--core',required=True);p.add_argument('--reference',required=True);p.add_argument('--audit');p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(a.core).resolve();audit={}
if a.audit:
 d=json.loads(pathlib.Path(a.audit).read_text());assert d['reference']==a.reference
 audit={('tests/'+r['file']):r for r in d['rows']}
rows=[]
for path in sorted(root.rglob('*')):
 if not path.is_file()or path.suffix.lower()not in ['.prg','.hb','.ch']:continue
 rel=path.relative_to(root).as_posix();top=rel.split('/')[0];data=path.read_bytes();text=data.decode('utf-8',errors='replace');r={'path':rel,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'profile':{'tests':'A-tests','extras':'B-extras','utils':'B-utils','contrib':'C-contrib','src':'internal-source'}.get(top,'support'),'kind':'header'if path.suffix.lower()=='.ch'else'source-unclassified','execution':'not-audited','reference_execution':'not-audited','entrypoint_review':'pending','dependencies_review':'pending','default_compile':'not-audited','llvm_compile':'not-audited'}
 # Search hints are not a parser and must not be used as readiness/coverage proof.
 r['review_hints']={'includes':sorted(set(re.findall(r'(?im)^\s*#\s*include\s*[<"]([^>"]+)',text))),'main_declaration_hint':bool(re.search(r'(?im)^\s*(?:static\s+)?(?:function|procedure)\s+main\b',text))}
 if rel in audit:
  for key,field in [('current','default_compile'),('llvm','llvm_compile')]:
   z=audit[rel][key];r[field]='accepted'if z['compiled']else'rejected';r[field+'_diagnostic']=z.get('diagnostic',[])
  r['compile_evidence']='frozen175-audit';r['compile_compiler']=d['compiler']
 if r['kind']=='header':r['execution']='not-applicable-header';r['entrypoint_review']='not-applicable-header'
 rows.append(r)
result={'schema':1,'reference':a.reference,'scope':'All .prg/.hb/.ch files in the pinned source tree. Source files are not assumed to be standalone examples. No source bodies copied.','execution_note':'No files executed by this inventory. not-audited does not negate separately recorded execution evidence.','counts':{'total':len(rows),'by_extension':dict(collections.Counter(pathlib.PurePosixPath(r['path']).suffix.lower()for r in rows)),'by_profile':dict(collections.Counter(r['profile']for r in rows)),'compile_audited':sum(r['default_compile']!='not-audited'for r in rows)},'files':rows};pathlib.Path(a.output).write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n');print(json.dumps(result['counts'],sort_keys=True))
