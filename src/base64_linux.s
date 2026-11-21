# Original MIT counted-byte standard base64 encoder,no line wrapping.
# rdi=bytes,rsi=length -> independent owned string rax/rdx.
.text
hbc_base64_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rsi, %rax
    xor %edx, %edx
    mov $3, %ecx
    div %rcx
    test %rdx, %rdx
    jz .Lbase64_length
    inc %rax
.Lbase64_length:
    mov %rax, %rsi
    shl $2, %rsi
    mov %rsi, %rcx
    shr $2, %rcx
    cmp %rax, %rcx
    jne hbc_oom
    call hbc_stralloc
    mov %rax, %rdi
    mov %rbx, %rsi
    lea .Lbase64_alphabet(%rip), %r10
.Lbase64_group:
    cmp $3, %r12
    jb .Lbase64_tail
    movzbl (%rsi), %ecx
    shl $16, %ecx
    movzbl 1(%rsi), %r8d
    shl $8, %r8d
    or %r8d, %ecx
    movzbl 2(%rsi), %r8d
    or %r8d, %ecx
    mov %ecx, %r8d
    shr $18, %r8d
    movzbl (%r10,%r8), %r9d
    mov %r9b, (%rdi)
    mov %ecx, %r8d
    shr $12, %r8d
    and $63, %r8d
    movzbl (%r10,%r8), %r9d
    mov %r9b, 1(%rdi)
    mov %ecx, %r8d
    shr $6, %r8d
    and $63, %r8d
    movzbl (%r10,%r8), %r9d
    mov %r9b, 2(%rdi)
    and $63, %ecx
    movzbl (%r10,%rcx), %r9d
    mov %r9b, 3(%rdi)
    add $3, %rsi
    add $4, %rdi
    sub $3, %r12
    jmp .Lbase64_group
.Lbase64_tail:
    test %r12, %r12
    jz .Lbase64_done
    movzbl (%rsi), %ecx
    mov %ecx, %r8d
    shr $2, %r8d
    movzbl (%r10,%r8), %r9d
    mov %r9b, (%rdi)
    and $3, %ecx
    shl $4, %ecx
    cmp $1, %r12
    je .Lbase64_one
    movzbl 1(%rsi), %r8d
    mov %r8d, %r9d
    shr $4, %r9d
    or %r9d, %ecx
    movzbl (%r10,%rcx), %r9d
    mov %r9b, 1(%rdi)
    and $15, %r8d
    shl $2, %r8d
    movzbl (%r10,%r8), %r9d
    mov %r9b, 2(%rdi)
    movb $61, 3(%rdi)
    jmp .Lbase64_done
.Lbase64_one:
    movzbl (%r10,%rcx), %r9d
    mov %r9b, 1(%rdi)
    movb $61, 2(%rdi)
    movb $61, 3(%rdi)
.Lbase64_done:
    pop %r12
    pop %rbx
    leave
    ret
.section .rodata
.Lbase64_alphabet:
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
.text
