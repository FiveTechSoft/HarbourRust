#!/usr/bin/env python3
"""Own-source escaped-marker/generated-directive characterization only."""
import argparse,pathlib,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args()
out=pathlib.Path(a.output_dir).resolve();out.mkdir(exist_ok=True);rows=[]
for outer in ['command','xcommand']:
 for inner in ['command','xcommand']:
  for form in ['escaped','unescaped','unknown','case','capture_collision','optional']:
   if form=='escaped':pat=r'\<kind: FUNCTION, PROCEDURE>';res=r'\<kind>'
   elif form=='unescaped':pat='<kind: FUNCTION, PROCEDURE>';res='<kind>'
   elif form=='unknown':pat=r'\<kind: FUNCTION, PROCEDURE>';res=r'\<missing>'
   elif form=='case':pat=r'\<kind: FUNCTION, PROCEDURE>';res=r'\<KIND>'
   elif form=='capture_collision':pat=r'\<tag: FUNCTION, PROCEDURE>';res=r'\<tag>'
   else:pat=r'\[\<kind: FUNCTION, PROCEDURE>]';res=r'\[\<kind>]'
   for tail in ['', 'INNER alpha', 'INNER FUNCTION alpha','INNER PROCEDURE alpha','INNER FUNC alpha','INNER OTHER alpha']:
    text=f'#{outer} FACTORY <!tag!> => #{inner} INNER {pat} <tag> => OUT( {res}, <tag> )\nFACTORY alpha\n{tail}\n';i=len(rows);f=out/f'p{i:03}.prg';f.write_text(text);r=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);p=f.with_suffix('.ppo');own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10)
    rows.append({'case':i,'outer':outer,'inner':inner,'form':form,'input':tail,'source':text,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),'reference_exit':r.returncode,'reference_preprocessed':p.read_text()if p.exists()else'','reference_diagnostic':r.stdout+r.stderr,'own_exit':own.returncode,'own_diagnostic':own.stderr,'own_preprocessed':own.stdout})
for r in rows:
 expected_error=1 if r['form']in ['unescaped','unknown','case']else 0
 assert r['reference_exit']==expected_error,(r['case'],r['reference_diagnostic'])
 if r['form']=='unescaped':assert '(1) Error: Label error'in r['reference_diagnostic']
 elif r['form']in ['unknown','case']:assert '(2) Error: Unknown result marker'in r['reference_diagnostic']
 else:
  matched=r['input']in ['INNER FUNCTION alpha','INNER PROCEDURE alpha']or(r['input']=='INNER FUNC alpha'and r['inner']=='command')or(r['input']=='INNER alpha'and r['form']=='optional')
  assert ('OUT('in r['reference_preprocessed'])==matched,(r['case'],r['reference_preprocessed'])
 assert r['own_exit']==1 and 'unknown result marker'in r['own_diagnostic'],(r['case'],r['own_diagnostic'])
timing=[]
texts=[('unused_unknown',r'#xcommand FACTORY <!tag!> => #xcommand INNER \<kind: FUNCTION, PROCEDURE> <tag> => OUT( \<missing>, <tag> )'+'\n'),('before_registration',r'#xcommand FACTORY <!tag!> => #xcommand INNER \<kind: FUNCTION, PROCEDURE> <tag> => OUT( \<kind>, <tag> )'+'\nINNER FUNCTION alpha\nFACTORY alpha\nINNER FUNCTION alpha\n'),('marker_free','#xcommand FACTORY => #xcommand INNER => OUT( yes )\nFACTORY\nINNER\n'),('unused_marker_free','#xcommand FACTORY => #xcommand INNER => OUT( yes )\nINNER\n')]
for name,text in texts:
 f=out/(name+'.prg');f.write_text(text);r=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True,timeout=10);o=subprocess.run([a.hpp,str(f)],capture_output=True,text=True,timeout=10);row={'case':name,'source':text,'reference_exit':r.returncode,'reference_preprocessed':f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'','reference_diagnostic':r.stdout+r.stderr,'own_exit':o.returncode,'own_preprocessed':o.stdout,'own_diagnostic':o.stderr};timing.append(row)
 assert r.returncode==0
 if name in ['unused_unknown','before_registration']:assert o.returncode==1 and 'unknown result marker'in o.stderr
 else:assert o.returncode==0
 if name=='marker_free':assert 'OUT( yes )'in row['reference_preprocessed'] and '#xcommand INNER'in o.stdout and o.stdout.endswith('INNER\n')
 if name=='unused_marker_free':assert row['reference_preprocessed'].strip()==o.stdout.strip()=='INNER'
 if name=='before_registration':assert row['reference_preprocessed'].strip()=='INNER FUNCTION alpha\n\nOUT( FUNCTION, alpha )'
j={'reference':'694428e1c12f726675b19324d62167fa77d68185','own':'732eb4b329c63d7de202216be77a467b9f70210f','scope':'144own-source preprocessor observations. No implementation or runtime programs. Escaped match/result markers,optional brackets,outer capture collision,generated definition timing and ordinary/X abbreviation. Own early rejection preserved.','rows':rows,'timing':timing}
(out/'results.json').write_text(json.dumps(j,indent=2)+'\n');print(len(rows),'generated-directive observations plus4timing observations;no production change')
