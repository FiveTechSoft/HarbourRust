# Original MIT counted-byte hexadecimal parser.
# rdi=bytes,rsi=length -> modulo-2^64 integer rax.
.text
hbc_hextonum_linux:
    xor %eax, %eax
.Lhextonum_space:
    test %rsi, %rsi
    jz .Lhextonum_done
    cmpb $32, (%rdi)
    jne .Lhextonum_digit
    inc %rdi
    dec %rsi
    jmp .Lhextonum_space
.Lhextonum_digit:
    test %rsi, %rsi
    jz .Lhextonum_done
    movzbl (%rdi), %ecx
    test %ecx, %ecx
    jz .Lhextonum_done
    cmp $48, %ecx
    jb .Lhextonum_bad
    cmp $57, %ecx
    jbe .Lhextonum_decimal
    or $32, %ecx
    sub $97, %ecx
    cmp $5, %ecx
    ja .Lhextonum_bad
    add $10, %ecx
    jmp .Lhextonum_accumulate
.Lhextonum_decimal:
    sub $48, %ecx
.Lhextonum_accumulate:
    shl $4, %rax
    or %rcx, %rax
    inc %rdi
    dec %rsi
    jmp .Lhextonum_digit
.Lhextonum_bad:
    xor %eax, %eax
.Lhextonum_done:
    ret
