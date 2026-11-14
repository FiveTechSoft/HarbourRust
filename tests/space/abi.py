#!/usr/bin/env python3
"""GNU as/ld Linux helper canaries and full-byte Space checks.

This supplements emitted-program tests, not native Windows/Mac validation.
"""
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--compiler',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.compiler=a.compiler.resolve();a.output=a.output.resolve()
a.output.mkdir(parents=True,exist_ok=False)
rows=[]
for n in [0,1,7,8,63,64,65,4096,65536,65537]:
    for instrument in [False,True]:
        label=str(n)+'-'+str(instrument);src=a.output/(label+'.prg');asm=src.with_suffix('.s')
        obj=src.with_suffix('.o');exe=src.with_suffix('.program')
        src.write_text('function Main()\nreturn nil\n')
        cmd=[a.compiler,src,asm,'--target=linux']+(['--instrument'] if instrument else [])
        q=subprocess.run(list(map(str,cmd)),capture_output=True);assert q.returncode==0,q.stderr
        text=asm.read_text();assert 'call hbc_fn_main' in text
        text=text.replace('call hbc_fn_main','call hbc_space_test',1)
        text+='''
.text
hbc_space_test:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov $101, %ebx
    mov $102, %r12d
    mov $103, %r13d
    mov $104, %r14d
    mov $105, %r15d
    mov $COUNT, %rdi
    call hbc_space
    cmp $COUNT, %rdx
    jne .Lspace_abi_fail
    mov %rax, (%rsp)
    cmp $101, %rbx
    jne .Lspace_abi_fail
    cmp $102, %r12
    jne .Lspace_abi_fail
    cmp $103, %r13
    jne .Lspace_abi_fail
    cmp $104, %r14
    jne .Lspace_abi_fail
    cmp $105, %r15
    jne .Lspace_abi_fail
    mov %rsp, %rcx
    and $15, %ecx
    jnz .Lspace_abi_fail
    cmpq $COUNT, -16(%rax)
    jne .Lspace_abi_fail
    cmpq $COUNT, -8(%rax)
    jne .Lspace_abi_fail
    xor %ecx, %ecx
1:  cmp $COUNT, %rcx
    jae 2f
    cmpb $32, (%rax,%rcx)
    jne .Lspace_abi_fail
    inc %rcx
    jmp 1b
2:  mov (%rsp), %rdi
    call hbc_freestr
    mov hbc_mem_allocs(%rip), %rax
    cmp hbc_mem_frees(%rip), %rax
    jne .Lspace_abi_fail
    add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
.Lspace_abi_fail:
    mov $60, %eax
    mov $99, %edi
    syscall
'''.replace('COUNT',str(n))
        asm.write_text(text)
        for cmd in [['as',str(asm),'-o',str(obj)],['ld',str(obj),'-o',str(exe)]]:
            q=subprocess.run(cmd,capture_output=True);assert q.returncode==0,q.stderr
        q=subprocess.run([str(exe)],capture_output=True,timeout=30)
        assert(q.returncode,q.stdout,q.stderr)==(0,b'',b''),(label,q.returncode,q.stderr)
        exe.unlink();obj.unlink()
        rows.append(dict(count=n,instrument=instrument,callee_saved=True,headers=True,bytes=True,logical_balance=True,exit=0))
(a.output/'summary.json').write_text(json.dumps(rows,indent=2)+'\n')
print('PASS',len(rows),'GNU as/ld helper canaries')
