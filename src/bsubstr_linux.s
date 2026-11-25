# Own MIT counted-byte SubStr. rdi=ptr,rsi=len,rdx=signed start,rcx=signed count.
.text
hbc_bsubstr_linux:
    test %rdx, %rdx
    jg .Lbsub_positive
    jz .Lbsub_zero
    add %rsi, %rdx
    jns .Lbsub_offset
.Lbsub_zero:
    xor %edx, %edx
    jmp .Lbsub_offset
.Lbsub_positive:
    dec %rdx
.Lbsub_offset:
    cmp %rsi, %rdx
    cmova %rsi, %rdx
    add %rdx, %rdi
    sub %rdx, %rsi
    test %rcx, %rcx
    jns .Lbsub_count
    xor %ecx, %ecx
.Lbsub_count:
    cmp %rsi, %rcx
    cmovb %rcx, %rsi
    jmp hbc_strcpy
