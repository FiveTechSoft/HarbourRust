#!/usr/bin/env python3
"""Characterize logical result markers; no compiler change or permission implied."""
import argparse,pathlib,subprocess,json,hashlib,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);rows=[]
cases=[]
for directive in ['command','xcommand','translate','xtranslate']:
 for pat,sources in [('PROBE [<m: META>]',['PROBE','PROBE META','PROBE meta']),('PROBE [<!m!>]',['PROBE','PROBE alpha','PROBE alpha beta']),('PROBE [<m>]',['PROBE','PROBE alpha','PROBE .F.','PROBE 0','PROBE ""']),('PROBE [<m,...>]',['PROBE','PROBE alpha,beta']),('PROBE <m>',['PROBE alpha','PROBE .F.','PROBE 0','PROBE ""']),('PROBE [META <!m!>] <!n!>',['PROBE alpha','PROBE META beta alpha'])]:
  for src in sources:
   if directive in ['translate','xtranslate'] and src=='PROBE alpha beta' and pat=='PROBE [<!m!>]':continue
   cases.append((directive,pat,'OUT( <.m.> )',src,'logical'))
 for pat,result,src in [('PROBE [<m: META>]','OUT( [<.m.>] )','PROBE'),('PROBE [<m: META>]','OUT( [<.m.>] )','PROBE META'),('PROBE [<m: META>]','OUT( <.M.> )','PROBE meta'),('PROBE <m>','OUT( <.missing.> )','PROBE alpha')]:cases.append((directive,pat,result,src,'bracket-or-validation'))
for i,(directive,pat,result,src,kind)in enumerate(cases):
 f=out/f'p{i:03}.prg';text=f'#{directive} {pat} => {result}\n{src}\n';f.write_text(text);r=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);ppo=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);assert own.returncode==1 and 'unknown result marker'in own.stderr,(i,own.stderr)
 if 'missing'in result or '<.M.>'in result:assert r.returncode==1 and 'Unknown result marker'in r.stdout+r.stderr,(i,r.stdout,r.stderr)
 else:assert r.returncode==0,(i,text,r.stdout,r.stderr,ppo)
 rows.append({'case':i,'directive':directive,'pattern':pat,'result':result,'input':src,'kind':kind,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_exit':r.returncode,'reference_preprocessed':ppo,'reference_diagnostic':(r.stdout+r.stderr).strip(),'own_exit':own.returncode,'own_diagnostic':own.stderr.strip()})
j={'reference':'694428e1c12f726675b19324d62167fa77d68185','own':'3002cb94ac2a6b35af3d927189139eac18eec76a','scope':'Own-source preprocessor-only characterization. No production mutation,program execution or full grammar claim. Logical result markers are distinct from literal-list match markers and general dotted lexical reemission.','rows':rows};(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(len(rows),'logical result observations;own rejection unchanged')
