.text
# rdi = initial rsp. Read envp then auxv, preserving the original env scan.
hbc_vinit:
    mov (%rdi), %rax
    lea 16(%rdi,%rax,8), %rsi
    mov %rsi, %r8
.Lvinit_envend:
    cmpq $0, (%rsi)
    je .Lvinit_aux
    add $8, %rsi
    jmp .Lvinit_envend
.Lvinit_aux:
    add $8, %rsi
.Lvinit_auxloop:
    mov (%rsi), %rax
    test %rax, %rax
    je .Lvinit_ret
    cmp $6, %rax
    je .Lvinit_page
    add $16, %rsi
    jmp .Lvinit_auxloop
.Lvinit_page:
    mov 8(%rsi), %rax
    test %rax, %rax
    je .Lvinit_ret
    lea -1(%rax), %rcx
    test %rax, %rcx
    jne .Lvinit_ret
    mov $16777216, %rdx
    and %rcx, %rdx
    jne .Lvinit_ret
    mov %rax, hbc_vpage(%rip)
    movb $1, hbc_von(%rip)
    mov %r8, %rsi
.Lvinit_env:
    mov (%rsi), %rdi
    test %rdi, %rdi
    je .Lvinit_ret
    lea hbc_venvname(%rip), %rdx
    xor %ecx, %ecx
.Lvinit_match:
    movzbq (%rdi,%rcx), %rax
    cmpb (%rdx,%rcx), %al
    jne .Lvinit_envnext
    inc %rcx
    cmp $17, %rcx
    jne .Lvinit_match
    cmpb $0, 17(%rdi)
    jne .Lvinit_envnext
    movb $0, hbc_von(%rip)
    ret
.Lvinit_envnext:
    add $8, %rsi
    jmp .Lvinit_env
.Lvinit_ret:
    ret
.section .rodata
hbc_venvname: .asciz "HB_VAS_ARRAYS=off"
.text
hbc_vreserve:
    incq hbc_vreserve_calls(%rip)
    xor %edi, %edi
    mov $16777216, %esi
    xor %edx, %edx
    mov $0x22, %r10d
    mov $-1, %r8
    xor %r9d, %r9d
    mov $9, %eax
    syscall
    mov $-4096, %rcx
    cmp %rcx, %rax
    jbe .Lvreserve_ret
    xor %eax, %eax
.Lvreserve_ret:
    ret
hbc_vcommit:
    incq hbc_vcommit_calls(%rip)
    mov $3, %edx
    mov $10, %eax
    syscall
    test %rax, %rax
    sete %al
    movzbq %al, %rax
    ret
hbc_vheap:
    mov %rdi, %rsi
    xor %edi, %edi
    mov $3, %edx
    mov $0x22, %r10d
    mov $-1, %r8
    xor %r9d, %r9d
    mov $9, %eax
    syscall
    mov $-4096, %rcx
    cmp %rcx, %rax
    jbe .Lvheap_ret
    xor %eax, %eax
.Lvheap_ret:
    ret
hbc_vrelease:
    mov $11, %eax
    syscall
    test %rax, %rax
    jne hbc_os_bad
    ret
