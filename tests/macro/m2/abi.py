from pathlib import Path
import subprocess,os,hashlib
R=Path(__file__).resolve().parents[3];E=R/'evidence'/'m2-abi';E.mkdir(exist_ok=True)
# Host adaptation (2026-11-24): HB_M2_COMPILER overrides the recorded /tmp
# compiler; on a Windows host the windows gate is assembled/linked/run with
# the bundled MinGW directly (no cross toolchain, no Wine). The linux gate
# keeps the recorded environment.
cc=os.environ.get('HB_M2_COMPILER','/tmp/hr-m2-hbc');native=os.name=='nt'
mingw=str(R/'tools/mingw/mingw64/bin') + ('\\' if native else '/') if native else '/tmp/hr-win-root/usr/bin/x86_64-w64-mingw32-'
if native:mingw=mingw.replace('\\','/')
env=os.environ.copy()
if not native:env.update(WINEPREFIX='/tmp/hr-m2-wine11-prefix',WINEDEBUG='-all')
(E/'client.c').write_text('#include <assert.h>\n#include <stdint.h>\n#include <stdio.h>\nextern uint64_t __attribute__((sysv_abi)) m2gate(void);\nint main(void){assert(m2gate()==0);puts("M2.dispatch.realhelpers.GPR.stackparity.args_unchanged.ownership.balance0=PASS");return 0;}\n')
for target in ['windows']if native else['linux','windows']:
 d=E/target;d.mkdir(exist_ok=True);asm=d/'production.s';q=subprocess.run([cc,str(R/'tests/macro/m2/mixed.prg'),str(asm),'--target='+target,'--instrument'],capture_output=True);assert not q.returncode,q.stderr
 s=asm.read_text().replace('.globl _start','.globl m2_unused_start').replace('\n_start:','\nm2_unused_start:')
 s+='\n.text\n.globl m2gate\nm2gate:\npush %rbp\nmov %rsp,%rbp\npush %rbx\npush %r12\npush %r13\npush %r14\npush %r15\nsub $168,%rsp\nmovq $0,-56(%rbp)\n'
 for parity in [0,8]:
  s+=f'sub ${parity},%rsp\nmov %rsp,-64(%rbp)\n'
  for id in [1,2,3,4,5]:
   # Actual production compiler-owned first argument and second int.
   s+='xor %edi,%edi\nlea -144(%rbp),%rcx\n'
   if id in [1,2,5]:s+='lea .Lm2text(%rip),%rsi\nmov $5,%edx\ncall hrm_export_string\n'
   else:s+='mov $0x400c000000000000,%rsi\nmov $655362,%edx\ncall hrm_export_float\n'
   s+='mov -136(%rbp),%rax\nmov %rax,-72(%rbp)\nmovq $0,-128(%rbp)\nmovq $2,-120(%rbp)\n'
   for reg in ['rbx','r12','r13','r14','r15']:s+='mov $0x12345678,%'+reg+'\n'
   s+=f'mov ${id},%edi\nmov $2,%esi\nlea -144(%rbp),%rdx\nlea -112(%rbp),%rcx\ncall hrm_call\ncmp $1,%eax\nje 1f\norq $1,-56(%rbp)\n1:\ncmp %rsp,-64(%rbp)\nje 1f\norq $2,-56(%rbp)\n1:\n'
   for reg in ['rbx','r12','r13','r14','r15']:s+='cmp $0x12345678,%'+reg+'\nje 1f\norq $4,-56(%rbp)\n1:\n'
   s+='mov -72(%rbp),%rax\ncmp -136(%rbp),%rax\nje 1f\norq $8,-56(%rbp)\n1:\n'
   if id!=5:s+='mov -104(%rbp),%rdi\ncall hbc_freestr\n' # ASC returns an int tag 0: no owned result to free
   s+='mov -72(%rbp),%rdi\ncall hbc_freestr\n'
  s+=f'add ${parity},%rsp\n'
 s+='mov hbc_mem_allocs(%rip),%rax\nsub hbc_mem_frees(%rip),%rax\njz 1f\norq $16,-56(%rbp)\n1:\nmov -56(%rbp),%rax\nlea -40(%rbp),%rsp\npop %r15\npop %r14\npop %r13\npop %r12\npop %rbx\npop %rbp\nret\n.data\n.Lm2text: .ascii "OwNeD"\n'
 asm.write_text(s);obj=d/'a.o';exe=d/('gate.exe'if target=='windows'else'gate')
 subprocess.run([mingw+'as.exe'if native else mingw+'as',str(asm),'-o',str(obj)],check=True)
 link=[mingw+('gcc.exe'if native else 'gcc-posix'),str(E/'client.c'),str(obj),'-lm','-o',str(exe)]
 if target=='linux':link.append('-no-pie')
 q=subprocess.run(link,capture_output=True);(d/'build.stderr').write_bytes(q.stderr);assert not q.returncode,q.stderr
 (d/'binary.sha256').write_text(hashlib.sha256(exe.read_bytes()).hexdigest()+'\n')
 if native:q=subprocess.run([str(exe)],capture_output=True,timeout=45)
 else:q=subprocess.run((['/tmp/hr-wine11/opt/wine-stable/bin/wine']if target=='windows'else[])+[str(exe)],env=env,capture_output=True,timeout=45)
 for k,v in [('stdout',q.stdout),('stderr',q.stderr),('rc',str(q.returncode).encode()+b'\n')]: (d/('run.'+k)).write_bytes(v)
 print(target,q.returncode,q.stdout,q.stderr,flush=True);assert not q.returncode
 objdump=mingw+'objdump.exe'if native else mingw+'objdump'
 (d/'objdump.txt').write_bytes(subprocess.check_output([objdump,'-d',str(obj)]));exe.unlink();obj.unlink()
