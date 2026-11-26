#!/usr/bin/env python3
"""Own MIT regression contract for bounded scalar variadic headers."""
from pathlib import Path
import argparse,subprocess,json,sys,os,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();T=Path(__file__).resolve().parent;R=T.parents[1];D=Path(a.output).resolve();D.mkdir(parents=True,exist_ok=False);cc=str(Path(a.compiler).resolve());rows=[]
sys.path.insert(0,str(R/'tests/trycatch-linux'));from memdelta_guard import emit_delta
positive=['count','named','mixed','owned','effect','recursive','unused','noinspect']
negative={'ref':'by-value scalar','forward':'forwarding and array/codeblock','array':'forwarding and array/codeblock','invalid-middle':'final function parameter','malformed-comma':'final function parameter','block-limit':'direct calls without','date-limit':'typed scalar or literal NIL','array-limit':'typed scalar or literal NIL','nested':'typed scalar or literal NIL','dyn-limit':'typed scalar or literal NIL','main-limit':'variadic Main','init-limit':'variadic INIT/EXIT','arity-limit':'64 scalar arguments','thread-limit':'direct calls without'}
def run(cmd,w,label):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=R,capture_output=True,stdin=subprocess.DEVNULL,timeout=60)
 (w/(label+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(R))))
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(label+'.'+k)).write_bytes(b)
 return z
for n in positive:
 w=D/n;w.mkdir();src=T/(n+'.prg');want=(T/(n+'.out')).read_bytes()
 for mode in ['normal','instrument']:
  exe=w/mode;z=run([cc,src,exe,'--target=linux']+(['--instrument']if mode=='instrument'else[]),w,mode+'-build');assert z.returncode==0,(n,z.stderr)
  z=run([exe],w,mode+'-run');assert(z.returncode,z.stdout,z.stderr)==(0,want,b''),(n,mode,z.returncode,z.stdout,z.stderr)
 b=w/'balance';b.mkdir();r=emit_delta(cc,os.environ,src,b,want);assert r['state_ok']and r['delta']==0,(n,r);rows.append(dict(name=n,kind='exact-saved-oracle-and-balance',**r))
for n,needle in negative.items():
 w=D/n;w.mkdir();z=run([cc,T/(n+'.prg'),w/'rejected','--target=linux'],w,'build');assert z.returncode==1 and needle.encode()in z.stderr,(n,z.returncode,z.stderr);rows.append(dict(name=n,kind='named-limit',rc=z.returncode))
for target in ['windows','macho','macho-arm64']:
 w=D/target;w.mkdir();z=run([cc,T/'count.prg',w/'rejected.s','--target='+target],w,'build');assert z.returncode==1 and b'variadic headers require ordinary Linux'in z.stderr,(target,z.stderr);rows.append(dict(name=target,kind='profile-guard'))
(D/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2));print('PASS variadic-header: 8 positives normal+instrumented+balance, 14 named limits, 3 profile guards')
