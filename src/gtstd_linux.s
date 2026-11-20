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

# Fatal raw writes can occur inside a render helper, with live arguments.
# Preserve every volatile register before closing previously deferred lines.
hbc_gtstd_before_fatal:
    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8
    push %r9
    push %r10
    push %r11
    call hbc_gtstd_close
    movq $0, hbc_console_mode(%rip)
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

# WAIT's counted prompt and printable-key echo are console writes too.
hbc_gtstd_wait_write:
    push %rax
    push %rcx
    push %rdx
    push %rsi
    push %rdi
    push %r8
    push %r9
    push %r10
    push %r11
    mov %rsi, %rdi
    mov %rdx, %rsi
    call hbc_gtstd_render
    call hbc_gtstd_finish
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
