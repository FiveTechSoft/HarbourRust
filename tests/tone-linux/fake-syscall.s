.data
fake_ns: .quad 1000000000000
.text
fake_syscall:
    cmp $96, %rax
    je fake_tv
    cmp $228, %rax
    je fake_ts
    cmp $23, %rax
    je fake_select
    syscall
    ret
fake_tv:
    mov %rdi, %r9
    mov fake_ns(%rip), %rax
    xor %edx, %edx
    mov $1000000000, %rcx
    div %rcx
    add $1795618800, %rax
    mov %rax, (%r9)
    mov %rdx, %rax
    xor %edx, %edx
    mov $1000, %ecx
    div %rcx
    mov %rax, 8(%r9)
    xor %eax, %eax
    ret
fake_ts:
    mov %rdi, %r10
    mov %rsi, %r9
    mov fake_ns(%rip), %rax
    xor %edx, %edx
    mov $1000000000, %rcx
    div %rcx
    test %r10, %r10
    jne 91f
    add $1795618800, %rax
91:
    mov %rax, (%r9)
    mov %rdx, 8(%r9)
    xor %eax, %eax
    ret
fake_select:
    mov 8(%r8), %rax
    imul $1000, %rax, %rax
    add %rax, fake_ns(%rip)
    xor %eax, %eax
    ret
hbc_panic_exit:
    mov $60, %eax
    mov $89, %edi
    syscall
