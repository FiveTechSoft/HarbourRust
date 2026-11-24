# Own MIT binary Left/Right. rdi/rsi=bytes,len;rdx=count;ecx=right.
.text
hbc_bslice_linux:
    test %rdx, %rdx
    jns .Lbsl_nonneg
    xor %edx, %edx
.Lbsl_nonneg:
    cmp %rsi, %rdx
    cmova %rsi, %rdx
    test %ecx, %ecx
    jz .Lbsl_copy
    sub %rdx, %rsi
    add %rsi, %rdi
.Lbsl_copy:
    mov %rdx, %rsi
    jmp hbc_strcpy
