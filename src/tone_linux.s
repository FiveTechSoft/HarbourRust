# Own MIT measured Linux GTSTD non-TTY TONE, not audio pitch synthesis.
# xmm0 ticks. No language effects inside this helper. literal finite profile.
.data
.align 8
hbc_tone_last_us: .quad 0
hbc_tone_seen: .quad 0
hbc_tone_bel: .byte 7
hbc_tone_limit: .ascii "Limit: Tone requires non-TTY output and working Linux clocks/select"
.byte 10
hbc_tone_limit_end:
.text
hbc_tone_linux:
    push %rbp
    mov %rsp, %rbp
    sub $112, %rsp
    movsd %xmm0, -8(%rbp)
    # This increment models GTSTD redirected output only, not a terminal GT.
    mov $1, %edi
    mov $21505, %esi
    lea -112(%rbp), %rdx
    mov $16, %eax
    syscall
    test %rax, %rax
    jz .Ltone_limit
    lea -32(%rbp), %rdi
    xor %esi, %esi
    mov $96, %eax
    syscall
    test %rax, %rax
    js .Ltone_limit
    mov -32(%rbp), %rax
    imul $1000000, %rax, %rax
    add -24(%rbp), %rax
    cmpq $0, hbc_tone_seen(%rip)
    je .Ltone_bel
    mov %rax, %rdx
    sub hbc_tone_last_us(%rip), %rdx
    cmp $500000, %rdx
    jle .Ltone_skip_bel
.Ltone_bel:
    mov %rax, hbc_tone_last_us(%rip)
    movq $1, hbc_tone_seen(%rip)
    mov $1, %eax
    mov $1, %edi
    lea hbc_tone_bel(%rip), %rsi
    mov $1, %edx
    syscall
.Ltone_skip_bel:
    movsd -8(%rbp), %xmm0
    xorpd %xmm1, %xmm1
    ucomisd %xmm1, %xmm0
    jb .Ltone_done
    movabs $0x4032333333333333, %rax
    movq %rax, %xmm1
    divsd %xmm1, %xmm0
    mov $1000, %eax
    cvtsi2sd %rax, %xmm1
    mulsd %xmm1, %xmm0
    cvttsd2si %xmm0, %rax
    mov %rax, -16(%rbp)
    test %rax, %rax
    jz .Ltone_once
    call hbc_tone_now_ms
    add -16(%rbp), %rax
    mov %rax, -16(%rbp)
.Ltone_loop:
    call hbc_tone_wait20
    call hbc_tone_now_ms
    cmp -16(%rbp), %rax
    jl .Ltone_loop
    jmp .Ltone_done
.Ltone_once:
    call hbc_tone_wait20
.Ltone_done:
    leave
    ret
hbc_tone_now_ms:
    sub $24, %rsp
    mov $1, %edi
    mov %rsp, %rsi
    mov $228, %eax
    syscall
    test %rax, %rax
    js .Ltone_clock_fail
    mov (%rsp), %rax
    imul $1000, %rax, %rax
    mov 8(%rsp), %rcx
    push %rax
    mov %rcx, %rax
    xor %edx, %edx
    mov $1000000, %ecx
    div %rcx
    pop %rcx
    add %rcx, %rax
    add $24, %rsp
    ret
.Ltone_clock_fail:
    add $24, %rsp
    jmp .Ltone_limit
hbc_tone_wait20:
    sub $24, %rsp
    movq $0, (%rsp)
    movq $20000, 8(%rsp)
    xor %edi, %edi
    xor %esi, %esi
    xor %edx, %edx
    xor %r10d, %r10d
    mov %rsp, %r8
    mov $23, %eax
    syscall
    test %rax, %rax
    js .Ltone_limit
    add $24, %rsp
    ret
.Ltone_limit:
    lea hbc_tone_limit(%rip), %rax
    mov $68, %edx
    call hbc_write_bytes
    jmp hbc_panic_exit
