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
	subq	$24, %rsp
	movq	.refptr.hbc_trace_top(%rip), %rdx
	movq	(%rdx), %r8
	movq	%rsp, %rax
	movq	%rax, (%rdx)
	leaq	.Lstr0(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$27, 16(%rsp)
	leaq	.Lstr1(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$27, 16(%rsp)
	leaq	.Lstr2(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$27, 16(%rsp)
	leaq	.Lstr3(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$27, 16(%rsp)
	testq	%rcx, %rcx
	jle	.LBB0_1
	leaq	.Lstr4(%rip), %r10
	movq	%r10, 8(%rsp)
	movq	$27, 16(%rsp)
	movl	$2, %eax
	movl	$5, %r9d
	.p2align	4
.LBB0_4:
	cmpq	%rcx, %rax
	jg	.LBB0_6
	movq	%r10, 8(%rsp)
	movq	$27, 16(%rsp)
	addq	$5, %r9
	incq	%rax
	jno	.LBB0_4
	movabsq	$9223372036854775803, %r9
	leaq	4(%r9), %rax
	jmp	.LBB0_6
.LBB0_1:
	movl	$1, %eax
	xorl	%r9d, %r9d
.LBB0_6:
	addq	%r9, %rax
	leaq	.Lstr5(%rip), %rcx
	movq	%rcx, 8(%rsp)
	movq	$27, 16(%rsp)
	movq	%r8, (%rdx)
	addq	$24, %rsp
	retq

	.def	ll_branchloop;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_branchloop
	.p2align	4
ll_branchloop:
	pushq	%r15
	pushq	%r14
	pushq	%rsi
	pushq	%rdi
	pushq	%rbx
	subq	$24, %rsp
	movq	.refptr.hbc_trace_top(%rip), %rdx
	movq	(%rdx), %r8
	movq	%rsp, %rax
	movq	%rax, (%rdx)
	leaq	.Lstr6(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$30, 16(%rsp)
	leaq	.Lstr7(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$30, 16(%rsp)
	leaq	.Lstr8(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	.Lstr9(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	testq	%rcx, %rcx
	jle	.LBB1_1
	leaq	-7(%rcx), %r10
	leaq	.Lstr10(%rip), %r11
	movq	%r11, 8(%rsp)
	movq	$31, 16(%rsp)
	xorl	%eax, %eax
	cmpq	$9, %rcx
	setge	%al
	leaq	.Lstr11(%rip), %rsi
	leaq	.Lstr12(%rip), %rdi
	movq	%rdi, %rbx
	cmovgeq	%rsi, %rbx
	leaq	1(,%rax,2), %r9
	movq	%rbx, 8(%rsp)
	movq	$31, 16(%rsp)
	movl	$2, %ebx
	movabsq	$9223372036854775807, %rax
	.p2align	4
.LBB1_4:
	cmpq	%rcx, %rbx
	jg	.LBB1_5
	movq	%r11, 8(%rsp)
	movq	$31, 16(%rsp)
	xorl	%r14d, %r14d
	cmpq	%r10, %rbx
	setl	%r14b
	movq	%rdi, %r15
	cmovlq	%rsi, %r15
	movq	%r15, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	(%r9,%r14,2), %r9
	incq	%r9
	incq	%rbx
	jno	.LBB1_4
	jmp	.LBB1_6
.LBB1_1:
	movl	$1, %eax
	xorl	%r9d, %r9d
	jmp	.LBB1_6
.LBB1_5:
	movq	%rbx, %rax
.LBB1_6:
	addq	%r9, %rax
	leaq	.Lstr13(%rip), %rcx
	movq	%rcx, 8(%rsp)
	movq	$31, 16(%rsp)
	movq	%r8, (%rdx)
	addq	$24, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	popq	%r15
	retq

	.def	ll_fact;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_fact
	.p2align	4
ll_fact:
	pushq	%rsi
	pushq	%rdi
	subq	$56, %rsp
	movq	.refptr.hbc_trace_top(%rip), %rsi
	movq	(%rsi), %rdx
	movq	%rdx, 32(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, (%rsi)
	leaq	.Lstr14(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	$25, 48(%rsp)
	leaq	.Lstr15(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	$25, 48(%rsp)
	movl	$1, %eax
	cmpq	$2, %rcx
	jl	.LBB2_2
	leaq	-1(%rcx), %rax
	movq	%rcx, %rdi
	movq	%rax, %rcx
	callq	ll_fact
	imulq	%rdi, %rax
	movq	32(%rsp), %rdx
.LBB2_2:
	movq	%rdx, (%rsi)
	addq	$56, %rsp
	popq	%rdi
	popq	%rsi
	retq

	.def	ll_recurrence;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_recurrence
	.p2align	4
ll_recurrence:
	pushq	%rsi
	pushq	%rdi
	subq	$24, %rsp
	movq	.refptr.hbc_trace_top(%rip), %rdx
	movq	(%rdx), %r8
	movq	%rsp, %rax
	movq	%rax, (%rdx)
	leaq	.Lstr16(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	.Lstr17(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	.Lstr18(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	.Lstr19(%rip), %rax
	movq	%rax, 8(%rsp)
	movq	$31, 16(%rsp)
	testq	%rcx, %rcx
	jle	.LBB3_1
	movl	$1, %esi
	xorl	%r9d, %r9d
	leaq	.Lstr20(%rip), %r10
	movl	$1, %r11d
	.p2align	4
.LBB3_3:
	incq	%r9
	movq	%r10, 8(%rsp)
	movq	$31, 16(%rsp)
	leaq	(%rsi,%rsi,2), %rax
	movq	%r9, %rdi
	incq	%rdi
	jo	.LBB3_5
	addq	%rax, %r11
	movq	%r11, %rsi
	movq	%rdi, %r11
	cmpq	%rcx, %rdi
	jle	.LBB3_3
.LBB3_5:
	addq	%r9, %rax
	jmp	.LBB3_6
.LBB3_1:
	movl	$1, %eax
.LBB3_6:
	leaq	.Lstr21(%rip), %rcx
	movq	%rcx, 8(%rsp)
	movq	$31, 16(%rsp)
	movq	%r8, (%rdx)
	addq	$24, %rsp
	popq	%rdi
	popq	%rsi
	retq

	.def	ll_main;
	.scl	2;
	.type	32;
	.endef
	.globl	ll_main
	.p2align	4
ll_main:
.seh_proc ll_main
	pushq	%r14
	.seh_pushreg %r14
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$136, %rsp
	.seh_stackalloc 136
	.seh_endprologue
	movq	.refptr.hbc_trace_top(%rip), %rbx
	movq	(%rbx), %rax
	movq	%rax, 64(%rsp)
	leaq	64(%rsp), %rax
	movq	%rax, (%rbx)
	leaq	.Lstr22(%rip), %rcx
	movq	%rcx, 72(%rsp)
	movq	$25, 80(%rsp)
	leaq	.Lstr23(%rip), %rcx
	movq	%rcx, 72(%rsp)
	movq	$25, 80(%rsp)
	leaq	40(%rsp), %r14
	movq	%r14, (%rbx)
	leaq	.Lstr0(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$27, 56(%rsp)
	leaq	.Lstr1(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$27, 56(%rsp)
	leaq	.Lstr2(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$27, 56(%rsp)
	leaq	.Lstr3(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	$-1000000, %rcx
	leaq	.Lstr4(%rip), %rdx
	.p2align	4
.LBB4_1:
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rdx, 48(%rsp)
	movq	$27, 56(%rsp)
	addq	$8, %rcx
	jne	.LBB4_1
	leaq	.Lstr5(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$27, 56(%rsp)
	movq	%rax, (%rbx)
	movq	%r14, (%rbx)
	leaq	.Lstr6(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$30, 56(%rsp)
	leaq	.Lstr7(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$30, 56(%rsp)
	leaq	.Lstr8(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	.Lstr9(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movl	$1, %ecx
	xorl	%esi, %esi
	leaq	.Lstr10(%rip), %rdx
	leaq	.Lstr11(%rip), %r8
	leaq	.Lstr12(%rip), %r9
	.p2align	4
.LBB4_3:
	movq	%rdx, 48(%rsp)
	movq	$31, 56(%rsp)
	xorl	%r10d, %r10d
	cmpq	$999993, %rcx
	setb	%r10b
	movq	%r9, %r11
	cmovbq	%r8, %r11
	movq	%r11, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	(%rsi,%r10,2), %r10
	movq	%rdx, 48(%rsp)
	movq	$31, 56(%rsp)
	xorl	%r11d, %r11d
	cmpq	$999992, %rcx
	setb	%r11b
	movq	%r9, %rsi
	cmovbq	%r8, %rsi
	movq	%rsi, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	(%r10,%r11,2), %rsi
	addq	$2, %rsi
	addq	$2, %rcx
	cmpq	$1000001, %rcx
	jne	.LBB4_3
	leaq	.Lstr13(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rax, (%rbx)
	movl	$10, %ecx
	callq	ll_fact
	movq	%rax, %rdi
	movq	(%rbx), %rax
	movq	%r14, (%rbx)
	leaq	.Lstr16(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	.Lstr17(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	.Lstr18(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	.Lstr19(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	leaq	.Lstr20(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	addq	$1000001, %rsi
	leaq	.Lstr21(%rip), %rcx
	movq	%rcx, 48(%rsp)
	movq	$31, 56(%rsp)
	movq	%rax, (%rbx)
	callq	rt_nl
	movl	$6000001, %ecx
	callq	rt_computed
	callq	rt_sep
	movq	%rsi, %rcx
	callq	rt_computed
	callq	rt_sep
	movq	%rdi, %rcx
	callq	rt_computed
	callq	rt_sep
	movabsq	$6101872691, %rcx
	callq	rt_computed
	leaq	.Lstr24(%rip), %rax
	movq	%rax, 72(%rsp)
	movq	$25, 80(%rsp)
	movq	64(%rsp), %rax
	movq	%rax, (%rbx)
	xorl	%eax, %eax
	.seh_startepilogue
	addq	$136, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	.seh_endepilogue
	retq
	.seh_endproc

	.section	.rdata,"dr"
	.p2align	4, 0x0
.Lstr0:
	.ascii	"  at sumloop (corpus.hb:2)\n"

	.p2align	4, 0x0
.Lstr1:
	.ascii	"  at sumloop (corpus.hb:2)\n"

	.p2align	4, 0x0
.Lstr2:
	.ascii	"  at sumloop (corpus.hb:3)\n"

	.p2align	4, 0x0
.Lstr3:
	.ascii	"  at sumloop (corpus.hb:4)\n"

	.p2align	4, 0x0
.Lstr4:
	.ascii	"  at sumloop (corpus.hb:5)\n"

	.p2align	4, 0x0
.Lstr5:
	.ascii	"  at sumloop (corpus.hb:7)\n"

	.p2align	4, 0x0
.Lstr6:
	.ascii	"  at branchloop (corpus.hb:9)\n"

	.p2align	4, 0x0
.Lstr7:
	.ascii	"  at branchloop (corpus.hb:9)\n"

	.p2align	4, 0x0
.Lstr8:
	.ascii	"  at branchloop (corpus.hb:10)\n"

	.p2align	4, 0x0
.Lstr9:
	.ascii	"  at branchloop (corpus.hb:11)\n"

	.p2align	4, 0x0
.Lstr10:
	.ascii	"  at branchloop (corpus.hb:12)\n"

	.p2align	4, 0x0
.Lstr11:
	.ascii	"  at branchloop (corpus.hb:13)\n"

	.p2align	4, 0x0
.Lstr12:
	.ascii	"  at branchloop (corpus.hb:15)\n"

	.p2align	4, 0x0
.Lstr13:
	.ascii	"  at branchloop (corpus.hb:18)\n"

	.p2align	4, 0x0
.Lstr14:
	.ascii	"  at fact (corpus.hb:20)\n"

	.p2align	4, 0x0
.Lstr15:
	.ascii	"  at fact (corpus.hb:20)\n"

	.p2align	4, 0x0
.Lstr16:
	.ascii	"  at recurrence (corpus.hb:22)\n"

	.p2align	4, 0x0
.Lstr17:
	.ascii	"  at recurrence (corpus.hb:22)\n"

	.p2align	4, 0x0
.Lstr18:
	.ascii	"  at recurrence (corpus.hb:23)\n"

	.p2align	4, 0x0
.Lstr19:
	.ascii	"  at recurrence (corpus.hb:24)\n"

	.p2align	4, 0x0
.Lstr20:
	.ascii	"  at recurrence (corpus.hb:25)\n"

	.p2align	4, 0x0
.Lstr21:
	.ascii	"  at recurrence (corpus.hb:27)\n"

	.p2align	4, 0x0
.Lstr22:
	.ascii	"  at main (corpus.hb:29)\n"

	.p2align	4, 0x0
.Lstr23:
	.ascii	"  at main (corpus.hb:29)\n"

	.p2align	4, 0x0
.Lstr24:
	.ascii	"  at main (corpus.hb:30)\n"

	.section	.rdata$.refptr.hbc_trace_top,"dr",discard,.refptr.hbc_trace_top
	.p2align	3, 0x0
	.globl	.refptr.hbc_trace_top
.refptr.hbc_trace_top:
	.quad	hbc_trace_top
