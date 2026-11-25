# Own MIT last binary match. rdi/rsi=needle ptr,len;rdx/rcx=haystack ptr,len.
.text
hbc_brat_linux:
    xor %eax, %eax
    test %rsi, %rsi
    jz .Lbrat_return
    cmp %rcx, %rsi
    ja .Lbrat_return
    sub %rsi, %rcx
.Lbrat_outer:
    xor %r9d, %r9d
    lea (%rdx,%rcx), %r11
.Lbrat_inner:
    mov (%rdi,%r9), %r10b
    cmp (%r11,%r9), %r10b
    jne .Lbrat_next
    inc %r9
    cmp %rsi, %r9
    jb .Lbrat_inner
    lea 1(%rcx), %rax
    ret
.Lbrat_next:
    test %rcx, %rcx
    jz .Lbrat_return
    dec %rcx
    jmp .Lbrat_outer
.Lbrat_return:
    ret
