# Own MIT Linux hb_FNameExtSet leaf-string helper.
# rdi/rsi=path,rdx/rcx=extension -> owned result rax/rdx.
.text
hbc_fnameextsetdef_linux:
    mov $1, %r8d
    jmp .Lfes_entry
hbc_fnameextset_linux:
    xor %r8d, %r8d
.Lfes_entry:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    sub $24, %rsp
    mov %r8, 16(%rsp)
    mov %rdi, %r12
    mov %rdx, %r13
    mov %rcx, %r14
    cmp $263, %rsi
    jbe .Lfes_scan_init
    mov $263, %esi
.Lfes_scan_init:
    xor %eax, %eax
    xor %r8d, %r8d
    mov $-1, %r9
.Lfes_path:
    cmp %rsi, %rax
    jae .Lfes_path_done
    movzbl (%r12,%rax), %ecx
    test %cl, %cl
    jz .Lfes_path_done
    cmp $47, %cl
    jne .Lfes_dot
    lea 1(%rax), %r8
    mov $-1, %r9
    jmp .Lfes_path_next
.Lfes_dot:
    cmp $46, %cl
    jne .Lfes_path_next
    cmp %r8, %rax
    je .Lfes_path_next
    mov %rax, %r9
.Lfes_path_next:
    inc %rax
    jmp .Lfes_path
.Lfes_path_done:
    cmpq $0, 16(%rsp)
    je .Lfes_replace
    cmp $-1, %r9
    je .Lfes_replace
    xor %r14d, %r14d
    jmp .Lfes_cap
.Lfes_replace:
    cmp $-1, %r9
    cmovne %r9, %rax
.Lfes_cap:
    cmp $262, %rax
    jbe .Lfes_base
    mov $262, %eax
.Lfes_base:
    mov %rax, %r15
    xor %ecx, %ecx
.Lfes_ext_scan:
    cmp %r14, %rcx
    jae .Lfes_ext_done
    cmpb $0, (%r13,%rcx)
    je .Lfes_ext_done
    inc %rcx
    jmp .Lfes_ext_scan
.Lfes_ext_done:
    mov %rcx, %r14
    xor %ebx, %ebx
    test %rcx, %rcx
    jz .Lfes_size
    cmpb $46, (%r13)
    je .Lfes_size
    mov $1, %ebx
.Lfes_size:
    mov %r15, %rax
    add %rbx, %rax
    add %r14, %rax
    cmp $262, %rax
    jbe .Lfes_allocate
    mov $262, %eax
.Lfes_allocate:
    mov %rax, (%rsp)
    mov %rax, %rsi
    call hbc_stralloc
    mov %rax, 8(%rsp)
    mov %rax, %rdi
    mov %r12, %rsi
    mov %r15, %rcx
    rep movsb
    mov (%rsp), %rcx
    sub %r15, %rcx
    jz .Lfes_done
    test %rbx, %rbx
    jz .Lfes_ext_copy
    movb $46, (%rdi)
    inc %rdi
    dec %rcx
.Lfes_ext_copy:
    mov %r13, %rsi
    rep movsb
.Lfes_done:
    mov 8(%rsp), %rax
    mov (%rsp), %rdx
    add $24, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
