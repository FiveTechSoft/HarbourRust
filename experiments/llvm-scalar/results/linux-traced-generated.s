	.att_syntax
	.file	"corpus.ll"
	.text
	.globl	ll_sumloop
	.prefalign	4, .Lfunc_end0, nop
	.type	ll_sumloop,@function
ll_sumloop:
	movq	hbc_trace_top@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rdx
	leaq	-24(%rsp), %rax
	movq	%rax, (%rcx)
	leaq	.Lstr0(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$27, -8(%rsp)
	leaq	.Lstr1(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$27, -8(%rsp)
	leaq	.Lstr2(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$27, -8(%rsp)
	leaq	.Lstr3(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$27, -8(%rsp)
	testq	%rdi, %rdi
	jle	.LBB0_1
	leaq	.Lstr4(%rip), %r8
	movq	%r8, -16(%rsp)
	movq	$27, -8(%rsp)
	movl	$2, %eax
	movl	$5, %esi
	.p2align	4
.LBB0_4:
	cmpq	%rdi, %rax
	jg	.LBB0_6
	movq	%r8, -16(%rsp)
	movq	$27, -8(%rsp)
	addq	$5, %rsi
	incq	%rax
	jno	.LBB0_4
	movabsq	$9223372036854775803, %rsi
	leaq	4(%rsi), %rax
	jmp	.LBB0_6
.LBB0_1:
	movl	$1, %eax
	xorl	%esi, %esi
.LBB0_6:
	addq	%rsi, %rax
	leaq	.Lstr5(%rip), %rsi
	movq	%rsi, -16(%rsp)
	movq	$27, -8(%rsp)
	movq	%rdx, (%rcx)
	retq
.Lfunc_end0:
	.size	ll_sumloop, .Lfunc_end0-ll_sumloop

	.globl	ll_branchloop
	.prefalign	4, .Lfunc_end1, nop
	.type	ll_branchloop,@function
ll_branchloop:
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	movq	hbc_trace_top@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rdx
	leaq	-24(%rsp), %rax
	movq	%rax, (%rcx)
	leaq	.Lstr6(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$30, -8(%rsp)
	leaq	.Lstr7(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$30, -8(%rsp)
	leaq	.Lstr8(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	.Lstr9(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	testq	%rdi, %rdi
	jle	.LBB1_1
	leaq	-7(%rdi), %r8
	leaq	.Lstr10(%rip), %r9
	movq	%r9, -16(%rsp)
	movq	$31, -8(%rsp)
	xorl	%eax, %eax
	cmpq	$9, %rdi
	setge	%al
	leaq	.Lstr11(%rip), %r10
	leaq	.Lstr12(%rip), %r11
	movq	%r11, %rbx
	cmovgeq	%r10, %rbx
	leaq	1(,%rax,2), %rsi
	movq	%rbx, -16(%rsp)
	movq	$31, -8(%rsp)
	movl	$2, %ebx
	movabsq	$9223372036854775807, %rax
	.p2align	4
.LBB1_4:
	cmpq	%rdi, %rbx
	jg	.LBB1_5
	movq	%r9, -16(%rsp)
	movq	$31, -8(%rsp)
	xorl	%r14d, %r14d
	cmpq	%r8, %rbx
	setl	%r14b
	movq	%r11, %r15
	cmovlq	%r10, %r15
	movq	%r15, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	(%rsi,%r14,2), %rsi
	incq	%rsi
	incq	%rbx
	jno	.LBB1_4
	jmp	.LBB1_6
.LBB1_1:
	movl	$1, %eax
	xorl	%esi, %esi
	jmp	.LBB1_6
.LBB1_5:
	movq	%rbx, %rax
.LBB1_6:
	addq	%rsi, %rax
	leaq	.Lstr13(%rip), %rsi
	movq	%rsi, -16(%rsp)
	movq	$31, -8(%rsp)
	movq	%rdx, (%rcx)
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end1:
	.size	ll_branchloop, .Lfunc_end1-ll_branchloop

	.globl	ll_fact
	.prefalign	4, .Lfunc_end2, nop
	.type	ll_fact,@function
ll_fact:
	pushq	%r14
	pushq	%rbx
	subq	$24, %rsp
	movq	hbc_trace_top@GOTPCREL(%rip), %rbx
	movq	(%rbx), %rcx
	movq	%rcx, (%rsp)
	movq	%rsp, %rax
	movq	%rax, (%rbx)
	leaq	.Lstr14(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$25, 16(%rsp)
	leaq	.Lstr15(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$25, 16(%rsp)
	movl	$1, %eax
	cmpq	$2, %rdi
	jl	.LBB2_2
	leaq	-1(%rdi), %rax
	movq	%rdi, %r14
	movq	%rax, %rdi
	callq	ll_fact@PLT
	imulq	%r14, %rax
	movq	(%rsp), %rcx
.LBB2_2:
	movq	%rcx, (%rbx)
	addq	$24, %rsp
	popq	%rbx
	popq	%r14
	retq
.Lfunc_end2:
	.size	ll_fact, .Lfunc_end2-ll_fact

	.globl	ll_recurrence
	.prefalign	4, .Lfunc_end3, nop
	.type	ll_recurrence,@function
ll_recurrence:
	movq	hbc_trace_top@GOTPCREL(%rip), %rcx
	movq	(%rcx), %rdx
	leaq	-24(%rsp), %rax
	movq	%rax, (%rcx)
	leaq	.Lstr16(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	.Lstr17(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	.Lstr18(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	.Lstr19(%rip), %rax
	movq	%rax, -16(%rsp)
	movq	$31, -8(%rsp)
	testq	%rdi, %rdi
	jle	.LBB3_1
	movl	$1, %r10d
	xorl	%esi, %esi
	leaq	.Lstr20(%rip), %r8
	movl	$1, %r9d
	.p2align	4
.LBB3_3:
	incq	%rsi
	movq	%r8, -16(%rsp)
	movq	$31, -8(%rsp)
	leaq	(%r10,%r10,2), %rax
	movq	%rsi, %r11
	incq	%r11
	jo	.LBB3_5
	addq	%rax, %r9
	movq	%r9, %r10
	movq	%r11, %r9
	cmpq	%rdi, %r11
	jle	.LBB3_3
.LBB3_5:
	addq	%rsi, %rax
	jmp	.LBB3_6
.LBB3_1:
	movl	$1, %eax
.LBB3_6:
	leaq	.Lstr21(%rip), %rsi
	movq	%rsi, -16(%rsp)
	movq	$31, -8(%rsp)
	movq	%rdx, (%rcx)
	retq
.Lfunc_end3:
	.size	ll_recurrence, .Lfunc_end3-ll_recurrence

	.globl	ll_main
	.prefalign	4, .Lfunc_end4, nop
	.type	ll_main,@function
ll_main:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$104, %rsp
	.cfi_def_cfa_offset 144
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	hbc_trace_top@GOTPCREL(%rip), %r15
	movq	(%r15), %rax
	movq	%rax, 32(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, (%r15)
	leaq	.Lstr22(%rip), %rcx
	movq	%rcx, 40(%rsp)
	movq	$25, 48(%rsp)
	leaq	.Lstr23(%rip), %rcx
	movq	%rcx, 40(%rsp)
	movq	$25, 48(%rsp)
	leaq	8(%rsp), %r12
	movq	%r12, (%r15)
	leaq	.Lstr0(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$27, 24(%rsp)
	leaq	.Lstr1(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$27, 24(%rsp)
	leaq	.Lstr2(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$27, 24(%rsp)
	leaq	.Lstr3(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	$-1000000, %rcx
	leaq	.Lstr4(%rip), %rdx
	.p2align	4
.LBB4_1:
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movq	$27, 24(%rsp)
	addq	$8, %rcx
	jne	.LBB4_1
	leaq	.Lstr5(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$27, 24(%rsp)
	movq	%rax, (%r15)
	movq	%r12, (%r15)
	leaq	.Lstr6(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$30, 24(%rsp)
	leaq	.Lstr7(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$30, 24(%rsp)
	leaq	.Lstr8(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	.Lstr9(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movl	$1, %ecx
	xorl	%ebx, %ebx
	leaq	.Lstr10(%rip), %rdx
	leaq	.Lstr11(%rip), %rsi
	leaq	.Lstr12(%rip), %rdi
	.p2align	4
.LBB4_3:
	movq	%rdx, 16(%rsp)
	movq	$31, 24(%rsp)
	xorl	%r8d, %r8d
	cmpq	$999993, %rcx
	setb	%r8b
	movq	%rdi, %r9
	cmovbq	%rsi, %r9
	movq	%r9, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	(%rbx,%r8,2), %r8
	movq	%rdx, 16(%rsp)
	movq	$31, 24(%rsp)
	xorl	%r9d, %r9d
	cmpq	$999992, %rcx
	setb	%r9b
	movq	%rdi, %r10
	cmovbq	%rsi, %r10
	movq	%r10, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	(%r8,%r9,2), %rbx
	addq	$2, %rbx
	addq	$2, %rcx
	cmpq	$1000001, %rcx
	jne	.LBB4_3
	leaq	.Lstr13(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rax, (%r15)
	movl	$10, %edi
	callq	ll_fact@PLT
	movq	%rax, %r14
	movq	(%r15), %rax
	movq	%r12, (%r15)
	leaq	.Lstr16(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	.Lstr17(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	.Lstr18(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	.Lstr19(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	leaq	.Lstr20(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	addq	$1000001, %rbx
	leaq	.Lstr21(%rip), %rcx
	movq	%rcx, 16(%rsp)
	movq	$31, 24(%rsp)
	movq	%rax, (%r15)
	callq	rt_nl@PLT
	movl	$6000001, %edi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movq	%rbx, %rdi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movq	%r14, %rdi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movabsq	$6101872691, %rdi
	callq	rt_computed@PLT
	leaq	.Lstr24(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	$25, 48(%rsp)
	movq	32(%rsp), %rax
	movq	%rax, (%r15)
	xorl	%eax, %eax
	addq	$104, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	ll_main, .Lfunc_end4-ll_main
	.cfi_endproc

	.type	.Lstr0,@object
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
.Lstr0:
	.ascii	"  at sumloop (corpus.hb:2)\n"
	.size	.Lstr0, 27

	.type	.Lstr1,@object
	.p2align	4, 0x0
.Lstr1:
	.ascii	"  at sumloop (corpus.hb:2)\n"
	.size	.Lstr1, 27

	.type	.Lstr2,@object
	.p2align	4, 0x0
.Lstr2:
	.ascii	"  at sumloop (corpus.hb:3)\n"
	.size	.Lstr2, 27

	.type	.Lstr3,@object
	.p2align	4, 0x0
.Lstr3:
	.ascii	"  at sumloop (corpus.hb:4)\n"
	.size	.Lstr3, 27

	.type	.Lstr4,@object
	.p2align	4, 0x0
.Lstr4:
	.ascii	"  at sumloop (corpus.hb:5)\n"
	.size	.Lstr4, 27

	.type	.Lstr5,@object
	.p2align	4, 0x0
.Lstr5:
	.ascii	"  at sumloop (corpus.hb:7)\n"
	.size	.Lstr5, 27

	.type	.Lstr6,@object
	.p2align	4, 0x0
.Lstr6:
	.ascii	"  at branchloop (corpus.hb:9)\n"
	.size	.Lstr6, 30

	.type	.Lstr7,@object
	.p2align	4, 0x0
.Lstr7:
	.ascii	"  at branchloop (corpus.hb:9)\n"
	.size	.Lstr7, 30

	.type	.Lstr8,@object
	.p2align	4, 0x0
.Lstr8:
	.ascii	"  at branchloop (corpus.hb:10)\n"
	.size	.Lstr8, 31

	.type	.Lstr9,@object
	.p2align	4, 0x0
.Lstr9:
	.ascii	"  at branchloop (corpus.hb:11)\n"
	.size	.Lstr9, 31

	.type	.Lstr10,@object
	.p2align	4, 0x0
.Lstr10:
	.ascii	"  at branchloop (corpus.hb:12)\n"
	.size	.Lstr10, 31

	.type	.Lstr11,@object
	.p2align	4, 0x0
.Lstr11:
	.ascii	"  at branchloop (corpus.hb:13)\n"
	.size	.Lstr11, 31

	.type	.Lstr12,@object
	.p2align	4, 0x0
.Lstr12:
	.ascii	"  at branchloop (corpus.hb:15)\n"
	.size	.Lstr12, 31

	.type	.Lstr13,@object
	.p2align	4, 0x0
.Lstr13:
	.ascii	"  at branchloop (corpus.hb:18)\n"
	.size	.Lstr13, 31

	.type	.Lstr14,@object
	.p2align	4, 0x0
.Lstr14:
	.ascii	"  at fact (corpus.hb:20)\n"
	.size	.Lstr14, 25

	.type	.Lstr15,@object
	.p2align	4, 0x0
.Lstr15:
	.ascii	"  at fact (corpus.hb:20)\n"
	.size	.Lstr15, 25

	.type	.Lstr16,@object
	.p2align	4, 0x0
.Lstr16:
	.ascii	"  at recurrence (corpus.hb:22)\n"
	.size	.Lstr16, 31

	.type	.Lstr17,@object
	.p2align	4, 0x0
.Lstr17:
	.ascii	"  at recurrence (corpus.hb:22)\n"
	.size	.Lstr17, 31

	.type	.Lstr18,@object
	.p2align	4, 0x0
.Lstr18:
	.ascii	"  at recurrence (corpus.hb:23)\n"
	.size	.Lstr18, 31

	.type	.Lstr19,@object
	.p2align	4, 0x0
.Lstr19:
	.ascii	"  at recurrence (corpus.hb:24)\n"
	.size	.Lstr19, 31

	.type	.Lstr20,@object
	.p2align	4, 0x0
.Lstr20:
	.ascii	"  at recurrence (corpus.hb:25)\n"
	.size	.Lstr20, 31

	.type	.Lstr21,@object
	.p2align	4, 0x0
.Lstr21:
	.ascii	"  at recurrence (corpus.hb:27)\n"
	.size	.Lstr21, 31

	.type	.Lstr22,@object
	.p2align	4, 0x0
.Lstr22:
	.ascii	"  at main (corpus.hb:29)\n"
	.size	.Lstr22, 25

	.type	.Lstr23,@object
	.p2align	4, 0x0
.Lstr23:
	.ascii	"  at main (corpus.hb:29)\n"
	.size	.Lstr23, 25

	.type	.Lstr24,@object
	.p2align	4, 0x0
.Lstr24:
	.ascii	"  at main (corpus.hb:30)\n"
	.size	.Lstr24, 25

	.section	".note.GNU-stack","",@progbits
