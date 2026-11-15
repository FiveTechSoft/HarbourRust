#!/usr/bin/env python3
"""Linux native-encoder guard-page and internal ABI test, no libc."""
import argparse,pathlib,subprocess,json
p=argparse.ArgumentParser();p.add_argument('--compiler',required=True);p.add_argument('--driver',required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);r=a.output
src=r/'empty.prg';src.write_text('function Main()\nreturn nil\n');asm=r/'probe.s';q=subprocess.run([a.compiler,str(src),str(asm),'--instrument'],capture_output=True);assert q.returncode==0,q.stderr
code=asm.read_text().replace('call hbc_fn_main','call guard_probe',1)
b=['.text','guard_probe:','push %rbp','mov %rsp,%rbp','push %rbx','push %r12','push %r13','push %r14','push %r15','sub $24,%rsp']
# Two independent mappings, writable middle page with inaccessible neighbors.
for off in [0,8]:
 b+=['xor %edi,%edi','mov $12288,%esi','xor %edx,%edx','mov $34,%r10d','mov $-1,%r8','xor %r9d,%r9d','mov $9,%eax','syscall','test %rax,%rax','js guard_fail',f'mov %rax,{off}(%rsp)','lea 4096(%rax),%rdi','mov $4096,%esi','mov $3,%edx','mov $10,%eax','syscall','test %rax,%rax','jnz guard_fail']
b+=['mov $101,%ebx','mov $102,%r12d','mov $103,%r13d','mov $104,%r14d','mov $105,%r15d']
cases=0
for byte in [0,1,127,128,255]:
 for n in range(66):
  for side in ['left','right']:
   for kind in ['missing','first','last'] if n else ['missing']:
    # Needle is ONE byte immediately before an inaccessible page.
    other=(byte+1)%256;cases+=1
    b+=['mov 8(%rsp),%rdi','add $8191,%rdi',f'movb ${byte},(%rdi)','mov (%rsp),%rdx',f'add ${4096 if side=="left" else 8192-n},%rdx']
    for i in range(n):b.append(f'movb ${other},{i}(%rdx)')
    expected=0
    if kind!='missing':idx=0 if kind=='first' else n-1;b.append(f'movb ${byte},{idx}(%rdx)');expected=idx+1
    b+=['mov $1,%esi',f'mov ${n},%ecx','call hbc_at',f'cmp ${expected},%rax','jne guard_fail','cmp $101,%rbx','jne guard_fail','cmp $102,%r12','jne guard_fail','cmp $103,%r13','jne guard_fail','cmp $104,%r14','jne guard_fail','cmp $105,%r15','jne guard_fail','mov %rsp,%rax','and $15,%eax','jnz guard_fail']
# Empty-needle fallback receives inaccessible pointers and must not dereference.
b+=['mov (%rsp),%rdi','xor %esi,%esi','mov 8(%rsp),%rdx','mov $99,%ecx','call hbc_at','test %rax,%rax','jnz guard_fail']
for off in [0,8]:b+=[f'mov {off}(%rsp),%rdi','mov $12288,%esi','mov $11,%eax','syscall','test %rax,%rax','jnz guard_fail']
b+=['cmpq $0,hbc_reg_count(%rip)','jne guard_fail','add $24,%rsp','pop %r15','pop %r14','pop %r13','pop %r12','pop %rbx','leave','ret','guard_fail:','mov $60,%eax','mov $99,%edi','syscall']
asm.write_text(code+'\n'+'\n'.join(b)+'\n');exe=r/'guard';q=subprocess.run([a.driver,'elf',str(asm),str(exe)],capture_output=True,timeout=90);assert q.returncode==0,q.stderr
exe.chmod(0o755);q=subprocess.run([str(exe)],capture_output=True,timeout=15);assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(q.returncode,q.stdout,q.stderr)
(r/'results.json').write_text(json.dumps({'native_encoder':True,'guard_page_cases':cases,'text_lengths':'0..65, left/right page edge','needle_one_byte_at_page_end':True,'empty_needle_inaccessible_pointers':True,'callee_saved_stack':True,'registry0':True},indent=2)+'\n');print(cases,'guard-page/ABI cases PASS')
