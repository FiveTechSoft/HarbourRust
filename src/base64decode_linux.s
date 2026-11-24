# Own MIT canonical padded base64 decoder. No implementation imported.
# rdi/rsi counted bytes -> owned rax/rdx. Empty accepted. Noncanonical
# inputs take an explicit limit, not a claim about Harbour's lax decoder.
.text
hbc_base64decode_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %r12
    mov %rsi, %r13
    test $3, %rsi
    jnz .Lbd_limit
    xor %r14d, %r14d
    test %rsi, %rsi
    jz .Lbd_alloc
    cmpb $61, -1(%r12,%r13)
    jne .Lbd_validate
    inc %r14
    cmpb $61, -2(%r12,%r13)
    jne .Lbd_validate
    inc %r14
.Lbd_validate:
    mov %r13, %r10
    sub %r14, %r10
    xor %r11d, %r11d
.Lbd_vloop:
    cmp %r10, %r11
    jae .Lbd_tailbits
    movzbl (%r12,%r11), %eax
    call .Lbd_digit
    test %eax, %eax
    js .Lbd_limit
    inc %r11
    jmp .Lbd_vloop
.Lbd_tailbits:
    cmp $2, %r14
    jne .Lbd_onepad
    test $15, %eax
    jnz .Lbd_limit
    jmp .Lbd_alloc
.Lbd_onepad:
    cmp $1, %r14
    jne .Lbd_alloc
    test $3, %eax
    jnz .Lbd_limit
.Lbd_alloc:
    mov %r13, %rsi
    shr $2, %rsi
    lea (%rsi,%rsi,2), %rbx
    sub %r14, %rbx
    mov %rbx, %rsi
    call hbc_stralloc
    mov %rax, %r14
    xor %r10d, %r10d
    xor %r11d, %r11d
    xor %r8d, %r8d
    xor %r9d, %r9d
.Lbd_loop:
    cmp %r13, %r10
    jae .Lbd_done
    movzbl (%r12,%r10), %eax
    inc %r10
    cmp $61, %eax
    je .Lbd_done
    call .Lbd_digit
    shl $6, %r8d
    or %eax, %r8d
    add $6, %r9d
    cmp $8, %r9d
    jb .Lbd_loop
    sub $8, %r9d
    mov %r9d, %ecx
    mov %r8d, %eax
    shr %cl, %eax
    mov %al, (%r14,%r11)
    inc %r11
    jmp .Lbd_loop
.Lbd_done:
    mov %r14, %rax
    mov %rbx, %rdx
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
.Lbd_limit:
    lea .Lbd_message(%rip), %rax
    mov $.Lbd_message_end-.Lbd_message, %edx
    call hbc_write_bytes
    jmp hbc_panic_exit
# eax ASCII -> digit, or -1. Only eax changed.
.Lbd_digit:
    cmp $65, %eax
    jb .Lbd_lower
    cmp $90, %eax
    ja .Lbd_lower
    sub $65, %eax
    ret
.Lbd_lower:
    cmp $97, %eax
    jb .Lbd_number
    cmp $122, %eax
    ja .Lbd_number
    sub $71, %eax
    ret
.Lbd_number:
    cmp $48, %eax
    jb .Lbd_plus
    cmp $57, %eax
    ja .Lbd_plus
    add $4, %eax
    ret
.Lbd_plus:
    cmp $43, %eax
    jne .Lbd_slash
    mov $62, %eax
    ret
.Lbd_slash:
    cmp $47, %eax
    jne .Lbd_invalid
    mov $63, %eax
    ret
.Lbd_invalid:
    mov $-1, %eax
    ret
.section .rodata
.Lbd_message:
    .ascii "Limit: hb_base64Decode requires canonical padded standard base64 in this increment"
    .byte 10
.Lbd_message_end:
.text
