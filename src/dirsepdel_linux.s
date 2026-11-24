# Own MIT counted-byte hb_DirSepDel, Linux x86-64.
# rdi=bytes,rsi=length -> independent owned copy rax/rdx.
# Preserve / and // roots; trim trailing slash bytes, not backslashes.
.text
hbc_dirsepdel_linux:
    xor %ecx, %ecx
    test %rsi, %rsi
    jz hbc_strcpy
    cmpb $47, (%rdi)
    jne .Ldsd_trim
    mov $1, %ecx
    cmp $2, %rsi
    jb .Ldsd_trim
    cmpb $47, 1(%rdi)
    jne .Ldsd_trim
    mov $2, %ecx
.Ldsd_trim:
    cmp %rcx, %rsi
    jbe hbc_strcpy
    cmpb $47, -1(%rdi,%rsi)
    jne hbc_strcpy
    dec %rsi
    jmp .Ldsd_trim
