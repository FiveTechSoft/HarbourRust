#!/usr/bin/env python3
"""Measure already validated artifacts, without guessing function boundaries."""
import argparse,json,pathlib,subprocess,hashlib
p=argparse.ArgumentParser();p.add_argument('--execution-dir',required=True);p.add_argument('--output',required=True);a=p.parse_args();root=pathlib.Path(a.execution_dir).resolve();d=json.loads((root/'results.json').read_text());assert all(x.get('exact')for x in d['rows']);rows=[]
for case in d['rows']:
 n=pathlib.PurePosixPath(case['file']).stem;row={'file':case['file'],'sha256':case['sha256'],'targets':{}}
 for m in ['default','llvm','harbour']:
  path=root/(n+'-'+m);f=[]
  if m=='llvm':
   for line in subprocess.check_output(['nm','-S','--defined-only',str(path)],text=True).splitlines():
    s=line.split()
    if len(s)==4 and s[-1].startswith('ll_'):f.append({'name':s[-1],'bytes':int(s[1],16)})
  row['targets'][m]={'file_bytes':path.stat().st_size,'executable_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'gnu_size_fields':subprocess.check_output(['size',str(path)],text=True).strip().splitlines()[-1].split()[:6],'function_bytes':f,'function_bytes_note':'Only LLVM ELF sized symbols measured; not guessed for default/Harbour'}
 rows.append(row)
result={'reference':d['reference'],'compiler':d['compiler'],'method':'Actual byte-exact reviewed-original Linux artifacts. Whole file and GNU size fields are distinct from per-function sizes. Default/Harbour symbols do not supply comparable exact function sizes here. Runtime/CRT and paths differ. No Rust translation or speed claim.','rows':rows};pathlib.Path(a.output).write_text(json.dumps(result,indent=2)+'\n');print(f'PASS sized {len(rows)} validated originals x3 configurations; per-function LLVM sizes separate')
