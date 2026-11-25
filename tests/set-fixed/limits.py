#!/usr/bin/env python3
"""Original MIT. Named compile limits and strict zero after SET FIXED."""
from pathlib import Path
import argparse,subprocess,json,hashlib,sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"trycatch-linux"));from memdelta_guard import DELTA_GUARD
p=argparse.ArgumentParser()
for n in ['compiler','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();out=Path(a.output).resolve();out.mkdir();rows=[]
def run(cmd,w,t,data=b''):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=w,input=data,capture_output=True,timeout=10)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(w),stdin_hex=data.hex())));return z
cases=[('? Set(1,.T.)',[]),('SET FIXED ON',['--target=windows']),('SET FIXED ON',['--target=macho']),('SET FIXED ON',['--experimental-llvm']),('? Set(2,1)',[]),('? Set(2,.T. .AND. .T.)',[]),('SET FIXED maybe',[])]
for i,(stmt,flags)in enumerate(cases):
 w=out/str(i);w.mkdir();s=w/'input.prg';s.write_text('PROCEDURE Main()\n'+stmt+'\nRETURN\n');z=run([a.compiler,s,w/'out',*flags],w,'build');rows.append(dict(case=i,kind='compile-limit',ok=z.returncode==1,stderr=z.stderr.decode(errors='replace')))
for i,prompt in enumerate(['.T.','.F.','.T.']):
 w=out/('zero'+str(i));w.mkdir();s=w/'input.prg';s.write_text('PROCEDURE Main()\nLOCAL x:=15.1004\nSet(2,'+prompt+')\n? x,Str(x)\nRETURN\n');asm=w/'checked.s';b=run([a.compiler,s,asm,'--target=linux','--instrument','--no-prune'],w,'emit');assert b.returncode==0
 text=asm.read_text();anchor='    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n';assert text.count(anchor)==1
 if '    call hbc_arena_flush\n' in text[text.index(anchor):text.index(anchor)+200]:anchor+='    call hbc_arena_flush\n'
 asm.write_text(text.replace(anchor,anchor+DELTA_GUARD.replace('    je .Lprobe_zero\n','')))
 assert run(['as','--64','-o',w/'checked.o',asm],w,'as').returncode==0
 assert run(['ld','-s','-o',w/'exe',w/'checked.o'],w,'ld').returncode==0
 z=run([w/'exe'],w,'run',b'A');rows.append(dict(case=i,kind='strict-zero',ok=z.returncode==99 and z.stderr==b'DELTA=0\n',build_rc=b.returncode,run_rc=z.returncode));(w/'exe').unlink()

(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),rows=rows),indent=2));print(sum(r['ok']for r in rows),'/',len(rows));print([r for r in rows if not r['ok']]);raise SystemExit(not all(r['ok']for r in rows))
