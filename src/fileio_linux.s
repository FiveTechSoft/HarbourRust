# Original MIT: bounded typed synchronous file I/O, Linux x86-64.
.text
# rdi=path bytes, rsi=count, edx=open flags. Return fd or -1.
hbc_fileio_open:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
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
    mov $257, %eax
    mov $-100, %edi
    mov %rbx, %rsi
    mov %r14d, %edx
    mov $438, %r10d
    syscall
    test %rax, %rax
    mov $-1, %r12
    cmovns %rax, %r12
    mov %rbx, %rdi
    call hbc_freestr
    mov %r12, %rax
    xor %edx, %edx
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
# rdi=fd, rsi=string, rdx=count. Return bytes written or zero.
hbc_fileio_write:
    mov $1, %eax
    syscall
    xor %ecx, %ecx
    test %rax, %rax
    cmovs %rcx, %rax
    xor %edx, %edx
    ret
# rdi=fd. Return logical.
hbc_fileio_close:
    mov $3, %eax
    syscall
    test %rax, %rax
    sete %al
    movzbq %al, %rax
    xor %edx, %edx
    ret
# rdi=fd, rsi=positive bounded count. Return owned counted string.
# A NUL ends the returned value, not the read operation's consumption.
hbc_fileio_readstr:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    sub $8, %rsp
    mov %rdi, %r12
    mov %rsi, %r13
    call hbc_stralloc
    mov %rax, %rbx
    mov %r12, %rdi
    mov %rbx, %rsi
    mov %r13, %rdx
    xor %eax, %eax
    syscall
    xor %edx, %edx
    test %rax, %rax
    jle .Lfileio_read_done
.Lfileio_nul:
    cmp %rax, %rdx
    jae .Lfileio_read_done
    cmpb $0, (%rbx,%rdx)
    je .Lfileio_read_done
    inc %rdx
    jmp .Lfileio_nul
.Lfileio_read_done:
    mov %rdx, -8(%rbx)
    mov %rbx, %rax
    add $8, %rsp
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
