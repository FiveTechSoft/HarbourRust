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
	subq	$40, %rsp
	movq	%rdi, %r10
	movl	%esi, %r11d
	movq	%rdx, %r8
	movq	%rdi, %rcx
	testq	%rdi, %rdi
	js	.L333
	testq	%rdi, %rdi
	jne	.L313
	movb	$48, (%rsp)
	testl	%esi, %esi
	jne	.L314
.L332:
	movl	$1, %edi
	movl	$1, %r9d
.L315:
	movq	%rsp, %rsi
	leaq	-1(%rsp,%rdi), %rax
	addq	%r8, %rcx
	.p2align 4,,10
	.p2align 3
.L322:
	movzbl	(%rax), %edx
	addq	$1, %rcx
	movb	%dl, -1(%rcx)
	movq	%rax, %rdx
	subq	$1, %rax
	cmpq	%rdx, %rsi
	jne	.L322
	movq	%r9, %rax
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L314:
	movl	%esi, %esi
	cmpl	$1, %r11d
	je	.L332
	xorl	%ecx, %ecx
	movl	$1, %edi
.L320:
	subq	%rdi, %rsi
	cmpq	%rcx, %rsi
	je	.L331
	xorl	%eax, %eax
	leaq	1(%rcx), %r10
	leaq	(%r8,%rcx), %r9
	subq	%rcx, %rsi
	.p2align 4,,10
	.p2align 3
.L321:
	movb	$48, (%r9,%rax)
	leaq	(%r10,%rax), %rcx
	movq	%rsi, %rdx
	addq	$1, %rax
	subq	%rax, %rdx
	cmpq	%rax, %rdx
	ja	.L321
.L331:
	leaq	(%rcx,%rdi), %r9
	jmp	.L315
	.p2align 4,,10
	.p2align 3
.L333:
	negq	%rcx
.L313:
	movabsq	$-3689348814741910323, %r9
	xorl	%edi, %edi
	.p2align 4,,10
	.p2align 3
.L316:
	movq	%rcx, %rax
	addq	$1, %rdi
	mulq	%r9
	movq	%rcx, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rsi
	addq	%rsi, %rsi
	subq	%rsi, %rax
	addl	$48, %eax
	movb	%al, -1(%rsp,%rdi)
	movq	%rcx, %rax
	movq	%rdx, %rcx
	cmpq	$9, %rax
	ja	.L316
	testq	%r10, %r10
	jns	.L323
	movb	$45, (%r8)
	movl	$1, %ecx
.L317:
	testl	%r11d, %r11d
	je	.L331
	movl	%r11d, %esi
	leaq	(%rcx,%rdi), %r9
	cmpq	%r9, %rsi
	jbe	.L315
	jmp	.L320
.L323:
	xorl	%ecx, %ecx
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
	ja	.L334
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
	jbe	.L334
	testq	%r13, %r13
	je	.L334
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.L339
	.p2align 4,,10
	.p2align 3
.L336:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.L336
.L339:
	leaq	0(%r13,%rbp), %r8
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r8, %rdx
	je	.L338
	.p2align 4,,10
	.p2align 3
.L337:
	movb	$32, (%r8,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L337
	addq	%r8, %rdx
.L338:
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
	js	.L340
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
	jbe	.L374
	subq	$9, %rsi
	cmpq	$3, %rsi
	adcq	$0, %r9
.L342:
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
.L345:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L345
	testq	%rax, %rax
	jle	.L340
	cmpq	%rdx, %rax
	ja	.L340
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L345
	leaq	28(%r13), %rsi
	movl	$18, %r9d
	movl	$1, %edx
.L346:
	movq	2280(%rbx), %rdi
	movl	$28, %r10d
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L346
	cmpq	$1, %rax
	jne	.L340
	movl	$18, %r9d
	movq	%r8, %rsi
	movq	%rbp, %r10
	movq	%r12, %rdx
.L347:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L347
	testq	%rax, %rax
	jle	.L340
	cmpq	%rdx, %rax
	ja	.L340
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L347
	movq	2256(%rbx), %rdi
	movq	2264(%rbx), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L340
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
.L334:
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
.L340:
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
.L374:
	addq	$3, %rsi
	jmp	.L342
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
	je	.L376
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
	js	.L376
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L376:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L375
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L380
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L375:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L380:
	movl	$7, %r8d
	movl	%r8d, %eax
	ret
	.size	hrntx_file_close.constprop.0, .-hrntx_file_close.constprop.0
	.p2align 4
	.type	dset.constprop.0, @function
dset.constprop.0:
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	jmp	.L386
	.p2align 4,,10
	.p2align 3
.L388:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.L387
.L386:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.L388
.L387:
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
	jne	.L389
	orl	%eax, %edx
	movb	%dl, (%rdi)
.L389:
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
	ja	.L395
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.L395
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.L395
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.L395
	cmpb	$0, 40(%rcx)
	je	.L395
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call	cxheader
	testl	%eax, %eax
	jne	.L391
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.L391
	cmpw	$1, 510(%r12)
	jne	.L391
	cmpb	$0, 512(%r12)
	jne	.L391
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.L395
	testl	$511, %r10d
	jne	.L395
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.L395
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.L391
	cmpw	$1, 2(%r12,%rdx)
	jne	.L391
	cmpl	$-1, 4(%r12,%rdx)
	jne	.L395
	cmpl	$-1, 8(%r12,%rdx)
	jne	.L395
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L391
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
	jne	.L391
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L395
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.L395
	testl	$511, %r8d
	jne	.L395
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.L395
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.L395
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.L395
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.L395
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L396
.L469:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.L433
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L468
.L396:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L469
.L433:
	movl	$2, %eax
	jmp	.L391
	.p2align 4,,10
	.p2align 3
.L395:
	movl	$1, %eax
.L391:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L468:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call	cxheader
	testl	%eax, %eax
	jne	.L391
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L433
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.L433
	cmpb	$0, (%r12,%rdx)
	jne	.L433
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.L397:
	cmpb	$0, (%rdi,%rdx)
	je	.L433
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.L397
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.L398:
	cmpq	%r11, 40(%rsp)
	jbe	.L433
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.L407:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.L401
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.L402
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.L402:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.L403
	subl	$32, %esi
.L403:
	cmpb	16(%rsp), %sil
	jne	.L401
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L399
	cmpq	$11, %rdx
	jne	.L407
	cmpq	$11, %rax
	jne	.L401
.L405:
	cmpl	%r11d, 36(%rsp)
	je	.L433
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.L433
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.L432
	cmpw	12(%r12,%r9), %ax
	jne	.L433
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.L437
	testq	%r14, %r14
	jne	.L439
	testl	%eax, %eax
	jne	.L437
.L439:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.L437
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.L437
	xorl	%edx, %edx
.L409:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L409
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L410
	orl	$1, %eax
	movb	%al, (%rcx)
.L410:
	testb	$2, %al
	jne	.L411
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L411:
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
.L412:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L412
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call	cxvisit
	testl	%eax, %eax
	je	.L470
.L413:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L391
.L399:
	cmpq	$11, %rax
	je	.L405
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L405
.L401:
	addq	$1, %r11
	jmp	.L398
.L437:
	movl	$3, %eax
	jmp	.L391
.L432:
	movl	$5, %eax
	jmp	.L391
.L470:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.L413
	xorl	%edx, %edx
	jmp	.L415
.L471:
	cmpq	$63, %rdx
	ja	.L440
.L415:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.L414
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.L414:
	addq	$1, %rdx
	testb	$1, %al
	je	.L471
.L440:
	testl	%eax, %eax
	jne	.L413
	movl	%ecx, 24(%rbx)
	jmp	.L391
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	put_number.isra.0, @function
put_number.isra.0:
	movl	%esi, %r11d
	movl	$3, %r10d
	movl	%edx, %esi
	cmpb	$78, %r11b
	jne	.L472
	movzwl	%cx, %ecx
	leaq	(%rdi,%rcx), %rdx
	movzbl	%sil, %ecx
	cmpl	%r9d, %ecx
	jb	.L493
	subl	%r9d, %ecx
	je	.L478
	leal	-1(%rcx), %edi
	movq	%rdx, %rax
	addq	%rdx, %rdi
	.p2align 4,,10
	.p2align 3
.L479:
	movq	%rax, %rsi
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdi, %rsi
	jne	.L479
.L478:
	testl	%r9d, %r9d
	je	.L477
	leal	-1(%r9), %eax
	leaq	1(%r8,%rax), %rdi
	movl	%ecx, %eax
	subl	%r8d, %eax
	.p2align 4,,10
	.p2align 3
.L480:
	movzbl	(%r8), %esi
	leal	(%rax,%r8), %ecx
	addq	$1, %r8
	movb	%sil, (%rdx,%rcx)
	cmpq	%rdi, %r8
	jne	.L480
.L477:
	xorl	%r10d, %r10d
.L472:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L493:
	movq	%rdx, %rax
	movzbl	%sil, %edx
	addq	%rax, %rdx
	testl	%ecx, %ecx
	je	.L477
	.p2align 4,,10
	.p2align 3
.L476:
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L477
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L476
	jmp	.L477
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
	ja	.L494
	movzbl	12(%rsi), %r12d
	movq	%rsi, %r10
	cmpl	$17, %ecx
	ja	.L520
	cmpb	%r12b, %r13b
	jnb	.L520
	movq	%rdi, %rbp
	movq	%rdx, %rsi
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jns	.L496
	negq	%rsi
	movl	$1, %r8d
.L496:
	movzbl	%r13b, %ebx
	cmpl	%ebx, %ecx
	jbe	.L497
	subl	%ebx, %ecx
	je	.L498
	xorl	%eax, %eax
	movl	$1, %edi
	.p2align 4,,10
	.p2align 3
.L499:
	leaq	(%rdi,%rdi,4), %rdi
	addl	$1, %eax
	addq	%rdi, %rdi
	cmpl	%eax, %ecx
	jne	.L499
	movq	%rsi, %rax
	xorl	%edx, %edx
	divq	%rdi
	shrq	%rdi
	movq	%rax, %rsi
	cmpq	%rdi, %rdx
	jb	.L500
.L498:
	addq	$1, %rsi
.L500:
	movabsq	$-3689348814741910323, %r9
	movq	%rsp, %rdi
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L505:
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
	ja	.L505
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
	ja	.L548
	testl	%r8d, %r8d
	je	.L511
	movb	$45, 48(%rsp)
.L511:
	cmpl	%ecx, %ebx
	jb	.L549
	leal	1(%r8), %r9d
	movl	%r8d, %r8d
	movb	$48, 48(%rsp,%r8)
.L513:
	testb	%r13b, %r13b
	je	.L515
	cmpl	%ecx, %ebx
	movl	%r9d, %edx
	leal	1(%r9), %eax
	cmovbe	%ebx, %ecx
	movb	$46, 48(%rsp,%rdx)
	subl	%ecx, %ebx
	je	.L516
	leal	1(%rbx,%r9), %edi
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L517:
	movl	%edx, %esi
	addl	$1, %edx
	movb	$48, 48(%rsp,%rsi)
	cmpl	%edx, %edi
	jne	.L517
	addl	%ebx, %eax
.L516:
	leal	(%rcx,%rax), %r9d
	leal	-1(%rcx,%rax), %esi
	.p2align 4,,10
	.p2align 3
.L518:
	movl	%esi, %ecx
	movl	%eax, %edx
	subl	%eax, %ecx
	addl	$1, %eax
	movzbl	(%rsp,%rcx), %ecx
	movb	%cl, 48(%rsp,%rdx)
	cmpl	%eax, %r9d
	jne	.L518
.L515:
	movzbl	11(%r10), %esi
	leaq	48(%rsp), %r8
	movl	%r14d, %ecx
	movl	%r12d, %edx
	movq	%rbp, %rdi
	call	put_number.isra.0
.L494:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L520:
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
.L497:
	jnb	.L500
	movl	%ebx, %edi
	subl	%ecx, %edi
	je	.L500
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rsi
	ja	.L501
	xorl	%eax, %eax
	jmp	.L502
	.p2align 4,,10
	.p2align 3
.L504:
	cmpq	%rdx, %rsi
	ja	.L501
.L502:
	leaq	(%rsi,%rsi,4), %rsi
	addl	$1, %eax
	addq	%rsi, %rsi
	cmpl	%eax, %edi
	jne	.L504
	jmp	.L500
	.p2align 4,,10
	.p2align 3
.L549:
	testl	%r9d, %r9d
	je	.L524
	movl	%edx, %r9d
	addl	%r8d, %r11d
	jmp	.L514
	.p2align 4,,10
	.p2align 3
.L550:
	movl	%r11d, %eax
	movl	%esi, %r8d
	subl	%esi, %eax
	movzbl	(%rsp,%rax), %eax
.L514:
	leal	1(%r8), %esi
	movl	%r8d, %r8d
	movb	%al, 48(%rsp,%r8)
	cmpl	%esi, %edx
	jne	.L550
	jmp	.L513
	.p2align 4,,10
	.p2align 3
.L548:
	xorl	%eax, %eax
	leaq	0(%rbp,%r14), %rdx
	.p2align 4,,10
	.p2align 3
.L509:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L509
	xorl	%eax, %eax
.L551:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L501:
	movzwl	14(%r10), %edx
	xorl	%eax, %eax
	addq	%rbp, %rdx
	.p2align 4,,10
	.p2align 3
.L503:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r12d
	ja	.L503
	xorl	%eax, %eax
	jmp	.L551
.L524:
	movl	%r8d, %r9d
	jmp	.L513
	.size	hrdbf_write_number_scaled.part.0, .-hrdbf_write_number_scaled.part.0
	.p2align 4
	.type	bn_shr_round, @function
bn_shr_round:
	movl	288(%rdi), %r9d
	movl	%esi, %r8d
	movl	%r9d, %esi
	sall	$5, %esi
	cmpl	%r8d, %esi
	jbe	.L597
	leal	-1(%r8), %edx
	xorl	%r10d, %r10d
	cmpl	%edx, %esi
	ja	.L598
.L559:
	cmpl	$1, %r8d
	je	.L560
	xorl	%ecx, %ecx
	jmp	.L563
	.p2align 4,,10
	.p2align 3
.L561:
	addl	$1, %ecx
	cmpl	%ecx, %edx
	je	.L560
.L563:
	cmpl	%ecx, %esi
	jbe	.L561
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L561
	testl	%r10d, %r10d
	movl	$3, %edx
	cmovne	%edx, %eax
.L574:
	cmpl	$31, %r8d
	jbe	.L568
	movl	%r8d, %r11d
	shrl	$5, %r11d
	cmpl	%r11d, %r9d
	jbe	.L570
	leal	-1(%r9), %ecx
	movq	%rdi, %rdx
	movl	%r11d, %esi
	subl	%r11d, %ecx
	leaq	4(%rdi,%rcx,4), %r10
	.p2align 4,,10
	.p2align 3
.L569:
	movl	(%rdx,%rsi,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%r10, %rdx
	jne	.L569
.L570:
	movl	%r9d, %edx
	subl	%r11d, %edx
	movl	%edx, 288(%rdi)
	cmpl	%edx, %r9d
	jbe	.L568
	movl	%edx, %ecx
	leal	-1(%r11), %esi
	leaq	(%rdi,%rcx,4), %rdx
	addq	%rsi, %rcx
	leaq	4(%rdi,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L571:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L571
.L568:
	andl	$31, %r8d
	jne	.L565
	ret
	.p2align 4,,10
	.p2align 3
.L598:
	movl	%edx, %eax
	movl	%edx, %ecx
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %r10d
	shrl	%cl, %r10d
	andl	$1, %r10d
	jmp	.L559
	.p2align 4,,10
	.p2align 3
.L597:
	xorl	%eax, %eax
	testl	%esi, %esi
	je	.L554
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L556:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r9d
	addl	$1, %ecx
	cmpl	%ecx, %esi
	jne	.L556
	testl	%eax, %eax
	je	.L554
	xorl	%r10d, %r10d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L557:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %r10d
	cmpl	%ecx, %esi
	jne	.L557
	subl	$1, %r8d
	cmpl	%r9d, %r8d
	ja	.L554
	sete	%al
	xorl	%edx, %edx
	cmpl	$1, %r10d
	sete	%dl
	andl	%eax, %edx
	movl	$3, %eax
	subl	%edx, %eax
.L554:
	movl	$1, 288(%rdi)
	movl	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.L560:
	leal	(%r10,%r10), %eax
	jmp	.L574
	.p2align 4,,10
	.p2align 3
.L565:
	movl	288(%rdi), %ecx
	pushq	%rbx
	leal	-1(%rcx), %ebx
	cmpl	$1, %ecx
	jbe	.L572
	movl	$32, %r10d
	subl	$2, %ecx
	movq	%rdi, %rdx
	subl	%r8d, %r10d
	leaq	4(%rdi,%rcx,4), %r11
	.p2align 4,,10
	.p2align 3
.L573:
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
	jne	.L573
	movl	%ebx, %esi
	movl	%r8d, %ecx
	movl	(%rdi,%rsi,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%rdi,%rsi,4)
	testl	%edx, %edx
	je	.L599
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L599:
	movl	%ebx, 288(%rdi)
	popq	%rbx
	ret
.L572:
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
.L601:
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
	jbe	.L611
	cmpl	$19, %r8d
	jbe	.L601
.L611:
	leaq	2289(%rdi), %r10
	leaq	2448(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L609:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L603
	.p2align 4,,10
	.p2align 3
.L605:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L604
.L603:
	cmpb	$0, (%rax)
	jne	.L605
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L606
	jmp	.L604
	.p2align 4,,10
	.p2align 3
.L607:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L604
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L606:
	testb	%cl, %cl
	jne	.L607
.L604:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L600
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L609
.L600:
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
	jmp	.L619
	.p2align 4,,10
	.p2align 3
.L621:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.L620
.L619:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.L621
.L620:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.L623
	.p2align 4,,10
	.p2align 3
.L625:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.L624
.L623:
	cmpb	$0, (%rax)
	jne	.L625
	cmpq	%rax, %rbx
	jbe	.L624
	movl	$32, %esi
	movl	$.LC1, %ecx
	.p2align 4,,10
	.p2align 3
.L626:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L624
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.L626
.L624:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call	fdec
	jmp	.L627
	.p2align 4,,10
	.p2align 3
.L629:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.L628
.L627:
	cmpb	$0, (%r11)
	jne	.L629
	cmpq	%r11, %rbx
	jbe	.L628
	movb	$41, (%r11)
	addq	$1, %r11
.L628:
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
	je	.L642
	movabsq	$4503599627370495, %rax
	andq	40(%rsp), %rax
	movq	%rdi, %rbx
	movq	%rax, 8(%rsp)
	testq	%r9, %r9
	je	.L876
	btsq	$52, 8(%rsp)
	movq	8(%rsp), %rax
	movl	$2, %edi
	leal	-1075(%r9), %r15d
	subl	$735, %r9d
	movl	%eax, %ecx
	movl	%r9d, %r10d
	shrq	$32, %rax
.L640:
	movl	%ecx, 48(%rsp)
	movl	$340, %esi
	xorl	%r8d, %r8d
	movl	%eax, 52(%rsp)
	movl	%edi, 336(%rsp)
	.p2align 4,,10
	.p2align 3
.L645:
	leal	-1(%rdi), %eax
	leaq	48(%rsp), %rdx
	leaq	52(%rsp,%rax,4), %r11
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L646:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%r11, %rdx
	jne	.L646
	testq	%rax, %rax
	je	.L647
	movl	%edi, %edx
	movl	$1, %r8d
	addl	$1, %edi
	movl	%eax, 48(%rsp,%rdx,4)
.L647:
	subl	$1, %esi
	jne	.L645
	testb	%r8b, %r8b
	je	.L649
	movl	%edi, 336(%rsp)
.L649:
	movl	%r10d, %esi
	testl	%r9d, %r9d
	js	.L650
	leaq	48(%rsp), %rdi
	call	bn_shl
	movl	336(%rsp), %eax
.L651:
	xorl	%ebp, %ebp
	jmp	.L655
	.p2align 4,,10
	.p2align 3
.L656:
	cmpq	$80, %rbp
	je	.L877
	leaq	48(%rsp), %rdi
	call	bn_divmod_1e9
	movl	%eax, 1264(%rsp,%rbp,4)
	movl	336(%rsp), %eax
	addq	$1, %rbp
.L655:
	movl	%ebp, %r8d
	cmpl	$1, %eax
	jne	.L656
	movl	48(%rsp), %r9d
	testl	%r9d, %r9d
	jne	.L656
	testl	%ebp, %ebp
	jne	.L878
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L641
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jnb	.L879
.L642:
	xorl	%eax, %eax
.L634:
	addq	$2312, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L876:
	testq	%rax, %rax
	jne	.L880
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.L641
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jb	.L642
	movl	$11824, %ecx
	leaq	2(%rdi), %rdx
	movw	%cx, (%rdi)
	movl	16(%rsp), %edi
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L644:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L644
	jmp	.L634
.L641:
	movl	36(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L642
	movb	$48, (%rbx)
	movl	$1, %eax
	jmp	.L634
.L880:
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
	jmp	.L640
.L650:
	negl	%esi
	leaq	48(%rsp), %rdi
	call	bn_shr_round
	movl	%eax, %r8d
	movl	336(%rsp), %eax
	cmpl	$1, %r8d
	jbe	.L651
	testl	%eax, %eax
	je	.L750
	leal	-1(%rax), %edx
	movq	%rdi, %rsi
	leaq	52(%rsp,%rdx,4), %rdi
	movl	$1, %edx
.L654:
	movl	(%rsi), %ecx
	addq	$4, %rsi
	addq	%rcx, %rdx
	movl	%edx, -4(%rsi)
	shrq	$32, %rdx
	cmpq	%rdi, %rsi
	jne	.L654
	testq	%rdx, %rdx
	je	.L651
	leal	1(%rax), %edx
.L653:
	movl	$1, 48(%rsp,%rax,4)
	movl	%edx, %eax
	movl	%edx, 336(%rsp)
	jmp	.L651
.L877:
	movl	$79, %r8d
.L659:
	movl	%r8d, %eax
	movl	$1, %ecx
	movl	$3435973837, %r9d
	movl	1264(%rsp,%rax,4), %esi
.L663:
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
	ja	.L663
	leaq	1584(%rsp), %r13
	leal	-1(%r12), %ecx
	leaq	1585(%rsp), %rax
	movq	%rcx, %r11
	leal	-1(%r12,%r13), %esi
	addq	%rax, %rcx
	movq	%r13, %rax
	jmp	.L665
.L881:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	960(%rsp,%rdx), %edx
.L665:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L881
	testl	%r8d, %r8d
	je	.L666
	leaq	1264(%rsp), %r14
	leal	-1(%r8), %eax
	movl	$3435973837, %r10d
	leaq	(%r14,%rax,4), %rbp
.L668:
	movl	%r11d, %edi
	movl	0(%rbp), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L667:
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
	jne	.L667
	leaq	-4(%rbp), %rax
	cmpq	%r14, %rbp
	je	.L882
	movq	%rax, %rbp
	jmp	.L668
.L882:
	leal	(%r8,%r8,8), %eax
	addl	%eax, %r12d
.L666:
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
.L670:
	leal	-1(%r8), %eax
	leaq	352(%rsp), %rcx
	leaq	356(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L671:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L671
	testq	%rax, %rax
	je	.L672
	movl	%r8d, %edx
	movl	$1, %r9d
	addl	$1, %r8d
	movl	%eax, 352(%rsp,%rdx,4)
.L672:
	subl	$1, %edi
	jne	.L670
	testb	%r9b, %r9b
	je	.L674
	movl	%r8d, 640(%rsp)
.L674:
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
	je	.L675
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
.L676:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L677:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rsi, %rcx
	jne	.L677
	testq	%rax, %rax
	je	.L678
	movl	%r11d, %edx
	movl	%r9d, %ebp
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L678:
	subl	$1, %r10d
	jne	.L676
	testb	%bpl, %bpl
	je	.L680
	movl	%r11d, 944(%rsp)
.L680:
	leal	338(%r15), %esi
	call	bn_shl
.L681:
	leaq	960(%rsp), %r8
	cmpl	$1, %r12d
	je	.L718
	leal	1(%r12), %eax
	leaq	960(%rsp), %r8
	movq	%rbx, 24(%rsp)
	movl	$2, %r14d
	movl	%eax, 32(%rsp)
	leaq	1585(%rsp), %rbp
	movl	$1, %r15d
	movq	%r8, %rbx
.L714:
	movl	%r15d, 4(%rsp)
	movq	%r13, %rdx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.L688:
	movzbl	(%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpq	%rdx, %rbp
	jne	.L688
	cmpb	$53, 0(%rbp)
	ja	.L689
	je	.L883
.L690:
	movl	32(%rsp), %r10d
	movq	%r10, %rcx
	subq	%r14, %rcx
	cmpq	$9, %rsi
	ja	.L884
.L692:
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
	je	.L696
	.p2align 4,,10
	.p2align 3
.L695:
	leal	-1(%rdi), %eax
	movq	%rbx, %rcx
	leaq	964(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L697:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L697
	testq	%rax, %rax
	je	.L698
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 960(%rsp,%rdx,4)
.L698:
	addl	$1, %r9d
	cmpl	%r10d, %r9d
	jne	.L695
	testb	%r11b, %r11b
	je	.L696
	movl	%edi, 1248(%rsp)
.L696:
	movl	%r10d, %esi
	movq	%rbx, %rdi
	call	bn_shl
	movl	1248(%rsp), %esi
	cmpl	944(%rsp), %esi
	je	.L701
	jnb	.L702
	cmpl	640(%rsp), %esi
	jne	.L703
	movl	$-1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L710
	.p2align 4,,10
	.p2align 3
.L713:
	movl	%eax, %edx
	subl	$1, %eax
	movl	352(%rsp,%rdx,4), %edi
	cmpl	%edi, 960(%rsp,%rdx,4)
	jne	.L885
.L710:
	cmpl	$-1, %eax
	jne	.L713
.L709:
	testb	$1, 8(%rsp)
	je	.L865
.L703:
	movl	%r14d, %eax
	addq	$1, %r15
	addq	$1, %r14
	addq	$1, %rbp
	cmpl	$17, %eax
	ja	.L866
	cmpl	%r12d, %eax
	jb	.L714
.L866:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
.L718:
	movl	$17, %eax
	cmpl	%eax, %r12d
	cmovbe	%r12d, %eax
	movl	%eax, 4(%rsp)
.L716:
	movl	4(%rsp), %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
.L719:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpl	%edx, %edi
	ja	.L719
	movl	4(%rsp), %eax
	cmpl	%r12d, %eax
	jnb	.L720
	cmpb	$53, 1584(%rsp,%rax)
	ja	.L721
	jne	.L720
	testb	$1, %sil
	jne	.L721
	movl	4(%rsp), %eax
	addl	$1, %eax
	cmpl	%r12d, %eax
	jb	.L722
	jmp	.L720
	.p2align 4,,10
	.p2align 3
.L886:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L720
.L722:
	cmpb	$48, 0(%r13,%rax)
	je	.L886
.L721:
	addq	$1, %rsi
.L720:
	movabsq	$-3689348814741910323, %r9
	xorl	%ecx, %ecx
.L723:
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
	ja	.L723
	cmpl	4(%rsp), %ecx
	jbe	.L724
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 20(%rsp)
	testl	%edi, %edi
	je	.L728
	leal	-1(%rdi), %eax
	movl	%edi, %ecx
	movq	%rax, %rdx
	movzbl	960(%rsp,%rax), %eax
	movl	%edx, %edi
.L724:
	xorl	%edx, %edx
	jmp	.L726
.L887:
	movl	%edi, %eax
	subl	%edx, %eax
	movzbl	960(%rsp,%rax), %eax
.L726:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L887
	cmpl	$1, %ecx
	jbe	.L727
.L888:
	leal	-1(%rcx), %edx
	cmpb	$48, 1584(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L727
	movl	%eax, %ecx
.L728:
	cmpl	$1, %ecx
	ja	.L888
.L727:
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
	jle	.L889
	movl	%ecx, %esi
	cmpq	%rsi, %rax
	jge	.L733
	cmpb	$52, 1584(%rsp,%rax)
	movl	%eax, %ecx
	jbe	.L739
	leal	-1(%rax), %esi
	movq	%rsi, %rax
	addq	%r13, %rsi
	subl	%esi, %eax
	jmp	.L736
.L735:
	movb	$48, (%rsi)
	leaq	-1(%rsi), %r10
	cmpq	%rsi, %r13
	je	.L890
	movq	%r10, %rsi
.L736:
	movzbl	(%rsi), %r10d
	leal	(%rax,%rsi), %r11d
	cmpb	$57, %r10b
	je	.L735
	movl	%r11d, %eax
	addl	$1, %r10d
	movb	%r10b, 1584(%rsp,%rax)
	jmp	.L739
	.p2align 4,,10
	.p2align 3
.L701:
	leal	-1(%rsi), %eax
	movl	%eax, %edx
	jmp	.L706
	.p2align 4,,10
	.p2align 3
.L708:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	656(%rsp,%rcx,4), %edi
	cmpl	%edi, 960(%rsp,%rcx,4)
	jne	.L891
.L706:
	cmpl	$-1, %edx
	jne	.L708
	xorl	%ecx, %ecx
	cmpl	%esi, 640(%rsp)
	je	.L710
	jmp	.L709
.L883:
	testb	$1, %sil
	jne	.L689
	cmpl	%r14d, %r12d
	jbe	.L690
	movq	%r14, %rax
	jmp	.L691
.L892:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.L690
.L691:
	cmpb	$48, 0(%r13,%rax)
	je	.L892
.L689:
	addq	$1, %rsi
	jmp	.L690
.L884:
	movq	%rsi, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L693:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rdi
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rdi
	ja	.L693
	cmpl	%r9d, 4(%rsp)
	jnb	.L692
	movabsq	$-3689348814741910323, %rax
	movq	%r10, %rcx
	mulq	%rsi
	subq	%r15, %rcx
	movq	%rdx, %rsi
	shrq	$3, %rsi
	jmp	.L692
.L891:
	jnb	.L707
	movl	$-1, %ecx
	cmpl	640(%rsp), %esi
	je	.L710
	jmp	.L703
.L885:
	jnb	.L712
	cmpl	$1, %ecx
	je	.L865
.L712:
	testl	%ecx, %ecx
	jne	.L703
	jmp	.L709
.L702:
	cmpl	640(%rsp), %esi
	jne	.L874
	movl	$1, %ecx
	leal	-1(%rsi), %eax
	jmp	.L710
.L874:
	jnb	.L703
.L865:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
	jmp	.L716
.L707:
	cmpl	640(%rsp), %esi
	jne	.L874
	movl	$1, %ecx
	jmp	.L710
.L893:
	leal	-1(%rcx), %esi
	cmpb	$48, 1584(%rsp,%rsi)
	movq	%rsi, %rax
	jne	.L873
	movl	%eax, %ecx
.L739:
	cmpl	$1, %ecx
	jne	.L893
.L738:
	xorl	%eax, %eax
	movl	$0, %esi
	cmpb	$48, 1584(%rsp)
	movl	$1, %ecx
	cmovne	%r8, %rax
	cmove	%esi, %edx
	jmp	.L731
	.p2align 4,,10
	.p2align 3
.L675:
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
.L683:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L684:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.L684
	testq	%rax, %rax
	je	.L685
	movl	%r11d, %edx
	movl	$1, %r9d
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.L685:
	subl	$1, %r10d
	jne	.L683
	testb	%r9b, %r9b
	je	.L687
	movl	%r11d, 944(%rsp)
.L687:
	movl	%ebp, %esi
	call	bn_shl
	jmp	.L681
.L733:
	cmpl	$1, %ecx
	je	.L738
.L873:
	movq	%r8, %rax
.L731:
	movl	20(%rsp), %r14d
	movl	$1, %r8d
	leal	1(%r14), %esi
	testl	%r14d, %r14d
	movslq	%esi, %rsi
	cmovs	%r8, %rsi
.L740:
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
	jg	.L642
	testl	%edx, %edx
	jne	.L894
	movq	%rbx, %rsi
	movl	$1, %eax
.L742:
	movl	20(%rsp), %edi
	testl	%edi, %edi
	js	.L743
	leal	1(%rdi), %eax
	xorl	%esi, %esi
	movslq	%eax, %r9
.L745:
	leal	(%rdx,%rsi), %edi
	movl	$48, %r8d
	cmpl	%ecx, %esi
	jnb	.L744
	movzbl	0(%r13,%rsi), %r8d
.L744:
	addq	$1, %rsi
	movb	%r8b, (%rbx,%rdi)
	cmpq	%rsi, %r9
	jne	.L745
	addl	%edx, %eax
.L746:
	movl	16(%rsp), %r10d
	testl	%r10d, %r10d
	je	.L634
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
	jmp	.L748
.L768:
	movl	%eax, %edx
.L748:
	movl	$48, %r8d
	testq	%rsi, %rsi
	js	.L747
	leal	(%r9,%rdx), %eax
	cmpl	%ecx, %eax
	jnb	.L747
	movzbl	0(%r13,%rsi), %r8d
.L747:
	leal	1(%rdx), %eax
	movb	%r8b, (%rbx,%rdx)
	addq	$1, %rsi
	cmpl	%r10d, %eax
	jne	.L768
	movl	16(%rsp), %eax
	addl	%edi, %eax
	jmp	.L634
.L889:
	jne	.L730
	cmpb	$52, 1584(%rsp)
	jbe	.L730
	negl	%esi
	movb	$49, 1584(%rsp)
	movq	%r8, %rax
	movl	$1, %ecx
	movl	%esi, 20(%rsp)
	jmp	.L731
.L730:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %esi
	movl	$1, %ecx
	movb	$48, 1584(%rsp)
	movl	$0, 20(%rsp)
	jmp	.L740
.L894:
	movb	$45, (%rbx)
	leaq	1(%rbx), %rsi
	movl	$2, %eax
	jmp	.L742
.L878:
	subl	$1, %r8d
	jmp	.L659
.L879:
	movl	16(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rbx)
	leaq	2(%rbx), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.L662:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L662
	jmp	.L634
.L743:
	movb	$48, (%rsi)
	jmp	.L746
.L750:
	movl	$1, %edx
	jmp	.L653
.L890:
	movb	$49, 1584(%rsp)
	movl	%r9d, 20(%rsp)
	jmp	.L739
	.size	hrdbf_fmt_harbour.part.0, .-hrdbf_fmt_harbour.part.0
	.p2align 4
	.type	hrdbf_write_number_double.part.0, @function
hrdbf_write_number_double.part.0:
	movzbl	13(%rsi), %edx
	movl	$4, %eax
	cmpb	$17, %dl
	ja	.L902
	pushq	%rbp
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$408, %rsp
	cmpb	12(%rsi), %dl
	jnb	.L895
	movq	%rdi, %rbp
	movl	$400, %esi
	movq	%rsp, %rdi
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %r9d
	movl	$5, %eax
	testl	%r9d, %r9d
	je	.L895
	movzwl	14(%rbx), %ecx
	movzbl	12(%rbx), %edx
	movq	%rsp, %r8
	movq	%rbp, %rdi
	movzbl	11(%rbx), %esi
	call	put_number.isra.0
.L895:
	addq	$408, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L902:
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
.L906:
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
	jbe	.L916
	cmpl	$19, %r8d
	jbe	.L906
.L916:
	leaq	2090(%rdi), %r10
	leaq	2249(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L914:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.L908
	.p2align 4,,10
	.p2align 3
.L910:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.L909
.L908:
	cmpb	$0, (%rax)
	jne	.L910
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.L911
	jmp	.L909
	.p2align 4,,10
	.p2align 3
.L912:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.L909
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.L911:
	testb	%cl, %cl
	jne	.L912
.L909:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.L905
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L914
.L905:
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
.L924:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.L923
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	2090(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.L926
	.p2align 4,,10
	.p2align 3
.L928:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.L927
.L926:
	cmpb	$0, (%rax)
	jne	.L928
	cmpq	%rdx, %rax
	jnb	.L927
	movb	%cl, (%rax)
	addq	$1, %rax
.L927:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.L924
.L923:
	ret
	.size	dname, .-dname
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
	jmp	.L933
	.p2align 4,,10
	.p2align 3
.L935:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.L934
.L933:
	cmpb	$0, (%rdx)
	jne	.L935
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.L936
	jmp	.L934
	.p2align 4,,10
	.p2align 3
.L938:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.L934
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.L936:
	testb	%cl, %cl
	jne	.L938
.L934:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.LC2(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.L940
	.p2align 4,,10
	.p2align 3
.L942:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.L941
.L940:
	cmpb	$0, (%rax)
	jne	.L942
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.L943
	jmp	.L941
	.p2align 4,,10
	.p2align 3
.L944:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.L941
.L943:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L944
.L941:
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
	je	.L953
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.L953:
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
	je	.L956
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.L956
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.L958
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
.L960:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.L970
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.L956:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L958:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.L961
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.L956
	.p2align 4,,10
	.p2align 3
.L970:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.L956
	.p2align 4,,10
	.p2align 3
.L961:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.L960
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
	je	.L1050
	testl	%esi, %esi
	je	.L1051
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.L1051
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
	ja	.L1051
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.L1054
	cmpb	$78, %r8b
	je	.L1055
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.L1056
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.L997
	cmpb	$89, %dl
	je	.L997
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.L1051
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.L1050
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.L1050
	.p2align 4,,10
	.p2align 3
.L1051:
	xorl	%r8d, %r8d
.L1050:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L997:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1054:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1050
	.p2align 4,,10
	.p2align 3
.L1055:
	testl	%edi, %edi
	je	.L1051
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.L976
	.p2align 4,,10
	.p2align 3
.L977:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.L1051
.L976:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.L977
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.L979
	.p2align 4,,10
	.p2align 3
.L1003:
	movl	%edx, %edi
.L979:
	cmpl	%edi, %eax
	jnb	.L978
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.L1003
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.L1023
	cmpb	$45, %r8b
	sete	%dl
.L1001:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.L981:
	cmpl	%eax, %edi
	jbe	.L1008
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.L1000:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.L985
	.p2align 4,,10
	.p2align 3
.L1057:
	testl	%ebx, %ebx
	jne	.L1024
	movl	$1, %ebx
.L982:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.L984
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.L985:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.L1057
.L1024:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L1008
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.L1014
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.L982
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.L982
	.p2align 4,,10
	.p2align 3
.L1056:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.L994:
	cmpb	$32, (%rax)
	jne	.L1016
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L994
	jmp	.L1051
.L1016:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L993:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.L1017
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.L993
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
	jbe	.L1050
	cmpl	$11, %edx
	ja	.L1050
	testl	%edi, %edi
	je	.L1050
	movzbl	days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.L1058
.L995:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.L1050
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.L1050
.L984:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.L971
	cmpl	%r13d, %r9d
	jb	.L971
	leal	1(%r13), %eax
	jbe	.L986
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.L987
	jmp	.L1014
	.p2align 4,,10
	.p2align 3
.L988:
	cmpq	%rsi, %r11
	ja	.L1014
.L987:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.L988
	testl	%r12d, %r12d
	jne	.L999
.L990:
	movq	%r11, %rax
.L991:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.L971:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1014:
	movl	$4, %r8d
	jmp	.L971
.L978:
	je	.L973
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.L981
	cmpb	$45, %dl
	sete	%dl
	jmp	.L1001
	.p2align 4,,10
	.p2align 3
.L973:
	xorl	%r8d, %r8d
	jmp	.L971
.L1008:
	movl	$5, %r8d
	jmp	.L971
.L1023:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.L1000
.L1017:
	movl	$5, %r8d
	jmp	.L1050
.L1058:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.L995
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L996
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.L995
.L996:
	addl	$1, %r10d
	jmp	.L995
.L986:
	testl	%r12d, %r12d
	je	.L990
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.L991
.L999:
	movq	%r11, %rax
	negq	%rax
	jmp	.L991
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.L1059
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.L1061
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.L1061:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.L1059:
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
	jbe	.L1140
	cmpb	$3, (%rsi)
	movq	%rsi, %r10
	jne	.L1141
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
	jbe	.L1068
	testl	%edi, %edi
	sete	%dl
	cmpq	%rbx, %r11
	setb	%al
	orb	%al, %dl
	je	.L1069
.L1068:
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
.L1064:
	addq	$2344, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1069:
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
.L1093:
	movzbl	(%rdi), %r12d
	movq	%r13, %rsi
	movzwl	8(%rsp), %ecx
	salq	$5, %rsi
	cmpb	$13, %r12b
	je	.L1142
	cmpq	%r13, 24(%rsp)
	je	.L1143
	cmpq	$129, %r13
	je	.L1144
	movw	%r13w, 22(%rsp)
	xorl	%eax, %eax
	jmp	.L1077
	.p2align 4,,10
	.p2align 3
.L1145:
	movzbl	(%rdi,%rax), %r12d
.L1077:
	movb	%r12b, 42(%rbx,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1145
	movzbl	-11(%r9), %r14d
	testb	%r14b, %r14b
	je	.L1078
	cmpl	$1, %r13d
	jbe	.L1079
	leal	-1(%r13), %r12d
	xorl	%esi, %esi
	salq	$4, %r12
	.p2align 4,,10
	.p2align 3
.L1080:
	movq	%r15, %rax
	movl	%r14d, %edx
	jmp	.L1083
	.p2align 4,,10
	.p2align 3
.L1147:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1083:
	leaq	(%rax,%r8), %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.L1146
	cmpq	%r9, %rax
	jne	.L1147
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
	jmp	.L1064
	.p2align 4,,10
	.p2align 3
.L1146:
	addq	$16, %rsi
	cmpq	%r12, %rsi
	jne	.L1080
.L1079:
	movzbl	11(%rdi), %edx
	movzbl	16(%rdi), %eax
	movw	%r10w, 3(%r9)
	movzbl	17(%rdi), %ecx
	movb	%dl, (%r9)
	movb	%al, 1(%r9)
	movb	%cl, 2(%r9)
	testb	%al, %al
	je	.L1148
	cmpb	$67, %dl
	je	.L1149
	cmpb	$78, %dl
	je	.L1150
	cmpb	$76, %dl
	je	.L1151
	cmpb	$68, %dl
	jne	.L1090
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	je	.L1086
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
	jmp	.L1064
	.p2align 4,,10
	.p2align 3
.L1140:
	movl	$.LC5, %esi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1064
.L1141:
	movl	$.LC6, %esi
	call	dset.constprop.0
	movzbl	(%r10), %esi
	movq	%rbp, %rdi
	call	dhex
	movl	$.LC7, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	$2, %eax
	jmp	.L1064
.L1149:
	testb	%cl, %cl
	jne	.L1152
.L1086:
	addl	%eax, %r10d
	cmpl	$65535, %r10d
	ja	.L1153
	addq	$1, %r13
	addq	$32, %rdi
	addq	$16, %rbx
	addq	$16, %r15
	addl	$1, 8(%rsp)
	subq	$16, %r8
	addq	$16, %r9
	movl	$1, %edx
	cmpq	%r13, 32(%rsp)
	jne	.L1093
	movl	$.LC30, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1064
.L1150:
	cmpb	$17, %cl
	ja	.L1110
	cmpb	%cl, %al
	ja	.L1086
.L1110:
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
	jmp	.L1064
	.p2align 4,,10
	.p2align 3
.L1151:
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.L1086
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
	jmp	.L1064
	.p2align 4,,10
	.p2align 3
.L1143:
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
	jmp	.L1064
.L1144:
	movl	$.LC13, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$4, %eax
	jmp	.L1064
.L1142:
	movl	%r10d, %ebx
	movq	40(%rsp), %r10
	testb	%dl, %dl
	je	.L1071
	movw	%cx, 116(%rsp)
	testw	%cx, %cx
	je	.L1071
	addq	$1, %rsi
	cmpl	%ebx, 16(%rsp)
	je	.L1095
	jmp	.L1154
	.p2align 4,,10
	.p2align 3
.L1096:
	addq	$1, %rsi
	cmpb	$0, -1(%r10,%rsi)
	jne	.L1155
.L1095:
	cmpq	(%rsp), %rsi
	jb	.L1096
	movl	%ebx, %ecx
	movq	%r11, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%rcx
	movl	12(%rsp), %r13d
	movq	%rax, %r12
	cmpq	%rax, %r13
	ja	.L1156
	movq	%r13, %rax
	imulq	%rcx, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r11
	je	.L1098
	movq	%r11, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1099
	cmpb	$26, (%r10,%rax)
	je	.L1098
.L1099:
	movl	$.LC38, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1064
.L1078:
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
	jmp	.L1064
.L1148:
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
	jmp	.L1064
.L1155:
	movl	$.LC34, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1064
.L1153:
	movl	$.LC29, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$4, %eax
	jmp	.L1064
.L1152:
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
	jmp	.L1064
.L1154:
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
	jmp	.L1064
.L1071:
	movl	$.LC31, %esi
	movq	%rbp, %rdi
	call	dset.constprop.0
	movl	$1, %eax
	jmp	.L1064
.L1090:
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
	jmp	.L1064
.L1098:
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
	je	.L1107
	movq	%rbp, (%rsp)
	movq	%rcx, %rbp
.L1106:
	movzbl	(%rbx), %r12d
	addq	$1, %r14
	cmpb	$32, %r12b
	je	.L1101
	cmpb	$42, %r12b
	jne	.L1157
.L1101:
	movq	%r14, 104(%rsp)
	movl	$1, %r15d
	jmp	.L1105
.L1102:
	addl	$1, %r15d
	cmpl	8(%rsp), %r15d
	ja	.L1158
.L1105:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call	hrdbf_get
	testl	%eax, %eax
	je	.L1102
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
	je	.L1159
.L1104:
	cmpb	$42, %r12b
	jne	.L1064
	movl	$.LC44, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call	dcat
	movl	(%rsp), %eax
	jmp	.L1064
.L1158:
	addq	%rbp, %rbx
	cmpq	%r14, %r13
	jne	.L1106
	movq	(%rsp), %rbp
.L1107:
	movl	$282, %ecx
	movq	%rbp, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.L1064
.L1156:
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
	jmp	.L1064
.L1157:
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
	jmp	.L1064
.L1159:
	movl	$.LC43, %esi
	movq	%rbp, %rdi
	call	dcat
	movl	(%rsp), %eax
	jmp	.L1104
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
	ja	.L1162
	je	.L1182
	cmpl	$5, %edx
	je	.L1165
	shrq	$8, %rdi
	jne	.L1183
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.L1162
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.L1162
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.L1162
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.L1162
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
	ja	.L1178
	testq	%rsi, %rsi
	je	.L1178
	movl	days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1184
.L1167:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1182:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.L1162
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.L1185
.L1162:
	ret
	.p2align 4,,10
	.p2align 3
.L1165:
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
.L1185:
	testb	$-1, %dh
	jne	.L1162
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
.L1183:
	ret
	.p2align 4,,10
	.p2align 3
.L1178:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1184:
	testb	$3, %cl
	jne	.L1167
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1168
	addl	$1, %eax
	jmp	.L1167
.L1168:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.L1167
	.size	hrv_validate, .-hrv_validate
	.p2align 4
	.globl	hrv_valtype
	.type	hrv_valtype, @function
hrv_valtype:
	endbr64
	movzbl	%dil, %edx
	movl	$63, %eax
	cmpb	$12, %dil
	ja	.L1186
	movzbl	CSWTCH.403(%rdx), %eax
.L1186:
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
	jne	.L1189
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.L1199
	testl	%edx, %edx
	je	.L1192
	cmpl	$9, %edx
	je	.L1192
	movl	$1, %eax
.L1189:
	ret
	.p2align 4,,10
	.p2align 3
.L1199:
	testl	$65280, %r9d
	jne	.L1200
.L1192:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1200:
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
	jne	.L1201
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1201
	movzbl	%r9b, %r13d
	movzbl	%r11b, %r12d
	cmpb	$11, %r9b
	jne	.L1203
	cmpl	$11, %r12d
	jne	.L1203
.L1214:
	xorl	%edx, %edx
	cmpq	%rbp, %r10
	sete	%dl
	movl	%edx, (%rbx)
.L1201:
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1203:
	cmpl	$1, %r13d
	je	.L1217
	cmpl	$1, %r12d
	je	.L1217
	cmpl	$3, %r13d
	jne	.L1206
	cmpl	$3, %r12d
	jne	.L1206
	testq	%r10, %r10
	sete	%dl
	testq	%rbp, %rbp
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1201
	.p2align 4,,10
	.p2align 3
.L1217:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1201
	.p2align 4,,10
	.p2align 3
.L1206:
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1210
	cmpl	$12, %r13d
	je	.L1240
	testl	%r13d, %r13d
	je	.L1209
	cmpl	$9, %r13d
	jne	.L1210
.L1209:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1210
	cmpl	$12, %r12d
	je	.L1241
	testl	%r12d, %r12d
	je	.L1214
	cmpl	$9, %r12d
	je	.L1214
	.p2align 4,,10
	.p2align 3
.L1210:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r10, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1242
.L1216:
	movl	$1, %eax
	jmp	.L1201
	.p2align 4,,10
	.p2align 3
.L1240:
	testl	$65280, %r9d
	je	.L1209
	jmp	.L1210
	.p2align 4,,10
	.p2align 3
.L1242:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1216
	xorl	%edx, %edx
	movsd	16(%rsp), %xmm0
	ucomisd	24(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1201
	.p2align 4,,10
	.p2align 3
.L1241:
	testl	$65280, %r11d
	je	.L1214
	jmp	.L1210
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
	jne	.L1243
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	je	.L1264
.L1243:
	addq	$40, %rsp
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1264:
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1245
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L1265
	testl	%eax, %eax
	je	.L1247
	cmpl	$9, %eax
	je	.L1247
	.p2align 4,,10
	.p2align 3
.L1245:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r12, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1266
.L1253:
	addq	$40, %rsp
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1266:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1253
	movsd	16(%rsp), %xmm1
	movsd	24(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1254
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1254:
	movq	%rdx, (%r11)
	jmp	.L1243
	.p2align 4,,10
	.p2align 3
.L1265:
	testl	$65280, %r9d
	jne	.L1245
.L1247:
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1245
	movzbl	%r10b, %edx
	cmpb	$12, %r10b
	je	.L1267
	testl	%edx, %edx
	je	.L1250
	cmpl	$9, %edx
	jne	.L1245
.L1250:
	xorl	%edx, %edx
	cmpq	%rbp, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%r11)
	jmp	.L1243
	.p2align 4,,10
	.p2align 3
.L1267:
	testl	$65280, %r10d
	je	.L1250
	jmp	.L1245
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
	jne	.L1268
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.L1272
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.L1270
	cmpl	$1, %ecx
	je	.L1273
.L1272:
	movl	$1, %eax
.L1268:
	ret
	.p2align 4,,10
	.p2align 3
.L1270:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.L1273:
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
	jne	.L1274
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.L1321
	cmpl	$12, %eax
	jne	.L1300
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
.L1282:
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
	ja	.L1282
	cmpl	%r12d, %r10d
	jb	.L1322
	movl	$1, %esi
.L1283:
	leal	1(%rsi,%r10), %eax
.L1284:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.L1285
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.L1323
	subl	%eax, %r14d
	je	.L1293
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1292:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1292
.L1293:
	testq	%r11, %r11
	jns	.L1291
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.L1291:
	testl	%esi, %esi
	je	.L1294
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.L1296
	.p2align 4,,10
	.p2align 3
.L1304:
	movl	%edx, %eax
.L1296:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1295
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1295:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.L1304
	addl	%esi, %r14d
.L1294:
	testl	%r10d, %r10d
	je	.L1274
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.L1298:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.L1297
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.L1297:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.L1298
.L1274:
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
.L1321:
	cmpq	$7, %rbx
	jbe	.L1285
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.L1278
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.L1280:
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
	jne	.L1280
	jmp	.L1274
	.p2align 4,,10
	.p2align 3
.L1300:
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
.L1322:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.L1283
	movl	%esi, %eax
	jmp	.L1284
	.p2align 4,,10
	.p2align 3
.L1285:
	movl	$3, %r8d
	jmp	.L1274
	.p2align 4,,10
	.p2align 3
.L1278:
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
	jmp	.L1274
	.p2align 4,,10
	.p2align 3
.L1323:
	testl	%r14d, %r14d
	je	.L1274
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1288:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.L1288
	jmp	.L1274
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
	jne	.L1324
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1324
	leal	-43(%rbx), %eax
	movq	%r9, %r14
	andl	$-3, %eax
	movl	%eax, %r15d
	je	.L1364
	cmpl	$42, %ebx
	je	.L1364
	cmpl	$47, %ebx
	je	.L1339
	cmpl	$37, %ebx
	je	.L1366
	movl	$1, %r10d
	cmpl	$94, %ebx
	je	.L1366
.L1324:
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
.L1364:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1339
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1387
	testl	%eax, %eax
	je	.L1330
	cmpl	$9, %eax
	je	.L1330
	.p2align 4,,10
	.p2align 3
.L1339:
	leaq	16(%rsp), %rcx
	leaq	32(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1324
	leaq	24(%rsp), %rcx
	leaq	40(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1324
	movsd	40(%rsp), %xmm1
	cmpl	$43, %ebx
	je	.L1388
	testl	%r15d, %r15d
	je	.L1389
	cmpl	$42, %ebx
	je	.L1390
	ucomisd	.LC47(%rip), %xmm1
	jp	.L1365
	je	.L1359
.L1365:
	movsd	32(%rsp), %xmm0
	movl	$517, %eax
	divsd	%xmm1, %xmm0
.L1342:
	movq	%rax, (%r14)
	movsd	%xmm0, 8(%r14)
	jmp	.L1324
	.p2align 4,,10
	.p2align 3
.L1387:
	testl	$65280, %r11d
	jne	.L1339
.L1330:
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1339
	movzbl	%r12b, %eax
	cmpb	$12, %r12b
	je	.L1391
	testl	%eax, %eax
	je	.L1333
	cmpl	$9, %eax
	jne	.L1339
.L1333:
	movq	$0, (%r14)
	cmpl	$43, %ebx
	je	.L1392
	testl	%r15d, %r15d
	je	.L1393
	imulq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1324
	.p2align 4,,10
	.p2align 3
.L1366:
	movq	%rsp, %rcx
	leaq	8(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1324
	leaq	4(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1324
	movsd	16(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1348
	ucomisd	.LC47(%rip), %xmm0
	jp	.L1349
	jne	.L1349
	movq	$0, (%r14)
	movq	$0, 8(%r14)
	jmp	.L1324
	.p2align 4,,10
	.p2align 3
.L1391:
	testl	$65280, %r12d
	je	.L1333
	jmp	.L1339
	.p2align 4,,10
	.p2align 3
.L1390:
	movl	$255, %edx
	movl	24(%rsp), %eax
	addl	16(%rsp), %eax
	cmpl	%edx, %eax
	movsd	32(%rsp), %xmm0
	cmova	%rdx, %rax
	mulsd	%xmm1, %xmm0
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1342
	.p2align 4,,10
	.p2align 3
.L1359:
	movl	$5, %r10d
	jmp	.L1324
	.p2align 4,,10
	.p2align 3
.L1388:
	addsd	32(%rsp), %xmm1
	movapd	%xmm1, %xmm0
.L1385:
	movl	24(%rsp), %eax
	movl	16(%rsp), %edx
	cmpl	%edx, %eax
	cmovb	%rdx, %rax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1342
	.p2align 4,,10
	.p2align 3
.L1389:
	movsd	32(%rsp), %xmm0
	subsd	%xmm1, %xmm0
	jmp	.L1385
	.p2align 4,,10
	.p2align 3
.L1392:
	addq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.L1324
.L1348:
	movsd	8(%rsp), %xmm1
	movq	%xmm0, %rcx
	movabsq	$9223372036854775807, %rax
	movq	%xmm1, %rsi
	movq	%xmm1, %rdx
	andq	%rax, %rsi
	andq	%rcx, %rax
	testq	%rdx, %rdx
	js	.L1394
	testq	%rsi, %rsi
	jne	.L1358
.L1353:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1351
	testq	%rcx, %rcx
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1351:
	movq	$517, (%r14)
	movq	%rdx, 8(%r14)
	jmp	.L1324
.L1393:
	subq	%r13, %rbp
	xorl	%r10d, %r10d
	movq	%rbp, 8(%r14)
	jmp	.L1324
.L1349:
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
	jmp	.L1351
.L1394:
	testq	%rsi, %rsi
	je	.L1353
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm2
	cmpq	%rdx, %rax
	ja	.L1354
	cvttsd2siq	%xmm2, %rdx
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rdx, %xmm1
	ucomisd	%xmm2, %xmm1
	jp	.L1361
	je	.L1354
.L1361:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1351
.L1358:
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
	jmp	.L1351
.L1354:
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
	ja	.L1386
	cvttsd2siq	%xmm2, %rax
	testb	$1, %al
	je	.L1386
	pxor	%xmm0, %xmm0
	subsd	%xmm1, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1351
.L1386:
	movq	%xmm1, %rdx
	jmp	.L1351
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
	ja	.L1395
	movl	%edi, %edi
	movq	CSWTCH.430(,%rdi,8), %rax
.L1395:
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
	ja	.L1401
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
	je	.L1401
	movabsq	$4503599627370495, %rcx
	andq	%rcx, %rax
	testq	%rdx, %rdx
	je	.L1496
	btsq	$52, %rax
	subl	$1075, %edx
	movl	$2, %edi
	movl	%eax, %ecx
	movslq	%edx, %r9
	shrq	$32, %rax
.L1405:
	movl	%ecx, 224(%rsp)
	leaq	224(%rsp), %r14
	movl	%eax, 228(%rsp)
	movl	%edi, 512(%rsp)
	testl	%ebx, %ebx
	je	.L1412
	xorl	%r10d, %r10d
	xorl	%r8d, %r8d
	leaq	224(%rsp), %r14
	.p2align 4,,10
	.p2align 3
.L1411:
	leal	-1(%rdi), %eax
	movq	%r14, %rdx
	leaq	228(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1413:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %rsi
	jne	.L1413
	testq	%rax, %rax
	je	.L1414
	movl	%edi, %edx
	movl	$1, %r10d
	addl	$1, %edi
	movl	%eax, 224(%rsp,%rdx,4)
.L1414:
	addl	$1, %r8d
	cmpl	%r8d, %ebx
	jne	.L1411
	testb	%r10b, %r10b
	je	.L1412
	movl	%edi, 512(%rsp)
.L1412:
	movl	%ebx, %esi
	addq	%r9, %rsi
	js	.L1417
	movq	%r14, %rdi
	call	bn_shl
	movl	512(%rsp), %r10d
.L1418:
	xorl	%r12d, %r12d
	jmp	.L1424
	.p2align 4,,10
	.p2align 3
.L1425:
	cmpq	$48, %r12
	je	.L1497
	movq	%r14, %rdi
	call	bn_divmod_1e9
	movl	512(%rsp), %r10d
	movl	%eax, 32(%rsp,%r12,4)
	addq	$1, %r12
.L1424:
	movl	%r12d, %r13d
	cmpl	$1, %r10d
	jne	.L1425
	movl	224(%rsp), %eax
	testl	%eax, %eax
	jne	.L1425
	testl	%r12d, %r12d
	jne	.L1498
	movl	$0, 32(%rsp)
	movl	$48, %edx
	movb	$48, 22(%rsp)
.L1430:
	leal	-1(%r10), %eax
	leaq	528(%rsp), %r14
	movq	%rax, %r11
	leaq	529(%rsp,%rax), %rcx
	leal	-1(%r10,%r14), %esi
	movq	%r14, %rax
	jmp	.L1433
	.p2align 4,,10
	.p2align 3
.L1499:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	22(%rsp,%rdx), %edx
.L1433:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1499
	testl	%r13d, %r13d
	je	.L1434
	leaq	32(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	.p2align 4,,10
	.p2align 3
.L1436:
	movl	%r11d, %edi
	movl	(%r12), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.L1435:
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
	jne	.L1435
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1500
	movq	%rax, %r12
	jmp	.L1436
	.p2align 4,,10
	.p2align 3
.L1401:
	xorl	%eax, %eax
.L1398:
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
.L1496:
	testq	%rax, %rax
	jne	.L1501
	cmpq	$0, 8(%rsp)
	jne	.L1502
	xorl	%edx, %edx
.L1406:
	testl	%ebx, %ebx
	je	.L1407
	leal	2(%rdx,%rbx), %esi
	cmpl	4(%rsp), %esi
	ja	.L1401
	movl	%edx, %eax
	movb	$48, 0(%rbp,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, 0(%rbp,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1409:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 0(%rbp,%rcx)
	cmpl	%edx, %esi
	jne	.L1409
	addl	%ebx, %eax
	jmp	.L1398
.L1502:
	movl	4(%rsp), %edx
	testl	%edx, %edx
	je	.L1401
	movb	$45, 0(%rbp)
	movl	$1, %edx
	jmp	.L1406
.L1417:
	negl	%esi
	movq	%r14, %rdi
	call	bn_shr_round
	movl	512(%rsp), %r10d
	cmpl	$3, %eax
	je	.L1503
	cmpl	$2, %eax
	jne	.L1418
	movl	224(%rsp), %ecx
	movl	%ecx, %edx
	andl	$1, %edx
	je	.L1418
	testl	%r10d, %r10d
	je	.L1451
.L1421:
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.L1423
	.p2align 4,,10
	.p2align 3
.L1504:
	movl	(%r14,%rdx,4), %ecx
.L1423:
	addq	%rcx, %rax
	movl	%eax, (%r14,%rdx,4)
	addq	$1, %rdx
	shrq	$32, %rax
	cmpl	%edx, %r10d
	ja	.L1504
	testq	%rax, %rax
	je	.L1418
	movl	%r10d, %eax
	addl	$1, %r10d
.L1420:
	movl	%r10d, 512(%rsp)
	movl	$1, 224(%rsp,%rax,4)
	jmp	.L1418
	.p2align 4,,10
	.p2align 3
.L1500:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %r10d
.L1434:
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
	ja	.L1401
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.L1439
	movb	$45, 0(%rbp)
	movl	$1, %edx
.L1439:
	cmpl	%r10d, %ebx
	jnb	.L1440
	testl	%eax, %eax
	je	.L1456
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1442:
	movzbl	(%r14), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1442
.L1441:
	testl	%ebx, %ebx
	je	.L1398
.L1443:
	cmpl	%r10d, %ebx
	movl	%r10d, %edi
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %edi
	movb	$46, 0(%rbp,%rcx)
	subl	%edi, %ebx
	je	.L1444
	leal	1(%rbx,%rax), %esi
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1445:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, 0(%rbp,%rcx)
	cmpl	%esi, %eax
	jne	.L1445
	addl	%ebx, %edx
.L1444:
	subl	%edi, %r10d
	leal	(%rdi,%rdx), %eax
	subl	%edx, %r10d
	.p2align 4,,10
	.p2align 3
.L1446:
	leal	(%r10,%rdx), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	528(%rsp,%rsi), %esi
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.L1446
	jmp	.L1398
.L1497:
	movl	220(%rsp), %ecx
	movl	$47, %r13d
.L1428:
	movl	$1, %esi
	movl	$3435973837, %r8d
	.p2align 4,,10
	.p2align 3
.L1431:
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
	ja	.L1431
	jmp	.L1430
.L1501:
	movl	%eax, %ecx
	shrq	$32, %rax
	movl	$0, %edx
	movq	$-1074, %r9
	cmpq	$1, %rax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rax, %rax
	cmove	%edx, %eax
	jmp	.L1405
.L1407:
	leal	1(%rdx), %eax
	cmpl	4(%rsp), %eax
	ja	.L1401
	movb	$48, 0(%rbp,%rdx)
	jmp	.L1398
.L1440:
	movb	$48, 0(%rbp,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1443
.L1503:
	testl	%r10d, %r10d
	je	.L1450
	movl	224(%rsp), %ecx
	jmp	.L1421
.L1456:
	movl	%edx, %eax
	jmp	.L1441
.L1451:
	xorl	%eax, %eax
	movl	%edx, %r10d
	jmp	.L1420
.L1450:
	xorl	%eax, %eax
	movl	$1, %r10d
	jmp	.L1420
.L1498:
	leal	-1(%r12), %eax
	movl	32(%rsp,%rax,4), %ecx
	movq	%rax, %r13
	jmp	.L1428
	.size	hrdbf_fmt_fixed, .-hrdbf_fmt_fixed
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.type	hrdbf_fmt_harbour, @function
hrdbf_fmt_harbour:
	endbr64
	cmpl	$32, %edx
	ja	.L1506
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1506:
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
	jne	.L1507
	movzwl	14(%rsi), %eax
	addq	%rax, %rdi
	movzbl	12(%rsi), %eax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	testq	%rcx, %rcx
	je	.L1509
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1510:
	movzbl	(%rdx,%rax), %r8d
	movb	%r8b, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1510
	movzbl	12(%rsi), %eax
.L1509:
	cmpq	%rcx, %rax
	jbe	.L1512
	.p2align 4,,10
	.p2align 3
.L1511:
	movb	$32, (%rdi,%rcx)
	movzbl	12(%rsi), %eax
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L1511
.L1512:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1507:
	ret
	.size	hrdbf_write_char, .-hrdbf_write_char
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.type	hrdbf_write_number_scaled, @function
hrdbf_write_number_scaled:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1521
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1521:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_scaled, .-hrdbf_write_number_scaled
	.p2align 4
	.globl	hrdbf_write_number_double
	.type	hrdbf_write_number_double, @function
hrdbf_write_number_double:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.L1523
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1523:
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
	jne	.L1524
	movzwl	14(%rsi), %eax
	addq	%rdi, %rax
	testl	%edx, %edx
	je	.L1539
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
	ja	.L1524
	cmpl	$9999, %ecx
	jbe	.L1524
	testl	%edi, %edi
	je	.L1524
	leal	-2(%rdx), %ecx
	movl	$31, %r10d
	cmpl	$9, %ecx
	jbe	.L1540
.L1528:
	movl	$3518437209, %esi
	imulq	%r9, %rsi
	shrq	$45, %rsi
	cmpl	$2, %edx
	je	.L1541
.L1529:
	movl	$5, %r8d
	cmpl	%edi, %r10d
	jb	.L1524
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
.L1524:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1539:
	leaq	8(%rax), %rdx
	.p2align 4,,10
	.p2align 3
.L1527:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1527
	xorl	%r8d, %r8d
	jmp	.L1524
	.p2align 4,,10
	.p2align 3
.L1540:
	movl	CSWTCH.439(,%rcx,4), %r10d
	jmp	.L1528
	.p2align 4,,10
	.p2align 3
.L1541:
	testb	$3, %sil
	jne	.L1529
	imull	$-1030792151, %esi, %ecx
	movl	%ecx, %r8d
	rorl	$2, %r8d
	cmpl	$42949672, %r8d
	ja	.L1530
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L1529
.L1530:
	addl	$1, %r10d
	jmp	.L1529
	.size	hrdbf_write_date, .-hrdbf_write_date
	.p2align 4
	.globl	hrdbf_write_logical
	.type	hrdbf_write_logical, @function
hrdbf_write_logical:
	endbr64
	cmpb	$76, 11(%rsi)
	movl	$3, %eax
	jne	.L1542
	cmpb	$1, %dl
	movzwl	14(%rsi), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	xorl	%eax, %eax
.L1542:
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
	jbe	.L1554
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1553
.L1554:
	movzbl	12(%rsi), %ecx
	testl	%ecx, %ecx
	je	.L1552
	leaq	(%rdi,%rdx), %rax
	subl	$1, %ecx
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1551:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1551
.L1552:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1553:
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
	je	.L1565
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
	js	.L1571
.L1565:
	xorl	%r9d, %r9d
.L1564:
	movq	2256(%r8), %rdi
	testq	%rdi, %rdi
	je	.L1562
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1567
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.L1562:
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1571:
	movl	$7, %r9d
	jmp	.L1564
	.p2align 4,,10
	.p2align 3
.L1567:
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
	movl	$257, %r8d
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$24, %rsp
	testl	%edx, %edx
	movb	$0, 2289(%rdi)
	setne	%al
	xorl	%r10d, %r10d
	cmpl	$1, %edx
	sbbq	%rdx, %rdx
	movl	%eax, 2272(%rdi)
	movq	$-100, %rdi
	andq	$-2, %rdx
	addq	$524290, %rdx
	.p2align 4,,10
	.p2align 3
.L1573:
	movq	%r8, %rax
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.L1573
	testq	%rax, %rax
	js	.L1611
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
	js	.L1609
	cmpq	$32, %rax
	jle	.L1612
	cmpq	$67108864, %rax
	jg	.L1613
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1614
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
	jb	.L1582
	movq	$0, 2256(%rbp)
.L1583:
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
	js	.L1610
	.p2align 4,,10
	.p2align 3
.L1577:
	movq	%rbp, %rdi
	call	hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r10d
.L1572:
	addq	$24, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1617:
	movq	%rax, %rdx
	movl	$.LC55, %esi
.L1609:
	movq	%rbp, %rdi
	call	ferr
.L1608:
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
	jmp	.L1577
	.p2align 4,,10
	.p2align 3
.L1582:
	movq	%rax, 2256(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L1583
	movq	2264(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.L1584
	.p2align 4,,10
	.p2align 3
.L1585:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L1588:
	movq	%r8, %rax
	movq	%r12, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L1588
	testq	%rax, %rax
	jne	.L1615
	movq	2264(%rbp), %rdx
	movq	2256(%rbp), %rsi
	movq	%rbp, %rdi
	call	hrdbf_open
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.L1590
	movl	2272(%rbp), %eax
	testl	%eax, %eax
	jne	.L1616
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
	jns	.L1572
	jmp	.L1610
	.p2align 4,,10
	.p2align 3
.L1618:
	movq	2256(%rbp), %rsi
.L1584:
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
	je	.L1586
	testq	%rax, %rax
	jle	.L1617
	addq	%rax, %r8
.L1586:
	movq	2264(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.L1618
	jmp	.L1585
	.p2align 4,,10
	.p2align 3
.L1613:
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
	jns	.L1577
	jmp	.L1610
.L1615:
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
.L1610:
	movl	$7, %r10d
	jmp	.L1577
	.p2align 4,,10
	.p2align 3
.L1612:
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
	jns	.L1577
	jmp	.L1610
.L1611:
	movq	%rax, %rdx
	movl	$.LC50, %esi
	movq	%rbp, %rdi
	call	ferr
	movl	$7, %r10d
	jmp	.L1572
.L1614:
	movl	$.LC51, %esi
	movq	%rbp, %rdi
	call	fset
	jmp	.L1608
.L1590:
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
	jns	.L1577
	jmp	.L1610
.L1616:
	movq	%r12, 2280(%rbp)
	movb	$1, 2288(%rbp)
	jmp	.L1572
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
	je	.L1621
	.p2align 4,,10
	.p2align 3
.L1622:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.L1622
.L1621:
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
	jne	.L1639
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.L1640
	cmpb	$78, %al
	je	.L1641
	cmpb	$68, %al
	je	.L1642
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1640:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.L1643
.L1628:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.L1644
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1642:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1641:
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
.L1643:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.L1631
	.p2align 4,,10
	.p2align 3
.L1630:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1630
.L1631:
	leaq	32(%rsp), %rdi
	jmp	.L1628
.L1639:
	movl	$.LC57, %edi
	call	hrdbf_app_fail
.L1644:
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
	je	.L1650
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.L1651
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L1652
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.L1653
	ret
.L1650:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L1653:
	movl	$.LC62, %edi
	call	hrdbf_app_fail
.L1652:
	movl	$.LC61, %edi
	call	hrdbf_app_fail
.L1651:
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
	jne	.L1655
	movq	2256(%rdi), %rdi
	testq	%rdi, %rdi
	je	.L1657
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1654
.L1663:
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.L1657:
	movl	%r9d, %edx
	movq	%r10, %rsi
	movq	%r8, %rdi
	jmp	hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.L1655:
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
	js	.L1667
	testq	%rdi, %rdi
	je	.L1657
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1663
.L1654:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1667:
	testq	%rdi, %rdi
	je	.L1654
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1654
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
	je	.L1668
	cmpb	$0, 2288(%rdi)
	je	.L1668
	cmpb	$0, 40(%rdi)
	je	.L1668
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L1668
	movl	16(%rdi), %edx
	cmpq	%rsi, %rdx
	jb	.L1668
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
	je	.L1672
	.p2align 4,,10
	.p2align 3
.L1670:
	movq	2280(%r8), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.L1670
	testq	%rax, %rax
	jle	.L1678
	cmpq	%rdx, %rax
	ja	.L1678
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.L1670
.L1672:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1678:
	movl	$7, %eax
.L1668:
	ret
	.size	hrdbf_file_write_record, .-hrdbf_file_write_record
	.p2align 4
	.globl	hrdbf_file_append
	.type	hrdbf_file_append, @function
hrdbf_file_append:
	endbr64
	movl	2272(%rdi), %eax
	testl	%eax, %eax
	je	.L1687
	cmpb	$0, 2288(%rdi)
	je	.L1687
	cmpb	$0, 40(%rdi)
	je	.L1687
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1687:
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
	je	.L1694
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.L1699:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1712
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1698
	.p2align 4,,10
	.p2align 3
.L1696:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1712
.L1698:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.L1696
	jnb	.L1712
	leal	1(%rdi), %r10d
.L1695:
	cmpl	%r11d, %r10d
	jb	.L1699
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1703
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.L1702:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.L1704
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1705
	.p2align 4,,10
	.p2align 3
.L1737:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1704
.L1705:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.L1737
.L1703:
	testl	%ebp, %ebp
	je	.L1693
	testl	%r12d, %r12d
	jne	.L1738
	movl	%r10d, %r11d
.L1693:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.L1712:
	movl	%edi, %r11d
	jmp	.L1695
.L1704:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.L1693
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.L1706
	.p2align 4,,10
	.p2align 3
.L1711:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.L1707
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.L1710
	.p2align 4,,10
	.p2align 3
.L1708:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1707
.L1710:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.L1708
	jb	.L1707
	movl	%edi, %r11d
.L1709:
	cmpl	%r11d, %r10d
	jb	.L1711
.L1706:
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
.L1707:
	leal	1(%rdi), %r10d
	jmp	.L1709
.L1738:
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
.L1694:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.L1693
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.L1702
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
	je	.L1740
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
	js	.L1740
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.L1740:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1741
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1752
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1741:
	cmpb	$0, hrdbf_app_state+2288(%rip)
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+2272(%rip)
	je	.L1746
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
	js	.L1759
.L1746:
	movq	hrdbf_app_state+2256(%rip), %rdi
	xorl	%r9d, %r9d
	testq	%rdi, %rdi
	je	.L1744
.L1743:
	movq	hrdbf_app_state+2264(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1747
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%r9d, %r8d
	movq	$0, hrdbf_app_state+2264(%rip)
.L1744:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%r8d, %r8d
	jne	.L1749
	ret
	.p2align 4,,10
	.p2align 3
.L1759:
	movq	hrdbf_app_state+2256(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1747
	movl	$7, %r9d
	jmp	.L1743
	.p2align 4,,10
	.p2align 3
.L1752:
	movl	$7, %r8d
	jmp	.L1741
.L1747:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.L1749:
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
.LC69:
	.string	"hbc: DBF open rejected: "
.LC70:
	.string	"\n"
	.text
	.p2align 4
	.globl	hrdbf_app_open
	.type	hrdbf_app_open, @function
hrdbf_app_open:
	endbr64
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$8, %rsp
	movq	%rdi, %rbx
	movq	%rcx, %rbp
	testq	%rdx, %rdx
	je	.L1761
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.L1809
.L1761:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.L1810
	xorl	%r9d, %r9d
	jmp	.L1762
	.p2align 4,,10
	.p2align 3
.L1790:
	movq	%r10, %r9
.L1762:
	movzbl	(%rbx,%r9), %eax
	testb	%al, %al
	je	.L1811
	leaq	1(%r9), %r10
	movb	%al, (%rsp,%r9)
	cmpq	%r10, %rsi
	jne	.L1790
	movq	hrdbf_app_order+32(%rip), %r13
	movb	$0, (%rsp,%r10)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r13, %r13
	je	.L1812
	movl	$11, %r12d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r13, %rdi
	movq	%r12, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1767
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1771
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1770
.L1772:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1771:
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	xorl	%ecx, %ecx
	movq	$0, hrdbf_app_pos(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1774:
	movzbl	(%rbx,%rax), %esi
	movq	%rax, %rdx
	addq	$1, %rax
	cmpb	$47, %sil
	cmove	%rax, %rcx
	cmpq	%rdx, %r9
	jne	.L1774
	cmpq	%r10, %rcx
	jnb	.L1775
	movq	%rcx, %rax
	jmp	.L1777
	.p2align 4,,10
	.p2align 3
.L1791:
	movq	%rdx, %rax
.L1777:
	cmpb	$46, (%rbx,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %r10
	cmpq	%r9, %rax
	jne	.L1791
.L1775:
	subq	%rcx, %r10
	leaq	(%rbx,%rcx), %rdi
	movl	$0, %edx
	movq	%r10, hrdbf_app_baselen(%rip)
	je	.L1782
	.p2align 4,,10
	.p2align 3
.L1778:
	movzbl	(%rdi,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rdx, %r10
	jne	.L1778
.L1782:
	xorl	%r10d, %r10d
	movl	$hrdbf_app_state, %edi
	testq	%r8, %r8
	movb	$0, hrdbf_app_state+2289(%rip)
	setne	%r10b
	call	hrdbf_file_close
	testl	%eax, %eax
	jne	.L1779
	movl	%r10d, %edx
	movq	%rsp, %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L1779
	addq	$4104, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1767:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1770
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1770
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1770:
	movl	$.LC68, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1812:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1771
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r13, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1772
	jmp	.L1770
.L1811:
	movl	$.LC67, %edi
	call	hrdbf_app_fail
.L1810:
	movl	$.LC66, %edi
	call	hrdbf_app_fail
.L1809:
	movl	$.LC65, %edi
	call	hrdbf_app_fail
.L1779:
	cmpb	$0, hrdbf_app_state+2289(%rip)
	movl	$hrdbf_app_state+2289, %r8d
	movl	$hrdbf_app_state+2090, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.L1785
	subl	$2, %eax
	movl	$.LC64, %r8d
	cmpl	$6, %eax
	ja	.L1785
	movq	CSWTCH.468(,%rax,8), %r8
.L1785:
	xorl	%edx, %edx
.L1786:
	addq	$1, %rdx
	cmpb	$0, .LC69(%rdx)
	jne	.L1786
	movl	$1, %eax
	movl	$2, %edi
	movl	$.LC69, %esi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.L1787
.L1788:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.L1788
.L1787:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.LC70, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call	hrdbf_app_exit
	.size	hrdbf_app_open, .-hrdbf_app_open
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1820
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1815
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L1816
.L1815:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1816:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L1818
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.L1819:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1818:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.L1819
.L1820:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1830
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1823
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1823
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rdx
	testl	%esi, %esi
	jne	.L1831
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.L1827:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
.L1828:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%edx, %edx
	sete	%dl
.L1825:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%dl, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1831:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.L1827
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
	jmp	.L1828
	.p2align 4,,10
	.p2align 3
.L1823:
	movl	hrdbf_app_state+16(%rip), %edx
	movl	$1, %eax
	testl	%edx, %edx
	cmovne	%rdx, %rax
	sete	%dl
	movl	%edx, %ecx
	jmp	.L1825
.L1830:
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
	je	.L1847
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1834
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1834
	testq	%rdi, %rdi
	je	.L1832
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.L1837
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.L1843
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.L1838:
	movq	%rsi, hrdbf_app_pos(%rip)
.L1839:
	cmpq	%rax, %rsi
	jnb	.L1841
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.L1842:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.L1832:
	ret
	.p2align 4,,10
	.p2align 3
.L1834:
	movl	$hrdbf_app_state, %edi
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L1843:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.L1838
	.p2align 4,,10
	.p2align 3
.L1841:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.L1842
	.p2align 4,,10
	.p2align 3
.L1837:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.L1840
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	jmp	.L1839
	.p2align 4,,10
	.p2align 3
.L1840:
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.L1839
.L1847:
	movl	$.LC59, %edi
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
	.string	"hbc: DBF index only one index is supported\n"
	.align 8
.LC74:
	.string	"hbc: DBF index filename length outside supported range\n"
	.align 8
.LC75:
	.string	"hbc: DBF index filename contains NUL\n"
	.align 8
.LC76:
	.string	"hbc: CDX must use a different basename from DBF; structural/autoopen indexes are outside this increment\n"
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
	endbr64
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1975
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L1976
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.L1977
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1851:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.L1978
	movb	%dl, 32(%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %dl
	leaq	32(%rsp), %r8
	cmove	%rax, %rcx
	cmpq	%rsi, %rax
	jne	.L1851
	movl	hrdbf_app_cdx(%rip), %ebp
	cmpq	%rsi, %rcx
	jnb	.L1854
	movq	%rsi, %rdx
	movq	%rcx, %rax
	xorl	%r9d, %r9d
	movl	$1, %r10d
	.p2align 4,,10
	.p2align 3
.L1856:
	cmpb	$46, (%rdi,%rax)
	cmove	%rax, %rdx
	cmove	%r10d, %r9d
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.L1856
	testl	%ebp, %ebp
	jne	.L1979
	testl	%r9d, %r9d
	je	.L1859
.L1911:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, 32(%rsp,%rax)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.L1980
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
	js	.L1981
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1869
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1908
.L1873:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1869:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.L1874:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.L1874
	testq	%rax, %rax
	js	.L1908
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
	js	.L1875
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.L1876
	cmpl	$1, %ebp
	movq	%r12, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.L1876
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1879
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
	jb	.L1880
	movq	$0, hrdbf_app_order+32(%rip)
.L1881:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.L1971
	.p2align 4,,10
	.p2align 3
.L1979:
	movq	hrdbf_app_baselen(%rip), %r11
	subq	%rcx, %rdx
	cmpq	%r11, %rdx
	je	.L1912
.L1861:
	movq	%rsi, %rax
	testl	%r9d, %r9d
	jne	.L1911
.L1910:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	movl	$100, %eax
	movb	$99, 33(%rsp,%rsi)
.L1909:
	movb	%al, 32(%rsp,%rdx)
	leaq	4(%rsi), %rax
	movb	$120, 35(%rsp,%rsi)
	jmp	.L1911
	.p2align 4,,10
	.p2align 3
.L1876:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rsi, %rdx
.L1974:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r10d
	testq	%rax, %rax
	js	.L1973
.L1885:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.L1901
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
	js	.L1902
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1904
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1908
.L1906:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1904:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L1908
	movl	$.LC71, %edi
	cmpl	$3, %r10d
	je	.L1872
	.p2align 4,,10
	.p2align 3
.L1908:
	movl	$.LC72, %edi
.L1872:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1980:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1869
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1873
	jmp	.L1908
	.p2align 4,,10
	.p2align 3
.L1981:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1908
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1908
.L1905:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.L1908
	.p2align 4,,10
	.p2align 3
.L1859:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	xorl	%ebp, %ebp
	movl	$116, %eax
	movb	$110, 33(%rsp,%rsi)
	jmp	.L1909
.L1902:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1908
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1905
	jmp	.L1908
.L1887:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.L1973:
	movl	$7, %r10d
	jmp	.L1885
.L1854:
	testl	%ebp, %ebp
	je	.L1859
	movq	%rsi, %r11
	subq	%rcx, %r11
	cmpq	%r11, hrdbf_app_baselen(%rip)
	jne	.L1910
	xorl	%r9d, %r9d
.L1912:
	testq	%r11, %r11
	je	.L1862
	movl	$1, %r10d
	xorl	%edx, %edx
	leaq	(%rdi,%rcx), %r12
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.L1865:
	movzbl	(%r12,%rdx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %ecx
	cmpb	$26, %dil
	cmovb	%ecx, %eax
	cmpb	%al, hrdbf_app_basename(%rdx)
	cmovne	%ebx, %r10d
	addq	$1, %rdx
	cmpq	%r11, %rdx
	jne	.L1865
	testl	%r10d, %r10d
	je	.L1861
.L1862:
	movl	$.LC76, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1875:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.L1885
.L1901:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1904
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1906
	jmp	.L1908
.L1880:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L1881
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.L1882
	jmp	.L1883
	.p2align 4,,10
	.p2align 3
.L1982:
	movq	hrdbf_app_order+32(%rip), %rsi
.L1882:
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
	je	.L1886
	testq	%rax, %rax
	jle	.L1887
	addq	%rax, %r8
.L1886:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.L1982
.L1883:
	leaq	31(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.L1888:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.L1888
	testq	%rax, %rax
	jne	.L1889
	cmpl	$1, %ebp
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.L1891
	xorl	%edx, %edx
	addq	$7, %rsi
	movl	$3, %r13d
	xorl	%r9d, %r9d
	shrq	$3, %rsi
	movl	$34, %r10d
	movq	%r12, %rdi
	movq	$-1, %r8
	divq	%rcx
	movq	%rsi, 8(%rsp)
	addq	%r15, %rsi
	movq	%r13, %rdx
	addq	$7, %rax
	shrq	$3, %rax
	addq	%rax, %rsi
	movq	%rax, %r14
	movl	$9, %eax
	movq	%rsi, hrdbf_app_order+56(%rip)
#APP
# 15 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.L1892
	movq	$0, hrdbf_app_order+40(%rip)
.L1893:
	movq	$0, hrdbf_app_order+56(%rip)
.L1971:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r10d
	testq	%rax, %rax
	jns	.L1885
	jmp	.L1973
.L1889:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.L1885
.L1879:
	movl	$3, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.L1885
.L1891:
	movl	$3, %eax
	movq	%r12, %rsi
	movq	%r12, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r10d
	testq	%rax, %rax
	jns	.L1885
	jmp	.L1973
.L1892:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.L1893
	testl	%ebp, %ebp
	movl	$hrntx_open, %edx
	movl	$hrcdx_open, %r10d
	movq	%rax, %r8
	cmove	%rdx, %r10
	addq	8(%rsp), %r14
	addq	%rax, %r15
	movq	hrdbf_app_order+48(%rip), %rdx
	pushq	%r14
	movl	$hrdbf_app_state, %ecx
	movl	hrdbf_app_state+16(%rip), %r9d
	movl	$hrdbf_app_order, %edi
	pushq	%r15
	movq	hrdbf_app_order+32(%rip), %rsi
	call	*%r10
	popq	%rdx
	popq	%rcx
	testl	%eax, %eax
	je	.L1897
	cmpl	$5, %eax
	movq	%rbx, %rdi
	movq	%r13, %rax
	movq	%r12, %rsi
	movq	%r12, %rdx
	jne	.L1974
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r10d
	testq	%rax, %rax
	jns	.L1885
	jmp	.L1973
	.p2align 4,,10
	.p2align 3
.L1897:
	movq	%r13, %rax
	movq	%rbx, %rdi
	movq	%r12, %rsi
	movq	%r12, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1973
	movl	$1, hrdbf_app_order_active(%rip)
	call	hrdbf_app_top
	addq	$4136, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L1978:
	movl	$.LC75, %edi
	call	hrdbf_app_fail
.L1975:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L1977:
	movl	$.LC74, %edi
	call	hrdbf_app_fail
.L1976:
	movl	$.LC73, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L1997
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.L1998
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
	js	.L1988
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.L1992
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1991
.L1993:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1992:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1988:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1991
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.L1991
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.L1991:
	movl	$.LC68, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1998:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.L1992
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.L1993
	jmp	.L1991
.L1997:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2001
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2001:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.LC77:
	.string	"hbc: DBF index seek requires an open index\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2009
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2004
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2004
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
	jb	.L2010
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.L2007:
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
.L2010:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.L2007
.L2004:
	movl	$.LC77, %edi
	call	hrdbf_app_fail
.L2009:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.section	.rodata.str1.8
	.align 8
.LC78:
	.string	"hbc: DBF index seek expects a character key value\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek_dyn
	.type	hrdbf_app_seek_dyn, @function
hrdbf_app_seek_dyn:
	endbr64
	pushq	%r13
	pushq	%r12
	subq	$296, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2049
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2013
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2013
	movq	%rdx, %r12
	movzbl	%dil, %edx
	movq	%rdi, %rax
	cmpl	$12, %edx
	ja	.L2015
	movq	%rsi, %rdi
	movq	%rcx, %r13
	notrack jmp	*.L2017(,%rdx,8)
	.section	.rodata
	.align 8
	.align 4
.L2017:
	.quad	.L2029
	.quad	.L2015
	.quad	.L2020
	.quad	.L2015
	.quad	.L2020
	.quad	.L2019
	.quad	.L2015
	.quad	.L2015
	.quad	.L2015
	.quad	.L2029
	.quad	.L2015
	.quad	.L2015
	.quad	.L2016
	.text
	.p2align 4,,10
	.p2align 3
.L2016:
	movzbl	%ah, %edx
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rsi, %xmm0
	leal	-1(%rdx), %eax
	testl	%edx, %edx
	je	.L2027
	movsd	.LC0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.L2028:
	divsd	%xmm1, %xmm0
	subl	$1, %eax
	jnb	.L2028
.L2027:
	comisd	.LC79(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	jbe	.L2048
.L2029:
	movzwl	hrdbf_app_order+28(%rip), %esi
	movq	%rsp, %rdx
	call	hrdbf_app_pad_ll
	movq	%r13, %rcx
	movq	%r12, %rdx
	movq	%rsp, %rdi
	movq	%rax, %rsi
	call	hrdbf_app_seek
	addq	$296, %rsp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L2015:
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
	addq	$296, %rsp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L2020:
	testq	%rsi, %rsi
	je	.L2050
	movq	-8(%rsi), %rsi
	addq	$296, %rsp
	movq	%r12, %rdx
	popq	%r12
	popq	%r13
	jmp	hrdbf_app_seek
	.p2align 4,,10
	.p2align 3
.L2019:
	testq	%rax, %rax
	jns	.L2023
	movq	(%rsi), %rdi
.L2023:
	movq	%rdi, %xmm0
	comisd	.LC79(%rip), %xmm0
	movabsq	$9223372036854775807, %rdi
	ja	.L2029
.L2048:
	movsd	.LC80(%rip), %xmm1
	addq	$1, %rdi
	comisd	%xmm0, %xmm1
	ja	.L2029
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L2051
	addsd	.LC81(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2029
	.p2align 4,,10
	.p2align 3
.L2051:
	subsd	.LC81(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.L2029
.L2013:
	movl	$.LC77, %edi
	call	hrdbf_app_fail
.L2049:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2050:
	movl	$.LC78, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_seek_dyn, .-hrdbf_app_seek_dyn
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2054
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.L2054:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2057
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.L2057:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_fcount
	.type	hrdbf_app_fcount, @function
hrdbf_app_fcount:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2060
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.L2060:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_fcount, .-hrdbf_app_fcount
	.p2align 4
	.globl	hrdbf_app_goto
	.type	hrdbf_app_goto, @function
hrdbf_app_goto:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2072
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %edx
	testq	%rdi, %rdi
	jle	.L2063
	xorl	%eax, %eax
	cmpq	%rdx, %rdi
	ja	.L2063
.L2064:
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rdi, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	je	.L2061
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2073
.L2061:
	ret
	.p2align 4,,10
	.p2align 3
.L2063:
	leaq	1(%rdx), %rdi
	movl	$1, %eax
	jmp	.L2064
	.p2align 4,,10
	.p2align 3
.L2073:
	movl	hrdbf_app_order+24(%rip), %ecx
	testl	%ecx, %ecx
	je	.L2070
	movq	hrdbf_app_order+16(%rip), %rsi
	xorl	%eax, %eax
	jmp	.L2068
	.p2align 4,,10
	.p2align 3
.L2067:
	addq	$1, %rax
	cmpq	%rcx, %rax
	je	.L2066
.L2068:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.L2067
.L2066:
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2070:
	xorl	%eax, %eax
	jmp	.L2066
.L2072:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_goto, .-hrdbf_app_goto
	.p2align 4
	.globl	hrdbf_app_ordselect
	.type	hrdbf_app_ordselect, @function
hrdbf_app_ordselect:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2084
	cmpq	$1, %rdi
	jne	.L2076
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2076
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %rsi
	movl	$1, hrdbf_app_order_active(%rip)
	testl	%ecx, %ecx
	je	.L2082
	movq	hrdbf_app_order+16(%rip), %rdi
	xorl	%eax, %eax
	jmp	.L2081
	.p2align 4,,10
	.p2align 3
.L2080:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2079
.L2081:
	movl	(%rdi,%rax,8), %edx
	cmpq	%rdx, %rsi
	jne	.L2080
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2076:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.L2082:
	xorl	%ecx, %ecx
.L2079:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2084:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_ordselect, .-hrdbf_app_ordselect
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2087
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.L2087:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2090
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.L2090:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2095
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2091
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2091:
	movq	%r8, %rax
	ret
.L2095:
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
	je	.L2102
	testq	%rdi, %rdi
	jle	.L2100
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.L2103
.L2100:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2103:
	call	hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.L2102:
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
	je	.L2105
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.L2107
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L2118:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2108:
	cmpb	$0, (%rsi,%rax)
	je	.L2109
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2108
.L2109:
	cmpq	%rax, %r9
	je	.L2130
.L2111:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.L2118
.L2107:
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
	movl	$.LC70, %esi
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
.L2130:
	testq	%r9, %r9
	je	.L2112
	xorl	%ecx, %ecx
	jmp	.L2116
	.p2align 4,,10
	.p2align 3
.L2131:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.L2112
.L2116:
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
	je	.L2131
	cmpq	%rcx, %r9
	jne	.L2111
	.p2align 4,,10
	.p2align 3
.L2112:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.L2132
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.L2132:
	movq	%r12, %rsi
	call	hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.L2105:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata.str1.8
	.align 8
.LC82:
	.string	"hbc: DBF field ordinal outside the open area\n"
	.align 8
.LC83:
	.string	"hbc: DBF field write type mismatch\n"
	.align 8
.LC84:
	.string	"hbc: DBF field write encoding rejected\n"
	.align 8
.LC85:
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
	jle	.L2134
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%r10, %rax
	jl	.L2134
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
	je	.L2136
	ja	.L2137
	cmpb	$67, %dl
	je	.L2138
	cmpb	$68, %dl
	jne	.L2140
	cmpl	$11, %ecx
	je	.L2195
	cmpl	$1, %ecx
	jne	.L2140
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2149
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2160
	.p2align 4,,10
	.p2align 3
.L2196:
	addq	$1, %rdx
.L2160:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2196
.L2145:
	movq	hrdbf_app_state+24(%rip), %rsi
.L2149:
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2197
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2137:
	cmpb	$78, %dl
	jne	.L2140
	cmpl	$12, %ecx
	je	.L2198
	testl	%ecx, %ecx
	je	.L2168
	cmpl	$9, %ecx
	je	.L2168
	cmpl	$5, %ecx
	je	.L2199
	cmpl	$1, %ecx
	jne	.L2140
	salq	$4, %rdi
	movzbl	hrdbf_app_state+54(%rdi), %ecx
	movzwl	hrdbf_app_state+56(%rdi), %edx
	testl	%ecx, %ecx
	je	.L2149
	addq	%rax, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.L2158
	.p2align 4,,10
	.p2align 3
.L2200:
	addq	$1, %rax
.L2158:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rax, %rcx
	jne	.L2200
	jmp	.L2145
	.p2align 4,,10
	.p2align 3
.L2138:
	leal	-2(%rcx), %edx
	andl	$-3, %edx
	je	.L2201
	cmpl	$1, %ecx
	jne	.L2140
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2149
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2150
	.p2align 4,,10
	.p2align 3
.L2202:
	addq	$1, %rdx
.L2150:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2202
	jmp	.L2145
	.p2align 4,,10
	.p2align 3
.L2136:
	cmpl	$3, %ecx
	je	.L2203
	cmpl	$1, %ecx
	jne	.L2140
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.L2149
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.L2163
	.p2align 4,,10
	.p2align 3
.L2204:
	addq	$1, %rdx
.L2163:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.L2204
	jmp	.L2145
	.p2align 4,,10
	.p2align 3
.L2203:
	cmpq	$1, %r12
	movzwl	24(%r10), %ecx
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rax,%rcx)
	movq	hrdbf_app_state+24(%rip), %rsi
	jmp	.L2149
	.p2align 4,,10
	.p2align 3
.L2201:
	movzwl	24(%r10), %ecx
	movzbl	22(%r10), %edx
	addq	%rax, %rcx
	movq	-8(%r12), %rax
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rax, %rax
	je	.L2143
	movq	%rcx, %rsi
	leaq	(%r12,%rax), %r8
	subq	%r12, %rsi
	.p2align 4,,10
	.p2align 3
.L2144:
	movzbl	(%r12), %edx
	movb	%dl, (%rsi,%r12)
	addq	$1, %r12
	cmpq	%r8, %r12
	jne	.L2144
	movq	%rdi, %rdx
	salq	$4, %rdx
	movzbl	hrdbf_app_state+54(%rdx), %edx
.L2143:
	cmpq	%rdx, %rax
	jnb	.L2145
	salq	$4, %rdi
	leaq	hrdbf_app_state+32(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.L2146:
	movb	$32, (%rcx,%rax)
	movzbl	22(%rsi), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2146
	jmp	.L2145
	.p2align 4,,10
	.p2align 3
.L2195:
	movl	%r12d, %edx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_date
.L2152:
	cmpl	$3, %eax
	je	.L2140
	testl	%eax, %eax
	je	.L2145
	movl	$.LC84, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2198:
	movzbl	%bh, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2152
	.p2align 4,,10
	.p2align 3
.L2168:
	xorl	%ecx, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2152
	.p2align 4,,10
	.p2align 3
.L2199:
	testq	%rbx, %rbx
	jns	.L2156
	movq	(%r12), %r12
.L2156:
	movq	%r12, %xmm0
	movq	%r8, %rsi
	movq	%rax, %rdi
	call	hrdbf_write_number_double.part.0
	jmp	.L2152
.L2140:
	movl	$.LC83, %edi
	call	hrdbf_app_fail
.L2134:
	movl	$.LC82, %edi
	call	hrdbf_app_fail
.L2197:
	movl	$.LC85, %edi
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
	je	.L2206
	movl	$hrdbf_app_state+42, %esi
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L2216:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2207:
	cmpb	$0, (%rsi,%rax)
	je	.L2208
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2207
.L2208:
	cmpq	%rax, %r10
	je	.L2229
.L2210:
	addl	$1, %r9d
	addq	$16, %rsi
	cmpl	%r9d, %r11d
	jne	.L2216
.L2206:
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
	movl	$.LC70, %esi
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
.L2229:
	testq	%r10, %r10
	je	.L2211
	xorl	%ecx, %ecx
	jmp	.L2215
	.p2align 4,,10
	.p2align 3
.L2230:
	addq	$1, %rcx
	cmpq	%rcx, %r10
	je	.L2211
.L2215:
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
	je	.L2230
	cmpq	%rcx, %r10
	jne	.L2210
.L2211:
	popq	%rbx
	movq	%r12, %rdx
	leal	1(%r9), %edi
	movq	%rbp, %rsi
	popq	%rbp
	popq	%r12
	jmp	hrdbf_app_fieldput
	.size	hrdbf_app_set_name, .-hrdbf_app_set_name
	.section	.rodata.str1.1
.LC86:
	.string	"hbc: DBF append failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_append
	.type	hrdbf_app_append, @function
hrdbf_app_append:
	endbr64
	subq	$24, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.L2239
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.L2240
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2241
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.L2242
	cmpb	$0, hrdbf_app_state+2288(%rip)
	je	.L2237
	leaq	12(%rsp), %rsi
	movl	$hrdbf_app_state, %edi
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2237
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	12(%rsp), %eax
	addq	$24, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2237:
	movl	$.LC86, %edi
	call	hrdbf_app_fail
.L2239:
	movl	$.LC59, %edi
	call	hrdbf_app_fail
.L2242:
	movl	$.LC62, %edi
	call	hrdbf_app_fail
.L2241:
	movl	$.LC61, %edi
	call	hrdbf_app_fail
.L2240:
	movl	$.LC60, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_append, .-hrdbf_app_append
	.section	.rodata.str1.8
	.align 8
.LC87:
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
	jne	.L2246
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.L2246:
	movl	$.LC87, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.LC88:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.LC89:
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
	jne	.L2248
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.L2264
	testl	%eax, %eax
	je	.L2256
	cmpl	$9, %eax
	jne	.L2252
.L2256:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2264:
	testl	$65280, %r9d
	je	.L2256
.L2251:
	movl	$.LC88, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2248:
	cmpl	$2, %eax
	je	.L2251
.L2252:
	movl	$.LC89, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.LC90:
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
	jne	.L2268
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.L2268:
	movl	$.LC90, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.LC91:
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
	jne	.L2270
	cmpb	$11, %dl
	je	.L2277
.L2270:
	leaq	24(%rsp), %r8
	movq	%r9, %rsi
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2278
	movq	24(%rsp), %rax
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2277:
	movq	%rcx, 8(%rsp)
	movq	%rdx, (%rsp)
	call	hrv_validate
	movq	(%rsp), %rdx
	movq	8(%rsp), %rcx
	testl	%eax, %eax
	jne	.L2272
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	%rcx, (%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2272
	movq	(%rsp), %rcx
	xorl	%eax, %eax
	movq	$-1, %rdx
	cmpq	%rcx, %r9
	seta	%al
	cmovb	%rdx, %rax
	addq	$40, %rsp
	ret
.L2278:
	movl	$.LC90, %edi
	call	hrdbf_app_fail
.L2272:
	movl	$.LC91, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.LC92:
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
	jne	.L2280
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.L2290
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.L2282
	.p2align 4,,10
	.p2align 3
.L2302:
	btq	%rax, %rcx
	jc	.L2294
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.L2290
.L2282:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.L2302
.L2294:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2280:
	cmpl	$8, %r10d
	je	.L2303
	cmpl	$5, %r10d
	je	.L2304
	cmpl	$7, %r10d
	je	.L2294
	subq	$8, %rsp
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2287
	cmpl	$12, %r10d
	ja	.L2287
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.L2288
	cmpl	$1, %r10d
	je	.L2295
.L2287:
	movl	$.LC92, %edi
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2290:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L2303:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.L2299
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.L2299:
	ret
	.p2align 4,,10
	.p2align 3
.L2304:
	testq	%rdi, %rdi
	js	.L2305
.L2286:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.LC47(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.L2305:
	movq	(%rsi), %r9
	jmp	.L2286
.L2288:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.L2279:
	addq	$8, %rsp
	ret
.L2295:
	movl	$1, %eax
	jmp	.L2279
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.LC93:
	.string	"hbc: DBF arithmetic division by zero\n"
	.align 8
.LC94:
	.string	"hbc: DBF arithmetic on a NIL or non-numeric operand\n"
	.section	.rodata.str1.1
.LC95:
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
	je	.L2311
	cmpl	$1, %eax
	je	.L2312
	testl	%eax, %eax
	jne	.L2313
	movq	(%rsp), %rax
	movq	8(%rsp), %rdx
	addq	$24, %rsp
	ret
.L2311:
	movl	$.LC93, %edi
	call	hrdbf_app_fail
.L2313:
	movl	$.LC95, %edi
	call	hrdbf_app_fail
.L2312:
	movl	$.LC94, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_arith, .-hrdbf_app_arith
	.section	.rodata.str1.8
	.align 8
.LC96:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
	endbr64
	movl	$.LC96, %edi
	call	hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.8
	.align 8
.LC97:
	.string	"unsupported table version or header flags"
	.section	.rodata.str1.1
.LC98:
	.string	"unsupported field type"
	.section	.rodata.str1.8
	.align 8
.LC99:
	.string	"size or field-count limit exceeded"
	.section	.rodata.str1.1
.LC100:
	.string	"record content invalid"
.LC101:
	.string	"I/O error"
.LC102:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	CSWTCH.468, @object
	.size	CSWTCH.468, 56
CSWTCH.468:
	.quad	.LC97
	.quad	.LC98
	.quad	.LC99
	.quad	.LC100
	.quad	.LC64
	.quad	.LC101
	.quad	.LC102
	.align 32
	.type	CSWTCH.439, @object
	.size	CSWTCH.439, 40
CSWTCH.439:
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
.LC103:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.LC104:
	.string	"DBF value type outside admitted operation"
	.align 8
.LC105:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.LC106:
	.string	"DBF value output buffer too short"
	.align 8
.LC107:
	.string	"DBF value tag or metadata invalid"
	.align 8
.LC108:
	.string	"DBF arithmetic division by zero"
	.section	.rodata
	.align 32
	.type	CSWTCH.430, @object
	.size	CSWTCH.430, 48
CSWTCH.430:
	.quad	.LC103
	.quad	.LC104
	.quad	.LC105
	.quad	.LC106
	.quad	.LC107
	.quad	.LC108
	.align 8
	.type	CSWTCH.403, @object
	.size	CSWTCH.403, 13
CSWTCH.403:
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
.LC79:
	.long	-798530048
	.long	1138748221
	.align 8
.LC80:
	.long	-798530048
	.long	-1008735427
	.align 8
.LC81:
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
