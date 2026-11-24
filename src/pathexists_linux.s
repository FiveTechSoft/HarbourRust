# Own MIT literal-path existence checks, Linux x86-64.
# rdi/rsi=counted path, edx=1 directory /0 regular file -> Bool rax.
# stat follows symlinks. No globbing or SET DEFAULT/PATH lookup.
.text
hbc_pathexists_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    sub $160, %rsp
    mov %rdi, %r12
    mov %rsi, %r13
    mov %edx, %r14d
    inc %rsi
    call hbc_stralloc
    mov %rax, %rbx
    mov %rax, %rdi
    mov %r12, %rsi
    mov %r13, %rcx
    rep movsb
    movb $0, (%rdi)
    mov $262, %eax
    mov $-100, %edi
    mov %rbx, %rsi
    mov %rsp, %rdx
    xor %r10d, %r10d
    syscall
    test %rax, %rax
    js .Lpe_false
    mov 24(%rsp), %eax
    and $61440, %eax
    test %r14d, %r14d
    jnz .Lpe_directory
    cmp $32768, %eax
    sete %r12b
    movzbl %r12b, %r12d
    jmp .Lpe_free
.Lpe_directory:
    cmp $16384, %eax
    sete %r12b
    movzbl %r12b, %r12d
    jmp .Lpe_free
.Lpe_false:
    xor %r12d, %r12d
.Lpe_free:
    mov %rbx, %rdi
    call hbc_freestr
    mov %r12, %rax
    xor %edx, %edx
    add $160, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
