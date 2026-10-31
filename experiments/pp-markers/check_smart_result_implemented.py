#!/usr/bin/env python3
"""Scoped smart result for existing captures;other contracts recorded separately."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
values=['alpha','123','-1','a+b','(a + b)','(a)+b','"a  b"',"'a  b'",'[a b]','f(1,2)','a[1,2]','{1,2}','"#<x>"','(a)+"b"','"a"+"b"']
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE <x>','PROBE <x,...>','PROBE <*x*>','PROBE [<x>]', 'PROBE <!x!>', 'PROBE <x:alpha,beta>']:
  inputs=(['alpha','beta'] if ':'in pattern else ['alpha','beta_2']if'!'in pattern else values+(['a,b','a,,b',',a,','"a b", (x+y), file.prg']if '...'in pattern or '*'in pattern else[]))
  if '['in pattern:inputs=inputs+['']
  for value in inputs:
   f=out/f'case{len(rows)}.prg';text=f'#{directive} {pattern} => OUT(<(x)>)\nPROBE {value}\n';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert ref.returncode==own.returncode==0 and tok(expected)==tok(own.stdout),(text,expected,own.stdout,own.stderr);rows.append(dict(source=text,reference_output=expected,own_output=own.stdout))
# Runtime macro and escape contracts stay explicit,not silently quoted.
for value in ['&name','&name.','&(x)','e"a\\tb"']:
 f=out/f'case{len(rows)}.prg';text=f'#command PROBE <x> => OUT(<(x)>)\nPROBE {value}\n';f.write_text(text);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);assert own.returncode!=0 and 'smart stringify of' in own.stderr,(text,own.stdout,own.stderr);rows.append(dict(source=text,kind='explicit scope rejection',own_error=own.stderr))
(out/'results.json').write_text(json.dumps({'scope':'scoped smart result;not extended matching or macro runtime','rows':rows},indent=2)+'\n');print(len(rows),'checks PASS,including4explicit rejections')
