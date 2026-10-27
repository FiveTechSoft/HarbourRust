	.att_syntax
	.file	"corpus.ll"
	.text
	.globl	ll_sumloop
	.prefalign	4, .Lfunc_end0, nop
	.type	ll_sumloop,@function
ll_sumloop:
	testq	%rdi, %rdi
	jle	.LBB0_1
	movl	$2, %ecx
	movl	$5, %eax
	.p2align	4
.LBB0_4:
	cmpq	%rdi, %rcx
	jg	.LBB0_6
	addq	$5, %rax
	incq	%rcx
	jno	.LBB0_4
	movabsq	$9223372036854775803, %rax
	leaq	4(%rax), %rcx
.LBB0_6:
	addq	%rcx, %rax
	retq
.LBB0_1:
	movl	$1, %eax
	retq
.Lfunc_end0:
	.size	ll_sumloop, .Lfunc_end0-ll_sumloop

	.globl	ll_branchloop
	.prefalign	4, .Lfunc_end1, nop
	.type	ll_branchloop,@function
ll_branchloop:
	testq	%rdi, %rdi
	jle	.LBB1_1
	leaq	-7(%rdi), %rcx
	xorl	%eax, %eax
	cmpq	$9, %rdi
	setge	%al
	leaq	1(,%rax,2), %rax
	movl	$2, %esi
	movabsq	$9223372036854775807, %rdx
	.p2align	4
.LBB1_4:
	cmpq	%rdi, %rsi
	jg	.LBB1_5
	xorl	%r8d, %r8d
	cmpq	%rcx, %rsi
	setl	%r8b
	leaq	(%rax,%r8,2), %rax
	incq	%rax
	incq	%rsi
	jno	.LBB1_4
	addq	%rdx, %rax
	retq
.LBB1_1:
	movl	$1, %eax
	retq
.LBB1_5:
	movq	%rsi, %rdx
	addq	%rdx, %rax
	retq
.Lfunc_end1:
	.size	ll_branchloop, .Lfunc_end1-ll_branchloop

	.globl	ll_fact
	.prefalign	4, .Lfunc_end2, nop
	.type	ll_fact,@function
ll_fact:
	movl	$1, %eax
	cmpq	$2, %rdi
	jl	.LBB2_7
	leaq	-1(%rdi), %rdx
	leaq	-2(%rdi), %rsi
	movl	%edx, %ecx
	andl	$7, %ecx
	cmpq	$7, %rsi
	jb	.LBB2_6
	andq	$-8, %rdx
	negq	%rdx
	xorl	%esi, %esi
	.p2align	4
.LBB2_3:
	leaq	(%rdi,%rsi), %r8
	imulq	%rax, %r8
	leaq	(%rdi,%rsi), %rax
	decq	%rax
	leaq	(%rdi,%rsi), %r9
	addq	$-2, %r9
	imulq	%rax, %r9
	imulq	%r8, %r9
	leaq	(%rdi,%rsi), %rax
	addq	$-3, %rax
	leaq	(%rdi,%rsi), %r8
	addq	$-4, %r8
	imulq	%rax, %r8
	leaq	(%rdi,%rsi), %r10
	addq	$-5, %r10
	imulq	%r8, %r10
	imulq	%r9, %r10
	leaq	(%rdi,%rsi), %r8
	addq	$-6, %r8
	leaq	(%rdi,%rsi), %rax
	addq	$-7, %rax
	imulq	%r8, %rax
	imulq	%r10, %rax
	addq	$-8, %rsi
	cmpq	%rsi, %rdx
	jne	.LBB2_3
	testq	%rcx, %rcx
	je	.LBB2_7
	addq	%rsi, %rdi
	.p2align	4
.LBB2_6:
	imulq	%rdi, %rax
	decq	%rdi
	decq	%rcx
	jne	.LBB2_6
.LBB2_7:
	retq
.Lfunc_end2:
	.size	ll_fact, .Lfunc_end2-ll_fact

	.globl	ll_recurrence
	.prefalign	4, .Lfunc_end3, nop
	.type	ll_recurrence,@function
ll_recurrence:
	testq	%rdi, %rdi
	jle	.LBB3_1
	movl	$1, %esi
	xorl	%ecx, %ecx
	movl	$1, %edx
	.p2align	4
.LBB3_3:
	incq	%rcx
	leaq	(%rsi,%rsi,2), %rax
	movq	%rcx, %r8
	incq	%r8
	jo	.LBB3_5
	addq	%rax, %rdx
	movq	%rdx, %rsi
	movq	%r8, %rdx
	cmpq	%rdi, %r8
	jle	.LBB3_3
.LBB3_5:
	addq	%rcx, %rax
	retq
.LBB3_1:
	movl	$1, %eax
	retq
.Lfunc_end3:
	.size	ll_recurrence, .Lfunc_end3-ll_recurrence

	.globl	ll_main
	.prefalign	4, .Lfunc_end4, nop
	.type	ll_main,@function
ll_main:
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movl	$1, %eax
	xorl	%ebx, %ebx
	.p2align	4
.LBB4_1:
	xorl	%ecx, %ecx
	cmpq	$999993, %rax
	setb	%cl
	leaq	(%rbx,%rcx,2), %rcx
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
	leaq	(%rcx,%rdx,2), %rbx
	addq	$5, %rbx
	addq	$5, %rax
	cmpq	$1000001, %rax
	jne	.LBB4_1
	addq	$1000001, %rbx
	callq	rt_nl@PLT
	movl	$6000001, %edi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movq	%rbx, %rdi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movl	$3628800, %edi
	callq	rt_computed@PLT
	callq	rt_sep@PLT
	movabsq	$6101872691, %rdi
	callq	rt_computed@PLT
	xorl	%eax, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	ll_main, .Lfunc_end4-ll_main
	.cfi_endproc

	.section	".note.GNU-stack","",@progbits
