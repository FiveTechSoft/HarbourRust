// Own MIT Darwin Intel scalar LLVM runtime, SysV C ABI at rt_* entries.
.section __TEXT,__text,regular,pure_instructions
.p2align 4
.globl _main
_main:
    push %rbp
    mov %rsp, %rbp
    call _ll_main
    xor %edi, %edi
    mov $0x2000001, %eax
    syscall
    ud2

// rdi pointer, rsi byte count. Retry short writes and EINTR.
.globl _rt_str
_rt_str:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    mov %rdi, %r12
    mov %rsi, %r13
Lwrite:
    test %r13, %r13
    jz Lwritten
    mov $1, %edi
    mov %r12, %rsi
    mov %r13, %rdx
    mov $0x2000004, %eax
    syscall
    jnc Lwriteok
    cmp $4, %rax
    je Lwrite
    jmp Lwritten
Lwriteok:
    test %rax, %rax
    jz Lwritten
    add %rax, %r12
    sub %rax, %r13
    jmp Lwrite
Lwritten:
    pop %r13
    pop %r12
    pop %rbp
    ret
.globl _rt_nl
_rt_nl:
    lea Lnewline(%rip), %rdi
    mov $1, %esi
    jmp _rt_str
.globl _rt_sep
_rt_sep:
    lea Lspaces(%rip), %rdi
    mov $1, %esi
    jmp _rt_str
.globl _rt_pdrop
_rt_pdrop:
    movq $0, Lpending(%rip)
    ret
.globl _rt_psep
_rt_psep:
    incq Lpending(%rip)
    ret
.globl _rt_pflush
_rt_pflush:
    push %rbp
    mov %rsp, %rbp
Lflush:
    mov Lpending(%rip), %rsi
    test %rsi, %rsi
    jz Lflushed
    mov $20, %eax
    cmp %rax, %rsi
    cmova %rax, %rsi
    sub %rsi, Lpending(%rip)
    lea Lspaces(%rip), %rdi
    call _rt_str
    jmp Lflush
Lflushed:
    pop %rbp
    ret

.globl _rt_pstrt
_rt_pstrt:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    push %r15
    mov %rdi, %r12
    mov %rsi, %r13
Lsegment:
    xor %r14d, %r14d
Lscan:
    cmp %r13, %r14
    je Llast
    cmpb $10, (%r12,%r14)
    je Lline
    inc %r14
    jmp Lscan
Lline:
    mov %r14, %r15
    test %r15, %r15
    jz Ltrimline
    cmpb $13, -1(%r12,%r15)
    jne Ltrimline
    dec %r15
Ltrimline:
    test %r15, %r15
    jz Lemitline
    cmpb $32, -1(%r12,%r15)
    jne Lemitline
    dec %r15
    jmp Ltrimline
Lemitline:
    test %r15, %r15
    jz Lemitnl
    call _rt_pflush
    mov %r12, %rdi
    mov %r15, %rsi
    call _rt_str
Lemitnl:
    call _rt_pdrop
    call _rt_nl
    inc %r14
    add %r14, %r12
    sub %r14, %r13
    jmp Lsegment
Llast:
    mov %r13, %r15
Ltrimlast:
    test %r15, %r15
    jz Llastready
    cmpb $32, -1(%r12,%r15)
    jne Llastready
    dec %r15
    jmp Ltrimlast
Llastready:
    test %r15, %r15
    jz Lhold
    call _rt_pflush
    mov %r12, %rdi
    mov %r15, %rsi
    call _rt_str
Lhold:
    sub %r15, %r13
    add %r13, Lpending(%rip)
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

.globl _rt_int
_rt_int:
    xor %esi, %esi
    jmp Lnumber
.globl _rt_computed
_rt_computed:
    mov $1, %esi
Lnumber:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    sub $64, %rsp
    mov %rdi, %r8
    mov %esi, %r9d
    mov %rdi, %rax
    test %rax, %rax
    jns Labs
    neg %rax
Labs:
    lea 64(%rsp), %r12
    xor %r13d, %r13d
    mov $10, %r10d
Ldigit:
    xor %edx, %edx
    div %r10
    add $48, %dl
    dec %r12
    mov %dl, (%r12)
    inc %r13
    test %rax, %rax
    jnz Ldigit
    test %r8, %r8
    jns Lwidth
    dec %r12
    movb $45, (%r12)
    inc %r13
Lwidth:
    mov $10, %esi
    test %r9d, %r9d
    jnz Lcomputedwidth
    test %r8, %r8
    js Lcomputedwidth
    lea 1(%r13), %rax
    cmp %rsi, %rax
    cmova %rax, %rsi
    jmp Lpadding
Lcomputedwidth:
    mov $20, %eax
    cmp $10, %r13
    cmova %rax, %rsi
Lpadding:
    sub %r13, %rsi
    jle Ldigits
    lea Lspaces(%rip), %rdi
    call _rt_str
Ldigits:
    mov %r12, %rdi
    mov %r13, %rsi
    call _rt_str
    add $64, %rsp
    pop %r13
    pop %r12
    pop %rbp
    ret

.globl _rt_bound_error
_rt_bound_error:
    lea Lbound(%rip), %rdi
    mov $26, %esi
    jmp Lfatal
.globl _rt_inc_error
_rt_inc_error:
    lea Linc(%rip), %rdi
    mov $50, %esi
Lfatal:
    // No return: realign for C calls regardless of the unreachable caller.
    and $-16, %rsp
    call _rt_str
    mov _hbc_trace_top(%rip), %r12
    test %r12, %r12
    jz Lexiterror
    lea Ltrace(%rip), %rdi
    mov $11, %esi
    call _rt_str
Ltraceframe:
    test %r12, %r12
    jz Lexiterror
    mov 8(%r12), %rdi
    mov 16(%r12), %rsi
    test %rdi, %rdi
    jz Lnextframe
    call _rt_str
Lnextframe:
    mov (%r12), %r12
    jmp Ltraceframe
Lexiterror:
    mov $1, %edi
    mov $0x2000001, %eax
    syscall
    ud2
.section __TEXT,__const
Lnewline: .byte 10
Lspaces: .ascii "                    "
Lbound: .ascii "Bound error: array access\n"
Linc: .ascii "Limit: increment overflow needs numeric promotion\n"
Ltrace: .ascii "Callstack:\n"
.zerofill __DATA,__bss,Lpending,8,3
.globl _hbc_trace_top
.zerofill __DATA,__bss,_hbc_trace_top,8,3
.subsections_via_symbols
