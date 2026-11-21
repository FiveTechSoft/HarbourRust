# Original MIT counted-byte ASCII uppercase copy.
# rdi=bytes,rsi=length -> independent owned string rax/rdx.
.text
hbc_asciiupper_linux:
    push %rbp
    mov %rsp, %rbp
    call hbc_strcpy
    mov %rax, %rdi
    mov %rdx, %rcx
    test %rcx, %rcx
    jz .Lasciiupper_done
.Lasciiupper_byte:
    movzbl (%rdi), %r8d
    cmp $97, %r8d
    jb .Lasciiupper_next
    cmp $122, %r8d
    ja .Lasciiupper_next
    sub $32, %r8d
    mov %r8b, (%rdi)
.Lasciiupper_next:
    inc %rdi
    dec %rcx
    jnz .Lasciiupper_byte
.Lasciiupper_done:
    leave
    ret
