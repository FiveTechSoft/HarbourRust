#!/usr/bin/env python3
import argparse,subprocess,pathlib,json,os,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--baseline',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--wine');p.add_argument('--wine-prefix');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=pathlib.Path(__file__).resolve().parent;rows=[];env=dict(os.environ,WINEDEBUG='-all')
if a.wine_prefix:env['WINEPREFIX']=a.wine_prefix
def run(cmd):return subprocess.run(list(map(str,cmd)),capture_output=True,env=env,timeout=30)
for name in ['literals','fallback']:
 src=r/(name+'.prg');hb=a.output/(name+'-hb');q=run([a.hbmk2,src,'-quiet','-gtstd','-o'+str(hb)]);assert q.returncode==0,q.stderr;q=run([hb]);hb.unlink();assert(q.returncode,q.stderr)==(0,b'');expected=q.stdout;(a.output/(name+'.oracle')).write_bytes(expected)
 for memory in [False,True]:
  path=r/(name+('-memory' if memory else '')+'.prg');want=expected+(b'\n         0' if memory else b'')
  for target in ['linux']+(['windows'] if a.wine else []):
   for inst in [False,True]:
    assembly=[]
    for impl,c in [('base',a.baseline),('new',a.compiler)]:
     label=f'{name}-{memory}-{target}-{inst}-{impl}';exe=a.output/label;asm=a.output/(label+'.s');flags=['--target='+target]+(['--instrument'] if inst else [])
     q=run([c,path,asm]+flags);assert q.returncode==0,q.stderr;assembly.append(asm.read_text());q=run([c,path,exe]+flags);assert q.returncode==0,q.stderr;q=run([a.wine,exe] if target=='windows' else [exe]);exe.unlink();(a.output/(label+'.stdout')).write_bytes(q.stdout);(a.output/(label+'.stderr')).write_bytes(q.stderr);assert(q.returncode,q.stdout,q.stderr)==(0,want,b''),(label,q.returncode,q.stdout,want,q.stderr)
     rows.append({'case':label,'status':'PASS'})
    if name=='fallback':assert assembly[0]==assembly[1],('fallback emitted code changed',target,inst,memory)
    else:assert assembly[0]!=assembly[1]
(a.output/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows),'PASS')
