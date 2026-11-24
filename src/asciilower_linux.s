# Original MIT counted-byte ASCII lowercase copy.
# rdi=bytes,rsi=length -> independent owned string rax/rdx.
.text
hbc_asciilower_linux:
    push %rbp
    mov %rsp, %rbp
    call hbc_strcpy
    mov %rax, %rdi
    mov %rdx, %rcx
    test %rcx, %rcx
    jz .Lasciilower_done
.Lasciilower_byte:
    movzbl (%rdi), %r8d
    cmp $65, %r8d
    jb .Lasciilower_next
    cmp $90, %r8d
    ja .Lasciilower_next
    add $32, %r8d
    mov %r8b, (%rdi)
.Lasciilower_next:
    inc %rdi
    dec %rcx
    jnz .Lasciilower_byte
.Lasciilower_done:
    leave
    ret
