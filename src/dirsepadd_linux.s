# Original MIT counted-byte Linux hb_DirSepAdd helper.
# rdi=bytes,rsi=length -> independent owned string rax/rdx.
.text
hbc_dirsepadd_linux:
    test %rsi, %rsi
    jz hbc_strcpy
    cmpb $47, -1(%rdi,%rsi,1)
    je hbc_strcpy
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %rbx
    mov %rsi, %r12
    inc %rsi
    jz hbc_oom
    call hbc_stralloc
    mov %rax, %rdi
    mov %rbx, %rsi
    mov %r12, %rcx
    rep movsb
    movb $47, (%rdi)
    pop %r12
    pop %rbx
    leave
    ret
