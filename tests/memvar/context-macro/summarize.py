from pathlib import Path
import json,subprocess,hashlib
R=Path(__file__).resolve().parents[3];E=R/'evidence';lines=[x for x in (R/'tests/manifest.txt').read_text().splitlines()if x.strip()and not x.lstrip().startswith('#')]
summary={}
for target in ['linux','windows']:
 O=E/'battery'/target;rows={}
 for p in sorted(p for p in O.glob('results-*.json') if '.pre-' not in p.name):
  for x in json.loads(p.read_text()):rows[x['index']]=x
 stats={'count':len(rows),'raw_regressions':[],'not_executed':[],'manifest_raw_failures':[],'canonical_lf_failures':[],'emission_changed':[]}
 for i,x in sorted(rows.items()):
  d=O/str(i);kind,source,*tail=lines[i].split(' ',2);rest=tail[0]if tail else''
  if not x['same_raw']:stats['raw_regressions'].append(i)
  if x.get('same_emission')is False:stats['emission_changed'].append(i)
  if kind=='neg':
   rc=int((d/'candidate.compile.rc').read_text());error=(d/'candidate.compile.stderr').read_text();passed=rc!=0 and rest in error
   if not passed:stats['manifest_raw_failures'].append({'index':i,'source':source,'stage':'negative'})
   continue
  if not(d/'candidate.rc').exists():stats['not_executed'].append({'index':i,'source':source});continue
  rc=int((d/'candidate.rc').read_text());out=(d/'candidate.stdout').read_bytes();err=(d/'candidate.stderr').read_bytes();want_rc=None;want_err=b''
  if kind=='streams':sp,ep=rest.split();want=(R/sp).read_bytes();want_err=(R/ep).read_bytes()
  elif kind=='pos2':sp=rest.split()[0 if target=='linux'else 1];want=(R/sp).read_bytes()
  else:
   if kind=='posx':v,rest=rest.split(' ',1);want_rc=int(v)
   want=subprocess.check_output(['printf','%b',rest])
  raw=out==want and err==want_err and(want_rc is None or want_rc==rc)
  canonical=(out==want if kind in ['streams','pos2'] else out.rstrip(b'\n')==want.rstrip(b'\n'))and err==want_err and(want_rc is None or want_rc==rc)
  if not raw:stats['manifest_raw_failures'].append({'index':i,'source':source,'rc':rc})
  if not canonical:stats['canonical_lf_failures'].append({'index':i,'source':source,'rc':rc})
 stats['emission_changed_cases']=[{'index':i,'source':lines[i].split(' ',2)[1]}for i in stats['emission_changed']]
 summary[target]=stats
(E/'battery-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({t:{k:v if not isinstance(v,list)else len(v)for k,v in s.items()}for t,s in summary.items()},indent=2))
