#!/usr/bin/env python3
"""Own-source characterization of result-side smart stringify on existing captures."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE <x>','PROBE <x,...>','PROBE <*x*>','PROBE [<x>]']:
  for value in ['alpha','alpha beta','123','-1','a+b','(a + b)','(a)+b','"a  b"',"'a  b'",'[a b]','e"a\\tb"','a,b','a,,b',',a,','"a b", (x+y), file.prg','f(1,2)','a[1,2]','{1,2}','&name','&name.','&(x)','&name.suffix','', '"#<x>"']:
   text=f'#{directive} {pattern} => OUT(<(x)>)\nPROBE {value}\n';f=out/f'case{len(rows)}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
   rows.append(dict(source=text,directive=directive,pattern=pattern,input=value,reference_exit=ref.returncode,reference_output=expected,reference_error=ref.stderr,own_exit=own.returncode,own_output=own.stdout,own_error=own.stderr))
(out/'results.json').write_text(json.dumps({'scope':'384observations,not compatibilitypasses','rows':rows},indent=2)+'\n');print(len(rows),'observations')
for r in rows[:48]:print(r['pattern'],repr(r['input']),'=>',repr(r['reference_output']))
