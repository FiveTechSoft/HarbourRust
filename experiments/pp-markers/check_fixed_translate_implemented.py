#!/usr/bin/env python3
"""Replay fixed-rule oracle and known captured/mixed boundaries separately."""
import argparse,pathlib,json,subprocess,re
p=argparse.ArgumentParser();p.add_argument('--hbpp',required=True);p.add_argument('--hpp',required=True);p.add_argument('--before',required=True);p.add_argument('--output-dir',required=True);a=p.parse_args();out=pathlib.Path(a.output_dir).resolve();out.mkdir(parents=True,exist_ok=True);root=pathlib.Path(__file__).parent/'fixed-translate-20261031';rows=[]
def tok(s):
 # Single/double quote spelling and statement separators differ historically.
 return re.findall(r'"[^"\n]*"|\x27[^\x27\n]*\x27|[A-Za-z_][A-Za-z_0-9]*|\d+|[^\s]',s)
for group in ['results','extra','abbr','mixed','temporal']:
 j=json.loads((root/(group+'.json')).read_text());j=j['rows']if isinstance(j,dict)else j
 for r in j:
  f=out/f'{group}{r["case"]}.prg';f.write_text(r['source']);ref=subprocess.run([a.hbpp,str(f),'-q2'],capture_output=True,text=True);expected=f.with_suffix('.ppo').read_text()if f.with_suffix('.ppo').exists()else'';assert(ref.returncode,expected)==(r['reference_exit'],r['reference_output'])
  own=subprocess.run([a.hpp,str(f)],capture_output=True,text=True);before=subprocess.run([a.before,str(f)],capture_output=True,text=True)
  pattern=r.get('pattern','');fixed=(group=='results'and'< 'not in pattern and '<'not in pattern and '['not in pattern and r['directive']in['translate','xtranslate'])or(group=='extra'and r['case']%19 in [0,1,2,3,4,5,7,8,9,10,13,14,15,17])or(group=='abbr'and r['case']in [0,1,2,3,4,5,7,8,9,10,11,12,13,15])
  if fixed:assert own.returncode==0 and tok(own.stdout)==tok(expected),(group,r['case'],own.stdout,expected);kind='fixed supported token match'
  elif group in ['mixed','temporal']:assert(own.returncode,own.stdout,own.stderr)==(before.returncode,before.stdout,before.stderr);kind='mixed family baseline preserved;not Harbour compatibility'
  else:kind='outside slice observation'
  rows.append({'group':group,'case':r['case'],'kind':kind,'own_exit':own.returncode,'own_output':own.stdout,'own_error':own.stderr})
(out/'results.json').write_text(json.dumps({'scope':'observations classified;only fixed supported token matches are compatibility checks','rows':rows},indent=2)+'\n');print({kind:sum(r['kind']==kind for r in rows)for kind in sorted(set(r['kind']for r in rows))})
