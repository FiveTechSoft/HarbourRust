# Own MIT startup argv0/PATH directory observation model. No realpath.
# Init before Main so later cwd/PATH changes cannot alter the base.
.data
.p2align 3
hbc_dirbase_len: .quad 0
.bss
.p2align 4
hbc_dirbase_bytes: .skip 8192
.text
hbc_dirbase_linux:
    lea hbc_dirbase_bytes(%rip), %rdi
    mov hbc_dirbase_len(%rip), %rsi
    jmp hbc_strcpy
hbc_dirbase_init:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $16520, %rsp
    mov %rdi, %r12
    mov %rsi, %r13
    mov $79, %eax
    lea 8192(%rsp), %rdi
    mov $4096, %esi
    syscall
    test %rax, %rax
    jle .Ldb_limit
    cmp $263, %rax
    ja .Ldb_limit
    lea -1(%rax), %r14
    xor %r15d, %r15d
    xor %ebx, %ebx
.Ldb_argv_scan:
    cmp $263, %r15
    jae .Ldb_limit
    movzbl (%r12,%r15), %eax
    test %al, %al
    jz .Ldb_argv_done
    cmp $47, %al
    jne .Ldb_argv_next
    mov $1, %ebx
.Ldb_argv_next:
    inc %r15
    jmp .Ldb_argv_scan
.Ldb_argv_done:
    test %r15, %r15
    jz .Ldb_init_done
    test %ebx, %ebx
    jnz .Ldb_have_path
.Ldb_env:
    mov (%r13), %rax
    test %rax, %rax
    jz .Ldb_init_done
    add $8, %r13
    cmpl $0x48544150, (%rax)
    jne .Ldb_env
    cmpb $61, 4(%rax)
    jne .Ldb_env
    lea 5(%rax), %r13
.Ldb_path_entry:
    xor %ebx, %ebx
.Ldb_path_scan:
    movzbl (%r13,%rbx), %eax
    test %al, %al
    jz .Ldb_path_try
    cmp $58, %al
    je .Ldb_path_try
    inc %rbx
    cmp $4095, %rbx
    jb .Ldb_path_scan
    jmp .Ldb_init_done
.Ldb_path_try:
    test %rbx, %rbx
    jz .Ldb_path_next
    lea (%rbx,%r15), %rax
    cmp $8190, %rax
    jae .Ldb_init_done
    mov %r13, %rsi
    mov %rsp, %rdi
    mov %rbx, %rcx
    rep movsb
    movb $47, (%rdi)
    inc %rdi
    mov %r12, %rsi
    mov %r15, %rcx
    rep movsb
    movb $0, (%rdi)
    mov $4, %eax
    mov %rsp, %rdi
    lea 12304(%rsp), %rsi
    syscall
    test %rax, %rax
    jnz .Ldb_path_next
    mov 12328(%rsp), %eax
    and $0xf000, %eax
    cmp $0x4000, %eax
    je .Ldb_path_next
    mov %rsp, %r12
    lea 1(%rbx,%r15), %r15
    jmp .Ldb_have_path
.Ldb_path_next:
    cmpb $0, (%r13,%rbx)
    je .Ldb_init_done
    lea 1(%r13,%rbx), %r13
    jmp .Ldb_path_entry
.Ldb_have_path:
    lea hbc_dirbase_bytes(%rip), %rdi
    cmpb $47, (%r12)
    je .Ldb_copy_path
    lea 8192(%rsp), %rsi
    mov %r14, %rcx
    rep movsb
    cmpb $47, -1(%rdi)
    je .Ldb_strip_dot
    movb $47, (%rdi)
    inc %rdi
.Ldb_strip_dot:
    cmpw $0x2f2e, (%r12)
    jne .Ldb_copy_path
    add $2, %r12
    sub $2, %r15
.Ldb_copy_path:
    mov %r12, %rsi
    mov %r15, %rcx
    rep movsb
    lea hbc_dirbase_bytes(%rip), %rsi
    sub %rsi, %rdi
    cmp $262, %rdi
    ja .Ldb_limit
.Ldb_last_slash:
    test %rdi, %rdi
    jz .Ldb_init_done
    cmpb $47, -1(%rsi,%rdi)
    je .Ldb_save
    dec %rdi
    jmp .Ldb_last_slash
.Ldb_save:
    mov %rdi, hbc_dirbase_len(%rip)
.Ldb_init_done:
    add $16520, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret

.Ldb_limit:
    mov $1, %eax
    mov $1, %edi
    lea .Ldb_limit_text(%rip), %rsi
    mov $.Ldb_limit_end-.Ldb_limit_text, %edx
    syscall
    mov $60, %eax
    mov $1, %edi
    syscall
.section .rodata
.Ldb_limit_text:
    .ascii "hb_DirBase path/cwd exceeds measured short-path profile"
    .byte 10
.Ldb_limit_end:
.text
