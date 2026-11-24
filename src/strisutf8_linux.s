# Own MIT measured hb_StrIsUTF8 byte-structure predicate, not RFC3629.
# rdi/rsi=counted bytes -> Bool rax; requires at least one multibyte group.
.text
hbc_strisutf8_linux:
    xor %eax, %eax
    xor %ecx, %ecx
    xor %r8d, %r8d
.Lsiu_byte:
    cmp %rsi, %rcx
    jae .Lsiu_done
    movzbl (%rdi,%rcx), %edx
    inc %rcx
    cmp $128, %edx
    jb .Lsiu_byte
    cmp $192, %edx
    jb .Lsiu_false
    mov $1, %r9d
    cmp $224, %edx
    jb .Lsiu_cont
    inc %r9d
    cmp $240, %edx
    jb .Lsiu_cont
    inc %r9d
    cmp $248, %edx
    jb .Lsiu_cont
    inc %r9d
    cmp $252, %edx
    jb .Lsiu_cont
    inc %r9d
    cmp $254, %edx
    jb .Lsiu_cont
    inc %r9d
    cmp $255, %edx
    jb .Lsiu_cont
    inc %r9d
.Lsiu_cont:
    cmp %rsi, %rcx
    jae .Lsiu_false
    movzbl (%rdi,%rcx), %edx
    and $192, %edx
    cmp $128, %edx
    jne .Lsiu_false
    inc %rcx
    dec %r9d
    jnz .Lsiu_cont
    mov $1, %r8d
    jmp .Lsiu_byte
.Lsiu_done:
    mov %r8, %rax
    xor %edx, %edx
    ret
.Lsiu_false:
    xor %eax, %eax
    xor %edx, %edx
    ret
