#!/usr/bin/env python3
"""Own rebase regression: startup argv, zero INIT/EXIT and direct-call PCount."""
from pathlib import Path
import argparse,subprocess,json,hashlib,os,sys
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--hbmk2',required=True);p.add_argument('--output',required=True);a=p.parse_args();R=Path(__file__).resolve().parents[2];D=Path(a.output).resolve();D.mkdir(parents=True,exist_ok=False);rows=[]
def run(cmd,w,t):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=R,capture_output=True,stdin=subprocess.DEVNULL,timeout=30)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(R))))
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 return z
for ix,args in enumerate([[],['alpha'],['alpha','beta'],['alpha','beta','extra']]):
 w=D/str(ix);w.mkdir();src=R/'tests/exit-hooks/rebase-main-exit-argv.prg';z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(w/'oracle')],w,'oracle-build');assert z.returncode==0,z.stderr;want=run([w/'oracle',*args],w,'oracle-run');assert want.returncode==0 and not want.stderr
 for mode,flags in [('native',[]),('instrument',['--instrument']),('external',['--external-as','--instrument']),('noprune',['--no-prune','--instrument'])]:
  z=run([a.compiler,src,w/mode,'--target=linux',*flags],w,mode+'-build');assert z.returncode==0,z.stderr;z=run([w/mode,*args],w,mode+'-run');hbc_want=want.stdout;ok=(z.returncode,z.stdout,z.stderr)==(want.returncode,hbc_want,want.stderr);rows.append(dict(argv=args,mode=mode,hbc_contract=ok,oracle_exact=z.stdout==want.stdout,known_delta=None));assert ok,(args,mode,z.returncode,z.stdout,z.stderr,hbc_want)
(D/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print('PASS combined startup/INIT/EXIT/direct PCount: Main/EXIT/direct PCount 4 argv cases x4 modes exact Harbour (INIT deliberately absent)')
