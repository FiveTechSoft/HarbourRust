import pathlib,sys
win=len(sys.argv)>1;key='w' if win else 'l';s='.text\n.globl abi_check\nabi_check:\n    push %rbp\n    mov %rsp, %rbp\n    sub $224, %rsp\n'
regs=['rbx','r12','r13','r14','r15']+(['rdi','rsi'] if win else [])
for j,r in enumerate(regs):s+=f'    mov ${0x123400+j}, %{r}\n'
if win:
 for j in range(10):s+=f'    mov ${0x567800+j}, %rax\n    movq %rax, %xmm{j+6}\n'
s+='    mov %rsp, 216(%rsp)\n'
s+='    call rt_nl\n    call rt_sep\n'
s+='    mov $42, %'+('rcx' if win else 'rdi')+'\n    call rt_computed\n'
s+='    mov $42, %'+('rcx' if win else 'rdi')+'\n    call rt_int\n'
s+='    lea abi_text(%rip), %'+('rcx' if win else 'rdi')+'\n    mov $3, %'+('rdx' if win else 'rsi')+'\n    call rt_str\n'
s+='    mov $10, %'+('rcx' if win else 'rdi')+'\n    call ll_fact\n    cmp $3628800, %rax\n    jne abi_fail\n'
# Exercise the unchanged scalar physical ABI with both logical input values.
for value,expected in [(0,1),(1,0)]:
 s+=f'    mov ${value}, %'+('rcx' if win else 'rdi')+'\n    call ll_boolflip\n'
 s+=f'    cmp ${expected}, %rax\n    jne abi_fail\n'
for j,r in enumerate(regs):s+=f'    cmp ${0x123400+j}, %{r}\n    jne abi_fail\n'
if win:
 for j in range(10):s+=f'    movq %xmm{j+6}, %rax\n    cmp ${0x567800+j}, %rax\n    jne abi_fail\n'
s+='    cmpq $0, hbc_trace_top(%rip)\n    jne abi_fail\n'
s+='    cmp %rsp, 216(%rsp)\n    jne abi_fail\n    leave\n    ret\nabi_fail:\n    ud2\n'
s+='\n.section .rdata,"r"\n' if win else '\n.section .rodata\n'
s+='abi_text: .ascii "ABI"\n'
pathlib.Path('abi_'+key+'.s').write_text(s)
p=pathlib.Path('corpus_w.ll.runtime.s' if win else 'corpus.ll.runtime.s');pathlib.Path('abi_rt_'+key+'.s').write_text(p.read_text().replace('call ll_main','call abi_check'))
