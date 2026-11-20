# Original MIT: GTSTD cursor state and blocking stdin byte input.
.data
hbc_cursor_mode: .quad 1
.text
hbc_cursor_set:
    mov hbc_cursor_mode(%rip), %rax
    cmp $4, %rdi
    jbe .Lcursor_mode_valid
    mov $1, %edi
.Lcursor_mode_valid:
    mov %rdi, hbc_cursor_mode(%rip)
    xor %edx, %edx
    ret
# Read the next nonzero input byte. EOF is not a key: wait, without busy-spin.
hbc_inkey_block_linux:
    # Keep entry export inside this reachable block for external as/ld.
    .globl _start
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
.Lkey_block_read:
    xor %eax, %eax
    xor %edi, %edi
    lea -1(%rbp), %rsi
    mov $1, %edx
    syscall
    cmp $1, %rax
    jne .Lkey_block_wait
    movzbl -1(%rbp), %eax
    test %eax, %eax
    jz .Lkey_block_read
    leave
    ret
.Lkey_block_wait:
    movq $0, -24(%rbp)
    movq $10000000, -16(%rbp)
    lea -24(%rbp), %rdi
    xor %esi, %esi
    mov $35, %eax
    syscall
    jmp .Lkey_block_read
