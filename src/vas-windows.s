.bss
.align 8
hbc_vsysinfo: .zero 48
hbc_venvbuf: .zero 16
.section .rdata,"r"
hbc_venvname: .asciz "HB_VAS_ARRAYS"
.text
hbc_vinit:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    lea hbc_vsysinfo(%rip), %rcx
    call GetSystemInfo
    lea hbc_vsysinfo(%rip), %rdx
    mov 4(%rdx), %eax
    test %rax, %rax
    je .Lvinitw_ret
    lea -1(%rax), %rcx
    test %rax, %rcx
    jne .Lvinitw_ret
    mov $16777216, %rdx
    and %rcx, %rdx
    jne .Lvinitw_ret
    mov %rax, hbc_vpage(%rip)
    movb $1, hbc_von(%rip)
    lea hbc_venvname(%rip), %rcx
    lea hbc_venvbuf(%rip), %rdx
    mov $16, %r8d
    call GetEnvironmentVariableA
    cmp $3, %rax
    jne .Lvinitw_ret
    lea hbc_venvbuf(%rip), %rdx
    cmpb $111, (%rdx)
    jne .Lvinitw_ret
    cmpb $102, 1(%rdx)
    jne .Lvinitw_ret
    cmpb $102, 2(%rdx)
    jne .Lvinitw_ret
    movb $0, hbc_von(%rip)
.Lvinitw_ret:
    leave
    ret
hbc_vreserve:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    incq hbc_vreserve_calls(%rip)
    xor %ecx, %ecx
    mov $16777216, %edx
    mov $8192, %r8d
    mov $1, %r9d
    call VirtualAlloc
    leave
    ret
hbc_vcommit:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    incq hbc_vcommit_calls(%rip)
    mov %rdi, %rcx
    mov %rsi, %rdx
    mov $4096, %r8d
    mov $4, %r9d
    call VirtualAlloc
    test %rax, %rax
    setne %al
    movzbq %al, %rax
    leave
    ret
hbc_vheap:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    mov %rdi, -8(%rbp)
    call GetProcessHeap
    mov %rax, %rcx
    mov $8, %edx
    mov -8(%rbp), %r8
    call HeapAlloc
    leave
    ret
hbc_vrelease:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp
    test %rdx, %rdx
    je .Lvrelease_heap
    mov %rdi, %rcx
    xor %edx, %edx
    mov $32768, %r8d
    call VirtualFree
    jmp .Lvrelease_done
.Lvrelease_heap:
    mov %rdi, -8(%rbp)
    call GetProcessHeap
    mov %rax, %rcx
    xor %edx, %edx
    mov -8(%rbp), %r8
    call HeapFree
.Lvrelease_done:
    test %rax, %rax
    je hbc_os_bad
    leave
    ret
