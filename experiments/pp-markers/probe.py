#!/usr/bin/env python3
"""Own-source black-box observations; no Harbour implementation is read."""
import argparse,pathlib,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();root=pathlib.Path(a.output_dir).resolve();root.mkdir(parents=True,exist_ok=True);rows=[]
values=['Alpha','A_2','1','12abc','a + b','(a)','"abc"','','a,b','a:b','a.b','alpha beta','a[1]','é','_x']
for kind,marker,suffix in [('identifier','<!x!>',' STOP'),('wildcard-nonterminal','<*x*>',' STOP'),('wildcard-terminal','<*x*>','')]:
 for i,val in enumerate(values):
  name=f'{kind}-{i:02}';source=f'#xcommand PROBE {marker}{suffix} => OUT( <x> )\nPROCEDURE Main()\nPROBE {val}{suffix}\nRETURN\n';f=root/(name+'.prg');f.write_text(source);ref=subprocess.run([str(pathlib.Path(a.hbpp).resolve()),str(f),'-q2'],cwd=root,capture_output=True,text=True,timeout=10);own=subprocess.run([str(pathlib.Path(a.hpp).resolve()),str(f)],cwd=root,capture_output=True,text=True,timeout=10);assert ref.returncode==0,(name,ref.stderr);out=f.with_suffix('.ppo').read_text();matched='OUT(' in out
  expected=(val in ['Alpha','A_2','_x']) if kind=='identifier' else (bool(val) if kind=='wildcard-terminal' else False)
  assert matched==expected,(name,out)
  assert own.returncode==1 and 'bad match marker' in own.stderr,(name,own.stderr)
  rows.append({'case':name,'marker':marker,'suffix':suffix,'input':val,'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'reference_preprocess_exit':ref.returncode,'reference_rule_matched':matched,'reference_preprocessed':out,'own_preprocess_exit':own.returncode,'own_diagnostic':own.stderr.strip()})
result={'reference':'harbour/core694428e1c12f726675b19324d62167fa77d68185','own_compiler':'41a92c14869a735c6a7340a18899fe782e58229a','scope':'45 own-source preprocessor-only probes. No program compiled/linked/executed. Source outputs contain only our own probe text. All remain rejected by own preprocessor. Not complete marker semantics.','rows':rows};(root/'results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(f'{len(rows)} reference observations and {len(rows)} own rejections verified')
