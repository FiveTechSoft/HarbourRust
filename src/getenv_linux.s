# Own Linux helper. rdi/rsi=key bytes/length, result fresh string rax/rdx.
# hbc_getenv_envp is saved at process entry before any call.
    .text
hbc_getenv_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %r12
    mov %rsi, %r13
    xor %eax, %eax
.Lgetenv_keylen:
    cmp %r13, %rax
    jae .Lgetenv_keydone
    cmpb $0, (%r12,%rax,1)
    je .Lgetenv_keydone
    cmpb $61, (%r12,%rax,1)
    je .Lgetenv_empty
    inc %rax
    jmp .Lgetenv_keylen
.Lgetenv_keydone:
    mov %rax, %r13
    test %r13, %r13
    jz .Lgetenv_empty
    mov hbc_getenv_envp(%rip), %rbx
.Lgetenv_entry:
    mov (%rbx), %r14
    test %r14, %r14
    jz .Lgetenv_empty
    xor %ecx, %ecx
.Lgetenv_compare:
    cmp %r13, %rcx
    jae .Lgetenv_equal
    movzbl (%r12,%rcx,1), %eax
    cmpb %al, (%r14,%rcx,1)
    jne .Lgetenv_next
    inc %rcx
    jmp .Lgetenv_compare
.Lgetenv_equal:
    cmpb $61, (%r14,%rcx,1)
    jne .Lgetenv_next
    lea 1(%r14,%rcx,1), %rdi
    xor %esi, %esi
.Lgetenv_vallen:
    cmpb $0, (%rdi,%rsi,1)
    je .Lgetenv_copy
    inc %rsi
    jmp .Lgetenv_vallen
.Lgetenv_next:
    add $8, %rbx
    jmp .Lgetenv_entry
.Lgetenv_empty:
    xor %edi, %edi
    xor %esi, %esi
.Lgetenv_copy:
    call hbc_strcpy
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
    .data
    .p2align 3
hbc_getenv_envp: .quad 0
    .text
