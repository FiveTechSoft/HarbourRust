from pathlib import Path
import argparse,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--output',required=True);a=p.parse_args();out=Path(a.output).resolve();out.mkdir();cc=str(Path(a.compiler).resolve());rows=[]
def run(cmd,w,t):
 cmd=list(map(str,cmd));z=subprocess.run(cmd,capture_output=True,timeout=20)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=cmd,cwd=str(Path.cwd())))+'\n');return z
base='PROCEDURE Main()\nTone(440,9.1)\nRETURN\n'
cases=[('windows',base,['--target=windows']),('macho',base,['--target=macho']),('arm',base,['--target=macho-arm64']),('llvm',base,['--experimental-llvm']),('threads','function Work()\nreturn 1\n'+base.replace('Tone','local t:=hb_threadStart(@Work())\nTone'),[]),('noargs',base.replace('(440,9.1)','()'),[]),('onearg',base.replace('(440,9.1)','(440)'),[]),('extra',base.replace('(440,9.1)','(440,9.1,1)'),[]),('string',base.replace('(440,9.1)','("x",9.1)'),[]),('nil',base.replace('(440,9.1)','(NIL,9.1)'),[]),('computed',base.replace('(440,9.1)','(440,9+0.1)'),[]),('dynamic',base.replace('Tone','local n:=9.1\nTone').replace('(440,9.1)','(440,n)'),[]),('long',base.replace('(440,9.1)','(440,183)'),[]),('negative',base.replace('(440,9.1)','(440,-1)'),[])]
for name,text,flags in cases:
 w=out/name;w.mkdir();src=w/'input.prg';src.write_text(text);z=run([cc,src,w/'bad',*flags],w,'build');assert z.returncode==1 and not(w/'bad').exists(),(name,z.stderr);rows.append(dict(case=name,compile_limit=True))
w=out/'runtime';w.mkdir();src=w/'input.prg';src.write_text(base);asm=w/'base.s';z=run([cc,src,asm],w,'emit');assert z.returncode==0
for name,syscall,ret in [('tty',16,0),('realtime-fail',96,-1),('monotonic-fail',228,-1),('select-fail',23,-1)]:
 d=w/name;d.mkdir();checked=d/'checked.s';fake='\n.text\nfake_syscall:\n    cmp $'+str(syscall)+', %rax\n    jne 91f\n    mov $'+str(ret)+', %rax\n    ret\n91:\n    syscall\n    ret\n';checked.write_text(asm.read_text().replace('    syscall\n','    call fake_syscall\n')+fake);z=run(['as','--64','-o',d/'checked.o',checked],d,'as');assert z.returncode==0;z=run(['ld','-s','-o',d/'exe',d/'checked.o'],d,'ld');assert z.returncode==0;z=run([d/'exe'],d,'run');assert z.returncode==1 and b'Limit: Tone requires non-TTY output and working Linux clocks/select\n' in z.stdout and not z.stderr,(name,z.returncode,z.stdout,z.stderr);(d/'exe').unlink();rows.append(dict(case=name,named_runtime_limit=True))
(out/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path(cc).read_bytes()).hexdigest(),rows=rows),indent=2)+'\n');print('PASS',len(rows))
