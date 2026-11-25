	.file	"hrdbf_embedded_linux.c"
	.text
	.p2align 4
	.type	dset, @function
dset:
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	jmp	.L2
	.p2align 4,,10
	.p2align 3
.L4:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.L3
.L2:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L4
.L3:
	movb	$0, (%rax)
	ret
	.size	dset, .-dset
	.p2align 4
	.type	dcat, @function
dcat:
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	jmp	.L7
	.p2align 4,,10
	.p2align 3
.L9:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.L8
.L7:
	cmpb	$0, (%rax)
	jne	.L9
	jmp	.L13
	.p2align 4,,10
	.p2align 3
.L11:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.L13:
	cmpq	%rax, %rdi
	jbe	.L8
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L11
.L8:
	movb	$0, (%rax)
	ret
	.size	dcat, .-dcat
	.p2align 4
	.type	hrv_to_double, @function
hrv_to_double:
	movl	%edi, %eax
	movq	%rsi, %r9
	andl	$255, %eax
	je	.L24
	cmpl	$9, %eax
	je	.L24
	cmpl	$12, %eax
	je	.L29
	movl	$1, %r8d
	cmpl	$5, %eax
	je	.L30
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L24:
	pxor	%xmm0, %xmm0
	xorl	%r8d, %r8d
	cvtsi2sdq	%rsi, %xmm0
	movl	%r8d, %eax
	movsd	%xmm0, (%rdx)
	movl	$0, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L30:
	testq	%rdi, %rdi
	js	.L31
	shrq	$8, %rdi
	movl	$2, %eax
	testl	%edi, %edi
	cmove	%eax, %edi
.L22:
	xorl	%r8d, %r8d
	movq	%r9, (%rdx)
	movl	%r8d, %eax
	movl	%edi, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L29:
	movl	%edi, %eax
	pxor	%xmm0, %xmm0
	andl	$65280, %edi
	movzbl	%ah, %eax
	cvtsi2sdq	%rsi, %xmm0
	movl	%eax, %r8d
	je	.L19
	movsd	.LC0(%rip), %xmm1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L20:
	divsd	%xmm1, %xmm0
	addl	$1, %eax
	cmpl	%r8d, %eax
	jne	.L20
.L19:
	movsd	%xmm0, (%rdx)
	movl	%r8d, (%rcx)
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L31:
	movq	(%rsi), %r9
	movzwl	8(%rsi), %edi
	jmp	.L22
	.size	hrv_to_double, .-hrv_to_double
	.p2align 4
	.type	bn_shl, @function
bn_shl:
	pushq	%r12
	movl	%esi, %r10d
	pushq	%rbp
	shrl	$5, %r10d
	pushq	%rbx
	movl	288(%rdi), %r12d
	leal	(%r12,%r10), %r8d
	cmpl	$71, %r8d
	ja	.L32
	movl	%esi, %ebp
	movq	%rdi, %rdx
	movl	%esi, %r9d
	andl	$31, %ebp
	je	.L35
	testl	%r12d, %r12d
	je	.L36
	movl	$32, %r11d
	leal	-1(%r12), %ecx
	movq	%rdi, %rax
	xorl	%r8d, %r8d
	subl	%ebp, %r11d
	leaq	4(%rdi,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.L37:
	movl	(%rax), %edi
	movl	%ebp, %ecx
	addq	$4, %rax
	movl	%edi, %esi
	sall	%cl, %esi
	movl	%r11d, %ecx
	orl	%r8d, %esi
	shrl	%cl, %edi
	movl	%esi, -4(%rax)
	movl	%edi, %r8d
	cmpq	%rbx, %rax
	jne	.L37
	testl	%edi, %edi
	je	.L41
	leal	1(%r12), %eax
	movl	%eax, 288(%rdx)
	movl	%edi, (%rdx,%r12,4)
.L41:
	cmpl	$31, %r9d
	jbe	.L32
	movl	288(%rdx), %r8d
	leal	-1(%r8), %ecx
	addl	%r10d, %r8d
	jmp	.L46
	.p2align 4,,10
	.p2align 3
.L35:
	cmpl	$31, %esi
	jbe	.L32
	leal	-1(%r12), %ecx
	testl	%r12d, %r12d
	je	.L39
.L46:
	movl	%ecx, %eax
	addl	%r10d, %ecx
	leaq	(%rdx,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.L42:
	movl	(%rax), %edi
	movl	%ecx, %esi
	subl	$1, %ecx
	movl	%edi, (%rdx,%rsi,4)
	movq	%rax, %rsi
	subq	$4, %rax
	cmpq	%rdx, %rsi
	jne	.L42
.L39:
	testl	%r10d, %r10d
	je	.L45
	leal	-1(%r10), %ecx
	movq	%rdx, %rax
	leaq	4(%rdx,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L44:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rcx
	jne	.L44
.L45:
	movl	%r8d, 288(%rdx)
.L32:
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L36:
	cmpl	$31, %esi
	jbe	.L32
	movl	%r10d, %r8d
	jmp	.L39
	.size	bn_shl, .-bn_shl
	.p2align 4
	.type	bn_divmod_1e9, @function
bn_divmod_1e9:
	pushq	%rbx
	movl	288(%rdi), %ebx
	testl	%ebx, %ebx
	je	.L65
	movabsq	$19342813113834067, %r11
	movq	%rdi, %r9
	leal	-1(%rbx), %edi
	movl	%edi, %eax
	leaq	(%r9,%rax,4), %r8
	xorl	%eax, %eax
	movq	%r8, %rcx
	.p2align 4,,10
	.p2align 3
.L62:
	movl	(%rcx), %esi
	salq	$32, %rax
	movq	%rcx, %r10
	subq	$4, %rcx
	orq	%rax, %rsi
	movq	%rsi, %rdx
	shrq	$9, %rdx
	movq	%rdx, %rax
	mulq	%r11
	movq	%rsi, %rax
	shrq	$11, %rdx
	movl	%edx, 4(%rcx)
	imulq	$1000000000, %rdx, %rdx
	subq	%rdx, %rax
	cmpq	%r9, %r10
	jne	.L62
	cmpl	$1, %ebx
	jne	.L63
	jmp	.L60
	.p2align 4,,10
	.p2align 3
.L64:
	movl	%edi, 288(%r9)
	subq	$4, %r8
	subl	$1, %edi
	je	.L60
.L63:
	movl	(%r8), %edx
	testl	%edx, %edx
	je	.L64
.L60:
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L65:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.size	bn_divmod_1e9, .-bn_divmod_1e9
	.p2align 4
	.type	fset, @function
fset:
	leaq	32977(%rdi), %rax
	addq	$33136, %rdi
	jmp	.L73
	.p2align 4,,10
	.p2align 3
.L75:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.L74
.L73:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L75
.L74:
	movb	$0, (%rax)
	ret
	.size	fset, .-fset
	.p2align 4
	.type	fcat, @function
fcat:
	leaq	32977(%rdi), %rax
	addq	$33136, %rdi
	jmp	.L77
	.p2align 4,,10
	.p2align 3
.L79:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.L78
.L77:
	cmpb	$0, (%rax)
	jne	.L79
	jmp	.L83
	.p2align 4,,10
	.p2align 3
.L81:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.L83:
	cmpq	%rax, %rdi
	jbe	.L78
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L81
.L78:
	movb	$0, (%rax)
	ret
	.size	fcat, .-fcat
	.p2align 4
	.type	nxvisit, @function
nxvisit:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$56, %rsp
	movq	(%rdi), %rax
	movq	(%rax), %r12
	cmpl	$63, %edx
	ja	.L88
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.L88
	testl	$1023, %esi
	jne	.L88
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.L88
	movl	%ebx, %ecx
	movl	%ebx, %eax
	movl	%edx, %esi
	movl	$1, %edx
	shrl	$10, %ecx
	shrl	$13, %eax
	addq	16(%rbp), %rax
	andl	$7, %ecx
	sall	%cl, %edx
	movzbl	(%rax), %ecx
	testb	%dl, %cl
	jne	.L88
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.L88
	testw	%r13w, %r13w
	jne	.L112
	testl	%esi, %esi
	je	.L112
	.p2align 4,,10
	.p2align 3
.L88:
	movl	$1, %eax
.L84:
	addq	$56, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L112:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.L93:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.L88
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.L88
	testw	%r11w, %r11w
	je	.L90
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.L92:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.L91
	cmpl	%r10d, %edx
	jl	.L88
.L91:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.L92
.L90:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.L93
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.L94
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.L128
	cmpl	%esi, %eax
	jne	.L88
.L94:
	testl	%r15d, %r15d
	movzwl	%r13w, %eax
	movq	%r14, %r13
	setne	23(%rsp)
	addq	%rax, %rax
	leaq	2(%r14,%rax), %rcx
	addq	%r14, %rax
	movq	%rax, 8(%rsp)
	leal	1(%rsi), %eax
	movq	%rcx, 24(%rsp)
	movl	%eax, 40(%rsp)
.L108:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.L88
	testl	%r15d, %r15d
	jne	.L96
.L99:
	cmpq	%r13, 8(%rsp)
	je	.L97
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.L101
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.L101
	cmpl	36(%rbp), %edx
	jbe	.L101
	leal	-1(%rax), %esi
	movl	$1, %edx
	movl	%esi, %ecx
	andl	$7, %ecx
	sall	%cl, %edx
	movl	%edx, %ecx
	movl	%esi, %edx
	shrl	$3, %edx
	addq	24(%rbp), %rdx
	movzbl	(%rdx), %edi
	testb	%cl, %dil
	jne	.L101
	orl	%ecx, %edi
	movzwl	%r8w, %r8d
	movb	%dil, (%rdx)
	movq	0(%rbp), %rdi
	leal	8(%rbx,%r8), %r10d
	movq	8(%rbp), %rdx
	movzwl	30(%rdi), %r8d
	movzwl	28(%rdi), %r9d
	movq	(%rdx), %rcx
	salq	$4, %r8
	movzwl	56(%r8,%rdx), %r11d
	movzwl	32(%rdx), %r8d
	movzwl	34(%rdx), %edx
	addq	%r8, %r11
	movl	%r10d, %r8d
	imulq	%rsi, %rdx
	addq	%rdx, %r11
	testq	%r9, %r9
	je	.L102
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.L103
	.p2align 4,,10
	.p2align 3
.L130:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.L129
.L103:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.L130
.L101:
	movl	$4, %eax
	jmp	.L84
.L96:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call	nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.L99
	jmp	.L84
	.p2align 4,,10
	.p2align 3
.L129:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.L111
.L127:
	movq	16(%rdi), %rsi
.L106:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.L108
.L97:
	xorl	%eax, %eax
	jmp	.L84
.L128:
	movl	%esi, 40(%rbp)
	jmp	.L94
.L111:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.L107
.L105:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.L109
.L107:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.L105
	jb	.L106
	jmp	.L88
.L102:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.L127
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.L109:
	cmpl	%r11d, %eax
	ja	.L106
	jmp	.L88
	.size	nxvisit, .-nxvisit
	.p2align 4
	.globl	hrntx_open
	.type	hrntx_open, @function
hrntx_open:
	endbr64
	pushq	%r15
	movl	$1, %r10d
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	movq	%rcx, %rbp
	leaq	-2048(%rdx), %rcx
	pushq	%rbx
	subq	$72, %rsp
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movq	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	cmpq	$67106816, %rcx
	ja	.L131
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.L131
	testl	$1023, %edx
	jne	.L131
	testq	%rbp, %rbp
	je	.L131
	cmpb	$0, 40(%rbp)
	je	.L131
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.L131
	cmpw	$0, 16(%rsi)
	jne	.L131
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.L134
	.p2align 4,,10
	.p2align 3
.L133:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.L195
.L134:
	cmpq	$11, %rcx
	jbe	.L133
	cmpb	$0, 538(%rax,%rcx)
	je	.L133
.L167:
	movl	$2, %r10d
.L131:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L195:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.L131
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.L131
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.L131
	movl	%esi, %ecx
	shrw	%cx
	cmpw	20(%rax), %cx
	jne	.L131
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.L135
	jmp	.L131
	.p2align 4,,10
	.p2align 3
.L136:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.L167
.L135:
	cmpb	$0, 22(%rax,%r12)
	jne	.L136
	testq	%r12, %r12
	je	.L167
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.L167
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.L137:
	xorl	%esi, %esi
	jmp	.L146
	.p2align 4,,10
	.p2align 3
.L196:
	leal	-97(%rcx), %r10d
	leal	-32(%rcx), %edi
	cmpb	$26, %r10b
	cmovb	%edi, %ecx
	movzbl	22(%rax,%rsi), %edi
	leal	-97(%rdi), %r11d
	leal	-32(%rdi), %r10d
	cmpb	$26, %r11b
	cmovb	%r10d, %edi
	cmpb	%cl, %dil
	jne	.L139
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.L138
	cmpq	$10, %rsi
	ja	.L138
.L146:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.L196
.L139:
	cmpq	%r12, %rsi
	je	.L151
.L143:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.L137
	jmp	.L167
.L138:
	cmpq	%r12, %rsi
	jne	.L143
	cmpq	$11, %rsi
	je	.L144
.L151:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.L143
.L144:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.L167
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.L131
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.L131
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.L173
	testq	%r8, %r8
	jne	.L174
	testl	%ecx, %ecx
	jne	.L173
.L174:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.L173
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.L173
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.L148:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.L148
	movw	%si, 30(%rbx)
	movq	128(%rsp), %rsi
	movq	%rdx, 8(%rbx)
	xorl	%edx, %edx
	addq	%rsi, %rdi
	movq	%rsi, 32(%rsp)
	movzwl	4(%rsp), %esi
	movq	%rax, (%rbx)
	movw	%si, 48(%rsp)
	movzwl	2(%rsp), %esi
	movq	%r8, 16(%rbx)
	movw	%si, 50(%rsp)
	movl	$4294967295, %esi
	movw	%r15w, 28(%rbx)
	salq	$32, %rsi
	movq	%rsi, 52(%rsp)
	movl	4(%rax), %esi
	movq	%rdi, 40(%rsp)
	leaq	16(%rsp), %rdi
	movq	%rbx, 16(%rsp)
	movq	%rbp, 24(%rsp)
	call	nxvisit
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L149
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.L150
	movl	$4, %r10d
.L149:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L131
.L150:
	movl	%eax, 24(%rbx)
	jmp	.L131
.L173:
	movl	$3, %r10d
	jmp	.L131
	.size	hrntx_open, .-hrntx_open
	.p2align 4
	.type	nxputslot, @function
nxputslot:
	imulq	%rsi, %rcx
	movq	%rdx, %r11
	movq	%rdi, %r10
	pushq	%rbx
	movl	%r8d, %edx
	movl	24(%rsp), %eax
	shrl	$16, %r8d
	movq	16(%rsp), %rdi
	addq	%r11, %rcx
	movw	%cx, 2(%r10,%rsi,2)
	leaq	(%r10,%rcx), %rsi
	movb	%dh, 1(%rsi)
	shrl	$24, %edx
	movb	$0, (%rsi)
	movb	%r8b, 2(%rsi)
	movb	%dl, 3(%rsi)
	movl	%r9d, 4(%r10,%rcx)
	movzwl	%ax, %ecx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L199:
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.L198
	movzbl	(%rdi,%rax), %edx
.L198:
	movb	%dl, 8(%rsi,%rax)
	addq	$1, %rax
	cmpl	%eax, %ecx
	ja	.L199
	popq	%rbx
	ret
	.size	nxputslot, .-nxputslot
	.p2align 4
	.type	cxleaf_header, @function
cxleaf_header:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	movzwl	2(%rdi), %r13d
	movw	%r13w, (%rdx)
	movzwl	12(%rdi), %ebp
	movw	%bp, 2(%rdx)
	movl	14(%rdi), %r11d
	movl	%r11d, 20(%rdx)
	movzbl	18(%rdi), %ebx
	movl	%ebx, 24(%rdx)
	movzbl	19(%rdi), %r12d
	movl	%r12d, 28(%rdx)
	movzbl	20(%rdi), %ecx
	movl	%ecx, 4(%rdx)
	movzbl	21(%rdi), %r9d
	leal	-1(%rcx), %eax
	cmpl	$31, %eax
	movl	%r9d, 8(%rdx)
	movzbl	22(%rdi), %r14d
	seta	%al
	movl	%r14d, 12(%rdx)
	movzbl	23(%rdi), %r10d
	movl	%r10d, 16(%rdx)
	leal	-1(%r9), %edx
	cmpb	$7, %dl
	seta	%dl
	orl	%edx, %eax
	leal	-1(%r14), %edx
	cmpb	$7, %dl
	seta	%dl
	orb	%al, %dl
	jne	.L210
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.L212
.L210:
	movl	$1, %eax
.L204:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L212:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.L204
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.L204
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.L204
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.L210
	cmpl	%edi, %r12d
	jb	.L210
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.L204
	.size	cxleaf_header, .-cxleaf_header
	.p2align 4
	.type	cxkey, @function
cxkey:
	pushq	%r12
	movq	%rsi, %r10
	movl	%ecx, %r11d
	pushq	%rbp
	pushq	%rbx
	movl	%edx, %ebx
	movl	16(%rsi), %edx
	movl	20(%rsi), %ebp
	testl	%edx, %edx
	je	.L214
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L215:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.L215
	movq	32(%rsp), %rax
	andl	%esi, %ebp
	movq	%rsi, %rdx
	movl	%ebp, (%rax)
	movl	4(%r10), %ecx
	movl	8(%r10), %ebp
	movl	28(%r10), %eax
	shrq	%cl, %rdx
	andl	24(%r10), %edx
	testl	%ebx, %ebx
	jne	.L216
	testl	%edx, %edx
	je	.L216
.L218:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L216:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.L218
.L224:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.L218
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.L218
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.L219
	xorl	%eax, %eax
	jmp	.L220
	.p2align 4,,10
	.p2align 3
.L237:
	movq	(%r9), %rcx
.L220:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.L237
.L219:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.L223
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L222:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L222
.L223:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L214:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.L224
	.size	cxkey, .-cxkey
	.p2align 4
	.type	cxvisit, @function
cxvisit:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$328, %rsp
	movq	$512, 24(%rsp)
	cmpl	$64, %edx
	je	.L241
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.L293
.L241:
	movl	$1, %r12d
.L238:
	addq	$328, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L293:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.L241
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.L241
	movl	%eax, %ecx
	movl	$1, %edx
	shrl	$9, %ecx
	andl	$7, %ecx
	sall	%cl, %edx
	movl	%edx, %ecx
	movl	%eax, %edx
	shrl	$12, %edx
	addq	32(%rdi), %rdx
	movzbl	(%rdx), %edi
	testb	%cl, %dil
	jne	.L241
	orl	%ecx, %edi
	xorl	%ecx, %ecx
	movb	%dil, (%rdx)
	addq	(%rbx), %rbp
	testl	%esi, %esi
	movzwl	0(%rbp), %edx
	sete	%cl
	movzwl	2(%rbp), %r13d
	movl	%edx, %edi
	cmpl	%edx, %ecx
	je	.L242
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.L241
.L242:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.L294
	cmpl	%r8d, %ecx
	jne	.L241
	cmpl	%eax, 312(%rdx)
	jne	.L241
.L264:
	cmpl	$-1, %r9d
	je	.L246
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.L241
	testl	$511, %r9d
	jne	.L241
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.L241
.L246:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.L247
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.L295
	cmpl	%esi, %eax
	jne	.L241
.L249:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call	cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L238
	testl	%r14d, %r14d
	je	.L259
	movl	%r15d, %ecx
.L250:
	leaq	20(%rsp), %rax
	movl	%r12d, %edx
	movq	%rbp, %rdi
	pushq	%rax
	leaq	32(%rsp), %r9
	leaq	72(%rsp), %r8
	leaq	40(%rsp), %rsi
	call	cxkey
	popq	%rdx
	testl	%eax, %eax
	jne	.L269
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.L252
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.L252
	cmpl	48(%rbx), %eax
	jbe	.L252
	leal	-1(%r8), %esi
	movl	$1, %eax
	movl	%esi, %ecx
	andl	$7, %ecx
	sall	%cl, %eax
	movl	%eax, %ecx
	movl	%esi, %eax
	shrl	$3, %eax
	addq	40(%rbx), %rax
	movzbl	(%rax), %edx
	testb	%cl, %dl
	jne	.L252
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movq	16(%rbx), %rax
	movq	24(%rbx), %r11
	movzwl	34(%rax), %edi
	movzwl	32(%rax), %edx
	movzwl	28(%r11), %ecx
	movq	(%rax), %r10
	imull	%esi, %edi
	movq	%rcx, %r9
	addl	%edx, %edi
	movzwl	30(%r11), %edx
	salq	$4, %rdx
	movzwl	56(%rdx,%rax), %edx
	addl	%edi, %edx
	movq	%rdx, %rdi
	testq	%rcx, %rcx
	je	.L253
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.L254
.L297:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.L296
	movq	%rdx, %rax
.L254:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.L297
.L252:
	movl	$4, %r12d
	jmp	.L238
	.p2align 4,,10
	.p2align 3
.L294:
	cmpl	$-1, %r8d
	jne	.L241
	jmp	.L264
.L247:
	testl	%r14d, %r14d
	je	.L241
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.L241
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.L262:
	leal	8(%rcx), %eax
	movl	%edi, %r12d
	movq	%rbp, %rdi
	imull	%r15d, %eax
	leal	12(%rax), %r9d
	movl	%eax, %ebx
	addq	%r13, %r9
	movl	4(%r9,%rdx), %esi
	movl	%r14d, %edx
	movq	%r9, (%rsp)
	bswap	%esi
	call	cxvisit
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L290
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.L241
	movq	24(%rbp), %rdx
	movq	(%rsp), %r9
	leal	-1(%rdi), %eax
	movq	16(%rdx), %rcx
	movzwl	28(%rdx), %edx
	leaq	(%rcx,%rax,8), %rcx
	movl	(%r9,%rdx), %eax
	movq	%rdx, %r11
	movl	4(%rcx), %esi
	bswap	%eax
	cmpl	%eax, (%rcx)
	jne	.L241
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.L260
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.L261
	.p2align 4,,10
	.p2align 3
.L298:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L260
.L261:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.L298
	jmp	.L241
.L295:
	movl	%esi, 52(%rbx)
	jmp	.L249
.L260:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.L290
	movzwl	%r11w, %ecx
	jmp	.L262
.L296:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.L267
.L292:
	movq	16(%r11), %rcx
.L257:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.L259
	movzwl	%r9w, %ecx
	jmp	.L250
.L290:
	movl	%r10d, %r12d
	jmp	.L238
.L253:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.L292
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.L265:
	cmpl	%r11d, %r8d
	ja	.L257
	jmp	.L241
.L267:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.L258
.L256:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.L265
	movq	%r15, %rsi
.L258:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.L256
	jb	.L257
	jmp	.L241
.L269:
	movl	%eax, %r12d
	jmp	.L238
.L259:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.L238
	.size	cxvisit, .-cxvisit
	.p2align 4
	.type	cxheader, @function
cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.L299
	cmpb	$1, 15(%rdi)
	jne	.L299
	cmpw	$1024, 16(%rdi)
	jne	.L299
	cmpw	$512, 18(%rdi)
	jne	.L299
	cmpw	$0, 502(%rdi)
	jne	.L299
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.L302
	.p2align 4,,10
	.p2align 3
.L321:
	cmpl	$23, %eax
	ja	.L309
.L301:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.L320
.L302:
	cmpb	$0, (%rdi,%rax)
	je	.L301
	testb	%cl, %cl
	je	.L321
.L309:
	movl	$2, %eax
.L299:
	ret
.L320:
	testl	%edx, %edx
	je	.L303
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.L299
	cmpb	$67, 21(%rdi)
	jne	.L299
	cmpb	$72, 22(%rdi)
	jne	.L299
	cmpb	$66, 23(%rdi)
	jne	.L299
.L303:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.L299
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.L299
	xorl	%eax, %eax
	cmpw	$0, 508(%rdi)
	setne	%al
	addl	%eax, %eax
	ret
	.size	cxheader, .-cxheader
	.p2align 4
	.type	hrdbf_app_pad_ll, @function
hrdbf_app_pad_ll:
	pushq	%rbx
	movl	%esi, %r9d
	movq	%rdi, %r11
	movq	%rdx, %r8
	movq	%rdi, %rsi
	subq	$32, %rsp
	testq	%rdi, %rdi
	js	.L341
	jne	.L324
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r9
	je	.L326
.L325:
	leaq	(%r8,%rsi), %rax
	leaq	(%rax,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L330:
	movb	$48, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L330
	addq	%rsi, %r9
.L326:
	movq	%rsp, %rdi
	leaq	-1(%rsp,%rcx), %rax
	leaq	(%r8,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L331:
	movzbl	(%rax), %esi
	addq	$1, %rdx
	movb	%sil, -1(%rdx)
	movq	%rax, %rsi
	subq	$1, %rax
	cmpq	%rsi, %rdi
	jne	.L331
	addq	$32, %rsp
	leaq	(%rcx,%r9), %rax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L341:
	negq	%rsi
.L324:
	movabsq	$-3689348814741910323, %rbx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L327:
	movq	%rsi, %rax
	movq	%rcx, %r10
	addq	$1, %rcx
	mulq	%rbx
	movq	%rsi, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rdi
	addq	%rdi, %rdi
	subq	%rdi, %rax
	addl	$48, %eax
	movb	%al, -1(%rsp,%rcx)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	cmpq	$9, %rax
	ja	.L327
	testq	%r11, %r11
	jns	.L333
	movb	$45, (%r8)
	addq	$2, %r10
	movl	$1, %esi
.L328:
	subq	%r10, %r9
	jne	.L325
	movq	%rsi, %r9
	jmp	.L326
.L333:
	movq	%rcx, %r10
	xorl	%esi, %esi
	jmp	.L328
	.size	hrdbf_app_pad_ll, .-hrdbf_app_pad_ll
	.p2align 4
	.type	hrdbf_file_append.part.0, @function
hrdbf_file_append.part.0:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$24, %rsp
	movzwl	34(%rdi), %r12d
	movl	16(%rdi), %ebp
	movzwl	32(%rdi), %eax
	imulq	%r12, %rbp
	addq	$1, %r12
	addq	%rax, %rbp
	movl	$4, %eax
	leaq	0(%rbp,%r12), %r14
	cmpq	$1073741824, %r14
	ja	.L342
	movl	$9, %r13d
	movq	%rdi, %rbx
	movq	%rsi, %r15
	xorl	%r9d, %r9d
	movl	$34, %r10d
	xorl	%edi, %edi
	movl	$3, %edx
	movq	%r13, %rax
	movq	$-1, %r8
	movq	%r14, %rsi
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	leaq	4095(%rax), %rdx
	movq	%rax, %r13
	movl	$8, %eax
	cmpq	$4094, %rdx
	jbe	.L342
	testq	%r13, %r13
	je	.L342
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 32952(%rbx)
	je	.L347
	.p2align 4,,10
	.p2align 3
.L344:
	movq	32944(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	32952(%rbx), %rax
	jb	.L344
.L347:
	leaq	0(%r13,%rbp), %r8
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r8, %rdx
	je	.L346
	.p2align 4,,10
	.p2align 3
.L345:
	movb	$32, (%r8,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L345
	addq	%r8, %rdx
.L346:
	movb	$26, (%rdx)
	xorl	%edx, %edx
	movq	%rsp, %rsi
	movl	$228, %eax
	movq	%rdx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L348
	movabsq	$1749024623285053783, %rdx
	movq	(%rsp), %rcx
	movabsq	$4137408090565272301, %rsi
	movabsq	$-1896998432287073591, %rdi
	movabsq	$3234497591006606311, %r11
	movq	%rcx, %rax
	sarq	$63, %rcx
	imulq	%rdx
	sarq	$13, %rdx
	subq	%rcx, %rdx
	leaq	719468(%rdx), %rcx
	movq	%rcx, %rax
	mulq	%rsi
	movq	%rdx, %r10
	movq	%rdx, %rsi
	shrq	$15, %r10
	shrq	$15, %rsi
	imulq	$146097, %r10, %rax
	subq	%rax, %rcx
	movq	%rcx, %rax
	movq	%rcx, %r10
	mulq	%rdi
	movq	%rdx, %rdi
	movq	%rdx, %rcx
	movq	%r10, %rdx
	shrq	$2, %rdx
	shrq	$15, %rcx
	movq	%rdx, %rax
	addq	%r10, %rcx
	shrq	$17, %rdi
	mulq	%r11
	shrq	$6, %rdx
	subq	%rdx, %rcx
	movabsq	$7429236654343298871, %rdx
	subq	%rdi, %rcx
	movq	%rcx, %rax
	mulq	%rdx
	movq	%rcx, %rax
	shrq	$2, %rcx
	subq	%rdx, %rax
	shrq	%rax
	leaq	(%rdx,%rax), %rdi
	leaq	(%rsi,%rsi,4), %rax
	movabsq	$2070078458244228039, %rdx
	leaq	(%rax,%rax,4), %r9
	movq	%rcx, %rax
	shrq	$8, %rdi
	mulq	%rdx
	movq	%rcx, %rax
	salq	$4, %r9
	addq	%rdi, %r9
	shrq	$10, %rdx
	leaq	(%rdx,%r10), %rsi
	movabsq	$-3689348814741910323, %r10
	mulq	%r11
	leaq	(%rdi,%rdi,8), %rax
	leaq	(%rdi,%rax,8), %rax
	leaq	(%rax,%rax,4), %rax
	shrq	$6, %rdx
	subq	%rdx, %rsi
	movabsq	$3858142551364089227, %rdx
	movq	%rsi, %rcx
	subq	%rax, %rcx
	leaq	2(%rcx,%rcx,4), %rdi
	movq	%rdi, %rax
	mulq	%rdx
	movq	%rdx, %rsi
	shrq	$5, %rsi
	addq	$1, %rcx
	leaq	(%rsi,%rsi,8), %rax
	movq	%rax, %rdx
	salq	$4, %rdx
	leaq	2(%rax,%rdx), %rdx
	movq	%rdx, %rax
	mulq	%r10
	shrq	$2, %rdx
	subq	%rdx, %rcx
	cmpq	$1529, %rdi
	jbe	.L382
	subq	$9, %rsi
	cmpq	$3, %rsi
	adcq	$0, %r9
.L350:
	subl	$108, %r9d
	movb	%sil, 2(%r13)
	movl	$7, %edx
	leaq	1(%r13), %rsi
	movb	%r9b, 1(%r13)
	movl	$1, %r10d
	movl	$18, %r9d
	movb	%cl, 3(%r13)
	movl	16(%rbx), %eax
	movb	$0, 28(%r13)
	addl	$1, %eax
	movl	%eax, 4(%r13)
	.p2align 4,,10
	.p2align 3
.L353:
	movq	32968(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L353
	testq	%rax, %rax
	jle	.L348
	cmpq	%rdx, %rax
	ja	.L348
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L353
	leaq	28(%r13), %rsi
	movl	$18, %r9d
	movl	$1, %edx
.L354:
	movq	32968(%rbx), %rdi
	movl	$28, %r10d
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L354
	cmpq	$1, %rax
	jne	.L348
	movl	$18, %r9d
	movq	%r8, %rsi
	movq	%rbp, %r10
	movq	%r12, %rdx
.L355:
	movq	32968(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L355
	testq	%rax, %rax
	jle	.L348
	cmpq	%rdx, %rax
	ja	.L348
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L355
	movq	32944(%rbx), %rdi
	movq	32952(%rbx), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L348
	movl	16(%rbx), %eax
	xorl	%edx, %edx
	movq	%r13, (%rbx)
	movq	%r13, 32944(%rbx)
	leal	1(%rax), %edi
	movq	%r14, 32952(%rbx)
	xorl	%eax, %eax
	movq	%r14, 8(%rbx)
	movl	%edi, 16(%rbx)
	movq	%rdi, 24(%rbx)
	movw	%dx, 38(%rbx)
	movl	%edi, (%r15)
.L342:
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L348:
	movl	$11, %eax
	xorl	%edx, %edx
	movq	%r13, %rdi
	movq	%r14, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	addq	$24, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L382:
	addq	$3, %rsi
	jmp	.L350
	.size	hrdbf_file_append.part.0, .-hrdbf_file_append.part.0
	.p2align 4
	.type	hrntx_file_flush.part.0.constprop.0, @function
hrntx_file_flush.part.0.constprop.0:
	xorl	%r10d, %r10d
	movl	$hrdbf_app_ntxpath, %esi
	movl	$257, %r9d
	movq	$-100, %rdi
	movl	$524290, %edx
	.p2align 4,,10
	.p2align 3
.L384:
	movq	%r9, %rax
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r8
	cmpq	$-4, %rax
	je	.L384
	testq	%rax, %rax
	js	.L401
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r10d, %r10d
	xorl	%esi, %esi
	movq	%r8, %rdi
	movl	$77, %eax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L387
	movq	hrdbf_app_order+48(%rip), %rdx
	movl	$18, %r9d
	testq	%rdx, %rdx
	je	.L389
	.p2align 4,,10
	.p2align 3
.L388:
	movq	hrdbf_app_order+32(%rip), %rsi
	subq	%r10, %rdx
	movq	%r9, %rax
	movq	%r8, %rdi
	addq	%r10, %rsi
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L390
	testq	%rax, %rax
	jle	.L402
	addq	%rax, %r10
.L390:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r10, %rdx
	ja	.L388
.L389:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r8, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L401
	movl	$0, hrdbf_app_order+64(%rip)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L387:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L401:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L402:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %eax
	ret
	.size	hrntx_file_flush.part.0.constprop.0, .-hrntx_file_flush.part.0.constprop.0
	.p2align 4
	.type	hrntx_file_close.constprop.0, @function
hrntx_file_close.constprop.0:
	movq	hrdbf_app_order+32(%rip), %rdi
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.L404
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	testq	%rax, %rax
	js	.L404
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L404:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L403
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L408
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L403:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L408:
	movl	$7, %r8d
	movl	%r8d, %eax
	ret
	.size	hrntx_file_close.constprop.0, .-hrntx_file_close.constprop.0
	.p2align 4
	.type	cxmark.isra.0, @function
cxmark.isra.0:
	movl	%esi, %ecx
	shrl	$3, %esi
	movl	$1, %eax
	addq	%rsi, %rdi
	andl	$7, %ecx
	movzbl	(%rdi), %edx
	sall	%cl, %eax
	testb	%al, %dl
	jne	.L413
	orl	%eax, %edx
	movb	%dl, (%rdi)
.L413:
	ret
	.size	cxmark.isra.0, .-cxmark.isra.0
	.p2align 4
	.globl	hrcdx_open
	.type	hrcdx_open, @function
hrcdx_open:
	endbr64
	pushq	%r15
	leaq	-2048(%rdx), %rax
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$936, %rsp
	movq	$0, (%rdi)
	movq	$512, 56(%rsp)
	movq	$0, 8(%rdi)
	movq	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	cmpq	$67106816, %rax
	ja	.L419
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.L419
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.L419
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.L419
	cmpb	$0, 40(%rcx)
	je	.L419
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call	cxheader
	testl	%eax, %eax
	jne	.L415
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.L415
	cmpw	$1, 510(%r12)
	jne	.L415
	cmpb	$0, 512(%r12)
	jne	.L415
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.L419
	testl	$511, %r10d
	jne	.L419
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.L419
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.L415
	cmpw	$1, 2(%r12,%rdx)
	jne	.L415
	cmpl	$-1, 4(%r12,%rdx)
	jne	.L419
	cmpl	$-1, 8(%r12,%rdx)
	jne	.L419
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L415
	leaq	52(%rsp), %rax
	xorl	%edx, %edx
	movq	%r8, %r14
	movl	$10, %ecx
	pushq	%rax
	movq	16(%rsp), %rdi
	leaq	64(%rsp), %r9
	leaq	104(%rsp), %r8
	leaq	72(%rsp), %rsi
	call	cxkey
	popq	%rdx
	testl	%eax, %eax
	jne	.L415
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L419
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.L419
	testl	$511, %r8d
	jne	.L419
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.L419
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.L419
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.L419
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.L419
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L420
.L493:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.L457
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L492
.L420:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L493
.L457:
	movl	$2, %eax
	jmp	.L415
	.p2align 4,,10
	.p2align 3
.L419:
	movl	$1, %eax
.L415:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L492:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call	cxheader
	testl	%eax, %eax
	jne	.L415
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L457
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.L457
	cmpb	$0, (%r12,%rdx)
	jne	.L457
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.L421:
	cmpb	$0, (%rdi,%rdx)
	je	.L457
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.L421
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.L422:
	cmpq	%r11, 40(%rsp)
	jbe	.L457
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.L431:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.L425
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.L426
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.L426:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.L427
	subl	$32, %esi
.L427:
	cmpb	16(%rsp), %sil
	jne	.L425
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L423
	cmpq	$11, %rdx
	jne	.L431
	cmpq	$11, %rax
	jne	.L425
.L429:
	cmpl	%r11d, 36(%rsp)
	je	.L457
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.L457
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.L456
	cmpw	12(%r12,%r9), %ax
	jne	.L457
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.L461
	testq	%r14, %r14
	jne	.L463
	testl	%eax, %eax
	jne	.L461
.L463:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.L461
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.L461
	xorl	%edx, %edx
.L433:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L433
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L434
	orl	$1, %eax
	movb	%al, (%rcx)
.L434:
	testb	$2, %al
	jne	.L435
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L435:
	movq	992(%rsp), %rdi
	movl	%r10d, %esi
	shrl	$9, %r8d
	shrl	$9, %esi
	call	cxmark.isra.0
	movq	992(%rsp), %rdi
	movl	%r8d, %esi
	call	cxmark.isra.0
	movq	992(%rsp), %rdi
	leal	1(%r8), %esi
	call	cxmark.isra.0
	movq	0(%r13), %rax
	movq	%r12, 352(%rsp)
	leaq	608(%rsp), %rdx
	movq	%rbp, 360(%rsp)
	movq	%rax, (%rbx)
	movq	8(%r13), %rax
	movq	%r13, 368(%rsp)
	movq	%rax, 8(%rbx)
	movq	8(%rsp), %rax
	movq	%r14, 16(%rbx)
	movzbl	54(%rax), %eax
	movl	$0, 24(%rbx)
	movw	%r11w, 30(%rbx)
	movw	%ax, 28(%rbx)
	movq	992(%rsp), %rax
	movq	%rbx, 376(%rsp)
	addq	%rax, %r9
	movq	%rax, 384(%rsp)
	movl	$4294967295, %eax
	movq	%r9, 392(%rsp)
	salq	$32, %rax
	movq	%rax, 400(%rsp)
	leaq	352(%rsp), %rax
.L436:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L436
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call	cxvisit
	testl	%eax, %eax
	je	.L494
.L437:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L415
.L423:
	cmpq	$11, %rax
	je	.L429
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L429
.L425:
	addq	$1, %r11
	jmp	.L422
.L461:
	movl	$3, %eax
	jmp	.L415
.L456:
	movl	$5, %eax
	jmp	.L415
.L494:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.L437
	xorl	%edx, %edx
	jmp	.L439
.L495:
	cmpq	$63, %rdx
	ja	.L464
.L439:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.L438
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.L438:
	addq	$1, %rdx
	testb	$1, %al
	je	.L495
.L464:
	testl	%eax, %eax
	jne	.L437
	movl	%ecx, 24(%rbx)
	jmp	.L415
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	put_number.isra.0, @function
put_number.isra.0:
	movl	%esi, %r11d
	movl	$3, %r10d
	movl	%edx, %esi
	cmpb	$78, %r11b
	jne	.L496
	movzwl	%cx, %ecx
	leaq	(%rdi,%rcx), %rdx
	movzbl	%sil, %ecx
	cmpl	%r9d, %ecx
	jb	.L517
	subl	%r9d, %ecx
	je	.L502
	leal	-1(%rcx), %edi
	movq	%rdx, %rax
	addq	%rdx, %rdi
	.p2align 4,,10
	.p2align 3
.L503:
	movq	%rax, %rsi
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdi, %rsi
	jne	.L503
.L502:
	testl	%r9d, %r9d
	je	.L501
	leal	-1(%r9), %eax
	leaq	1(%r8,%rax), %rdi
	movl	%ecx, %eax
	subl	%r8d, %eax
	.p2align 4,,10
	.p2align 3
.L504:
	movzbl	(%r8), %esi
	leal	(%rax,%r8), %ecx
	addq	$1, %r8
	movb	%sil, (%rdx,%rcx)
	cmpq	%rdi, %r8
	jne	.L504
.L501:
	xorl	%r10d, %r10d
.L496:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L517:
	movq	%rdx, %rax
	movzbl	%sil, %edx
	addq	%rax, %rdx
	testl	%ecx, %ecx
	je	.L501
	.p2align 4,,10
	.p2align 3
.L500:
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L501
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L500
	jmp	.L501
	.size	put_number.isra.0, .-put_number.isra.0
	.p2align 4
	.type	hrdbf_write_number_scaled.part.0, @function
hrdbf_write_number_scaled.part.0:
	pushq	%r14
	movl	$4, %eax
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$112, %rsp
	movzbl	13(%rsi), %r13d
	cmpb	$17, %r13b
	ja	.L518
	movzbl	12(%rsi), %r12d
	movq	%rsi, %r10
	cmpl	$17, %ecx
	ja	.L544
	cmpb	%r12b, %r13b
	jnb	.L544
	movq	%rdi, %rbp
	movq	%rdx, %rsi
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jns	.L520
	negq	%rsi
	movl	$1, %r8d
.L520:
	movzbl	%r13b, %ebx
	cmpl	%ebx, %ecx
	jbe	.L521
	subl	%ebx, %ecx
	je	.L522
	xorl	%eax, %eax
	movl	$1, %edi
	.p2align 4,,10
	.p2align 3
.L523:
	leaq	(%rdi,%rdi,4), %rdi
	addl	$1, %eax
	addq	%rdi, %rdi
	cmpl	%eax, %ecx
	jne	.L523
	movq	%rsi, %rax
	xorl	%edx, %edx
	divq	%rdi
	shrq	%rdi
	movq	%rax, %rsi
	cmpq	%rdi, %rdx
	jb	.L524
.L522:
	addq	$1, %rsi
.L524:
	movabsq	$-3689348814741910323, %r9
	movq	%rsp, %rdi
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L529:
	movq	%rsi, %rax
	movl	%ecx, %r11d
	addq	$1, %rdi
	addl	$1, %ecx
	mulq	%r9
	movq	%rsi, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r14
	addq	%r14, %r14
	subq	%r14, %rax
	movq	%rsi, %r14
	movq	%rdx, %rsi
	addl	$48, %eax
	movb	%al, -1(%rdi)
	cmpq	$9, %r14
	ja	.L529
	movl	%ecx, %r9d
	movl	$1, %edx
	leal	1(%rbx), %esi
	movzbl	%r12b, %edi
	subl	%ebx, %r9d
	cmpl	%ecx, %ebx
	movzwl	14(%r10), %r14d
	cmovnb	%edx, %r9d
	xorl	%edx, %edx
	testb	%r13b, %r13b
	cmove	%edx, %esi
	leal	(%r9,%r8), %edx
	addl	%edx, %esi
	cmpl	%edi, %esi
	ja	.L572
	testl	%r8d, %r8d
	je	.L535
	movb	$45, 48(%rsp)
.L535:
	cmpl	%ecx, %ebx
	jb	.L573
	leal	1(%r8), %r9d
	movl	%r8d, %r8d
	movb	$48, 48(%rsp,%r8)
.L537:
	testb	%r13b, %r13b
	je	.L539
	cmpl	%ecx, %ebx
	movl	%r9d, %edx
	leal	1(%r9), %eax
	cmovbe	%ebx, %ecx
	movb	$46, 48(%rsp,%rdx)
	subl	%ecx, %ebx
	je	.L540
	leal	1(%rbx,%r9), %edi
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L541:
	movl	%edx, %esi
	addl	$1, %edx
	movb	$48, 48(%rsp,%rsi)
	cmpl	%edx, %edi
	jne	.L541
	addl	%ebx, %eax
.L540:
	leal	(%rcx,%rax), %r9d
	leal	-1(%rcx,%rax), %esi
	.p2align 4,,10
	.p2align 3
.L542:
	movl	%esi, %ecx
	movl	%eax, %edx
	subl	%eax, %ecx
	addl	$1, %eax
	movzbl	(%rsp,%rcx), %ecx
	movb	%cl, 48(%rsp,%rdx)
	cmpl	%eax, %r9d
	jne	.L542
.L539:
	movzbl	11(%r10), %esi
	leaq	48(%rsp), %r8
	movl	%r14d, %ecx
	movl	%r12d, %edx
	movq	%rbp, %rdi
	call	put_number.isra.0
.L518:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L544:
	addq	$112, %rsp
	movl	$4, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L521:
	jnb	.L524
	movl	%ebx, %edi
	subl	%ecx, %edi
	je	.L524
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rsi
	ja	.L525
	xorl	%eax, %eax
	jmp	.L526
	.p2align 4,,10
	.p2align 3
.L528:
	cmpq	%rdx, %rsi
	ja	.L525
.L526:
	leaq	(%rsi,%rsi,4), %rsi
	addl	$1, %eax
	addq	%rsi, %rsi
	cmpl	%eax, %edi
	jne	.L528
	jmp	.L524
	.p2align 4,,10
	.p2align 3
.L573:
	testl	%r9d, %r9d
	je	.L548
	movl	%edx, %r9d
	addl	%r8d, %r11d
	jmp	.L538
	.p2align 4,,10
	.p2align 3
.L574:
	movl	%r11d, %eax
	movl	%esi, %r8d
	subl	%esi, %eax
	movzbl	(%rsp,%rax), %eax
.L538:
	leal	1(%r8), %esi
	movl	%r8d, %r8d
	movb	%al, 48(%rsp,%r8)
	cmpl	%esi, %edx
	jne	.L574
	jmp	.L537
	.p2align 4,,10
	.p2align 3
.L572:
	xorl	%eax, %eax
	leaq	0(%rbp,%r14), %rdx
	.p2align 4,,10
	.p2align 3
.L533:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L533
	xorl	%eax, %eax
.L575:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L525:
	movzwl	14(%r10), %edx
	xorl	%eax, %eax
	addq	%rbp, %rdx
	.p2align 4,,10
	.p2align 3
.L527:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r12d
	ja	.L527
	xorl	%eax, %eax
	jmp	.L575
.L548:
	movl	%r8d, %r9d
	jmp	.L537
	.size	hrdbf_write_number_scaled.part.0, .-hrdbf_write_number_scaled.part.0
	.p2align 4
	.type	bn_shr_round, @function
bn_shr_round:
	movl	288(%rdi), %r9d
	movl	%esi, %r8d
	movl	%r9d, %esi
	sall	$5, %esi
	cmpl	%r8d, %esi
	jbe	.L621
	leal	-1(%r8), %edx
	xorl	%r10d, %r10d
	cmpl	%edx, %esi
	ja	.L622
.L583:
	cmpl	$1, %r8d
	je	.L584
	xorl	%ecx, %ecx
	jmp	.L587
	.p2align 4,,10
	.p2align 3
.L585:
	addl	$1, %ecx
	cmpl	%ecx, %edx
	je	.L584
.L587:
	cmpl	%ecx, %esi
	jbe	.L585
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L585
	testl	%r10d, %r10d
	movl	$3, %edx
	cmovne	%edx, %eax
.L598:
	cmpl	$31, %r8d
	jbe	.L592
	movl	%r8d, %r11d
	shrl	$5, %r11d
	cmpl	%r11d, %r9d
	jbe	.L594
	leal	-1(%r9), %ecx
	movq	%rdi, %rdx
	movl	%r11d, %esi
	subl	%r11d, %ecx
	leaq	4(%rdi,%rcx,4), %r10
	.p2align 4,,10
	.p2align 3
.L593:
	movl	(%rdx,%rsi,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%r10, %rdx
	jne	.L593
.L594:
	movl	%r9d, %edx
	subl	%r11d, %edx
	movl	%edx, 288(%rdi)
	cmpl	%edx, %r9d
	jbe	.L592
	movl	%edx, %ecx
	leal	-1(%r11), %esi
	leaq	(%rdi,%rcx,4), %rdx
	addq	%rsi, %rcx
	leaq	4(%rdi,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L595:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L595
.L592:
	andl	$31, %r8d
	jne	.L589
	ret
	.p2align 4,,10
	.p2align 3
.L622:
	movl	%edx, %eax
	movl	%edx, %ecx
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %r10d
	shrl	%cl, %r10d
	andl	$1, %r10d
	jmp	.L583
	.p2align 4,,10
	.p2align 3
.L621:
	xorl	%eax, %eax
	testl	%esi, %esi
	je	.L578
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L580:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r9d
	addl	$1, %ecx
	cmpl	%ecx, %esi
	jne	.L580
	testl	%eax, %eax
	je	.L578
	xorl	%r10d, %r10d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L581:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %r10d
	cmpl	%ecx, %esi
	jne	.L581
	subl	$1, %r8d
	cmpl	%r9d, %r8d
	ja	.L578
	sete	%al
	xorl	%edx, %edx
	cmpl	$1, %r10d
	sete	%dl
	andl	%eax, %edx
	movl	$3, %eax
	subl	%edx, %eax
.L578:
	movl	$1, 288(%rdi)
	movl	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.L584:
	leal	(%r10,%r10), %eax
	jmp	.L598
	.p2align 4,,10
	.p2align 3
.L589:
	movl	288(%rdi), %ecx
	pushq	%rbx
	leal	-1(%rcx), %ebx
	cmpl	$1, %ecx
	jbe	.L596
	movl	$32, %r10d
	subl	$2, %ecx
	movq	%rdi, %rdx
	subl	%r8d, %r10d
	leaq	4(%rdi,%rcx,4), %r11
	.p2align 4,,10
	.p2align 3
.L597:
	movl	(%rdx), %esi
	movl	4(%rdx), %r9d
	movl	%r8d, %ecx
	addq	$4, %rdx
	shrl	%cl, %esi
	movl	%r10d, %ecx
	sall	%cl, %r9d
	orl	%r9d, %esi
	movl	%esi, -4(%rdx)
	cmpq	%rdx, %r11
	jne	.L597
	movl	%ebx, %esi
	movl	%r8d, %ecx
	movl	(%rdi,%rsi,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%rdi,%rsi,4)
	testl	%edx, %edx
	je	.L623
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L623:
	movl	%ebx, 288(%rdi)
	popq	%rbx
	ret
.L596:
	movl	%r8d, %ecx
	shrl	%cl, (%rdi,%rbx,4)
	popq	%rbx
	ret
	.size	bn_shr_round, .-bn_shr_round
	.p2align 4
	.type	fdec, @function
fdec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabsq	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.L625:
	movq	%rsi, %rax
	movq	%rsi, %rcx
	mulq	%r9
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movl	%r8d, %eax
	addl	$1, %r8d
	addl	$48, %ecx
	movb	%cl, 16(%rsp,%rax)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	cmpq	$9, %rax
	jbe	.L635
	cmpl	$19, %r8d
	jbe	.L625
.L635:
	leaq	32977(%rdi), %r10
	leaq	33136(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L633:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L627
	.p2align 4,,10
	.p2align 3
.L629:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L628
.L627:
	cmpb	$0, (%rax)
	jne	.L629
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L630
	jmp	.L628
	.p2align 4,,10
	.p2align 3
.L631:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L628
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L630:
	testb	%cl, %cl
	jne	.L631
.L628:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L624
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L633
.L624:
	addq	$56, %rsp
	ret
	.size	fdec, .-fdec
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	" (errno "
	.text
	.p2align 4
	.type	ferr, @function
ferr:
	leaq	32977(%rdi), %r11
	pushq	%rbx
	leaq	33136(%rdi), %rbx
	movq	%r11, %rax
	jmp	.L643
	.p2align 4,,10
	.p2align 3
.L645:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.L644
.L643:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.L645
.L644:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.L647
	.p2align 4,,10
	.p2align 3
.L649:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.L648
.L647:
	cmpb	$0, (%rax)
	jne	.L649
	cmpq	%rax, %rbx
	jbe	.L648
	movl	$32, %esi
	movl	$.LC1, %ecx
	.p2align 4,,10
	.p2align 3
.L650:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L648
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.L650
.L648:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call	fdec
	jmp	.L651
	.p2align 4,,10
	.p2align 3
.L653:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.L652
.L651:
	cmpb	$0, (%r11)
	jne	.L653
	cmpq	%r11, %rbx
	jbe	.L652
	movb	$41, (%r11)
	addq	$1, %r11
.L652:
	movb	$0, (%r11)
	popq	%rbx
	ret
	.size	ferr, .-ferr
	.p2align 4
	.type	hrdbf_fmt_harbour.part.0, @function
hrdbf_fmt_harbour.part.0:
	pushq	%r15
	movq	%xmm0, %r9
	pushq	%r14
	shrq	$52, %r9
	pushq	%r13
	andl	$2047, %r9d
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$2312, %rsp
	movl	%esi, 36(%rsp)
	movl	%edx, 16(%rsp)
	movq	%xmm0, 40(%rsp)
	cmpq	$2047, %r9
	je	.L666
	movabsq	$4503599627370495, %rax
	andq	40(%rsp), %rax
	movq	%rdi, %rbx
	movq	%rax, 8(%rsp)
	testq	%r9, %r9
	je	.L900
	btsq	$52, 8(%rsp)
	movq	8(%rsp), %rax
	movl	$2, %edi
	leal	-1075(%r9), %r15d
	subl	$735, %r9d
	movl	%eax, %ecx
	movl	%r9d, %r10d
	shrq	$32, %rax
.L664:
	movl	%ecx, 48(%rsp)
	movl	$340, %esi
	xorl	%r8d, %r8d
	movl	%eax, 52(%rsp)
	movl	%edi, 336(%rsp)
	.p2align 4,,10
	.p2align 3
.L669:
	leal	-1(%rdi), %eax
	leaq	48(%rsp), %rdx
	leaq	52(%rsp,%rax,4), %r11
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L670:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%r11, %rdx
	jne	.L670
	testq	%rax, %rax
	je	.L671
	movl	%edi, %edx
	movl	$1, %r8d
	addl	$1, %edi
	movl	%eax, 48(%rsp,%rdx,4)
.L671:
	subl	$1, %esi
	jne	.L669
	testb	%r8b, %r8b
	je	.L673
	movl	%edi, 336(%rsp)
.L673:
	movl	%r10d, %esi
	testl	%r9d, %r9d
	js	.L674
	leaq	48(%rsp), %rdi
	call	bn_shl
	movl	336(%rsp), %eax
.L675:
	xorl	%ebp, %ebp
	jmp	.L679
	.p2align 4,,10
	.p2align 3
.L680:
	cmpq	$80, %rbp
	je	.L901
	leaq	48(%rsp), %rdi
	call	bn_divmod_1e9
	movl	%eax, 1264(%rsp,%rbp,4)
	movl	336(%rsp), %eax
	addq	$1, %rbp
.L679:
	movl	%ebp, %r8d
	cmpl	$1, %eax
	jne	.L680
	movl	48(%rsp), %r9d
	testl	%r9d, %r9d
	jne	.L680
	testl	%ebp, %ebp
	jne	.L902
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L665
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jnb	.L903
.L666:
	xorl	%eax, %eax
.L658:
	addq	$2312, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L900:
	testq	%rax, %rax
	jne	.L904
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L665
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jb	.L666
	movl	$11824, %ecx
	leaq	2(%rdi), %rdx
	movw	%cx, (%rdi)
	movl	16(%rsp), %edi
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L668:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L668
	jmp	.L658
.L665:
	movl	36(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L666
	movb	$48, (%rbx)
	movl	$1, %eax
	jmp	.L658
.L904:
	movq	8(%rsp), %rdx
	movl	$-734, %r10d
	movl	$-734, %r9d
	movl	$-1074, %r15d
	movl	%edx, %ecx
	shrq	$32, %rdx
	cmpq	$1, %rdx
	movl	%edx, %eax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rdx, %rdx
	movl	$0, %edx
	cmove	%edx, %eax
	jmp	.L664
.L674:
	negl	%esi
	leaq	48(%rsp), %rdi
	call	bn_shr_round
	movl	%eax, %r8d
	movl	336(%rsp), %eax
	cmpl	$1, %r8d
	jbe	.L675
	testl	%eax, %eax
	je	.L774
	leal	-1(%rax), %edx
	movq	%rdi, %rsi
	leaq	52(%rsp,%rdx,4), %rdi
	movl	$1, %edx
.L678:
	movl	(%rsi), %ecx
	addq	$4, %rsi
	addq	%rcx, %rdx
	movl	%edx, -4(%rsi)
	shrq	$32, %rdx
	cmpq	%rdi, %rsi
	jne	.L678
	testq	%rdx, %rdx
	je	.L675
	leal	1(%rax), %edx
.L677:
	movl	$1, 48(%rsp,%rax,4)
	movl	%edx, %eax
	movl	%edx, 336(%rsp)
	jmp	.L675
.L901:
	movl	$79, %r8d
.L683:
	movl	%r8d, %eax
	movl	$1, %ecx
	movl	$3435973837, %r9d
	movl	1264(%rsp,%rax,4), %esi
.L687:
	movl	%esi, %eax
	movl	%esi, %edx
	movl	%ecx, %r12d
	imulq	%r9, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %edi
	addl	%edi, %edi
	subl	%edi, %edx
	movl	%esi, %edi
	movl	%eax, %esi
	addl	$48, %edx
	movb	%dl, 959(%rsp,%rcx)
	addq	$1, %rcx
	cmpl	$9, %edi
	ja	.L687
	leaq	1584(%rsp), %r13
	leal	-1(%r12), %ecx
	leaq	1585(%rsp), %rax
	movq	%rcx, %r11
	leal	-1(%r12,%r13), %esi
	addq	%rax, %rcx
	movq	%r13, %rax
	jmp	.L689
.L905:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	960(%rsp,%rdx), %edx
.L689:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L905
	testl	%r8d, %r8d
	je	.L690
	leaq	1264(%rsp), %r14
	leal	-1(%r8), %eax
	movl	$3435973837, %r10d
	leaq	(%r14,%rax,4), %rbp
.L692:
	movl	%r11d, %edi
	movl	0(%rbp), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L691:
	movl	%edx, %eax
	movl	%ecx, %esi
	subl	$1, %ecx
	imulq	%r10, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %r9d
	addl	%r9d, %r9d
	subl	%r9d, %edx
	addl	$48, %edx
	movb	%dl, 1584(%rsp,%rsi)
	movl	%eax, %edx
	cmpl	%edi, %ecx
	jne	.L691
	leaq	-4(%rbp), %rax
	cmpq	%r14, %rbp
	je	.L906
	movq	%rax, %rbp
	jmp	.L692
.L906:
	leal	(%r8,%r8,8), %eax
	addl	%eax, %r12d
.L690:
	leal	-341(%r12), %eax
	xorl	%r8d, %r8d
	movl	$340, %edi
	movl	%eax, 20(%rsp)
	movq	8(%rsp), %rax
	leaq	(%rax,%rax), %r14
	leaq	1(%r14), %rax
	movq	%rax, 352(%rsp)
	shrq	$32, %rax
	setne	%r8b
	xorl	%r9d, %r9d
	addl	$1, %r8d
	movl	%r8d, 640(%rsp)
	.p2align 4,,10
	.p2align 3
.L694:
	leal	-1(%r8), %eax
	leaq	352(%rsp), %rcx
	leaq	356(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L695:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L695
	testq	%rax, %rax
	je	.L696
	movl	%r8d, %edx
	movl	$1, %r9d
	addl	$1, %r8d
	movl	%eax, 352(%rsp,%rdx,4)
.L696:
	subl	$1, %edi
	jne	.L694
	testb	%r9b, %r9b
	je	.L698
	movl	%r8d, 640(%rsp)
.L698:
	leal	339(%r15), %ebp
	leaq	352(%rsp), %rdi
	movl	%ebp, %esi
	call	bn_shl
	cmpl	$-1074, %r15d
	movabsq	$4503599627370496, %rax
	setne	%r9b
	cmpq	%rax, 8(%rsp)
	sete	%al
	andb	%al, %r9b
	je	.L699
	movl	$340, %r10d
	xorl	%ebp, %ebp
	movl	$2, %r11d
	movabsq	$18014398509481983, %rax
	movq	%rax, 656(%rsp)
	leaq	656(%rsp), %rdi
	leaq	660(%rsp), %r8
	movl	$2, 944(%rsp)
	.p2align 4,,10
	.p2align 3
.L700:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L701:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rsi, %rcx
	jne	.L701
	testq	%rax, %rax
	je	.L702
	movl	%r11d, %edx
	movl	%r9d, %ebp
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L702:
	subl	$1, %r10d
	jne	.L700
	testb	%bpl, %bpl
	je	.L704
	movl	%r11d, 944(%rsp)
.L704:
	leal	338(%r15), %esi
	call	bn_shl
.L705:
	leaq	960(%rsp), %r8
	cmpl	$1, %r12d
	je	.L742
	leal	1(%r12), %eax
	leaq	960(%rsp), %r8
	movq	%rbx, 24(%rsp)
	movl	$2, %r14d
	movl	%eax, 32(%rsp)
	leaq	1585(%rsp), %rbp
	movl	$1, %r15d
	movq	%r8, %rbx
.L738:
	movl	%r15d, 4(%rsp)
	movq	%r13, %rdx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.L712:
	movzbl	(%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpq	%rdx, %rbp
	jne	.L712
	cmpb	$53, 0(%rbp)
	ja	.L713
	je	.L907
.L714:
	movl	32(%rsp), %r10d
	movq	%r10, %rcx
	subq	%r14, %rcx
	cmpq	$9, %rsi
	ja	.L908
.L716:
	xorl	%edi, %edi
	movq	%rsi, 960(%rsp)
	shrq	$32, %rsi
	movl	%ecx, %r10d
	setne	%dil
	xorl	%r9d, %r9d
	xorl	%r11d, %r11d
	addl	$1, %edi
	movl	%edi, 1248(%rsp)
	testl	%ecx, %ecx
	je	.L720
	.p2align 4,,10
	.p2align 3
.L719:
	leal	-1(%rdi), %eax
	movq	%rbx, %rcx
	leaq	964(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L721:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L721
	testq	%rax, %rax
	je	.L722
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 960(%rsp,%rdx,4)
.L722:
	addl	$1, %r9d
	cmpl	%r10d, %r9d
	jne	.L719
	testb	%r11b, %r11b
	je	.L720
	movl	%edi, 1248(%rsp)
.L720:
	movl	%r10d, %esi
	movq	%rbx, %rdi
	call	bn_shl
	movl	1248(%rsp), %esi
	cmpl	944(%rsp), %esi
	je	.L725
	jnb	.L726
	cmpl	640(%rsp), %esi
	jne	.L727
	movl	$-1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L734
	.p2align 4,,10
	.p2align 3
.L737:
	movl	%eax, %edx
	subl	$1, %eax
	movl	352(%rsp,%rdx,4), %edi
	cmpl	%edi, 960(%rsp,%rdx,4)
	jne	.L909
.L734:
	cmpl	$-1, %eax
	jne	.L737
.L733:
	testb	$1, 8(%rsp)
	je	.L889
.L727:
	movl	%r14d, %eax
	addq	$1, %r15
	addq	$1, %r14
	addq	$1, %rbp
	cmpl	$17, %eax
	ja	.L890
	cmpl	%r12d, %eax
	jb	.L738
.L890:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
.L742:
	movl	$17, %eax
	cmpl	%eax, %r12d
	cmovbe	%r12d, %eax
	movl	%eax, 4(%rsp)
.L740:
	movl	4(%rsp), %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
.L743:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpl	%edx, %edi
	ja	.L743
	movl	4(%rsp), %eax
	cmpl	%r12d, %eax
	jnb	.L744
	cmpb	$53, 1584(%rsp,%rax)
	ja	.L745
	jne	.L744
	testb	$1, %sil
	jne	.L745
	movl	4(%rsp), %eax
	addl	$1, %eax
	cmpl	%r12d, %eax
	jb	.L746
	jmp	.L744
	.p2align 4,,10
	.p2align 3
.L910:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L744
.L746:
	cmpb	$48, 0(%r13,%rax)
	je	.L910
.L745:
	addq	$1, %rsi
.L744:
	movabsq	$-3689348814741910323, %r9
	xorl	%ecx, %ecx
.L747:
	movq	%rsi, %rax
	movl	%ecx, %edi
	addq	$1, %r8
	addl	$1, %ecx
	mulq	%r9
	movq	%rsi, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r10
	addq	%r10, %r10
	subq	%r10, %rax
	movq	%rsi, %r10
	movq	%rdx, %rsi
	addl	$48, %eax
	movb	%al, -1(%r8)
	cmpq	$9, %r10
	ja	.L747
	cmpl	4(%rsp), %ecx
	jbe	.L748
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 20(%rsp)
	testl	%edi, %edi
	je	.L752
	leal	-1(%rdi), %eax
	movl	%edi, %ecx
	movq	%rax, %rdx
	movzbl	960(%rsp,%rax), %eax
	movl	%edx, %edi
.L748:
	xorl	%edx, %edx
	jmp	.L750
.L911:
	movl	%edi, %eax
	subl	%edx, %eax
	movzbl	960(%rsp,%rax), %eax
.L750:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L911
	cmpl	$1, %ecx
	jbe	.L751
.L912:
	leal	-1(%rcx), %edx
	cmpb	$48, 1584(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L751
	movl	%eax, %ecx
.L752:
	cmpl	$1, %ecx
	ja	.L912
.L751:
	movl	20(%rsp), %eax
	movl	16(%rsp), %edi
	movq	40(%rsp), %r8
	leal	1(%rax), %r9d
	movq	%rdi, %rsi
	movslq	%r9d, %rax
	shrq	$63, %r8
	addq	%rdi, %rax
	movl	%r8d, %edx
	testq	%rax, %rax
	jle	.L913
	movl	%ecx, %esi
	cmpq	%rsi, %rax
	jge	.L757
	cmpb	$52, 1584(%rsp,%rax)
	movl	%eax, %ecx
	jbe	.L763
	leal	-1(%rax), %esi
	movq	%rsi, %rax
	addq	%r13, %rsi
	subl	%esi, %eax
	jmp	.L760
.L759:
	movb	$48, (%rsi)
	leaq	-1(%rsi), %r10
	cmpq	%rsi, %r13
	je	.L914
	movq	%r10, %rsi
.L760:
	movzbl	(%rsi), %r10d
	leal	(%rax,%rsi), %r11d
	cmpb	$57, %r10b
	je	.L759
	movl	%r11d, %eax
	addl	$1, %r10d
	movb	%r10b, 1584(%rsp,%rax)
	jmp	.L763
	.p2align 4,,10
	.p2align 3
.L725:
	leal	-1(%rsi), %eax
	movl	%eax, %edx
	jmp	.L730
	.p2align 4,,10
	.p2align 3
.L732:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	656(%rsp,%rcx,4), %edi
	cmpl	%edi, 960(%rsp,%rcx,4)
	jne	.L915
.L730:
	cmpl	$-1, %edx
	jne	.L732
	xorl	%ecx, %ecx
	cmpl	%esi, 640(%rsp)
	je	.L734
	jmp	.L733
.L907:
	testb	$1, %sil
	jne	.L713
	cmpl	%r14d, %r12d
	jbe	.L714
	movq	%r14, %rax
	jmp	.L715
.L916:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L714
.L715:
	cmpb	$48, 0(%r13,%rax)
	je	.L916
.L713:
	addq	$1, %rsi
	jmp	.L714
.L908:
	movq	%rsi, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L717:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rdi
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rdi
	ja	.L717
	cmpl	%r9d, 4(%rsp)
	jnb	.L716
	movabsq	$-3689348814741910323, %rax
	movq	%r10, %rcx
	mulq	%rsi
	subq	%r15, %rcx
	movq	%rdx, %rsi
	shrq	$3, %rsi
	jmp	.L716
.L915:
	jnb	.L731
	movl	$-1, %ecx
	cmpl	640(%rsp), %esi
	je	.L734
	jmp	.L727
.L909:
	jnb	.L736
	cmpl	$1, %ecx
	je	.L889
.L736:
	testl	%ecx, %ecx
	jne	.L727
	jmp	.L733
.L726:
	cmpl	640(%rsp), %esi
	jne	.L898
	movl	$1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L734
.L898:
	jnb	.L727
.L889:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
	jmp	.L740
.L731:
	cmpl	640(%rsp), %esi
	jne	.L898
	movl	$1, %ecx
	jmp	.L734
.L917:
	leal	-1(%rcx), %esi
	cmpb	$48, 1584(%rsp,%rsi)
	movq	%rsi, %rax
	jne	.L897
	movl	%eax, %ecx
.L763:
	cmpl	$1, %ecx
	jne	.L917
.L762:
	xorl	%eax, %eax
	movl	$0, %esi
	cmpb	$48, 1584(%rsp)
	movl	$1, %ecx
	cmovne	%r8, %rax
	cmove	%esi, %edx
	jmp	.L755
	.p2align 4,,10
	.p2align 3
.L699:
	subq	$1, %r14
	xorl	%r11d, %r11d
	movl	$340, %r10d
	movq	%r14, 656(%rsp)
	shrq	$32, %r14
	leaq	656(%rsp), %rdi
	leaq	660(%rsp), %r8
	setne	%r11b
	addl	$1, %r11d
	movl	%r11d, 944(%rsp)
	.p2align 4,,10
	.p2align 3
.L707:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L708:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L708
	testq	%rax, %rax
	je	.L709
	movl	%r11d, %edx
	movl	$1, %r9d
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L709:
	subl	$1, %r10d
	jne	.L707
	testb	%r9b, %r9b
	je	.L711
	movl	%r11d, 944(%rsp)
.L711:
	movl	%ebp, %esi
	call	bn_shl
	jmp	.L705
.L757:
	cmpl	$1, %ecx
	je	.L762
.L897:
	movq	%r8, %rax
.L755:
	movl	20(%rsp), %r14d
	movl	$1, %r8d
	leal	1(%r14), %esi
	testl	%r14d, %r14d
	movslq	%esi, %rsi
	cmovs	%r8, %rsi
.L764:
	movl	16(%rsp), %r8d
	leaq	1(%rdi,%rsi), %rdi
	testl	%r8d, %r8d
	cmovne	%rdi, %rsi
	movl	$400, %edi
	addq	%rsi, %rax
	movl	36(%rsp), %esi
	cmpq	%rdi, %rsi
	cmovg	%rdi, %rsi
	cmpq	%rsi, %rax
	jg	.L666
	testl	%edx, %edx
	jne	.L918
	movq	%rbx, %rsi
	movl	$1, %eax
.L766:
	movl	20(%rsp), %edi
	testl	%edi, %edi
	js	.L767
	leal	1(%rdi), %eax
	xorl	%esi, %esi
	movslq	%eax, %r9
.L769:
	leal	(%rdx,%rsi), %edi
	movl	$48, %r8d
	cmpl	%ecx, %esi
	jnb	.L768
	movzbl	0(%r13,%rsi), %r8d
.L768:
	addq	$1, %rsi
	movb	%r8b, (%rbx,%rdi)
	cmpq	%rsi, %r9
	jne	.L769
	addl	%edx, %eax
.L770:
	movl	16(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L658
	movl	20(%rsp), %r14d
	movl	%eax, %edx
	leal	1(%rax), %edi
	leal	1(%rax,%r10), %r10d
	movb	$46, (%rbx,%rdx)
	movl	%edi, %edx
	leal	1(%r14), %esi
	subl	%eax, %r14d
	movslq	%esi, %rsi
	movl	%r14d, %r9d
	jmp	.L772
.L792:
	movl	%eax, %edx
.L772:
	movl	$48, %r8d
	testq	%rsi, %rsi
	js	.L771
	leal	(%r9,%rdx), %eax
	cmpl	%ecx, %eax
	jnb	.L771
	movzbl	0(%r13,%rsi), %r8d
.L771:
	leal	1(%rdx), %eax
	movb	%r8b, (%rbx,%rdx)
	addq	$1, %rsi
	cmpl	%r10d, %eax
	jne	.L792
	movl	16(%rsp), %eax
	addl	%edi, %eax
	jmp	.L658
.L913:
	jne	.L754
	cmpb	$52, 1584(%rsp)
	jbe	.L754
	negl	%esi
	movb	$49, 1584(%rsp)
	movq	%r8, %rax
	movl	$1, %ecx
	movl	%esi, 20(%rsp)
	jmp	.L755
.L754:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %esi
	movl	$1, %ecx
	movb	$48, 1584(%rsp)
	movl	$0, 20(%rsp)
	jmp	.L764
.L918:
	movb	$45, (%rbx)
	leaq	1(%rbx), %rsi
	movl	$2, %eax
	jmp	.L766
.L902:
	subl	$1, %r8d
	jmp	.L683
.L903:
	movl	16(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rbx)
	leaq	2(%rbx), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L686:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L686
	jmp	.L658
.L767:
	movb	$48, (%rsi)
	jmp	.L770
.L774:
	movl	$1, %edx
	jmp	.L677
.L914:
	movb	$49, 1584(%rsp)
	movl	%r9d, 20(%rsp)
	jmp	.L763
	.size	hrdbf_fmt_harbour.part.0, .-hrdbf_fmt_harbour.part.0
	.p2align 4
	.type	hrdbf_write_number_double.part.0, @function
hrdbf_write_number_double.part.0:
	movzbl	13(%rsi), %edx
	movl	$4, %eax
	cmpb	$17, %dl
	ja	.L926
	pushq	%rbp
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$408, %rsp
	cmpb	12(%rsi), %dl
	jnb	.L919
	movq	%rdi, %rbp
	movl	$400, %esi
	movq	%rsp, %rdi
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %r9d
	movl	$5, %eax
	testl	%r9d, %r9d
	je	.L919
	movzwl	14(%rbx), %ecx
	movzbl	12(%rbx), %edx
	movq	%rsp, %r8
	movq	%rbp, %rdi
	movzbl	11(%rbx), %esi
	call	put_number.isra.0
.L919:
	addq	$408, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L926:
	ret
	.size	hrdbf_write_number_double.part.0, .-hrdbf_write_number_double.part.0
	.p2align 4
	.type	ddec, @function
ddec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabsq	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.L930:
	movq	%rsi, %rax
	movq	%rsi, %rcx
	mulq	%r9
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movl	%r8d, %eax
	addl	$1, %r8d
	addl	$48, %ecx
	movb	%cl, 16(%rsp,%rax)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	cmpq	$9, %rax
	jbe	.L940
	cmpl	$19, %r8d
	jbe	.L930
.L940:
	leaq	32778(%rdi), %r10
	leaq	32937(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L938:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L932
	.p2align 4,,10
	.p2align 3
.L934:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L933
.L932:
	cmpb	$0, (%rax)
	jne	.L934
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L935
	jmp	.L933
	.p2align 4,,10
	.p2align 3
.L936:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L933
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L935:
	testb	%cl, %cl
	jne	.L936
.L933:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L929
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L938
.L929:
	addq	$56, %rsp
	ret
	.size	ddec, .-ddec
	.p2align 4
	.type	dname, @function
dname:
	xorl	%r8d, %r8d
	movl	$63, %r9d
	leaq	32937(%rdi), %rdx
	.p2align 4,,10
	.p2align 3
.L948:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.L947
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	32778(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.L950
	.p2align 4,,10
	.p2align 3
.L952:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.L951
.L950:
	cmpb	$0, (%rax)
	jne	.L952
	cmpq	%rdx, %rax
	jnb	.L951
	movb	%cl, (%rax)
	addq	$1, %rax
.L951:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.L948
.L947:
	ret
	.size	dname, .-dname
	.p2align 4
	.type	hrntx_file_open.part.0.constprop.0, @function
hrntx_file_open.part.0.constprop.0:
	pushq	%r15
	movq	%rdi, %r8
	xorl	%r10d, %r10d
	movl	$257, %r9d
	pushq	%r14
	movq	$-100, %rdi
	movl	$524288, %edx
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	movl	%esi, %ebp
	pushq	%rbx
	subq	$24, %rsp
	movl	%esi, hrdbf_app_order+68(%rip)
	.p2align 4,,10
	.p2align 3
.L957:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L957
	testq	%rax, %rax
	js	.L1012
	movl	$8, %r8d
	xorl	%esi, %esi
	movl	$2, %edx
	movq	%rbx, %rdi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	testq	%rax, %rax
	js	.L960
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.L1016
	cmpl	$1, %ebp
	movq	%r12, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.L965
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L966
	movq	%r12, hrdbf_app_order+48(%rip)
	xorl	%r9d, %r9d
	movq	%r13, %rdi
	movq	%r12, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.L967
	movq	$0, hrdbf_app_order+32(%rip)
.L968:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.L1009
	.p2align 4,,10
	.p2align 3
.L1016:
	movl	$3, %eax
	movq	%rsi, %rdx
.L1015:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	js	.L1010
.L963:
	movq	hrdbf_app_order+32(%rip), %r10
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.L985
	movl	$11, %r9d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r10, %rdi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L986
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L956
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1012
.L1011:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L956:
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L986:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1012
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1012
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1012:
	movl	$7, %r8d
	jmp	.L956
	.p2align 4,,10
	.p2align 3
.L960:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L963
.L966:
	movl	$3, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L963
.L972:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1010:
	movl	$7, %r8d
	jmp	.L963
	.p2align 4,,10
	.p2align 3
.L985:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L956
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1011
	jmp	.L1012
	.p2align 4,,10
	.p2align 3
.L965:
	movl	$3, %eax
	movq	%rsi, %rdx
	jmp	.L1015
	.p2align 4,,10
	.p2align 3
.L967:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L968
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.L969
	jmp	.L970
	.p2align 4,,10
	.p2align 3
.L1017:
	movq	hrdbf_app_order+32(%rip), %rsi
.L969:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%r9, %rax
	movq	%rbx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L971
	testq	%rax, %rax
	jle	.L972
	addq	%rax, %r8
.L971:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.L1017
.L970:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L973:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.L973
	testq	%rax, %rax
	jne	.L974
	cmpl	$1, %ebp
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.L976
	xorl	%edx, %edx
	leaq	7(%rsi), %r14
	movl	$34, %r10d
	xorl	%r9d, %r9d
	shrq	$3, %r14
	movq	$-1, %r8
	movq	%r12, %rdi
	divq	%rcx
	leaq	(%r15,%r14), %rsi
	movl	$3, %edx
	leaq	7(%rax), %r13
	movl	$9, %eax
	shrq	$3, %r13
	addq	%r13, %rsi
	movq	%rsi, hrdbf_app_order+56(%rip)
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.L977
	movq	$0, hrdbf_app_order+40(%rip)
.L978:
	movq	$0, hrdbf_app_order+56(%rip)
.L1009:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r8d
	testq	%rax, %rax
	jns	.L963
	jmp	.L1010
.L976:
	movl	$3, %eax
	movq	%r12, %rsi
	movq	%r12, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.L963
	jmp	.L1010
.L974:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L963
.L977:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.L978
	testl	%ebp, %ebp
	movl	$hrntx_open, %edx
	movl	$hrcdx_open, %r10d
	movq	%rax, %r8
	cmove	%rdx, %r10
	addq	%rax, %r15
	addq	%r14, %r13
	movq	hrdbf_app_order+48(%rip), %rdx
	pushq	%r13
	movq	hrdbf_app_order+32(%rip), %rsi
	movl	$hrdbf_app_order, %edi
	movl	$hrdbf_app_state, %ecx
	pushq	%r15
	movl	hrdbf_app_state+16(%rip), %r9d
	call	*%r10
	movq	%rbx, %rdi
	movq	%r12, %rsi
	movl	%eax, %r8d
	popq	%rax
	movl	$3, %eax
	popq	%rdx
	movq	%r12, %rdx
	testl	%r8d, %r8d
	je	.L982
	cmpl	$5, %r8d
	jne	.L1015
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r8d
	testq	%rax, %rax
	jns	.L963
	jmp	.L1010
	.p2align 4,,10
	.p2align 3
.L982:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L956
	jmp	.L1010
	.size	hrntx_file_open.part.0.constprop.0, .-hrntx_file_open.part.0.constprop.0
	.section	.rodata.str1.1
.LC2:
	.string	"0123456789ABCDEF"
	.text
	.p2align 4
	.type	dhex, @function
dhex:
	movl	%esi, %eax
	subq	$16, %rsp
	shrl	$4, %eax
	movb	$0, 15(%rsp)
	movzbl	.LC2(%rax), %ecx
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	movq	%rax, %rdx
	movb	%cl, 14(%rsp)
	jmp	.L1019
	.p2align 4,,10
	.p2align 3
.L1021:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.L1020
.L1019:
	cmpb	$0, (%rdx)
	jne	.L1021
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.L1022
	jmp	.L1020
	.p2align 4,,10
	.p2align 3
.L1024:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.L1020
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.L1022:
	testb	%cl, %cl
	jne	.L1024
.L1020:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.LC2(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.L1026
	.p2align 4,,10
	.p2align 3
.L1028:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.L1027
.L1026:
	cmpb	$0, (%rax)
	jne	.L1028
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.L1029
	jmp	.L1027
	.p2align 4,,10
	.p2align 3
.L1030:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.L1027
.L1029:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1030
.L1027:
	movb	$0, (%rax)
	addq	$16, %rsp
	ret
	.size	dhex, .-dhex
	.p2align 4
	.globl	hrdbf_close
	.type	hrdbf_close, @function
hrdbf_close:
	endbr64
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	ret
	.size	hrdbf_close, .-hrdbf_close
	.p2align 4
	.globl	hrdbf_top
	.type	hrdbf_top, @function
hrdbf_top:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.L1039
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.L1039:
	ret
	.size	hrdbf_top, .-hrdbf_top
	.p2align 4
	.globl	hrdbf_skip
	.type	hrdbf_skip, @function
hrdbf_skip:
	endbr64
	cmpb	$0, 40(%rdi)
	movq	%rdi, %rax
	movl	$6, %r8d
	je	.L1042
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.L1042
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.L1044
	movl	16(%rdi), %ecx
	movq	%rcx, %r8
	movq	%rcx, %rdi
	addq	$1, %rcx
	subq	%rdx, %r8
	addq	%rsi, %rdx
	addq	$1, %r8
	cmpq	%rsi, %r8
	cmovnb	%rdx, %rcx
	movq	%rcx, 24(%rax)
.L1046:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.L1056
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.L1042:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1044:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.L1047
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.L1042
	.p2align 4,,10
	.p2align 3
.L1056:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.L1042
	.p2align 4,,10
	.p2align 3
.L1047:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.L1046
	.size	hrdbf_skip, .-hrdbf_skip
	.p2align 4
	.globl	hrdbf_get
	.type	hrdbf_get, @function
hrdbf_get:
	endbr64
	movl	$85, %eax
	movb	$0, 28(%rdx)
	movl	$6, %r8d
	movw	%ax, (%rdx)
	movb	$0, 2(%rdx)
	movq	$0, 8(%rdx)
	movq	$0, 16(%rdx)
	movl	$0, 24(%rdx)
	cmpb	$0, 40(%rdi)
	je	.L1136
	testl	%esi, %esi
	je	.L1137
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.L1137
	leal	-1(%rsi), %edx
	salq	$4, %rdx
	addq	%rdi, %rdx
	movzbl	53(%rdx), %r8d
	movb	%r8b, (%rcx)
	movzbl	54(%rdx), %edi
	movb	%dil, 1(%rcx)
	movzbl	55(%rdx), %r9d
	movb	%r9b, 2(%rcx)
	movq	24(%rax), %rsi
	movl	16(%rax), %r10d
	cmpq	%r10, %rsi
	ja	.L1137
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.L1140
	cmpb	$78, %r8b
	je	.L1141
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.L1142
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.L1083
	cmpb	$89, %dl
	je	.L1083
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.L1137
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.L1136
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.L1136
	.p2align 4,,10
	.p2align 3
.L1137:
	xorl	%r8d, %r8d
.L1136:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1083:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1140:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1136
	.p2align 4,,10
	.p2align 3
.L1141:
	testl	%edi, %edi
	je	.L1137
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.L1062
	.p2align 4,,10
	.p2align 3
.L1063:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.L1137
.L1062:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.L1063
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.L1065
	.p2align 4,,10
	.p2align 3
.L1089:
	movl	%edx, %edi
.L1065:
	cmpl	%edi, %eax
	jnb	.L1064
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.L1089
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.L1109
	cmpb	$45, %r8b
	sete	%dl
.L1087:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.L1067:
	cmpl	%eax, %edi
	jbe	.L1094
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.L1086:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.L1071
	.p2align 4,,10
	.p2align 3
.L1143:
	testl	%ebx, %ebx
	jne	.L1110
	movl	$1, %ebx
.L1068:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.L1070
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.L1071:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.L1143
.L1110:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L1094
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.L1100
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.L1068
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.L1068
	.p2align 4,,10
	.p2align 3
.L1142:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.L1080:
	cmpb	$32, (%rax)
	jne	.L1102
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1080
	jmp	.L1137
.L1102:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L1079:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.L1103
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.L1079
	movl	%r9d, %esi
	movl	$5, %r8d
	imulq	$1374389535, %rsi, %rdx
	shrq	$37, %rdx
	movl	%edx, %eax
	imulq	$1374389535, %rax, %rax
	shrq	$37, %rax
	imull	$100, %eax, %edi
	movl	%edx, %eax
	imull	$100, %edx, %edx
	subl	%edi, %eax
	movl	%r9d, %edi
	subl	%edx, %edi
	leal	-1(%rax), %edx
	cmpl	$9999, %r9d
	jbe	.L1136
	cmpl	$11, %edx
	ja	.L1136
	testl	%edi, %edi
	je	.L1136
	movzbl	days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.L1144
.L1081:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.L1136
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1136
.L1070:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.L1057
	cmpl	%r13d, %r9d
	jb	.L1057
	leal	1(%r13), %eax
	jbe	.L1072
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.L1073
	jmp	.L1100
	.p2align 4,,10
	.p2align 3
.L1074:
	cmpq	%rsi, %r11
	ja	.L1100
.L1073:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.L1074
	testl	%r12d, %r12d
	jne	.L1085
.L1076:
	movq	%r11, %rax
.L1077:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.L1057:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1100:
	movl	$4, %r8d
	jmp	.L1057
.L1064:
	je	.L1059
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.L1067
	cmpb	$45, %dl
	sete	%dl
	jmp	.L1087
	.p2align 4,,10
	.p2align 3
.L1059:
	xorl	%r8d, %r8d
	jmp	.L1057
.L1094:
	movl	$5, %r8d
	jmp	.L1057
.L1109:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.L1086
.L1103:
	movl	$5, %r8d
	jmp	.L1136
.L1144:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.L1081
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L1082
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L1081
.L1082:
	addl	$1, %r10d
	jmp	.L1081
.L1072:
	testl	%r12d, %r12d
	je	.L1076
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.L1077
.L1085:
	movq	%r11, %rax
	negq	%rax
	jmp	.L1077
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.L1145
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.L1147
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.L1147:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.L1145:
	ret
	.size	hrdbf_deleted, .-hrdbf_deleted
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC3:
	.string	"' numeric content overflows int64"
	.align 8
.LC4:
	.string	"' content is not valid for its type"
	.align 8
.LC5:
	.string	"file has fewer than the 33 header bytes"
	.section	.rodata.str1.1
.LC6:
	.string	"version byte 0x"
	.section	.rodata.str1.8
	.align 8
.LC7:
	.string	" is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)"
	.section	.rodata.str1.1
.LC8:
	.string	"implausible header length "
.LC9:
	.string	" or record length "
.LC10:
	.string	" for file size "
.LC11:
	.string	"field descriptor "
	.section	.rodata.str1.8
	.align 8
.LC12:
	.string	" truncated before end of header"
	.align 8
.LC13:
	.string	"more than 2046 field descriptors"
	.section	.rodata.str1.1
.LC14:
	.string	" has an empty name"
.LC15:
	.string	"field '"
.LC16:
	.string	"' has zero width"
.LC17:
	.string	"C field '"
.LC18:
	.string	"' declares decimals"
.LC19:
	.string	"N field '"
.LC20:
	.string	"' width "
.LC21:
	.string	" / decimals "
.LC22:
	.string	" outside supported range"
.LC23:
	.string	"L field '"
	.section	.rodata.str1.8
	.align 8
.LC24:
	.string	"' width must be 1 with no decimals"
	.section	.rodata.str1.1
.LC25:
	.string	"D field '"
	.section	.rodata.str1.8
	.align 8
.LC26:
	.string	"' width must be 8 with no decimals"
	.section	.rodata.str1.1
.LC27:
	.string	"' has unsupported type '"
.LC28:
	.string	"' (only C/N/D/L, no memo)"
	.section	.rodata.str1.8
	.align 8
.LC29:
	.string	"field widths exceed the 65535 record limit"
	.align 8
.LC30:
	.string	"field descriptors not terminated by 0x0D"
	.section	.rodata.str1.1
.LC31:
	.string	"table declares no fields"
	.section	.rodata.str1.8
	.align 8
.LC32:
	.string	"field widths plus delete flag sum to "
	.section	.rodata.str1.1
.LC33:
	.string	" but header record length is "
	.section	.rodata.str1.8
	.align 8
.LC34:
	.string	"nonzero byte between field descriptors and header end"
	.section	.rodata.str1.1
.LC35:
	.string	"header record count "
.LC36:
	.string	" exceeds the "
.LC37:
	.string	" records physically present"
	.section	.rodata.str1.8
	.align 8
.LC38:
	.string	"unexpected trailing bytes after the last record (no 0x1A terminator)"
	.section	.rodata.str1.1
.LC39:
	.string	"record "
.LC40:
	.string	" has delete flag 0x"
.LC41:
	.string	" (expected space or '*')"
.LC42:
	.string	" field '"
	.section	.rodata.str1.8
	.align 8
.LC43:
	.string	" (logical byte must be T/F/Y/N/?/space)"
	.section	.rodata.str1.1
.LC44:
	.string	" inside a deleted record"
.LC45:
	.string	"duplicate field name '"
.LC46:
	.string	"'"
	.text
	.p2align 4
	.globl	hrdbf_open
	.type	hrdbf_open, @function
hrdbf_open:
	endbr64
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$104, %rsp
	movb	$0, 32778(%rdi)
	movb	$0, hrdbf_open_tmp+32778(%rip)
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	$0, hrdbf_open_tmp(%rip)
	movq	$0, hrdbf_open_tmp+8(%rip)
	movl	$0, hrdbf_open_tmp+16(%rip)
	movq	$0, hrdbf_open_tmp+24(%rip)
	movl	$16842752, hrdbf_open_tmp+36(%rip)
	movb	$0, hrdbf_open_tmp+40(%rip)
	cmpq	$32, %rdx
	jbe	.L1223
	cmpb	$3, (%rsi)
	movq	%rsi, %rbx
	jne	.L1224
	movzwl	8(%rsi), %r13d
	movq	%rdx, %r12
	movw	%r13w, hrdbf_open_tmp+32(%rip)
	movzwl	10(%rsi), %edi
	movw	%di, hrdbf_open_tmp+34(%rip)
	movl	4(%rsi), %eax
	movl	%edi, %r14d
	movl	%edi, 8(%rsp)
	movl	%eax, 24(%rsp)
	movl	%eax, hrdbf_open_tmp+16(%rip)
	cmpw	$32, %r13w
	jbe	.L1154
	movzwl	%r13w, %eax
	movq	%rax, (%rsp)
	testl	%edi, %edi
	je	.L1154
	cmpq	%rdx, %rax
	ja	.L1154
	movq	(%rsp), %rax
	movw	%r13w, 30(%rsp)
	movl	$1, %edi
	leaq	32(%rsi), %r9
	movq	%rsi, 32(%rsp)
	movl	%edi, %ebx
	subq	$32, %rax
	movq	%rdx, 40(%rsp)
	andq	$-32, %rax
	addq	$32, %rax
	movq	%rax, 16(%rsp)
	movl	$32, %eax
	movq	%rax, %r12
.L1178:
	cmpb	$13, (%r9)
	je	.L1225
	cmpq	16(%rsp), %r12
	je	.L1226
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	cmpw	$2046, %ax
	je	.L1227
	leal	1(%rax), %ecx
	movzwl	%ax, %r8d
	movzwl	%ax, %r15d
	xorl	%eax, %eax
	movw	%cx, hrdbf_open_tmp+36(%rip)
	salq	$4, %r8
	.p2align 4,,10
	.p2align 3
.L1162:
	movzbl	(%r9,%rax), %edx
	movb	%dl, hrdbf_open_tmp+42(%r8,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1162
	movq	%r15, %rax
	salq	$4, %rax
	movzbl	hrdbf_open_tmp+42(%rax), %r11d
	testb	%r11b, %r11b
	je	.L1163
	movzwl	%cx, %eax
	cmpw	$1, %cx
	jbe	.L1164
	leal	-1(%rax), %r10d
	leaq	hrdbf_open_tmp+43(%r8), %r13
	xorl	%esi, %esi
	salq	$4, %r10
	leaq	hrdbf_open_tmp+53(%r8), %rdi
	.p2align 4,,10
	.p2align 3
.L1165:
	movq	%r13, %rax
	movl	%r11d, %edx
	jmp	.L1168
	.p2align 4,,10
	.p2align 3
.L1229:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1168:
	movq	%rax, %rcx
	subq	%r8, %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.L1228
	cmpq	%rdi, %rax
	jne	.L1229
	movq	%rbp, %rdi
	movl	$.LC45, %esi
	call	dset
	movq	%rbp, %rdi
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	call	dname
	movl	$.LC46, %esi
	call	dcat
	addq	$104, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L1154:
	movl	$.LC8, %esi
	movq	%rbp, %rdi
	call	dset
	movzwl	hrdbf_open_tmp+32(%rip), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC9, %esi
	movq	%rbp, %rdi
	call	dcat
	movzwl	hrdbf_open_tmp+34(%rip), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC10, %esi
	movq	%rbp, %rdi
	call	dcat
	movq	%r12, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$1, %eax
.L1150:
	addq	$104, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L1228:
	addq	$16, %rsi
	cmpq	%r10, %rsi
	jne	.L1165
.L1164:
	movq	%r15, %rax
	movzbl	11(%r9), %ecx
	salq	$4, %rax
	leaq	hrdbf_open_tmp+32(%rax), %rdx
	leaq	hrdbf_open_tmp+53(%rax), %r10
	movb	%cl, 21(%rdx)
	movzbl	16(%r9), %eax
	movb	%al, 22(%rdx)
	movzbl	17(%r9), %esi
	movw	%bx, 24(%rdx)
	movb	%sil, 23(%rdx)
	testb	%al, %al
	je	.L1230
	cmpb	$67, %cl
	je	.L1231
	cmpb	$78, %cl
	je	.L1232
	cmpb	$76, %cl
	je	.L1233
	cmpb	$68, %cl
	jne	.L1175
	cmpw	$8, 22(%rdx)
	je	.L1171
	movl	$.LC25, %esi
	movq	%rbp, %rdi
	call	dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call	dname
	movl	$.LC26, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
	.p2align 4,,10
	.p2align 3
.L1223:
	movl	$.LC5, %esi
	call	dset
	addq	$104, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1224:
	movl	$.LC6, %esi
	call	dset
	movzbl	(%rbx), %esi
	movq	%rbp, %rdi
	call	dhex
	movq	%rbp, %rdi
	movl	$.LC7, %esi
	call	dcat
	addq	$104, %rsp
	movl	$2, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1231:
	testb	%sil, %sil
	jne	.L1234
.L1171:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.L1235
	addq	$32, %r12
	addq	$32, %r9
	cmpq	%r12, (%rsp)
	ja	.L1178
	movl	$.LC30, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$1, %eax
	jmp	.L1150
.L1232:
	cmpb	$17, %sil
	ja	.L1197
	cmpb	%sil, %al
	ja	.L1171
.L1197:
	movl	$.LC19, %esi
	movq	%rbp, %rdi
	call	dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call	dname
	movl	$.LC20, %esi
	call	dcat
	movq	%r15, %rax
	movq	%rbp, %rdi
	salq	$4, %rax
	movzbl	hrdbf_open_tmp+54(%rax), %esi
	leaq	hrdbf_open_tmp+32(%rax), %r11
	call	ddec
	movl	$.LC21, %esi
	movq	%rbp, %rdi
	call	dcat
	movzbl	23(%r11), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC22, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$4, %eax
	jmp	.L1150
	.p2align 4,,10
	.p2align 3
.L1233:
	cmpw	$1, 22(%rdx)
	je	.L1171
	movl	$.LC23, %esi
	movq	%rbp, %rdi
	call	dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call	dname
	movl	$.LC24, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
	.p2align 4,,10
	.p2align 3
.L1226:
	movl	$.LC11, %esi
	movq	%rbp, %rdi
	call	dset
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	movq	%rbp, %rdi
	leaq	1(%rax), %rsi
	call	ddec
	movl	$.LC12, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
.L1227:
	movl	$.LC13, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$4, %eax
	jmp	.L1150
.L1225:
	movzwl	hrdbf_open_tmp+36(%rip), %r11d
	movl	%ebx, %ecx
	movq	%r12, %rax
	movzwl	30(%rsp), %r13d
	movq	32(%rsp), %rbx
	movq	40(%rsp), %r12
	testw	%r11w, %r11w
	je	.L1236
	addq	$1, %rax
	cmpl	%ecx, 8(%rsp)
	je	.L1180
	jmp	.L1237
	.p2align 4,,10
	.p2align 3
.L1181:
	addq	$1, %rax
	cmpb	$0, -1(%rbx,%rax)
	jne	.L1238
.L1180:
	cmpq	%rax, (%rsp)
	ja	.L1181
	movl	%ecx, %r10d
	movq	%r12, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%r10
	movl	24(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.L1239
	movq	%r8, %rax
	imulq	%r10, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r12
	je	.L1183
	movq	%r12, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1184
	cmpb	$26, (%rbx,%rax)
	je	.L1183
.L1184:
	movl	$.LC38, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$1, %eax
	jmp	.L1150
.L1163:
	movl	$.LC11, %esi
	movq	%rbp, %rdi
	call	dset
	movzwl	hrdbf_open_tmp+36(%rip), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC14, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
.L1230:
	movl	$.LC15, %esi
	movq	%rbp, %rdi
	call	dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call	dname
	movl	$.LC16, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
.L1238:
	movl	$.LC34, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$1, %eax
	jmp	.L1150
.L1235:
	movl	$.LC29, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$4, %eax
	jmp	.L1150
.L1234:
	movl	$.LC17, %esi
	movq	%rbp, %rdi
	call	dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call	dname
	movl	$.LC18, %esi
	call	dcat
	movl	$3, %eax
	jmp	.L1150
.L1237:
	movl	$.LC32, %esi
	movq	%rbp, %rdi
	call	dset
	movl	%ecx, %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC33, %esi
	movq	%rbp, %rdi
	call	dcat
	movzwl	hrdbf_open_tmp+34(%rip), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$1, %eax
	jmp	.L1150
.L1236:
	movl	$.LC31, %esi
	movq	%rbp, %rdi
	call	dset
	movl	$1, %eax
	jmp	.L1150
.L1175:
	movl	$.LC15, %esi
	movq	%rbp, %rdi
	call	dset
	movq	%rbp, %rdi
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	call	dname
	movl	$.LC27, %esi
	call	dcat
	movzbl	(%r10), %eax
	leaq	64(%rsp), %rsi
	movq	%rbp, %rdi
	movb	$0, 65(%rsp)
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	movb	%al, 64(%rsp)
	call	dcat
	movl	$.LC28, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$3, %eax
	jmp	.L1150
.L1183:
	movq	(%rsp), %rax
	cmpl	$0, 24(%rsp)
	movq	%rbx, hrdbf_open_tmp(%rip)
	sete	%r9b
	xorl	%r15d, %r15d
	movq	%r12, hrdbf_open_tmp+8(%rip)
	addq	%rbx, %rax
	movb	$1, hrdbf_open_tmp+40(%rip)
	movq	%rax, 8(%rsp)
	movzwl	%r11w, %eax
	movq	$1, hrdbf_open_tmp+24(%rip)
	movb	%r9b, hrdbf_open_tmp+39(%rip)
	movb	%r9b, hrdbf_open_tmp+38(%rip)
	movl	%eax, 16(%rsp)
	testq	%r8, %r8
	je	.L1193
	movw	%r14w, 30(%rsp)
	movl	%r13d, %r14d
	movl	%r11d, %r13d
	movq	%rbx, %r11
	movq	%r12, 32(%rsp)
	movq	%r10, %r12
	movq	%rbp, %r10
	movq	%r8, %rbp
.L1192:
	movq	8(%rsp), %rax
	addq	$1, %r15
	movzbl	(%rax), %eax
	movb	%al, (%rsp)
	cmpb	$32, %al
	je	.L1187
	cmpb	$42, %al
	jne	.L1240
.L1187:
	movq	%r15, hrdbf_open_tmp+24(%rip)
	movl	$1, %ebx
	jmp	.L1191
.L1188:
	addl	$1, %ebx
	cmpl	%ebx, 16(%rsp)
	jb	.L1241
.L1191:
	leaq	64(%rsp), %rdx
	movl	%ebx, %esi
	movl	$hrdbf_open_tmp, %edi
	movq	%r11, 56(%rsp)
	movq	%r10, 48(%rsp)
	movb	%r9b, 40(%rsp)
	call	hrdbf_get
	movzbl	40(%rsp), %r9d
	movq	48(%rsp), %r10
	testl	%eax, %eax
	movq	56(%rsp), %r11
	je	.L1188
	movq	%r10, %rdi
	movl	$.LC39, %esi
	movl	%eax, 24(%rsp)
	movq	%r10, %rbp
	movl	%ebx, 8(%rsp)
	call	dset
	movq	%r10, %rdi
	movq	%r15, %rsi
	call	ddec
	movl	$.LC42, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	8(%rsp), %ecx
	movq	%rbp, %rdi
	leal	1(%rcx), %esi
	leal	-1(%rcx), %r10d
	salq	$4, %rsi
	addq	$hrdbf_open_tmp+10, %rsi
	call	dname
	movl	24(%rsp), %eax
	movl	$.LC4, %edx
	movl	$.LC3, %esi
	cmpl	$4, %eax
	cmovne	%rdx, %rsi
	call	dcat
	movl	%r10d, %edx
	movl	24(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, hrdbf_open_tmp+53(%rdx)
	je	.L1242
.L1190:
	cmpb	$42, (%rsp)
	jne	.L1150
	movl	$.LC44, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call	dcat
	movl	(%rsp), %eax
	jmp	.L1150
.L1241:
	addq	%r12, 8(%rsp)
	cmpq	%r15, %rbp
	jne	.L1192
	movq	%r11, %rbx
	movq	32(%rsp), %r12
	movl	%r13d, %r11d
	movl	%r14d, %r13d
	movzwl	30(%rsp), %r14d
	movq	%r10, %rbp
.L1193:
	movl	24(%rsp), %eax
	movw	%r13w, 32(%rbp)
	xorl	%ecx, %ecx
	movq	$1, hrdbf_open_tmp+24(%rip)
	movw	%r14w, 34(%rbp)
	movq	%rbx, 0(%rbp)
	movq	%r12, 8(%rbp)
	movq	$1, 24(%rbp)
	movb	%r9b, 38(%rbp)
	movb	%r9b, 39(%rbp)
	movw	%r11w, 36(%rbp)
	movzwl	hrdbf_open_tmp+36(%rip), %esi
	movl	%eax, 16(%rbp)
	movl	$53, %eax
.L1186:
	cmpl	%ecx, %esi
	jbe	.L1243
	leaq	-11(%rax), %rdx
.L1194:
	movzbl	hrdbf_open_tmp(%rdx), %edi
	movb	%dil, 0(%rbp,%rdx)
	addq	$1, %rdx
	cmpq	%rax, %rdx
	jne	.L1194
	movzbl	hrdbf_open_tmp(%rax), %edx
	addl	$1, %ecx
	movb	%dl, 0(%rbp,%rax)
	movzbl	hrdbf_open_tmp+1(%rax), %edx
	movb	%dl, 1(%rbp,%rax)
	movzbl	hrdbf_open_tmp+2(%rax), %edx
	movb	%dl, 2(%rbp,%rax)
	movzwl	hrdbf_open_tmp+3(%rax), %edx
	movw	%dx, 3(%rbp,%rax)
	addq	$16, %rax
	jmp	.L1186
.L1239:
	movl	$.LC35, %esi
	movq	%rbp, %rdi
	call	dset
	movl	hrdbf_open_tmp+16(%rip), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC36, %esi
	movq	%rbp, %rdi
	call	dcat
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	movq	%r12, %rax
	movq	%rbp, %rdi
	movzwl	hrdbf_open_tmp+34(%rip), %ecx
	subq	%rdx, %rax
	xorl	%edx, %edx
	divq	%rcx
	movq	%rax, %rsi
	call	ddec
	movl	$.LC37, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1150
.L1243:
	movb	$1, 40(%rbp)
	xorl	%eax, %eax
	jmp	.L1150
.L1240:
	movq	%r10, %rdi
	movl	$.LC39, %esi
	movq	%r10, %rbp
	call	dset
	movq	%r15, %rsi
	movq	%r10, %rdi
	call	ddec
	movl	$.LC40, %esi
	movq	%rbp, %rdi
	call	dcat
	movzbl	(%rsp), %esi
	movq	%rbp, %rdi
	call	dhex
	movl	$.LC41, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$5, %eax
	jmp	.L1150
.L1242:
	movl	$.LC43, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	24(%rsp), %eax
	jmp	.L1190
	.size	hrdbf_open, .-hrdbf_open
	.p2align 4
	.globl	hrv_date
	.type	hrv_date, @function
hrv_date:
	endbr64
	movl	%edi, %edx
	movl	$11, %eax
	ret
	.size	hrv_date, .-hrv_date
	.p2align 4
	.globl	hrv_number
	.type	hrv_number, @function
hrv_number:
	endbr64
	movl	%edx, %edx
	movl	%esi, %esi
	salq	$8, %rdx
	salq	$16, %rsi
	orq	%rsi, %rdx
	movq	%rdx, %rax
	movq	%rdi, %rdx
	orq	$12, %rax
	ret
	.size	hrv_number, .-hrv_number
	.p2align 4
	.globl	hrv_validate
	.type	hrv_validate, @function
hrv_validate:
	endbr64
	movzbl	%dil, %edx
	movl	$4, %eax
	cmpl	$12, %edx
	ja	.L1246
	je	.L1266
	cmpl	$5, %edx
	je	.L1249
	shrq	$8, %rdi
	jne	.L1267
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.L1246
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.L1246
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.L1246
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.L1246
	movabsq	$2951479051793528259, %r8
	movq	%rsi, %rax
	shrq	$2, %rax
	mulq	%r8
	movq	%rdx, %rdi
	shrq	$4, %rdx
	movq	%rdx, %rax
	shrq	$2, %rdi
	mulq	%r8
	movq	%rdx, %rax
	andq	$-4, %rdx
	shrq	$2, %rax
	addq	%rdx, %rax
	movq	%rdi, %rdx
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rdx
	leaq	(%rdi,%rdi,4), %rax
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rsi
	leal	-1(%rdx), %eax
	cmpl	$11, %eax
	ja	.L1262
	testq	%rsi, %rsi
	je	.L1262
	movl	days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1268
.L1251:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1266:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.L1246
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.L1269
.L1246:
	ret
	.p2align 4,,10
	.p2align 3
.L1249:
	movabsq	$-9223372036854775803, %rax
	movq	%rdi, %rdx
	shrq	$63, %rdx
	cmpq	%rax, %rdi
	setne	%al
	andl	%edx, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1269:
	testb	$-1, %dh
	jne	.L1246
	movl	%edi, %eax
	movzbl	%ah, %edi
	cmpl	$17, %edi
	seta	%al
	cmpl	%edi, %edx
	setbe	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1267:
	ret
	.p2align 4,,10
	.p2align 3
.L1262:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1268:
	testb	$3, %cl
	jne	.L1251
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1252
	addl	$1, %eax
	jmp	.L1251
.L1252:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.L1251
	.size	hrv_validate, .-hrv_validate
	.p2align 4
	.globl	hrv_valtype
	.type	hrv_valtype, @function
hrv_valtype:
	endbr64
	movzbl	%dil, %edx
	movl	$63, %eax
	cmpb	$12, %dil
	ja	.L1270
	movzbl	CSWTCH.459(%rdx), %eax
.L1270:
	ret
	.size	hrv_valtype, .-hrv_valtype
	.p2align 4
	.globl	hrv_i64
	.type	hrv_i64, @function
hrv_i64:
	endbr64
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1273
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.L1283
	testl	%edx, %edx
	je	.L1276
	cmpl	$9, %edx
	je	.L1276
	movl	$1, %eax
.L1273:
	ret
	.p2align 4,,10
	.p2align 3
.L1283:
	testl	$65280, %r9d
	jne	.L1284
.L1276:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1284:
	movl	$2, %eax
	ret
	.size	hrv_i64, .-hrv_i64
	.p2align 4
	.globl	hrv_equal
	.type	hrv_equal, @function
hrv_equal:
	endbr64
	pushq	%r13
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	pushq	%r12
	pushq	%rbp
	movq	%rcx, %rbp
	pushq	%rbx
	movq	%r8, %rbx
	subq	$40, %rsp
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1285
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1285
	movzbl	%r9b, %r13d
	movzbl	%r11b, %r12d
	cmpb	$11, %r9b
	jne	.L1287
	cmpl	$11, %r12d
	jne	.L1287
.L1298:
	xorl	%edx, %edx
	cmpq	%rbp, %r10
	sete	%dl
	movl	%edx, (%rbx)
.L1285:
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1287:
	cmpl	$1, %r13d
	je	.L1301
	cmpl	$1, %r12d
	je	.L1301
	cmpl	$3, %r13d
	jne	.L1290
	cmpl	$3, %r12d
	jne	.L1290
	testq	%r10, %r10
	sete	%dl
	testq	%rbp, %rbp
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1285
	.p2align 4,,10
	.p2align 3
.L1301:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1285
	.p2align 4,,10
	.p2align 3
.L1290:
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1294
	cmpl	$12, %r13d
	je	.L1324
	testl	%r13d, %r13d
	je	.L1293
	cmpl	$9, %r13d
	jne	.L1294
.L1293:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1294
	cmpl	$12, %r12d
	je	.L1325
	testl	%r12d, %r12d
	je	.L1298
	cmpl	$9, %r12d
	je	.L1298
	.p2align 4,,10
	.p2align 3
.L1294:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1326
.L1300:
	movl	$1, %eax
	jmp	.L1285
	.p2align 4,,10
	.p2align 3
.L1324:
	testl	$65280, %r9d
	je	.L1293
	jmp	.L1294
	.p2align 4,,10
	.p2align 3
.L1326:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1300
	xorl	%edx, %edx
	movsd	16(%rsp), %xmm0
	ucomisd	24(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1285
	.p2align 4,,10
	.p2align 3
.L1325:
	testl	$65280, %r11d
	je	.L1298
	jmp	.L1294
	.size	hrv_equal, .-hrv_equal
	.p2align 4
	.globl	hrv_compare
	.type	hrv_compare, @function
hrv_compare:
	endbr64
	pushq	%r12
	movq	%rdi, %r9
	movq	%rsi, %r12
	movq	%rdx, %r10
	pushq	%rbp
	movq	%r8, %r11
	movq	%rcx, %rbp
	subq	$40, %rsp
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1327
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	je	.L1348
.L1327:
	addq	$40, %rsp
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1348:
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1329
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L1349
	testl	%eax, %eax
	je	.L1331
	cmpl	$9, %eax
	je	.L1331
	.p2align 4,,10
	.p2align 3
.L1329:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1350
.L1337:
	addq	$40, %rsp
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1350:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1337
	movsd	16(%rsp), %xmm1
	movsd	24(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1338
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1338:
	movq	%rdx, (%r11)
	jmp	.L1327
	.p2align 4,,10
	.p2align 3
.L1349:
	testl	$65280, %r9d
	jne	.L1329
.L1331:
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1329
	movzbl	%r10b, %edx
	cmpb	$12, %r10b
	je	.L1351
	testl	%edx, %edx
	je	.L1334
	cmpl	$9, %edx
	jne	.L1329
.L1334:
	xorl	%edx, %edx
	cmpq	%rbp, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%r11)
	jmp	.L1327
	.p2align 4,,10
	.p2align 3
.L1351:
	testl	$65280, %r10d
	je	.L1334
	jmp	.L1329
	.size	hrv_compare, .-hrv_compare
	.p2align 4
	.globl	hrv_empty
	.type	hrv_empty, @function
hrv_empty:
	endbr64
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1352
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.L1356
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.L1354
	cmpl	$1, %ecx
	je	.L1357
.L1356:
	movl	$1, %eax
.L1352:
	ret
	.p2align 4,,10
	.p2align 3
.L1354:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1357:
	movl	$1, (%r11)
	ret
	.size	hrv_empty, .-hrv_empty
	.p2align 4
	.globl	hrv_render
	.type	hrv_render, @function
hrv_render:
	endbr64
	pushq	%r14
	movq	%rdi, %r10
	movq	%rsi, %r11
	movq	%rdx, %r9
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	movq	%r8, %rbp
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$32, %rsp
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1358
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.L1405
	cmpl	$12, %eax
	jne	.L1384
	movl	%r10d, %r14d
	movl	%r10d, %eax
	negq	%rcx
	movl	$1, %esi
	shrl	$16, %r14d
	testq	%r11, %r11
	movzbl	%ah, %eax
	movabsq	$-3689348814741910323, %r13
	cmovns	%r11, %rcx
	movl	%eax, %r10d
	.p2align 4,,10
	.p2align 3
.L1366:
	movq	%rcx, %rax
	movq	%rcx, %rdi
	movl	%esi, %r12d
	mulq	%r13
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	addq	%rax, %rax
	subq	%rax, %rdi
	movq	%rcx, %rax
	movq	%rdx, %rcx
	addl	$48, %edi
	movb	%dil, -1(%rsp,%rsi)
	addq	$1, %rsi
	cmpq	$9, %rax
	ja	.L1366
	cmpl	%r12d, %r10d
	jb	.L1406
	movl	$1, %esi
.L1367:
	leal	1(%rsi,%r10), %eax
.L1368:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.L1369
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.L1407
	subl	%eax, %r14d
	je	.L1377
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1376:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1376
.L1377:
	testq	%r11, %r11
	jns	.L1375
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.L1375:
	testl	%esi, %esi
	je	.L1378
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.L1380
	.p2align 4,,10
	.p2align 3
.L1388:
	movl	%edx, %eax
.L1380:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1379
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1379:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.L1388
	addl	%esi, %r14d
.L1378:
	testl	%r10d, %r10d
	je	.L1358
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.L1382:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1381
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1381:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.L1382
.L1358:
	addq	$32, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1405:
	cmpq	$7, %rbx
	jbe	.L1369
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.L1362
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.L1364:
	movq	%rdx, %rax
	shrq	%cl, %rax
	andl	$1, %eax
	cmpq	$1, %rax
	sbbl	%eax, %eax
	andl	$-15, %eax
	addl	$47, %eax
	movb	%al, (%r9,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	jne	.L1364
	jmp	.L1358
	.p2align 4,,10
	.p2align 3
.L1384:
	addq	$32, %rsp
	movl	$1, %r8d
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1406:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.L1367
	movl	%esi, %eax
	jmp	.L1368
	.p2align 4,,10
	.p2align 3
.L1369:
	movl	$3, %r8d
	jmp	.L1358
	.p2align 4,,10
	.p2align 3
.L1362:
	movq	%r11, %rax
	movb	$47, 2(%r9)
	movabsq	$3777893186295716171, %rdx
	movabsq	$2951479051793528259, %rdi
	mulq	%rdx
	movq	%r11, %rax
	movb	$47, 5(%r9)
	shrq	$2, %rax
	movq	%rdx, %rcx
	mulq	%rdi
	shrq	$11, %rcx
	movq	%rdx, %rsi
	shrq	$4, %rdx
	movq	%rdx, %rax
	shrq	$2, %rsi
	mulq	%rdi
	movq	%rdx, %rax
	andq	$-4, %rdx
	shrq	$2, %rax
	addq	%rdx, %rax
	movq	%rsi, %rdx
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rdx
	leaq	(%rsi,%rsi,4), %rax
	movl	$3435973837, %esi
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %r11
	movl	%edx, %eax
	imulq	%rsi, %rax
	shrq	$35, %rax
	leal	48(%rax), %edi
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movb	%dil, (%r9)
	subl	%eax, %edx
	movl	%r11d, %eax
	imulq	%rsi, %rax
	addl	$48, %edx
	movb	%dl, 1(%r9)
	shrq	$35, %rax
	leal	48(%rax), %edx
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movb	%dl, 3(%r9)
	subl	%eax, %r11d
	movl	%ecx, %eax
	imulq	%rsi, %rax
	addl	$48, %r11d
	movb	%r11b, 4(%r9)
	shrq	$35, %rax
	movl	%eax, %edx
	imulq	%rsi, %rdx
	shrq	$35, %rdx
	leal	(%rdx,%rdx,4), %esi
	movl	%eax, %edx
	leal	(%rax,%rax,4), %eax
	addl	%esi, %esi
	addl	%eax, %eax
	subl	%esi, %edx
	addl	$48, %edx
	subl	%eax, %ecx
	addl	$48, %ecx
	movb	%dl, 6(%r9)
	movb	%cl, 7(%r9)
	jmp	.L1358
	.p2align 4,,10
	.p2align 3
.L1407:
	testl	%r14d, %r14d
	je	.L1358
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1372:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.L1372
	jmp	.L1358
	.size	hrv_render, .-hrv_render
	.p2align 4
	.globl	hrv_arith
	.type	hrv_arith, @function
hrv_arith:
	endbr64
	pushq	%r15
	movq	%rsi, %r11
	pushq	%r14
	pushq	%r13
	movq	%r8, %r13
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbp
	movq	%rdx, %rbp
	pushq	%rbx
	movl	%edi, %ebx
	movq	%rsi, %rdi
	movq	%rdx, %rsi
	subq	$56, %rsp
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	leal	-43(%rbx), %eax
	movq	%r9, %r14
	andl	$-3, %eax
	movl	%eax, %r15d
	je	.L1448
	cmpl	$42, %ebx
	je	.L1448
	cmpl	$47, %ebx
	je	.L1423
	cmpl	$37, %ebx
	je	.L1450
	movl	$1, %r10d
	cmpl	$94, %ebx
	je	.L1450
.L1408:
	addq	$56, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L1448:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1423
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1471
	testl	%eax, %eax
	je	.L1414
	cmpl	$9, %eax
	je	.L1414
	.p2align 4,,10
	.p2align 3
.L1423:
	leaq	16(%rsp), %rcx
	leaq	32(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	leaq	24(%rsp), %rcx
	leaq	40(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	movsd	40(%rsp), %xmm1
	cmpl	$43, %ebx
	je	.L1472
	testl	%r15d, %r15d
	je	.L1473
	cmpl	$42, %ebx
	je	.L1474
	ucomisd	.LC47(%rip), %xmm1
	jp	.L1449
	je	.L1443
.L1449:
	movsd	32(%rsp), %xmm0
	movl	$517, %eax
	divsd	%xmm1, %xmm0
.L1426:
	movq	%rax, (%r14)
	movsd	%xmm0, 8(%r14)
	jmp	.L1408
	.p2align 4,,10
	.p2align 3
.L1471:
	testl	$65280, %r11d
	jne	.L1423
.L1414:
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1423
	movzbl	%r12b, %eax
	cmpb	$12, %r12b
	je	.L1475
	testl	%eax, %eax
	je	.L1417
	cmpl	$9, %eax
	jne	.L1423
.L1417:
	movq	$0, (%r14)
	cmpl	$43, %ebx
	je	.L1476
	testl	%r15d, %r15d
	je	.L1477
	imulq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1408
	.p2align 4,,10
	.p2align 3
.L1450:
	movq	%rsp, %rcx
	leaq	8(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	leaq	4(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1408
	movsd	16(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1432
	ucomisd	.LC47(%rip), %xmm0
	jp	.L1433
	jne	.L1433
	movq	$0, (%r14)
	movq	$0, 8(%r14)
	jmp	.L1408
	.p2align 4,,10
	.p2align 3
.L1475:
	testl	$65280, %r12d
	je	.L1417
	jmp	.L1423
	.p2align 4,,10
	.p2align 3
.L1474:
	movl	$255, %edx
	movl	24(%rsp), %eax
	addl	16(%rsp), %eax
	cmpl	%edx, %eax
	movsd	32(%rsp), %xmm0
	cmova	%rdx, %rax
	mulsd	%xmm1, %xmm0
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1426
	.p2align 4,,10
	.p2align 3
.L1443:
	movl	$5, %r10d
	jmp	.L1408
	.p2align 4,,10
	.p2align 3
.L1472:
	addsd	32(%rsp), %xmm1
	movapd	%xmm1, %xmm0
.L1469:
	movl	24(%rsp), %eax
	movl	16(%rsp), %edx
	cmpl	%edx, %eax
	cmovb	%rdx, %rax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1426
	.p2align 4,,10
	.p2align 3
.L1473:
	movsd	32(%rsp), %xmm0
	subsd	%xmm1, %xmm0
	jmp	.L1469
	.p2align 4,,10
	.p2align 3
.L1476:
	addq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1408
.L1432:
	movsd	8(%rsp), %xmm1
	movq	%xmm0, %rcx
	movabsq	$9223372036854775807, %rax
	movq	%xmm1, %rsi
	movq	%xmm1, %rdx
	andq	%rax, %rsi
	andq	%rcx, %rax
	testq	%rdx, %rdx
	js	.L1478
	testq	%rsi, %rsi
	jne	.L1442
.L1437:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1435
	testq	%rcx, %rcx
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1435:
	movq	$517, (%r14)
	movq	%rdx, 8(%r14)
	jmp	.L1408
.L1477:
	subq	%r13, %rbp
	xorl	%r10d, %r10d
	movq	%rbp, 8(%r14)
	jmp	.L1408
.L1433:
	movsd	8(%rsp), %xmm1
	movsd	%xmm0, 32(%rsp)
	movsd	%xmm1, 24(%rsp)
#APP
# 101 "runtime/hrvalue.c" 1
	fldl 32(%rsp)
	fldl 24(%rsp)
	1: fprem
	fnstsw %ax
	test $4,%ah
	jnz 1b
	fstpl 40(%rsp)
	fstp %st(0)
# 0 "" 2
#NO_APP
	movq	40(%rsp), %rdx
	jmp	.L1435
.L1478:
	testq	%rsi, %rsi
	je	.L1437
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm2
	cmpq	%rdx, %rax
	ja	.L1438
	cvttsd2siq	%xmm2, %rdx
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rdx, %xmm1
	ucomisd	%xmm2, %xmm1
	jp	.L1445
	je	.L1438
.L1445:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1435
.L1442:
	movsd	%xmm1, 24(%rsp)
	movsd	%xmm0, 32(%rsp)
#APP
# 107 "runtime/hrvalue.c" 1
	fldl 32(%rsp)
	fldl 24(%rsp)
	fyl2x
	fld %st(0)
	frndint
	fxch %st(1)
	fsub %st(1),%st(0)
	f2xm1
	fld1
	faddp %st(0),%st(1)
	fscale
	fstp %st(1)
	fstpl 40(%rsp)
# 0 "" 2
#NO_APP
	movq	40(%rsp), %rdx
	jmp	.L1435
.L1438:
	movq	%rsi, 24(%rsp)
	movsd	%xmm0, 32(%rsp)
#APP
# 107 "runtime/hrvalue.c" 1
	fldl 32(%rsp)
	fldl 24(%rsp)
	fyl2x
	fld %st(0)
	frndint
	fxch %st(1)
	fsub %st(1),%st(0)
	f2xm1
	fld1
	faddp %st(0),%st(1)
	fscale
	fstp %st(1)
	fstpl 40(%rsp)
# 0 "" 2
#NO_APP
	movabsq	$4841369599423283199, %rdx
	movsd	40(%rsp), %xmm1
	cmpq	%rdx, %rax
	ja	.L1470
	cvttsd2siq	%xmm2, %rax
	testb	$1, %al
	je	.L1470
	pxor	%xmm0, %xmm0
	subsd	%xmm1, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1435
.L1470:
	movq	%xmm1, %rdx
	jmp	.L1435
	.size	hrv_arith, .-hrv_arith
	.section	.rodata.str1.1
.LC49:
	.string	"DBF unknown value error"
	.text
	.p2align 4
	.globl	hrv_error_name
	.type	hrv_error_name, @function
hrv_error_name:
	endbr64
	movl	$.LC49, %eax
	cmpl	$5, %edi
	ja	.L1479
	movl	%edi, %edi
	movq	CSWTCH.486(,%rdi,8), %rax
.L1479:
	ret
	.size	hrv_error_name, .-hrv_error_name
	.p2align 4
	.globl	hrdbf_fmt_fixed
	.type	hrdbf_fmt_fixed, @function
hrdbf_fmt_fixed:
	endbr64
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$888, %rsp
	movl	%esi, 4(%rsp)
	cmpl	$32, %edx
	ja	.L1485
	movl	%edx, %ebx
	movq	%xmm0, %rdx
	movq	%xmm0, %rax
	movq	%rdi, %rbp
	shrq	$52, %rdx
	movq	%xmm0, %rdi
	shrq	$63, %rdi
	andl	$2047, %edx
	movq	%rdi, 8(%rsp)
	cmpq	$2047, %rdx
	je	.L1485
	movabsq	$4503599627370495, %rcx
	andq	%rcx, %rax
	testq	%rdx, %rdx
	je	.L1580
	btsq	$52, %rax
	subl	$1075, %edx
	movl	$2, %edi
	movl	%eax, %ecx
	movslq	%edx, %r9
	shrq	$32, %rax
.L1489:
	movl	%ecx, 224(%rsp)
	leaq	224(%rsp), %r14
	movl	%eax, 228(%rsp)
	movl	%edi, 512(%rsp)
	testl	%ebx, %ebx
	je	.L1496
	xorl	%r10d, %r10d
	xorl	%r8d, %r8d
	leaq	224(%rsp), %r14
	.p2align 4,,10
	.p2align 3
.L1495:
	leal	-1(%rdi), %eax
	movq	%r14, %rdx
	leaq	228(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1497:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %rsi
	jne	.L1497
	testq	%rax, %rax
	je	.L1498
	movl	%edi, %edx
	movl	$1, %r10d
	addl	$1, %edi
	movl	%eax, 224(%rsp,%rdx,4)
.L1498:
	addl	$1, %r8d
	cmpl	%r8d, %ebx
	jne	.L1495
	testb	%r10b, %r10b
	je	.L1496
	movl	%edi, 512(%rsp)
.L1496:
	movl	%ebx, %esi
	addq	%r9, %rsi
	js	.L1501
	movq	%r14, %rdi
	call	bn_shl
	movl	512(%rsp), %r10d
.L1502:
	xorl	%r12d, %r12d
	jmp	.L1508
	.p2align 4,,10
	.p2align 3
.L1509:
	cmpq	$48, %r12
	je	.L1581
	movq	%r14, %rdi
	call	bn_divmod_1e9
	movl	512(%rsp), %r10d
	movl	%eax, 32(%rsp,%r12,4)
	addq	$1, %r12
.L1508:
	movl	%r12d, %r13d
	cmpl	$1, %r10d
	jne	.L1509
	movl	224(%rsp), %eax
	testl	%eax, %eax
	jne	.L1509
	testl	%r12d, %r12d
	jne	.L1582
	movl	$0, 32(%rsp)
	movl	$48, %edx
	movb	$48, 22(%rsp)
.L1514:
	leal	-1(%r10), %eax
	leaq	528(%rsp), %r14
	movq	%rax, %r11
	leaq	529(%rsp,%rax), %rcx
	leal	-1(%r10,%r14), %esi
	movq	%r14, %rax
	jmp	.L1517
	.p2align 4,,10
	.p2align 3
.L1583:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	22(%rsp,%rdx), %edx
.L1517:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1583
	testl	%r13d, %r13d
	je	.L1518
	leaq	32(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	.p2align 4,,10
	.p2align 3
.L1520:
	movl	%r11d, %edi
	movl	(%r12), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L1519:
	movl	%edx, %eax
	movl	%ecx, %esi
	subl	$1, %ecx
	imulq	%r9, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %r8d
	addl	%r8d, %r8d
	subl	%r8d, %edx
	addl	$48, %edx
	movb	%dl, 528(%rsp,%rsi)
	movl	%eax, %edx
	cmpl	%ecx, %edi
	jne	.L1519
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1584
	movq	%rax, %r12
	jmp	.L1520
	.p2align 4,,10
	.p2align 3
.L1485:
	xorl	%eax, %eax
.L1482:
	addq	$888, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L1580:
	testq	%rax, %rax
	jne	.L1585
	cmpq	$0, 8(%rsp)
	jne	.L1586
	xorl	%edx, %edx
.L1490:
	testl	%ebx, %ebx
	je	.L1491
	leal	2(%rdx,%rbx), %esi
	cmpl	4(%rsp), %esi
	ja	.L1485
	movl	%edx, %eax
	movb	$48, 0(%rbp,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, 0(%rbp,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1493:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 0(%rbp,%rcx)
	cmpl	%edx, %esi
	jne	.L1493
	addl	%ebx, %eax
	jmp	.L1482
.L1586:
	movl	4(%rsp), %edx
	testl	%edx, %edx
	je	.L1485
	movb	$45, 0(%rbp)
	movl	$1, %edx
	jmp	.L1490
.L1501:
	negl	%esi
	movq	%r14, %rdi
	call	bn_shr_round
	movl	512(%rsp), %r10d
	cmpl	$3, %eax
	je	.L1587
	cmpl	$2, %eax
	jne	.L1502
	movl	224(%rsp), %ecx
	movl	%ecx, %edx
	andl	$1, %edx
	je	.L1502
	testl	%r10d, %r10d
	je	.L1535
.L1505:
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.L1507
	.p2align 4,,10
	.p2align 3
.L1588:
	movl	(%r14,%rdx,4), %ecx
.L1507:
	addq	%rcx, %rax
	movl	%eax, (%r14,%rdx,4)
	addq	$1, %rdx
	shrq	$32, %rax
	cmpl	%edx, %r10d
	ja	.L1588
	testq	%rax, %rax
	je	.L1502
	movl	%r10d, %eax
	addl	$1, %r10d
.L1504:
	movl	%r10d, 512(%rsp)
	movl	$1, 224(%rsp,%rax,4)
	jmp	.L1502
	.p2align 4,,10
	.p2align 3
.L1584:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %r10d
.L1518:
	movl	%r10d, %eax
	movl	$1, %edx
	movq	8(%rsp), %rdi
	leal	1(%rbx), %ecx
	subl	%ebx, %eax
	cmpl	%r10d, %ebx
	cmovnb	%edx, %eax
	xorl	%edx, %edx
	testl	%ebx, %ebx
	cmove	%edx, %ecx
	leal	(%rax,%rdi), %edx
	addl	%ecx, %edx
	cmpl	4(%rsp), %edx
	ja	.L1485
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.L1523
	movb	$45, 0(%rbp)
	movl	$1, %edx
.L1523:
	cmpl	%r10d, %ebx
	jnb	.L1524
	testl	%eax, %eax
	je	.L1540
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1526:
	movzbl	(%r14), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1526
.L1525:
	testl	%ebx, %ebx
	je	.L1482
.L1527:
	cmpl	%r10d, %ebx
	movl	%r10d, %edi
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %edi
	movb	$46, 0(%rbp,%rcx)
	subl	%edi, %ebx
	je	.L1528
	leal	1(%rbx,%rax), %esi
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1529:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, 0(%rbp,%rcx)
	cmpl	%esi, %eax
	jne	.L1529
	addl	%ebx, %edx
.L1528:
	subl	%edi, %r10d
	leal	(%rdi,%rdx), %eax
	subl	%edx, %r10d
	.p2align 4,,10
	.p2align 3
.L1530:
	leal	(%r10,%rdx), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	528(%rsp,%rsi), %esi
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1530
	jmp	.L1482
.L1581:
	movl	220(%rsp), %ecx
	movl	$47, %r13d
.L1512:
	movl	$1, %esi
	movl	$3435973837, %r8d
	.p2align 4,,10
	.p2align 3
.L1515:
	movl	%ecx, %eax
	movl	%ecx, %edx
	movl	%esi, %r10d
	imulq	%r8, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %edi
	addl	%edi, %edi
	subl	%edi, %edx
	movl	%ecx, %edi
	movl	%eax, %ecx
	addl	$48, %edx
	movb	%dl, 21(%rsp,%rsi)
	addq	$1, %rsi
	cmpl	$9, %edi
	ja	.L1515
	jmp	.L1514
.L1585:
	movl	%eax, %ecx
	shrq	$32, %rax
	movl	$0, %edx
	movq	$-1074, %r9
	cmpq	$1, %rax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rax, %rax
	cmove	%edx, %eax
	jmp	.L1489
.L1491:
	leal	1(%rdx), %eax
	cmpl	4(%rsp), %eax
	ja	.L1485
	movb	$48, 0(%rbp,%rdx)
	jmp	.L1482
.L1524:
	movb	$48, 0(%rbp,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1527
.L1587:
	testl	%r10d, %r10d
	je	.L1534
	movl	224(%rsp), %ecx
	jmp	.L1505
.L1540:
	movl	%edx, %eax
	jmp	.L1525
.L1535:
	xorl	%eax, %eax
	movl	%edx, %r10d
	jmp	.L1504
.L1534:
	xorl	%eax, %eax
	movl	$1, %r10d
	jmp	.L1504
.L1582:
	leal	-1(%r12), %eax
	movl	32(%rsp,%rax,4), %ecx
	movq	%rax, %r13
	jmp	.L1512
	.size	hrdbf_fmt_fixed, .-hrdbf_fmt_fixed
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.type	hrdbf_fmt_harbour, @function
hrdbf_fmt_harbour:
	endbr64
	cmpl	$32, %edx
	ja	.L1590
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1590:
	xorl	%eax, %eax
	ret
	.size	hrdbf_fmt_harbour, .-hrdbf_fmt_harbour
	.p2align 4
	.globl	hrdbf_write_char
	.type	hrdbf_write_char, @function
hrdbf_write_char:
	endbr64
	cmpb	$67, 11(%rsi)
	movl	$3, %eax
	jne	.L1591
	movzwl	14(%rsi), %eax
	addq	%rax, %rdi
	movzbl	12(%rsi), %eax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	testq	%rcx, %rcx
	je	.L1593
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1594:
	movzbl	(%rdx,%rax), %r8d
	movb	%r8b, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1594
	movzbl	12(%rsi), %eax
.L1593:
	cmpq	%rcx, %rax
	jbe	.L1596
	.p2align 4,,10
	.p2align 3
.L1595:
	movb	$32, (%rdi,%rcx)
	movzbl	12(%rsi), %eax
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L1595
.L1596:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1591:
	ret
	.size	hrdbf_write_char, .-hrdbf_write_char
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.type	hrdbf_write_number_scaled, @function
hrdbf_write_number_scaled:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1605
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1605:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_scaled, .-hrdbf_write_number_scaled
	.p2align 4
	.globl	hrdbf_write_number_double
	.type	hrdbf_write_number_double, @function
hrdbf_write_number_double:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1607
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1607:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_double, .-hrdbf_write_number_double
	.p2align 4
	.globl	hrdbf_write_date
	.type	hrdbf_write_date, @function
hrdbf_write_date:
	endbr64
	cmpb	$68, 11(%rsi)
	movl	%edx, %ecx
	movl	$3, %r8d
	jne	.L1608
	movzwl	14(%rsi), %eax
	addq	%rdi, %rax
	testl	%edx, %edx
	je	.L1623
	movl	%edx, %r9d
	movl	$5, %r8d
	imulq	$1374389535, %r9, %rsi
	shrq	$37, %rsi
	movl	%esi, %edx
	imulq	$1374389535, %rdx, %rdx
	shrq	$37, %rdx
	imull	$100, %edx, %edi
	movl	%esi, %edx
	imull	$100, %esi, %esi
	subl	%edi, %edx
	movl	%ecx, %edi
	subl	%esi, %edi
	leal	-1(%rdx), %esi
	cmpl	$11, %esi
	ja	.L1608
	cmpl	$9999, %ecx
	jbe	.L1608
	testl	%edi, %edi
	je	.L1608
	leal	-2(%rdx), %ecx
	movl	$31, %r10d
	cmpl	$9, %ecx
	jbe	.L1624
.L1612:
	movl	$3518437209, %esi
	imulq	%r9, %rsi
	shrq	$45, %rsi
	cmpl	$2, %edx
	je	.L1625
.L1613:
	movl	$5, %r8d
	cmpl	%edi, %r10d
	jb	.L1608
	imulq	$1801439851, %r9, %rcx
	movl	$3435973837, %r9d
	shrq	$54, %rcx
	movl	%ecx, %r8d
	imulq	%r9, %r8
	shrq	$35, %r8
	leal	(%r8,%r8,4), %r8d
	addl	%r8d, %r8d
	subl	%r8d, %ecx
	addl	$48, %ecx
	movb	%cl, (%rax)
	movl	%esi, %ecx
	imulq	$1374389535, %rcx, %r8
	imulq	%r9, %rcx
	shrq	$37, %r8
	movl	%r8d, %r10d
	shrq	$35, %rcx
	imulq	%r9, %r10
	shrq	$35, %r10
	leal	(%r10,%r10,4), %r10d
	addl	%r10d, %r10d
	subl	%r10d, %r8d
	addl	$48, %r8d
	movb	%r8b, 1(%rax)
	movl	%ecx, %r8d
	imulq	%r9, %r8
	shrq	$35, %r8
	leal	(%r8,%r8,4), %r10d
	movl	%ecx, %r8d
	leal	(%rcx,%rcx,4), %ecx
	addl	%ecx, %ecx
	addl	%r10d, %r10d
	subl	%ecx, %esi
	movl	%edx, %ecx
	subl	%r10d, %r8d
	imulq	%r9, %rcx
	addl	$48, %esi
	addl	$48, %r8d
	movb	%sil, 3(%rax)
	movb	%r8b, 2(%rax)
	shrq	$35, %rcx
	leal	48(%rcx), %esi
	leal	(%rcx,%rcx,4), %ecx
	addl	%ecx, %ecx
	movb	%sil, 4(%rax)
	subl	%ecx, %edx
	addl	$48, %edx
	movb	%dl, 5(%rax)
	movl	%edi, %edx
	imulq	%r9, %rdx
	shrq	$35, %rdx
	leal	48(%rdx), %ecx
	movb	%cl, 6(%rax)
	leal	(%rdx,%rdx,4), %ecx
	addl	%ecx, %ecx
	subl	%ecx, %edi
	xorl	%r8d, %r8d
	movl	%edi, %edx
	addl	$48, %edx
	movb	%dl, 7(%rax)
.L1608:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1623:
	leaq	8(%rax), %rdx
	.p2align 4,,10
	.p2align 3
.L1611:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1611
	xorl	%r8d, %r8d
	jmp	.L1608
	.p2align 4,,10
	.p2align 3
.L1624:
	movl	CSWTCH.495(,%rcx,4), %r10d
	jmp	.L1612
	.p2align 4,,10
	.p2align 3
.L1625:
	testb	$3, %sil
	jne	.L1613
	imull	$-1030792151, %esi, %ecx
	movl	%ecx, %r8d
	rorl	$2, %r8d
	cmpl	$42949672, %r8d
	ja	.L1614
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L1613
.L1614:
	addl	$1, %r10d
	jmp	.L1613
	.size	hrdbf_write_date, .-hrdbf_write_date
	.p2align 4
	.globl	hrdbf_write_logical
	.type	hrdbf_write_logical, @function
hrdbf_write_logical:
	endbr64
	cmpb	$76, 11(%rsi)
	movl	$3, %eax
	jne	.L1626
	cmpb	$1, %dl
	movzwl	14(%rsi), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	xorl	%eax, %eax
.L1626:
	ret
	.size	hrdbf_write_logical, .-hrdbf_write_logical
	.p2align 4
	.globl	hrdbf_write_blank
	.type	hrdbf_write_blank, @function
hrdbf_write_blank:
	endbr64
	movzbl	11(%rsi), %eax
	movzwl	14(%rsi), %edx
	leal	-67(%rax), %ecx
	cmpb	$1, %cl
	jbe	.L1638
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1637
.L1638:
	movzbl	12(%rsi), %ecx
	testl	%ecx, %ecx
	je	.L1636
	leaq	(%rdi,%rdx), %rax
	subl	$1, %ecx
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1635:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1635
.L1636:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1637:
	movl	$3, %eax
	ret
	.size	hrdbf_write_blank, .-hrdbf_write_blank
	.p2align 4
	.globl	hrdbf_write_deleted
	.type	hrdbf_write_deleted, @function
hrdbf_write_deleted:
	endbr64
	cmpb	$1, %sil
	sbbl	%eax, %eax
	andl	$-10, %eax
	addl	$42, %eax
	movb	%al, (%rdi)
	ret
	.size	hrdbf_write_deleted, .-hrdbf_write_deleted
	.p2align 4
	.globl	hrdbf_file_close
	.type	hrdbf_file_close, @function
hrdbf_file_close:
	endbr64
	cmpb	$0, 32976(%rdi)
	movq	$0, (%rdi)
	movq	%rdi, %r8
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movl	$0, 32960(%rdi)
	je	.L1649
	xorl	%edx, %edx
	movq	32968(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, 32976(%r8)
	movq	$0, 32968(%r8)
	testq	%rax, %rax
	js	.L1655
.L1649:
	xorl	%r9d, %r9d
.L1648:
	movq	32944(%r8), %rdi
	testq	%rdi, %rdi
	je	.L1646
	movq	32952(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1651
	movq	$0, 32944(%r8)
	movq	$0, 32952(%r8)
.L1646:
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1655:
	movl	$7, %r9d
	jmp	.L1648
	.p2align 4,,10
	.p2align 3
.L1651:
	movl	$7, %r9d
	movl	%r9d, %eax
	ret
	.size	hrdbf_file_close, .-hrdbf_file_close
	.section	.rodata.str1.8
	.align 8
.LC50:
	.string	"OS open failed (missing file, permission or sharing conflict)"
	.section	.rodata.str1.1
.LC51:
	.string	"OS seek failed"
.LC52:
	.string	"file size "
.LC53:
	.string	" exceeds the 1 GiB limit"
	.section	.rodata.str1.8
	.align 8
.LC54:
	.string	"out of memory snapshotting the file"
	.section	.rodata.str1.1
.LC55:
	.string	"OS read failed"
	.section	.rodata.str1.8
	.align 8
.LC56:
	.string	"file changed size while being read"
	.text
	.p2align 4
	.type	hrdbf_file_open.part.0, @function
hrdbf_file_open.part.0:
	pushq	%r13
	xorl	%eax, %eax
	movl	$0, %r10d
	movl	$257, %r8d
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$24, %rsp
	cmpl	$1, %edx
	movb	$0, 32977(%rdi)
	sete	%al
	movl	%eax, 32960(%rdi)
	sete	%al
	movq	$-100, %rdi
	movzbl	%al, %eax
	leaq	524288(%rax,%rax), %rdx
	.p2align 4,,10
	.p2align 3
.L1657:
	movq	%r8, %rax
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.L1657
	testq	%rax, %rax
	js	.L1695
	movl	$8, %r8d
	xorl	%ebx, %ebx
	movl	$2, %edx
	movq	%r12, %rdi
	movq	%r8, %rax
	movq	%rbx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC51, %esi
	movq	%rax, %r13
	movq	%rax, %rdx
	testq	%rax, %rax
	js	.L1693
	cmpq	$32, %rax
	jle	.L1696
	cmpq	$1073741824, %rax
	jg	.L1697
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1698
	movq	%r13, 32952(%rbp)
	xorl	%r9d, %r9d
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.L1666
	movq	$0, 32944(%rbp)
.L1667:
	movq	$0, 32952(%rbp)
	movq	%rbp, %rdi
	movl	$.LC54, %esi
	call	fset
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r10d
	testq	%rax, %rax
	js	.L1694
	.p2align 4,,10
	.p2align 3
.L1661:
	movq	%rbp, %rdi
	call	hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r10d
.L1656:
	addq	$24, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1701:
	movq	%rax, %rdx
	movl	$.LC55, %esi
.L1693:
	movq	%rbp, %rdi
	call	ferr
.L1692:
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.L1661
	.p2align 4,,10
	.p2align 3
.L1666:
	movq	%rax, 32944(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L1667
	movq	32952(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.L1668
	.p2align 4,,10
	.p2align 3
.L1669:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L1672:
	movq	%r8, %rax
	movq	%r12, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L1672
	testq	%rax, %rax
	jne	.L1699
	movq	32952(%rbp), %rdx
	movq	32944(%rbp), %rsi
	movq	%rbp, %rdi
	call	hrdbf_open
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1674
	movl	32960(%rbp), %eax
	testl	%eax, %eax
	jne	.L1700
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1656
	jmp	.L1694
	.p2align 4,,10
	.p2align 3
.L1702:
	movq	32944(%rbp), %rsi
.L1668:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%rbx, %rax
	movq	%r12, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L1670
	testq	%rax, %rax
	jle	.L1701
	addq	%rax, %r8
.L1670:
	movq	32952(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.L1702
	jmp	.L1669
	.p2align 4,,10
	.p2align 3
.L1697:
	movq	%rbp, %rdi
	movl	$.LC52, %esi
	call	fset
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call	fdec
	movq	%rbp, %rdi
	movl	$.LC53, %esi
	call	fcat
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r10d
	testq	%rax, %rax
	jns	.L1661
	jmp	.L1694
.L1699:
	movq	%rbp, %rdi
	movl	$.LC56, %esi
	call	fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1694:
	movl	$7, %r10d
	jmp	.L1661
	.p2align 4,,10
	.p2align 3
.L1696:
	movq	%rbp, %rdi
	movl	$.LC5, %esi
	call	fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r10d
	testq	%rax, %rax
	jns	.L1661
	jmp	.L1694
.L1695:
	movq	%rax, %rdx
	movl	$.LC50, %esi
	movq	%rbp, %rdi
	call	ferr
	movl	$7, %r10d
	jmp	.L1656
.L1698:
	movl	$.LC51, %esi
	movq	%rbp, %rdi
	call	fset
	jmp	.L1692
.L1674:
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1661
	jmp	.L1694
.L1700:
	movq	%r12, 32968(%rbp)
	movb	$1, 32976(%rbp)
	jmp	.L1656
	.size	hrdbf_file_open.part.0, .-hrdbf_file_open.part.0
	.p2align 4
	.type	hrdbf_app_exit, @function
hrdbf_app_exit:
	call	hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movl	$1, %edi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	.size	hrdbf_app_exit, .-hrdbf_app_exit
	.p2align 4
	.type	hrdbf_app_fail, @function
hrdbf_app_fail:
	xorl	%edx, %edx
	cmpb	$0, (%rdi)
	movq	%rdi, %rsi
	je	.L1705
	.p2align 4,,10
	.p2align 3
.L1706:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.L1706
.L1705:
	movl	$1, %eax
	movl	$2, %edi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrdbf_app_exit
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.section	.rodata.str1.8
	.align 8
.LC57:
	.string	"hbc: DBF field decoding failed\n"
	.align 8
.LC58:
	.string	"hbc: DBF field string allocation failed\n"
	.text
	.p2align 4
	.type	hrdbf_app_get_ord.part.0, @function
hrdbf_app_get_ord.part.0:
	pushq	%rbx
	movq	%rsi, %rbx
	movl	%edi, %esi
	movl	$hrdbf_app_state, %edi
	subq	$288, %rsp
	movq	%rsp, %rdx
	call	hrdbf_get
	testl	%eax, %eax
	jne	.L1723
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.L1724
	cmpb	$78, %al
	je	.L1725
	cmpb	$68, %al
	je	.L1726
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1724:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.L1727
.L1712:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.L1728
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1726:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1725:
	movzbl	2(%rsp), %eax
	movzbl	1(%rsp), %edx
	salq	$8, %rax
	salq	$16, %rdx
	orq	%rdx, %rax
	movq	16(%rsp), %rdx
	addq	$288, %rsp
	orq	$12, %rax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1727:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.L1715
	.p2align 4,,10
	.p2align 3
.L1714:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1714
.L1715:
	leaq	32(%rsp), %rdi
	jmp	.L1712
.L1723:
	movl	$.LC57, %edi
	call	hrdbf_app_fail
.L1728:
	movl	$.LC58, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
	endbr64
	movb	$0, 32977(%rdi)
	movq	%rdi, %r8
	movq	%rsi, %r10
	movl	%edx, %r9d
	cmpb	$0, 32976(%rdi)
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movl	$0, 32960(%rdi)
	jne	.L1730
	movq	32944(%rdi), %rdi
	testq	%rdi, %rdi
	je	.L1732
	movq	32952(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1729
.L1738:
	movq	$0, 32944(%r8)
	movq	$0, 32952(%r8)
.L1732:
	movl	%r9d, %edx
	movq	%r10, %rsi
	movq	%r8, %rdi
	jmp	hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.L1730:
	xorl	%edx, %edx
	movq	32968(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, 32976(%r8)
	movq	32944(%r8), %rdi
	movq	$0, 32968(%r8)
	testq	%rax, %rax
	js	.L1742
	testq	%rdi, %rdi
	je	.L1732
	movq	32952(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1738
.L1729:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1742:
	testq	%rdi, %rdi
	je	.L1729
	movq	32952(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1729
	movq	$0, 32944(%r8)
	movl	$7, %eax
	movq	$0, 32952(%r8)
	ret
	.size	hrdbf_file_open, .-hrdbf_file_open
	.p2align 4
	.globl	hrdbf_file_write_record
	.type	hrdbf_file_write_record, @function
hrdbf_file_write_record:
	endbr64
	movl	32960(%rdi), %edx
	movq	%rdi, %r8
	movl	$6, %eax
	testl	%edx, %edx
	je	.L1743
	cmpb	$0, 32976(%rdi)
	je	.L1743
	cmpb	$0, 40(%rdi)
	je	.L1743
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L1743
	movl	16(%rdi), %edx
	cmpq	%rsi, %rdx
	jb	.L1743
	leaq	-1(%rsi), %r10
	movzwl	34(%rdi), %edx
	movzwl	32(%rdi), %eax
	movl	$18, %r9d
	movq	%r10, %rsi
	imulq	%rdx, %rsi
	leaq	(%rsi,%rax), %r10
	movq	32944(%rdi), %rsi
	addq	%r10, %rsi
	testq	%rdx, %rdx
	je	.L1747
	.p2align 4,,10
	.p2align 3
.L1745:
	movq	32968(%r8), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L1745
	testq	%rax, %rax
	jle	.L1753
	cmpq	%rdx, %rax
	ja	.L1753
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L1745
.L1747:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1753:
	movl	$7, %eax
.L1743:
	ret
	.size	hrdbf_file_write_record, .-hrdbf_file_write_record
	.p2align 4
	.globl	hrdbf_file_append
	.type	hrdbf_file_append, @function
hrdbf_file_append:
	endbr64
	movl	32960(%rdi), %eax
	testl	%eax, %eax
	je	.L1762
	cmpb	$0, 32976(%rdi)
	je	.L1762
	cmpb	$0, 40(%rdi)
	je	.L1762
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1762:
	movl	$6, %eax
	ret
	.size	hrdbf_file_append, .-hrdbf_file_append
	.p2align 4
	.globl	hrntx_close
	.type	hrntx_close, @function
hrntx_close:
	endbr64
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movq	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	ret
	.size	hrntx_close, .-hrntx_close
	.p2align 4
	.globl	hrntx_seek
	.type	hrntx_seek, @function
hrntx_seek:
	endbr64
	pushq	%r14
	pushq	%r13
	movq	%r9, %r13
	pushq	%r12
	movl	%r8d, %r12d
	pushq	%rbp
	movl	%ecx, %ebp
	pushq	%rbx
	movzwl	28(%rdi), %eax
	movq	%rdi, %rbx
	movl	24(%rdi), %r11d
	movl	$0, (%r9)
	cmpq	%rdx, %rax
	cmovbe	%rax, %rdx
	testl	%r11d, %r11d
	je	.L1769
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.L1774:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1787
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1773
	.p2align 4,,10
	.p2align 3
.L1771:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1787
.L1773:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.L1771
	jnb	.L1787
	leal	1(%rdi), %r10d
.L1770:
	cmpl	%r11d, %r10d
	jb	.L1774
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1778
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.L1777:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.L1779
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1780
	.p2align 4,,10
	.p2align 3
.L1812:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1779
.L1780:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.L1812
.L1778:
	testl	%ebp, %ebp
	je	.L1768
	testl	%r12d, %r12d
	jne	.L1813
	movl	%r10d, %r11d
.L1768:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1787:
	movl	%edi, %r11d
	jmp	.L1770
.L1779:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.L1768
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1781
	.p2align 4,,10
	.p2align 3
.L1786:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1782
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1785
	.p2align 4,,10
	.p2align 3
.L1783:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1782
.L1785:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.L1783
	jb	.L1782
	movl	%edi, %r11d
.L1784:
	cmpl	%r11d, %r10d
	jb	.L1786
.L1781:
	leal	-1(%r10), %r11d
	popq	%rbx
	popq	%rbp
	movl	%r11d, %eax
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1782:
	leal	1(%rdi), %r10d
	jmp	.L1784
.L1813:
	leal	-1(%r10), %eax
	testl	%r10d, %r10d
	popq	%rbx
	popq	%rbp
	cmovne	%eax, %r11d
	popq	%r12
	popq	%r13
	popq	%r14
	movl	%r11d, %eax
	ret
.L1769:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.L1768
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.L1777
	.size	hrntx_seek, .-hrntx_seek
	.p2align 4
	.globl	hrntx_build
	.type	hrntx_build, @function
hrntx_build:
	endbr64
	pushq	%r15
	movq	%rcx, %rax
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$120, %rsp
	movzwl	28(%rdx), %ebx
	movl	16(%rcx), %ecx
	movq	%r8, 16(%rsp)
	movzwl	30(%rdx), %edx
	movw	%bx, 24(%rsp)
	testq	%rdi, %rdi
	je	.L1818
	movq	%rsi, %r10
	testq	%rsi, %rsi
	je	.L1818
	cmpb	$0, 40(%rax)
	je	.L1818
	movq	%rdi, %rbp
	movzwl	24(%rsp), %edi
	testw	%di, %di
	je	.L1818
	cmpq	$0, 16(%rsp)
	je	.L1818
	movl	%ecx, %ebx
	movq	%rbx, %rcx
	movq	%rbx, 56(%rsp)
	salq	$4, %rcx
	cmpq	%r9, %rcx
	ja	.L1818
	movzwl	18(%rsi), %ecx
	movw	%cx, 100(%rsp)
	testw	%cx, %cx
	je	.L1818
	movzwl	%cx, %r11d
	movzwl	%di, %esi
	leaq	8(%rsi), %r13
	movq	%r11, %rcx
	leaq	4(%r11,%r11), %r12
	movq	%r11, 64(%rsp)
	imulq	%r13, %rcx
	addq	%r12, %rcx
	cmpq	$1024, %rcx
	ja	.L1818
	leaq	1(%r11), %rdi
	movq	%rdi, 72(%rsp)
	cmpq	%r11, %rbx
	ja	.L1819
	testq	%rbx, %rbx
	je	.L1864
.L1820:
	salq	$4, %rdx
	movzwl	32(%rax), %ecx
	movq	56(%rsp), %r9
	movzwl	56(%rdx,%rax), %edx
	movzwl	34(%rax), %edi
	addq	%rdx, %rcx
	movq	16(%rsp), %rdx
	addq	(%rax), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1822:
	leal	1(%rax), %r8d
	addq	$1, %rax
	movq	%rcx, 8(%rdx)
	addq	$16, %rdx
	movl	%r8d, -16(%rdx)
	addq	%rdi, %rcx
	cmpq	%rax, %r9
	ja	.L1822
	cmpq	$1, 56(%rsp)
	jbe	.L1841
	movq	16(%rsp), %r11
	movq	%r13, 32(%rsp)
	movl	$1, %r15d
	movq	56(%rsp), %r13
	leaq	16(%r11), %r14
	.p2align 4,,10
	.p2align 3
.L1829:
	movl	(%r14), %ebx
	movq	8(%r14), %rcx
	movq	%r14, %rdi
	.p2align 4,,10
	.p2align 3
.L1824:
	movl	-16(%rdi), %r8d
	movq	-8(%rdi), %rdx
	movq	%rdi, %r9
	xorl	%eax, %eax
	movl	%r8d, 8(%rsp)
	.p2align 4,,10
	.p2align 3
.L1828:
	movzbl	(%rdx,%rax), %r8d
	cmpb	%r8b, (%rcx,%rax)
	jne	.L1865
	addq	$1, %rax
	cmpq	%rax, %rsi
	ja	.L1828
	movl	8(%rsp), %r8d
	cmpl	%ebx, %r8d
	jbe	.L1825
.L1827:
	movdqu	-16(%rdi), %xmm0
	subq	$16, %rdi
	movups	%xmm0, 16(%rdi)
	cmpq	%rdi, %r11
	jne	.L1824
	movq	%r11, %r9
	.p2align 4,,10
	.p2align 3
.L1825:
	addq	$1, %r15
	movl	%ebx, (%r9)
	addq	$16, %r14
	movq	%rcx, 8(%r9)
	cmpq	%r15, %r13
	jne	.L1829
	movq	32(%rsp), %r13
.L1841:
	movq	56(%rsp), %rax
	movq	64(%rsp), %rbx
	xorl	%edx, %edx
	leaq	1(%rax,%rbx), %rax
	divq	72(%rsp)
	movq	%rax, 40(%rsp)
	cmpq	%rbx, %rax
	jbe	.L1821
	.p2align 4,,10
	.p2align 3
.L1818:
	xorl	%eax, %eax
.L1814:
	addq	$120, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1819:
	movq	64(%rsp), %rbx
	movq	%rbx, %rcx
	imulq	%rbx, %rcx
	cmpq	%rcx, 56(%rsp)
	jbe	.L1820
	jmp	.L1818
.L1864:
	movq	$1, 40(%rsp)
.L1821:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1830:
	movzbl	(%r10,%rax), %edx
	movb	%dl, 0(%rbp,%rax)
	addq	$1, %rax
	cmpq	$1024, %rax
	jne	.L1830
	movq	40(%rsp), %rax
	testq	%rax, %rax
	je	.L1831
	subq	$1, %rax
	movq	%rbp, 104(%rsp)
	leaq	1024(%rbp), %r15
	movq	%rax, 88(%rsp)
	movq	56(%rsp), %rax
	movq	$0, 48(%rsp)
	movq	%rax, 80(%rsp)
	movzwl	100(%rsp), %eax
	movq	$0, 32(%rsp)
	shrw	$8, %ax
	movw	%ax, 102(%rsp)
.L1834:
	movq	32(%rsp), %rbx
	cmpq	%rbx, 88(%rsp)
	je	.L1866
	movzbl	100(%rsp), %eax
	movzwl	24(%rsp), %ebx
	movb	%al, (%r15)
	movzbl	102(%rsp), %eax
	movb	%al, 1(%r15)
	movq	64(%rsp), %rax
	movq	%rax, 8(%rsp)
.L1833:
	movq	48(%rsp), %rax
	movq	16(%rsp), %rdi
	xorl	%r14d, %r14d
	salq	$4, %rax
	leaq	(%rdi,%rax), %rbp
	.p2align 4,,10
	.p2align 3
.L1836:
	pushq	%rbx
	movl	0(%rbp), %r9d
	movq	%r14, %rsi
	xorl	%r8d, %r8d
	pushq	8(%rbp)
	movq	%r13, %rcx
	movq	%r12, %rdx
	movq	%r15, %rdi
	addq	$1, %r14
	addq	$16, %rbp
	call	nxputslot
	popq	%r10
	popq	%r11
	cmpq	8(%rsp), %r14
	jne	.L1836
.L1837:
	pushq	%rbx
	movq	%r15, %rdi
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	pushq	$0
	movq	24(%rsp), %rsi
	movq	%r13, %rcx
	movq	%r12, %rdx
	addq	$1024, %r15
	call	nxputslot
	movq	88(%rsp), %rsi
	addq	$1, 48(%rsp)
	addq	%rsi, 64(%rsp)
	movq	48(%rsp), %rax
	subq	%rsi, 96(%rsp)
	popq	%rbp
	popq	%r14
	cmpq	40(%rsp), %rax
	jne	.L1834
	movq	40(%rsp), %rax
	movq	104(%rsp), %rbp
	movl	%ebx, 8(%rsp)
	cmpq	$1, %rax
	je	.L1831
	leaq	1(%rax), %r15
	movl	$1, %r10d
	subl	$1, %eax
	movq	%rbp, 24(%rsp)
	salq	$10, %r15
	movq	64(%rsp), %rbx
	leaq	0(%rbp,%r15), %rdi
	movq	%r12, %rbp
	movq	%r10, %r12
	movw	%ax, (%rdi)
	movq	%rdi, %r14
	jmp	.L1838
.L1844:
	movq	%rdx, %r12
.L1838:
	leaq	-1(%r12), %rsi
	cmpq	%rbx, 56(%rsp)
	jbe	.L1818
	movl	8(%rsp), %eax
	movq	%rbx, %rdx
	movl	%r12d, %r8d
	movq	%r13, %rcx
	salq	$4, %rdx
	sall	$10, %r8d
	movq	%r14, %rdi
	pushq	%rax
	movq	24(%rsp), %rax
	pushq	8(%rax,%rdx)
	movl	(%rax,%rdx), %r9d
	movq	%rbp, %rdx
	call	nxputslot
	addq	88(%rsp), %rbx
	leaq	1(%r12), %rdx
	popq	%r8
	popq	%r9
	cmpq	40(%rsp), %rdx
	jne	.L1844
	movl	8(%rsp), %eax
	movq	%r12, %r10
	movq	%rbp, %r12
	movq	24(%rsp), %rbp
	movq	%r14, %rdi
	movq	%r13, %rcx
	movq	%r12, %rdx
	movq	%r10, %rsi
	pushq	%rax
	xorl	%r9d, %r9d
	pushq	$0
	movl	56(%rsp), %r8d
	sall	$10, %r8d
	call	nxputslot
	movq	%r15, %rax
	movl	%r15d, %ecx
	movl	%r15d, %edx
	shrl	$16, %ecx
	movzbl	%ah, %esi
	shrl	$24, %edx
	popq	%rax
	movl	$2, %eax
	popq	%rdi
.L1839:
	addq	40(%rsp), %rax
	movb	$0, 4(%rbp)
	movb	%sil, 5(%rbp)
	salq	$10, %rax
	movb	%cl, 6(%rbp)
	movb	%dl, 7(%rbp)
	jmp	.L1814
	.p2align 4,,10
	.p2align 3
.L1865:
	jb	.L1827
	jmp	.L1825
.L1866:
	movq	80(%rsp), %rax
	cmpq	%rax, 64(%rsp)
	jb	.L1818
	movzbl	%ah, %ebx
	movb	%al, (%r15)
	movb	%bl, 1(%r15)
	movzwl	24(%rsp), %ebx
	testq	%rax, %rax
	jne	.L1843
	movq	$0, 8(%rsp)
	jmp	.L1837
.L1843:
	movq	80(%rsp), %rax
	movq	%rax, 8(%rsp)
	jmp	.L1833
.L1831:
	movl	$4, %esi
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.L1839
	.size	hrntx_build, .-hrntx_build
	.p2align 4
	.globl	hrcdx_build
	.type	hrcdx_build, @function
hrcdx_build:
	endbr64
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$424, %rsp
	movzwl	28(%rdx), %r14d
	movzwl	30(%rdx), %r15d
	movl	16(%rcx), %r11d
	testq	%rdi, %rdi
	je	.L1872
	movq	%rsi, %rbp
	testq	%rsi, %rsi
	je	.L1872
	cmpb	$0, 40(%rcx)
	movq	%rcx, %rbx
	je	.L1872
	testw	%r14w, %r14w
	je	.L1872
	movq	%r8, %r13
	testq	%r8, %r8
	je	.L1872
	movl	%r11d, %r10d
	movq	%r10, %rax
	salq	$4, %rax
	cmpq	%r9, %rax
	ja	.L1872
	movl	(%rsi), %eax
	movq	8(%rcx), %rdx
	cmpl	$1023, %eax
	jbe	.L1872
	testl	$511, %eax
	jne	.L1872
	subq	$512, %rdx
	cmpq	%rdx, %rax
	ja	.L1872
	movq	%rdi, %r12
	leaq	(%rsi,%rax), %rdi
	cmpw	$3, (%rdi)
	jne	.L1872
	cmpw	$1, 2(%rsi,%rax)
	jne	.L1872
	leaq	128(%rsp), %rdx
	movl	$10, %esi
	movq	%r10, 16(%rsp)
	movl	%r11d, 8(%rsp)
	movq	$512, 120(%rsp)
	movq	%rdi, (%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L1872
	leaq	116(%rsp), %rax
	xorl	%edx, %edx
	movl	$10, %ecx
	pushq	%rax
	movq	8(%rsp), %rdi
	leaq	128(%rsp), %r9
	leaq	168(%rsp), %r8
	leaq	136(%rsp), %rsi
	call	cxkey
	popq	%rdx
	testl	%eax, %eax
	jne	.L1872
	movl	116(%rsp), %eax
	movl	%eax, %ecx
	movq	8(%rbx), %rax
	movl	%ecx, 36(%rsp)
	cmpl	$1023, %ecx
	jbe	.L1872
	testl	$511, %ecx
	jne	.L1872
	subq	$512, %rax
	movq	%rcx, 40(%rsp)
	cmpq	%rax, %rcx
	ja	.L1872
	movq	16(%rsp), %r10
	movl	8(%rsp), %r11d
	movl	$1, %eax
	movl	$1, %esi
	movl	%eax, %ecx
	testq	%r10, %r10
	cmove	%eax, %r11d
	jmp	.L1875
	.p2align 4,,10
	.p2align 3
.L1877:
	addl	$1, %ecx
	cmpl	$32, %ecx
	je	.L1876
.L1875:
	movl	%esi, %edx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %r11d
	ja	.L1877
.L1876:
	movzwl	%r14w, %esi
	movl	$16, %edx
	movl	%ecx, %eax
	movl	$3, %r8d
	movl	%esi, 88(%rsp)
	cmpl	%edx, %ecx
	cmovb	%edx, %eax
	movl	$1, %edx
.L1911:
	movl	$1, %ecx
	jmp	.L1878
	.p2align 4,,10
	.p2align 3
.L1880:
	addl	$1, %ecx
	cmpl	$32, %ecx
	je	.L1879
.L1878:
	movl	%edx, %edi
	sall	%cl, %edi
	subl	$1, %edi
	cmpl	%edi, %esi
	ja	.L1880
	movl	%ecx, %edi
	leal	0(,%r8,4), %ecx
	subl	%edi, %ecx
	addl	%ecx, %ecx
	cmpl	$32, %ecx
	ja	.L1879
	cmpl	%ecx, %eax
	ja	.L1879
	movl	%edx, %r9d
	sall	%cl, %r9d
	subl	$1, %r9d
	cmpl	16(%rbx), %r9d
	jnb	.L1951
.L1879:
	cmpl	$6, %r8d
	je	.L1872
	addl	$1, %r8d
	jmp	.L1911
	.p2align 4,,10
	.p2align 3
.L1872:
	xorl	%eax, %eax
.L1867:
	addq	$424, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1951:
	movzwl	%r14w, %esi
	movl	%r8d, %eax
	movl	%ecx, 72(%rsp)
	leaq	8(%rsi), %r11
	leaq	(%rsi,%rax), %rcx
	movq	%rax, 56(%rsp)
	movq	%r11, 64(%rsp)
	cmpq	$488, %rcx
	ja	.L1872
	cmpq	$500, %r11
	ja	.L1872
	movl	$488, %eax
	xorl	%edx, %edx
	divq	%rcx
	movq	%rax, 16(%rsp)
	testq	%r10, %r10
	je	.L1913
	movq	%rax, %rcx
	xorl	%edx, %edx
	leaq	-1(%r10,%rax), %rax
	divq	%rcx
	xorl	%edx, %edx
	movq	%rax, (%rsp)
	movl	$500, %eax
	divq	%r11
	cmpq	(%rsp), %rax
	jb	.L1872
.L1881:
	movzwl	%r15w, %eax
	movq	%r13, %r9
	xorl	%ecx, %ecx
	addq	$2, %rax
	salq	$4, %rax
	leaq	(%rbx,%rax), %r11
	jmp	.L1882
.L1883:
	leal	1(%rcx), %eax
	movzwl	24(%r11), %edx
	addq	$16, %r9
	movl	%eax, -16(%r9)
	movzwl	32(%rbx), %eax
	addq	%rdx, %rax
	movzwl	34(%rbx), %edx
	imulq	%rcx, %rdx
	addq	$1, %rcx
	addq	%rdx, %rax
	addq	(%rbx), %rax
	movq	%rax, -8(%r9)
.L1882:
	cmpq	%r10, %rcx
	jb	.L1883
	movl	$16, %r15d
	movl	$1, %ebx
.L1884:
	cmpq	%r10, %rbx
	jnb	.L1952
	movl	0(%r13,%r15), %r11d
	movq	8(%r13,%r15), %rdx
	movq	%r15, %r9
.L1885:
	movl	-16(%r13,%r9), %eax
	movq	-8(%r13,%r9), %rcx
	movl	%edi, 8(%rsp)
	movl	%eax, 24(%rsp)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1889:
	movzbl	(%rcx,%rax), %edi
	cmpb	%dil, (%rdx,%rax)
	jne	.L1953
	addq	$1, %rax
	cmpq	%rax, %rsi
	ja	.L1889
	xorl	%eax, %eax
	movl	8(%rsp), %edi
	cmpl	24(%rsp), %r11d
	setb	%al
.L1891:
	testl	%eax, %eax
	je	.L1886
	movdqu	-16(%r13,%r9), %xmm0
	movups	%xmm0, 0(%r13,%r9)
	subq	$16, %r9
	jne	.L1885
.L1886:
	addq	%r13, %r9
	addq	$1, %rbx
	addq	$16, %r15
	movl	%r11d, (%r9)
	movq	%rdx, 8(%r9)
	jmp	.L1884
.L1913:
	movq	$1, (%rsp)
	jmp	.L1881
.L1953:
	sbbl	%eax, %eax
	movl	8(%rsp), %edi
	shrl	$31, %eax
	jmp	.L1891
.L1952:
	movq	40(%rsp), %rcx
	xorl	%eax, %eax
	addq	$1024, %rcx
	movq	%rcx, 24(%rsp)
.L1893:
	movzbl	0(%rbp,%rax), %edx
	movb	%dl, (%r12,%rax)
	addq	$1, %rax
	cmpq	%rax, 24(%rsp)
	ja	.L1893
	movzbl	72(%rsp), %ecx
	movl	$1, %eax
	xorl	%ebp, %ebp
	xorl	%r15d, %r15d
	salq	%cl, %rax
	subl	$1, %eax
	movzbl	%ah, %ecx
	movl	%eax, %edx
	movb	%al, 92(%rsp)
	shrl	$24, %eax
	movl	%ecx, 80(%rsp)
	movl	%edi, %ecx
	shrl	$16, %edx
	movl	%eax, 84(%rsp)
	movl	$1, %eax
	sall	%cl, %eax
	movb	%dl, 93(%rsp)
	subl	$1, %eax
	movb	%al, 79(%rsp)
	movl	36(%rsp), %eax
	addl	$1536, %eax
	movl	%eax, 32(%rsp)
	movq	24(%rsp), %rax
	leaq	(%r12,%rax), %rdx
	movq	(%rsp), %rax
	subq	$1, %rax
	movq	%rax, 48(%rsp)
	leal	(%r14,%r8), %eax
	movw	%ax, 94(%rsp)
	movl	$512, %eax
	subq	%rsi, %rax
	movq	%rax, 96(%rsp)
.L1894:
	cmpq	%r15, (%rsp)
	je	.L1954
	cmpq	%r15, 48(%rsp)
	je	.L1915
	movq	16(%rsp), %rax
	leaq	(%rax,%rbp), %r14
	movq	%r14, 8(%rsp)
.L1895:
	movq	8(%rsp), %r9
	movq	%rdx, %rax
	leaq	512(%rdx), %r11
	movq	%r9, %rcx
	subq	%rbp, %rcx
	movq	%rcx, %rbx
	movq	%r9, %rcx
	.p2align 4,,10
	.p2align 3
.L1896:
	movb	$0, (%rax)
	addq	$1, %rax
	cmpq	%rax, %r11
	jne	.L1896
	testq	%r15, %r15
	movq	%rcx, 8(%rsp)
	sete	%r9b
	xorl	%eax, %eax
	cmpq	$1, (%rsp)
	movb	$0, 1(%rdx)
	sete	%al
	movb	%bl, 2(%rdx)
	andl	%r9d, %eax
	movb	%bh, 3(%rdx)
	addl	$2, %eax
	movb	%al, (%rdx)
	testq	%r15, %r15
	je	.L1916
	movl	32(%rsp), %eax
	subl	$1024, %eax
.L1897:
	movl	%eax, %r9d
	movb	%al, 4(%rdx)
	movb	%ah, 5(%rdx)
	shrl	$24, %eax
	shrl	$16, %r9d
	cmpq	%r15, 48(%rsp)
	movb	%al, 7(%rdx)
	movl	$-1, %eax
	cmovne	32(%rsp), %eax
	movb	%r9b, 6(%rdx)
	movl	%eax, %r9d
	movb	%al, 8(%rdx)
	shrl	$16, %r9d
	movb	%ah, 9(%rdx)
	shrl	$24, %eax
	movb	%r9b, 10(%rdx)
	movzwl	94(%rsp), %r9d
	movb	%al, 11(%rdx)
	movl	$488, %eax
	imull	%ebx, %r9d
	movb	%dil, 21(%rdx)
	movb	%dil, 22(%rdx)
	movb	%r8b, 23(%rdx)
	subl	%r9d, %eax
	movb	%al, 12(%rdx)
	movb	%ah, 13(%rdx)
	movzbl	92(%rsp), %eax
	movb	%al, 14(%rdx)
	movzbl	80(%rsp), %eax
	movb	%al, 15(%rdx)
	movzbl	93(%rsp), %eax
	movb	%al, 16(%rdx)
	movzbl	84(%rsp), %eax
	movb	%al, 17(%rdx)
	movzbl	79(%rsp), %eax
	movb	%al, 18(%rdx)
	movb	%al, 19(%rdx)
	movzbl	72(%rsp), %eax
	movb	%al, 20(%rdx)
	testq	%rbx, %rbx
	je	.L1903
	movq	8(%rsp), %rcx
	movq	96(%rsp), %rax
	movq	%rbp, %r9
	salq	$4, %r9
	salq	$4, %rcx
	leaq	(%rax,%rdx), %rbx
	addq	%r13, %r9
	leaq	0(%r13,%rcx), %rax
	movq	%rax, 8(%rsp)
.L1902:
	movq	%rsi, 104(%rsp)
	movl	(%r9), %ebp
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1900:
	leal	0(,%rax,8), %ecx
	movq	%rbp, %rsi
	shrq	%cl, %rsi
	movb	%sil, 24(%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.L1900
	movq	104(%rsp), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1901:
	movq	8(%r9), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, (%rbx,%rax)
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.L1901
	addq	$16, %r9
	subq	%rsi, %rbx
	addq	56(%rsp), %rdx
	cmpq	%r9, 8(%rsp)
	jne	.L1902
.L1903:
	addl	$512, 32(%rsp)
	addq	$1, %r15
	movq	%r14, %rbp
	movq	%r11, %rdx
	jmp	.L1894
.L1916:
	orl	$-1, %eax
	jmp	.L1897
.L1915:
	movq	16(%rsp), %rax
	movq	%r10, 8(%rsp)
	leaq	(%rax,%rbp), %r14
	jmp	.L1895
.L1954:
	movq	24(%rsp), %rcx
	movq	(%rsp), %rax
	movq	%rcx, %rbx
	cmpq	$1, %rax
	jbe	.L1905
	salq	$9, %rax
	leaq	(%rax,%rcx), %rbx
	leaq	(%r12,%rbx), %rdx
	leaq	512(%rdx), %rcx
	movq	%rdx, %rax
.L1906:
	movb	$0, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1906
	movq	(%rsp), %rcx
	movl	36(%rsp), %eax
	movw	$1, (%rdx)
	addq	%rdx, %rsi
	movq	$-256, 3(%rdx)
	xorl	%ebp, %ebp
	xorl	%r11d, %r11d
	movq	%rdx, %r9
	movb	%cl, 2(%rdx)
	movq	16(%rsp), %r14
	addl	$1024, %eax
	leaq	-1(%rcx), %r15
	movb	$-1, 11(%rdx)
.L1909:
	cmpq	%r11, %r15
	movq	%r14, %rcx
	leaq	(%r9,%rbp), %r8
	movq	%r9, %rdx
	cmove	%r10, %rcx
	salq	$4, %rcx
	leaq	-16(%r13,%rcx), %rdi
	xorl	%ecx, %ecx
.L1908:
	movq	8(%rdi), %r9
	movzbl	(%r9,%rcx), %r9d
	movb	%r9b, 12(%r8,%rcx)
	addq	$1, %rcx
	cmpl	%ecx, 88(%rsp)
	ja	.L1908
	movl	(%rdi), %ecx
	movq	%rdx, %r9
	movb	%ah, 18(%rsi)
	addq	$1, %r11
	movb	%al, 19(%rsi)
	addq	16(%rsp), %r14
	movl	%ecx, %edi
	movb	%ch, 14(%rsi)
	shrl	$24, %edi
	movb	%cl, 15(%rsi)
	movb	%dil, 12(%rsi)
	movl	%ecx, %edi
	movl	%eax, %ecx
	shrl	$24, %ecx
	shrl	$16, %edi
	movb	%cl, 16(%rsi)
	movl	%eax, %ecx
	addl	$512, %eax
	shrl	$16, %ecx
	movb	%dil, 13(%rsi)
	movb	%cl, 17(%rsi)
	movq	64(%rsp), %rcx
	addq	%rcx, %rsi
	addq	%rcx, %rbp
	cmpq	%r11, (%rsp)
	jne	.L1909
.L1905:
	movq	40(%rsp), %rax
	movq	(%rsp), %rcx
	movl	%ebx, (%r12,%rax)
	xorl	%eax, %eax
	cmpq	$1, %rcx
	seta	%al
	addq	%rcx, %rax
	salq	$9, %rax
	addq	24(%rsp), %rax
	jmp	.L1867
	.size	hrcdx_build, .-hrcdx_build
	.p2align 4
	.type	hrntx_file_rebuild.constprop.0, @function
hrntx_file_rebuild.constprop.0:
	movq	hrdbf_app_order(%rip), %rdx
	testq	%rdx, %rdx
	je	.L1977
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$344, %rsp
	movl	hrdbf_app_state+16(%rip), %ebx
	movl	hrdbf_app_order+68(%rip), %r8d
	movq	%rbx, %r14
	leaq	0(,%rbx,8), %r15
	salq	$4, %r14
	testl	%r8d, %r8d
	je	.L1957
	movq	hrdbf_app_order+48(%rip), %rax
	movq	hrdbf_app_order+32(%rip), %rdi
	movq	$512, 40(%rsp)
	cmpq	$2047, %rax
	jbe	.L2005
	testl	$511, %eax
	jne	.L2005
	movl	(%rdi), %edx
	cmpl	$1023, %edx
	jbe	.L2005
	testl	$511, %edx
	jne	.L2005
	subq	$512, %rax
	cmpq	%rax, %rdx
	jbe	.L2007
	.p2align 4,,10
	.p2align 3
.L2005:
	movl	$1, %r8d
.L1955:
	addq	$344, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L1957:
	movzwl	18(%rdx), %edx
	testl	%ebx, %ebx
	jne	.L1968
	movl	$4, %r8d
	testw	%dx, %dx
	je	.L1955
	movq	$1, (%rsp)
	movl	$2048, %r13d
.L1969:
	movl	$9, %ebp
	movl	$34, %r10d
	xorl	%r9d, %r9d
	xorl	%edi, %edi
	movq	$-1, %r8
	movl	$3, %edx
	movq	%rbp, %rax
	movq	%r13, %rsi
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	leaq	4095(%rax), %rax
	cmpq	$4094, %rax
	jbe	.L2004
	testq	%r12, %r12
	je	.L2004
	addq	$7, %rbx
	movq	(%rsp), %rsi
	shrq	$3, %rbx
	leaq	(%r14,%rbx), %rax
	addq	%rax, %rsi
	movq	%rax, 8(%rsp)
	movq	%rbp, %rax
	movq	%rsi, 16(%rsp)
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbp
	leaq	4095(%rax), %rax
	cmpq	$4094, %rax
	jbe	.L1971
	testq	%rbp, %rbp
	je	.L1971
	movq	hrdbf_app_order(%rip), %rsi
	movq	%r14, %r9
	movq	%rbp, %r8
	movq	%r12, %rdi
	movl	$hrdbf_app_state, %ecx
	movl	$hrdbf_app_order, %edx
	call	hrntx_build
	movq	%rax, %r14
	testq	%rax, %rax
	jne	.L1973
	movl	$11, %r8d
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%r14, %rdx
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	8(%rsp), %rsi
	movq	%r8, %rax
	movq	%rbp, %rdi
	subq	%r15, %rsi
	addq	(%rsp), %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	jmp	.L1955
	.p2align 4,,10
	.p2align 3
.L1968:
	movzwl	%dx, %ecx
	leal	-1(%rbx,%rdx), %eax
	xorl	%edx, %edx
	movl	$4, %r8d
	divq	%rcx
	cmpq	%rcx, %rax
	ja	.L1955
	cmpq	$1, %rax
	jbe	.L1970
	leaq	2(%rax), %r13
	addq	$9, %rax
	shrq	$3, %rax
	salq	$10, %r13
	movq	%rax, (%rsp)
	jmp	.L1969
	.p2align 4,,10
	.p2align 3
.L1971:
	movl	$11, %eax
	xorl	%edx, %edx
	movq	%r12, %rdi
	movq	%r13, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r8d
	jmp	.L1955
.L1962:
	movl	$11, %eax
	xorl	%edx, %edx
	movq	%r12, %rdi
	movq	%rbx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.L2004:
	movl	$8, %r8d
	jmp	.L1955
	.p2align 4,,10
	.p2align 3
.L1977:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2007:
	leaq	(%rdi,%rdx), %r12
	movl	$10, %esi
	leaq	48(%rsp), %rdx
	movq	%r12, %rdi
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L2005
	leaq	36(%rsp), %rax
	leaq	80(%rsp), %rbp
	movq	%r12, %rdi
	xorl	%edx, %edx
	pushq	%rax
	movq	%rbp, %r8
	movl	$10, %ecx
	leaq	48(%rsp), %r9
	leaq	56(%rsp), %rsi
	call	cxkey
	popq	%rdi
	testl	%eax, %eax
	jne	.L2005
	movl	36(%rsp), %ecx
	movq	%rcx, %rax
	cmpl	$1023, %ecx
	jbe	.L2005
	andl	$511, %eax
	movl	%eax, (%rsp)
	jne	.L2005
	movq	hrdbf_app_order+48(%rip), %rax
	subq	$1024, %rax
	cmpq	%rax, %rcx
	ja	.L2005
	movzwl	hrdbf_app_order+28(%rip), %esi
	xorl	%edx, %edx
	movl	$500, %eax
	xorl	%edi, %edi
	movl	$9, %r13d
	movl	$34, %r10d
	movq	$-1, %r8
	xorl	%r9d, %r9d
	addq	$8, %rsi
	divq	%rsi
	movl	$3, %edx
	addq	$2, %rax
	salq	$9, %rax
	leaq	1024(%rcx,%rax), %rbx
	movl	hrdbf_app_state+16(%rip), %eax
	movq	%rbx, %rsi
	movl	%eax, 8(%rsp)
	movq	%r13, %rax
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4095, %rax
	jnb	.L2004
	testq	%rax, %rax
	je	.L2004
	movq	%rbx, %rax
	movl	$34, %r10d
	xorl	%r9d, %r9d
	xorl	%edi, %edi
	shrq	$9, %rax
	movq	$-1, %r8
	addq	$7, %rax
	shrq	$3, %rax
	movq	%rax, %rcx
	movq	%rax, 16(%rsp)
	movl	8(%rsp), %eax
	addq	$7, %rax
	shrq	$3, %rax
	movq	%rax, 24(%rsp)
	addq	%r14, %rax
	movq	%rax, %rsi
	movq	%r13, %rax
	addq	%rcx, %rsi
	movq	%rsi, 8(%rsp)
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r13
	leaq	4095(%rax), %rax
	cmpq	$4094, %rax
	jbe	.L1962
	testq	%r13, %r13
	je	.L1962
	movq	hrdbf_app_order+32(%rip), %rsi
	movq	%r14, %r9
	movq	%r13, %r8
	movq	%r12, %rdi
	movl	$hrdbf_app_state, %ecx
	movl	$hrdbf_app_order, %edx
	call	hrcdx_build
	movq	%rax, %r14
	testq	%rax, %rax
	jne	.L1964
	movl	$11, %r8d
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%r14, %rdx
	movq	%r8, %rax
.L2006:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	8(%rsp), %rsi
	movq	%r8, %rax
	movq	%r13, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.L2005
	.p2align 4,,10
	.p2align 3
.L1970:
	addq	$1, %rax
	movq	$1, (%rsp)
	salq	$10, %rax
	movq	%rax, %r13
	jmp	.L1969
	.p2align 4,,10
	.p2align 3
.L1973:
	movq	(%rsp), %rax
	pxor	%xmm0, %xmm0
	movq	%rbp, %r8
	movq	%r14, %rdx
	movaps	%xmm0, 80(%rsp)
	movl	hrdbf_app_state+16(%rip), %r9d
	movl	$hrdbf_app_state, %ecx
	movq	%r12, %rsi
	addq	%rbx, %rax
	movaps	%xmm0, 96(%rsp)
	pushq	%rax
	leaq	0(%rbp,%r15), %rax
	pushq	%rax
	leaq	96(%rsp), %rdi
	call	hrntx_open
	movl	%eax, %r8d
	popq	%rax
	popq	%rdx
	testl	%r8d, %r8d
	jne	.L2008
	movq	hrdbf_app_order+32(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1975
	movl	$11, %eax
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1975:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1976
	movl	$11, %eax
	movq	hrdbf_app_order+56(%rip), %rsi
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1976:
	movq	16(%rsp), %rax
	movdqa	80(%rsp), %xmm1
	movq	%r12, hrdbf_app_order+32(%rip)
	movdqa	96(%rsp), %xmm2
	movq	%r14, hrdbf_app_order+48(%rip)
	movq	%rbp, hrdbf_app_order+40(%rip)
	movq	%rax, hrdbf_app_order+56(%rip)
	movl	$1, hrdbf_app_order+64(%rip)
	movaps	%xmm1, hrdbf_app_order(%rip)
	movaps	%xmm2, hrdbf_app_order+16(%rip)
	jmp	.L1955
.L2008:
	movl	$11, %r8d
	movq	%r12, %rdi
	movq	%r13, %rsi
	xorl	%edx, %edx
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	8(%rsp), %rbx
	movq	(%rsp), %rsi
	movq	%r8, %rax
	movq	%rbp, %rdi
	subq	%r15, %rbx
	addq	%rbx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	jmp	.L1955
.L1964:
	movl	(%rsp), %eax
	movl	$8, %ecx
	movq	%rbp, %rdi
	movq	%r13, %r8
	movl	hrdbf_app_state+16(%rip), %r9d
	movq	%r12, %rsi
	movq	%r14, %rdx
	rep stosl
	movq	16(%rsp), %rax
	addq	24(%rsp), %rax
	movl	$hrdbf_app_state, %ecx
	pushq	%rax
	leaq	0(%r13,%r15), %rax
	pushq	%rax
	leaq	96(%rsp), %rdi
	call	hrcdx_open
	popq	%rcx
	popq	%rsi
	movl	%eax, %r8d
	testl	%eax, %eax
	je	.L1965
	movl	$11, %r8d
	movq	%r12, %rdi
	movq	%rbx, %rsi
	xorl	%edx, %edx
	movq	%r8, %rax
	jmp	.L2006
.L1965:
	movq	hrdbf_app_order+32(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1966
	movl	$11, %eax
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1966:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1967
	movl	$11, %eax
	movq	hrdbf_app_order+56(%rip), %rsi
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1967:
	movq	8(%rsp), %rax
	movdqa	80(%rsp), %xmm3
	movq	%r12, hrdbf_app_order+32(%rip)
	movdqa	96(%rsp), %xmm4
	movq	%r14, hrdbf_app_order+48(%rip)
	movq	%r13, hrdbf_app_order+40(%rip)
	movq	%rax, hrdbf_app_order+56(%rip)
	movl	$1, hrdbf_app_order+64(%rip)
	movaps	%xmm3, hrdbf_app_order(%rip)
	movaps	%xmm4, hrdbf_app_order+16(%rip)
	jmp	.L1955
	.size	hrntx_file_rebuild.constprop.0, .-hrntx_file_rebuild.constprop.0
	.section	.rodata.str1.8
	.align 8
.LC59:
	.string	"hbc: DBF NTX index rebuild failed\n"
	.text
	.p2align 4
	.type	hrdbf_app_rebuild_index, @function
hrdbf_app_rebuild_index:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2019
	subq	$8, %rsp
	call	hrntx_file_rebuild.constprop.0
	testl	%eax, %eax
	jne	.L2022
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %rsi
	movq	%rcx, hrdbf_app_pos(%rip)
	testq	%rcx, %rcx
	je	.L2016
	movq	hrdbf_app_order+16(%rip), %rdi
	xorl	%eax, %eax
	jmp	.L2015
	.p2align 4,,10
	.p2align 3
.L2013:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2016
.L2015:
	movl	(%rdi,%rax,8), %edx
	cmpq	%rdx, %rsi
	jne	.L2013
	cmpq	%rax, %rcx
	movq	%rax, hrdbf_app_pos(%rip)
	setbe	%al
	jbe	.L2012
.L2014:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2016:
	movl	$1, %eax
.L2012:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
	jmp	.L2014
	.p2align 4,,10
	.p2align 3
.L2019:
	ret
.L2022:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_rebuild_index, .-hrdbf_app_rebuild_index
	.section	.rodata.str1.1
.LC60:
	.string	"hbc: DBF index flush failed\n"
.LC61:
	.string	"hbc: DBF/NTX close failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_close
	.type	hrdbf_app_close, @function
hrdbf_app_close:
	endbr64
	movl	hrdbf_app_order+64(%rip), %eax
	movq	hrdbf_app_order+32(%rip), %rdi
	testl	%eax, %eax
	je	.L2024
	testq	%rdi, %rdi
	je	.L2025
	cmpq	$0, hrdbf_app_order+48(%rip)
	je	.L2026
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2027
	movq	hrdbf_app_order+32(%rip), %rdi
.L2024:
	movq	$0, hrdbf_app_order(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.L2028
.L2038:
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	testq	%rax, %rax
	js	.L2028
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L2028:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2029
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2041
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2029:
	cmpb	$0, hrdbf_app_state+32976(%rip)
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+32960(%rip)
	je	.L2034
	xorl	%edx, %edx
	movq	hrdbf_app_state+32968(%rip), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, hrdbf_app_state+32976(%rip)
	movq	$0, hrdbf_app_state+32968(%rip)
	testq	%rax, %rax
	jns	.L2034
	movq	hrdbf_app_state+32944(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2035
	movl	$7, %r9d
.L2031:
	movq	hrdbf_app_state+32952(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2035
	movq	$0, hrdbf_app_state+32944(%rip)
	orl	%r9d, %r8d
	movq	$0, hrdbf_app_state+32952(%rip)
.L2032:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	testl	%r8d, %r8d
	jne	.L2037
	ret
	.p2align 4,,10
	.p2align 3
.L2034:
	movq	hrdbf_app_state+32944(%rip), %rdi
	xorl	%r9d, %r9d
	testq	%rdi, %rdi
	jne	.L2031
	jmp	.L2032
	.p2align 4,,10
	.p2align 3
.L2026:
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	jmp	.L2038
	.p2align 4,,10
	.p2align 3
.L2041:
	movl	$7, %r8d
	jmp	.L2029
	.p2align 4,,10
	.p2align 3
.L2025:
	movq	$0, hrdbf_app_order(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	jmp	.L2028
.L2027:
	movl	$.LC60, %edi
	call	hrdbf_app_fail
.L2035:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
.L2037:
	movl	$.LC61, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata.str1.1
.LC62:
	.string	"table format not supported"
	.section	.rodata.str1.8
	.align 8
.LC63:
	.string	"hbc: DBF only one workarea is supported\n"
	.align 8
.LC64:
	.string	"hbc: DBF filename length outside supported range\n"
	.align 8
.LC65:
	.string	"hbc: DBF filename contains NUL\n"
	.section	.rodata.str1.1
.LC66:
	.string	"hbc: DBF index close failed\n"
	.section	.rodata.str1.8
	.align 8
.LC67:
	.string	"hbc: DBF open mode outside supported range\n"
	.section	.rodata.str1.1
.LC68:
	.string	"hbc: DBF open rejected: "
.LC69:
	.string	"\n"
	.text
	.p2align 4
	.globl	hrdbf_app_open
	.type	hrdbf_app_open, @function
hrdbf_app_open:
	endbr64
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	movq	%rdi, %r10
	movq	%rcx, %rbp
	testq	%rdx, %rdx
	je	.L2049
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.L2122
.L2049:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.L2123
	xorl	%r9d, %r9d
	jmp	.L2050
	.p2align 4,,10
	.p2align 3
.L2094:
	movq	%rbx, %r9
.L2050:
	movzbl	(%r10,%r9), %eax
	testb	%al, %al
	je	.L2124
	leaq	1(%r9), %rbx
	movb	%al, (%rsp,%r9)
	movq	%rsp, %r12
	cmpq	%rbx, %rsi
	jne	.L2094
	movq	hrdbf_app_order+32(%rip), %r14
	movb	$0, (%rsp,%rbx)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r14, %r14
	je	.L2125
	movl	$11, %r13d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r14, %rdi
	movq	%r13, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2126
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L2058
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r13, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2059
.L2060:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2058:
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movl	$0, hrdbf_app_found_flag(%rip)
	setne	%al
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	cmpq	$2, %r8
	ja	.L2127
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2063:
	movzbl	(%r10,%rdx), %esi
	movq	%rdx, %rcx
	addq	$1, %rdx
	cmpb	$47, %sil
	cmove	%rdx, %rax
	cmpq	%rcx, %r9
	jne	.L2063
	cmpq	%rbx, %rax
	jb	.L2066
	jmp	.L2128
	.p2align 4,,10
	.p2align 3
.L2095:
	movq	%rdx, %rax
.L2066:
	cmpb	$46, (%r10,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rbx
	cmpq	%r9, %rax
	jne	.L2095
	movq	%rbx, hrdbf_app_baselen(%rip)
	testq	%rbx, %rbx
	je	.L2067
.L2092:
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.L2069:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rbx, %rdx
	jb	.L2069
.L2067:
	movl	$hrdbf_app_state, %edi
	movb	$0, hrdbf_app_state+32977(%rip)
	movl	%r8d, %r10d
	call	hrdbf_file_close
	testl	%eax, %eax
	jne	.L2070
	movl	%r10d, %edx
	movq	%r12, %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L2070
	testq	%rbp, %rbp
	je	.L2048
	leaq	4(%rbx), %rax
	cmpq	$4095, %rax
	jbe	.L2129
.L2048:
	addq	$4096, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L2126:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2059
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r13, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2059
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2059:
	movl	$.LC66, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2125:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2058
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r14, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L2060
	jmp	.L2059
.L2129:
	movb	$46, (%rsp,%rbx)
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movq	$-100, %rdi
	movb	$99, 1(%rsp,%rbx)
	movl	$524288, %edx
	movb	$100, 2(%rsp,%rbx)
	movb	$120, 3(%rsp,%rbx)
	movb	$0, 4(%rsp,%rbx)
	.p2align 4,,10
	.p2align 3
.L2080:
	movq	%r9, %rax
	movq	%r12, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r8
	cmpq	$-4, %rax
	je	.L2080
	cmpq	$-2, %rax
	je	.L2048
	cmpq	$-20, %rax
	je	.L2048
	testq	%rax, %rax
	js	.L2081
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r8, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L2081:
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.L2082
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.L2048
.L2128:
	movq	%rbx, hrdbf_app_baselen(%rip)
	jmp	.L2092
.L2082:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.L2083
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r9, %rdi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2130
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L2088
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2086
.L2090:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2088:
	movl	$1, %esi
	movq	%r12, %rdi
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2086
	movl	$1, hrdbf_app_struct(%rip)
	addq	$5, %rbx
	xorl	%eax, %eax
.L2091:
	movzbl	(%r12,%rax), %edx
	addq	$1, %rax
	movb	%dl, hrdbf_app_ntxpath-1(%rax)
	cmpq	%rbx, %rax
	jne	.L2091
	jmp	.L2048
.L2130:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2086
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2086
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2086:
	movl	$3, hrdbf_app_struct(%rip)
	jmp	.L2048
.L2083:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2088
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L2090
	jmp	.L2086
.L2124:
	movl	$.LC65, %edi
	call	hrdbf_app_fail
.L2123:
	movl	$.LC64, %edi
	call	hrdbf_app_fail
.L2127:
	movl	$.LC67, %edi
	call	hrdbf_app_fail
.L2122:
	movl	$.LC63, %edi
	call	hrdbf_app_fail
.L2070:
	cmpb	$0, hrdbf_app_state+32977(%rip)
	movl	$hrdbf_app_state+32977, %r8d
	movl	$hrdbf_app_state+32778, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.L2073
	subl	$2, %eax
	movl	$.LC62, %r8d
	cmpl	$6, %eax
	ja	.L2073
	movq	CSWTCH.530(,%rax,8), %r8
.L2073:
	xorl	%edx, %edx
.L2074:
	addq	$1, %rdx
	cmpb	$0, .LC68(%rdx)
	jne	.L2074
	movl	$1, %eax
	movl	$2, %edi
	movl	$.LC68, %esi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.L2075
.L2076:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.L2076
.L2075:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC69, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrdbf_app_exit
	.size	hrdbf_app_open, .-hrdbf_app_open
	.section	.rodata.str1.1
.LC70:
	.string	"hbc: DBF no workarea is open\n"
	.text
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2138
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2133
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L2134
.L2133:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2134:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L2136
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.L2137:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2136:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.L2137
.L2138:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2148
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2141
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2141
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rdx
	testl	%esi, %esi
	jne	.L2149
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.L2145:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
.L2146:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%edx, %edx
	sete	%dl
.L2143:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%dl, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2149:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.L2145
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
	jmp	.L2146
	.p2align 4,,10
	.p2align 3
.L2141:
	movl	hrdbf_app_state+16(%rip), %edx
	movl	$1, %eax
	testl	%edx, %edx
	cmovne	%rdx, %rax
	sete	%dl
	movl	%edx, %ecx
	jmp	.L2143
.L2148:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	movq	%rdi, %rsi
	je	.L2165
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2152
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2152
	testq	%rdi, %rdi
	je	.L2150
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.L2155
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.L2161
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.L2156:
	movq	%rsi, hrdbf_app_pos(%rip)
.L2157:
	cmpq	%rax, %rsi
	jnb	.L2159
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.L2160:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.L2150:
	ret
	.p2align 4,,10
	.p2align 3
.L2152:
	movl	$hrdbf_app_state, %edi
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L2161:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.L2156
	.p2align 4,,10
	.p2align 3
.L2159:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.L2160
	.p2align 4,,10
	.p2align 3
.L2155:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.L2158
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	jmp	.L2157
	.p2align 4,,10
	.p2align 3
.L2158:
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.L2157
.L2165:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata.str1.8
	.align 8
.LC71:
	.string	"hbc: CDX direct character key field width must be <=240\n"
	.align 8
.LC72:
	.string	"hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\n"
	.align 8
.LC73:
	.string	"hbc: DBF index filename length outside supported range\n"
	.align 8
.LC74:
	.string	"hbc: DBF index filename contains NUL\n"
	.align 8
.LC75:
	.string	"hbc: structural CDX on a readonly=.F. open is outside this increment (index maintenance)\n"
	.align 8
.LC76:
	.string	"hbc: structural CDX present but not admitted (one tag, subset, size or format)\n"
	.align 8
.LC77:
	.string	"hbc: structural CDX on a shared=.T. open is outside this increment (index lock protocol)\n"
	.align 8
.LC78:
	.string	"hbc: DBF index on a shared=.T. open is outside this increment (index lock protocol)\n"
	.align 8
.LC79:
	.string	"hbc: DBF index only one index is supported\n"
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
	endbr64
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2229
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.L2230
	xorl	%edx, %edx
	xorl	%eax, %eax
	jmp	.L2168
	.p2align 4,,10
	.p2align 3
.L2200:
	movq	%rbx, %rax
.L2168:
	movzbl	(%rdi,%rax), %ecx
	testb	%cl, %cl
	je	.L2231
	leaq	1(%rax), %rbx
	cmpb	$47, %cl
	movb	%cl, (%rsp,%rax)
	cmove	%rbx, %rdx
	cmpq	%rbx, %rsi
	jne	.L2200
	movq	%rbx, %rcx
	xorl	%esi, %esi
	cmpq	%rbx, %rdx
	jnb	.L2171
	movl	$1, %r9d
	jmp	.L2173
	.p2align 4,,10
	.p2align 3
.L2202:
	movq	%r8, %rdx
.L2173:
	cmpb	$46, (%rdi,%rdx)
	leaq	1(%rdx), %r8
	cmove	%rdx, %rcx
	cmove	%r9d, %esi
	cmpq	%rax, %rdx
	jne	.L2202
.L2171:
	movl	hrdbf_app_cdx(%rip), %r9d
	testl	%r9d, %r9d
	jne	.L2232
.L2174:
	movl	hrdbf_app_shared(%rip), %edx
	testl	%edx, %edx
	jne	.L2233
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2234
	testl	%esi, %esi
	je	.L2235
.L2184:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, (%rsp,%rbx)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.L2186
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r10, %rdi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2236
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L2191
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2195
.L2193:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2191:
	movl	%r9d, %esi
	movq	%rsp, %rdi
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2237
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.L2196
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2197:
	movzbl	(%rsp,%rax), %edx
	movb	%dl, hrdbf_app_ntxpath(%rax)
	movq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rdx, %rbx
	jne	.L2197
.L2198:
	movl	$1, hrdbf_app_order_active(%rip)
	call	hrdbf_app_top
	addq	$4096, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2232:
	cmpq	%rcx, hrdbf_app_baselen(%rip)
	jne	.L2174
	testq	%rcx, %rcx
	je	.L2175
	movl	$1, %r10d
	xorl	%r8d, %r8d
	xorl	%r12d, %r12d
	.p2align 4,,10
	.p2align 3
.L2178:
	movzbl	(%rdi,%r8), %edx
	leal	-97(%rdx), %ebp
	leal	-32(%rdx), %r11d
	cmpb	$26, %bpl
	cmovb	%r11d, %edx
	cmpb	%dl, hrdbf_app_basename(%r8)
	cmovne	%r12d, %r10d
	addq	$1, %r8
	cmpq	%rcx, %r8
	jne	.L2178
	testl	%r10d, %r10d
	je	.L2174
.L2175:
	movl	hrdbf_app_struct(%rip), %edx
	cmpl	$1, %edx
	je	.L2198
	cmpl	$2, %edx
	je	.L2238
	cmpl	$3, %edx
	je	.L2239
	cmpl	$4, %edx
	jne	.L2174
	movl	$.LC77, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2235:
	cmpl	$1, %r9d
	movb	$46, (%rsp,%rbx)
	leaq	5(%rax), %rbx
	sbbl	%ecx, %ecx
	movb	$120, 4(%rsp,%rax)
	andl	$11, %ecx
	addl	$99, %ecx
	cmpl	$1, %r9d
	sbbl	%edx, %edx
	movb	%cl, 2(%rsp,%rax)
	andl	$16, %edx
	addl	$100, %edx
	movb	%dl, 3(%rsp,%rax)
	jmp	.L2184
	.p2align 4,,10
	.p2align 3
.L2236:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2195
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2195
	movq	$0, hrdbf_app_order+40(%rip)
	movl	$.LC72, %edi
	movq	$0, hrdbf_app_order+56(%rip)
.L2189:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2196:
	movb	$0, hrdbf_app_ntxpath(%rip)
	jmp	.L2198
	.p2align 4,,10
	.p2align 3
.L2186:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2191
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L2193
.L2195:
	movl	$.LC72, %edi
	jmp	.L2189
	.p2align 4,,10
	.p2align 3
.L2231:
	movl	$.LC74, %edi
	call	hrdbf_app_fail
.L2230:
	movl	$.LC73, %edi
	call	hrdbf_app_fail
.L2237:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L2195
	cmpl	$3, %eax
	jne	.L2195
	movl	$.LC71, %edi
	jmp	.L2189
.L2233:
	movl	$.LC78, %edi
	call	hrdbf_app_fail
.L2239:
	movl	$.LC76, %edi
	call	hrdbf_app_fail
.L2238:
	movl	$.LC75, %edi
	call	hrdbf_app_fail
.L2229:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
.L2234:
	movl	$.LC79, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2263
	movl	hrdbf_app_order+64(%rip), %eax
	movq	hrdbf_app_order+32(%rip), %rdi
	testl	%eax, %eax
	je	.L2242
	testq	%rdi, %rdi
	je	.L2243
	cmpq	$0, hrdbf_app_order+48(%rip)
	je	.L2244
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2245
	movq	hrdbf_app_order+32(%rip), %rdi
.L2242:
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.L2246
.L2255:
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2247
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L2252
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2253
.L2254:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2252:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2247:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2253
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2253
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2253:
	movl	$.LC66, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2243:
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
.L2246:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2252
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L2254
	jmp	.L2253
	.p2align 4,,10
	.p2align 3
.L2244:
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	jmp	.L2255
.L2245:
	movl	$.LC60, %edi
	call	hrdbf_app_fail
.L2263:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2266
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2266:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.LC80:
	.string	"hbc: DBF index seek requires an open index\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2274
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2269
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2269
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	leaq	12(%rsp), %r9
	setne	%r8b
	xorl	%ecx, %ecx
	testq	%rdx, %rdx
	movq	%rsi, %rdx
	setne	%cl
	movq	%rdi, %rsi
	movl	$hrdbf_app_order, %edi
	call	hrntx_seek
	movl	12(%rsp), %edx
	movl	hrdbf_app_order+24(%rip), %esi
	movl	%eax, %eax
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%rsi, %rcx
	movl	%edx, hrdbf_app_found_flag(%rip)
	cmpq	%rsi, %rax
	jb	.L2275
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.L2272:
	cmpq	%rsi, %rax
	movq	%rdi, hrdbf_app_state+24(%rip)
	movslq	%edx, %rax
	setnb	hrdbf_app_state+39(%rip)
	orl	hrdbf_app_cdx(%rip), %ecx
	sete	hrdbf_app_state+38(%rip)
	addq	$16, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2275:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.L2272
.L2269:
	movl	$.LC80, %edi
	call	hrdbf_app_fail
.L2274:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.section	.rodata.str1.8
	.align 8
.LC81:
	.string	"hbc: DBF index seek expects a character key value\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek_dyn
	.type	hrdbf_app_seek_dyn, @function
hrdbf_app_seek_dyn:
	endbr64
	pushq	%r12
	subq	$304, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2314
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2278
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2278
	movq	%rdi, %rax
	movq	%rdx, %r12
	movq	%rsi, %rdi
	movzbl	%al, %edx
	leal	-2(%rdx), %esi
	andl	$-3, %esi
	je	.L2315
	testl	%edx, %edx
	je	.L2293
	cmpl	$9, %edx
	je	.L2293
	cmpl	$5, %edx
	je	.L2316
	cmpl	$12, %edx
	je	.L2317
	movl	hrdbf_app_order+24(%rip), %ecx
	movl	hrdbf_app_state+16(%rip), %edx
	movl	$0, hrdbf_app_found_flag(%rip)
	movb	$1, hrdbf_app_state+39(%rip)
	movq	%rcx, %rax
	addq	$1, %rdx
	orl	hrdbf_app_cdx(%rip), %eax
	movq	%rcx, hrdbf_app_pos(%rip)
	sete	hrdbf_app_state+38(%rip)
	xorl	%eax, %eax
	movq	%rdx, hrdbf_app_state+24(%rip)
	addq	$304, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2315:
	testq	%rdi, %rdi
	je	.L2318
	movq	-8(%rdi), %rsi
	addq	$304, %rsp
	movq	%r12, %rdx
	popq	%r12
	jmp	hrdbf_app_seek
	.p2align 4,,10
	.p2align 3
.L2317:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rdi, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.L2291
	movsd	.LC0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.L2292:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.L2292
.L2291:
	comisd	.LC82(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	ja	.L2293
.L2313:
	movsd	.LC83(%rip), %xmm1
	addq	$1, %rdi
	comisd	%xmm0, %xmm1
	jbe	.L2319
.L2293:
	movzwl	hrdbf_app_order+28(%rip), %esi
	leaq	16(%rsp), %rdx
	movq	%rcx, 8(%rsp)
	call	hrdbf_app_pad_ll
	movq	8(%rsp), %rcx
	movq	%r12, %rdx
	leaq	16(%rsp), %rdi
	movq	%rax, %rsi
	call	hrdbf_app_seek
	addq	$304, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2316:
	testq	%rax, %rax
	js	.L2320
.L2286:
	movq	%rdi, %xmm0
	comisd	.LC82(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	ja	.L2293
	jmp	.L2313
	.p2align 4,,10
	.p2align 3
.L2319:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L2321
	addsd	.LC84(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2293
	.p2align 4,,10
	.p2align 3
.L2320:
	movq	(%rdi), %rdi
	jmp	.L2286
	.p2align 4,,10
	.p2align 3
.L2321:
	subsd	.LC84(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2293
.L2278:
	movl	$.LC80, %edi
	call	hrdbf_app_fail
.L2314:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
.L2318:
	movl	$.LC81, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek_dyn, .-hrdbf_app_seek_dyn
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2324
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.L2324:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2327
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.L2327:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_fcount
	.type	hrdbf_app_fcount, @function
hrdbf_app_fcount:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2330
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.L2330:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_fcount, .-hrdbf_app_fcount
	.p2align 4
	.globl	hrdbf_app_goto
	.type	hrdbf_app_goto, @function
hrdbf_app_goto:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2342
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %edx
	testq	%rdi, %rdi
	jle	.L2333
	xorl	%eax, %eax
	cmpq	%rdx, %rdi
	ja	.L2333
.L2334:
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rdi, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	je	.L2331
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2343
.L2331:
	ret
	.p2align 4,,10
	.p2align 3
.L2333:
	leaq	1(%rdx), %rdi
	movl	$1, %eax
	jmp	.L2334
	.p2align 4,,10
	.p2align 3
.L2343:
	movl	hrdbf_app_order+24(%rip), %ecx
	testl	%ecx, %ecx
	je	.L2340
	movq	hrdbf_app_order+16(%rip), %rsi
	xorl	%eax, %eax
	jmp	.L2338
	.p2align 4,,10
	.p2align 3
.L2337:
	addq	$1, %rax
	cmpq	%rcx, %rax
	je	.L2336
.L2338:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.L2337
.L2336:
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2340:
	xorl	%eax, %eax
	jmp	.L2336
.L2342:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_goto, .-hrdbf_app_goto
	.p2align 4
	.globl	hrdbf_app_ordselect
	.type	hrdbf_app_ordselect, @function
hrdbf_app_ordselect:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2359
	testq	%rdi, %rdi
	jle	.L2346
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2360
	cmpq	$1, %rdi
	jne	.L2346
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %rdi
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %rsi
	testl	%ecx, %ecx
	jne	.L2352
	jmp	.L2361
	.p2align 4,,10
	.p2align 3
.L2351:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2354
.L2352:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.L2351
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2360:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.L2362
	cmpl	$3, %eax
	je	.L2363
	cmpl	$4, %eax
	je	.L2364
.L2346:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.L2361:
	xorl	%ecx, %ecx
.L2354:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2359:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
.L2362:
	movl	$.LC75, %edi
	call	hrdbf_app_fail
.L2364:
	movl	$.LC77, %edi
	call	hrdbf_app_fail
.L2363:
	movl	$.LC76, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_ordselect, .-hrdbf_app_ordselect
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2367
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.L2367:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2370
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.L2370:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2375
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2371
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2371:
	movq	%r8, %rax
	ret
.L2375:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_deleted, .-hrdbf_app_deleted
	.p2align 4
	.globl	hrdbf_app_get
	.type	hrdbf_app_get, @function
hrdbf_app_get:
	endbr64
	subq	$8, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2382
	testq	%rdi, %rdi
	jle	.L2380
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.L2383
.L2380:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2383:
	call	hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.L2382:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get, .-hrdbf_app_get
	.p2align 4
	.globl	hrdbf_app_get_name
	.type	hrdbf_app_get_name, @function
hrdbf_app_get_name:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	je	.L2385
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.L2387
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L2398:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2388:
	cmpb	$0, (%rsi,%rax)
	je	.L2389
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2388
.L2389:
	cmpq	%rax, %r9
	je	.L2410
.L2391:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.L2398
.L2387:
	movl	$1, %ebx
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbx, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rbx, %rax
	movq	%r10, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC69, %esi
	movq	%rbx, %rax
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.L2410:
	testq	%r9, %r9
	je	.L2392
	xorl	%ecx, %ecx
	jmp	.L2396
	.p2align 4,,10
	.p2align 3
.L2411:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.L2392
.L2396:
	movzbl	(%r10,%rcx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %edx
	cmpb	$26, %dil
	cmovb	%edx, %eax
	movzbl	(%rsi,%rcx), %edx
	leal	-97(%rdx), %r8d
	leal	-32(%rdx), %edi
	cmpb	$26, %r8b
	cmovb	%edi, %edx
	cmpb	%al, %dl
	je	.L2411
	cmpq	%rcx, %r9
	jne	.L2391
	.p2align 4,,10
	.p2align 3
.L2392:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.L2412
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.L2412:
	movq	%r12, %rsi
	call	hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.L2385:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata.str1.8
	.align 8
.LC85:
	.string	"hbc: DBF field write requires a readonly=.F. open\n"
	.align 8
.LC86:
	.string	"hbc: DBF field ordinal outside the open area\n"
	.align 8
.LC87:
	.string	"hbc: DBF field write type mismatch\n"
	.align 8
.LC88:
	.string	"hbc: DBF field write encoding rejected\n"
	.align 8
.LC89:
	.string	"hbc: DBF field write commit failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_fieldput
	.type	hrdbf_app_fieldput, @function
hrdbf_app_fieldput:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	pushq	%rbx
	je	.L2478
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.L2479
	movq	%rdi, %rbx
	testq	%rdi, %rdi
	jle	.L2416
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rdi, %rax
	jl	.L2416
	movq	%rsi, %rcx
	leaq	1(%rdi), %rax
	leaq	-1(%rdi), %r11
	movq	%rdx, %r8
	movq	hrdbf_app_state+24(%rip), %rsi
	movzwl	hrdbf_app_state+34(%rip), %edi
	salq	$4, %rax
	movzbl	%cl, %r9d
	leaq	hrdbf_app_state+10(%rax), %r10
	addq	$hrdbf_app_state, %rax
	leaq	-1(%rsi), %rdx
	imulq	%rdi, %rdx
	movzwl	hrdbf_app_state+32(%rip), %edi
	addq	%rdi, %rdx
	movq	hrdbf_app_state+32944(%rip), %rdi
	addq	%rdx, %rdi
	movzbl	21(%rax), %edx
	cmpb	$76, %dl
	je	.L2418
	ja	.L2419
	cmpb	$67, %dl
	je	.L2420
	cmpb	$68, %dl
	jne	.L2422
	cmpl	$11, %r9d
	je	.L2480
	cmpl	$1, %r9d
	jne	.L2422
	salq	$4, %r11
	movzbl	hrdbf_app_state+54(%r11), %ecx
	movzwl	hrdbf_app_state+56(%r11), %edx
	testl	%ecx, %ecx
	je	.L2431
	addq	%rdi, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2442
	.p2align 4,,10
	.p2align 3
.L2481:
	addq	$1, %rax
.L2442:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rcx, %rax
	jne	.L2481
.L2427:
	movq	hrdbf_app_state+24(%rip), %rsi
.L2431:
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2482
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2413
	movzwl	hrdbf_app_order+30(%rip), %eax
	addq	$1, %rax
	cmpq	%rbx, %rax
	je	.L2483
.L2413:
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L2419:
	cmpb	$78, %dl
	jne	.L2422
	cmpl	$12, %r9d
	je	.L2484
	testl	%r9d, %r9d
	je	.L2451
	cmpl	$9, %r9d
	je	.L2451
	cmpl	$5, %r9d
	je	.L2485
	cmpl	$1, %r9d
	jne	.L2422
	salq	$4, %r11
	movzbl	hrdbf_app_state+54(%r11), %ecx
	movzwl	hrdbf_app_state+56(%r11), %edx
	testl	%ecx, %ecx
	je	.L2431
	addq	%rdi, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2440
	.p2align 4,,10
	.p2align 3
.L2486:
	addq	$1, %rax
.L2440:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rax, %rcx
	jne	.L2486
	jmp	.L2427
	.p2align 4,,10
	.p2align 3
.L2420:
	leal	-2(%r9), %edx
	andl	$-3, %edx
	je	.L2487
	cmpl	$1, %r9d
	jne	.L2422
	movzbl	22(%rax), %ecx
	movzwl	24(%rax), %edx
	testl	%ecx, %ecx
	je	.L2431
	addq	%rdi, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2432
	.p2align 4,,10
	.p2align 3
.L2488:
	addq	$1, %rax
.L2432:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rcx, %rax
	jne	.L2488
	jmp	.L2427
	.p2align 4,,10
	.p2align 3
.L2418:
	cmpl	$3, %r9d
	je	.L2489
	cmpl	$1, %r9d
	jne	.L2422
	movzbl	22(%rax), %ecx
	movzwl	24(%rax), %edx
	testl	%ecx, %ecx
	je	.L2431
	addq	%rdi, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2445
	.p2align 4,,10
	.p2align 3
.L2490:
	addq	$1, %rax
.L2445:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rcx, %rax
	jne	.L2490
	jmp	.L2427
	.p2align 4,,10
	.p2align 3
.L2483:
	popq	%rbx
	jmp	hrdbf_app_rebuild_index
	.p2align 4,,10
	.p2align 3
.L2489:
	cmpq	$1, %r8
	movzwl	24(%rax), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	movq	hrdbf_app_state+24(%rip), %rsi
	jmp	.L2431
	.p2align 4,,10
	.p2align 3
.L2487:
	movzbl	22(%rax), %edx
	movzwl	24(%rax), %ecx
	movq	-8(%r8), %rax
	addq	%rdi, %rcx
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rax, %rax
	je	.L2425
	movq	%rcx, %rsi
	leaq	(%r8,%rax), %rdi
	subq	%r8, %rsi
	.p2align 4,,10
	.p2align 3
.L2426:
	movzbl	(%r8), %edx
	movb	%dl, (%rsi,%r8)
	addq	$1, %r8
	cmpq	%rdi, %r8
	jne	.L2426
	movq	%r11, %rdx
	salq	$4, %rdx
	movzbl	hrdbf_app_state+54(%rdx), %edx
.L2425:
	cmpq	%rdx, %rax
	jnb	.L2427
	salq	$4, %r11
	leaq	hrdbf_app_state+32(%r11), %rsi
	.p2align 4,,10
	.p2align 3
.L2428:
	movb	$32, (%rcx,%rax)
	movzbl	22(%rsi), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2428
	jmp	.L2427
	.p2align 4,,10
	.p2align 3
.L2484:
	movzbl	%ch, %ecx
	movq	%r8, %rdx
	movq	%r10, %rsi
	call	hrdbf_write_number_scaled.part.0
.L2434:
	cmpl	$3, %eax
	je	.L2422
	testl	%eax, %eax
	je	.L2427
	movl	$.LC88, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2480:
	movl	%r8d, %edx
	movq	%r10, %rsi
	call	hrdbf_write_date
	jmp	.L2434
	.p2align 4,,10
	.p2align 3
.L2451:
	xorl	%ecx, %ecx
	movq	%r8, %rdx
	movq	%r10, %rsi
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2434
	.p2align 4,,10
	.p2align 3
.L2485:
	testq	%rcx, %rcx
	jns	.L2438
	movq	(%r8), %r8
.L2438:
	movq	%r8, %xmm0
	movq	%r10, %rsi
	call	hrdbf_write_number_double.part.0
	jmp	.L2434
.L2422:
	movl	$.LC87, %edi
	call	hrdbf_app_fail
.L2416:
	movl	$.LC86, %edi
	call	hrdbf_app_fail
.L2478:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
.L2479:
	movl	$.LC85, %edi
	call	hrdbf_app_fail
.L2482:
	movl	$.LC89, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_fieldput, .-hrdbf_app_fieldput
	.section	.rodata.str1.8
	.align 8
.LC90:
	.string	"hbc: DBF delete/recall requires a readonly=.F. open\n"
	.align 8
.LC91:
	.string	"hbc: DBF delete commit failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_delete
	.type	hrdbf_app_delete, @function
hrdbf_app_delete:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2498
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.L2499
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.L2500
.L2491:
	ret
	.p2align 4,,10
	.p2align 3
.L2500:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	movl	$hrdbf_app_state, %edi
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$42, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rsi
	call	hrdbf_file_write_record
	testl	%eax, %eax
	je	.L2491
	movl	$.LC91, %edi
	call	hrdbf_app_fail
.L2499:
	movl	$.LC90, %edi
	call	hrdbf_app_fail
.L2498:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_delete, .-hrdbf_app_delete
	.section	.rodata.str1.8
	.align 8
.LC92:
	.string	"hbc: DBF recall commit failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_recall
	.type	hrdbf_app_recall, @function
hrdbf_app_recall:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2508
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.L2509
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.L2510
.L2501:
	ret
	.p2align 4,,10
	.p2align 3
.L2510:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	movl	$hrdbf_app_state, %edi
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$32, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rsi
	call	hrdbf_file_write_record
	testl	%eax, %eax
	je	.L2501
	movl	$.LC92, %edi
	call	hrdbf_app_fail
.L2509:
	movl	$.LC90, %edi
	call	hrdbf_app_fail
.L2508:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_recall, .-hrdbf_app_recall
	.p2align 4
	.globl	hrdbf_app_commit
	.type	hrdbf_app_commit, @function
hrdbf_app_commit:
	endbr64
	ret
	.size	hrdbf_app_commit, .-hrdbf_app_commit
	.p2align 4
	.globl	hrdbf_app_set_name
	.type	hrdbf_app_set_name, @function
hrdbf_app_set_name:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	je	.L2536
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.L2514
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	testl	%ebx, %ebx
	je	.L2516
	movq	%rdx, %rbp
	movq	%rcx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L2526:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2517:
	cmpb	$0, (%rsi,%rax)
	je	.L2518
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2517
.L2518:
	cmpq	%rax, %r9
	je	.L2537
.L2520:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.L2526
.L2516:
	movl	$1, %ebx
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbx, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rbx, %rax
	movq	%r10, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC69, %esi
	movq	%rbx, %rax
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.L2537:
	testq	%r9, %r9
	je	.L2521
	xorl	%ecx, %ecx
	jmp	.L2525
	.p2align 4,,10
	.p2align 3
.L2538:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.L2521
.L2525:
	movzbl	(%r10,%rcx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %edx
	cmpb	$26, %dil
	cmovb	%edx, %eax
	movzbl	(%rsi,%rcx), %edx
	leal	-97(%rdx), %r8d
	leal	-32(%rdx), %edi
	cmpb	$26, %r8b
	cmovb	%edi, %edx
	cmpb	%al, %dl
	je	.L2538
	cmpq	%rcx, %r9
	jne	.L2520
.L2521:
	popq	%rbx
	movq	%r12, %rdx
	leal	1(%r11), %edi
	movq	%rbp, %rsi
	popq	%rbp
	popq	%r12
	jmp	hrdbf_app_fieldput
.L2514:
	movl	$.LC85, %edi
	call	hrdbf_app_fail
.L2536:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_set_name, .-hrdbf_app_set_name
	.section	.rodata.str1.1
.LC93:
	.string	"hbc: DBF append failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_append
	.type	hrdbf_app_append, @function
hrdbf_app_append:
	endbr64
	subq	$24, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2545
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.L2546
	cmpb	$0, hrdbf_app_state+32976(%rip)
	je	.L2543
	leaq	12(%rsp), %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2543
	movl	$0, hrdbf_app_found_flag(%rip)
	call	hrdbf_app_rebuild_index
	movl	12(%rsp), %eax
	addq	$24, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2543:
	movl	$.LC93, %edi
	call	hrdbf_app_fail
.L2545:
	movl	$.LC70, %edi
	call	hrdbf_app_fail
.L2546:
	movl	$.LC85, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_append, .-hrdbf_app_append
	.section	.rodata.str1.8
	.align 8
.LC94:
	.string	"hbc: DBF scalar render rejected\n"
	.text
	.p2align 4
	.globl	hrdbf_app_render
	.type	hrdbf_app_render, @function
hrdbf_app_render:
	endbr64
	subq	$24, %rsp
	movl	$256, %ecx
	movq	$0, 8(%rsp)
	leaq	8(%rsp), %r8
	call	hrv_render
	testl	%eax, %eax
	jne	.L2550
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.L2550:
	movl	$.LC94, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.LC95:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.LC96:
	.string	"hbc: DBF scalar cannot enter I64 operation\n"
	.text
	.p2align 4
	.globl	hrdbf_app_integer
	.type	hrdbf_app_integer, @function
hrdbf_app_integer:
	endbr64
	subq	$8, %rsp
	movq	%rdi, %r9
	movq	%rsi, %r10
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2552
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L2568
	testl	%eax, %eax
	je	.L2560
	cmpl	$9, %eax
	jne	.L2556
.L2560:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2568:
	testl	$65280, %r9d
	je	.L2560
.L2555:
	movl	$.LC95, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2552:
	cmpl	$2, %eax
	je	.L2555
.L2556:
	movl	$.LC96, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.LC97:
	.string	"hbc: DBF scalar comparison is outside this increment\n"
	.text
	.p2align 4
	.globl	hrdbf_app_equal
	.type	hrdbf_app_equal, @function
hrdbf_app_equal:
	endbr64
	subq	$24, %rsp
	leaq	12(%rsp), %r8
	call	hrv_equal
	testl	%eax, %eax
	jne	.L2572
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.L2572:
	movl	$.LC97, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.LC98:
	.string	"hbc: DBF invalid Date comparison\n"
	.text
	.p2align 4
	.globl	hrdbf_app_compare
	.type	hrdbf_app_compare, @function
hrdbf_app_compare:
	endbr64
	subq	$40, %rsp
	movq	%rsi, %r9
	cmpb	$11, %dil
	jne	.L2574
	cmpb	$11, %dl
	je	.L2581
.L2574:
	leaq	24(%rsp), %r8
	movq	%r9, %rsi
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2582
	movq	24(%rsp), %rax
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2581:
	movq	%rcx, 8(%rsp)
	movq	%rdx, (%rsp)
	call	hrv_validate
	movq	(%rsp), %rdx
	movq	8(%rsp), %rcx
	testl	%eax, %eax
	jne	.L2576
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	%rcx, (%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2576
	movq	(%rsp), %rcx
	xorl	%eax, %eax
	movq	$-1, %rdx
	cmpq	%rcx, %r9
	seta	%al
	cmovb	%rdx, %rax
	addq	$40, %rsp
	ret
.L2582:
	movl	$.LC97, %edi
	call	hrdbf_app_fail
.L2576:
	movl	$.LC98, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.LC99:
	.string	"hbc: DBF scalar Empty rejected\n"
	.text
	.p2align 4
	.globl	hrdbf_app_empty
	.type	hrdbf_app_empty, @function
hrdbf_app_empty:
	endbr64
	movzbl	%dil, %r10d
	movq	%rsi, %r9
	leal	-2(%r10), %eax
	andl	$-3, %eax
	jne	.L2584
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.L2594
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.L2586
	.p2align 4,,10
	.p2align 3
.L2606:
	btq	%rax, %rcx
	jc	.L2598
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.L2594
.L2586:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.L2606
.L2598:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2584:
	cmpl	$8, %r10d
	je	.L2607
	cmpl	$5, %r10d
	je	.L2608
	cmpl	$7, %r10d
	je	.L2598
	subq	$8, %rsp
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2591
	cmpl	$12, %r10d
	ja	.L2591
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.L2592
	cmpl	$1, %r10d
	je	.L2599
.L2591:
	movl	$.LC99, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2594:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2607:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L2603
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.L2603:
	ret
	.p2align 4,,10
	.p2align 3
.L2608:
	testq	%rdi, %rdi
	js	.L2609
.L2590:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.LC47(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.L2609:
	movq	(%rsi), %r9
	jmp	.L2590
.L2592:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.L2583:
	addq	$8, %rsp
	ret
.L2599:
	movl	$1, %eax
	jmp	.L2583
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.LC100:
	.string	"hbc: DBF arithmetic division by zero\n"
	.align 8
.LC101:
	.string	"hbc: DBF arithmetic on a NIL or non-numeric operand\n"
	.section	.rodata.str1.1
.LC102:
	.string	"hbc: DBF arithmetic rejected\n"
	.text
	.p2align 4
	.globl	hrdbf_app_arith
	.type	hrdbf_app_arith, @function
hrdbf_app_arith:
	endbr64
	subq	$24, %rsp
	movq	%rsp, %r9
	call	hrv_arith
	cmpl	$5, %eax
	je	.L2615
	cmpl	$1, %eax
	je	.L2616
	testl	%eax, %eax
	jne	.L2617
	movq	(%rsp), %rax
	movq	8(%rsp), %rdx
	addq	$24, %rsp
	ret
.L2615:
	movl	$.LC100, %edi
	call	hrdbf_app_fail
.L2617:
	movl	$.LC102, %edi
	call	hrdbf_app_fail
.L2616:
	movl	$.LC101, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_arith, .-hrdbf_app_arith
	.section	.rodata.str1.8
	.align 8
.LC103:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
	endbr64
	movl	$.LC103, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.8
	.align 8
.LC104:
	.string	"unsupported table version or header flags"
	.section	.rodata.str1.1
.LC105:
	.string	"unsupported field type"
	.section	.rodata.str1.8
	.align 8
.LC106:
	.string	"size or field-count limit exceeded"
	.section	.rodata.str1.1
.LC107:
	.string	"record content invalid"
.LC108:
	.string	"I/O error"
.LC109:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	CSWTCH.530, @object
	.size	CSWTCH.530, 56
CSWTCH.530:
	.quad	.LC104
	.quad	.LC105
	.quad	.LC106
	.quad	.LC107
	.quad	.LC62
	.quad	.LC108
	.quad	.LC109
	.align 32
	.type	CSWTCH.495, @object
	.size	CSWTCH.495, 40
CSWTCH.495:
	.long	28
	.long	31
	.long	30
	.long	31
	.long	30
	.long	31
	.long	31
	.long	30
	.long	31
	.long	30
	.section	.rodata.str1.1
.LC110:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.LC111:
	.string	"DBF value type outside admitted operation"
	.align 8
.LC112:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.LC113:
	.string	"DBF value output buffer too short"
	.align 8
.LC114:
	.string	"DBF value tag or metadata invalid"
	.align 8
.LC115:
	.string	"DBF arithmetic division by zero"
	.section	.rodata
	.align 32
	.type	CSWTCH.486, @object
	.size	CSWTCH.486, 48
CSWTCH.486:
	.quad	.LC110
	.quad	.LC111
	.quad	.LC112
	.quad	.LC113
	.quad	.LC114
	.quad	.LC115
	.align 8
	.type	CSWTCH.459, @object
	.size	CSWTCH.459, 13
CSWTCH.459:
	.byte	78
	.byte	85
	.byte	67
	.byte	76
	.byte	67
	.byte	78
	.byte	65
	.byte	66
	.byte	65
	.byte	78
	.byte	63
	.byte	68
	.byte	78
	.align 32
	.type	days.0, @object
	.size	days.0, 48
days.0:
	.long	31
	.long	28
	.long	31
	.long	30
	.long	31
	.long	30
	.long	31
	.long	31
	.long	30
	.long	31
	.long	30
	.long	31
	.align 8
	.type	days.1, @object
	.size	days.1, 12
days.1:
	.ascii	"\037\034\037\036\037\036\037\037\036\037\036\037"
	.align 32
	.type	hrdbf_app_pre_field, @object
	.size	hrdbf_app_pre_field, 44
hrdbf_app_pre_field:
	.string	"hbc: DBF field not found in the open area: "
	.local	hrdbf_app_shared
	.comm	hrdbf_app_shared,4,4
	.local	hrdbf_app_struct
	.comm	hrdbf_app_struct,4,4
	.local	hrdbf_app_ntxpath
	.comm	hrdbf_app_ntxpath,4096,32
	.local	hrdbf_app_baselen
	.comm	hrdbf_app_baselen,8,8
	.local	hrdbf_app_basename
	.comm	hrdbf_app_basename,4096,32
	.local	hrdbf_app_cdx
	.comm	hrdbf_app_cdx,4,4
	.local	hrdbf_app_order_active
	.comm	hrdbf_app_order_active,4,4
	.local	hrdbf_app_found_flag
	.comm	hrdbf_app_found_flag,4,4
	.local	hrdbf_app_pos
	.comm	hrdbf_app_pos,8,8
	.local	hrdbf_app_order
	.comm	hrdbf_app_order,72,32
	.local	hrdbf_app_state
	.comm	hrdbf_app_state,33144,32
	.local	hrdbf_open_tmp
	.comm	hrdbf_open_tmp,32944,32
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC0:
	.long	0
	.long	1076101120
	.align 8
.LC47:
	.long	0
	.long	0
	.align 8
.LC82:
	.long	-798530048
	.long	1138748221
	.align 8
.LC83:
	.long	-798530048
	.long	-1008735427
	.align 8
.LC84:
	.long	0
	.long	1071644672
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
