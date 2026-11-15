import argparse,pathlib,subprocess,os,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine',required=True);p.add_argument('--wine-prefix',required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=pathlib.Path(__file__).resolve().parent;rows=[];env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
for name in ['stod','dtos','year','arithmetic']:
 src=r/(name+'.prg');exe=a.output/(name+'base');q=run([a.baseline,src,exe]);assert q.returncode==1 and b'hbc_' in q.stderr and not exe.exists(),(name,q.returncode,q.stderr);(a.output/(name+'-base.stderr')).write_bytes(q.stderr)
 hb=a.output/(name+'hb');q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');want=q.stdout;(a.output/(name+'.oracle')).write_bytes(want)
 for target in ['linux','windows','macho']:
  for inst in [False,True]:
   label=name+target+str(inst);exe=a.output/label;q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,(label,q.stderr)
   if target!='macho':
    q=run([a.wine,exe] if target=='windows' else [exe]);(a.output/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,want,b''),(label,q.returncode,q.stdout,want,q.stderr)
   exe.unlink();rows.append({'case':label,'status':'emission only' if target=='macho' else 'exact'})
(a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'PASS,4 baseline failures reproduced')
