#!/usr/bin/env python3
"""Classify generated DBF delta after symbol-only normalization. Not a runtime proof."""
import argparse,pathlib,re,difflib,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--before',required=True);p.add_argument('--after',required=True);p.add_argument('--output',required=True);a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(exist_ok=False)
def normalize(path):
 s=pathlib.Path(path).read_text();s=re.sub(r'^\s*\.file\s+.*\n','',s,flags=re.M)
 # GCC's static switch IDs change when an unrelated function grows.
 names=re.findall(r'^(hrdbf_local_CSWTCH\.\d+):',s,re.M);mp={n:f'hrdbf_local_CSWTCH_{i}' for i,n in enumerate(names)}
 # Bind string labels by their actual literal instead of the preceding function.
 for label,lit in re.findall(r'^(\.Lhrdbf_\w+):\n\s*\.string\s+(.*)$',s,re.M):mp[label]='.Lstring_'+hashlib.sha256(lit.encode()).hexdigest()[:16]
 owner='head';counts={}
 for line in s.splitlines():
  m=re.match(r'^([A-Za-z_]\w*(?:\.\w+)*):$',line)
  if m:owner=mp.get(m[1],m[1])
  m=re.match(r'^(\.Lhrdbf_[\w.]+):$',line)
  if m and m[1] not in mp:
   i=counts.get(owner,0);counts[owner]=i+1;mp[m[1]]=f'.L_{owner}_{i}'
 pat=re.compile(r'(?<![\w.$])('+'|'.join(map(re.escape,sorted(mp,key=len,reverse=True)))+r')(?![\w.$])')
 s=pat.sub(lambda m:mp[m[1]],s)
 # Preserve all directives and instructions; only the symbol names above change.
 return s
x=normalize(a.before);y=normalize(a.after);(r/'before.normalized.s').write_text(x);(r/'after.normalized.s').write_text(y);(r/'normalized.diff').write_text(''.join(difflib.unified_diff(x.splitlines(True),y.splitlines(True))))
def funcs(s):
 d={}
 for m in re.finditer(r'^\s*\.type\s+(\S+),\s*@function\n(.*?^\s*\.size\s+\1,.*?$)',s,re.M|re.S):d[m[1]]=m[2]
 return d
u=funcs(x);v=funcs(y);assert u.keys()==v.keys();changed=[n for n in u if u[n]!=v[n]];assert sorted(changed)==['hrdbf_app_empty','hrv_validate'],changed
(r/'results.json').write_text(json.dumps(dict(changed_functions=changed,function_count=len(u),normalization='symbol names and .file only',limits='Not binary identity or runtime verification; raw assembly remains authoritative'),indent=2)+'\n');print('PASS only Empty and validate functions change after symbol normalization',len(u),'functions')
