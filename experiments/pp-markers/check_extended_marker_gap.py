#!/usr/bin/env python3
"""Own black-box characterization of the existing <(x)> extended marker."""
import argparse,pathlib,subprocess,json,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE <(x)>','PROBE <(x)> TAIL','PROBE [<(x)>]']:
  for result in ['OUT(<x>)','OUT(<(x)>)','OUT(#<x>)','OUT(<"x">)']:
   for value in ['alpha','alpha beta','(alpha+beta)','"a  b"','a[1,2]','a,b','(a,b)','', 'alpha TAIL','(alpha + beta) TAIL']:
    text=f'#{directive} {pattern} => {result}\nPROBE {value}\n';f=out/f'case{len(rows)}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else''
    def tok(s):return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[^\s]',s)
    rows.append(dict(source=text,directive=directive,pattern=pattern,result=result,input=value,reference_exit=ref.returncode,reference_output=expected,reference_error=ref.stderr,own_exit=own.returncode,own_output=own.stdout,own_error=own.stderr,token_match=ref.returncode==own.returncode==0 and tok(expected)==tok(own.stdout)))
(out/'results.json').write_text(json.dumps({'scope':'480observations;not480compatibilitypasses','rows':rows},indent=2)+'\n');print(len(rows),'observations',sum(r['token_match']for r in rows),'token matches')
for r in rows[:40]:print(r['source'].replace('\n',' / '),'=>',r['reference_output'].strip(),';own=',r['own_output'].strip())
