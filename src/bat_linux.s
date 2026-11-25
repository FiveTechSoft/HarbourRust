# Own MIT two-leaf binary At. rdi/rsi=needle ptr,len;rdx/rcx=haystack ptr,len.
.text
hbc_bat_linux:
    xor %eax, %eax
    test %rsi, %rsi
    jz .Lbat_return
    cmp %rcx, %rsi
    ja .Lbat_return
    sub %rsi, %rcx
    xor %r8d, %r8d
.Lbat_outer:
    xor %r9d, %r9d
.Lbat_inner:
    mov (%rdi,%r9), %r10b
    lea (%rdx,%r8), %r11
    cmp (%r11,%r9), %r10b
    jne .Lbat_next
    inc %r9
    cmp %rsi, %r9
    jb .Lbat_inner
    lea 1(%r8), %rax
    ret
.Lbat_next:
    inc %r8
    cmp %rcx, %r8
    jbe .Lbat_outer
.Lbat_return:
    ret
