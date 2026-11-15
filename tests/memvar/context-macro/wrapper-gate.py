from pathlib import Path
import subprocess,os,json,hashlib
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'wrapper';E.mkdir(exist_ok=True)
env=os.environ.copy();env.update(WINEPREFIX='/tmp/hr-win11-prefix',WINEDEBUG='-all')
C='''#include <assert.h>\n#include <stdio.h>\n#include <stdint.h>\nextern uint64_t __attribute__((sysv_abi)) hrctx_gate(void);\nint main(void){assert(hrctx_gate()==0);puts("new.SysV.wrappers.sentinels.stack.parities.raw.exactsize.float.slot16.balance=PASS");return 0;}\n'''
(E/'client.c').write_text(C)
for target in ['linux','windows']:
 d=E/target;d.mkdir(exist_ok=True);s=d/'product.s';q=subprocess.run([os.environ.get('HB_B2_COMPILER','/tmp/hr-b2-hbc-final'),str(R/'tests/memvar/context-macro/fixtures/mixed.prg'),str(s),'--target='+target,'--instrument'],capture_output=True);assert not q.returncode,q.stderr
 text=s.read_text().replace('.globl _start','.globl hrctx_unused_start').replace('\n_start:','\nhrctx_unused_start:');extra='\n.text\n.globl hrctx_gate\nhrctx_gate:\npush %rbp\nmov %rsp,%rbp\npush %rbx\npush %r12\npush %r13\npush %r14\npush %r15\nsub $152,%rsp\nmovq $0,-56(%rbp)\n'
 for parity in [0,8]:
  extra+=f'sub ${parity},%rsp\nmov %rsp,-64(%rbp)\n'
  for name in ['hrm_raw_alloc','hrm_raw_free','hrm_export_float','hbc_freestr','hrm_export_string','hbc_freestr']:
   for reg in ['rbx','r12','r13','r14','r15']:extra+='mov $0x12345678,%'+reg+'\n'
   if name=='hrm_raw_alloc':extra+='xor %edi,%edi\nmov $37,%esi\n'
   elif name=='hrm_raw_free':extra+='xor %edi,%edi\nmov -72(%rbp),%rsi\nmov $37,%edx\n'
   elif name=='hrm_export_float':extra+='xor %edi,%edi\nmov $0x400c000000000000,%rsi\nmov $655364,%edx\nlea -112(%rbp),%rcx\n'
   elif name=='hrm_export_string':extra+='xor %edi,%edi\nlea .Lctx_text(%rip),%rsi\nmov $5,%edx\nlea -112(%rbp),%rcx\n'
   else:extra+='mov -104(%rbp),%rdi\n'
   extra+='call '+name+'\ncmp %rsp,-64(%rbp)\nje 1f\norq $1,-56(%rbp)\n1:\n'
   for reg in ['rbx','r12','r13','r14','r15']:extra+='cmp $0x12345678,%'+reg+'\nje 1f\norq $2,-56(%rbp)\n1:\n'
   if name=='hrm_raw_alloc':extra+='mov %rax,-72(%rbp)\ncmpq $37,-8(%rax)\nje 1f\norq $4,-56(%rbp)\n1:\n'
   if name=='hrm_export_float':extra+='mov -104(%rbp),%rax\nmov $0x400c000000000000,%rcx\ncmp (%rax),%rcx\nje 1f\norq $8,-56(%rbp)\n1:\ncmpq $655364,8(%rax)\nje 1f\norq $8,-56(%rbp)\n1:\n'
  extra+=f'add ${parity},%rsp\n'
 extra+='mov hbc_mem_allocs(%rip),%rax\nsub hbc_mem_frees(%rip),%rax\njz 1f\norq $16,-56(%rbp)\n1:\nmov -56(%rbp),%rax\nlea -40(%rbp),%rsp\npop %r15\npop %r14\npop %r13\npop %r12\npop %rbx\npop %rbp\nret\n.data\n.Lctx_text: .byte 111,119,110,101,100\n'
 s.write_text(text+extra);obj=d/'product.o';binary=d/('gate.exe'if target=='windows'else'gate');prefix='/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-'if target=='windows'else''
 q=subprocess.run([prefix+'as',str(s),'-o',str(obj)],capture_output=True);assert not q.returncode,q.stderr
 q=subprocess.run([prefix+'gcc-posix'if target=='windows'else'gcc',str(E/'client.c'),str(obj),'-lm','-o',str(binary)]+([]if target=='windows'else['-no-pie']),capture_output=True);(d/'build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
 (d/'binary.sha256').write_text(hashlib.sha256(binary.read_bytes()).hexdigest()+'\n')
 q=subprocess.run((['/tmp/hr-wine11/opt/wine-stable/bin/wine']if target=='windows'else[])+[str(binary)],capture_output=True,env=env,timeout=10)
 for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('run.'+k)).write_bytes(v)
 print(target,q.returncode,q.stdout,q.stderr);assert not q.returncode
 (d/'symbols.txt').write_bytes(subprocess.check_output([prefix+'nm',str(obj)]));(d/'objdump.txt').write_bytes(subprocess.check_output([prefix+'objdump','-d',str(obj)]));obj.unlink();binary.unlink()
