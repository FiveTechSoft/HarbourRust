from pathlib import Path
import argparse,subprocess,json,hashlib,os
p=argparse.ArgumentParser()
for n in ['compiler','hbmk2','output']:p.add_argument('--'+n,required=True)
a=p.parse_args();r=Path(__file__).resolve().parents[2];here=Path(__file__).parent;out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,tag,env=None):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,cwd=r,capture_output=True,env=env,timeout=30)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(tag+'.'+k)).write_bytes(b)
 (w/(tag+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(r),stat_env={k:v for k,v in (env or {}).items()if k in ['LD_PRELOAD','HB_TEST_STAT']}),indent=2)+'\n');return z
src=out/'input.prg';src.write_bytes((here/'basic.prg').read_bytes());(out/'input.sha256').write_text(hashlib.sha256(src.read_bytes()).hexdigest()+'\n')
z=run(['gcc','-shared','-fPIC','-O2',here/'fake.c','-o',out/'fake.so'],out,'fake-build');assert z.returncode==0,z.stderr
z=run([a.hbmk2,src,'-quiet','-gtstd','-w0','-o'+str(out/'oracle')],out,'oracle-build');assert z.returncode==0,z.stderr
cases=[(4096,1000,300,200),(1024,1000001,300003,200007),(512,0,0,0),(1,17,17,0),(4096,1000,1000,1000),(65536,10000000,1234567,765432),(4096,4000000000,2000000000,1000000000),(1,10000000000,9999999999,9999999998),None]
for mode,flags in [('native',[]),('external',['--external-as']),('flat',['--no-vas-arrays']),('noescape',['--no-escape-analysis']),('noprune',['--no-prune'])]:
 w=out/mode;w.mkdir();asm=w/'base.s';z=run([cc,src,asm,'--instrument',*flags],w,'emit');assert z.returncode==0,z.stderr
 text=asm.read_text();lo=text.index('hbc_diskspace_linux:');hi=text.index('.Ldiskspace_free:',lo);assert text[lo:hi].count('    syscall\n')==1;text=text[:lo]+text[lo:hi].replace('    syscall\n','    call fake_statfs\n')+text[hi:]
 for j,values in enumerate(cases):
  d=w/str(j);d.mkdir();s=d/'checked.s';fake='\n.text\nfake_statfs:\n'
  if values is None:fake+='    mov $-2, %rax\n    ret\n'
  else:
   for off,v in zip([8,16,24,32],values):fake+=f'    movabs ${v}, %rax\n    mov %rax, {off}(%rsi)\n'
   fake+='    xor %eax, %eax\n    ret\n'
  s.write_text(text+fake);z=run(['as','--64','-o',d/'checked.o',s],d,'as');assert z.returncode==0,z.stderr
  z=run(['ld','-s','-o',d/'checked',d/'checked.o'],d,'ld');assert z.returncode==0,z.stderr
  env=dict(os.environ,LD_PRELOAD=str(out/'fake.so'),HB_TEST_STAT=','.join(map(str,values))if values else 'fail');want=run([out/'oracle'],d,'oracle',env);got=run([d/'checked'],d,'run')
  assert(want.returncode,want.stdout,want.stderr)==(got.returncode,got.stdout,got.stderr)==(0,want.stdout,b''),(mode,values,want.stdout,got.stdout,got.stderr);rows.append(dict(mode=mode,stat=values,exact=True,snapshot_injected=True));(d/'checked').unlink()
(out/'oracle').unlink();(out/'fake.so').unlink();(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows,scope='Controlled statvfs snapshot in external Harbour, native helper one statfs syscall replaced by same fields. Metadata/format/value/failure triples exact, not changing live filesystem byte parity.'),indent=2)+'\n');print('PASS controlled snapshot',len(rows))
