# Internal SysV adapters. Distinct raw headers never enter string destructors.
.text
hrm_raw_alloc:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
    mov %rsi,(%rsp)
    lea 8(%rsi),%rdi
    call hbc_alloc
    decq hbc_mem_allocs(%rip)
    mov (%rsp),%rcx
    mov %rcx,(%rax)
    add $8,%rax
    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
hrm_raw_free:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
    cmp -8(%rsi),%rdx
    jne hbc_os_bad
    mov %rsi,%rdi
    mov $1,%esi
    call hbc_free
    decq hbc_mem_frees(%rip)
    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
hrm_export_string:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
    mov %rcx,(%rsp)
    mov %rsi,%rdi
    mov %rdx,%rsi
    call hbc_strcpy
    mov (%rsp),%rcx
    movq $4,(%rcx)
    mov %rax,8(%rcx)
    xor %eax,%eax
    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
hrm_export_float:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    and $-16,%rsp
    sub $32,%rsp
    mov %rcx,(%rsp)
    mov %rsi,%rdi
    mov %rdx,%rsi
    call hbc_float_new
    mov (%rsp),%rcx
    mov %rax,(%rcx)
    mov %rdx,8(%rcx)
    xor %eax,%eax
    lea -40(%rbp),%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# Generic terminal builtin frame: rdi/rsi diagnostic, rdx/rcx name/length.
# Only reached after all evaluator/context ownership has been released.
hrm_builtin_fail:
    and $-16,%rsp
    sub $64,%rsp
    mov hbc_trace_top(%rip),%r11
    mov %r11,(%rsp)
    movq $0,8(%rsp)
    movq $0,16(%rsp)
    movq $0,24(%rsp)
    mov %rdx,32(%rsp)
    mov %rcx,40(%rsp)
    mov %rsp,hbc_trace_top(%rip)
    call hrm_fail
