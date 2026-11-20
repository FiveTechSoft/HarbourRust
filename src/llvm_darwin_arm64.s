// Own MIT Darwin ARM64 scalar LLVM runtime. C ABI at every rt_* entry.
// x18 is reserved by Darwin. Stack and nonvolatile registers follow AAPCS64.
.section __TEXT,__text,regular,pure_instructions
.p2align 2
.globl _main
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _ll_main
    mov x0, #0
    mov x16, #1
    svc #0x80
    brk #0

// x0 pointer, x1 byte count. Raw stdout, no trim. Retry short writes/EINTR.
.globl _rt_str
_rt_str:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
Lwrite:
    cbz x20, Lwritten
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x16, #4
    svc #0x80
    b.cc Lwrite_ok
    cmp x0, #4
    b.eq Lwrite
    b Lwritten
Lwrite_ok:
    cbz x0, Lwritten
    add x19, x19, x0
    sub x20, x20, x0
    b Lwrite
Lwritten:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.globl _rt_nl
_rt_nl:
    adrp x0, Lnewline@PAGE
    add x0, x0, Lnewline@PAGEOFF
    mov x1, #1
    b _rt_str
.globl _rt_sep
_rt_sep:
    adrp x0, Lspaces@PAGE
    add x0, x0, Lspaces@PAGEOFF
    mov x1, #1
    b _rt_str
.globl _rt_pdrop
_rt_pdrop:
    adrp x9, Lpending@PAGE
    str xzr, [x9, Lpending@PAGEOFF]
    ret
.globl _rt_psep
_rt_psep:
    adrp x9, Lpending@PAGE
    ldr x10, [x9, Lpending@PAGEOFF]
    add x10, x10, #1
    str x10, [x9, Lpending@PAGEOFF]
    ret
.globl _rt_pflush
_rt_pflush:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
Lflush:
    adrp x9, Lpending@PAGE
    ldr x10, [x9, Lpending@PAGEOFF]
    cbz x10, Lflushed
    mov x1, #20
    cmp x10, x1
    csel x1, x10, x1, lo
    sub x10, x10, x1
    str x10, [x9, Lpending@PAGEOFF]
    adrp x0, Lspaces@PAGE
    add x0, x0, Lspaces@PAGEOFF
    bl _rt_str
    b Lflush
Lflushed:
    ldp x29, x30, [sp], #16
    ret

// Formatted strings: trim spaces before LF (optional CR), retain final hold.
.globl _rt_pstrt
_rt_pstrt:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
Lsegment:
    mov x21, #0
Lscan:
    cmp x21, x20
    b.eq Llast
    ldrb w9, [x19, x21]
    cmp w9, #10
    b.eq Lline
    add x21, x21, #1
    b Lscan
Lline:
    mov x22, x21
    cbz x22, Ltrimline
    sub x9, x22, #1
    ldrb w10, [x19, x9]
    cmp w10, #13
    b.ne Ltrimline
    sub x22, x22, #1
Ltrimline:
    cbz x22, Lemitline
    sub x9, x22, #1
    ldrb w10, [x19, x9]
    cmp w10, #32
    b.ne Lemitline
    sub x22, x22, #1
    b Ltrimline
Lemitline:
    cbz x22, Lemitnl
    bl _rt_pflush
    mov x0, x19
    mov x1, x22
    bl _rt_str
Lemitnl:
    bl _rt_pdrop
    bl _rt_nl
    add x21, x21, #1
    add x19, x19, x21
    sub x20, x20, x21
    b Lsegment
Llast:
    mov x22, x20
Ltrimlast:
    cbz x22, Llastready
    sub x9, x22, #1
    ldrb w10, [x19, x9]
    cmp w10, #32
    b.ne Llastready
    sub x22, x22, #1
    b Ltrimlast
Llastready:
    cbz x22, Lhold
    bl _rt_pflush
    mov x0, x19
    mov x1, x22
    bl _rt_str
Lhold:
    sub x10, x20, x22
    adrp x9, Lpending@PAGE
    ldr x11, [x9, Lpending@PAGEOFF]
    add x10, x10, x11
    str x10, [x9, Lpending@PAGEOFF]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldr x23, [sp, #48]
    ldp x29, x30, [sp], #64
    ret

.globl _rt_int
_rt_int:
    mov x1, #0
    b Lnumber
.globl _rt_computed
_rt_computed:
    mov x1, #1
Lnumber:
    stp x29, x30, [sp, #-128]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x22, x1
    add x20, sp, #128
    mov x21, #0
    cmp x0, #0
    cneg x0, x0, lt
    mov x11, #10
Ldigit:
    udiv x9, x0, x11
    msub x10, x9, x11, x0
    add w10, w10, #48
    strb w10, [x20, #-1]!
    add x21, x21, #1
    mov x0, x9
    cbnz x0, Ldigit
    tbz x19, #63, Lwidth
    mov w10, #45
    strb w10, [x20, #-1]!
    add x21, x21, #1
Lwidth:
    mov x1, #10
    cbnz x22, Lcomputedwidth
    tbnz x19, #63, Lcomputedwidth
    add x9, x21, #1
    cmp x9, x1
    csel x1, x9, x1, hi
    b Lpadding
Lcomputedwidth:
    cmp x21, #10
    mov x9, #20
    csel x1, x9, x1, hi
Lpadding:
    subs x1, x1, x21
    b.le Ldigits
    adrp x0, Lspaces@PAGE
    add x0, x0, Lspaces@PAGEOFF
    bl _rt_str
Ldigits:
    mov x0, x20
    mov x1, x21
    bl _rt_str
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x29, x30, [sp], #128
    ret

.globl _rt_bound_error
_rt_bound_error:
    adrp x0, Lbound@PAGE
    add x0, x0, Lbound@PAGEOFF
    mov x1, #26
    b Lfatal
.globl _rt_inc_error
_rt_inc_error:
    adrp x0, Linc@PAGE
    add x0, x0, Linc@PAGEOFF
    mov x1, #50
Lfatal:
    bl _rt_str
    adrp x9, _hbc_trace_top@PAGE
    ldr x19, [x9, _hbc_trace_top@PAGEOFF]
    cbz x19, Lexiterror
    adrp x0, Ltrace@PAGE
    add x0, x0, Ltrace@PAGEOFF
    mov x1, #11
    bl _rt_str
Ltraceframe:
    cbz x19, Lexiterror
    ldp x0, x1, [x19, #8]
    cbz x0, Lnextframe
    bl _rt_str
Lnextframe:
    ldr x19, [x19]
    b Ltraceframe
Lexiterror:
    mov x0, #1
    mov x16, #1
    svc #0x80
    brk #0
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
