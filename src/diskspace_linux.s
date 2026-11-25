# Own MIT bounded Linux hb_DiskSpace, external statvfs observations only.
# rdi/rsi=counted path, edx=literal0..3 -> xmm0=value, rdi=width10/dec0.
# Linux statfs ABI bsize/blocks/bfree/bavail at offsets8/16/24/32.
.text
hbc_diskspace_linux:
    push %rbp
    mov %rsp, %rbp
    sub $4288, %rsp
    mov %edx, -8(%rbp)
    cmp $4095, %rsi
    ja .Ldiskspace_zero
    mov %rsi, %rcx
    lea 144(%rsp), %r8
    xor %edx, %edx
.Ldiskspace_copy:
    cmp %rcx, %rdx
    jae .Ldiskspace_terminate
    movzbl (%rdi,%rdx), %eax
    mov %al, (%r8,%rdx)
    test %al, %al
    jz .Ldiskspace_terminate
    inc %rdx
    jmp .Ldiskspace_copy
.Ldiskspace_terminate:
    movb $0, (%r8,%rdx)
    mov %r8, %rdi
    mov %rsp, %rsi
    mov $137, %eax
    syscall
    test %rax, %rax
    jnz .Ldiskspace_zero
    mov -8(%rbp), %eax
    cmp $1, %eax
    je .Ldiskspace_free
    cmp $2, %eax
    je .Ldiskspace_used
    cmp $3, %eax
    je .Ldiskspace_total
    mov 32(%rsp), %rax
    jmp .Ldiskspace_number
.Ldiskspace_free:
    mov 24(%rsp), %rax
    jmp .Ldiskspace_number
.Ldiskspace_used:
    mov 16(%rsp), %rax
    sub 24(%rsp), %rax
    jmp .Ldiskspace_number
.Ldiskspace_total:
    mov 16(%rsp), %rax
.Ldiskspace_number:
    cvtsi2sd %rax, %xmm0
    cvtsi2sdq 8(%rsp), %xmm1
    mulsd %xmm1, %xmm0
    jmp .Ldiskspace_done
.Ldiskspace_zero:
    xorpd %xmm0, %xmm0
.Ldiskspace_done:
    mov $655360, %edi
    movabs $10000000000, %rax
    cvtsi2sd %rax, %xmm1
    ucomisd %xmm1, %xmm0
    jb .Ldiskspace_width_done
    mov $1310720, %edi
.Ldiskspace_width_done:
    leave
    ret
