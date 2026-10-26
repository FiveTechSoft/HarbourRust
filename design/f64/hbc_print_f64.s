# hbc_print_f64: %xmm0 = value, %rdi = dec_count. Frontier: 1e-17<=|x|<1e15, dec<=17.
hbc_print_f64:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    push %r15
    sub $160, %rsp
    mov %rdi, -40(%rbp)          # dec_count
    # sign / |x|
    xor %r10d, %r10d
    movq %xmm0, %rax
    test %rax, %rax
    jns 10f
    mov $1, %r10d
    mov $0x7fffffffffffffff, %rcx
    and %rcx, %rax
    movq %rax, %xmm0
10:
    # zero? (covers -0.0: sign dropped, oracle hk282)
    xorpd %xmm2, %xmm2
    ucomisd %xmm2, %xmm0
    jp 11f                      # unordered (NaN): treat as nonzero-defensive
    je 20f                      # zero
11:
    # normalize ax into [1,10), e in %r11
    xor %r11d, %r11d
    mov $0x4024000000000000, %rax
    movq %rax, %xmm1            # 10.0
1:  comisd %xmm1, %xmm0
    jb 2f
    divsd %xmm1, %xmm0
    inc %r11
    jmp 1b
2:  mov $0x3FF0000000000000, %rax
    movq %rax, %xmm2            # 1.0
3:  comisd %xmm2, %xmm0
    jae 4f
    mulsd %xmm1, %xmm0
    dec %r11
    jmp 3b
4:
    # N = (i64)(m * 1e15 + 0.5)
    mov $0x430C6BF526340000, %rax
    movq %rax, %xmm2
    mulsd %xmm2, %xmm0
    mov $0x3FE0000000000000, %rax
    movq %rax, %xmm2
    addsd %xmm2, %xmm0
    cvttsd2si %xmm0, %rax
    # carry: N == 1e16 -> N=1e15, e++
    mov $10000000000000000, %rcx
    cmp %rcx, %rax
    jne 5f
    mov $1000000000000000, %rax
    inc %r11
5:
    mov %rax, -48(%rbp)         # N
    mov %r11, -56(%rbp)         # e
    jmp 30f
20: # zero: N=0, e=0, sign=0
    xor %r10d, %r10d
    movq $0, -48(%rbp)
    movq $0, -56(%rbp)
30:
    # digit buffer: 16 digits of N at -48..-65(%rbp) (ASCII, most significant first)
    mov -48(%rbp), %rax
    lea -65(%rbp), %rsi
    mov $16, %ecx
6:  xor %edx, %edx
    mov $10, %r8
    div %r8
    add $48, %dl
    mov %dl, (%rsi)
    dec %rsi
    dec %ecx
    jnz 6b
    # compose output at -144(%rbp) forward; r9 = cursor
    lea -144(%rbp), %r9
    # total_len = sign + int_len + 1 + dec ; width = 11 + dec ; pad = max(width-total,0)
    mov -56(%rbp), %r11         # e
    mov $1, %r12                # int_len (e<0 -> "0")
    test %r11, %r11
    js 7f
    lea 1(%r11), %r12           # int_len = e+1
7:  mov -40(%rbp), %r13          # dec
    lea 1(%r12,%r13), %r14      # int_len + 1 + dec
    test %r10d, %r10d
    jz 8f
    inc %r14
8:  mov %r13, %r15
    add $11, %r15               # width
    sub %r14, %r15              # pad (may be negative)
    jle 9f
12: movb $32, (%r9)
    inc %r9
    dec %r15d
    jnz 12b
9:  test %r10d, %r10d
    jz 13f
    movb $45, (%r9)
    inc %r9
13:
    # integer part
    mov -56(%rbp), %r11
    test %r11, %r11
    js 14f
    # copy e+1 digits from digit buf (leading zeros within 16-digit N are real)
    lea -80(%rbp), %rsi
    mov %r12, %rcx
    # skip (16 - int_len - max(frac...)) hmm: N always has exactly 16 digits incl leading zeros; int part = FIRST int_len of the 16 only when N>=10^(16-int_len)... For zero N this is wrong; zero handled: digits are "0000000000000000", int="0".
    mov -48(%rbp), %rax
    test %rax, %rax
    jnz 15f
    movb $48, (%r9)
    inc %r9
    jmp 16f
15: # nonzero: first int_len digits are the integer part (N in [1e15,1e16) so no leading zeros within int_len when int_len=e+1)
    mov %r12, %rcx
17: movsbq (%rsi), %rdx
    mov %dl, (%r9)
    inc %rsi
    inc %r9
    dec %ecx
    jnz 17b
    jmp 16f
14: movb $48, (%r9)             # e<0: integer "0"
    inc %r9
16:
    movb $46, (%r9)             # '.'
    inc %r9
    # fraction sequence: [(-e-1) zeros if e<0] + [16 digits of N after int part] + zeros; take dec chars
    mov -40(%rbp), %r13          # dec remaining
    test %r13, %r13
    jz 40f
    mov -56(%rbp), %r11
    # leading zeros for e<0
    test %r11, %r11
    jns 18f
    mov %r11, %rcx
    neg %rcx
    dec %rcx                    # -e-1
19: test %r13, %r13
    jz 40f
    test %rcx, %rcx
    jz 18f
    movb $48, (%r9)
    inc %r9
    dec %r13
    dec %rcx
    jmp 19b
18:
    # digits of N after the integer part: rsi points into digit buf
    lea -80(%rbp), %rsi
    xor %r12d, %r12d            # e<0: fraction starts at digit 0 of N
    mov -56(%rbp), %r11
    test %r11, %r11
    js 21f
    lea 1(%r11), %r12           # e>=0: skip the e+1 integer digits
21: add %r12, %rsi              # first fraction digit
    lea -64(%rbp), %rdx         # end of 16 digits (exclusive)
22: test %r13, %r13
    jz 40f
    cmp %rdx, %rsi
    jae 23f
    movsbq (%rsi), %rcx
    mov %cl, (%r9)
    inc %r9
    inc %rsi
    dec %r13
    jmp 22b
23: movb $48, (%r9)             # zero pad
    inc %r9
    dec %r13
    jmp 22b
40:
    # write: start -112, len = r9 - start
    lea -144(%rbp), %rax
    mov %r9, %rdx
    sub %rax, %rdx
    call hbc_print_str
    add $160, %rsp
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    leave
    ret

