# Own MIT bounded binary whole-file read, Linux x86-64.
# rdi=path, rsi=length. Owned result; preserve the caller's FError.
.text
hbc_fileio_memoread:
    push %rbp
    mov %rsp,%rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $8,%rsp
    mov hbc_ferror_value(%rip),%rbx
    mov $2048,%edx
    call hbc_fileio_open
    mov %rax,%r12
    xor %r13d,%r13d
    xor %r14d,%r14d
    xor %r15d,%r15d
    test %rax,%rax
    js .Lmemo_empty
    sub $144,%rsp
    mov %r12,%rdi
    mov %rsp,%rsi
    mov $5,%eax
    syscall
    test %rax,%rax
    js .Lmemo_stat_bad
    mov 24(%rsp),%eax
    and $61440,%eax
    cmp $32768,%eax
    jne .Lmemo_stat_bad
    add $144,%rsp
    jmp .Lmemo_stat_ok
.Lmemo_stat_bad:
    add $144,%rsp
    jmp .Lmemo_close_empty
.Lmemo_stat_ok:
    mov %r12,%rdi
    xor %esi,%esi
    mov $2,%edx
    mov $8,%eax
    syscall
    test %rax,%rax
    js .Lmemo_close_empty
    cmp $1048576,%rax
    ja .Lmemo_limit
    mov %rax,%r14
    mov %r12,%rdi
    xor %esi,%esi
    xor %edx,%edx
    mov $8,%eax
    syscall
    test %rax,%rax
    js .Lmemo_close_empty
    mov %r14,%rsi
    call hbc_stralloc
    mov %rax,%r13
.Lmemo_read:
    cmp %r14,%r15
    jae .Lmemo_close
    mov %r12,%rdi
    lea (%r13,%r15),%rsi
    mov %r14,%rdx
    sub %r15,%rdx
    xor %eax,%eax
    syscall
    cmp $-4,%rax
    je .Lmemo_read
    test %rax,%rax
    js .Lmemo_read_error
    jz .Lmemo_close
    add %rax,%r15
    jmp .Lmemo_read
.Lmemo_read_error:
    xor %r15d,%r15d
.Lmemo_close:
    mov %r12,%rdi
    mov $3,%eax
    syscall
    mov %r15,-8(%r13)
    mov %r13,%rax
    mov %r15,%rdx
    jmp .Lmemo_done
.Lmemo_close_empty:
    mov %r12,%rdi
    mov $3,%eax
    syscall
.Lmemo_empty:
    xor %esi,%esi
    call hbc_stralloc
.Lmemo_done:
    mov %rbx,hbc_ferror_value(%rip)
    add $8,%rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
.Lmemo_limit:
    mov %r12,%rdi
    mov $3,%eax
    syscall
    mov $1,%eax
    mov $2,%edi
    lea .Lmemo_limit_msg(%rip),%rsi
    mov $.Lmemo_limit_end-.Lmemo_limit_msg,%edx
    syscall
    mov $60,%eax
    mov $1,%edi
    syscall
.section .rodata
.Lmemo_limit_msg:
    .ascii "hb_MemoRead: files above 1048576 bytes are outside this increment"
    .byte 10
.Lmemo_limit_end:
.text
