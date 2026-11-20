# Original MIT. Linux syscall results mapped by externally measured errno table.
.data
hbc_ferror_value: .quad 0
.text
# rax=negative errno or nonnegative result; returns mapped error, no FError write.
hbc_flink_error:
    test %rax, %rax
    jns .Lflink_noerror
    neg %rax
    cmp $1, %rax
    je .Lflink_e5
    cmp $9, %rax
    jne .Lflink_not9
    mov $6, %eax
    ret
.Lflink_not9:
    cmp $11, %rax
    jne .Lflink_not11
    mov $33, %eax
    ret
.Lflink_not11:
    cmp $12, %rax
    jne .Lflink_not12
    mov $8, %eax
    ret
.Lflink_not12:
    cmp $13, %rax
    je .Lflink_e5
    cmp $14, %rax
    jne .Lflink_not14
    mov $9, %eax
    ret
.Lflink_not14:
    cmp $17, %rax
    jne .Lflink_not17
    mov $32, %eax
    ret
.Lflink_not17:
    cmp $20, %rax
    jne .Lflink_not20
    mov $3, %eax
    ret
.Lflink_not20:
    cmp $22, %rax
    jne .Lflink_not22
    mov $13, %eax
    ret
.Lflink_not22:
    cmp $23, %rax
    je .Lflink_e4
    cmp $24, %rax
    je .Lflink_e4
    cmp $26, %rax
    je .Lflink_e5
    cmp $28, %rax
    je .Lflink_e29
    cmp $29, %rax
    jne .Lflink_not29
    mov $25, %eax
    ret
.Lflink_not29:
    cmp $30, %rax
    jne .Lflink_not30
    mov $19, %eax
    ret
.Lflink_not30:
    cmp $32, %rax
    je .Lflink_e29
    ret
.Lflink_e5:
    mov $5, %eax
    ret
.Lflink_e4:
    mov $4, %eax
    ret
.Lflink_e29:
    mov $29, %eax
    ret
.Lflink_noerror:
    xor %eax, %eax
    ret
# Preserve syscall result in rax. Set the user-visible FError flag.
hbc_ferror_set_result:
    push %rax
    call hbc_flink_error
    mov %rax, hbc_ferror_value(%rip)
    pop %rax
    ret
# rdi=first zero-terminated name, rsi=second; rdx=86 hard,88 symlink.
hbc_flink_pair:
    mov %rdx, %rax
    syscall
    push %rax
    call hbc_ferror_set_result
    pop %rax
    test %rax, %rax
    jns .Lflink_pair_done
    mov $-1, %rax
.Lflink_pair_done:
    xor %edx, %edx
    ret
# rdi=zero-terminated name. Owned string truncated to264 measured bytes.
hbc_flink_read:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %r12
    mov $264, %esi
    call hbc_stralloc
    mov %rax, %rbx
    mov %r12, %rdi
    mov %rbx, %rsi
    mov $264, %edx
    mov $89, %eax
    syscall
    call hbc_ferror_set_result
    xor %ecx, %ecx
    test %rax, %rax
    cmovs %rcx, %rax
    mov %rax, %rdx
    mov %rax, -8(%rbx)
    mov %rbx, %rax
    pop %r12
    pop %rbx
    pop %rbp
    ret
# rdi=zero-terminated name. DirCreate returns mapped error, preserves FError.
hbc_flink_dir:
    mov $511, %esi
    mov $83, %eax
    syscall
    call hbc_flink_error
    xor %edx, %edx
    ret
# rdi=zero-terminated path,rsi=bytes,rdx=count. MemoWrit preserves FError.
hbc_flink_memo:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rsi, %r12
    mov %rdx, %r13
    mov %rdi, %rsi
    mov $-100, %edi
    mov $578, %edx
    mov $438, %r10d
    mov $257, %eax
    syscall
    xor %ebx, %ebx
    test %rax, %rax
    js .Lflink_memo_done
    mov %rax, %r14
    mov %r14, %rdi
    mov %r12, %rsi
    mov %r13, %rdx
    mov $1, %eax
    syscall
    cmp %r13, %rax
    sete %bl
    mov %r14, %rdi
    mov $3, %eax
    syscall
.Lflink_memo_done:
    mov %rbx, %rax
    xor %edx, %edx
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
# rdi=counted bytes,rsi=len -> owned NUL-terminated copy with original len at rd x.
hbc_flink_cstr:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %rbx
    mov %rsi, %r12
    inc %rsi
    call hbc_stralloc
    mov %rax, %rdi
    mov %rbx, %rsi
    mov %r12, %rcx
    rep movsb
    movb $0, (%rdi)
    mov %r12, %rdx
    pop %r12
    pop %rbx
    pop %rbp
    ret
