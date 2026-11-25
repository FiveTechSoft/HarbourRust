# Own MIT counted-byte Linux hb_HexToStr. Ignore nonhex,drop odd nibble.
# rdi/rsi=input bytes/length -> owned result rax/rdx.
.text
hbc_hextostr_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    mov %rdi, %r12
    mov %rsi, %r13
    xor %r14d, %r14d
    xor %ecx, %ecx
.Lhts_count:
    cmp %r13, %rcx
    jae .Lhts_alloc
    movzbl (%r12,%rcx), %eax
    sub $48, %eax
    cmp $9, %eax
    jbe .Lhts_count_yes
    movzbl (%r12,%rcx), %eax
    or $32, %eax
    sub $97, %eax
    cmp $5, %eax
    ja .Lhts_count_next
.Lhts_count_yes:
    inc %r14
.Lhts_count_next:
    inc %rcx
    jmp .Lhts_count
.Lhts_alloc:
    mov %r14, %rsi
    shr $1, %rsi
    call hbc_stralloc
    mov %rax, %rbx
    xor %ecx, %ecx
    xor %r14d, %r14d
    xor %r8d, %r8d
    xor %r9d, %r9d
.Lhts_scan:
    cmp %r13, %rcx
    jae .Lhts_done
    movzbl (%r12,%rcx), %eax
    sub $48, %eax
    cmp $9, %eax
    jbe .Lhts_digit
    movzbl (%r12,%rcx), %eax
    or $32, %eax
    sub $97, %eax
    cmp $5, %eax
    ja .Lhts_next
    add $10, %eax
.Lhts_digit:
    test %r9d, %r9d
    jnz .Lhts_pair
    mov %eax, %r8d
    shl $4, %r8d
    mov $1, %r9d
    jmp .Lhts_next
.Lhts_pair:
    or %r8d, %eax
    mov %al, (%rbx,%r14)
    inc %r14
    xor %r9d, %r9d
.Lhts_next:
    inc %rcx
    jmp .Lhts_scan
.Lhts_done:
    mov %rbx, %rax
    mov %r14, %rdx
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    leave
    ret
