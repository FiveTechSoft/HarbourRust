from pathlib import Path
import subprocess,json,hashlib,re
r=Path('/tmp/exit-noticeguard-boundaries');r.mkdir();rows=[]
def run(cmd,w,t,data=b''):
 z=subprocess.run(list(map(str,cmd)),cwd=w,input=data,capture_output=True,timeout=10)
 for k,b in [('stdout',z.stdout),('stderr',z.stderr),('rc',str(z.returncode).encode())]:(w/(t+'.'+k)).write_bytes(b)
 (w/(t+'.command.json')).write_text(json.dumps(dict(argv=list(map(str,cmd)),cwd=str(w),stdin_hex=data.hex())));return z
src='PROCEDURE Main()\n? ""\nRETURN\nEXIT PROCEDURE Hook()\n? "exit"\nRETURN\n'
s=r/'input.prg';s.write_text(src);asm=r/'runtime.s';b=run(['/dev/shm/exit-noticeguard-hbc',s,asm,'--instrument','--no-prune'],r,'emit');assert b.returncode==0;text=asm.read_text()
assert text.index('hbc_exit_hooks_completed(%rip)')<text.index('    call hbc_persistent_cleanup\n    call hbc_str_cache_flush\n')
# A synthetic final status is not ErrorLevel implementation. It exercises
# completed-hook state and retains actual cleanup/GTSTD close before exit.
anchor='    mov $60, %eax\n    xor %edi, %edi\n';assert text.count(anchor)==1
status=text.replace(anchor,'    mov $60, %eax\n    mov $7, %edi\n',1)
for name,code,expected_rc,expected_stdout,expected_stderr in [('status7',status,7,b'\n\nexit',b'')]:
 f=r/(name+'.s');f.write_text(code);assert run(['as',f,'-o',r/(name+'.o')],r,name+'-as').returncode==0;assert run(['ld',r/(name+'.o'),'-o',r/name],r,name+'-ld').returncode==0;z=run([r/name],r,name+'-run');assert(z.returncode,z.stdout,z.stderr)==(expected_rc,expected_stdout,expected_stderr),(z.returncode,z.stdout,z.stderr);rows.append(dict(case=name,pass_=True));(r/name).unlink();(r/(name+'.o')).unlink()
# Exact emitted helper, called using the exact emitted 128-byte reservation.
start=text.index('hbc_exit_fatal_notice:\n');end=text.index('\n.text\n',start)+len('\n.text\n');helper=text[start:end];assert 'hbc_exit_hooks_completed' in helper
for variant,completed,exitcode in [('nonexit',0,39),('fatal',0,60),('completed',1,60)]:
 # For fatal variant invoke notice, then check canaries before clean exit0.
 code='''.globl _start
.text
_start:
    movq $12345, -8(%rsp)
    movq $67890, -128(%rsp)
    mov $SYSCALLNO, %eax
    mov $7, %edi
    mov $23456, %esi
    mov $34567, %edx
    mov $45678, %ecx
    mov $56789, %r11d
    cmp %rax, %rax
    lea -128(%rsp), %rsp
    call hbc_exit_fatal_notice
    lea 128(%rsp), %rsp
    jne fail
    cmp $SYSCALLNO, %eax
    jne fail
    cmp $7, %edi
    jne fail
    cmp $23456, %esi
    jne fail
    cmp $34567, %edx
    jne fail
    cmp $45678, %ecx
    jne fail
    cmp $56789, %r11d
    jne fail
    cmpq $12345, -8(%rsp)
    jne fail
    cmpq $67890, -128(%rsp)
    jne fail
    xor %edi, %edi
    jmp done
fail:
    mov $99, %edi
done:
    mov $60, %eax
    syscall
.data
.align 8
hbc_exit_hooks_completed: .quad COMPLETED
.text
'''.replace('SYSCALLNO',str(exitcode)).replace('COMPLETED',str(completed))+helper
 f=r/('canary-'+variant+'.s');f.write_text(code);assert run(['as',f,'-o',r/'canary.o'],r,variant+'-as').returncode==0;assert run(['ld',r/'canary.o','-o',r/'canary'],r,variant+'-ld').returncode==0;z=run([r/'canary'],r,variant+'-run');assert z.returncode==0 and z.stdout==b'';assert z.stderr==(b'EXIT hooks skipped: fatal runtime termination (normal-return-only)\n'if variant=='fatal'else b'');rows.append(dict(case='redzone-regs-flags-'+variant,pass_=True));(r/'canary').unlink();(r/'canary.o').unlink()
# Pending empty QOut must precede fatal diagnostic in merged stream.
w=r/'pending';w.mkdir();s=w/'input.prg';s.write_text('PROCEDURE Main()\nLOCAL a:=1,b:=0\n? ""\n? a/b\nRETURN\nEXIT PROCEDURE Hook()\n? "exit"\nRETURN\n');assert run(['/dev/shm/exit-noticeguard-hbc',s,w/'exe','--instrument'],w,'build').returncode==0
with (w/'merged.stdout').open('wb')as f:z=subprocess.run([w/'exe'],cwd=w,input=b'',stdout=f,stderr=subprocess.STDOUT,timeout=10)
(w/'merged.rc').write_text(str(z.returncode));data=(w/'merged.stdout').read_bytes();assert z.returncode==1 and data.startswith(b'\nError: division by zero\n') and data.endswith(b'EXIT hooks skipped: fatal runtime termination (normal-return-only)\n');rows.append(dict(case='pending-empty-qout-merged',pass_=True));(w/'exe').unlink()
(r/'results.json').write_text(json.dumps(dict(compiler_sha256=hashlib.sha256(Path('/dev/shm/exit-noticeguard-hbc').read_bytes()).hexdigest(),rows=rows,scope='Emitted helper canaries and synthetic final status, not ErrorLevel support. Normal actual cleanup and gtstd_close retained in status7. Fatal abort does not flush string caches or execute persistent cleanup, divergence remains open.'),indent=2));print(rows)
