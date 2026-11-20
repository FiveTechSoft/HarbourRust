# Original MIT: measured bare WAIT on Linux GTSTD. No termios/keyboard state.
.section .rodata
.Lbase_wait_prompt: .byte 10
    .ascii "Press any key to continue..."
.text
hbc_base_wait:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp
    mov $1, %eax
    mov $1, %edi
    lea .Lbase_wait_prompt(%rip), %rsi
    mov $29, %edx
    syscall
    call hbc_inkey_block_linux
    mov %al, (%rsp)
    cmp $32, %eax
    jb .Lbase_wait_done
    cmp $127, %eax
    je .Lbase_wait_done
    mov $1, %eax
    mov $1, %edi
    mov %rsp, %rsi
    mov $1, %edx
    syscall
.Lbase_wait_done:
    xor %eax, %eax
    xor %edx, %edx
    leave
    ret
