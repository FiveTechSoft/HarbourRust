# Own MIT counted-byte hb_DirSepToOS Linux helper.
# rdi/rsi=path bytes/length -> independent owned copy rax/rdx.
.text
hbc_dirseptoos_linux:
    push %rbp
    mov %rsp, %rbp
    call hbc_strcpy
    xor %ecx, %ecx
.Ldsto_loop:
    cmp %rdx, %rcx
    jae .Ldsto_done
    cmpb $92, (%rax,%rcx)
    jne .Ldsto_next
    movb $47, (%rax,%rcx)
.Ldsto_next:
    inc %rcx
    jmp .Ldsto_loop
.Ldsto_done:
    leave
    ret
