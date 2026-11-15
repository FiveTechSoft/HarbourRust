#!/usr/bin/env python3
"""Native encoder Linux guard-page read/write probe. Allocator replaced ONLY here.
Real allocator/headers/registry are exercised separately by ABI/ownership tests.
"""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser()
for x in ['compiler','driver','output']:p.add_argument('--'+x,required=True)
a=p.parse_args();r=pathlib.Path(a.output);r.mkdir(parents=True,exist_ok=False);src=r/'empty.prg';src.write_text('function Main()\nreturn nil\n');asm=r/'probe.s';q=subprocess.run([a.compiler,str(src),str(asm),'--instrument'],capture_output=True);assert q.returncode==0,q.stderr
code=asm.read_text().replace('call hbc_fn_main','call guard_probe',1).replace('\nhbc_stralloc:\n','\nhbc_real_stralloc:\n',1)
b=['.text','hbc_stralloc:','mov guard_dest(%rip),%rax','mov %rsi,%rdx','ret','guard_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $24,%rsp']
for label in ['guard_srcmap','guard_dstmap']:
 b+=['xor %edi,%edi','mov $12288,%esi','xor %edx,%edx','mov $34,%r10d','mov $-1,%r8','xor %r9d,%r9d','mov $9,%eax','syscall','test %rax,%rax','js guard_fail',f'mov %rax,{label}(%rip)','lea 4096(%rax),%rdi','mov $4096,%esi','mov $3,%edx','mov $10,%eax','syscall','test %rax,%rax','jnz guard_fail']
# RBX=n,R12=byte,R13=side; caller-save loop position kept in stack/globals.
b+=['xor %ebx,%ebx','guard_n:','xor %r12d,%r12d','guard_byte:','xor %r13d,%r13d','guard_side:']
for name,lo,hi,op in [('upper',97,122,'sub'),('lower',65,90,'add')]:
 for delta in range(16):
  tag=f'guard_{name}_{delta}'
  b+=['mov guard_srcmap(%rip),%rdi','add $4096,%rdi','mov guard_dstmap(%rip),%r14','add $4096,%r14','test %r13,%r13',f'jz {tag}_left','add $4096,%rdi','sub %rbx,%rdi',f'sub ${delta},%rdi','add $4096,%r14','sub %rbx,%r14',f'jmp {tag}_ready',tag+'_left:',f'add ${delta},%rdi',tag+'_ready:','mov %rdi,guard_source(%rip)','mov %r14,guard_dest(%rip)','mov %rbx,%rcx','mov %r12b,%al','rep stosb','mov guard_source(%rip),%rdi','mov %rbx,%rsi',f'call hbc_{name}','cmp %r14,%rax','jne guard_fail','cmp %rbx,%rdx','jne guard_fail','mov %rsp,%rcx','and $15,%ecx','jnz guard_fail','mov %r12d,%r15d',f'cmp ${lo},%r15d',f'jb {tag}_expect',f'cmp ${hi},%r15d',f'ja {tag}_expect',f'{op} $32,%r15d',tag+'_expect:','xor %ecx,%ecx',tag+'_check:','cmp %rbx,%rcx',f'jae {tag}_done','cmp %r15b,(%rax,%rcx)','jne guard_fail','mov guard_source(%rip),%rdi','cmp %r12b,(%rdi,%rcx)','jne guard_fail','inc %rcx',f'jmp {tag}_check',tag+'_done:']
b+=['inc %r13','cmp $2,%r13','jb guard_side','inc %r12','cmp $256,%r12','jb guard_byte','inc %rbx','cmp $66,%rbx','jb guard_n']
# Zero length with inaccessible source AND destination must touch neither.
for name in ['upper','lower']:
 b+=['mov guard_srcmap(%rip),%rdi','mov guard_dstmap(%rip),%rax','mov %rax,guard_dest(%rip)','xor %esi,%esi',f'call hbc_{name}','test %rdx,%rdx','jnz guard_fail']
for label in ['guard_srcmap','guard_dstmap']:
 b+=[f'mov {label}(%rip),%rdi','mov $12288,%esi','mov $11,%eax','syscall','test %rax,%rax','jnz guard_fail']
b+=['add $24,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','leave','ret','guard_fail:','mov $60,%eax','mov $99,%edi','syscall','.data','.p2align 3']
for label in ['guard_source','guard_dest','guard_srcmap','guard_dstmap']:b+=[label+': .quad 0']
asm.write_text(code+'\n'+'\n'.join(b)+'\n');exe=r/'guard';q=subprocess.run([a.driver,'elf',str(asm),str(exe)],capture_output=True,timeout=90);assert q.returncode==0,q.stderr;exe.chmod(0o755);q=subprocess.run([str(exe)],capture_output=True,timeout=30);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(q.returncode,q.stdout,q.stderr)
(r/'results.json').write_text(json.dumps(dict(cases=66*256*2*2*16+2,native_encoder=True,lengths='0..65',bytes='0..255',page_edges='source and destination left/right; source offsets0..15',source_unchanged=True,zero_inaccessible=True,allocator='stubbed ONLY for exact destination guards'),indent=2)+'\n');print(66*256*2*2*16+2,'guard cases PASS')
