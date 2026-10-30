#!/usr/bin/env python3
"""Own-source observations of call-form translation; no runtime execution."""
import pathlib,subprocess,json,argparse
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args()
out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
forms={
'optional':'#xtranslate F( <name>([<args,...>]) ) => OUT( <name> [, <args>] )\n',
'overload':'#xtranslate F( <name> ) => ATOM( <name> )\n#xtranslate F( <name>([<args,...>]) ) => CALL( <name> [, <args>] )\n',
'reversed':'#xtranslate F( <name>([<args,...>]) ) => CALL( <name> [, <args>] )\n#xtranslate F( <name> ) => ATOM( <name> )\n',
'arity':'#xtranslate F( <a>, <b> ) => TWO( <a>, <b> )\n#xtranslate F( <a> ) => ONE( <a> )\n',
}
for form,definition in forms.items():
 for val in ['alpha','alpha()','alpha(1)','alpha(1,2)','alpha(beta(1,2),3)','1,2','', 'alpha + 1']:
  for context in ['F('+val+')','? F('+val+')','x := F('+val+') + 7']:
   i=len(rows);text=definition+context+'\n';p=out/f'p{i}.prg';p.write_text(text);r=subprocess.run([a.hbpp,str(p),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(p)],capture_output=True,text=True,timeout=10);rows.append({'case':i,'form':form,'value':val,'context':context,'source':text,'reference_exit':r.returncode,'reference_output':p.with_suffix('.ppo').read_text()if p.with_suffix('.ppo').exists()else'','reference_error':r.stdout+r.stderr,'own_exit':o.returncode,'own_output':o.stdout,'own_error':o.stderr})
(out/'results.json').write_text(json.dumps({'scope':'96own-source call-form translation observations,not runtime.','rows':rows},indent=2)+'\n')
assert len(rows)==96 and all(r['reference_exit']==0 for r in rows)
print('96call-form translation observations;no production mutation')
