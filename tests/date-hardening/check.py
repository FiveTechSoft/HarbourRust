import pathlib,subprocess,argparse,os,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine',required=True);p.add_argument('--wine-prefix',required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=pathlib.Path(__file__).resolve().parent;rows=[];env=dict(os.environ,WINEDEBUG='-all',WINEPREFIX=a.wine_prefix)
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
hb=a.output/'hb';q=run([a.hbmk2,r/'empty.prg','-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');want=q.stdout;(a.output/'harbour.stdout').write_bytes(want)
for memory in [False,True]:
 for target in ['linux','windows','macho']:
  for inst in [False,True]:
   label=f'{memory}-{target}-{inst}';src=r/('empty-memory.prg' if memory else 'empty.prg');exe=a.output/label;q=run([a.compiler,src,exe,'--target='+target]+(['--instrument'] if inst else []));assert q.returncode==0,q.stderr
   if target!='macho':
    q=run([a.wine,exe] if target=='windows' else [exe]);(a.output/(label+'.stdout')).write_bytes(q.stdout);assert(q.returncode,q.stdout,q.stderr)==(0,want+(b'\n         0' if memory else b''),b''),(label,q.returncode,q.stdout,q.stderr)
   exe.unlink();rows.append({'case':label,'status':'emission only' if target=='macho' else 'exact/registry0' if memory else 'exact'})
for name in ['dtos','stod','year','date_add','date_diff','date_days','date_from_days']:
 src=a.output/(name+'.prg');src.write_text('function '+name+'()\nreturn nil\nfunction Main()\nreturn nil\n');out=a.output/name;q=run([a.compiler,src,out]);assert q.returncode==1 and b'reserved' in q.stderr and not out.exists(),(name,q.returncode,q.stderr);(a.output/(name+'.stderr')).write_bytes(q.stderr);rows.append({'collision':name,'status':'named rejection'})
(a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'PASS')
