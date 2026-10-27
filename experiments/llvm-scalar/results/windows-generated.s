	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.att_syntax
	.file	"corpus_w.ll"
	.def	ll_sumloop;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	ll_sumloop
	.p2align	4
ll_sumloop:
	testq	%rcx, %rcx
	jle	.LBB0_1
	movl	$2, %edx
	movl	$5, %eax
	.p2align	4
.LBB0_4:
	cmpq	%rcx, %rdx
	jg	.LBB0_6
	addq	$5, %rax
	incq	%rdx
	jno	.LBB0_4
	movabsq	$9223372036854775803, %rax
	leaq	4(%rax), %rdx
.LBB0_6:
	addq	%rdx, %rax
	retq
.LBB0_1:
	movl	$1, %eax
	retq

	.def	ll_branchloop;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_branchloop
	.p2align	4
ll_branchloop:
	testq	%rcx, %rcx
	jle	.LBB1_1
	leaq	-7(%rcx), %rdx
	xorl	%eax, %eax
	cmpq	$9, %rcx
	setge	%al
	leaq	1(,%rax,2), %rax
	movl	$2, %r9d
	movabsq	$9223372036854775807, %r8
	.p2align	4
.LBB1_4:
	cmpq	%rcx, %r9
	jg	.LBB1_5
	xorl	%r10d, %r10d
	cmpq	%rdx, %r9
	setl	%r10b
	leaq	(%rax,%r10,2), %rax
	incq	%rax
	incq	%r9
	jno	.LBB1_4
	addq	%r8, %rax
	retq
.LBB1_1:
	movl	$1, %eax
	retq
.LBB1_5:
	movq	%r9, %r8
	addq	%r8, %rax
	retq

	.def	ll_fact;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_fact
	.p2align	4
ll_fact:
	pushq	%rsi
	movl	$1, %eax
	cmpq	$2, %rcx
	jl	.LBB2_7
	leaq	-1(%rcx), %r8
	leaq	-2(%rcx), %r9
	movl	%r8d, %edx
	andl	$7, %edx
	cmpq	$7, %r9
	jb	.LBB2_6
	andq	$-8, %r8
	negq	%r8
	xorl	%r9d, %r9d
	.p2align	4
.LBB2_3:
	leaq	(%rcx,%r9), %r10
	imulq	%rax, %r10
	leaq	(%rcx,%r9), %rax
	decq	%rax
	leaq	(%rcx,%r9), %r11
	addq	$-2, %r11
	imulq	%rax, %r11
	imulq	%r10, %r11
	leaq	(%rcx,%r9), %rax
	addq	$-3, %rax
	leaq	(%rcx,%r9), %r10
	addq	$-4, %r10
	imulq	%rax, %r10
	leaq	(%rcx,%r9), %rsi
	addq	$-5, %rsi
	imulq	%r10, %rsi
	imulq	%r11, %rsi
	leaq	(%rcx,%r9), %r10
	addq	$-6, %r10
	leaq	(%rcx,%r9), %rax
	addq	$-7, %rax
	imulq	%r10, %rax
	imulq	%rsi, %rax
	addq	$-8, %r9
	cmpq	%r9, %r8
	jne	.LBB2_3
	testq	%rdx, %rdx
	je	.LBB2_7
	addq	%r9, %rcx
	.p2align	4
.LBB2_6:
	imulq	%rcx, %rax
	decq	%rcx
	decq	%rdx
	jne	.LBB2_6
.LBB2_7:
	popq	%rsi
	retq

	.def	ll_recurrence;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_recurrence
	.p2align	4
ll_recurrence:
	testq	%rcx, %rcx
	jle	.LBB3_1
	movl	$1, %r9d
	xorl	%edx, %edx
	movl	$1, %r8d
	.p2align	4
.LBB3_3:
	incq	%rdx
	leaq	(%r9,%r9,2), %rax
	movq	%rdx, %r10
	incq	%r10
	jo	.LBB3_5
	addq	%rax, %r8
	movq	%r8, %r9
	movq	%r10, %r8
	cmpq	%rcx, %r10
	jle	.LBB3_3
.LBB3_5:
	addq	%rdx, %rax
	retq
.LBB3_1:
	movl	$1, %eax
	retq

	.def	ll_main;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_main
	.p2align	4
ll_main:
.seh_proc ll_main
	pushq	%rsi
	.seh_pushreg %rsi
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	movl	$1, %eax
	xorl	%esi, %esi
	.p2align	4
.LBB4_1:
	xorl	%ecx, %ecx
	cmpq	$999993, %rax
	setb	%cl
	leaq	(%rsi,%rcx,2), %rcx
	xorl	%edx, %edx
	cmpq	$999992, %rax
	setb	%dl
	leaq	(%rcx,%rdx,2), %rcx
	xorl	%edx, %edx
	cmpq	$999991, %rax
	setb	%dl
	leaq	(%rcx,%rdx,2), %rcx
	xorl	%edx, %edx
	cmpq	$999990, %rax
	setb	%dl
	leaq	(%rcx,%rdx,2), %rcx
	xorl	%edx, %edx
	cmpq	$999989, %rax
	setb	%dl
	leaq	(%rcx,%rdx,2), %rsi
	addq	$5, %rsi
	addq	$5, %rax
	cmpq	$1000001, %rax
	jne	.LBB4_1
	addq	$1000001, %rsi
	callq	rt_nl
	movl	$6000001, %ecx
	callq	rt_computed
	callq	rt_sep
	movq	%rsi, %rcx
	callq	rt_computed
	callq	rt_sep
	movl	$3628800, %ecx
	callq	rt_computed
	callq	rt_sep
	movabsq	$6101872691, %rcx
	callq	rt_computed
	xorl	%eax, %eax
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rsi
	.seh_endepilogue
	retq
	.seh_endproc
