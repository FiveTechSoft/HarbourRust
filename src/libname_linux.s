# Original MIT: construct Linux library filenames from counted byte strings.
.text
hbc_libname_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $616, %rsp
    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r14
    mov %rcx, %r15
    mov $263, %eax
    cmp %rax, %r13
    cmova %rax, %r13
    cmp %rax, %r15
    cmova %rax, %r15
    xor %ecx, %ecx
.Llib_dir_nul:
    cmp %r15, %rcx
    jae .Llib_dir_ready
    cmpb $0, (%r14,%rcx)
    je .Llib_dir_truncate
    inc %rcx
    jmp .Llib_dir_nul
.Llib_dir_truncate:
    mov %rcx, %r15
.Llib_dir_ready:
    xor %ebx, %ebx
    xor %ecx, %ecx
    mov $3, %r10d
.Llib_scan:
    cmp %r13, %rcx
    jae .Llib_scanned
    cmpb $0, (%r12,%rcx)
    je .Llib_name_truncate
    cmpb $47, (%r12,%rcx)
    jne .Llib_dot
    lea 1(%rcx), %rbx
    mov $3, %r10d
    jmp .Llib_next
.Llib_dot:
    cmpb $46, (%r12,%rcx)
    jne .Llib_next
    cmp %rbx, %rcx
    je .Llib_next
    xor %r10d, %r10d
.Llib_next:
    inc %rcx
    jmp .Llib_scan
.Llib_name_truncate:
    mov %rcx, %r13
.Llib_scanned:
    mov %r10, 40(%rsp)
    lea (%r12,%rbx), %rax
    mov %rax, 16(%rsp)
    mov %r13, %rax
    sub %rbx, %rax
    mov %rax, 24(%rsp)
    movq $0, 32(%rsp)
    test %rbx, %rbx
    jz .Llib_directory
    mov %r12, (%rsp)
    mov %rbx, 8(%rsp)
    jmp .Llib_allocate
.Llib_directory:
    mov %r14, (%rsp)
    mov %r15, 8(%rsp)
    test %r15, %r15
    jz .Llib_allocate
    cmpb $47, -1(%r14,%r15)
    je .Llib_allocate
    movq $1, 32(%rsp)
.Llib_allocate:
    lea 72(%rsp), %rdi
    mov (%rsp), %rsi
    mov 8(%rsp), %rcx
    rep movsb
    cmpq $0, 32(%rsp)
    je .Llib_prefix
    movb $47, (%rdi)
    inc %rdi
.Llib_prefix:
    movb $108, (%rdi)
    movb $105, 1(%rdi)
    movb $98, 2(%rdi)
    add $3, %rdi
    mov 16(%rsp), %rsi
    mov 24(%rsp), %rcx
    rep movsb
    cmpq $0, 40(%rsp)
    je .Llib_done
    movb $46, (%rdi)
    movb $115, 1(%rdi)
    movb $111, 2(%rdi)
.Llib_done:
    # Historical filename ABI: split at most 263 source bytes, return
    # at most 262 result bytes. Construct first, then clip the full result.
    lea 72(%rsp), %rax
    # rdi points past the base; account for the extension just emitted.
    add 40(%rsp), %rdi
    mov %rdi, %rsi
    sub %rax, %rsi
    mov $262, %ecx
    cmp %rcx, %rsi
    cmova %rcx, %rsi
    mov %rax, %rdi
    call hbc_strcpy
    add $616, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
