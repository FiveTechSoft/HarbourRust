# Original MIT counted-byte uppercase hexadecimal encoder.
# rdi=bytes,rsi=length -> independent owned string rax/rdx.
.text
hbc_strtohex_linux:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    mov %rdi, %rbx
    mov %rsi, %r12
    add %rsi, %rsi
    jc hbc_oom
    call hbc_stralloc
    mov %rax, %rdi
    test %r12, %r12
    jz .Lstrtohex_done
.Lstrtohex_byte:
    movzbl (%rbx), %r8d
    mov %r8d, %r9d
    shr $4, %r8d
    and $15, %r9d
    add $48, %r8d
    cmp $57, %r8d
    jbe .Lstrtohex_hi
    add $7, %r8d
.Lstrtohex_hi:
    add $48, %r9d
    cmp $57, %r9d
    jbe .Lstrtohex_lo
    add $7, %r9d
.Lstrtohex_lo:
    mov %r8b, (%rdi)
    mov %r9b, 1(%rdi)
    inc %rbx
    add $2, %rdi
    dec %r12
    jnz .Lstrtohex_byte
.Lstrtohex_done:
    pop %r12
    pop %rbx
    leave
    ret
