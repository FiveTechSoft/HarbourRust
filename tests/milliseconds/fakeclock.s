    .text
fake_milliseconds_clock:
    movabs $HB_SEC, %rax
    mov %rax, (%rsi)
    movabs $HB_NSEC, %rax
    mov %rax, 8(%rsi)
    xor %eax, %eax
    ret
