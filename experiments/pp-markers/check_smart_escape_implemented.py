#!/usr/bin/env python3
"""Own ASCII smart escape cases:compare decoded literal contents,not typography."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
# Expected literals are decoded independently from each preprocessor output.
def semantic(s):
 result=[];i=0
 while i<len(s):
  if s[i].isspace():i+=1;continue
  esc=s[i:i+2].lower()=='e"';start=i+2 if esc else i+1
  if esc or s[i] in "\"'":
   quote='"'if esc else s[i];text='';j=start
   while j<len(s):
    if s[j]==quote:break
    if esc and s[j]=='\\':
     j+=1;assert j<len(s);text+=dict(n='\n',r='\r',t='\t',a='\a',b='\b',f='\f',v='\v').get(s[j],s[j]);j+=1
    else:text+=s[j];j+=1
   assert j<len(s),(s,i);result.append(('literal',text));i=j+1
  else:result.append(s[i]);i+=1
 return result
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE <x>','PROBE <x,...>','PROBE <*x*>']:
  for value in ['e"a\\tb"','e"a\\nb"','e"a\\rb"','e"a\\ab"','e"a\\bb"','e"a\\fb"','e"a\\vb"','e"a\\\"b"','e"a\\\\b"','e"a\\qb"','e"#<x>"','e"a\\tb", e"c\\nd"']:
   if ','in value and pattern=='PROBE <x>':continue
   text=f'#{directive} {pattern} => OUT(<(x)>)\nPROBE {value}\n';f=out/f'case{len(rows)}.prg';f.write_text(text);h=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text();assert h.returncode==o.returncode==0 and semantic(expected)==semantic(o.stdout),(text,expected,o.stdout,o.stderr);rows.append(dict(source=text,reference_output=expected,own_output=o.stdout,exact_decoded_contents=True))
(out/'results.json').write_text(json.dumps({'scope':'140decoded-literal checks;not numeric escapes or repeated matching','rows':rows},indent=2)+'\n');print(len(rows),'decoded literal checks PASS')
