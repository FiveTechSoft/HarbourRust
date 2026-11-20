# Original MIT bridge: C SysV convention to existing raw byte writer.
.bss
.balign 8
hbc_console_mode: .quad 0
.text
hbc_print_str:
    cmpq $0, hbc_console_mode(%rip)
    je hbc_write_bytes
    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8
    push %r9
    push %r10
    push %r11
    mov %rax, %rdi
    mov %rdx, %rsi
    call hbc_gtstd_render
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    pop %rdi
    pop %rsi
    pop %rdx
    pop %rcx
    pop %rax
    ret
hbc_gtstd_write:
    mov %rdi, %rax
    mov %rsi, %rdx
    jmp hbc_write_bytes
