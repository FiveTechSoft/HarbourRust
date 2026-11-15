from pathlib import Path
import re
R=Path(__file__).resolve().parent
pro='''    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
'''
epi='''    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
'''
functions={
'hrbt_new':'    call hbc_float_new\n',
'hrbt_free':'    call hbc_freestr\n',
'hrbt_unpack_meta':'    mov %rdi,%rax\n    mov %rsi,%rdx\n    call hbc_float_unpack\n    mov %rdi,%rax\n',
'hrbt_format':'''    mov %rdi,%rax
    mov %rsi,%rdx
    call hbc_float_unpack
    xor %esi,%esi
    xor %edx,%edx
    xor %ecx,%ecx
    call hbc_str_f64
''',
'hrbt_string':'''    mov %rdi,(%rsp)
    mov %rsi,8(%rsp)
    call hbc_stralloc
    mov %rax,16(%rsp)
    mov %rax,%rdi
    mov (%rsp),%rsi
    mov 8(%rsp),%rcx
    rep movsb
    mov 16(%rsp),%rdx
    mov $4,%eax
''',
'hrbt_balance':'''    mov hbc_mem_allocs(%rip),%rax
    sub hbc_mem_frees(%rip),%rax
''',
'hrbt_flush':'    call hbc_str_cache_flush\n'}
for target in ['linux','windows']:
 s=(R/(target+'.s')).read_text().replace('.globl _start','.globl hrbt_unused_start').replace('\n_start:','\nhrbt_unused_start:')
 # B2 embeds the same bridge symbols under internal SysV. Keep them separate
 # from the native-C bridge linked by this legacy B1 callback gate.
 s=re.sub(r'\b(hrm[bv]_[A-Za-z0-9_]+)\b',r'hrbt_embedded_\1',s)
 # Production formatting/allocator bodies are unchanged; only API labels differ.
 s+='\n.text\n'
 for name,body in functions.items():s+='.globl '+name+'\n'+name+':\n'+pro+body+epi
 (R/(target+'-linked.s')).write_text(s)
