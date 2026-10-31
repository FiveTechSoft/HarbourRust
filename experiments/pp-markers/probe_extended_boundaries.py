#!/usr/bin/env python3
"""Own extended-match whitespace/delimiter observations, not support claims."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
values=['alpha','alpha beta','a+b','a +b','a+ b','a + b','a\tb','a/b','a /b','foo\\bar.prg','foo-bar.prg','C:\\foo.prg','foo:bar','foo.bar','foo..bar','a=b','a:=b','a==b','a<>b','a:b','a,b','a;b','f(x)','f(x,y)','a[x]','a[x,y]','{x}','{x,y}','[a b]','"a b"','"a b"+x','"a b" +x','"a b",x',"'a b'",'e"a\\tb"','(x)','( x )','(x)+y','(x) + y','(x) y','(x),y','(x);y','(f(x,y))','(x)[y]','(x):y','((x))','()','( )','(x + y) * z','(x) .AND. y','&name','&name.','&name.suffix','&(x)','&( x + y )','&(x)+y','&name+x','a/*c*/b','a //c','a&&c']
for directive in ['command','xcommand','translate','xtranslate']:
 for pattern in ['PROBE <(x)>','PROBE <(x)> TAIL']:
  for value in values:
   supplied=value+(' TAIL'if pattern.endswith('TAIL')else'');text=f'#{directive} {pattern} => HIT(<x>)\nPROBE {supplied}\n';f=out/f'case{len(rows)}.prg';f.write_text(text);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';rows.append(dict(directive=directive,pattern=pattern,input=value,source=text,reference_exit=ref.returncode,reference_output=expected,reference_error=ref.stderr,reference_matched='HIT('in expected,own_exit=own.returncode,own_output=own.stdout,own_error=own.stderr))
(out/'results.json').write_text(json.dumps({'scope':'480own black-box observations;not compatibility passes;no runtime execution','rows':rows},indent=2)+'\n');print(len(rows),'observations')
for r in rows[:60]:print(repr(r['input']),'->',repr(r['reference_output'].strip()))
