from pathlib import Path
import subprocess,os,shutil,json
import argparse,hashlib
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2',required=True);ap.add_argument('--wine',required=True);ap.add_argument('--wine-prefix',required=True);ap.add_argument('--mingw-bin',required=True);ap.add_argument('--output',required=True);a=ap.parse_args()
r=Path(__file__).resolve().parents[2];out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=False)
env=os.environ.copy();env.update(PATH=a.mingw_bin+':'+env['PATH'],HB_CCPATH=a.mingw_bin+'/',HB_CCPREFIX='x86_64-w64-mingw32-',HB_CCSUFFIX='-posix',WINEPREFIX=a.wine_prefix,WINEDEBUG='-all');hb=Path(a.hbmk2).resolve();wine=Path(a.wine).resolve();compiler=Path(a.compiler).resolve();rows=[];commands=[]
(out/'compiler.sha256').write_text(hashlib.sha256(compiler.read_bytes()).hexdigest()+'\n')
def run(cmd,d,label,extra={}):
 commands.append(dict(argv=[str(x) for x in cmd],cwd=str(d),label=label));(out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
 p=subprocess.run([str(x) for x in cmd],cwd=d,env={**env,**extra},capture_output=True,timeout=60)
 for ext,data in [('stdout',p.stdout),('stderr',p.stderr),('rc',str(p.returncode).encode())]:(d/(label+'.'+ext)).write_bytes(data)
 assert p.returncode==0,(d,label,p.returncode,p.stderr)
 return p
for family,builders in [('dbf',['fixtures','widths']),('ntx',['fixtures','variants','wide-fixture']),('cdx',['fixtures','variants','wide-fixture','deep-fixture'])]:
 d=out/family;d.mkdir()
 for name in builders:
  shutil.copyfile(r/'tests'/family/(name+'.prg'),d/(name+'.prg'))
  run([hb,name+'.prg','-plat=win','-comp=mingw64','-gtstd','-o'+name],d,name+'-build');run([wine,d/(name+'.exe')],d,name+'-run')
 for source in sorted((r/'tests'/family/'programs').glob('*.prg')):
  shutil.copyfile(source,d/'probe.prg');run([hb,'probe.prg','-plat=win','-comp=mingw64','-gtstd','-ooracle'],d,source.stem+'-oracle-build');ref=run([wine,d/'oracle.exe'],d,source.stem+'-oracle-run')
  for mode,flags in [('normal',[]),('instrument',['--instrument'])]:
   label=source.stem+'-'+mode
   run([compiler,'probe.prg','candidate.exe','--target=windows',*flags],d,label+'-build')
   p=run([wine,d/'candidate.exe'],d,label+'-run',{'HB_MEMCHECK':'1'})
   ok=p.stdout.replace(b'\r\n',b'\n')==ref.stdout.replace(b'\r\n',b'\n') and p.stderr==ref.stderr
   rows.append(dict(family=family,case=source.name,mode=mode,CRLF_normalised=True,match=ok));(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print(rows[-1],flush=True)
   assert ok,(d,label)
assert (out/'compiler.sha256').read_text().strip()==hashlib.sha256(compiler.read_bytes()).hexdigest()
print('PASS',len(rows))
