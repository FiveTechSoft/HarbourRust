	.text
	.p2align 4
hrdbfw_device_eq:
	testq	%rdx, %rdx
	je	.Lhrdbfw_16
	pushq	%rbx
	movq	%rdx, %r11
	movq	%rcx, %rbx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_7:
	movzwl	(%rbx,%rcx,2), %eax
	leal	-97(%rax), %r10d
	leal	-32(%rax), %r9d
	cmpl	$26, %r10d
	cmovb	%r9d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_9
	addq	$1, %rcx
	cmpq	%rcx, %r11
	je	.Lhrdbfw_6
.Lhrdbfw_2:
	movzbl	(%r8,%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_7
.Lhrdbfw_9:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_6:
	addq	%r11, %r8
	xorl	%eax, %eax
	popq	%rbx
	cmpb	$0, (%r8)
	sete	%al
	ret
.Lhrdbfw_16:
	xorl	%eax, %eax
	cmpb	$0, (%r8)
	sete	%al
	ret
	.p2align 4
hrdbfw_local_nxvisit:
	cmpl	$63, %r8d
	ja	.Lhrdbfw_60
	movl	%edx, %r9d
	testl	%edx, %edx
	je	.Lhrdbfw_60
	testl	$1023, %edx
	jne	.Lhrdbfw_60
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	movl	%edx, %edi
	pushq	%rsi
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$88, %rsp
	movq	(%rcx), %r10
	movq	8(%r10), %rax
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.Lhrdbfw_21
	movl	%edx, %ecx
	movl	%r9d, %eax
	movl	$1, %edx
	shrl	$10, %ecx
	shrl	$13, %eax
	addq	16(%rbx), %rax
	andl	$7, %ecx
	sall	%cl, %edx
	movzbl	(%rax), %ecx
	testb	%dl, %cl
	jne	.Lhrdbfw_21
	movq	(%r10), %r14
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movzwl	32(%rbx), %eax
	addq	%r14, %rdi
	movzwl	(%rdi), %r13d
	cmpw	%ax, %r13w
	ja	.Lhrdbfw_21
	testw	%r13w, %r13w
	jne	.Lhrdbfw_45
	testl	%r8d, %r8d
	je	.Lhrdbfw_45
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_21:
	movl	$1, %eax
.Lhrdbfw_17:
	addq	$88, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_60:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_45:
	leal	4(%rax,%rax), %eax
	xorl	%r12d, %r12d
	leaq	4(%rdi), %r15
	movl	%eax, 40(%rsp)
.Lhrdbfw_26:
	movzwl	%r12w, %eax
	movzwl	2(%rdi,%rax,2), %r11d
	movq	%r11, %rax
	cmpl	40(%rsp), %r11d
	jl	.Lhrdbfw_21
	movzwl	34(%rbx), %edx
	addq	%rdx, %rax
	movq	%rdx, %r10
	cmpq	$1024, %rax
	ja	.Lhrdbfw_21
	testw	%r12w, %r12w
	je	.Lhrdbfw_23
	leal	-1(%r12), %edx
	leaq	2(%rdi), %rax
	movzwl	%dx, %edx
	leal	(%r11,%r10), %ebp
	leaq	(%r15,%rdx,2), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_25:
	movzwl	(%rax), %edx
	leal	(%rdx,%r10), %ecx
	cmpl	%ecx, %r11d
	jge	.Lhrdbfw_24
	cmpl	%ebp, %edx
	jl	.Lhrdbfw_21
.Lhrdbfw_24:
	addq	$2, %rax
	cmpq	%rsi, %rax
	jne	.Lhrdbfw_25
.Lhrdbfw_23:
	addl	$1, %r12d
	cmpw	%r12w, %r13w
	jnb	.Lhrdbfw_26
	movzwl	2(%rdi), %eax
	movl	(%rdi,%rax), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_27
	movl	40(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_64
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_21
.Lhrdbfw_27:
	testl	%ebp, %ebp
	movzwl	%r13w, %eax
	movq	%rdi, %rsi
	movl	$1, %r15d
	setne	55(%rsp)
	addq	%rax, %rax
	leaq	2(%rdi,%rax), %rcx
	addq	%rdi, %rax
	movq	%rax, 40(%rsp)
	leal	1(%r8), %eax
	movl	%eax, 64(%rsp)
	leal	8(%r9), %eax
	movq	%rcx, 56(%rsp)
	movl	%eax, 68(%rsp)
.Lhrdbfw_41:
	movzwl	2(%rsi), %r13d
	movl	(%rdi,%r13), %edx
	movq	%r13, %r12
	testl	%edx, %edx
	setne	%al
	cmpb	55(%rsp), %al
	jne	.Lhrdbfw_21
	testl	%ebp, %ebp
	jne	.Lhrdbfw_29
.Lhrdbfw_32:
	cmpq	%rsi, 40(%rsp)
	je	.Lhrdbfw_30
	movl	4(%rdi,%r13), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_34
	movq	8(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_34
	cmpl	36(%rbx), %eax
	jbe	.Lhrdbfw_34
	leal	-1(%rdx), %r8d
	movl	%r15d, %r10d
	movl	%r8d, %ecx
	andl	$7, %ecx
	sall	%cl, %r10d
	movl	%r8d, %ecx
	shrl	$3, %ecx
	addq	24(%rbx), %rcx
	movzbl	(%rcx), %r9d
	testb	%r10b, %r9b
	jne	.Lhrdbfw_34
	orl	%r10d, %r9d
	movzwl	%r12w, %eax
	addl	68(%rsp), %eax
	movb	%r9b, (%rcx)
	movq	(%rbx), %r10
	movq	8(%rbx), %rcx
	movzwl	30(%r10), %r9d
	movzwl	28(%r10), %r12d
	movq	(%rcx), %r13
	salq	$4, %r9
	movzwl	56(%r9,%rcx), %r11d
	movzwl	32(%rcx), %r9d
	movzwl	34(%rcx), %ecx
	addq	%r11, %r9
	movl	%eax, %r11d
	imulq	%rcx, %r8
	addq	%r9, %r8
	testq	%r12, %r12
	je	.Lhrdbfw_35
	xorl	%ecx, %ecx
	leaq	(%r14,%r11), %r9
	addq	%r13, %r8
	jmp	.Lhrdbfw_36
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_66:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_65
.Lhrdbfw_36:
	movzbl	(%r8,%rcx), %r13d
	cmpb	%r13b, (%r9,%rcx)
	je	.Lhrdbfw_66
.Lhrdbfw_34:
	movl	$4, %eax
	jmp	.Lhrdbfw_17
.Lhrdbfw_29:
	movl	64(%rsp), %r8d
	movq	%rbx, %rcx
	call	hrdbfw_local_nxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_32
	jmp	.Lhrdbfw_17
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_65:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_44
.Lhrdbfw_63:
	movq	16(%r10), %r9
.Lhrdbfw_39:
	movl	%ecx, %r8d
	addl	$1, %ecx
	addq	$2, %rsi
	leaq	(%r9,%r8,8), %r8
	movl	%edx, (%r8)
	movl	%eax, 4(%r8)
	movl	%ecx, 36(%rbx)
	cmpq	%rsi, 56(%rsp)
	jne	.Lhrdbfw_41
.Lhrdbfw_30:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_17
.Lhrdbfw_64:
	movl	%r8d, 40(%rbx)
	jmp	.Lhrdbfw_27
.Lhrdbfw_44:
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	addq	%r14, %r12
	leaq	(%r9,%r8,8), %r8
	movl	4(%r8), %r10d
	movl	(%r8), %r13d
	addq	%r10, %r12
	leaq	(%r14,%r10), %r8
	movq	%r12, 72(%rsp)
	jmp	.Lhrdbfw_40
.Lhrdbfw_38:
	addq	$1, %r8
	cmpq	72(%rsp), %r8
	je	.Lhrdbfw_42
.Lhrdbfw_40:
	movq	%r8, %r12
	subq	%r10, %r12
	movzbl	(%r12,%r11), %r12d
	cmpb	%r12b, (%r8)
	je	.Lhrdbfw_38
	jb	.Lhrdbfw_39
	jmp	.Lhrdbfw_21
.Lhrdbfw_35:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_63
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	movl	(%r9,%r8,8), %r13d
.Lhrdbfw_42:
	cmpl	%r13d, %edx
	ja	.Lhrdbfw_39
	jmp	.Lhrdbfw_21
	.p2align 4
	.globl	hrntx_open
hrntx_open:
	leaq	-2048(%r8), %rax
	movq	$0, (%rcx)
	cmpq	$67106816, %rax
	movq	$0, 8(%rcx)
	movl	$1, %eax
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	ja	.Lhrdbfw_88
	testq	%rdx, %rdx
	je	.Lhrdbfw_88
	testl	$1023, %r8d
	jne	.Lhrdbfw_89
	testq	%r9, %r9
	je	.Lhrdbfw_89
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_131
	cmpw	$6, (%rdx)
	movl	$2, %eax
	jne	.Lhrdbfw_131
	cmpw	$0, 16(%rdx)
	jne	.Lhrdbfw_131
	pushq	%r15
	movq	$-260, %rax
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$104, %rsp
	jmp	.Lhrdbfw_70
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_69:
	addq	$1, %rax
	cmpq	$486, %rax
	je	.Lhrdbfw_134
.Lhrdbfw_70:
	cmpq	$11, %rax
	jbe	.Lhrdbfw_69
	cmpb	$0, 538(%rdx,%rax)
	je	.Lhrdbfw_69
.Lhrdbfw_103:
	movl	$2, %eax
.Lhrdbfw_67:
	addq	$104, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_88:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_131:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_89:
	ret
.Lhrdbfw_134:
	movzwl	14(%rdx), %r13d
	movl	$1, %eax
	leal	-1(%r13), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbfw_67
	leal	8(%r13), %r14d
	cmpw	%r14w, 12(%rdx)
	jne	.Lhrdbfw_67
	movzwl	18(%rdx), %r15d
	leal	-1(%r15), %ecx
	cmpw	$509, %cx
	ja	.Lhrdbfw_67
	movl	%r15d, %ecx
	shrw $1, %cx
	cmpw	20(%rdx), %cx
	jne	.Lhrdbfw_67
	leal	1(%r15), %ecx
	movzwl	%r14w, %r11d
	xorl	%edi, %edi
	movzwl	%cx, %r10d
	addq	%rcx, %rcx
	imulq	%r11, %r10
	andl	$131070, %ecx
	leaq	2(%r10,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbfw_71
	jmp	.Lhrdbfw_67
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_72:
	addq	$1, %rdi
	cmpq	$256, %rdi
	je	.Lhrdbfw_103
.Lhrdbfw_71:
	cmpb	$0, 22(%rdx,%rdi)
	jne	.Lhrdbfw_72
	testq	%rdi, %rdi
	je	.Lhrdbfw_103
	movzwl	36(%r9), %eax
	movw	%ax, 46(%rsp)
	testq	%rax, %rax
	je	.Lhrdbfw_103
	movq	%r8, 192(%rsp)
	movq	%r9, %rbp
	xorl	%r12d, %r12d
	movq	%rax, %r8
.Lhrdbfw_73:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_82
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_135:
	leal	-97(%rax), %r11d
	leal	-32(%rax), %r10d
	cmpb	$26, %r11b
	cmovb	%r10d, %eax
	movzbl	22(%rdx,%rcx), %r10d
	leal	-97(%r10), %esi
	leal	-32(%r10), %r11d
	cmpb	$26, %sil
	cmovb	%r11d, %r10d
	cmpb	%al, %r10b
	jne	.Lhrdbfw_75
	addq	$1, %rcx
	cmpq	%rdi, %rcx
	jnb	.Lhrdbfw_74
	cmpq	$10, %rcx
	ja	.Lhrdbfw_74
.Lhrdbfw_82:
	movzbl	42(%rbp,%rcx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_135
.Lhrdbfw_75:
	cmpq	%rdi, %rcx
	je	.Lhrdbfw_87
.Lhrdbfw_79:
	addq	$1, %r12
	addq	$16, %rbp
	cmpq	%r8, %r12
	jne	.Lhrdbfw_73
	jmp	.Lhrdbfw_103
.Lhrdbfw_74:
	cmpq	%rdi, %rcx
	jne	.Lhrdbfw_79
	cmpq	$11, %rcx
	je	.Lhrdbfw_80
.Lhrdbfw_87:
	movq	%r12, %rax
	salq	$4, %rax
	addq	%r9, %rax
	cmpb	$0, 42(%rcx,%rax)
	jne	.Lhrdbfw_79
.Lhrdbfw_80:
	movq	192(%rsp), %r8
	movl	%r12d, %r10d
	cmpw	%r12w, 46(%rsp)
	je	.Lhrdbfw_103
	movq	%r12, %rcx
	movl	$2, %eax
	salq	$4, %rcx
	addq	%r9, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbfw_67
	movzbl	54(%rcx), %ecx
	cmpw	%r13w, %cx
	jne	.Lhrdbfw_67
	movl	16(%r9), %eax
	cmpq	216(%rsp), %rax
	ja	.Lhrdbfw_109
	cmpq	$0, 208(%rsp)
	jne	.Lhrdbfw_110
	testl	%eax, %eax
	jne	.Lhrdbfw_109
.Lhrdbfw_110:
	movq	%r8, %rcx
	addq	$7, %rax
	shrq	$10, %rcx
	shrq	$3, %rax
	addq	$7, %rcx
	shrq	$3, %rcx
	cmpq	$0, 224(%rsp)
	je	.Lhrdbfw_109
	addq	%rcx, %rax
	cmpq	232(%rsp), %rax
	ja	.Lhrdbfw_109
	movq	224(%rsp), %r11
	addq	%r11, %rax
.Lhrdbfw_84:
	movb	$0, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_84
	movq	208(%rsp), %rax
	movq	%r8, 8(%rbx)
	xorl	%r8d, %r8d
	movq	%rdx, (%rbx)
	movq	%rax, 16(%rbx)
	movq	224(%rsp), %rax
	movw	%r13w, 28(%rbx)
	movq	%rax, 64(%rsp)
	movq	224(%rsp), %rax
	movw	%r10w, 30(%rbx)
	movl	4(%rdx), %edx
	addq	%rcx, %rax
	leaq	48(%rsp), %rcx
	movq	%rbx, 48(%rsp)
	movq	%rax, 72(%rsp)
	movl	$4294967295, %eax
	salq	$32, %rax
	movq	%r9, 56(%rsp)
	movq	%r9, 200(%rsp)
	movw	%r15w, 80(%rsp)
	movw	%r14w, 82(%rsp)
	movq	%rax, 84(%rsp)
	call	hrdbfw_local_nxvisit
	testl	%eax, %eax
	jne	.Lhrdbfw_85
	movq	200(%rsp), %r9
	movl	84(%rsp), %edx
	cmpl	16(%r9), %edx
	je	.Lhrdbfw_86
	movl	$4, %eax
.Lhrdbfw_85:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_67
.Lhrdbfw_86:
	movl	%edx, 24(%rbx)
	jmp	.Lhrdbfw_67
.Lhrdbfw_109:
	movl	$3, %eax
	jmp	.Lhrdbfw_67
	.p2align 4
hrdbfw_local_cxleaf_header:
	pushq	%r15
	movl	%edx, %r10d
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movzwl	2(%rcx), %r14d
	movw	%r14w, (%r8)
	movzwl	12(%rcx), %r12d
	movw	%r12w, 2(%r8)
	movl	14(%rcx), %edi
	movl	%edi, 20(%r8)
	movzbl	18(%rcx), %ebp
	movl	%ebp, 24(%r8)
	movzbl	19(%rcx), %r13d
	movl	%r13d, 28(%r8)
	movzbl	20(%rcx), %edx
	movl	%edx, 4(%r8)
	movzbl	21(%rcx), %ebx
	leal	-1(%rdx), %eax
	cmpl	$31, %eax
	movl	%ebx, 8(%r8)
	movzbl	22(%rcx), %r15d
	leal	-1(%rbx), %eax
	movl	%r15d, 12(%r8)
	movzbl	23(%rcx), %esi
	movl	%esi, 16(%r8)
	seta	%r8b
	cmpb	$7, %al
	seta	%al
	orl	%r8d, %eax
	leal	-1(%r15), %r8d
	cmpb	$7, %r8b
	seta	%r8b
	orb	%r8b, %al
	jne	.Lhrdbfw_142
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.Lhrdbfw_144
.Lhrdbfw_142:
	movl	$1, %eax
.Lhrdbfw_136:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_144:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.Lhrdbfw_136
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.Lhrdbfw_136
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.Lhrdbfw_136
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.Lhrdbfw_142
	cmpl	%r10d, %r13d
	jb	.Lhrdbfw_142
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbfw_136
	.p2align 4
hrdbfw_local_cxkey:
	pushq	%r12
	movq	%rcx, %r11
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	movl	16(%rdx), %edx
	movq	80(%rsp), %rdi
	movq	88(%rsp), %rsi
	movl	20(%rbx), %ebp
	testl	%edx, %edx
	je	.Lhrdbfw_146
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_147:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.Lhrdbfw_147
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.Lhrdbfw_148
	testl	%edx, %edx
	je	.Lhrdbfw_148
.Lhrdbfw_150:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_148:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.Lhrdbfw_150
.Lhrdbfw_156:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbfw_150
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_150
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.Lhrdbfw_151
	xorl	%eax, %eax
	jmp	.Lhrdbfw_152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_169:
	movq	(%rsi), %rcx
.Lhrdbfw_152:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbfw_169
.Lhrdbfw_151:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.Lhrdbfw_155
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_154:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_154
.Lhrdbfw_155:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_146:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_156
	.p2align 4
hrdbfw_local_cxvisit:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$408, %rsp
	movq	$512, 104(%rsp)
	cmpl	$64, %r8d
	je	.Lhrdbfw_173
	cmpl	$1023, %edx
	ja	.Lhrdbfw_224
.Lhrdbfw_173:
	movl	$1, %r12d
.Lhrdbfw_170:
	addq	$408, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_224:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.Lhrdbfw_173
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_173
	movl	%edx, %ecx
	movl	$1, %eax
	shrl	$9, %ecx
	andl	$7, %ecx
	sall	%cl, %eax
	movl	%eax, %ecx
	movl	%edx, %eax
	shrl	$12, %eax
	addq	32(%rbx), %rax
	movzbl	(%rax), %r9d
	testb	%cl, %r9b
	jne	.Lhrdbfw_173
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.Lhrdbfw_174
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.Lhrdbfw_173
.Lhrdbfw_174:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_225
	cmpl	%r10d, %ecx
	jne	.Lhrdbfw_173
	cmpl	%edx, 312(%rax)
	jne	.Lhrdbfw_173
.Lhrdbfw_196:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.Lhrdbfw_178
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_173
	testl	$511, %ecx
	jne	.Lhrdbfw_173
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.Lhrdbfw_173
.Lhrdbfw_178:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.Lhrdbfw_179
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_226
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_173
.Lhrdbfw_181:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	hrdbfw_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_170
	testl	%r13d, %r13d
	je	.Lhrdbfw_191
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.Lhrdbfw_182:
	movq	72(%rsp), %rax
	movzwl	28(%r14), %r9d
	movl	%r12d, %r8d
	movq	%r15, %rdx
	movq	%rbp, 32(%rsp)
	movq	%rsi, %rcx
	movq	%rax, 48(%rsp)
	movq	80(%rsp), %rax
	movq	%rax, 40(%rsp)
	call	hrdbfw_local_cxkey
	testl	%eax, %eax
	jne	.Lhrdbfw_201
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_184
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.Lhrdbfw_184
	cmpl	48(%rbx), %edx
	jbe	.Lhrdbfw_184
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.Lhrdbfw_184
	orl	%edi, %edx
	movb	%dl, (%rax)
	movq	16(%rbx), %rdx
	movl	100(%rsp), %r9d
	movq	24(%rbx), %r14
	movzwl	34(%rdx), %ecx
	movq	(%rdx), %r10
	leal	-1(%r9), %eax
	imull	%ecx, %eax
	movzwl	32(%rdx), %ecx
	addl	%ecx, %eax
	movzwl	30(%r14), %ecx
	salq	$4, %rcx
	movzwl	56(%rcx,%rdx), %ecx
	addl	%ecx, %eax
	movzwl	28(%r14), %ecx
	movl	%eax, 88(%rsp)
	movl	%eax, %edx
	testq	%rcx, %rcx
	je	.Lhrdbfw_185
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.Lhrdbfw_186
.Lhrdbfw_228:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbfw_227
	movq	%rdx, %rax
.Lhrdbfw_186:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.Lhrdbfw_228
.Lhrdbfw_184:
	movl	$4, %r12d
	jmp	.Lhrdbfw_170
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_225:
	cmpl	$-1, %r10d
	jne	.Lhrdbfw_173
	jmp	.Lhrdbfw_196
.Lhrdbfw_179:
	testl	%r13d, %r13d
	je	.Lhrdbfw_173
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.Lhrdbfw_173
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.Lhrdbfw_194:
	addl	$8, %eax
	movl	%r15d, %r8d
	movq	%rbx, %rcx
	movl	%r9d, %r14d
	imull	%ebp, %eax
	leal	12(%rax), %edi
	addq	%rsi, %rdi
	movl	4(%rdx,%rdi), %edx
	bswap	%edx
	call	hrdbfw_local_cxvisit
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_170
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.Lhrdbfw_173
	movq	24(%rbx), %rdx
	leal	-1(%r9), %eax
	movq	16(%rdx), %rcx
	movzwl	28(%rdx), %edx
	leaq	(%rcx,%rax,8), %r10
	movl	(%rdi,%rdx), %eax
	movq	%rdx, %r8
	movl	4(%r10), %ecx
	bswap	%eax
	cmpl	%eax, (%r10)
	jne	.Lhrdbfw_173
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_192
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.Lhrdbfw_193
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_229:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_192
.Lhrdbfw_193:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.Lhrdbfw_229
	jmp	.Lhrdbfw_173
.Lhrdbfw_226:
	movl	%r8d, 52(%rbx)
	jmp	.Lhrdbfw_181
.Lhrdbfw_192:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.Lhrdbfw_170
	movzwl	%r8w, %eax
	jmp	.Lhrdbfw_194
.Lhrdbfw_227:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_199
.Lhrdbfw_223:
	movq	16(%r14), %rcx
.Lhrdbfw_189:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.Lhrdbfw_182
	movzwl	94(%rsp), %edi
.Lhrdbfw_191:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbfw_170
.Lhrdbfw_199:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.Lhrdbfw_190
.Lhrdbfw_188:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.Lhrdbfw_197
	movq	%r11, %r8
.Lhrdbfw_190:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.Lhrdbfw_188
	jb	.Lhrdbfw_189
	jmp	.Lhrdbfw_173
.Lhrdbfw_185:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_223
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.Lhrdbfw_197:
	cmpl	%edi, %r9d
	ja	.Lhrdbfw_189
	jmp	.Lhrdbfw_173
.Lhrdbfw_201:
	movl	%eax, %r12d
	jmp	.Lhrdbfw_170
	.p2align 4
hrdbfw_local_cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.Lhrdbfw_230
	cmpb	$1, 15(%rcx)
	jne	.Lhrdbfw_230
	cmpw	$1024, 16(%rcx)
	jne	.Lhrdbfw_230
	cmpw	$512, 18(%rcx)
	jne	.Lhrdbfw_230
	cmpw	$0, 502(%rcx)
	jne	.Lhrdbfw_230
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.Lhrdbfw_233
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_253:
	cmpl	$23, %eax
	ja	.Lhrdbfw_240
.Lhrdbfw_232:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbfw_252
.Lhrdbfw_233:
	cmpb	$0, (%rcx,%rax)
	je	.Lhrdbfw_232
	testb	%dl, %dl
	je	.Lhrdbfw_253
.Lhrdbfw_240:
	movl	$2, %eax
.Lhrdbfw_230:
	ret
.Lhrdbfw_252:
	testl	%r8d, %r8d
	je	.Lhrdbfw_234
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_230
	cmpb	$67, 21(%rcx)
	jne	.Lhrdbfw_230
	cmpb	$72, 22(%rcx)
	jne	.Lhrdbfw_230
	cmpb	$66, 23(%rcx)
	jne	.Lhrdbfw_230
.Lhrdbfw_234:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_230
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.Lhrdbfw_230
	xorl	%eax, %eax
	cmpw	$0, 508(%rcx)
	setne	%al
	addl	%eax, %eax
	ret
	.p2align 4
hrdbf_get.part.0:
	leal	-1(%rdx), %eax
	pushq	%r14
	xorl	%r11d, %r11d
	salq	$4, %rax
	pushq	%r13
	addq	%rcx, %rax
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movzbl	53(%rax), %r9d
	movb	%r9b, (%r8)
	movzbl	54(%rax), %ebx
	movb	%bl, 1(%r8)
	movzbl	55(%rax), %r10d
	movb	%r10b, 2(%r8)
	movq	24(%rcx), %rdx
	movl	16(%rcx), %esi
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_254
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_334
	cmpb	$78, %r9b
	je	.Lhrdbfw_335
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_336
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_281
	cmpb	$89, %al
	je	.Lhrdbfw_281
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_254
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_254
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_254:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_281:
	xorl	%r11d, %r11d
	popq	%rbx
	popq	%rsi
	movb	$1, 28(%r8)
	popq	%rdi
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_335:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_258
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_259
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_260:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_258
.Lhrdbfw_259:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_260
	jmp	.Lhrdbfw_262
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_286:
	movl	%r9d, %ecx
.Lhrdbfw_262:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_261
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_286
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_264
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_284:
	movl	%eax, %ecx
	subl	%eax, %r9d
	xorl	%ebp, %ebp
	xorl	%ebx, %ebx
	leaq	1(%rdx,%rcx), %rax
	leaq	(%rdx,%rcx), %r11
	xorl	%esi, %esi
	xorl	%edx, %edx
	movabs	$-3689348814741910323, %r13
	addq	%rax, %r9
	jmp	.Lhrdbfw_268
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_338:
	testl	%esi, %esi
	jne	.Lhrdbfw_305
	movl	$1, %esi
.Lhrdbfw_266:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_337
.Lhrdbfw_268:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_338
.Lhrdbfw_305:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_298
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_295
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_266
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_266
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_334:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rsi
	movq	%rdx, 8(%r8)
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_336:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_277:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_297
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_277
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_298:
	movl	$5, %r11d
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_297:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_276:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_298
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_276
	movl	%r9d, %ecx
	movl	$5, %r11d
	imulq	$1374389535, %rcx, %rdx
	shrq	$37, %rdx
	movl	%edx, %eax
	imulq	$1374389535, %rax, %rax
	shrq	$37, %rax
	imull	$100, %eax, %r10d
	movl	%edx, %eax
	imull	$100, %edx, %edx
	subl	%r10d, %eax
	movl	%r9d, %r10d
	subl	%edx, %r10d
	leal	-1(%rax), %edx
	cmpl	$9999, %r9d
	jbe	.Lhrdbfw_254
	cmpl	$11, %edx
	ja	.Lhrdbfw_254
	testl	%r10d, %r10d
	je	.Lhrdbfw_254
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_339
.Lhrdbfw_279:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_254
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_264:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_265:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_298
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_284
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_295:
	movl	$4, %r11d
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_337:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_254
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_254
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_269
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_270
	jmp	.Lhrdbfw_295
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_271:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_295
.Lhrdbfw_270:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_271
	testl	%r12d, %r12d
	jne	.Lhrdbfw_283
.Lhrdbfw_274:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_254
.Lhrdbfw_261:
	je	.Lhrdbfw_258
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_264
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_265
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_258:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_254
.Lhrdbfw_339:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_279
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_280
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_279
.Lhrdbfw_280:
	addl	$1, %edx
	jmp	.Lhrdbfw_279
.Lhrdbfw_269:
	testl	%r12d, %r12d
	je	.Lhrdbfw_274
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_274
.Lhrdbfw_283:
	negq	%rbx
	jmp	.Lhrdbfw_274
	.p2align 4
hrntx_file_close.constprop.0:
	pushq	%r12
	subq	$32, %rsp
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_343
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_355
.Lhrdbfw_343:
	xorl	%r12d, %r12d
.Lhrdbfw_342:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_344
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_356
	movl	$7, %r12d
.Lhrdbfw_344:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_340
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_347
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_340:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_356:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_344
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_355:
	movl	$7, %r12d
	jmp	.Lhrdbfw_342
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_347:
	movl	$7, %r12d
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4
hrdbfw_local_cxmark.isra.0:
	movq	%rcx, %r8
	movl	%edx, %ecx
	shrl	$3, %edx
	movl	$1, %eax
	andl	$7, %ecx
	addq	%r8, %rdx
	sall	%cl, %eax
	movzbl	(%rdx), %ecx
	testb	%al, %cl
	jne	.Lhrdbfw_357
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_357:
	ret
	.p2align 4
	.globl	hrcdx_open
hrcdx_open:
	pushq	%r15
	leaq	-2048(%r8), %rax
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$968, %rsp
	movq	$0, (%rcx)
	movq	$512, 88(%rsp)
	movq	$0, 8(%rcx)
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	cmpq	$67106816, %rax
	ja	.Lhrdbfw_363
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_363
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_363
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_363
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_363
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_359
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_359
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_359
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_359
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_363
	testl	$511, %r12d
	jne	.Lhrdbfw_363
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_363
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_359
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_359
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_363
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_363
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_359
	leaq	84(%rsp), %rax
	movq	72(%rsp), %r10
	xorl	%r8d, %r8d
	movq	%r14, %rcx
	movq	%rax, 48(%rsp)
	leaq	128(%rsp), %r15
	leaq	88(%rsp), %rax
	movl	$10, %r9d
	movq	%rax, 40(%rsp)
	movq	%r10, %rdx
	movq	%r15, 32(%rsp)
	call	hrdbfw_local_cxkey
	testl	%eax, %eax
	jne	.Lhrdbfw_359
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_363
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_363
	testl	$511, %eax
	jne	.Lhrdbfw_363
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_363
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_363
	cmpl	%r12d, %eax
	je	.Lhrdbfw_363
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_363
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_364
.Lhrdbfw_437:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_401
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_436
.Lhrdbfw_364:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_437
.Lhrdbfw_401:
	movl	$2, %eax
	jmp	.Lhrdbfw_359
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_363:
	movl	$1, %eax
.Lhrdbfw_359:
	addq	$968, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbfw_436:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_359
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_401
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_401
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_401
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_365:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_401
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_365
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_366:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_401
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_375:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_369
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_370
	subl	$32, %ecx
.Lhrdbfw_370:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_371
	subl	$32, %r13d
.Lhrdbfw_371:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_369
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_367
	cmpq	$11, %rdx
	jne	.Lhrdbfw_375
	cmpq	$11, %rax
	jne	.Lhrdbfw_369
.Lhrdbfw_373:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_401
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_401
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_400
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_401
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_405
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_407
	testl	%eax, %eax
	jne	.Lhrdbfw_405
.Lhrdbfw_407:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_405
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_405
	xorl	%edx, %edx
.Lhrdbfw_377:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_377
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_378
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_378:
	testb	$2, %al
	jne	.Lhrdbfw_379
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_379:
	movq	1088(%rsp), %rcx
	movl	%r12d, %edx
	shrl	$9, %edx
	call	hrdbfw_local_cxmark.isra.0
	movl	84(%rsp), %edx
	movq	1088(%rsp), %rcx
	shrl	$9, %edx
	call	hrdbfw_local_cxmark.isra.0
	movl	84(%rsp), %edx
	movq	1088(%rsp), %rcx
	shrl	$9, %edx
	addl	$1, %edx
	call	hrdbfw_local_cxmark.isra.0
	movq	0(%rbp), %rax
	movq	%rdi, 384(%rsp)
	leaq	640(%rsp), %rdx
	movq	%rbp, 400(%rsp)
	movq	%rax, (%rbx)
	movq	8(%rbp), %rax
	movq	%rbx, 408(%rsp)
	movq	%rax, 8(%rbx)
	movq	1072(%rsp), %rax
	movl	$0, 24(%rbx)
	movq	%rax, 16(%rbx)
	movzbl	54(%r10), %eax
	movw	%r9w, 30(%rbx)
	movw	%ax, 28(%rbx)
	movq	1088(%rsp), %rax
	movq	%rsi, 392(%rsp)
	leaq	384(%rsp), %rsi
	addq	%rax, %r11
	movq	%rax, 416(%rsp)
	movl	$4294967295, %eax
	movq	%r11, 424(%rsp)
	salq	$32, %rax
	movq	%rax, 432(%rsp)
	movq	%rsi, %rax
.Lhrdbfw_380:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_380
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_438
.Lhrdbfw_381:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_359
.Lhrdbfw_367:
	cmpq	$11, %rax
	je	.Lhrdbfw_373
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_373
.Lhrdbfw_369:
	addq	$1, %r9
	jmp	.Lhrdbfw_366
.Lhrdbfw_405:
	movl	$3, %eax
	jmp	.Lhrdbfw_359
.Lhrdbfw_400:
	movl	$5, %eax
	jmp	.Lhrdbfw_359
.Lhrdbfw_438:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_381
	xorl	%edx, %edx
	jmp	.Lhrdbfw_383
.Lhrdbfw_439:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_408
.Lhrdbfw_383:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_382
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_382:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_439
.Lhrdbfw_408:
	testl	%eax, %eax
	jne	.Lhrdbfw_381
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_359
	.section .rdata,"dr"
.Lhrdbfw_C0:

.byte 67,79,78,0
.Lhrdbfw_C1:

.byte 80,82,78,0
.Lhrdbfw_C2:

.byte 65,85,88,0
.Lhrdbfw_C3:

.byte 78,85,76,0
.Lhrdbfw_C4:

.byte 67,79,78,73,78,36,0
.Lhrdbfw_C5:

.byte 67,79,78,79,85,84,36,0
.Lhrdbfw_C6:

.byte 67,76,79,67,75,36,0
.Lhrdbfw_C7:

.byte 67,79,77,0
.Lhrdbfw_C8:

.byte 76,80,84,0
	.text
	.p2align 4
hrdbfw_snapshot:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	movq	%rdx, %rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$632, %rsp
	movzbl	(%rcx), %edx
	movq	%r9, 728(%rsp)
	testb	%dl, %dl
	je	.Lhrdbfw_444
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.Lhrdbfw_542
	cmpb	$47, %dl
	jne	.Lhrdbfw_537
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_444
	movl	$47, %eax
.Lhrdbfw_445:
	movabs	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.Lhrdbfw_446
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_544:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.Lhrdbfw_444
.Lhrdbfw_450:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_543
	js	.Lhrdbfw_444
	cmpq	$258, %rbx
	ja	.Lhrdbfw_444
.Lhrdbfw_446:
	cmpb	$63, %al
	ja	.Lhrdbfw_544
	btq	%rax, %r9
	jc	.Lhrdbfw_444
	cmpb	$60, %al
	je	.Lhrdbfw_444
	cmpb	$58, %al
	jne	.Lhrdbfw_449
	cmpq	$1, %rbx
	jne	.Lhrdbfw_444
	cmpb	$25, %dl
	ja	.Lhrdbfw_444
	movl	$58, %eax
	jmp	.Lhrdbfw_450
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_549:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_455
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_444:
	movl	$7, %r14d
.Lhrdbfw_440:
	addq	$632, %rsp
	movl	%r14d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_542:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.Lhrdbfw_445
	jmp	.Lhrdbfw_444
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_449:
	cmpb	$47, %al
	jne	.Lhrdbfw_450
	movl	$92, %eax
	jmp	.Lhrdbfw_450
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_537:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.Lhrdbfw_445
	jmp	.Lhrdbfw_444
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_543:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.Lhrdbfw_470
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_453:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.Lhrdbfw_545
	movq	%rax, %rbx
.Lhrdbfw_470:
	cmpq	%r15, %r12
	je	.Lhrdbfw_452
	cmpw	$92, (%rdi,%r15,2)
	jne	.Lhrdbfw_453
.Lhrdbfw_452:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.Lhrdbfw_485
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.Lhrdbfw_454
	cmpw	$46, %ax
	je	.Lhrdbfw_454
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.Lhrdbfw_455:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_457
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_458:
	movzwl	0(%r13,%rax,2), %edx
.Lhrdbfw_457:
	cmpw	$46, %dx
	je	.Lhrdbfw_546
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_458
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.Lhrdbfw_460
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_464:
	subq	$1, %rsi
	je	.Lhrdbfw_460
.Lhrdbfw_463:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.Lhrdbfw_464
.Lhrdbfw_460:
	leaq	.Lhrdbfw_C0(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C1(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C2(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C3(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_444
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.Lhrdbfw_453
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_453
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_467
.Lhrdbfw_547:
	leaq	.Lhrdbfw_C7(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_483
	movzwl	0(%r13,%rcx,2), %eax
.Lhrdbfw_467:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_483
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_547
	jmp	.Lhrdbfw_444
.Lhrdbfw_483:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_469
.Lhrdbfw_548:
	movzwl	0(%r13,%rdx,2), %r14d
.Lhrdbfw_469:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_485
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_444
	leaq	.Lhrdbfw_C8(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_548
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_485:
	movq	%rbx, %rcx
	jmp	.Lhrdbfw_453
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_454:
	cmpq	$1, %rsi
	je	.Lhrdbfw_549
	cmpq	$2, %rsi
	jne	.Lhrdbfw_444
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.Lhrdbfw_444
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_455
	jmp	.Lhrdbfw_444
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_546:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_463
	jmp	.Lhrdbfw_460
.Lhrdbfw_545:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.Lhrdbfw_444
	cmpq	$1, %rbx
	je	.Lhrdbfw_471
	cmpw	$58, 98(%rsp)
	je	.Lhrdbfw_550
.Lhrdbfw_471:
	movq	%r12, %rcx
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	movl	$-2147483648, %edx
	movq	$0, 48(%rsp)
	movl	$128, 40(%rsp)
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_444
	movq	728(%rsp), %rax
	leaq GetFileSizeEx(%rip), %r13
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_444
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_487
	cmpq	$67108864, %r10
	jg	.Lhrdbfw_487
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_472
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	movl	$1, %r14d
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_440
.Lhrdbfw_472:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.Lhrdbfw_489
	movq	(%rdi), %r8
	leaq ReadFile(%rip), %rsi
	leaq	76(%rsp), %r14
	testq	%r8, %r8
	je	.Lhrdbfw_473
	leaq ReadFile(%rip), %rsi
	xorl	%ebx, %ebx
	leaq	76(%rsp), %r14
	movq	%rax, %rdx
	jmp	.Lhrdbfw_474
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_551:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_444
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%rbx, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_444
	addq	%rax, %rbx
	cmpq	%rbx, %r8
	jbe	.Lhrdbfw_473
	movq	0(%rbp), %rdx
.Lhrdbfw_474:
	addq	%rbx, %rdx
	subl	%ebx, %r8d
	movq	%r14, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rsi
	testl	%eax, %eax
	jne	.Lhrdbfw_551
	jmp	.Lhrdbfw_444
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_487:
	movl	$1, %r14d
	jmp	.Lhrdbfw_440
.Lhrdbfw_473:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%r14, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rsi
	testl	%eax, %eax
	je	.Lhrdbfw_444
	movl	76(%rsp), %r14d
	testl	%r14d, %r14d
	jne	.Lhrdbfw_444
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_444
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_440
	jmp	.Lhrdbfw_444
.Lhrdbfw_489:
	movl	$8, %r14d
	jmp	.Lhrdbfw_440
.Lhrdbfw_550:
	cmpq	$2, %rbx
	je	.Lhrdbfw_444
	cmpw	$92, 100(%rsp)
	jne	.Lhrdbfw_444
	jmp	.Lhrdbfw_471
	.p2align 4
	.globl	hrdbf_close
hrdbf_close:
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	ret
	.p2align 4
	.globl	hrdbf_top
hrdbf_top:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_553
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_553:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_556
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_556
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_558
	movl	16(%rcx), %r8d
	movq	%r8, %r10
	movq	%r8, %r9
	addq	$1, %r8
	subq	%rax, %r10
	addq	%rdx, %rax
	addq	$1, %r10
	cmpq	%rdx, %r10
	cmovb	%r8, %rax
	movq	%rax, 24(%rcx)
.Lhrdbfw_560:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_570
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_556:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_558:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_561
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_570:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_561:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_560
	.p2align 4
	.globl	hrdbf_get
hrdbf_get:
	movl	$85, %eax
	movb	$0, 28(%r8)
	movw	%ax, (%r8)
	movb	$0, 2(%r8)
	movq	$0, 8(%r8)
	movq	$0, 16(%r8)
	movl	$0, 24(%r8)
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_573
	testl	%edx, %edx
	je	.Lhrdbfw_575
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_575
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_575:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_573:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_576
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_578
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_578:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_576:
	ret
	.p2align 4
	.globl	hrdbf_open
hrdbf_open:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$2216, %rsp
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	$0, 112(%rsp)
	movq	$0, 120(%rsp)
	movq	$0, 136(%rsp)
	movl	$16842752, 148(%rsp)
	movb	$0, 152(%rsp)
	cmpq	$32, %r8
	jbe	.Lhrdbfw_620
	cmpb	$3, (%rdx)
	movq	%rdx, %rsi
	movl	$2, %eax
	jne	.Lhrdbfw_581
	cmpb	$0, 14(%rdx)
	jne	.Lhrdbfw_581
	cmpb	$0, 15(%rdx)
	jne	.Lhrdbfw_581
	cmpb	$0, 28(%rdx)
	jne	.Lhrdbfw_581
	cmpb	$0, 29(%rdx)
	jne	.Lhrdbfw_581
	movzwl	8(%rdx), %eax
	movzwl	10(%rdx), %r14d
	movl	4(%rdx), %r13d
	movw	%ax, 144(%rsp)
	movw	%r14w, 146(%rsp)
	movl	%r13d, 128(%rsp)
	cmpw	$32, %ax
	jbe	.Lhrdbfw_620
	movzwl	%r14w, %edi
	movq	%rcx, %rbx
	movzwl	%ax, %ecx
	testl	%edi, %edi
	movl	%edi, 76(%rsp)
	sete	%dl
	cmpq	%r8, %rcx
	movq	%rcx, 40(%rsp)
	seta	%al
	orb	%dl, %al
	je	.Lhrdbfw_640
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_620:
	movl	$1, %eax
.Lhrdbfw_581:
	addq	$2216, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbfw_640:
	leaq	-32(%rcx), %rdx
	leaq	112(%rsp), %r11
	xorl	%r10d, %r10d
	xorl	%r15d, %r15d
	leaq	181(%rsp), %rcx
	shrq	$5, %rdx
	movq	%r11, 56(%rsp)
	movl	$1, %r9d
	movq	%rcx, 64(%rsp)
	leaq	32(%rsi), %rdi
	movq	%rsi, 2296(%rsp)
	movq	%rdx, 48(%rsp)
	movl	$32, %edx
	movq	%rbx, 2288(%rsp)
	movq	%rdx, %rbx
	movq	%r8, 2304(%rsp)
	movl	%r9d, %r8d
.Lhrdbfw_598:
	movzbl	(%rdi), %ecx
	cmpb	$13, %cl
	je	.Lhrdbfw_641
	cmpq	48(%rsp), %r15
	je	.Lhrdbfw_620
	cmpq	$4128, %rbx
	je	.Lhrdbfw_621
	movl	%r15d, %eax
	movl	%r15d, %esi
	xorl	%edx, %edx
	jmp	.Lhrdbfw_589
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_642:
	movzbl	(%rdi,%rdx), %ecx
.Lhrdbfw_589:
	movb	%cl, 42(%r11,%rdx)
	addq	$1, %rdx
	cmpq	$11, %rdx
	jne	.Lhrdbfw_642
	movzbl	42(%r11), %r12d
	testb	%r12b, %r12b
	je	.Lhrdbfw_620
	leal	1(%rax), %edx
	cmpl	$1, %edx
	jbe	.Lhrdbfw_590
	movq	56(%rsp), %rcx
	leal	-1(%rax), %ebp
	xorl	%r9d, %r9d
	salq	$4, %rbp
	addq	64(%rsp), %rbp
	addq	$53, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_591:
	leaq	-11(%rcx), %rax
	movl	%r12d, %edx
	jmp	.Lhrdbfw_593
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_644:
	leaq	(%r9,%rax), %rdx
	movzbl	(%rdx,%r10), %edx
.Lhrdbfw_593:
	cmpb	%dl, (%rax)
	jne	.Lhrdbfw_643
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_644
	movl	$1, %eax
	jmp	.Lhrdbfw_581
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_643:
	addq	$16, %rcx
	subq	$16, %r9
	cmpq	%rbp, %rcx
	jne	.Lhrdbfw_591
.Lhrdbfw_590:
	movzbl	11(%rdi), %edx
	movzbl	16(%rdi), %eax
	movw	%r8w, 56(%r11)
	movzbl	17(%rdi), %ecx
	movb	%dl, 53(%r11)
	movb	%al, 54(%r11)
	movb	%cl, 55(%r11)
	testb	%al, %al
	je	.Lhrdbfw_620
	cmpb	$67, %dl
	je	.Lhrdbfw_645
	cmpb	$78, %dl
	je	.Lhrdbfw_646
	cmpb	$76, %dl
	je	.Lhrdbfw_647
	cmpb	$68, %dl
	jne	.Lhrdbfw_619
	movslq	%esi, %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	jne	.Lhrdbfw_620
.Lhrdbfw_595:
	addl	%eax, %r8d
	cmpl	$65535, %r8d
	ja	.Lhrdbfw_621
	addq	$32, %rbx
	addq	$1, %r15
	addq	$32, %rdi
	addq	$16, %r11
	addq	$16, %r10
	movl	$1, %eax
	cmpq	%rbx, 40(%rsp)
	ja	.Lhrdbfw_598
	jmp	.Lhrdbfw_620
.Lhrdbfw_645:
	testb	%cl, %cl
	je	.Lhrdbfw_595
.Lhrdbfw_619:
	movl	$3, %eax
	jmp	.Lhrdbfw_581
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_646:
	cmpb	$17, %cl
	ja	.Lhrdbfw_621
	cmpb	%cl, %al
	ja	.Lhrdbfw_595
.Lhrdbfw_621:
	movl	$4, %eax
	jmp	.Lhrdbfw_581
.Lhrdbfw_647:
	movslq	%esi, %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.Lhrdbfw_595
	jmp	.Lhrdbfw_620
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_641:
	movl	%r8d, %edi
	movq	%rbx, %rcx
	movq	2296(%rsp), %rsi
	movq	2288(%rsp), %rbx
	movq	2304(%rsp), %r8
	testb	%al, %al
	je	.Lhrdbfw_585
	movw	%r15w, 148(%rsp)
.Lhrdbfw_585:
	cmpw	$0, 148(%rsp)
	je	.Lhrdbfw_620
	cmpl	%edi, 76(%rsp)
	jne	.Lhrdbfw_620
	movq	%rcx, %rax
	addq	$1, %rax
	jmp	.Lhrdbfw_586
.Lhrdbfw_599:
	addq	$1, %rax
	cmpb	$0, -1(%rsi,%rax)
	jne	.Lhrdbfw_620
.Lhrdbfw_586:
	cmpq	%rax, 40(%rsp)
	ja	.Lhrdbfw_599
	movq	40(%rsp), %rdi
	movq	%r8, %rax
	xorl	%edx, %edx
	movl	%r13d, %ecx
	subq	%rdi, %rax
	divq	%r14
	cmpq	%rax, %rcx
	ja	.Lhrdbfw_620
	imulq	%rcx, %r14
	movq	%rdi, %rax
	addq	%r14, %rax
	cmpq	%rax, %r8
	je	.Lhrdbfw_600
	movq	%r8, %rdx
	subq	%rax, %rdx
	subq	$1, %rdx
	jne	.Lhrdbfw_620
	cmpb	$26, (%rsi,%rax)
	jne	.Lhrdbfw_620
.Lhrdbfw_600:
	testl	%r13d, %r13d
	movq	%rsi, 112(%rsp)
	movl	128(%rsp), %edx
	sete	%al
	movb	$1, 152(%rsp)
	xorl	%edi, %edi
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	movq	%r8, 120(%rsp)
	leaq	80(%rsp), %r8
.Lhrdbfw_601:
	movl	%edx, %eax
	cmpq	%rdi, %rax
	jbe	.Lhrdbfw_648
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %ecx
	imulq	%rdi, %rax
	addq	%rsi, %rax
	movzbl	(%rax,%rcx), %eax
	cmpb	$32, %al
	je	.Lhrdbfw_625
	cmpb	$42, %al
	jne	.Lhrdbfw_622
.Lhrdbfw_625:
	addq	$1, %rdi
	movl	$1, %ebp
	cmpw	$0, 148(%rsp)
	movq	%rdi, 136(%rsp)
	jne	.Lhrdbfw_603
	jmp	.Lhrdbfw_601
.Lhrdbfw_650:
	movq	56(%rsp), %rcx
	movl	%ebp, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_581
	movzwl	148(%rsp), %eax
	addl	$1, %ebp
	cmpl	%ebp, %eax
	jb	.Lhrdbfw_649
.Lhrdbfw_603:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.Lhrdbfw_650
	movl	$6, %eax
	jmp	.Lhrdbfw_581
.Lhrdbfw_649:
	movl	128(%rsp), %edx
	jmp	.Lhrdbfw_601
.Lhrdbfw_648:
	cmpb	$0, 152(%rsp)
	je	.Lhrdbfw_606
	movq	$1, 136(%rsp)
	testl	%edx, %edx
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.Lhrdbfw_606:
	movq	56(%rsp), %rsi
	movl	$262, %ecx
	movq	%rbx, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.Lhrdbfw_581
.Lhrdbfw_622:
	movl	$5, %eax
	jmp	.Lhrdbfw_581
	.p2align 4
	.globl	hrv_date
hrv_date:
	movl	%edx, %edx
	movq	$11, (%rcx)
	movq	%rcx, %rax
	movq	%rdx, 8(%rcx)
	ret
	.p2align 4
	.globl	hrv_number
hrv_number:
	movl	%r9d, %r9d
	movl	%r8d, %r8d
	movq	%rdx, 8(%rcx)
	movq	%rcx, %rax
	salq	$8, %r9
	salq	$16, %r8
	orq	%r8, %r9
	orq	$12, %r9
	movq	%r9, (%rcx)
	ret
	.p2align 4
	.globl	hrv_validate
hrv_validate:
	pushq	%rbp
	movq	(%rcx), %rax
	movl	$4, %r8d
	movq	8(%rcx), %rcx
	movzbl	%al, %edx
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %edx
	ja	.Lhrdbfw_653
	je	.Lhrdbfw_684
	cmpl	$5, %edx
	je	.Lhrdbfw_657
	shrq	$8, %rax
	jne	.Lhrdbfw_653
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_653
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_653
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_653
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_653
	movabs	$2951479051793528259, %r10
	movq	%rcx, %rax
	shrq	$2, %rax
	mulq	%r10
	movq	%rdx, %r8
	shrq	$4, %rdx
	movq	%rdx, %rax
	shrq	$2, %r8
	mulq	%r10
	movq	%rdx, %rax
	andq	$-4, %rdx
	shrq	$2, %rax
	addq	%rdx, %rax
	movq	%r8, %rdx
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rdx
	leaq	(%r8,%r8,4), %rax
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rcx
	leal	-1(%rdx), %eax
	cmpl	$11, %eax
	ja	.Lhrdbfw_671
	testq	%rcx, %rcx
	je	.Lhrdbfw_671
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_685
.Lhrdbfw_659:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_653:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_684:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_653
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_653
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_671
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_671
	cmpl	%edx, %eax
	jb	.Lhrdbfw_653
.Lhrdbfw_671:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_657:
	testq	%rax, %rax
	jns	.Lhrdbfw_666
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_653
.Lhrdbfw_666:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_685:
	testb	$3, %r9b
	jne	.Lhrdbfw_659
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_660
	addl	$1, %eax
	jmp	.Lhrdbfw_659
.Lhrdbfw_660:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_659
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_686
	leaq	hrdbfw_local_CSWTCH.179(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_686:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4
	.globl	hrv_i64
hrv_i64:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	andq	$-16, %rsp
	subq	$48, %rsp
	movq	(%rcx), %r11
	movq	8(%rcx), %rsi
	leaq	32(%rsp), %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_691
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_702
	testl	%edx, %edx
	je	.Lhrdbfw_694
	cmpl	$9, %edx
	je	.Lhrdbfw_694
	movl	$1, %eax
.Lhrdbfw_691:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_702:
	testl	$65280, %r11d
	jne	.Lhrdbfw_703
.Lhrdbfw_694:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_703:
	movl	$2, %eax
	jmp	.Lhrdbfw_691
	.p2align 4
	.globl	hrv_equal
hrv_equal:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	movq	%r8, %r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$48, %rsp
	movq	(%rcx), %rbx
	movq	8(%rcx), %rsi
	leaq	32(%rsp), %r11
	movq	(%rdx), %rdi
	movq	8(%rdx), %r12
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_704
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_704
	movzbl	%bl, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %bl
	jne	.Lhrdbfw_706
	cmpl	$11, %r14d
	jne	.Lhrdbfw_706
.Lhrdbfw_719:
	xorl	%edx, %edx
	cmpq	%r12, %rsi
	sete	%dl
	movl	%edx, 0(%r13)
.Lhrdbfw_704:
	leaq	-56(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_706:
	cmpl	$1, %r15d
	je	.Lhrdbfw_722
	cmpl	$1, %r14d
	je	.Lhrdbfw_722
	cmpl	$3, %r15d
	jne	.Lhrdbfw_709
	cmpl	$3, %r14d
	jne	.Lhrdbfw_709
	testq	%rsi, %rsi
	sete	%dl
	testq	%r12, %r12
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_704
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_722:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_704
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_709:
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_704
	cmpl	$12, %r15d
	je	.Lhrdbfw_745
	testl	%r15d, %r15d
	je	.Lhrdbfw_712
	movl	$1, %eax
	cmpl	$9, %r15d
	jne	.Lhrdbfw_704
.Lhrdbfw_712:
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_704
	cmpl	$12, %r14d
	je	.Lhrdbfw_746
	testl	%r14d, %r14d
	je	.Lhrdbfw_719
	cmpl	$9, %r14d
	je	.Lhrdbfw_719
	movl	$1, %eax
	jmp	.Lhrdbfw_704
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_745:
	andb	$-1, %bh
	je	.Lhrdbfw_712
.Lhrdbfw_718:
	movl	$2, %eax
	jmp	.Lhrdbfw_704
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_746:
	testl	$65280, %edi
	je	.Lhrdbfw_719
	jmp	.Lhrdbfw_718
	.p2align 4
	.globl	hrv_empty
hrv_empty:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rsi
	movq	%rdx, %rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$48, %rsp
	movq	(%rcx), %r11
	movq	8(%rcx), %rbx
	leaq	32(%rsp), %rcx
	movq	%r11, 32(%rsp)
	movq	%rbx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_747
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_752
	leaq	.Lhrdbfw_750(%rip), %rcx
	movslq	(%rcx,%rdx,4), %rdx
	addq	%rcx, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_750:
	.long	.Lhrdbfw_749-.Lhrdbfw_750
	.long	.Lhrdbfw_751-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_749-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_749-.Lhrdbfw_750
	.long	.Lhrdbfw_752-.Lhrdbfw_750
	.long	.Lhrdbfw_749-.Lhrdbfw_750
	.long	.Lhrdbfw_749-.Lhrdbfw_750
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_752:
	movl	$1, %eax
.Lhrdbfw_747:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_749:
	xorl	%edx, %edx
	testq	%rbx, %rbx
	sete	%dl
	movl	%edx, (%rsi)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_751:
	movl	$1, (%rsi)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4
	.globl	hrv_render
hrv_render:
	pushq	%rbp
	movq	%rdx, %r11
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	movq	%r9, %rdi
	pushq	%rsi
	movq	%r8, %rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$96, %rsp
	movq	(%rcx), %rbx
	movq	8(%rcx), %r13
	leaq	48(%rsp), %rcx
	movq	%rbx, 48(%rsp)
	movq	%r13, 56(%rsp)
	call	hrv_validate
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_754
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_801
	cmpl	$12, %eax
	jne	.Lhrdbfw_780
	movl	%ebx, %eax
	negq	%rcx
	movzbl	%bh, %ebx
	movl	$1, %r10d
	shrl	$16, %eax
	testq	%r13, %r13
	leaq	63(%rsp), %r14
	movabs	$-3689348814741910323, %r9
	movl	%eax, 44(%rsp)
	cmovns	%r13, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_762:
	movq	%rcx, %rax
	movl	%r10d, %r8d
	mulq	%r9
	movq	%rcx, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r15
	addq	%r15, %r15
	subq	%r15, %rax
	addl	$48, %eax
	movb	%al, (%r14,%r10)
	movq	%rcx, %rax
	addq	$1, %r10
	movq	%rdx, %rcx
	cmpq	$9, %rax
	ja	.Lhrdbfw_762
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_802
	movl	$1, %r9d
.Lhrdbfw_763:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_764:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_765
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_803
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_773
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_772:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_772
.Lhrdbfw_773:
	testq	%r13, %r13
	jns	.Lhrdbfw_771
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_771:
	testl	%r9d, %r9d
	je	.Lhrdbfw_774
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_776
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_784:
	movl	%edx, %eax
.Lhrdbfw_776:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_775
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_775:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_784
	addl	%r9d, %r10d
.Lhrdbfw_774:
	testl	%ebx, %ebx
	je	.Lhrdbfw_754
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_778:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_777
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_777:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_778
.Lhrdbfw_754:
	leaq	-56(%rbp), %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_801:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_765
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_760
	movq	%r13, %rax
	movb	$47, 2(%r11)
	movabs	$3777893186295716171, %rdx
	movabs	$2951479051793528259, %r9
	mulq	%rdx
	movq	%r13, %rax
	movb	$47, 5(%r11)
	shrq	$2, %rax
	movq	%rdx, %rcx
	mulq	%r9
	shrq	$11, %rcx
	movq	%rdx, %r8
	shrq	$4, %rdx
	movq	%rdx, %rax
	shrq	$2, %r8
	mulq	%r9
	movq	%rdx, %rax
	andq	$-4, %rdx
	shrq	$2, %rax
	addq	%rdx, %rax
	movq	%r8, %rdx
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %rdx
	leaq	(%r8,%r8,4), %rax
	movl	$3435973837, %r8d
	leaq	(%rax,%rax,4), %rax
	salq	$2, %rax
	subq	%rax, %r13
	movl	%edx, %eax
	imulq	%r8, %rax
	shrq	$35, %rax
	leal	48(%rax), %r9d
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movb	%r9b, (%r11)
	subl	%eax, %edx
	movl	%r13d, %eax
	imulq	%r8, %rax
	addl	$48, %edx
	movb	%dl, 1(%r11)
	shrq	$35, %rax
	leal	48(%rax), %edx
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movb	%dl, 3(%r11)
	subl	%eax, %r13d
	movl	%ecx, %eax
	imulq	%r8, %rax
	addl	$48, %r13d
	movb	%r13b, 4(%r11)
	shrq	$35, %rax
	movl	%eax, %edx
	imulq	%r8, %rdx
	shrq	$35, %rdx
	leal	(%rdx,%rdx,4), %r8d
	movl	%eax, %edx
	leal	(%rax,%rax,4), %eax
	addl	%r8d, %r8d
	addl	%eax, %eax
	subl	%r8d, %edx
	addl	$48, %edx
	subl	%eax, %ecx
	addl	$48, %ecx
	movb	%dl, 6(%r11)
	movb	%cl, 7(%r11)
	jmp	.Lhrdbfw_754
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_780:
	movl	$1, %r12d
	jmp	.Lhrdbfw_754
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_804:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_779
.Lhrdbfw_759:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_754
.Lhrdbfw_760:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_804
.Lhrdbfw_779:
	movl	$47, %eax
	jmp	.Lhrdbfw_759
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_802:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_763
	movl	%r9d, %eax
	jmp	.Lhrdbfw_764
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_765:
	movl	$3, %r12d
	jmp	.Lhrdbfw_754
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_803:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_754
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_768:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_768
	jmp	.Lhrdbfw_754
	.section .rdata,"dr"
.Lhrdbfw_C9:

.byte 68,66,70,32,117,110,107,110,111,119,110,32,118,97,108,117,101,32,101,114,114,111,114,0
.Lhrdbfw_C10:

.byte 111,107,0
	.align 8
.Lhrdbfw_C11:

.byte 68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,0
	.align 8
.Lhrdbfw_C12:

.byte 68,66,70,32,118,97,108,117,101,32,111,117,116,112,117,116,32,98,117,102,102,101,114,32,116,111,111,32,115,104,111,114,116,0
	.align 8
.Lhrdbfw_C13:

.byte 68,66,70,32,118,97,108,117,101,32,116,97,103,32,111,114,32,109,101,116,97,100,97,116,97,32,105,110,118,97,108,105,100,0
	.align 8
.Lhrdbfw_C14:

.byte 68,66,70,32,118,97,108,117,101,32,116,121,112,101,32,111,117,116,115,105,100,101,32,97,100,109,105,116,116,101,100,32,111,112,101,114,97,116,105,111,110,0
	.text
	.p2align 4
	.globl	hrv_error_name
hrv_error_name:
	cmpl	$4, %ecx
	ja	.Lhrdbfw_806
	leaq	.Lhrdbfw_808(%rip), %rdx
	movl	%ecx, %ecx
	movslq	(%rdx,%rcx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_808:
	.long	.Lhrdbfw_813-.Lhrdbfw_808
	.long	.Lhrdbfw_811-.Lhrdbfw_808
	.long	.Lhrdbfw_810-.Lhrdbfw_808
	.long	.Lhrdbfw_809-.Lhrdbfw_808
	.long	.Lhrdbfw_807-.Lhrdbfw_808
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_811:
	leaq	.Lhrdbfw_C14(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_813:
	leaq	.Lhrdbfw_C10(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_807:
	leaq	.Lhrdbfw_C13(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_810:
	leaq	.Lhrdbfw_C11(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_809:
	leaq	.Lhrdbfw_C12(%rip), %rax
	ret
.Lhrdbfw_806:
	leaq	.Lhrdbfw_C9(%rip), %rax
	ret
	.p2align 4
	.globl	hrdbf_file_close
hrdbf_file_close:
	pushq	%r12
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$40, %rsp
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	2112(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_817
	movq	$0, 2112(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_824
.Lhrdbfw_817:
	xorl	%r12d, %r12d
.Lhrdbfw_816:
	movq	2096(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_814
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_819
	movq	$0, 2096(%rbx)
	movq	$0, 2104(%rbx)
.Lhrdbfw_814:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_824:
	movl	$7, %r12d
	jmp	.Lhrdbfw_816
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_819:
	movl	$7, %r12d
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
hrdbf_app_fail:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.Lhrdbfw_826
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_827:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_827
.Lhrdbfw_826:
	movl	$-12, %ecx
	call GetStdHandle
	leaq	60(%rsp), %r9
	movl	%ebx, %r8d
	movq	%r12, %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call WriteFile
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_close
	movl	$1, %ecx
	call ExitProcess
	.p2align 4
	.globl	hrdbf_file_open
hrdbf_file_open:
	pushq	%r13
	movq	%rdx, %r13
	pushq	%r12
	movq	%rcx, %r12
	subq	$56, %rsp
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	2112(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_859
	movq	$0, 2112(%r12)
	call CloseHandle
	movq	2096(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_835
	testq	%rcx, %rcx
	je	.Lhrdbfw_857
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_857
	movq	$0, 2096(%r12)
	movq	$0, 2104(%r12)
	jmp	.Lhrdbfw_857
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_835:
	testq	%rcx, %rcx
	je	.Lhrdbfw_834
.Lhrdbfw_833:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_860
.Lhrdbfw_857:
	movl	$7, %r13d
	addq	$56, %rsp
	movl	%r13d, %eax
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_859:
	movq	2096(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_833
.Lhrdbfw_834:
	movl	$0, 40(%rsp)
	movq	%r13, %rcx
	leaq	2096(%r12), %rdx
	leaq	2112(%r12), %r9
	movq	$33, 32(%rsp)
	leaq	2104(%r12), %r8
	call	hrdbfw_snapshot
	movl	%eax, %r13d
	testl	%eax, %eax
	je	.Lhrdbfw_861
.Lhrdbfw_839:
	movq	%r12, %rcx
	call	hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r13d
	addq	$56, %rsp
	popq	%r12
	movl	%r13d, %eax
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_861:
	movq	2096(%r12), %rdx
	movq	2104(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_839
	addq	$56, %rsp
	movl	%r13d, %eax
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_860:
	movq	$0, 2096(%r12)
	movq	$0, 2104(%r12)
	jmp	.Lhrdbfw_834
	.p2align 4
	.globl	hrntx_close
hrntx_close:
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	ret
	.p2align 4
	.globl	hrntx_seek
hrntx_seek:
	pushq	%r14
	pushq	%r12
	pushq	%rbp
	movl	%r9d, %ebp
	pushq	%rdi
	pushq	%rsi
	movq	%rcx, %rsi
	movq	%rdx, %rcx
	pushq	%rbx
	movzwl	28(%rsi), %edx
	movq	96(%rsp), %r12
	movl	24(%rsi), %r9d
	cmpq	%r8, %rdx
	movl	$0, (%r12)
	cmova	%r8, %rdx
	testl	%r9d, %r9d
	je	.Lhrdbfw_864
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_869:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_882
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_868
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_866:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_882
.Lhrdbfw_868:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_866
	jnb	.Lhrdbfw_882
	leal	1(%r10), %r11d
.Lhrdbfw_865:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_869
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_873
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_872:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_874
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_875
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_907:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_874
.Lhrdbfw_875:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_907
.Lhrdbfw_873:
	testl	%ebp, %ebp
	je	.Lhrdbfw_863
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_908
	movl	%r11d, %r9d
.Lhrdbfw_863:
	popq	%rbx
	movl	%r9d, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_882:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_865
.Lhrdbfw_874:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_863
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_876
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_881:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_877
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_880
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_878:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_877
.Lhrdbfw_880:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_878
	jb	.Lhrdbfw_877
	movl	%r9d, %r10d
.Lhrdbfw_879:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_881
.Lhrdbfw_876:
	leal	-1(%r11), %r9d
	popq	%rbx
	popq	%rsi
	movl	%r9d, %eax
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_877:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_879
.Lhrdbfw_908:
	leal	-1(%r11), %eax
	testl	%r11d, %r11d
	popq	%rbx
	popq	%rsi
	cmovne	%eax, %r9d
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r14
	movl	%r9d, %eax
	ret
.Lhrdbfw_864:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_863
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_872
	.section .rdata,"dr"
.Lhrdbfw_C15:

.byte 104,98,99,58,32,68,66,70,47,78,84,88,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_close
hrdbfw_app_close:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	movq	hrdbf_app_state+2112(%rip), %rcx
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	%eax, %ebx
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_914
	movq	$0, hrdbf_app_state+2112(%rip)
	call CloseHandle
	testl	%eax, %eax
	jne	.Lhrdbfw_914
	movq	hrdbf_app_state+2096(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_915
	movl	$7, %esi
	jmp	.Lhrdbfw_911
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_914:
	movq	hrdbf_app_state+2096(%rip), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_924
.Lhrdbfw_912:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.Lhrdbfw_917
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_924:
	xorl	%esi, %esi
.Lhrdbfw_911:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_915
	movq	$0, hrdbf_app_state+2096(%rip)
	orl	%esi, %ebx
	movq	$0, hrdbf_app_state+2104(%rip)
	jmp	.Lhrdbfw_912
.Lhrdbfw_915:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbfw_917:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C16:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C17:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C18:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C19:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C20:

.byte 104,98,99,58,32,68,66,70,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,102,111,114,109,97,116,44,32,100,97,116,97,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_open
hrdbfw_app_open:
	pushq	%r12
	pushq	%rbp
	movq	%r9, %rbp
	pushq	%rdi
	movq	%rcx, %rdi
	pushq	%rsi
	pushq	%rbx
	subq	$304, %rsp
	testq	%r8, %r8
	je	.Lhrdbfw_926
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_957
.Lhrdbfw_926:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_958
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_927
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_942:
	movq	%rsi, %rbx
.Lhrdbfw_927:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_959
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_942
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_960
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movq	$0, hrdbf_app_pos(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_932
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_930:
	cmpq	%rcx, %rbx
	je	.Lhrdbfw_961
.Lhrdbfw_932:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.Lhrdbfw_945
	cmpb	$92, %dl
	jne	.Lhrdbfw_930
.Lhrdbfw_945:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.Lhrdbfw_932
.Lhrdbfw_961:
	cmpq	%rsi, %r8
	jnb	.Lhrdbfw_933
	movq	%r8, %rax
	jmp	.Lhrdbfw_935
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_943:
	movq	%rdx, %rax
.Lhrdbfw_935:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_943
.Lhrdbfw_933:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.Lhrdbfw_940
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_936:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrdbfw_936
.Lhrdbfw_940:
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open
	testl	%eax, %eax
	jne	.Lhrdbfw_962
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.Lhrdbfw_959:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_958:
	leaq	.Lhrdbfw_C17(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_957:
	leaq	.Lhrdbfw_C16(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_962:
	leaq	.Lhrdbfw_C20(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_960:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C21:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_972
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_973
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbfw_974
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_968:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_974:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbfw_968
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_973:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_972:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_985
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_986
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_987
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_980:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_981:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_987:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_980
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_981
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_986:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_985:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1005
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1006
	testq	%rcx, %rcx
	je	.Lhrdbfw_988
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbfw_992
	movq	%rax, %r8
	subq	%rdx, %r8
	cmpq	%rcx, %r8
	jb	.Lhrdbfw_998
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	setnb	%dl
.Lhrdbfw_993:
	movq	%rcx, hrdbf_app_pos(%rip)
.Lhrdbfw_994:
	cmpq	%rax, %rcx
	jnb	.Lhrdbfw_996
.Lhrdbfw_1007:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
.Lhrdbfw_997:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbfw_988:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_992:
	movq	%rcx, %r8
	negq	%r8
	cmpq	%rdx, %r8
	jbe	.Lhrdbfw_995
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_1007
.Lhrdbfw_996:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_997
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_998:
	movq	%rax, %rcx
	movl	$1, %edx
	jmp	.Lhrdbfw_993
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_995:
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	movq	%rcx, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbfw_994
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1006:
	movq	%rcx, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
.Lhrdbfw_1005:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C22:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C23:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C24:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C25:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C26:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C27:

.byte 104,98,99,58,32,67,68,88,32,109,117,115,116,32,117,115,101,32,97,32,100,105,102,102,101,114,101,110,116,32,98,97,115,101,110,97,109,101,32,102,114,111,109,32,68,66,70,59,32,115,116,114,117,99,116,117,114,97,108,47,97,117,116,111,111,112,101,110,32,105,110,100,101,120,101,115,32,97,114,101,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_order_add
hrdbfw_app_order_add:
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$336, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1082
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1083
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_1084
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.Lhrdbfw_1011
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1013:
	cmpq	%rcx, %r9
	je	.Lhrdbfw_1085
.Lhrdbfw_1049:
	movq	%rcx, %rdx
.Lhrdbfw_1011:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1086
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.Lhrdbfw_1053
	cmpb	$92, %al
	jne	.Lhrdbfw_1013
.Lhrdbfw_1053:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.Lhrdbfw_1049
.Lhrdbfw_1085:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.Lhrdbfw_1015
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.Lhrdbfw_1017
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1050:
	movq	%r11, %rax
.Lhrdbfw_1017:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1050
	testl	%ebx, %ebx
	je	.Lhrdbfw_1021
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.Lhrdbfw_1047
.Lhrdbfw_1022:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1045
.Lhrdbfw_1046:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1027
	testl	%ebx, %ebx
	je	.Lhrdbfw_1029
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$512, 40(%rsp)
	movq	%r12, %rcx
	movq	$2048, 32(%rsp)
	leaq	-16(%r9), %r8
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.Lhrdbfw_1041
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.Lhrdbfw_1040:
	cmpq	$67108864, %rbp
	ja	.Lhrdbfw_1081
	xorl	%edx, %edx
	leaq	7(%rcx), %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	divq	%r8
	shrq	$3, %rdi
	movl	$12288, %r8d
	leaq	(%rdi,%rbp), %rdx
	leaq	7(%rax), %rbx
	shrq	$3, %rbx
	addq	%rbx, %rdx
	movq	%rdx, hrdbf_app_order+56(%rip)
	call VirtualAlloc
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbfw_1081
	testl	%esi, %esi
	leaq	hrntx_open(%rip), %rdx
	leaq	hrcdx_open(%rip), %r10
	movq	%rax, 32(%rsp)
	cmove	%rdx, %r10
	addq	%rdi, %rbx
	addq	%rax, %rbp
	movq	hrdbf_app_order+48(%rip), %r8
	movq	%rbx, 56(%rsp)
	movl	hrdbf_app_state+16(%rip), %ebx
	leaq	hrdbf_app_state(%rip), %r9
	leaq	hrdbf_app_order(%rip), %rcx
	movq	%rbp, 48(%rsp)
	movq	hrdbf_app_order+32(%rip), %rdx
	movq	%rbx, 40(%rsp)
	call	*%r10
	testl	%eax, %eax
	je	.Lhrdbfw_1034
	cmpl	$5, %eax
	je	.Lhrdbfw_1035
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1081:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1027
.Lhrdbfw_1036:
	leaq	.Lhrdbfw_C23(%rip), %rcx
	jmp	.Lhrdbfw_1037
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1021:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1020
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1027
.Lhrdbfw_1029:
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$1024, 40(%rsp)
	movq	%r12, %rcx
	movq	$2048, 32(%rsp)
	leaq	-16(%r9), %r8
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.Lhrdbfw_1041
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.Lhrdbfw_1040
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1020:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.Lhrdbfw_1044:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.Lhrdbfw_1046
.Lhrdbfw_1015:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1020
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.Lhrdbfw_1087
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1045:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.Lhrdbfw_1044
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1041:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.Lhrdbfw_1027:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_1036
	cmpl	$3, %eax
	je	.Lhrdbfw_1038
	jmp	.Lhrdbfw_1036
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1034:
	call	hrdbfw_app_top
	addq	$336, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
.Lhrdbfw_1087:
	xorl	%r10d, %r10d
.Lhrdbfw_1047:
	testq	%rdi, %rdi
	je	.Lhrdbfw_1023
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1026:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.Lhrdbfw_1026
	testl	%r11d, %r11d
	je	.Lhrdbfw_1022
.Lhrdbfw_1023:
	leaq	.Lhrdbfw_C27(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1035:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1027
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1036
.Lhrdbfw_1038:
	leaq	.Lhrdbfw_C22(%rip), %rcx
.Lhrdbfw_1037:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1086:
	leaq	.Lhrdbfw_C26(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1083:
	leaq	.Lhrdbfw_C24(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1082:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1084:
	leaq	.Lhrdbfw_C25(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1114
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_1115
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	movq	hrdbf_app_order+32(%rip), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1094
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1116
.Lhrdbfw_1091:
	xorl	%edx, %edx
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1095
	movq	hrdbf_app_order+40(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1096
.Lhrdbfw_1092:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_1096
.Lhrdbfw_1117:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_1097:
	testl	%esi, %esi
	jne	.Lhrdbfw_1096
.Lhrdbfw_1093:
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1094:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1091
.Lhrdbfw_1112:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1093
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1117
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1096:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1115:
	movq	hrdbf_app_order+32(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1091
	jmp	.Lhrdbfw_1112
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1095:
	movq	hrdbf_app_order+40(%rip), %rcx
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1092
	jmp	.Lhrdbfw_1097
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1116:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1092
	jmp	.Lhrdbfw_1096
.Lhrdbfw_1114:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1123
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_1123:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C28:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1130
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_1131
	movq	%r9, %rax
	xorl	%r9d, %r9d
	testq	%r8, %r8
	setne	%r9b
	testq	%rax, %rax
	leaq	60(%rsp), %r8
	setne	%al
	movq	%r8, 40(%rsp)
	movq	%rdx, %r8
	movq	%rcx, %rdx
	movzbl	%al, %eax
	leaq	hrdbf_app_order(%rip), %rcx
	movl	%eax, 32(%rsp)
	call	hrntx_seek
	movl	60(%rsp), %edx
	movl	hrdbf_app_order+24(%rip), %r8d
	movl	%eax, %eax
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%r8, %rcx
	movl	%edx, hrdbf_app_found_flag(%rip)
	cmpq	%r8, %rax
	jb	.Lhrdbfw_1132
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_1128:
	cmpq	%r8, %rax
	movq	%r9, hrdbf_app_state+24(%rip)
	movslq	%edx, %rax
	setnb	hrdbf_app_state+39(%rip)
	orl	hrdbf_app_cdx(%rip), %ecx
	sete	hrdbf_app_state+38(%rip)
	addq	$72, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1132:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_1128
.Lhrdbfw_1131:
	leaq	.Lhrdbfw_C28(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1130:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1138
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_1138:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1144
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_1144:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1150
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_1150:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1156
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_1156:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1164
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1157
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_1157:
	movq	%r8, %rax
	ret
.Lhrdbfw_1164:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C29:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C30:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,115,116,114,105,110,103,32,97,108,108,111,99,97,116,105,111,110,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	pushq	%rbx
	subq	$328, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1184
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_1167
	movzwl	hrdbf_app_state+36(%rip), %ecx
	movq	%rcx, %rax
	cmpq	%rdx, %rcx
	jge	.Lhrdbfw_1168
.Lhrdbfw_1167:
	movq	$1, (%r12)
	movq	$0, 8(%r12)
.Lhrdbfw_1165:
	addq	$328, %rsp
	movq	%r12, %rax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1168:
	movl	$85, %ecx
	movb	$0, 60(%rsp)
	movw	%cx, 32(%rsp)
	movb	$0, 34(%rsp)
	movq	$0, 40(%rsp)
	movq	$0, 48(%rsp)
	movl	$0, 56(%rsp)
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1180
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1185
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	jne	.Lhrdbfw_1172
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1186
.Lhrdbfw_1173:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1187
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1172:
	cmpb	$78, %al
	je	.Lhrdbfw_1188
	cmpb	$68, %al
	jne	.Lhrdbfw_1189
	movl	56(%rsp), %eax
	movq	$11, (%r12)
	movq	%rax, 8(%r12)
	jmp	.Lhrdbfw_1165
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1180:
	xorl	%eax, %eax
.Lhrdbfw_1170:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1189:
	movzbl	60(%rsp), %eax
	jmp	.Lhrdbfw_1170
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1188:
	movzbl	34(%rsp), %eax
	movzbl	33(%rsp), %edx
	salq	$8, %rax
	salq	$16, %rdx
	orq	%rdx, %rax
	orq	$12, %rax
	movq	%rax, (%r12)
	movq	48(%rsp), %rax
	movq	%rax, 8(%r12)
	jmp	.Lhrdbfw_1165
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1186:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1176
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1175:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1175
.Lhrdbfw_1176:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1173
.Lhrdbfw_1184:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1185:
	leaq	.Lhrdbfw_C29(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1187:
	leaq	.Lhrdbfw_C30(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C31:

.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,114,101,110,100,101,114,32,114,101,106,101,99,116,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_render
hrdbfw_app_render:
	pushq	%rbp
	movq	%rdx, %r9
	movq	%r8, %rdx
	movl	$256, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	subq	$64, %rsp
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%r9, 40(%rsp)
	leaq	56(%rsp), %r9
	movq	$0, 56(%rsp)
	call	hrv_render
	testl	%eax, %eax
	jne	.Lhrdbfw_1193
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_1193:
	leaq	.Lhrdbfw_C31(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C32:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C33:

.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_integer
hrdbfw_app_integer:
	pushq	%rbp
	movq	%rcx, %r11
	movq	%rsp, %rbp
	pushq	%r12
	movq	%rdx, %r12
	andq	$-16, %rsp
	subq	$48, %rsp
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1195
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1211
	testl	%eax, %eax
	je	.Lhrdbfw_1203
	cmpl	$9, %eax
	jne	.Lhrdbfw_1199
.Lhrdbfw_1203:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1211:
	testl	$65280, %r11d
	je	.Lhrdbfw_1203
.Lhrdbfw_1198:
	leaq	.Lhrdbfw_C32(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1195:
	cmpl	$2, %eax
	je	.Lhrdbfw_1198
.Lhrdbfw_1199:
	leaq	.Lhrdbfw_C33(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C34:

.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,99,111,109,112,97,114,105,115,111,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_equal
hrdbfw_app_equal:
	pushq	%rbp
	movq	%rsp, %rbp
	andq	$-16, %rsp
	subq	$80, %rsp
	movq	%rcx, 48(%rsp)
	leaq	48(%rsp), %rcx
	movq	%rdx, 56(%rsp)
	leaq	32(%rsp), %rdx
	movq	%r8, 32(%rsp)
	leaq	76(%rsp), %r8
	movq	%r9, 40(%rsp)
	call	hrv_equal
	cmpl	$2, %eax
	je	.Lhrdbfw_1216
	testl	%eax, %eax
	jne	.Lhrdbfw_1217
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_1216:
	leaq	.Lhrdbfw_C32(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1217:
	leaq	.Lhrdbfw_C34(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C35:

.byte 104,98,99,58,32,68,66,70,32,105,110,118,97,108,105,100,32,68,97,116,101,32,99,111,109,112,97,114,105,115,111,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_compare
hrdbfw_app_compare:
	pushq	%rbp
	movq	%rcx, %r11
	movq	%rsp, %rbp
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	movq	%r9, %rdi
	pushq	%rsi
	movq	%rdx, %rsi
	pushq	%rbx
	movq	%r8, %rbx
	andq	$-16, %rsp
	subq	$48, %rsp
	cmpb	$11, %cl
	jne	.Lhrdbfw_1219
	movq	%rcx, 32(%rsp)
	movq	%rdx, 40(%rsp)
	cmpb	$11, %r8b
	je	.Lhrdbfw_1261
	leaq	32(%rsp), %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1225
.Lhrdbfw_1229:
	leaq	.Lhrdbfw_C33(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1225:
	cmpl	$2, %eax
	jne	.Lhrdbfw_1229
.Lhrdbfw_1228:
	leaq	.Lhrdbfw_C32(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1219:
	leaq	32(%rsp), %r12
	movq	%rcx, 32(%rsp)
	movzbl	%cl, %r13d
	movq	%r12, %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1225
	cmpl	$12, %r13d
	jne	.Lhrdbfw_1226
	testl	$65280, %r11d
	jne	.Lhrdbfw_1228
.Lhrdbfw_1227:
	movq	%r12, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1225
	movzbl	%bl, %eax
	cmpb	$12, %bl
	je	.Lhrdbfw_1262
	testl	%eax, %eax
	je	.Lhrdbfw_1235
	cmpl	$9, %eax
	jne	.Lhrdbfw_1229
.Lhrdbfw_1235:
	cmpq	%rdi, %rsi
	jl	.Lhrdbfw_1237
	setg	%al
	movzbl	%al, %eax
.Lhrdbfw_1218:
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1226:
	testl	%r13d, %r13d
	je	.Lhrdbfw_1227
	cmpl	$9, %r13d
	je	.Lhrdbfw_1227
	jmp	.Lhrdbfw_1229
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1237:
	leaq	-40(%rbp), %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1261:
	leaq	32(%rsp), %r11
	movq	%r11, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1222
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1222
	cmpq	%rdi, %rsi
	jb	.Lhrdbfw_1237
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbfw_1218
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1262:
	andb	$-1, %bh
	je	.Lhrdbfw_1235
	jmp	.Lhrdbfw_1228
.Lhrdbfw_1222:
	leaq	.Lhrdbfw_C35(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C37:

.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,69,109,112,116,121,32,114,101,106,101,99,116,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_empty
hrdbfw_app_empty:
	pushq	%rbp
	movq	%rdx, %r11
	movq	%rsp, %rbp
	pushq	%rbx
	movzbl	%cl, %ebx
	leal	-2(%rbx), %eax
	andq	$-16, %rsp
	subq	$48, %rsp
	andl	$-3, %eax
	jne	.Lhrdbfw_1264
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_1276
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_1266
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1284:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_1280
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_1276
.Lhrdbfw_1266:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_1284
.Lhrdbfw_1280:
	xorl	%eax, %eax
.Lhrdbfw_1263:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1264:
	cmpl	$8, %ebx
	je	.Lhrdbfw_1285
	cmpl	$5, %ebx
	je	.Lhrdbfw_1286
	cmpl	$7, %ebx
	je	.Lhrdbfw_1280
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1271
	cmpl	$12, %ebx
	ja	.Lhrdbfw_1271
	leaq	.Lhrdbfw_1273(%rip), %rdx
	movslq	(%rdx,%rbx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1273:
	.long	.Lhrdbfw_1272-.Lhrdbfw_1273
	.long	.Lhrdbfw_1276-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1272-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1272-.Lhrdbfw_1273
	.long	.Lhrdbfw_1271-.Lhrdbfw_1273
	.long	.Lhrdbfw_1272-.Lhrdbfw_1273
	.long	.Lhrdbfw_1272-.Lhrdbfw_1273
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1276:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1285:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1263
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_1263
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1271:
	leaq	.Lhrdbfw_C37(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1286:
	testq	%rcx, %rcx
	js	.Lhrdbfw_1287
.Lhrdbfw_1270:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C36(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_1263
.Lhrdbfw_1272:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_1263
.Lhrdbfw_1287:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_1270
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C38:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C38(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.179:
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
hrdbfw_local_days.0:
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
hrdbfw_local_days.1:

.byte 31,28,31,30,31,30,31,31,30,31,30,31
.bss
.balign 8
hrdbf_app_baselen:
.zero 8
.text

.bss
.balign 32
hrdbf_app_basename:
.zero 260
.text

.bss
.balign 4
hrdbf_app_cdx:
.zero 4
.text

.bss
.balign 4
hrdbf_app_found_flag:
.zero 4
.text

.bss
.balign 8
hrdbf_app_pos:
.zero 8
.text

.bss
.balign 32
hrdbf_app_order:
.zero 72
.text

.bss
.balign 32
hrdbf_app_state:
.zero 2120
.text
	.align 8
.Lhrdbfw_C36:
	.long	0
	.long	0

.text

hrdbf_app_close:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_close
    leave
    ret

hrdbf_app_open:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rcx, %r9
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_open
    leave
    ret

hrdbf_app_top:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_top
    leave
    ret

hrdbf_app_bottom:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_bottom
    leave
    ret

hrdbf_app_skip:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdi, %rcx
    call hrdbfw_app_skip
    leave
    ret

hrdbf_app_order_add:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_order_add
    leave
    ret

hrdbf_app_order_clear:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_order_clear
    leave
    ret

hrdbf_app_found:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_found
    leave
    ret

hrdbf_app_seek:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rcx, %r9
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_seek
    leave
    ret

hrdbf_app_recno:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_recno
    leave
    ret

hrdbf_app_lastrec:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_lastrec
    leave
    ret

hrdbf_app_bof:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_bof
    leave
    ret

hrdbf_app_eof:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_eof
    leave
    ret

hrdbf_app_deleted:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_deleted
    leave
    ret

hrdbf_app_render:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_render
    leave
    ret

hrdbf_app_integer:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_integer
    leave
    ret

hrdbf_app_equal:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rcx, %r9
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_equal
    leave
    ret

hrdbf_app_compare:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rcx, %r9
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_compare
    leave
    ret

hrdbf_app_empty:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_empty
    leave
    ret

hrdbf_app_unsupported:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_unsupported
    leave
    ret

hrdbf_app_get:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rsi, 48(%rsp)
    mov %rdi, %rdx
    lea 32(%rsp), %rcx
    lea hrdbfw_copy_callback(%rip), %r8
    call hrdbfw_app_get
    mov 32(%rsp), %rax
    mov 40(%rsp), %rdx
    leave
    ret
hrdbfw_copy_callback:
    push %rbp
    mov %rsp, %rbp
    push %rdi
    push %rsi
    sub $192, %rsp
    movdqu %xmm6, 32(%rsp)
    movdqu %xmm7, 48(%rsp)
    movdqu %xmm8, 64(%rsp)
    movdqu %xmm9, 80(%rsp)
    movdqu %xmm10, 96(%rsp)
    movdqu %xmm11, 112(%rsp)
    movdqu %xmm12, 128(%rsp)
    movdqu %xmm13, 144(%rsp)
    movdqu %xmm14, 160(%rsp)
    movdqu %xmm15, 176(%rsp)
    mov %rcx, %rdi
    mov %rdx, %rsi
    call hbc_strcpy
    movdqu 32(%rsp), %xmm6
    movdqu 48(%rsp), %xmm7
    movdqu 64(%rsp), %xmm8
    movdqu 80(%rsp), %xmm9
    movdqu 96(%rsp), %xmm10
    movdqu 112(%rsp), %xmm11
    movdqu 128(%rsp), %xmm12
    movdqu 144(%rsp), %xmm13
    movdqu 160(%rsp), %xmm14
    movdqu 176(%rsp), %xmm15
    add $192, %rsp
    pop %rsi
    pop %rdi
    pop %rbp
    ret
