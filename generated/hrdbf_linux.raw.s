	.file	"hrdbf_embedded_linux.c"
	.text
	.p2align 4
	.type	dcat, @function
dcat:
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	jmp	.L2
	.p2align 4,,10
	.p2align 3
.L4:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.L3
.L2:
	cmpb	$0, (%rax)
	jne	.L4
	jmp	.L8
	.p2align 4,,10
	.p2align 3
.L6:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.L8:
	cmpq	%rax, %rdi
	jbe	.L3
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L6
.L3:
	movb	$0, (%rax)
	ret
	.size	dcat, .-dcat
	.p2align 4
	.type	hrv_to_double, @function
hrv_to_double:
	movl	%edi, %eax
	movq	%rsi, %r9
	andl	$255, %eax
	je	.L20
	cmpl	$9, %eax
	je	.L20
	cmpl	$12, %eax
	je	.L25
	movl	$1, %r8d
	cmpl	$5, %eax
	je	.L26
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L20:
	pxor	%xmm0, %xmm0
	xorl	%r8d, %r8d
	cvtsi2sdq	%rsi, %xmm0
	movl	%r8d, %eax
	movsd	%xmm0, (%rdx)
	movl	$0, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L26:
	testq	%rdi, %rdi
	js	.L27
	shrq	$8, %rdi
	movl	$2, %eax
	testl	%edi, %edi
	cmove	%eax, %edi
.L18:
	xorl	%r8d, %r8d
	movq	%r9, (%rdx)
	movl	%r8d, %eax
	movl	%edi, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L25:
	movl	%edi, %eax
	pxor	%xmm0, %xmm0
	andl	$65280, %edi
	movzbl	%ah, %eax
	cvtsi2sdq	%rsi, %xmm0
	movl	%eax, %r8d
	je	.L15
	movsd	.LC0(%rip), %xmm1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L16:
	divsd	%xmm1, %xmm0
	addl	$1, %eax
	cmpl	%r8d, %eax
	jne	.L16
.L15:
	movsd	%xmm0, (%rdx)
	movl	%r8d, (%rcx)
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L27:
	movq	(%rsi), %r9
	movzwl	8(%rsi), %edi
	jmp	.L18
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
	ja	.L28
	movl	%esi, %ebp
	movq	%rdi, %rdx
	movl	%esi, %r9d
	andl	$31, %ebp
	je	.L31
	testl	%r12d, %r12d
	je	.L32
	movl	$32, %r11d
	leal	-1(%r12), %ecx
	movq	%rdi, %rax
	xorl	%r8d, %r8d
	subl	%ebp, %r11d
	leaq	4(%rdi,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.L33:
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
	jne	.L33
	testl	%edi, %edi
	je	.L37
	leal	1(%r12), %eax
	movl	%eax, 288(%rdx)
	movl	%edi, (%rdx,%r12,4)
.L37:
	cmpl	$31, %r9d
	jbe	.L28
	movl	288(%rdx), %r8d
	leal	-1(%r8), %ecx
	addl	%r10d, %r8d
	jmp	.L42
	.p2align 4,,10
	.p2align 3
.L31:
	cmpl	$31, %esi
	jbe	.L28
	leal	-1(%r12), %ecx
	testl	%r12d, %r12d
	je	.L35
.L42:
	movl	%ecx, %eax
	addl	%r10d, %ecx
	leaq	(%rdx,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.L38:
	movl	(%rax), %edi
	movl	%ecx, %esi
	subl	$1, %ecx
	movl	%edi, (%rdx,%rsi,4)
	movq	%rax, %rsi
	subq	$4, %rax
	cmpq	%rdx, %rsi
	jne	.L38
.L35:
	testl	%r10d, %r10d
	je	.L41
	leal	-1(%r10), %ecx
	movq	%rdx, %rax
	leaq	4(%rdx,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L40:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rcx
	jne	.L40
.L41:
	movl	%r8d, 288(%rdx)
.L28:
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L32:
	cmpl	$31, %esi
	jbe	.L28
	movl	%r10d, %r8d
	jmp	.L35
	.size	bn_shl, .-bn_shl
	.p2align 4
	.type	bn_divmod_1e9, @function
bn_divmod_1e9:
	pushq	%rbx
	movl	288(%rdi), %ebx
	testl	%ebx, %ebx
	je	.L61
	movabsq	$19342813113834067, %r11
	movq	%rdi, %r9
	leal	-1(%rbx), %edi
	movl	%edi, %eax
	leaq	(%r9,%rax,4), %r8
	xorl	%eax, %eax
	movq	%r8, %rcx
	.p2align 4,,10
	.p2align 3
.L58:
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
	jne	.L58
	cmpl	$1, %ebx
	jne	.L59
	jmp	.L56
	.p2align 4,,10
	.p2align 3
.L60:
	movl	%edi, 288(%r9)
	subq	$4, %r8
	subl	$1, %edi
	je	.L56
.L59:
	movl	(%r8), %edx
	testl	%edx, %edx
	je	.L60
.L56:
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L61:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.size	bn_divmod_1e9, .-bn_divmod_1e9
	.p2align 4
	.type	fset, @function
fset:
	leaq	2289(%rdi), %rax
	addq	$2448, %rdi
	jmp	.L69
	.p2align 4,,10
	.p2align 3
.L71:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.L70
.L69:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L71
.L70:
	movb	$0, (%rax)
	ret
	.size	fset, .-fset
	.p2align 4
	.type	fcat, @function
fcat:
	leaq	2289(%rdi), %rax
	addq	$2448, %rdi
	jmp	.L73
	.p2align 4,,10
	.p2align 3
.L75:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.L74
.L73:
	cmpb	$0, (%rax)
	jne	.L75
	jmp	.L79
	.p2align 4,,10
	.p2align 3
.L77:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.L79:
	cmpq	%rax, %rdi
	jbe	.L74
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L77
.L74:
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
	ja	.L84
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.L84
	testl	$1023, %esi
	jne	.L84
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.L84
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
	jne	.L84
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.L84
	testw	%r13w, %r13w
	jne	.L108
	testl	%esi, %esi
	je	.L108
	.p2align 4,,10
	.p2align 3
.L84:
	movl	$1, %eax
.L80:
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
.L108:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.L89:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.L84
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.L84
	testw	%r11w, %r11w
	je	.L86
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.L88:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.L87
	cmpl	%r10d, %edx
	jl	.L84
.L87:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.L88
.L86:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.L89
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.L90
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.L124
	cmpl	%esi, %eax
	jne	.L84
.L90:
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
.L104:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.L84
	testl	%r15d, %r15d
	jne	.L92
.L95:
	cmpq	%r13, 8(%rsp)
	je	.L93
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.L97
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.L97
	cmpl	36(%rbp), %edx
	jbe	.L97
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
	jne	.L97
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
	je	.L98
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.L99
	.p2align 4,,10
	.p2align 3
.L126:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.L125
.L99:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.L126
.L97:
	movl	$4, %eax
	jmp	.L80
.L92:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call	nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.L95
	jmp	.L80
	.p2align 4,,10
	.p2align 3
.L125:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.L107
.L123:
	movq	16(%rdi), %rsi
.L102:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.L104
.L93:
	xorl	%eax, %eax
	jmp	.L80
.L124:
	movl	%esi, 40(%rbp)
	jmp	.L90
.L107:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.L103
.L101:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.L105
.L103:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.L101
	jb	.L102
	jmp	.L84
.L98:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.L123
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.L105:
	cmpl	%r11d, %eax
	ja	.L102
	jmp	.L84
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
	ja	.L127
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.L127
	testl	$1023, %edx
	jne	.L127
	testq	%rbp, %rbp
	je	.L127
	cmpb	$0, 40(%rbp)
	je	.L127
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.L127
	cmpw	$0, 16(%rsi)
	jne	.L127
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.L130
	.p2align 4,,10
	.p2align 3
.L129:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.L191
.L130:
	cmpq	$11, %rcx
	jbe	.L129
	cmpb	$0, 538(%rax,%rcx)
	je	.L129
.L163:
	movl	$2, %r10d
.L127:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L191:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.L127
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.L127
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.L127
	movl	%esi, %ecx
	shrw	%cx
	cmpw	20(%rax), %cx
	jne	.L127
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.L131
	jmp	.L127
	.p2align 4,,10
	.p2align 3
.L132:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.L163
.L131:
	cmpb	$0, 22(%rax,%r12)
	jne	.L132
	testq	%r12, %r12
	je	.L163
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.L163
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.L133:
	xorl	%esi, %esi
	jmp	.L142
	.p2align 4,,10
	.p2align 3
.L192:
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
	jne	.L135
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.L134
	cmpq	$10, %rsi
	ja	.L134
.L142:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.L192
.L135:
	cmpq	%r12, %rsi
	je	.L147
.L139:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.L133
	jmp	.L163
.L134:
	cmpq	%r12, %rsi
	jne	.L139
	cmpq	$11, %rsi
	je	.L140
.L147:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.L139
.L140:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.L163
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.L127
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.L127
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.L169
	testq	%r8, %r8
	jne	.L170
	testl	%ecx, %ecx
	jne	.L169
.L170:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.L169
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.L169
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.L144:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.L144
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
	jne	.L145
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.L146
	movl	$4, %r10d
.L145:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L127
.L146:
	movl	%eax, 24(%rbx)
	jmp	.L127
.L169:
	movl	$3, %r10d
	jmp	.L127
	.size	hrntx_open, .-hrntx_open
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
	jne	.L199
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.L201
.L199:
	movl	$1, %eax
.L193:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.L201:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.L193
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.L193
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.L193
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.L199
	cmpl	%edi, %r12d
	jb	.L199
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.L193
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
	je	.L203
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L204:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.L204
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
	jne	.L205
	testl	%edx, %edx
	je	.L205
.L207:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L205:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.L207
.L213:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.L207
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.L207
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.L208
	xorl	%eax, %eax
	jmp	.L209
	.p2align 4,,10
	.p2align 3
.L226:
	movq	(%r9), %rcx
.L209:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.L226
.L208:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.L212
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L211:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L211
.L212:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L203:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.L213
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
	je	.L230
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.L282
.L230:
	movl	$1, %r12d
.L227:
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
.L282:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.L230
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.L230
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
	jne	.L230
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
	je	.L231
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.L230
.L231:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.L283
	cmpl	%r8d, %ecx
	jne	.L230
	cmpl	%eax, 312(%rdx)
	jne	.L230
.L253:
	cmpl	$-1, %r9d
	je	.L235
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.L230
	testl	$511, %r9d
	jne	.L230
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.L230
.L235:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.L236
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.L284
	cmpl	%esi, %eax
	jne	.L230
.L238:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call	cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L227
	testl	%r14d, %r14d
	je	.L248
	movl	%r15d, %ecx
.L239:
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
	jne	.L258
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.L241
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.L241
	cmpl	48(%rbx), %eax
	jbe	.L241
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
	jne	.L241
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
	je	.L242
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.L243
.L286:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.L285
	movq	%rdx, %rax
.L243:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.L286
.L241:
	movl	$4, %r12d
	jmp	.L227
	.p2align 4,,10
	.p2align 3
.L283:
	cmpl	$-1, %r8d
	jne	.L230
	jmp	.L253
.L236:
	testl	%r14d, %r14d
	je	.L230
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.L230
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.L251:
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
	jne	.L279
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.L230
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
	jne	.L230
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.L249
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.L250
	.p2align 4,,10
	.p2align 3
.L287:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L249
.L250:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.L287
	jmp	.L230
.L284:
	movl	%esi, 52(%rbx)
	jmp	.L238
.L249:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.L279
	movzwl	%r11w, %ecx
	jmp	.L251
.L285:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.L256
.L281:
	movq	16(%r11), %rcx
.L246:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.L248
	movzwl	%r9w, %ecx
	jmp	.L239
.L279:
	movl	%r10d, %r12d
	jmp	.L227
.L242:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.L281
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.L254:
	cmpl	%r11d, %r8d
	ja	.L246
	jmp	.L230
.L256:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.L247
.L245:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.L254
	movq	%r15, %rsi
.L247:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.L245
	jb	.L246
	jmp	.L230
.L258:
	movl	%eax, %r12d
	jmp	.L227
.L248:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.L227
	.size	cxvisit, .-cxvisit
	.p2align 4
	.type	cxheader, @function
cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.L288
	cmpb	$1, 15(%rdi)
	jne	.L288
	cmpw	$1024, 16(%rdi)
	jne	.L288
	cmpw	$512, 18(%rdi)
	jne	.L288
	cmpw	$0, 502(%rdi)
	jne	.L288
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.L291
	.p2align 4,,10
	.p2align 3
.L310:
	cmpl	$23, %eax
	ja	.L298
.L290:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.L309
.L291:
	cmpb	$0, (%rdi,%rax)
	je	.L290
	testb	%cl, %cl
	je	.L310
.L298:
	movl	$2, %eax
.L288:
	ret
.L309:
	testl	%edx, %edx
	je	.L292
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.L288
	cmpb	$67, 21(%rdi)
	jne	.L288
	cmpb	$72, 22(%rdi)
	jne	.L288
	cmpb	$66, 23(%rdi)
	jne	.L288
.L292:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.L288
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.L288
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
	js	.L330
	jne	.L313
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r9
	je	.L315
.L314:
	leaq	(%r8,%rsi), %rax
	leaq	(%rax,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L319:
	movb	$48, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L319
	addq	%rsi, %r9
.L315:
	movq	%rsp, %rdi
	leaq	-1(%rsp,%rcx), %rax
	leaq	(%r8,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L320:
	movzbl	(%rax), %esi
	addq	$1, %rdx
	movb	%sil, -1(%rdx)
	movq	%rax, %rsi
	subq	$1, %rax
	cmpq	%rsi, %rdi
	jne	.L320
	addq	$32, %rsp
	leaq	(%rcx,%r9), %rax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L330:
	negq	%rsi
.L313:
	movabsq	$-3689348814741910323, %rbx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L316:
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
	ja	.L316
	testq	%r11, %r11
	jns	.L322
	movb	$45, (%r8)
	addq	$2, %r10
	movl	$1, %esi
.L317:
	subq	%r10, %r9
	jne	.L314
	movq	%rsi, %r9
	jmp	.L315
.L322:
	movq	%rcx, %r10
	xorl	%esi, %esi
	jmp	.L317
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
	cmpq	$67108864, %r14
	ja	.L331
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
	jbe	.L331
	testq	%r13, %r13
	je	.L331
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.L336
	.p2align 4,,10
	.p2align 3
.L333:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.L333
.L336:
	leaq	0(%r13,%rbp), %r8
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r8, %rdx
	je	.L335
	.p2align 4,,10
	.p2align 3
.L334:
	movb	$32, (%r8,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L334
	addq	%r8, %rdx
.L335:
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
	js	.L337
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
	jbe	.L371
	subq	$9, %rsi
	cmpq	$3, %rsi
	adcq	$0, %r9
.L339:
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
.L342:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L342
	testq	%rax, %rax
	jle	.L337
	cmpq	%rdx, %rax
	ja	.L337
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L342
	leaq	28(%r13), %rsi
	movl	$18, %r9d
	movl	$1, %edx
.L343:
	movq	2280(%rbx), %rdi
	movl	$28, %r10d
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L343
	cmpq	$1, %rax
	jne	.L337
	movl	$18, %r9d
	movq	%r8, %rsi
	movq	%rbp, %r10
	movq	%r12, %rdx
.L344:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L344
	testq	%rax, %rax
	jle	.L337
	cmpq	%rdx, %rax
	ja	.L337
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L344
	movq	2256(%rbx), %rdi
	movq	2264(%rbx), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L337
	movl	16(%rbx), %eax
	xorl	%edx, %edx
	movq	%r13, (%rbx)
	movq	%r13, 2256(%rbx)
	leal	1(%rax), %edi
	movq	%r14, 2264(%rbx)
	xorl	%eax, %eax
	movq	%r14, 8(%rbx)
	movl	%edi, 16(%rbx)
	movq	%rdi, 24(%rbx)
	movw	%dx, 38(%rbx)
	movl	%edi, (%r15)
.L331:
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
.L337:
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
.L371:
	addq	$3, %rsi
	jmp	.L339
	.size	hrdbf_file_append.part.0, .-hrdbf_file_append.part.0
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
	je	.L373
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
	js	.L373
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L373:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L372
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L377
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L372:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L377:
	movl	$7, %r8d
	movl	%r8d, %eax
	ret
	.size	hrntx_file_close.constprop.0, .-hrntx_file_close.constprop.0
	.p2align 4
	.type	dset.constprop.0, @function
dset.constprop.0:
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	jmp	.L383
	.p2align 4,,10
	.p2align 3
.L385:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.L384
.L383:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L385
.L384:
	movb	$0, (%rax)
	ret
	.size	dset.constprop.0, .-dset.constprop.0
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
	jne	.L386
	orl	%eax, %edx
	movb	%dl, (%rdi)
.L386:
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
	ja	.L392
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.L392
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.L392
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.L392
	cmpb	$0, 40(%rcx)
	je	.L392
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call	cxheader
	testl	%eax, %eax
	jne	.L388
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.L388
	cmpw	$1, 510(%r12)
	jne	.L388
	cmpb	$0, 512(%r12)
	jne	.L388
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.L392
	testl	$511, %r10d
	jne	.L392
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.L392
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.L388
	cmpw	$1, 2(%r12,%rdx)
	jne	.L388
	cmpl	$-1, 4(%r12,%rdx)
	jne	.L392
	cmpl	$-1, 8(%r12,%rdx)
	jne	.L392
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L388
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
	jne	.L388
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L392
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.L392
	testl	$511, %r8d
	jne	.L392
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.L392
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.L392
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.L392
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.L392
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L393
.L466:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.L430
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L465
.L393:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L466
.L430:
	movl	$2, %eax
	jmp	.L388
	.p2align 4,,10
	.p2align 3
.L392:
	movl	$1, %eax
.L388:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L465:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call	cxheader
	testl	%eax, %eax
	jne	.L388
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L430
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.L430
	cmpb	$0, (%r12,%rdx)
	jne	.L430
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.L394:
	cmpb	$0, (%rdi,%rdx)
	je	.L430
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.L394
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.L395:
	cmpq	%r11, 40(%rsp)
	jbe	.L430
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.L404:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.L398
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.L399
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.L399:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.L400
	subl	$32, %esi
.L400:
	cmpb	16(%rsp), %sil
	jne	.L398
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L396
	cmpq	$11, %rdx
	jne	.L404
	cmpq	$11, %rax
	jne	.L398
.L402:
	cmpl	%r11d, 36(%rsp)
	je	.L430
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.L430
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.L429
	cmpw	12(%r12,%r9), %ax
	jne	.L430
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.L434
	testq	%r14, %r14
	jne	.L436
	testl	%eax, %eax
	jne	.L434
.L436:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.L434
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.L434
	xorl	%edx, %edx
.L406:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L406
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L407
	orl	$1, %eax
	movb	%al, (%rcx)
.L407:
	testb	$2, %al
	jne	.L408
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L408:
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
.L409:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L409
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call	cxvisit
	testl	%eax, %eax
	je	.L467
.L410:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L388
.L396:
	cmpq	$11, %rax
	je	.L402
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L402
.L398:
	addq	$1, %r11
	jmp	.L395
.L434:
	movl	$3, %eax
	jmp	.L388
.L429:
	movl	$5, %eax
	jmp	.L388
.L467:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.L410
	xorl	%edx, %edx
	jmp	.L412
.L468:
	cmpq	$63, %rdx
	ja	.L437
.L412:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.L411
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.L411:
	addq	$1, %rdx
	testb	$1, %al
	je	.L468
.L437:
	testl	%eax, %eax
	jne	.L410
	movl	%ecx, 24(%rbx)
	jmp	.L388
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	put_number.isra.0, @function
put_number.isra.0:
	movl	%esi, %r11d
	movl	$3, %r10d
	movl	%edx, %esi
	cmpb	$78, %r11b
	jne	.L469
	movzwl	%cx, %ecx
	leaq	(%rdi,%rcx), %rdx
	movzbl	%sil, %ecx
	cmpl	%r9d, %ecx
	jb	.L490
	subl	%r9d, %ecx
	je	.L475
	leal	-1(%rcx), %edi
	movq	%rdx, %rax
	addq	%rdx, %rdi
	.p2align 4,,10
	.p2align 3
.L476:
	movq	%rax, %rsi
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdi, %rsi
	jne	.L476
.L475:
	testl	%r9d, %r9d
	je	.L474
	leal	-1(%r9), %eax
	leaq	1(%r8,%rax), %rdi
	movl	%ecx, %eax
	subl	%r8d, %eax
	.p2align 4,,10
	.p2align 3
.L477:
	movzbl	(%r8), %esi
	leal	(%rax,%r8), %ecx
	addq	$1, %r8
	movb	%sil, (%rdx,%rcx)
	cmpq	%rdi, %r8
	jne	.L477
.L474:
	xorl	%r10d, %r10d
.L469:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L490:
	movq	%rdx, %rax
	movzbl	%sil, %edx
	addq	%rax, %rdx
	testl	%ecx, %ecx
	je	.L474
	.p2align 4,,10
	.p2align 3
.L473:
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L474
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L473
	jmp	.L474
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
	ja	.L491
	movzbl	12(%rsi), %r12d
	movq	%rsi, %r10
	cmpl	$17, %ecx
	ja	.L517
	cmpb	%r12b, %r13b
	jnb	.L517
	movq	%rdi, %rbp
	movq	%rdx, %rsi
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jns	.L493
	negq	%rsi
	movl	$1, %r8d
.L493:
	movzbl	%r13b, %ebx
	cmpl	%ebx, %ecx
	jbe	.L494
	subl	%ebx, %ecx
	je	.L495
	xorl	%eax, %eax
	movl	$1, %edi
	.p2align 4,,10
	.p2align 3
.L496:
	leaq	(%rdi,%rdi,4), %rdi
	addl	$1, %eax
	addq	%rdi, %rdi
	cmpl	%eax, %ecx
	jne	.L496
	movq	%rsi, %rax
	xorl	%edx, %edx
	divq	%rdi
	shrq	%rdi
	movq	%rax, %rsi
	cmpq	%rdi, %rdx
	jb	.L497
.L495:
	addq	$1, %rsi
.L497:
	movabsq	$-3689348814741910323, %r9
	movq	%rsp, %rdi
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L502:
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
	ja	.L502
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
	ja	.L545
	testl	%r8d, %r8d
	je	.L508
	movb	$45, 48(%rsp)
.L508:
	cmpl	%ecx, %ebx
	jb	.L546
	leal	1(%r8), %r9d
	movl	%r8d, %r8d
	movb	$48, 48(%rsp,%r8)
.L510:
	testb	%r13b, %r13b
	je	.L512
	cmpl	%ecx, %ebx
	movl	%r9d, %edx
	leal	1(%r9), %eax
	cmovbe	%ebx, %ecx
	movb	$46, 48(%rsp,%rdx)
	subl	%ecx, %ebx
	je	.L513
	leal	1(%rbx,%r9), %edi
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L514:
	movl	%edx, %esi
	addl	$1, %edx
	movb	$48, 48(%rsp,%rsi)
	cmpl	%edx, %edi
	jne	.L514
	addl	%ebx, %eax
.L513:
	leal	(%rcx,%rax), %r9d
	leal	-1(%rcx,%rax), %esi
	.p2align 4,,10
	.p2align 3
.L515:
	movl	%esi, %ecx
	movl	%eax, %edx
	subl	%eax, %ecx
	addl	$1, %eax
	movzbl	(%rsp,%rcx), %ecx
	movb	%cl, 48(%rsp,%rdx)
	cmpl	%eax, %r9d
	jne	.L515
.L512:
	movzbl	11(%r10), %esi
	leaq	48(%rsp), %r8
	movl	%r14d, %ecx
	movl	%r12d, %edx
	movq	%rbp, %rdi
	call	put_number.isra.0
.L491:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L517:
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
.L494:
	jnb	.L497
	movl	%ebx, %edi
	subl	%ecx, %edi
	je	.L497
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rsi
	ja	.L498
	xorl	%eax, %eax
	jmp	.L499
	.p2align 4,,10
	.p2align 3
.L501:
	cmpq	%rdx, %rsi
	ja	.L498
.L499:
	leaq	(%rsi,%rsi,4), %rsi
	addl	$1, %eax
	addq	%rsi, %rsi
	cmpl	%eax, %edi
	jne	.L501
	jmp	.L497
	.p2align 4,,10
	.p2align 3
.L546:
	testl	%r9d, %r9d
	je	.L521
	movl	%edx, %r9d
	addl	%r8d, %r11d
	jmp	.L511
	.p2align 4,,10
	.p2align 3
.L547:
	movl	%r11d, %eax
	movl	%esi, %r8d
	subl	%esi, %eax
	movzbl	(%rsp,%rax), %eax
.L511:
	leal	1(%r8), %esi
	movl	%r8d, %r8d
	movb	%al, 48(%rsp,%r8)
	cmpl	%esi, %edx
	jne	.L547
	jmp	.L510
	.p2align 4,,10
	.p2align 3
.L545:
	xorl	%eax, %eax
	leaq	0(%rbp,%r14), %rdx
	.p2align 4,,10
	.p2align 3
.L506:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L506
	xorl	%eax, %eax
.L548:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L498:
	movzwl	14(%r10), %edx
	xorl	%eax, %eax
	addq	%rbp, %rdx
	.p2align 4,,10
	.p2align 3
.L500:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r12d
	ja	.L500
	xorl	%eax, %eax
	jmp	.L548
.L521:
	movl	%r8d, %r9d
	jmp	.L510
	.size	hrdbf_write_number_scaled.part.0, .-hrdbf_write_number_scaled.part.0
	.p2align 4
	.type	bn_shr_round, @function
bn_shr_round:
	movl	288(%rdi), %r9d
	movl	%esi, %r8d
	movl	%r9d, %esi
	sall	$5, %esi
	cmpl	%r8d, %esi
	jbe	.L594
	leal	-1(%r8), %edx
	xorl	%r10d, %r10d
	cmpl	%edx, %esi
	ja	.L595
.L556:
	cmpl	$1, %r8d
	je	.L557
	xorl	%ecx, %ecx
	jmp	.L560
	.p2align 4,,10
	.p2align 3
.L558:
	addl	$1, %ecx
	cmpl	%ecx, %edx
	je	.L557
.L560:
	cmpl	%ecx, %esi
	jbe	.L558
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L558
	testl	%r10d, %r10d
	movl	$3, %edx
	cmovne	%edx, %eax
.L571:
	cmpl	$31, %r8d
	jbe	.L565
	movl	%r8d, %r11d
	shrl	$5, %r11d
	cmpl	%r11d, %r9d
	jbe	.L567
	leal	-1(%r9), %ecx
	movq	%rdi, %rdx
	movl	%r11d, %esi
	subl	%r11d, %ecx
	leaq	4(%rdi,%rcx,4), %r10
	.p2align 4,,10
	.p2align 3
.L566:
	movl	(%rdx,%rsi,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%r10, %rdx
	jne	.L566
.L567:
	movl	%r9d, %edx
	subl	%r11d, %edx
	movl	%edx, 288(%rdi)
	cmpl	%edx, %r9d
	jbe	.L565
	movl	%edx, %ecx
	leal	-1(%r11), %esi
	leaq	(%rdi,%rcx,4), %rdx
	addq	%rsi, %rcx
	leaq	4(%rdi,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L568:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L568
.L565:
	andl	$31, %r8d
	jne	.L562
	ret
	.p2align 4,,10
	.p2align 3
.L595:
	movl	%edx, %eax
	movl	%edx, %ecx
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %r10d
	shrl	%cl, %r10d
	andl	$1, %r10d
	jmp	.L556
	.p2align 4,,10
	.p2align 3
.L594:
	xorl	%eax, %eax
	testl	%esi, %esi
	je	.L551
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L553:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r9d
	addl	$1, %ecx
	cmpl	%ecx, %esi
	jne	.L553
	testl	%eax, %eax
	je	.L551
	xorl	%r10d, %r10d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L554:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %r10d
	cmpl	%ecx, %esi
	jne	.L554
	subl	$1, %r8d
	cmpl	%r9d, %r8d
	ja	.L551
	sete	%al
	xorl	%edx, %edx
	cmpl	$1, %r10d
	sete	%dl
	andl	%eax, %edx
	movl	$3, %eax
	subl	%edx, %eax
.L551:
	movl	$1, 288(%rdi)
	movl	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.L557:
	leal	(%r10,%r10), %eax
	jmp	.L571
	.p2align 4,,10
	.p2align 3
.L562:
	movl	288(%rdi), %ecx
	pushq	%rbx
	leal	-1(%rcx), %ebx
	cmpl	$1, %ecx
	jbe	.L569
	movl	$32, %r10d
	subl	$2, %ecx
	movq	%rdi, %rdx
	subl	%r8d, %r10d
	leaq	4(%rdi,%rcx,4), %r11
	.p2align 4,,10
	.p2align 3
.L570:
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
	jne	.L570
	movl	%ebx, %esi
	movl	%r8d, %ecx
	movl	(%rdi,%rsi,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%rdi,%rsi,4)
	testl	%edx, %edx
	je	.L596
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L596:
	movl	%ebx, 288(%rdi)
	popq	%rbx
	ret
.L569:
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
.L598:
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
	jbe	.L608
	cmpl	$19, %r8d
	jbe	.L598
.L608:
	leaq	2289(%rdi), %r10
	leaq	2448(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L606:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L600
	.p2align 4,,10
	.p2align 3
.L602:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L601
.L600:
	cmpb	$0, (%rax)
	jne	.L602
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L603
	jmp	.L601
	.p2align 4,,10
	.p2align 3
.L604:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L601
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L603:
	testb	%cl, %cl
	jne	.L604
.L601:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L597
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L606
.L597:
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
	leaq	2289(%rdi), %r11
	pushq	%rbx
	leaq	2448(%rdi), %rbx
	movq	%r11, %rax
	jmp	.L616
	.p2align 4,,10
	.p2align 3
.L618:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.L617
.L616:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.L618
.L617:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.L620
	.p2align 4,,10
	.p2align 3
.L622:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.L621
.L620:
	cmpb	$0, (%rax)
	jne	.L622
	cmpq	%rax, %rbx
	jbe	.L621
	movl	$32, %esi
	movl	$.LC1, %ecx
	.p2align 4,,10
	.p2align 3
.L623:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L621
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.L623
.L621:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call	fdec
	jmp	.L624
	.p2align 4,,10
	.p2align 3
.L626:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.L625
.L624:
	cmpb	$0, (%r11)
	jne	.L626
	cmpq	%r11, %rbx
	jbe	.L625
	movb	$41, (%r11)
	addq	$1, %r11
.L625:
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
	je	.L639
	movabsq	$4503599627370495, %rax
	andq	40(%rsp), %rax
	movq	%rdi, %rbx
	movq	%rax, 8(%rsp)
	testq	%r9, %r9
	je	.L873
	btsq	$52, 8(%rsp)
	movq	8(%rsp), %rax
	movl	$2, %edi
	leal	-1075(%r9), %r15d
	subl	$735, %r9d
	movl	%eax, %ecx
	movl	%r9d, %r10d
	shrq	$32, %rax
.L637:
	movl	%ecx, 48(%rsp)
	movl	$340, %esi
	xorl	%r8d, %r8d
	movl	%eax, 52(%rsp)
	movl	%edi, 336(%rsp)
	.p2align 4,,10
	.p2align 3
.L642:
	leal	-1(%rdi), %eax
	leaq	48(%rsp), %rdx
	leaq	52(%rsp,%rax,4), %r11
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L643:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%r11, %rdx
	jne	.L643
	testq	%rax, %rax
	je	.L644
	movl	%edi, %edx
	movl	$1, %r8d
	addl	$1, %edi
	movl	%eax, 48(%rsp,%rdx,4)
.L644:
	subl	$1, %esi
	jne	.L642
	testb	%r8b, %r8b
	je	.L646
	movl	%edi, 336(%rsp)
.L646:
	movl	%r10d, %esi
	testl	%r9d, %r9d
	js	.L647
	leaq	48(%rsp), %rdi
	call	bn_shl
	movl	336(%rsp), %eax
.L648:
	xorl	%ebp, %ebp
	jmp	.L652
	.p2align 4,,10
	.p2align 3
.L653:
	cmpq	$80, %rbp
	je	.L874
	leaq	48(%rsp), %rdi
	call	bn_divmod_1e9
	movl	%eax, 1264(%rsp,%rbp,4)
	movl	336(%rsp), %eax
	addq	$1, %rbp
.L652:
	movl	%ebp, %r8d
	cmpl	$1, %eax
	jne	.L653
	movl	48(%rsp), %r9d
	testl	%r9d, %r9d
	jne	.L653
	testl	%ebp, %ebp
	jne	.L875
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L638
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jnb	.L876
.L639:
	xorl	%eax, %eax
.L631:
	addq	$2312, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L873:
	testq	%rax, %rax
	jne	.L877
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L638
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jb	.L639
	movl	$11824, %ecx
	leaq	2(%rdi), %rdx
	movw	%cx, (%rdi)
	movl	16(%rsp), %edi
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L641:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L641
	jmp	.L631
.L638:
	movl	36(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L639
	movb	$48, (%rbx)
	movl	$1, %eax
	jmp	.L631
.L877:
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
	jmp	.L637
.L647:
	negl	%esi
	leaq	48(%rsp), %rdi
	call	bn_shr_round
	movl	%eax, %r8d
	movl	336(%rsp), %eax
	cmpl	$1, %r8d
	jbe	.L648
	testl	%eax, %eax
	je	.L747
	leal	-1(%rax), %edx
	movq	%rdi, %rsi
	leaq	52(%rsp,%rdx,4), %rdi
	movl	$1, %edx
.L651:
	movl	(%rsi), %ecx
	addq	$4, %rsi
	addq	%rcx, %rdx
	movl	%edx, -4(%rsi)
	shrq	$32, %rdx
	cmpq	%rdi, %rsi
	jne	.L651
	testq	%rdx, %rdx
	je	.L648
	leal	1(%rax), %edx
.L650:
	movl	$1, 48(%rsp,%rax,4)
	movl	%edx, %eax
	movl	%edx, 336(%rsp)
	jmp	.L648
.L874:
	movl	$79, %r8d
.L656:
	movl	%r8d, %eax
	movl	$1, %ecx
	movl	$3435973837, %r9d
	movl	1264(%rsp,%rax,4), %esi
.L660:
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
	ja	.L660
	leaq	1584(%rsp), %r13
	leal	-1(%r12), %ecx
	leaq	1585(%rsp), %rax
	movq	%rcx, %r11
	leal	-1(%r12,%r13), %esi
	addq	%rax, %rcx
	movq	%r13, %rax
	jmp	.L662
.L878:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	960(%rsp,%rdx), %edx
.L662:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L878
	testl	%r8d, %r8d
	je	.L663
	leaq	1264(%rsp), %r14
	leal	-1(%r8), %eax
	movl	$3435973837, %r10d
	leaq	(%r14,%rax,4), %rbp
.L665:
	movl	%r11d, %edi
	movl	0(%rbp), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L664:
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
	jne	.L664
	leaq	-4(%rbp), %rax
	cmpq	%r14, %rbp
	je	.L879
	movq	%rax, %rbp
	jmp	.L665
.L879:
	leal	(%r8,%r8,8), %eax
	addl	%eax, %r12d
.L663:
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
.L667:
	leal	-1(%r8), %eax
	leaq	352(%rsp), %rcx
	leaq	356(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L668:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L668
	testq	%rax, %rax
	je	.L669
	movl	%r8d, %edx
	movl	$1, %r9d
	addl	$1, %r8d
	movl	%eax, 352(%rsp,%rdx,4)
.L669:
	subl	$1, %edi
	jne	.L667
	testb	%r9b, %r9b
	je	.L671
	movl	%r8d, 640(%rsp)
.L671:
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
	je	.L672
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
.L673:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L674:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rsi, %rcx
	jne	.L674
	testq	%rax, %rax
	je	.L675
	movl	%r11d, %edx
	movl	%r9d, %ebp
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L675:
	subl	$1, %r10d
	jne	.L673
	testb	%bpl, %bpl
	je	.L677
	movl	%r11d, 944(%rsp)
.L677:
	leal	338(%r15), %esi
	call	bn_shl
.L678:
	leaq	960(%rsp), %r8
	cmpl	$1, %r12d
	je	.L715
	leal	1(%r12), %eax
	leaq	960(%rsp), %r8
	movq	%rbx, 24(%rsp)
	movl	$2, %r14d
	movl	%eax, 32(%rsp)
	leaq	1585(%rsp), %rbp
	movl	$1, %r15d
	movq	%r8, %rbx
.L711:
	movl	%r15d, 4(%rsp)
	movq	%r13, %rdx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.L685:
	movzbl	(%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpq	%rdx, %rbp
	jne	.L685
	cmpb	$53, 0(%rbp)
	ja	.L686
	je	.L880
.L687:
	movl	32(%rsp), %r10d
	movq	%r10, %rcx
	subq	%r14, %rcx
	cmpq	$9, %rsi
	ja	.L881
.L689:
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
	je	.L693
	.p2align 4,,10
	.p2align 3
.L692:
	leal	-1(%rdi), %eax
	movq	%rbx, %rcx
	leaq	964(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L694:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L694
	testq	%rax, %rax
	je	.L695
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 960(%rsp,%rdx,4)
.L695:
	addl	$1, %r9d
	cmpl	%r10d, %r9d
	jne	.L692
	testb	%r11b, %r11b
	je	.L693
	movl	%edi, 1248(%rsp)
.L693:
	movl	%r10d, %esi
	movq	%rbx, %rdi
	call	bn_shl
	movl	1248(%rsp), %esi
	cmpl	944(%rsp), %esi
	je	.L698
	jnb	.L699
	cmpl	640(%rsp), %esi
	jne	.L700
	movl	$-1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L707
	.p2align 4,,10
	.p2align 3
.L710:
	movl	%eax, %edx
	subl	$1, %eax
	movl	352(%rsp,%rdx,4), %edi
	cmpl	%edi, 960(%rsp,%rdx,4)
	jne	.L882
.L707:
	cmpl	$-1, %eax
	jne	.L710
.L706:
	testb	$1, 8(%rsp)
	je	.L862
.L700:
	movl	%r14d, %eax
	addq	$1, %r15
	addq	$1, %r14
	addq	$1, %rbp
	cmpl	$17, %eax
	ja	.L863
	cmpl	%r12d, %eax
	jb	.L711
.L863:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
.L715:
	movl	$17, %eax
	cmpl	%eax, %r12d
	cmovbe	%r12d, %eax
	movl	%eax, 4(%rsp)
.L713:
	movl	4(%rsp), %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
.L716:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpl	%edx, %edi
	ja	.L716
	movl	4(%rsp), %eax
	cmpl	%r12d, %eax
	jnb	.L717
	cmpb	$53, 1584(%rsp,%rax)
	ja	.L718
	jne	.L717
	testb	$1, %sil
	jne	.L718
	movl	4(%rsp), %eax
	addl	$1, %eax
	cmpl	%r12d, %eax
	jb	.L719
	jmp	.L717
	.p2align 4,,10
	.p2align 3
.L883:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L717
.L719:
	cmpb	$48, 0(%r13,%rax)
	je	.L883
.L718:
	addq	$1, %rsi
.L717:
	movabsq	$-3689348814741910323, %r9
	xorl	%ecx, %ecx
.L720:
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
	ja	.L720
	cmpl	4(%rsp), %ecx
	jbe	.L721
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 20(%rsp)
	testl	%edi, %edi
	je	.L725
	leal	-1(%rdi), %eax
	movl	%edi, %ecx
	movq	%rax, %rdx
	movzbl	960(%rsp,%rax), %eax
	movl	%edx, %edi
.L721:
	xorl	%edx, %edx
	jmp	.L723
.L884:
	movl	%edi, %eax
	subl	%edx, %eax
	movzbl	960(%rsp,%rax), %eax
.L723:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L884
	cmpl	$1, %ecx
	jbe	.L724
.L885:
	leal	-1(%rcx), %edx
	cmpb	$48, 1584(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L724
	movl	%eax, %ecx
.L725:
	cmpl	$1, %ecx
	ja	.L885
.L724:
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
	jle	.L886
	movl	%ecx, %esi
	cmpq	%rsi, %rax
	jge	.L730
	cmpb	$52, 1584(%rsp,%rax)
	movl	%eax, %ecx
	jbe	.L736
	leal	-1(%rax), %esi
	movq	%rsi, %rax
	addq	%r13, %rsi
	subl	%esi, %eax
	jmp	.L733
.L732:
	movb	$48, (%rsi)
	leaq	-1(%rsi), %r10
	cmpq	%rsi, %r13
	je	.L887
	movq	%r10, %rsi
.L733:
	movzbl	(%rsi), %r10d
	leal	(%rax,%rsi), %r11d
	cmpb	$57, %r10b
	je	.L732
	movl	%r11d, %eax
	addl	$1, %r10d
	movb	%r10b, 1584(%rsp,%rax)
	jmp	.L736
	.p2align 4,,10
	.p2align 3
.L698:
	leal	-1(%rsi), %eax
	movl	%eax, %edx
	jmp	.L703
	.p2align 4,,10
	.p2align 3
.L705:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	656(%rsp,%rcx,4), %edi
	cmpl	%edi, 960(%rsp,%rcx,4)
	jne	.L888
.L703:
	cmpl	$-1, %edx
	jne	.L705
	xorl	%ecx, %ecx
	cmpl	%esi, 640(%rsp)
	je	.L707
	jmp	.L706
.L880:
	testb	$1, %sil
	jne	.L686
	cmpl	%r14d, %r12d
	jbe	.L687
	movq	%r14, %rax
	jmp	.L688
.L889:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L687
.L688:
	cmpb	$48, 0(%r13,%rax)
	je	.L889
.L686:
	addq	$1, %rsi
	jmp	.L687
.L881:
	movq	%rsi, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L690:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rdi
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rdi
	ja	.L690
	cmpl	%r9d, 4(%rsp)
	jnb	.L689
	movabsq	$-3689348814741910323, %rax
	movq	%r10, %rcx
	mulq	%rsi
	subq	%r15, %rcx
	movq	%rdx, %rsi
	shrq	$3, %rsi
	jmp	.L689
.L888:
	jnb	.L704
	movl	$-1, %ecx
	cmpl	640(%rsp), %esi
	je	.L707
	jmp	.L700
.L882:
	jnb	.L709
	cmpl	$1, %ecx
	je	.L862
.L709:
	testl	%ecx, %ecx
	jne	.L700
	jmp	.L706
.L699:
	cmpl	640(%rsp), %esi
	jne	.L871
	movl	$1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L707
.L871:
	jnb	.L700
.L862:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
	jmp	.L713
.L704:
	cmpl	640(%rsp), %esi
	jne	.L871
	movl	$1, %ecx
	jmp	.L707
.L890:
	leal	-1(%rcx), %esi
	cmpb	$48, 1584(%rsp,%rsi)
	movq	%rsi, %rax
	jne	.L870
	movl	%eax, %ecx
.L736:
	cmpl	$1, %ecx
	jne	.L890
.L735:
	xorl	%eax, %eax
	movl	$0, %esi
	cmpb	$48, 1584(%rsp)
	movl	$1, %ecx
	cmovne	%r8, %rax
	cmove	%esi, %edx
	jmp	.L728
	.p2align 4,,10
	.p2align 3
.L672:
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
.L680:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L681:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L681
	testq	%rax, %rax
	je	.L682
	movl	%r11d, %edx
	movl	$1, %r9d
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L682:
	subl	$1, %r10d
	jne	.L680
	testb	%r9b, %r9b
	je	.L684
	movl	%r11d, 944(%rsp)
.L684:
	movl	%ebp, %esi
	call	bn_shl
	jmp	.L678
.L730:
	cmpl	$1, %ecx
	je	.L735
.L870:
	movq	%r8, %rax
.L728:
	movl	20(%rsp), %r14d
	movl	$1, %r8d
	leal	1(%r14), %esi
	testl	%r14d, %r14d
	movslq	%esi, %rsi
	cmovs	%r8, %rsi
.L737:
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
	jg	.L639
	testl	%edx, %edx
	jne	.L891
	movq	%rbx, %rsi
	movl	$1, %eax
.L739:
	movl	20(%rsp), %edi
	testl	%edi, %edi
	js	.L740
	leal	1(%rdi), %eax
	xorl	%esi, %esi
	movslq	%eax, %r9
.L742:
	leal	(%rdx,%rsi), %edi
	movl	$48, %r8d
	cmpl	%ecx, %esi
	jnb	.L741
	movzbl	0(%r13,%rsi), %r8d
.L741:
	addq	$1, %rsi
	movb	%r8b, (%rbx,%rdi)
	cmpq	%rsi, %r9
	jne	.L742
	addl	%edx, %eax
.L743:
	movl	16(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L631
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
	jmp	.L745
.L765:
	movl	%eax, %edx
.L745:
	movl	$48, %r8d
	testq	%rsi, %rsi
	js	.L744
	leal	(%r9,%rdx), %eax
	cmpl	%ecx, %eax
	jnb	.L744
	movzbl	0(%r13,%rsi), %r8d
.L744:
	leal	1(%rdx), %eax
	movb	%r8b, (%rbx,%rdx)
	addq	$1, %rsi
	cmpl	%r10d, %eax
	jne	.L765
	movl	16(%rsp), %eax
	addl	%edi, %eax
	jmp	.L631
.L886:
	jne	.L727
	cmpb	$52, 1584(%rsp)
	jbe	.L727
	negl	%esi
	movb	$49, 1584(%rsp)
	movq	%r8, %rax
	movl	$1, %ecx
	movl	%esi, 20(%rsp)
	jmp	.L728
.L727:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %esi
	movl	$1, %ecx
	movb	$48, 1584(%rsp)
	movl	$0, 20(%rsp)
	jmp	.L737
.L891:
	movb	$45, (%rbx)
	leaq	1(%rbx), %rsi
	movl	$2, %eax
	jmp	.L739
.L875:
	subl	$1, %r8d
	jmp	.L656
.L876:
	movl	16(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rbx)
	leaq	2(%rbx), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L659:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L659
	jmp	.L631
.L740:
	movb	$48, (%rsi)
	jmp	.L743
.L747:
	movl	$1, %edx
	jmp	.L650
.L887:
	movb	$49, 1584(%rsp)
	movl	%r9d, 20(%rsp)
	jmp	.L736
	.size	hrdbf_fmt_harbour.part.0, .-hrdbf_fmt_harbour.part.0
	.p2align 4
	.type	hrdbf_write_number_double.part.0, @function
hrdbf_write_number_double.part.0:
	movzbl	13(%rsi), %edx
	movl	$4, %eax
	cmpb	$17, %dl
	ja	.L899
	pushq	%rbp
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$408, %rsp
	cmpb	12(%rsi), %dl
	jnb	.L892
	movq	%rdi, %rbp
	movl	$400, %esi
	movq	%rsp, %rdi
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %r9d
	movl	$5, %eax
	testl	%r9d, %r9d
	je	.L892
	movzwl	14(%rbx), %ecx
	movzbl	12(%rbx), %edx
	movq	%rsp, %r8
	movq	%rbp, %rdi
	movzbl	11(%rbx), %esi
	call	put_number.isra.0
.L892:
	addq	$408, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L899:
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
.L903:
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
	jbe	.L913
	cmpl	$19, %r8d
	jbe	.L903
.L913:
	leaq	2090(%rdi), %r10
	leaq	2249(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L911:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L905
	.p2align 4,,10
	.p2align 3
.L907:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L906
.L905:
	cmpb	$0, (%rax)
	jne	.L907
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L908
	jmp	.L906
	.p2align 4,,10
	.p2align 3
.L909:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L906
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L908:
	testb	%cl, %cl
	jne	.L909
.L906:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L902
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L911
.L902:
	addq	$56, %rsp
	ret
	.size	ddec, .-ddec
	.p2align 4
	.type	dname, @function
dname:
	xorl	%r8d, %r8d
	movl	$63, %r9d
	leaq	2249(%rdi), %rdx
	.p2align 4,,10
	.p2align 3
.L921:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.L920
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	2090(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.L923
	.p2align 4,,10
	.p2align 3
.L925:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.L924
.L923:
	cmpb	$0, (%rax)
	jne	.L925
	cmpq	%rdx, %rax
	jnb	.L924
	movb	%cl, (%rax)
	addq	$1, %rax
.L924:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.L921
.L920:
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
	movl	%esi, %r12d
	pushq	%rbp
	pushq	%rbx
	subq	$24, %rsp
	.p2align 4,,10
	.p2align 3
.L930:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L930
	testq	%rax, %rax
	js	.L985
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
	movq	%rax, %rbp
	testq	%rax, %rax
	js	.L933
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.L989
	cmpl	$1, %r12d
	movq	%rbp, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.L938
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L939
	movq	%rbp, hrdbf_app_order+48(%rip)
	xorl	%r9d, %r9d
	movq	%r13, %rdi
	movq	%rbp, %rsi
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
	jb	.L940
	movq	$0, hrdbf_app_order+32(%rip)
.L941:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.L982
	.p2align 4,,10
	.p2align 3
.L989:
	movl	$3, %eax
	movq	%rsi, %rdx
.L988:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	js	.L983
.L936:
	movq	hrdbf_app_order+32(%rip), %r10
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.L958
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
	js	.L959
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L929
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L985
.L984:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L929:
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
.L959:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L985
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L985
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L985:
	movl	$7, %r8d
	jmp	.L929
	.p2align 4,,10
	.p2align 3
.L933:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L936
.L939:
	movl	$3, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L936
.L945:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L983:
	movl	$7, %r8d
	jmp	.L936
	.p2align 4,,10
	.p2align 3
.L958:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L929
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L984
	jmp	.L985
	.p2align 4,,10
	.p2align 3
.L938:
	movl	$3, %eax
	movq	%rsi, %rdx
	jmp	.L988
	.p2align 4,,10
	.p2align 3
.L940:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L941
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.L942
	jmp	.L943
	.p2align 4,,10
	.p2align 3
.L990:
	movq	hrdbf_app_order+32(%rip), %rsi
.L942:
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
	je	.L944
	testq	%rax, %rax
	jle	.L945
	addq	%rax, %r8
.L944:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.L990
.L943:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L946:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbp
	cmpq	$-4, %rax
	je	.L946
	testq	%rax, %rax
	jne	.L947
	cmpl	$1, %r12d
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.L949
	xorl	%edx, %edx
	leaq	7(%rsi), %r14
	movl	$34, %r10d
	xorl	%r9d, %r9d
	shrq	$3, %r14
	movq	$-1, %r8
	movq	%rbp, %rdi
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
	jb	.L950
	movq	$0, hrdbf_app_order+40(%rip)
.L951:
	movq	$0, hrdbf_app_order+56(%rip)
.L982:
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
	jns	.L936
	jmp	.L983
.L949:
	movl	$3, %eax
	movq	%rbp, %rsi
	movq	%rbp, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.L936
	jmp	.L983
.L947:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.L936
.L950:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.L951
	testl	%r12d, %r12d
	movl	$hrntx_open, %edx
	movq	%rax, %r8
	movl	$hrdbf_app_order, %edi
	movl	$hrcdx_open, %r10d
	movq	hrdbf_app_order+32(%rip), %rsi
	movl	$hrdbf_app_state, %ecx
	movl	hrdbf_app_state+16(%rip), %r9d
	cmove	%rdx, %r10
	addq	%rax, %r15
	addq	%r14, %r13
	movq	hrdbf_app_order+48(%rip), %rdx
	pushq	%r13
	pushq	%r15
	call	*%r10
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	movl	%eax, %r8d
	popq	%rax
	movl	$3, %eax
	popq	%rdx
	movq	%rbp, %rdx
	testl	%r8d, %r8d
	je	.L955
	cmpl	$5, %r8d
	jne	.L988
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r8d
	testq	%rax, %rax
	jns	.L936
	jmp	.L983
	.p2align 4,,10
	.p2align 3
.L955:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L929
	jmp	.L983
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
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	movq	%rax, %rdx
	movb	%cl, 14(%rsp)
	jmp	.L992
	.p2align 4,,10
	.p2align 3
.L994:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.L993
.L992:
	cmpb	$0, (%rdx)
	jne	.L994
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.L995
	jmp	.L993
	.p2align 4,,10
	.p2align 3
.L997:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.L993
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.L995:
	testb	%cl, %cl
	jne	.L997
.L993:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.LC2(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.L999
	.p2align 4,,10
	.p2align 3
.L1001:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.L1000
.L999:
	cmpb	$0, (%rax)
	jne	.L1001
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.L1002
	jmp	.L1000
	.p2align 4,,10
	.p2align 3
.L1003:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.L1000
.L1002:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1003
.L1000:
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
	je	.L1012
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.L1012:
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
	je	.L1015
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.L1015
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.L1017
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
.L1019:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.L1029
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.L1015:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1017:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.L1020
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.L1015
	.p2align 4,,10
	.p2align 3
.L1029:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.L1015
	.p2align 4,,10
	.p2align 3
.L1020:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.L1019
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
	je	.L1109
	testl	%esi, %esi
	je	.L1110
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.L1110
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
	ja	.L1110
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.L1113
	cmpb	$78, %r8b
	je	.L1114
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.L1115
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.L1056
	cmpb	$89, %dl
	je	.L1056
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.L1110
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.L1109
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.L1109
	.p2align 4,,10
	.p2align 3
.L1110:
	xorl	%r8d, %r8d
.L1109:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1056:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1113:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1109
	.p2align 4,,10
	.p2align 3
.L1114:
	testl	%edi, %edi
	je	.L1110
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.L1035
	.p2align 4,,10
	.p2align 3
.L1036:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.L1110
.L1035:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.L1036
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.L1038
	.p2align 4,,10
	.p2align 3
.L1062:
	movl	%edx, %edi
.L1038:
	cmpl	%edi, %eax
	jnb	.L1037
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.L1062
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.L1082
	cmpb	$45, %r8b
	sete	%dl
.L1060:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.L1040:
	cmpl	%eax, %edi
	jbe	.L1067
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.L1059:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.L1044
	.p2align 4,,10
	.p2align 3
.L1116:
	testl	%ebx, %ebx
	jne	.L1083
	movl	$1, %ebx
.L1041:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.L1043
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.L1044:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.L1116
.L1083:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L1067
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.L1073
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.L1041
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.L1041
	.p2align 4,,10
	.p2align 3
.L1115:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.L1053:
	cmpb	$32, (%rax)
	jne	.L1075
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1053
	jmp	.L1110
.L1075:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L1052:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.L1076
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.L1052
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
	jbe	.L1109
	cmpl	$11, %edx
	ja	.L1109
	testl	%edi, %edi
	je	.L1109
	movzbl	days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.L1117
.L1054:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.L1109
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1109
.L1043:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.L1030
	cmpl	%r13d, %r9d
	jb	.L1030
	leal	1(%r13), %eax
	jbe	.L1045
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.L1046
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1047:
	cmpq	%rsi, %r11
	ja	.L1073
.L1046:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.L1047
	testl	%r12d, %r12d
	jne	.L1058
.L1049:
	movq	%r11, %rax
.L1050:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.L1030:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1073:
	movl	$4, %r8d
	jmp	.L1030
.L1037:
	je	.L1032
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.L1040
	cmpb	$45, %dl
	sete	%dl
	jmp	.L1060
	.p2align 4,,10
	.p2align 3
.L1032:
	xorl	%r8d, %r8d
	jmp	.L1030
.L1067:
	movl	$5, %r8d
	jmp	.L1030
.L1082:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.L1059
.L1076:
	movl	$5, %r8d
	jmp	.L1109
.L1117:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.L1054
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L1055
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L1054
.L1055:
	addl	$1, %r10d
	jmp	.L1054
.L1045:
	testl	%r12d, %r12d
	je	.L1049
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.L1050
.L1058:
	movq	%r11, %rax
	negq	%rax
	jmp	.L1050
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.L1118
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.L1120
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.L1120:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.L1118:
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
	.string	"more than 128 field descriptors"
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
	subq	$2344, %rsp
	movb	$0, 2090(%rdi)
	movb	$0, 2170(%rsp)
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	$0, 80(%rsp)
	movq	$0, 88(%rsp)
	movl	$0, 96(%rsp)
	movq	$0, 104(%rsp)
	movl	$16842752, 116(%rsp)
	movb	$0, 120(%rsp)
	cmpq	$32, %rdx
	jbe	.L1199
	cmpb	$3, (%rsi)
	movq	%rsi, %r10
	jne	.L1200
	movl	4(%rsi), %ebx
	movzwl	8(%rsi), %eax
	movq	%rdx, %r11
	movzwl	10(%rsi), %edi
	movl	%ebx, 12(%rsp)
	movl	%ebx, 96(%rsp)
	movzwl	%ax, %ebx
	movw	%ax, 112(%rsp)
	movw	%di, 20(%rsp)
	movl	%edi, 16(%rsp)
	movw	%di, 114(%rsp)
	movq	%rbx, (%rsp)
	cmpw	$32, %ax
	jbe	.L1127
	testl	%edi, %edi
	sete	%dl
	cmpq	%rbx, %r11
	setb	%al
	orb	%al, %dl
	je	.L1128
.L1127:
	movl	$.LC8, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movq	(%rsp), %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC9, %esi
	movq	%rbp, %rdi
	call	dcat
	movzwl	20(%rsp), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC10, %esi
	movq	%rbp, %rdi
	call	dcat
	movq	%r11, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$1, %eax
.L1123:
	addq	$2344, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1128:
	movq	(%rsp), %rcx
	movq	%rsi, 40(%rsp)
	leaq	32(%rsi), %rdi
	xorl	%r8d, %r8d
	leaq	80(%rsp), %rbx
	movl	$0, 8(%rsp)
	leaq	123(%rsp), %r15
	movl	$1, %r13d
	leaq	-33(%rcx), %rax
	leaq	133(%rsp), %r9
	shrq	$5, %rax
	addq	$2, %rax
	movq	%rax, 32(%rsp)
	leaq	-32(%rcx), %rax
	shrq	$5, %rax
	addq	$1, %rax
	movq	%rax, 24(%rsp)
	movl	$1, %eax
	movl	%eax, %r10d
.L1152:
	movzbl	(%rdi), %r12d
	movq	%r13, %rsi
	movzwl	8(%rsp), %ecx
	salq	$5, %rsi
	cmpb	$13, %r12b
	je	.L1201
	cmpq	%r13, 24(%rsp)
	je	.L1202
	cmpq	$129, %r13
	je	.L1203
	movw	%r13w, 22(%rsp)
	xorl	%eax, %eax
	jmp	.L1136
	.p2align 4,,10
	.p2align 3
.L1204:
	movzbl	(%rdi,%rax), %r12d
.L1136:
	movb	%r12b, 42(%rbx,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1204
	movzbl	-11(%r9), %r14d
	testb	%r14b, %r14b
	je	.L1137
	cmpl	$1, %r13d
	jbe	.L1138
	leal	-1(%r13), %r12d
	xorl	%esi, %esi
	salq	$4, %r12
	.p2align 4,,10
	.p2align 3
.L1139:
	movq	%r15, %rax
	movl	%r14d, %edx
	jmp	.L1142
	.p2align 4,,10
	.p2align 3
.L1206:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1142:
	leaq	(%rax,%r8), %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.L1205
	cmpq	%r9, %rax
	jne	.L1206
	movzwl	22(%rsp), %eax
	movl	$.LC45, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC46, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
	.p2align 4,,10
	.p2align 3
.L1205:
	addq	$16, %rsi
	cmpq	%r12, %rsi
	jne	.L1139
.L1138:
	movzbl	11(%rdi), %edx
	movzbl	16(%rdi), %eax
	movw	%r10w, 3(%r9)
	movzbl	17(%rdi), %ecx
	movb	%dl, (%r9)
	movb	%al, 1(%r9)
	movb	%cl, 2(%r9)
	testb	%al, %al
	je	.L1207
	cmpb	$67, %dl
	je	.L1208
	cmpb	$78, %dl
	je	.L1209
	cmpb	$76, %dl
	je	.L1210
	cmpb	$68, %dl
	jne	.L1149
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	je	.L1145
	movzwl	22(%rsp), %eax
	movl	$.LC25, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC26, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
	.p2align 4,,10
	.p2align 3
.L1199:
	movl	$.LC5, %esi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1123
.L1200:
	movl	$.LC6, %esi
	call	dset.constprop.0
	movzbl	(%r10), %esi
	movq	%rbp, %rdi
	call	dhex
	movl	$.LC7, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$2, %eax
	jmp	.L1123
.L1208:
	testb	%cl, %cl
	jne	.L1211
.L1145:
	addl	%eax, %r10d
	cmpl	$65535, %r10d
	ja	.L1212
	addq	$1, %r13
	addq	$32, %rdi
	addq	$16, %rbx
	addq	$16, %r15
	addl	$1, 8(%rsp)
	subq	$16, %r8
	addq	$16, %r9
	movl	$1, %edx
	cmpq	%r13, 32(%rsp)
	jne	.L1152
	movl	$.LC30, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1123
.L1209:
	cmpb	$17, %cl
	ja	.L1169
	cmpb	%cl, %al
	ja	.L1145
.L1169:
	movzwl	22(%rsp), %eax
	movl	$.LC19, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movslq	8(%rsp), %r11
	movq	%rbp, %rdi
	leal	2(%r11), %eax
	addq	$2, %r11
	cltq
	salq	$4, %r11
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC20, %esi
	call	dcat
	movzbl	102(%rsp,%r11), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC21, %esi
	movq	%rbp, %rdi
	call	dcat
	movzbl	103(%rsp,%r11), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC22, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$4, %eax
	jmp	.L1123
	.p2align 4,,10
	.p2align 3
.L1210:
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.L1145
	movzwl	22(%rsp), %eax
	movl	$.LC23, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC24, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
	.p2align 4,,10
	.p2align 3
.L1202:
	leal	1(%rcx), %r8d
	movl	$1, %eax
	testb	%dl, %dl
	movl	$.LC11, %esi
	movzwl	%r8w, %r8d
	movq	%rbp, %rdi
	cmove	%rax, %r8
	call	dset.constprop.0
	movq	%rbp, %rdi
	movq	%r8, %rsi
	call	ddec
	movl	$.LC12, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
.L1203:
	movl	$.LC13, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$4, %eax
	jmp	.L1123
.L1201:
	movl	%r10d, %ebx
	movq	40(%rsp), %r10
	testb	%dl, %dl
	je	.L1130
	movw	%cx, 116(%rsp)
	testw	%cx, %cx
	je	.L1130
	addq	$1, %rsi
	cmpl	%ebx, 16(%rsp)
	je	.L1154
	jmp	.L1213
	.p2align 4,,10
	.p2align 3
.L1155:
	addq	$1, %rsi
	cmpb	$0, -1(%r10,%rsi)
	jne	.L1214
.L1154:
	cmpq	(%rsp), %rsi
	jb	.L1155
	movl	%ebx, %ecx
	movq	%r11, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%rcx
	movl	12(%rsp), %r13d
	movq	%rax, %r12
	cmpq	%rax, %r13
	ja	.L1215
	movq	%r13, %rax
	imulq	%rcx, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r11
	je	.L1157
	movq	%r11, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1158
	cmpb	$26, (%r10,%rax)
	je	.L1157
.L1158:
	movl	$.LC38, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1123
.L1137:
	movl	$.LC11, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC14, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
.L1207:
	movzwl	22(%rsp), %eax
	movl	$.LC15, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC16, %esi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
.L1214:
	movl	$.LC34, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1123
.L1212:
	movl	$.LC29, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$4, %eax
	jmp	.L1123
.L1211:
	movzwl	22(%rsp), %eax
	movl	$.LC17, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC18, %esi
	call	dcat
	movl	$3, %eax
	jmp	.L1123
.L1213:
	movl	$.LC32, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	%ebx, %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC33, %esi
	movq	%rbp, %rdi
	call	dcat
	movzwl	20(%rsp), %esi
	movq	%rbp, %rdi
	call	ddec
	movl	$1, %eax
	jmp	.L1123
.L1130:
	movl	$.LC31, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1123
.L1149:
	movzwl	22(%rsp), %eax
	movl	$.LC15, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call	dset.constprop.0
	movl	8(%rsp), %ebx
	movq	%rbp, %rdi
	leal	2(%rbx), %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call	dname
	movl	$.LC27, %esi
	call	dcat
	movslq	%ebx, %rax
	leaq	48(%rsp), %rsi
	movq	%rbp, %rdi
	salq	$4, %rax
	movb	$0, 49(%rsp)
	movzbl	133(%rsp,%rax), %eax
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	movb	%al, 48(%rsp)
	call	dcat
	movl	$.LC28, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$3, %eax
	jmp	.L1123
.L1157:
	cmpl	$0, 12(%rsp)
	movq	(%rsp), %rbx
	movq	%r10, 80(%rsp)
	sete	%al
	movq	%r11, 88(%rsp)
	xorl	%r14d, %r14d
	movb	$1, 120(%rsp)
	addq	%r10, %rbx
	movb	%al, 119(%rsp)
	movb	%al, 118(%rsp)
	testq	%r13, %r13
	je	.L1166
	movq	%rbp, (%rsp)
	movq	%rcx, %rbp
.L1165:
	movzbl	(%rbx), %r12d
	addq	$1, %r14
	cmpb	$32, %r12b
	je	.L1160
	cmpb	$42, %r12b
	jne	.L1216
.L1160:
	movq	%r14, 104(%rsp)
	movl	$1, %r15d
	jmp	.L1164
.L1161:
	addl	$1, %r15d
	cmpl	8(%rsp), %r15d
	ja	.L1217
.L1164:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call	hrdbf_get
	testl	%eax, %eax
	je	.L1161
	movq	(%rsp), %rbp
	movl	$.LC39, %esi
	movl	%eax, 8(%rsp)
	movq	%rbp, %rdi
	call	dset.constprop.0
	movq	%r14, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC42, %esi
	movq	%rbp, %rdi
	leal	-1(%r15), %r10d
	call	dcat
	leal	1(%r15), %edx
	movq	%rbp, %rdi
	salq	$4, %rdx
	leaq	90(%rsp,%rdx), %rsi
	call	dname
	movl	8(%rsp), %eax
	movl	$.LC4, %edx
	movl	$.LC3, %esi
	cmpl	$4, %eax
	movl	%eax, (%rsp)
	cmovne	%rdx, %rsi
	call	dcat
	movl	%r10d, %edx
	movl	(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 133(%rsp,%rdx)
	je	.L1218
.L1163:
	cmpb	$42, %r12b
	jne	.L1123
	movl	$.LC44, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call	dcat
	movl	(%rsp), %eax
	jmp	.L1123
.L1217:
	addq	%rbp, %rbx
	cmpq	%r14, %r13
	jne	.L1165
	movq	(%rsp), %rbp
.L1166:
	movl	$282, %ecx
	movq	%rbp, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.L1123
.L1215:
	movl	$.LC35, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC36, %esi
	movq	%rbp, %rdi
	call	dcat
	movq	%r12, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC37, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$1, %eax
	jmp	.L1123
.L1216:
	movq	(%rsp), %rbp
	movl	$.LC39, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movq	%r14, %rsi
	movq	%rbp, %rdi
	call	ddec
	movl	$.LC40, %esi
	movq	%rbp, %rdi
	call	dcat
	movzbl	%r12b, %esi
	movq	%rbp, %rdi
	call	dhex
	movl	$.LC41, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$5, %eax
	jmp	.L1123
.L1218:
	movl	$.LC43, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	(%rsp), %eax
	jmp	.L1163
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
	ja	.L1221
	je	.L1241
	cmpl	$5, %edx
	je	.L1224
	shrq	$8, %rdi
	jne	.L1242
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.L1221
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.L1221
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.L1221
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.L1221
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
	ja	.L1237
	testq	%rsi, %rsi
	je	.L1237
	movl	days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1243
.L1226:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1241:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.L1221
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.L1244
.L1221:
	ret
	.p2align 4,,10
	.p2align 3
.L1224:
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
.L1244:
	testb	$-1, %dh
	jne	.L1221
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
.L1242:
	ret
	.p2align 4,,10
	.p2align 3
.L1237:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1243:
	testb	$3, %cl
	jne	.L1226
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1227
	addl	$1, %eax
	jmp	.L1226
.L1227:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.L1226
	.size	hrv_validate, .-hrv_validate
	.p2align 4
	.globl	hrv_valtype
	.type	hrv_valtype, @function
hrv_valtype:
	endbr64
	movzbl	%dil, %edx
	movl	$63, %eax
	cmpb	$12, %dil
	ja	.L1245
	movzbl	CSWTCH.411(%rdx), %eax
.L1245:
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
	jne	.L1248
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.L1258
	testl	%edx, %edx
	je	.L1251
	cmpl	$9, %edx
	je	.L1251
	movl	$1, %eax
.L1248:
	ret
	.p2align 4,,10
	.p2align 3
.L1258:
	testl	$65280, %r9d
	jne	.L1259
.L1251:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1259:
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
	jne	.L1260
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1260
	movzbl	%r9b, %r13d
	movzbl	%r11b, %r12d
	cmpb	$11, %r9b
	jne	.L1262
	cmpl	$11, %r12d
	jne	.L1262
.L1273:
	xorl	%edx, %edx
	cmpq	%rbp, %r10
	sete	%dl
	movl	%edx, (%rbx)
.L1260:
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1262:
	cmpl	$1, %r13d
	je	.L1276
	cmpl	$1, %r12d
	je	.L1276
	cmpl	$3, %r13d
	jne	.L1265
	cmpl	$3, %r12d
	jne	.L1265
	testq	%r10, %r10
	sete	%dl
	testq	%rbp, %rbp
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1260
	.p2align 4,,10
	.p2align 3
.L1276:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1260
	.p2align 4,,10
	.p2align 3
.L1265:
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1269
	cmpl	$12, %r13d
	je	.L1299
	testl	%r13d, %r13d
	je	.L1268
	cmpl	$9, %r13d
	jne	.L1269
.L1268:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1269
	cmpl	$12, %r12d
	je	.L1300
	testl	%r12d, %r12d
	je	.L1273
	cmpl	$9, %r12d
	je	.L1273
	.p2align 4,,10
	.p2align 3
.L1269:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1301
.L1275:
	movl	$1, %eax
	jmp	.L1260
	.p2align 4,,10
	.p2align 3
.L1299:
	testl	$65280, %r9d
	je	.L1268
	jmp	.L1269
	.p2align 4,,10
	.p2align 3
.L1301:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1275
	xorl	%edx, %edx
	movsd	16(%rsp), %xmm0
	ucomisd	24(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1260
	.p2align 4,,10
	.p2align 3
.L1300:
	testl	$65280, %r11d
	je	.L1273
	jmp	.L1269
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
	jne	.L1302
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	je	.L1323
.L1302:
	addq	$40, %rsp
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1323:
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1304
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L1324
	testl	%eax, %eax
	je	.L1306
	cmpl	$9, %eax
	je	.L1306
	.p2align 4,,10
	.p2align 3
.L1304:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1325
.L1312:
	addq	$40, %rsp
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1325:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1312
	movsd	16(%rsp), %xmm1
	movsd	24(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1313
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1313:
	movq	%rdx, (%r11)
	jmp	.L1302
	.p2align 4,,10
	.p2align 3
.L1324:
	testl	$65280, %r9d
	jne	.L1304
.L1306:
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1304
	movzbl	%r10b, %edx
	cmpb	$12, %r10b
	je	.L1326
	testl	%edx, %edx
	je	.L1309
	cmpl	$9, %edx
	jne	.L1304
.L1309:
	xorl	%edx, %edx
	cmpq	%rbp, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%r11)
	jmp	.L1302
	.p2align 4,,10
	.p2align 3
.L1326:
	testl	$65280, %r10d
	je	.L1309
	jmp	.L1304
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
	jne	.L1327
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.L1331
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.L1329
	cmpl	$1, %ecx
	je	.L1332
.L1331:
	movl	$1, %eax
.L1327:
	ret
	.p2align 4,,10
	.p2align 3
.L1329:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1332:
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
	jne	.L1333
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.L1380
	cmpl	$12, %eax
	jne	.L1359
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
.L1341:
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
	ja	.L1341
	cmpl	%r12d, %r10d
	jb	.L1381
	movl	$1, %esi
.L1342:
	leal	1(%rsi,%r10), %eax
.L1343:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.L1344
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.L1382
	subl	%eax, %r14d
	je	.L1352
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1351:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1351
.L1352:
	testq	%r11, %r11
	jns	.L1350
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.L1350:
	testl	%esi, %esi
	je	.L1353
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.L1355
	.p2align 4,,10
	.p2align 3
.L1363:
	movl	%edx, %eax
.L1355:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1354
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1354:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.L1363
	addl	%esi, %r14d
.L1353:
	testl	%r10d, %r10d
	je	.L1333
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.L1357:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1356
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1356:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.L1357
.L1333:
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
.L1380:
	cmpq	$7, %rbx
	jbe	.L1344
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.L1337
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.L1339:
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
	jne	.L1339
	jmp	.L1333
	.p2align 4,,10
	.p2align 3
.L1359:
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
.L1381:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.L1342
	movl	%esi, %eax
	jmp	.L1343
	.p2align 4,,10
	.p2align 3
.L1344:
	movl	$3, %r8d
	jmp	.L1333
	.p2align 4,,10
	.p2align 3
.L1337:
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
	jmp	.L1333
	.p2align 4,,10
	.p2align 3
.L1382:
	testl	%r14d, %r14d
	je	.L1333
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1347:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.L1347
	jmp	.L1333
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
	jne	.L1383
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1383
	leal	-43(%rbx), %eax
	movq	%r9, %r14
	andl	$-3, %eax
	movl	%eax, %r15d
	je	.L1423
	cmpl	$42, %ebx
	je	.L1423
	cmpl	$47, %ebx
	je	.L1398
	cmpl	$37, %ebx
	je	.L1425
	movl	$1, %r10d
	cmpl	$94, %ebx
	je	.L1425
.L1383:
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
.L1423:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1398
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1446
	testl	%eax, %eax
	je	.L1389
	cmpl	$9, %eax
	je	.L1389
	.p2align 4,,10
	.p2align 3
.L1398:
	leaq	16(%rsp), %rcx
	leaq	32(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1383
	leaq	24(%rsp), %rcx
	leaq	40(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1383
	movsd	40(%rsp), %xmm1
	cmpl	$43, %ebx
	je	.L1447
	testl	%r15d, %r15d
	je	.L1448
	cmpl	$42, %ebx
	je	.L1449
	ucomisd	.LC47(%rip), %xmm1
	jp	.L1424
	je	.L1418
.L1424:
	movsd	32(%rsp), %xmm0
	movl	$517, %eax
	divsd	%xmm1, %xmm0
.L1401:
	movq	%rax, (%r14)
	movsd	%xmm0, 8(%r14)
	jmp	.L1383
	.p2align 4,,10
	.p2align 3
.L1446:
	testl	$65280, %r11d
	jne	.L1398
.L1389:
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1398
	movzbl	%r12b, %eax
	cmpb	$12, %r12b
	je	.L1450
	testl	%eax, %eax
	je	.L1392
	cmpl	$9, %eax
	jne	.L1398
.L1392:
	movq	$0, (%r14)
	cmpl	$43, %ebx
	je	.L1451
	testl	%r15d, %r15d
	je	.L1452
	imulq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1383
	.p2align 4,,10
	.p2align 3
.L1425:
	movq	%rsp, %rcx
	leaq	8(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1383
	leaq	4(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1383
	movsd	16(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1407
	ucomisd	.LC47(%rip), %xmm0
	jp	.L1408
	jne	.L1408
	movq	$0, (%r14)
	movq	$0, 8(%r14)
	jmp	.L1383
	.p2align 4,,10
	.p2align 3
.L1450:
	testl	$65280, %r12d
	je	.L1392
	jmp	.L1398
	.p2align 4,,10
	.p2align 3
.L1449:
	movl	$255, %edx
	movl	24(%rsp), %eax
	addl	16(%rsp), %eax
	cmpl	%edx, %eax
	movsd	32(%rsp), %xmm0
	cmova	%rdx, %rax
	mulsd	%xmm1, %xmm0
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1401
	.p2align 4,,10
	.p2align 3
.L1418:
	movl	$5, %r10d
	jmp	.L1383
	.p2align 4,,10
	.p2align 3
.L1447:
	addsd	32(%rsp), %xmm1
	movapd	%xmm1, %xmm0
.L1444:
	movl	24(%rsp), %eax
	movl	16(%rsp), %edx
	cmpl	%edx, %eax
	cmovb	%rdx, %rax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1401
	.p2align 4,,10
	.p2align 3
.L1448:
	movsd	32(%rsp), %xmm0
	subsd	%xmm1, %xmm0
	jmp	.L1444
	.p2align 4,,10
	.p2align 3
.L1451:
	addq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1383
.L1407:
	movsd	8(%rsp), %xmm1
	movq	%xmm0, %rcx
	movabsq	$9223372036854775807, %rax
	movq	%xmm1, %rsi
	movq	%xmm1, %rdx
	andq	%rax, %rsi
	andq	%rcx, %rax
	testq	%rdx, %rdx
	js	.L1453
	testq	%rsi, %rsi
	jne	.L1417
.L1412:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1410
	testq	%rcx, %rcx
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1410:
	movq	$517, (%r14)
	movq	%rdx, 8(%r14)
	jmp	.L1383
.L1452:
	subq	%r13, %rbp
	xorl	%r10d, %r10d
	movq	%rbp, 8(%r14)
	jmp	.L1383
.L1408:
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
	jmp	.L1410
.L1453:
	testq	%rsi, %rsi
	je	.L1412
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm2
	cmpq	%rdx, %rax
	ja	.L1413
	cvttsd2siq	%xmm2, %rdx
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rdx, %xmm1
	ucomisd	%xmm2, %xmm1
	jp	.L1420
	je	.L1413
.L1420:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1410
.L1417:
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
	jmp	.L1410
.L1413:
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
	ja	.L1445
	cvttsd2siq	%xmm2, %rax
	testb	$1, %al
	je	.L1445
	pxor	%xmm0, %xmm0
	subsd	%xmm1, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1410
.L1445:
	movq	%xmm1, %rdx
	jmp	.L1410
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
	ja	.L1454
	movl	%edi, %edi
	movq	CSWTCH.438(,%rdi,8), %rax
.L1454:
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
	ja	.L1460
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
	je	.L1460
	movabsq	$4503599627370495, %rcx
	andq	%rcx, %rax
	testq	%rdx, %rdx
	je	.L1555
	btsq	$52, %rax
	subl	$1075, %edx
	movl	$2, %edi
	movl	%eax, %ecx
	movslq	%edx, %r9
	shrq	$32, %rax
.L1464:
	movl	%ecx, 224(%rsp)
	leaq	224(%rsp), %r14
	movl	%eax, 228(%rsp)
	movl	%edi, 512(%rsp)
	testl	%ebx, %ebx
	je	.L1471
	xorl	%r10d, %r10d
	xorl	%r8d, %r8d
	leaq	224(%rsp), %r14
	.p2align 4,,10
	.p2align 3
.L1470:
	leal	-1(%rdi), %eax
	movq	%r14, %rdx
	leaq	228(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1472:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %rsi
	jne	.L1472
	testq	%rax, %rax
	je	.L1473
	movl	%edi, %edx
	movl	$1, %r10d
	addl	$1, %edi
	movl	%eax, 224(%rsp,%rdx,4)
.L1473:
	addl	$1, %r8d
	cmpl	%r8d, %ebx
	jne	.L1470
	testb	%r10b, %r10b
	je	.L1471
	movl	%edi, 512(%rsp)
.L1471:
	movl	%ebx, %esi
	addq	%r9, %rsi
	js	.L1476
	movq	%r14, %rdi
	call	bn_shl
	movl	512(%rsp), %r10d
.L1477:
	xorl	%r12d, %r12d
	jmp	.L1483
	.p2align 4,,10
	.p2align 3
.L1484:
	cmpq	$48, %r12
	je	.L1556
	movq	%r14, %rdi
	call	bn_divmod_1e9
	movl	512(%rsp), %r10d
	movl	%eax, 32(%rsp,%r12,4)
	addq	$1, %r12
.L1483:
	movl	%r12d, %r13d
	cmpl	$1, %r10d
	jne	.L1484
	movl	224(%rsp), %eax
	testl	%eax, %eax
	jne	.L1484
	testl	%r12d, %r12d
	jne	.L1557
	movl	$0, 32(%rsp)
	movl	$48, %edx
	movb	$48, 22(%rsp)
.L1489:
	leal	-1(%r10), %eax
	leaq	528(%rsp), %r14
	movq	%rax, %r11
	leaq	529(%rsp,%rax), %rcx
	leal	-1(%r10,%r14), %esi
	movq	%r14, %rax
	jmp	.L1492
	.p2align 4,,10
	.p2align 3
.L1558:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	22(%rsp,%rdx), %edx
.L1492:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1558
	testl	%r13d, %r13d
	je	.L1493
	leaq	32(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	.p2align 4,,10
	.p2align 3
.L1495:
	movl	%r11d, %edi
	movl	(%r12), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L1494:
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
	jne	.L1494
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1559
	movq	%rax, %r12
	jmp	.L1495
	.p2align 4,,10
	.p2align 3
.L1460:
	xorl	%eax, %eax
.L1457:
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
.L1555:
	testq	%rax, %rax
	jne	.L1560
	cmpq	$0, 8(%rsp)
	jne	.L1561
	xorl	%edx, %edx
.L1465:
	testl	%ebx, %ebx
	je	.L1466
	leal	2(%rdx,%rbx), %esi
	cmpl	4(%rsp), %esi
	ja	.L1460
	movl	%edx, %eax
	movb	$48, 0(%rbp,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, 0(%rbp,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1468:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 0(%rbp,%rcx)
	cmpl	%edx, %esi
	jne	.L1468
	addl	%ebx, %eax
	jmp	.L1457
.L1561:
	movl	4(%rsp), %edx
	testl	%edx, %edx
	je	.L1460
	movb	$45, 0(%rbp)
	movl	$1, %edx
	jmp	.L1465
.L1476:
	negl	%esi
	movq	%r14, %rdi
	call	bn_shr_round
	movl	512(%rsp), %r10d
	cmpl	$3, %eax
	je	.L1562
	cmpl	$2, %eax
	jne	.L1477
	movl	224(%rsp), %ecx
	movl	%ecx, %edx
	andl	$1, %edx
	je	.L1477
	testl	%r10d, %r10d
	je	.L1510
.L1480:
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.L1482
	.p2align 4,,10
	.p2align 3
.L1563:
	movl	(%r14,%rdx,4), %ecx
.L1482:
	addq	%rcx, %rax
	movl	%eax, (%r14,%rdx,4)
	addq	$1, %rdx
	shrq	$32, %rax
	cmpl	%edx, %r10d
	ja	.L1563
	testq	%rax, %rax
	je	.L1477
	movl	%r10d, %eax
	addl	$1, %r10d
.L1479:
	movl	%r10d, 512(%rsp)
	movl	$1, 224(%rsp,%rax,4)
	jmp	.L1477
	.p2align 4,,10
	.p2align 3
.L1559:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %r10d
.L1493:
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
	ja	.L1460
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.L1498
	movb	$45, 0(%rbp)
	movl	$1, %edx
.L1498:
	cmpl	%r10d, %ebx
	jnb	.L1499
	testl	%eax, %eax
	je	.L1515
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1501:
	movzbl	(%r14), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1501
.L1500:
	testl	%ebx, %ebx
	je	.L1457
.L1502:
	cmpl	%r10d, %ebx
	movl	%r10d, %edi
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %edi
	movb	$46, 0(%rbp,%rcx)
	subl	%edi, %ebx
	je	.L1503
	leal	1(%rbx,%rax), %esi
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1504:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, 0(%rbp,%rcx)
	cmpl	%esi, %eax
	jne	.L1504
	addl	%ebx, %edx
.L1503:
	subl	%edi, %r10d
	leal	(%rdi,%rdx), %eax
	subl	%edx, %r10d
	.p2align 4,,10
	.p2align 3
.L1505:
	leal	(%r10,%rdx), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	528(%rsp,%rsi), %esi
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1505
	jmp	.L1457
.L1556:
	movl	220(%rsp), %ecx
	movl	$47, %r13d
.L1487:
	movl	$1, %esi
	movl	$3435973837, %r8d
	.p2align 4,,10
	.p2align 3
.L1490:
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
	ja	.L1490
	jmp	.L1489
.L1560:
	movl	%eax, %ecx
	shrq	$32, %rax
	movl	$0, %edx
	movq	$-1074, %r9
	cmpq	$1, %rax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rax, %rax
	cmove	%edx, %eax
	jmp	.L1464
.L1466:
	leal	1(%rdx), %eax
	cmpl	4(%rsp), %eax
	ja	.L1460
	movb	$48, 0(%rbp,%rdx)
	jmp	.L1457
.L1499:
	movb	$48, 0(%rbp,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1502
.L1562:
	testl	%r10d, %r10d
	je	.L1509
	movl	224(%rsp), %ecx
	jmp	.L1480
.L1515:
	movl	%edx, %eax
	jmp	.L1500
.L1510:
	xorl	%eax, %eax
	movl	%edx, %r10d
	jmp	.L1479
.L1509:
	xorl	%eax, %eax
	movl	$1, %r10d
	jmp	.L1479
.L1557:
	leal	-1(%r12), %eax
	movl	32(%rsp,%rax,4), %ecx
	movq	%rax, %r13
	jmp	.L1487
	.size	hrdbf_fmt_fixed, .-hrdbf_fmt_fixed
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.type	hrdbf_fmt_harbour, @function
hrdbf_fmt_harbour:
	endbr64
	cmpl	$32, %edx
	ja	.L1565
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1565:
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
	jne	.L1566
	movzwl	14(%rsi), %eax
	addq	%rax, %rdi
	movzbl	12(%rsi), %eax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	testq	%rcx, %rcx
	je	.L1568
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1569:
	movzbl	(%rdx,%rax), %r8d
	movb	%r8b, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1569
	movzbl	12(%rsi), %eax
.L1568:
	cmpq	%rcx, %rax
	jbe	.L1571
	.p2align 4,,10
	.p2align 3
.L1570:
	movb	$32, (%rdi,%rcx)
	movzbl	12(%rsi), %eax
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L1570
.L1571:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1566:
	ret
	.size	hrdbf_write_char, .-hrdbf_write_char
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.type	hrdbf_write_number_scaled, @function
hrdbf_write_number_scaled:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1580
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1580:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_scaled, .-hrdbf_write_number_scaled
	.p2align 4
	.globl	hrdbf_write_number_double
	.type	hrdbf_write_number_double, @function
hrdbf_write_number_double:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1582
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1582:
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
	jne	.L1583
	movzwl	14(%rsi), %eax
	addq	%rdi, %rax
	testl	%edx, %edx
	je	.L1598
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
	ja	.L1583
	cmpl	$9999, %ecx
	jbe	.L1583
	testl	%edi, %edi
	je	.L1583
	leal	-2(%rdx), %ecx
	movl	$31, %r10d
	cmpl	$9, %ecx
	jbe	.L1599
.L1587:
	movl	$3518437209, %esi
	imulq	%r9, %rsi
	shrq	$45, %rsi
	cmpl	$2, %edx
	je	.L1600
.L1588:
	movl	$5, %r8d
	cmpl	%edi, %r10d
	jb	.L1583
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
.L1583:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1598:
	leaq	8(%rax), %rdx
	.p2align 4,,10
	.p2align 3
.L1586:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1586
	xorl	%r8d, %r8d
	jmp	.L1583
	.p2align 4,,10
	.p2align 3
.L1599:
	movl	CSWTCH.447(,%rcx,4), %r10d
	jmp	.L1587
	.p2align 4,,10
	.p2align 3
.L1600:
	testb	$3, %sil
	jne	.L1588
	imull	$-1030792151, %esi, %ecx
	movl	%ecx, %r8d
	rorl	$2, %r8d
	cmpl	$42949672, %r8d
	ja	.L1589
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L1588
.L1589:
	addl	$1, %r10d
	jmp	.L1588
	.size	hrdbf_write_date, .-hrdbf_write_date
	.p2align 4
	.globl	hrdbf_write_logical
	.type	hrdbf_write_logical, @function
hrdbf_write_logical:
	endbr64
	cmpb	$76, 11(%rsi)
	movl	$3, %eax
	jne	.L1601
	cmpb	$1, %dl
	movzwl	14(%rsi), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	xorl	%eax, %eax
.L1601:
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
	jbe	.L1613
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1612
.L1613:
	movzbl	12(%rsi), %ecx
	testl	%ecx, %ecx
	je	.L1611
	leaq	(%rdi,%rdx), %rax
	subl	$1, %ecx
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1610:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1610
.L1611:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1612:
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
	cmpb	$0, 2288(%rdi)
	movq	$0, (%rdi)
	movq	%rdi, %r8
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movl	$0, 2272(%rdi)
	je	.L1624
	xorl	%edx, %edx
	movq	2280(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, 2288(%r8)
	movq	$0, 2280(%r8)
	testq	%rax, %rax
	js	.L1630
.L1624:
	xorl	%r9d, %r9d
.L1623:
	movq	2256(%r8), %rdi
	testq	%rdi, %rdi
	je	.L1621
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1626
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.L1621:
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1630:
	movl	$7, %r9d
	jmp	.L1623
	.p2align 4,,10
	.p2align 3
.L1626:
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
	.string	" exceeds the 64 MiB limit"
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
	movb	$0, 2289(%rdi)
	sete	%al
	movl	%eax, 2272(%rdi)
	sete	%al
	movq	$-100, %rdi
	movzbl	%al, %eax
	leaq	524288(%rax,%rax), %rdx
	.p2align 4,,10
	.p2align 3
.L1632:
	movq	%r8, %rax
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.L1632
	testq	%rax, %rax
	js	.L1670
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
	js	.L1668
	cmpq	$32, %rax
	jle	.L1671
	cmpq	$67108864, %rax
	jg	.L1672
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1673
	movq	%r13, 2264(%rbp)
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
	jb	.L1641
	movq	$0, 2256(%rbp)
.L1642:
	movq	$0, 2264(%rbp)
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
	js	.L1669
	.p2align 4,,10
	.p2align 3
.L1636:
	movq	%rbp, %rdi
	call	hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r10d
.L1631:
	addq	$24, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1676:
	movq	%rax, %rdx
	movl	$.LC55, %esi
.L1668:
	movq	%rbp, %rdi
	call	ferr
.L1667:
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
	jmp	.L1636
	.p2align 4,,10
	.p2align 3
.L1641:
	movq	%rax, 2256(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L1642
	movq	2264(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.L1643
	.p2align 4,,10
	.p2align 3
.L1644:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L1647:
	movq	%r8, %rax
	movq	%r12, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L1647
	testq	%rax, %rax
	jne	.L1674
	movq	2264(%rbp), %rdx
	movq	2256(%rbp), %rsi
	movq	%rbp, %rdi
	call	hrdbf_open
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1649
	movl	2272(%rbp), %eax
	testl	%eax, %eax
	jne	.L1675
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
	jns	.L1631
	jmp	.L1669
	.p2align 4,,10
	.p2align 3
.L1677:
	movq	2256(%rbp), %rsi
.L1643:
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
	je	.L1645
	testq	%rax, %rax
	jle	.L1676
	addq	%rax, %r8
.L1645:
	movq	2264(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.L1677
	jmp	.L1644
	.p2align 4,,10
	.p2align 3
.L1672:
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
	jns	.L1636
	jmp	.L1669
.L1674:
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
.L1669:
	movl	$7, %r10d
	jmp	.L1636
	.p2align 4,,10
	.p2align 3
.L1671:
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
	jns	.L1636
	jmp	.L1669
.L1670:
	movq	%rax, %rdx
	movl	$.LC50, %esi
	movq	%rbp, %rdi
	call	ferr
	movl	$7, %r10d
	jmp	.L1631
.L1673:
	movl	$.LC51, %esi
	movq	%rbp, %rdi
	call	fset
	jmp	.L1667
.L1649:
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
	jns	.L1636
	jmp	.L1669
.L1675:
	movq	%r12, 2280(%rbp)
	movb	$1, 2288(%rbp)
	jmp	.L1631
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
	je	.L1680
	.p2align 4,,10
	.p2align 3
.L1681:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.L1681
.L1680:
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
	jne	.L1698
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.L1699
	cmpb	$78, %al
	je	.L1700
	cmpb	$68, %al
	je	.L1701
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1699:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.L1702
.L1687:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.L1703
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1701:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1700:
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
.L1702:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.L1690
	.p2align 4,,10
	.p2align 3
.L1689:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1689
.L1690:
	leaq	32(%rsp), %rdi
	jmp	.L1687
.L1698:
	movl	$.LC57, %edi
	call	hrdbf_app_fail
.L1703:
	movl	$.LC58, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.section	.rodata.str1.1
.LC59:
	.string	"hbc: DBF no workarea is open\n"
	.section	.rodata.str1.8
	.align 8
.LC60:
	.string	"hbc: DBF field write requires a readonly=.F. open\n"
	.align 8
.LC61:
	.string	"hbc: DBF field write with an open index is outside this increment\n"
	.align 8
.LC62:
	.string	"hbc: DBF field write with no record positioned\n"
	.text
	.p2align 4
	.type	hrdbf_app_require_writable, @function
hrdbf_app_require_writable:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1709
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.L1710
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L1711
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.L1712
	ret
.L1709:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L1712:
	movl	$.LC62, %edi
	call	hrdbf_app_fail
.L1711:
	movl	$.LC61, %edi
	call	hrdbf_app_fail
.L1710:
	movl	$.LC60, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_require_writable, .-hrdbf_app_require_writable
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
	endbr64
	movb	$0, 2289(%rdi)
	movq	%rdi, %r8
	movq	%rsi, %r10
	movl	%edx, %r9d
	cmpb	$0, 2288(%rdi)
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movl	$0, 2272(%rdi)
	jne	.L1714
	movq	2256(%rdi), %rdi
	testq	%rdi, %rdi
	je	.L1716
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1713
.L1722:
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.L1716:
	movl	%r9d, %edx
	movq	%r10, %rsi
	movq	%r8, %rdi
	jmp	hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.L1714:
	xorl	%edx, %edx
	movq	2280(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, 2288(%r8)
	movq	2256(%r8), %rdi
	movq	$0, 2280(%r8)
	testq	%rax, %rax
	js	.L1726
	testq	%rdi, %rdi
	je	.L1716
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1722
.L1713:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1726:
	testq	%rdi, %rdi
	je	.L1713
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1713
	movq	$0, 2256(%r8)
	movl	$7, %eax
	movq	$0, 2264(%r8)
	ret
	.size	hrdbf_file_open, .-hrdbf_file_open
	.p2align 4
	.globl	hrdbf_file_write_record
	.type	hrdbf_file_write_record, @function
hrdbf_file_write_record:
	endbr64
	movl	2272(%rdi), %edx
	movq	%rdi, %r8
	movl	$6, %eax
	testl	%edx, %edx
	je	.L1727
	cmpb	$0, 2288(%rdi)
	je	.L1727
	cmpb	$0, 40(%rdi)
	je	.L1727
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L1727
	movl	16(%rdi), %edx
	cmpq	%rsi, %rdx
	jb	.L1727
	leaq	-1(%rsi), %r10
	movzwl	34(%rdi), %edx
	movzwl	32(%rdi), %eax
	movl	$18, %r9d
	movq	%r10, %rsi
	imulq	%rdx, %rsi
	leaq	(%rsi,%rax), %r10
	movq	2256(%rdi), %rsi
	addq	%r10, %rsi
	testq	%rdx, %rdx
	je	.L1731
	.p2align 4,,10
	.p2align 3
.L1729:
	movq	2280(%r8), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L1729
	testq	%rax, %rax
	jle	.L1737
	cmpq	%rdx, %rax
	ja	.L1737
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L1729
.L1731:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1737:
	movl	$7, %eax
.L1727:
	ret
	.size	hrdbf_file_write_record, .-hrdbf_file_write_record
	.p2align 4
	.globl	hrdbf_file_append
	.type	hrdbf_file_append, @function
hrdbf_file_append:
	endbr64
	movl	2272(%rdi), %eax
	testl	%eax, %eax
	je	.L1746
	cmpb	$0, 2288(%rdi)
	je	.L1746
	cmpb	$0, 40(%rdi)
	je	.L1746
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1746:
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
	je	.L1753
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.L1758:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1771
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1757
	.p2align 4,,10
	.p2align 3
.L1755:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1771
.L1757:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.L1755
	jnb	.L1771
	leal	1(%rdi), %r10d
.L1754:
	cmpl	%r11d, %r10d
	jb	.L1758
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1762
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.L1761:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.L1763
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1764
	.p2align 4,,10
	.p2align 3
.L1796:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1763
.L1764:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.L1796
.L1762:
	testl	%ebp, %ebp
	je	.L1752
	testl	%r12d, %r12d
	jne	.L1797
	movl	%r10d, %r11d
.L1752:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1771:
	movl	%edi, %r11d
	jmp	.L1754
.L1763:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.L1752
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1765
	.p2align 4,,10
	.p2align 3
.L1770:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1766
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1769
	.p2align 4,,10
	.p2align 3
.L1767:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1766
.L1769:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.L1767
	jb	.L1766
	movl	%edi, %r11d
.L1768:
	cmpl	%r11d, %r10d
	jb	.L1770
.L1765:
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
.L1766:
	leal	1(%rdi), %r10d
	jmp	.L1768
.L1797:
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
.L1753:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.L1752
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.L1761
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata.str1.1
.LC63:
	.string	"hbc: DBF/NTX close failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_close
	.type	hrdbf_app_close, @function
hrdbf_app_close:
	endbr64
	movq	hrdbf_app_order+32(%rip), %rdi
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.L1799
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
	js	.L1799
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L1799:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1800
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1811
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1800:
	cmpb	$0, hrdbf_app_state+2288(%rip)
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+2272(%rip)
	je	.L1805
	xorl	%edx, %edx
	movq	hrdbf_app_state+2280(%rip), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movb	$0, hrdbf_app_state+2288(%rip)
	movq	$0, hrdbf_app_state+2280(%rip)
	testq	%rax, %rax
	js	.L1818
.L1805:
	movq	hrdbf_app_state+2256(%rip), %rdi
	xorl	%r9d, %r9d
	testq	%rdi, %rdi
	je	.L1803
.L1802:
	movq	hrdbf_app_state+2264(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1806
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%r9d, %r8d
	movq	$0, hrdbf_app_state+2264(%rip)
.L1803:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	testl	%r8d, %r8d
	jne	.L1808
	ret
	.p2align 4,,10
	.p2align 3
.L1818:
	movq	hrdbf_app_state+2256(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1806
	movl	$7, %r9d
	jmp	.L1802
	.p2align 4,,10
	.p2align 3
.L1811:
	movl	$7, %r8d
	jmp	.L1800
.L1806:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
.L1808:
	movl	$.LC63, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata.str1.1
.LC64:
	.string	"table format not supported"
	.section	.rodata.str1.8
	.align 8
.LC65:
	.string	"hbc: DBF only one workarea is supported\n"
	.align 8
.LC66:
	.string	"hbc: DBF filename length outside supported range\n"
	.align 8
.LC67:
	.string	"hbc: DBF filename contains NUL\n"
	.section	.rodata.str1.1
.LC68:
	.string	"hbc: DBF index close failed\n"
	.section	.rodata.str1.8
	.align 8
.LC69:
	.string	"hbc: DBF open mode outside supported range\n"
	.section	.rodata.str1.1
.LC70:
	.string	"hbc: DBF open rejected: "
.LC71:
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
	movq	%rcx, %r12
	movq	%r8, %rbp
	testq	%rdx, %rdx
	je	.L1820
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.L1894
.L1820:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.L1895
	xorl	%r9d, %r9d
	jmp	.L1821
	.p2align 4,,10
	.p2align 3
.L1865:
	movq	%rbx, %r9
.L1821:
	movzbl	(%r10,%r9), %eax
	testb	%al, %al
	je	.L1896
	leaq	1(%r9), %rbx
	movb	%al, (%rsp,%r9)
	movq	%rsp, %r13
	cmpq	%rbx, %rsi
	jne	.L1865
	movq	hrdbf_app_order+32(%rip), %r14
	movb	$0, (%rsp,%rbx)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r14, %r14
	je	.L1897
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r14, %rdi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1898
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1829
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1830
.L1831:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1829:
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%r12, %r12
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	cmpq	$2, %rbp
	ja	.L1899
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1834:
	movzbl	(%r10,%rdx), %esi
	movq	%rdx, %rcx
	addq	$1, %rdx
	cmpb	$47, %sil
	cmove	%rdx, %rax
	cmpq	%rcx, %r9
	jne	.L1834
	cmpq	%rbx, %rax
	jb	.L1837
	jmp	.L1900
	.p2align 4,,10
	.p2align 3
.L1866:
	movq	%rdx, %rax
.L1837:
	cmpb	$46, (%r10,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rbx
	cmpq	%r9, %rax
	jne	.L1866
	movq	%rbx, hrdbf_app_baselen(%rip)
	testq	%rbx, %rbx
	je	.L1838
.L1863:
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.L1840:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rbx, %rdx
	jb	.L1840
.L1838:
	movl	$hrdbf_app_state, %edi
	movb	$0, hrdbf_app_state+2289(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	jne	.L1841
	movl	%ebp, %edx
	movq	%r13, %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L1841
	testq	%r12, %r12
	je	.L1819
	leaq	4(%rbx), %rax
	cmpq	$4095, %rax
	jbe	.L1901
.L1819:
	addq	$4096, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1898:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1830
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1830
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1830:
	movl	$.LC68, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1897:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1829
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r14, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1831
	jmp	.L1830
.L1901:
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
.L1851:
	movq	%r9, %rax
	movq	%r13, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r8
	cmpq	$-4, %rax
	je	.L1851
	cmpq	$-2, %rax
	je	.L1819
	cmpq	$-20, %rax
	je	.L1819
	testq	%rax, %rax
	js	.L1852
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r8, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1852:
	cmpq	$1, %rbp
	je	.L1902
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.L1854
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.L1819
.L1900:
	movq	%rbx, hrdbf_app_baselen(%rip)
	jmp	.L1863
.L1854:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.L1855
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
	js	.L1903
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1860
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1857
.L1862:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1860:
	movl	$1, %esi
	movq	%r13, %rdi
	call	hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.L1857
.L1858:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.L1819
.L1902:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.L1819
.L1855:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1860
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1862
.L1857:
	movl	$3, %eax
	jmp	.L1858
.L1896:
	movl	$.LC67, %edi
	call	hrdbf_app_fail
.L1903:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1857
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1857
	movq	$0, hrdbf_app_order+40(%rip)
	movl	$3, %eax
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.L1858
.L1895:
	movl	$.LC66, %edi
	call	hrdbf_app_fail
.L1894:
	movl	$.LC65, %edi
	call	hrdbf_app_fail
.L1841:
	cmpb	$0, hrdbf_app_state+2289(%rip)
	movl	$hrdbf_app_state+2289, %r8d
	movl	$hrdbf_app_state+2090, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.L1844
	subl	$2, %eax
	movl	$.LC64, %r8d
	cmpl	$6, %eax
	ja	.L1844
	movq	CSWTCH.477(,%rax,8), %r8
.L1844:
	xorl	%edx, %edx
.L1845:
	addq	$1, %rdx
	cmpb	$0, .LC70(%rdx)
	jne	.L1845
	movl	$1, %eax
	movl	$2, %edi
	movl	$.LC70, %esi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.L1846
.L1847:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.L1847
.L1846:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC71, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrdbf_app_exit
.L1899:
	movl	$.LC69, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1911
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1906
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L1907
.L1906:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1907:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L1909
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.L1910:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1909:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.L1910
.L1911:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1921
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1914
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1914
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rdx
	testl	%esi, %esi
	jne	.L1922
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.L1918:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
.L1919:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%edx, %edx
	sete	%dl
.L1916:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%dl, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1922:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.L1918
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
	jmp	.L1919
	.p2align 4,,10
	.p2align 3
.L1914:
	movl	hrdbf_app_state+16(%rip), %edx
	movl	$1, %eax
	testl	%edx, %edx
	cmovne	%rdx, %rax
	sete	%dl
	movl	%edx, %ecx
	jmp	.L1916
.L1921:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	movq	%rdi, %rsi
	je	.L1938
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1925
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1925
	testq	%rdi, %rdi
	je	.L1923
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.L1928
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.L1934
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.L1929:
	movq	%rsi, hrdbf_app_pos(%rip)
.L1930:
	cmpq	%rax, %rsi
	jnb	.L1932
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.L1933:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.L1923:
	ret
	.p2align 4,,10
	.p2align 3
.L1925:
	movl	$hrdbf_app_state, %edi
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L1934:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.L1929
	.p2align 4,,10
	.p2align 3
.L1932:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.L1933
	.p2align 4,,10
	.p2align 3
.L1928:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.L1931
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	jmp	.L1930
	.p2align 4,,10
	.p2align 3
.L1931:
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.L1930
.L1938:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata.str1.8
	.align 8
.LC72:
	.string	"hbc: CDX direct character key field width must be <=240\n"
	.align 8
.LC73:
	.string	"hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\n"
	.align 8
.LC74:
	.string	"hbc: DBF index filename length outside supported range\n"
	.align 8
.LC75:
	.string	"hbc: DBF index filename contains NUL\n"
	.align 8
.LC76:
	.string	"hbc: structural CDX on a readonly=.F. open is outside this increment (index maintenance)\n"
	.align 8
.LC77:
	.string	"hbc: structural CDX present but not admitted (one tag, subset, size or format)\n"
	.align 8
.LC78:
	.string	"hbc: structural CDX on a shared=.T. open is outside this increment (index lock protocol)\n"
	.align 8
.LC79:
	.string	"hbc: DBF index on a shared=.T. open is outside this increment (index lock protocol)\n"
	.align 8
.LC80:
	.string	"hbc: DBF index only one index is supported\n"
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
	endbr64
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$8, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2001
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.L2002
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1941:
	movzbl	(%rdi,%rax), %ecx
	testb	%cl, %cl
	je	.L2003
	movb	%cl, (%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %cl
	cmove	%rax, %rdx
	cmpq	%rsi, %rax
	jne	.L1941
	movq	%rsi, %rax
	xorl	%ecx, %ecx
	cmpq	%rsi, %rdx
	jnb	.L1944
	movl	$1, %r8d
	.p2align 4,,10
	.p2align 3
.L1946:
	cmpb	$46, (%rdi,%rdx)
	cmove	%rdx, %rax
	cmove	%r8d, %ecx
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.L1946
.L1944:
	movl	hrdbf_app_cdx(%rip), %r9d
	testl	%r9d, %r9d
	jne	.L2004
.L1947:
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	jne	.L2005
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2006
	testl	%ecx, %ecx
	je	.L2007
.L1957:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, (%rsp,%rsi)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.L1959
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
	js	.L2008
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1964
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1968
.L1966:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1964:
	movl	%r9d, %esi
	movq	%rsp, %rdi
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2009
.L1967:
	movl	$1, hrdbf_app_order_active(%rip)
	call	hrdbf_app_top
	addq	$4104, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L2004:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.L1947
	testq	%rax, %rax
	je	.L1948
	movl	$1, %r10d
	xorl	%r8d, %r8d
	xorl	%ebp, %ebp
	.p2align 4,,10
	.p2align 3
.L1951:
	movzbl	(%rdi,%r8), %edx
	leal	-97(%rdx), %ebx
	leal	-32(%rdx), %r11d
	cmpb	$26, %bl
	cmovb	%r11d, %edx
	cmpb	%dl, hrdbf_app_basename(%r8)
	cmovne	%ebp, %r10d
	addq	$1, %r8
	cmpq	%rax, %r8
	jne	.L1951
	testl	%r10d, %r10d
	je	.L1947
.L1948:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.L1967
	cmpl	$2, %eax
	je	.L2010
	cmpl	$3, %eax
	je	.L2011
	cmpl	$4, %eax
	jne	.L1947
	movl	$.LC78, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2007:
	cmpl	$1, %r9d
	movb	$46, (%rsp,%rsi)
	sbbl	%edx, %edx
	andl	$11, %edx
	addl	$99, %edx
	cmpl	$1, %r9d
	sbbl	%eax, %eax
	movb	%dl, 1(%rsp,%rsi)
	leaq	3(%rsi), %rdx
	andl	$16, %eax
	addl	$100, %eax
	movb	%al, 2(%rsp,%rsi)
	addq	$4, %rsi
	movb	$120, (%rsp,%rdx)
	jmp	.L1957
	.p2align 4,,10
	.p2align 3
.L2008:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1968
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1968
	movq	$0, hrdbf_app_order+40(%rip)
	movl	$.LC73, %edi
	movq	$0, hrdbf_app_order+56(%rip)
.L1962:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1959:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1964
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1966
.L1968:
	movl	$.LC73, %edi
	jmp	.L1962
	.p2align 4,,10
	.p2align 3
.L2003:
	movl	$.LC75, %edi
	call	hrdbf_app_fail
.L2002:
	movl	$.LC74, %edi
	call	hrdbf_app_fail
.L2009:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L1968
	cmpl	$3, %eax
	jne	.L1968
	movl	$.LC72, %edi
	jmp	.L1962
.L2005:
	movl	$.LC79, %edi
	call	hrdbf_app_fail
.L2011:
	movl	$.LC77, %edi
	call	hrdbf_app_fail
.L2010:
	movl	$.LC76, %edi
	call	hrdbf_app_fail
.L2001:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2006:
	movl	$.LC80, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2026
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.L2027
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
	js	.L2017
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L2021
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2020
.L2022:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2021:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2017:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2020
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L2020
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L2020:
	movl	$.LC68, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2027:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L2021
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L2022
	jmp	.L2020
.L2026:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2030
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2030:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.LC81:
	.string	"hbc: DBF index seek requires an open index\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2038
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2033
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2033
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
	jb	.L2039
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.L2036:
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
.L2039:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.L2036
.L2033:
	movl	$.LC81, %edi
	call	hrdbf_app_fail
.L2038:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.section	.rodata.str1.8
	.align 8
.LC82:
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
	je	.L2078
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2042
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2042
	movq	%rdi, %rax
	movq	%rdx, %r12
	movq	%rsi, %rdi
	movzbl	%al, %edx
	leal	-2(%rdx), %esi
	andl	$-3, %esi
	je	.L2079
	testl	%edx, %edx
	je	.L2057
	cmpl	$9, %edx
	je	.L2057
	cmpl	$5, %edx
	je	.L2080
	cmpl	$12, %edx
	je	.L2081
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
.L2079:
	testq	%rdi, %rdi
	je	.L2082
	movq	-8(%rdi), %rsi
	addq	$304, %rsp
	movq	%r12, %rdx
	popq	%r12
	jmp	hrdbf_app_seek
	.p2align 4,,10
	.p2align 3
.L2081:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rdi, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.L2055
	movsd	.LC0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.L2056:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.L2056
.L2055:
	comisd	.LC83(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	ja	.L2057
.L2077:
	movsd	.LC84(%rip), %xmm1
	addq	$1, %rdi
	comisd	%xmm0, %xmm1
	jbe	.L2083
.L2057:
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
.L2080:
	testq	%rax, %rax
	js	.L2084
.L2050:
	movq	%rdi, %xmm0
	comisd	.LC83(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	ja	.L2057
	jmp	.L2077
	.p2align 4,,10
	.p2align 3
.L2083:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L2085
	addsd	.LC85(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2057
	.p2align 4,,10
	.p2align 3
.L2084:
	movq	(%rdi), %rdi
	jmp	.L2050
	.p2align 4,,10
	.p2align 3
.L2085:
	subsd	.LC85(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2057
.L2042:
	movl	$.LC81, %edi
	call	hrdbf_app_fail
.L2078:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2082:
	movl	$.LC82, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek_dyn, .-hrdbf_app_seek_dyn
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2088
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.L2088:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2091
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.L2091:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_fcount
	.type	hrdbf_app_fcount, @function
hrdbf_app_fcount:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2094
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.L2094:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_fcount, .-hrdbf_app_fcount
	.p2align 4
	.globl	hrdbf_app_goto
	.type	hrdbf_app_goto, @function
hrdbf_app_goto:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2106
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %edx
	testq	%rdi, %rdi
	jle	.L2097
	xorl	%eax, %eax
	cmpq	%rdx, %rdi
	ja	.L2097
.L2098:
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rdi, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	je	.L2095
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2107
.L2095:
	ret
	.p2align 4,,10
	.p2align 3
.L2097:
	leaq	1(%rdx), %rdi
	movl	$1, %eax
	jmp	.L2098
	.p2align 4,,10
	.p2align 3
.L2107:
	movl	hrdbf_app_order+24(%rip), %ecx
	testl	%ecx, %ecx
	je	.L2104
	movq	hrdbf_app_order+16(%rip), %rsi
	xorl	%eax, %eax
	jmp	.L2102
	.p2align 4,,10
	.p2align 3
.L2101:
	addq	$1, %rax
	cmpq	%rcx, %rax
	je	.L2100
.L2102:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.L2101
.L2100:
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2104:
	xorl	%eax, %eax
	jmp	.L2100
.L2106:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_goto, .-hrdbf_app_goto
	.p2align 4
	.globl	hrdbf_app_ordselect
	.type	hrdbf_app_ordselect, @function
hrdbf_app_ordselect:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2123
	testq	%rdi, %rdi
	jle	.L2110
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2124
	cmpq	$1, %rdi
	jne	.L2110
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %rdi
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %rsi
	testl	%ecx, %ecx
	jne	.L2116
	jmp	.L2125
	.p2align 4,,10
	.p2align 3
.L2115:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2118
.L2116:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.L2115
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2124:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.L2126
	cmpl	$3, %eax
	je	.L2127
	cmpl	$4, %eax
	je	.L2128
.L2110:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.L2125:
	xorl	%ecx, %ecx
.L2118:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2123:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2126:
	movl	$.LC76, %edi
	call	hrdbf_app_fail
.L2128:
	movl	$.LC78, %edi
	call	hrdbf_app_fail
.L2127:
	movl	$.LC77, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_ordselect, .-hrdbf_app_ordselect
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2131
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.L2131:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2134
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.L2134:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2139
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2135
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2135:
	movq	%r8, %rax
	ret
.L2139:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_deleted, .-hrdbf_app_deleted
	.p2align 4
	.globl	hrdbf_app_get
	.type	hrdbf_app_get, @function
hrdbf_app_get:
	endbr64
	subq	$8, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2146
	testq	%rdi, %rdi
	jle	.L2144
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.L2147
.L2144:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2147:
	call	hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.L2146:
	movl	$.LC59, %edi
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
	je	.L2149
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.L2151
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L2162:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2152:
	cmpb	$0, (%rsi,%rax)
	je	.L2153
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2152
.L2153:
	cmpq	%rax, %r9
	je	.L2174
.L2155:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.L2162
.L2151:
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
	movl	$.LC71, %esi
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
.L2174:
	testq	%r9, %r9
	je	.L2156
	xorl	%ecx, %ecx
	jmp	.L2160
	.p2align 4,,10
	.p2align 3
.L2175:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.L2156
.L2160:
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
	je	.L2175
	cmpq	%rcx, %r9
	jne	.L2155
	.p2align 4,,10
	.p2align 3
.L2156:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.L2176
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.L2176:
	movq	%r12, %rsi
	call	hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.L2149:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata.str1.8
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
	pushq	%r12
	movq	%rdi, %r10
	movq	%rdx, %r12
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$8, %rsp
	call	hrdbf_app_require_writable
	testq	%r10, %r10
	jle	.L2178
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%r10, %rax
	jl	.L2178
	movq	hrdbf_app_state+24(%rip), %rsi
	movzwl	hrdbf_app_state+34(%rip), %edx
	leaq	-1(%r10), %rdi
	addq	$1, %r10
	salq	$4, %r10
	movzbl	%bl, %ecx
	leaq	-1(%rsi), %rax
	leaq	hrdbf_app_state+10(%r10), %r8
	addq	$hrdbf_app_state, %r10
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	%rdx, %rax
	movzbl	21(%r10), %edx
	addq	hrdbf_app_state+2256(%rip), %rax
	cmpb	$76, %dl
	je	.L2180
	ja	.L2181
	cmpb	$67, %dl
	je	.L2182
	cmpb	$68, %dl
	jne	.L2184
	cmpl	$11, %ecx
	je	.L2239
	cmpl	$1, %ecx
	jne	.L2184
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2193
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2204
	.p2align 4,,10
	.p2align 3
.L2240:
	addq	$1, %rdx
.L2204:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2240
.L2189:
	movq	hrdbf_app_state+24(%rip), %rsi
.L2193:
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2241
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2181:
	cmpb	$78, %dl
	jne	.L2184
	cmpl	$12, %ecx
	je	.L2242
	testl	%ecx, %ecx
	je	.L2212
	cmpl	$9, %ecx
	je	.L2212
	cmpl	$5, %ecx
	je	.L2243
	cmpl	$1, %ecx
	jne	.L2184
	salq	$4, %rdi
	movzbl	hrdbf_app_state+54(%rdi), %ecx
	movzwl	hrdbf_app_state+56(%rdi), %edx
	testl	%ecx, %ecx
	je	.L2193
	addq	%rax, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2202
	.p2align 4,,10
	.p2align 3
.L2244:
	addq	$1, %rax
.L2202:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rax, %rcx
	jne	.L2244
	jmp	.L2189
	.p2align 4,,10
	.p2align 3
.L2182:
	leal	-2(%rcx), %edx
	andl	$-3, %edx
	je	.L2245
	cmpl	$1, %ecx
	jne	.L2184
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2193
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2194
	.p2align 4,,10
	.p2align 3
.L2246:
	addq	$1, %rdx
.L2194:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2246
	jmp	.L2189
	.p2align 4,,10
	.p2align 3
.L2180:
	cmpl	$3, %ecx
	je	.L2247
	cmpl	$1, %ecx
	jne	.L2184
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2193
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2207
	.p2align 4,,10
	.p2align 3
.L2248:
	addq	$1, %rdx
.L2207:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2248
	jmp	.L2189
	.p2align 4,,10
	.p2align 3
.L2247:
	cmpq	$1, %r12
	movzwl	24(%r10), %ecx
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rax,%rcx)
	movq	hrdbf_app_state+24(%rip), %rsi
	jmp	.L2193
	.p2align 4,,10
	.p2align 3
.L2245:
	movzwl	24(%r10), %ecx
	movzbl	22(%r10), %edx
	addq	%rax, %rcx
	movq	-8(%r12), %rax
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rax, %rax
	je	.L2187
	movq	%rcx, %rsi
	leaq	(%r12,%rax), %r8
	subq	%r12, %rsi
	.p2align 4,,10
	.p2align 3
.L2188:
	movzbl	(%r12), %edx
	movb	%dl, (%rsi,%r12)
	addq	$1, %r12
	cmpq	%r8, %r12
	jne	.L2188
	movq	%rdi, %rdx
	salq	$4, %rdx
	movzbl	hrdbf_app_state+54(%rdx), %edx
.L2187:
	cmpq	%rdx, %rax
	jnb	.L2189
	salq	$4, %rdi
	leaq	hrdbf_app_state+32(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L2190:
	movb	$32, (%rcx,%rax)
	movzbl	22(%rsi), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2190
	jmp	.L2189
	.p2align 4,,10
	.p2align 3
.L2239:
	movl	%r12d, %edx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_date
.L2196:
	cmpl	$3, %eax
	je	.L2184
	testl	%eax, %eax
	je	.L2189
	movl	$.LC88, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2242:
	movzbl	%bh, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2196
	.p2align 4,,10
	.p2align 3
.L2212:
	xorl	%ecx, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2196
	.p2align 4,,10
	.p2align 3
.L2243:
	testq	%rbx, %rbx
	jns	.L2200
	movq	(%r12), %r12
.L2200:
	movq	%r12, %xmm0
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_double.part.0
	jmp	.L2196
.L2184:
	movl	$.LC87, %edi
	call	hrdbf_app_fail
.L2178:
	movl	$.LC86, %edi
	call	hrdbf_app_fail
.L2241:
	movl	$.LC89, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_fieldput, .-hrdbf_app_fieldput
	.p2align 4
	.globl	hrdbf_app_set_name
	.type	hrdbf_app_set_name, @function
hrdbf_app_set_name:
	endbr64
	pushq	%r12
	movq	%rsi, %r10
	movq	%rcx, %r12
	pushq	%rbp
	movq	%rdx, %rbp
	pushq	%rbx
	movq	%rdi, %rbx
	call	hrdbf_app_require_writable
	movzwl	hrdbf_app_state+36(%rip), %r11d
	testl	%r11d, %r11d
	je	.L2250
	movl	$hrdbf_app_state+42, %esi
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L2260:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2251:
	cmpb	$0, (%rsi,%rax)
	je	.L2252
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2251
.L2252:
	cmpq	%rax, %r10
	je	.L2273
.L2254:
	addl	$1, %r9d
	addq	$16, %rsi
	cmpl	%r9d, %r11d
	jne	.L2260
.L2250:
	movl	$1, %ebp
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbp, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rbp, %rax
	movq	%rbx, %rsi
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC71, %esi
	movq	%rbp, %rax
	movq	%rbp, %rdx
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
	movq	%rbp, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.L2273:
	testq	%r10, %r10
	je	.L2255
	xorl	%ecx, %ecx
	jmp	.L2259
	.p2align 4,,10
	.p2align 3
.L2274:
	addq	$1, %rcx
	cmpq	%rcx, %r10
	je	.L2255
.L2259:
	movzbl	(%rbx,%rcx), %eax
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
	je	.L2274
	cmpq	%rcx, %r10
	jne	.L2254
.L2255:
	popq	%rbx
	movq	%r12, %rdx
	leal	1(%r9), %edi
	movq	%rbp, %rsi
	popq	%rbp
	popq	%r12
	jmp	hrdbf_app_fieldput
	.size	hrdbf_app_set_name, .-hrdbf_app_set_name
	.section	.rodata.str1.1
.LC90:
	.string	"hbc: DBF append failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_append
	.type	hrdbf_app_append, @function
hrdbf_app_append:
	endbr64
	subq	$24, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2283
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.L2284
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2285
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.L2286
	cmpb	$0, hrdbf_app_state+2288(%rip)
	je	.L2281
	leaq	12(%rsp), %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2281
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	12(%rsp), %eax
	addq	$24, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2281:
	movl	$.LC90, %edi
	call	hrdbf_app_fail
.L2283:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2286:
	movl	$.LC62, %edi
	call	hrdbf_app_fail
.L2285:
	movl	$.LC61, %edi
	call	hrdbf_app_fail
.L2284:
	movl	$.LC60, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_append, .-hrdbf_app_append
	.section	.rodata.str1.8
	.align 8
.LC91:
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
	jne	.L2290
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.L2290:
	movl	$.LC91, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.LC92:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.LC93:
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
	jne	.L2292
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L2308
	testl	%eax, %eax
	je	.L2300
	cmpl	$9, %eax
	jne	.L2296
.L2300:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2308:
	testl	$65280, %r9d
	je	.L2300
.L2295:
	movl	$.LC92, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2292:
	cmpl	$2, %eax
	je	.L2295
.L2296:
	movl	$.LC93, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.LC94:
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
	jne	.L2312
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.L2312:
	movl	$.LC94, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.LC95:
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
	jne	.L2314
	cmpb	$11, %dl
	je	.L2321
.L2314:
	leaq	24(%rsp), %r8
	movq	%r9, %rsi
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2322
	movq	24(%rsp), %rax
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2321:
	movq	%rcx, 8(%rsp)
	movq	%rdx, (%rsp)
	call	hrv_validate
	movq	(%rsp), %rdx
	movq	8(%rsp), %rcx
	testl	%eax, %eax
	jne	.L2316
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	%rcx, (%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2316
	movq	(%rsp), %rcx
	xorl	%eax, %eax
	movq	$-1, %rdx
	cmpq	%rcx, %r9
	seta	%al
	cmovb	%rdx, %rax
	addq	$40, %rsp
	ret
.L2322:
	movl	$.LC94, %edi
	call	hrdbf_app_fail
.L2316:
	movl	$.LC95, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.LC96:
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
	jne	.L2324
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.L2334
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.L2326
	.p2align 4,,10
	.p2align 3
.L2346:
	btq	%rax, %rcx
	jc	.L2338
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.L2334
.L2326:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.L2346
.L2338:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2324:
	cmpl	$8, %r10d
	je	.L2347
	cmpl	$5, %r10d
	je	.L2348
	cmpl	$7, %r10d
	je	.L2338
	subq	$8, %rsp
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2331
	cmpl	$12, %r10d
	ja	.L2331
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.L2332
	cmpl	$1, %r10d
	je	.L2339
.L2331:
	movl	$.LC96, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2334:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2347:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L2343
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.L2343:
	ret
	.p2align 4,,10
	.p2align 3
.L2348:
	testq	%rdi, %rdi
	js	.L2349
.L2330:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.LC47(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.L2349:
	movq	(%rsi), %r9
	jmp	.L2330
.L2332:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.L2323:
	addq	$8, %rsp
	ret
.L2339:
	movl	$1, %eax
	jmp	.L2323
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.LC97:
	.string	"hbc: DBF arithmetic division by zero\n"
	.align 8
.LC98:
	.string	"hbc: DBF arithmetic on a NIL or non-numeric operand\n"
	.section	.rodata.str1.1
.LC99:
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
	je	.L2355
	cmpl	$1, %eax
	je	.L2356
	testl	%eax, %eax
	jne	.L2357
	movq	(%rsp), %rax
	movq	8(%rsp), %rdx
	addq	$24, %rsp
	ret
.L2355:
	movl	$.LC97, %edi
	call	hrdbf_app_fail
.L2357:
	movl	$.LC99, %edi
	call	hrdbf_app_fail
.L2356:
	movl	$.LC98, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_arith, .-hrdbf_app_arith
	.section	.rodata.str1.8
	.align 8
.LC100:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
	endbr64
	movl	$.LC100, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.8
	.align 8
.LC101:
	.string	"unsupported table version or header flags"
	.section	.rodata.str1.1
.LC102:
	.string	"unsupported field type"
	.section	.rodata.str1.8
	.align 8
.LC103:
	.string	"size or field-count limit exceeded"
	.section	.rodata.str1.1
.LC104:
	.string	"record content invalid"
.LC105:
	.string	"I/O error"
.LC106:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	CSWTCH.477, @object
	.size	CSWTCH.477, 56
CSWTCH.477:
	.quad	.LC101
	.quad	.LC102
	.quad	.LC103
	.quad	.LC104
	.quad	.LC64
	.quad	.LC105
	.quad	.LC106
	.align 32
	.type	CSWTCH.447, @object
	.size	CSWTCH.447, 40
CSWTCH.447:
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
.LC107:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.LC108:
	.string	"DBF value type outside admitted operation"
	.align 8
.LC109:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.LC110:
	.string	"DBF value output buffer too short"
	.align 8
.LC111:
	.string	"DBF value tag or metadata invalid"
	.align 8
.LC112:
	.string	"DBF arithmetic division by zero"
	.section	.rodata
	.align 32
	.type	CSWTCH.438, @object
	.size	CSWTCH.438, 48
CSWTCH.438:
	.quad	.LC107
	.quad	.LC108
	.quad	.LC109
	.quad	.LC110
	.quad	.LC111
	.quad	.LC112
	.align 8
	.type	CSWTCH.411, @object
	.size	CSWTCH.411, 13
CSWTCH.411:
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
	.comm	hrdbf_app_order,64,32
	.local	hrdbf_app_state
	.comm	hrdbf_app_state,2456,32
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
.LC83:
	.long	-798530048
	.long	1138748221
	.align 8
.LC84:
	.long	-798530048
	.long	-1008735427
	.align 8
.LC85:
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
