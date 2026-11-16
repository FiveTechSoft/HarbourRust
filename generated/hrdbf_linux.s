	.text
	.p2align 4
	.type	hrdbf_local_nxvisit, @function
hrdbf_local_nxvisit:
.Lhrdbf_entry_hrdbf_local_nxvisit:
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
	ja	.Lhrdbf_5
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.Lhrdbf_5
	testl	$1023, %esi
	jne	.Lhrdbf_5
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.Lhrdbf_5
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
	jne	.Lhrdbf_5
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.Lhrdbf_5
	testw	%r13w, %r13w
	jne	.Lhrdbf_29
	testl	%esi, %esi
	je	.Lhrdbf_29
	.p2align 4,,10
	.p2align 3
.Lhrdbf_5:
	movl	$1, %eax
.Lhrdbf_1:
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
.Lhrdbf_29:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.Lhrdbf_10:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.Lhrdbf_5
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.Lhrdbf_5
	testw	%r11w, %r11w
	je	.Lhrdbf_7
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_9:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.Lhrdbf_8
	cmpl	%r10d, %edx
	jl	.Lhrdbf_5
.Lhrdbf_8:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.Lhrdbf_9
.Lhrdbf_7:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.Lhrdbf_10
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.Lhrdbf_11
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.Lhrdbf_46
	cmpl	%esi, %eax
	jne	.Lhrdbf_5
.Lhrdbf_11:
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
.Lhrdbf_25:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.Lhrdbf_5
	testl	%r15d, %r15d
	jne	.Lhrdbf_13
.Lhrdbf_16:
	cmpq	%r13, 8(%rsp)
	je	.Lhrdbf_14
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbf_18
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.Lhrdbf_18
	cmpl	36(%rbp), %edx
	jbe	.Lhrdbf_18
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
	jne	.Lhrdbf_18
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
	je	.Lhrdbf_19
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.Lhrdbf_20
	.p2align 4,,10
	.p2align 3
.Lhrdbf_48:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.Lhrdbf_47
.Lhrdbf_20:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.Lhrdbf_48
.Lhrdbf_18:
	movl	$4, %eax
	jmp	.Lhrdbf_1
.Lhrdbf_13:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call .Lhrdbf_entry_hrdbf_local_nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.Lhrdbf_16
	jmp	.Lhrdbf_1
	.p2align 4,,10
	.p2align 3
.Lhrdbf_47:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_28
.Lhrdbf_44:
	movq	16(%rdi), %rsi
.Lhrdbf_23:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.Lhrdbf_25
.Lhrdbf_14:
	xorl	%eax, %eax
	jmp	.Lhrdbf_1
.Lhrdbf_46:
	movl	%esi, 40(%rbp)
	jmp	.Lhrdbf_11
.Lhrdbf_28:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.Lhrdbf_24
.Lhrdbf_22:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.Lhrdbf_26
.Lhrdbf_24:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.Lhrdbf_22
	jb	.Lhrdbf_23
	jmp	.Lhrdbf_5
.Lhrdbf_19:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_44
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.Lhrdbf_26:
	cmpl	%r11d, %eax
	ja	.Lhrdbf_23
	jmp	.Lhrdbf_5
	.size	hrdbf_local_nxvisit, .-hrdbf_local_nxvisit
	.p2align 4
	.globl	hrntx_open
	.type	hrntx_open, @function
hrntx_open:
.Lhrdbf_entry_hrntx_open:
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
	ja	.Lhrdbf_49
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrdbf_49
	testl	$1023, %edx
	jne	.Lhrdbf_49
	testq	%rbp, %rbp
	je	.Lhrdbf_49
	cmpb	$0, 40(%rbp)
	je	.Lhrdbf_49
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.Lhrdbf_49
	cmpw	$0, 16(%rsi)
	jne	.Lhrdbf_49
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.Lhrdbf_52
	.p2align 4,,10
	.p2align 3
.Lhrdbf_51:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.Lhrdbf_113
.Lhrdbf_52:
	cmpq	$11, %rcx
	jbe	.Lhrdbf_51
	cmpb	$0, 538(%rax,%rcx)
	je	.Lhrdbf_51
.Lhrdbf_85:
	movl	$2, %r10d
.Lhrdbf_49:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_113:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbf_49
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.Lhrdbf_49
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.Lhrdbf_49
	movl	%esi, %ecx
	shrw	%cx
	cmpw	20(%rax), %cx
	jne	.Lhrdbf_49
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbf_53
	jmp	.Lhrdbf_49
	.p2align 4,,10
	.p2align 3
.Lhrdbf_54:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.Lhrdbf_85
.Lhrdbf_53:
	cmpb	$0, 22(%rax,%r12)
	jne	.Lhrdbf_54
	testq	%r12, %r12
	je	.Lhrdbf_85
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbf_85
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.Lhrdbf_55:
	xorl	%esi, %esi
	jmp	.Lhrdbf_64
	.p2align 4,,10
	.p2align 3
.Lhrdbf_114:
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
	jne	.Lhrdbf_57
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.Lhrdbf_56
	cmpq	$10, %rsi
	ja	.Lhrdbf_56
.Lhrdbf_64:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_114
.Lhrdbf_57:
	cmpq	%r12, %rsi
	je	.Lhrdbf_69
.Lhrdbf_61:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.Lhrdbf_55
	jmp	.Lhrdbf_85
.Lhrdbf_56:
	cmpq	%r12, %rsi
	jne	.Lhrdbf_61
	cmpq	$11, %rsi
	je	.Lhrdbf_62
.Lhrdbf_69:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.Lhrdbf_61
.Lhrdbf_62:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.Lhrdbf_85
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbf_49
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.Lhrdbf_49
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.Lhrdbf_91
	testq	%r8, %r8
	jne	.Lhrdbf_92
	testl	%ecx, %ecx
	jne	.Lhrdbf_91
.Lhrdbf_92:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.Lhrdbf_91
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.Lhrdbf_91
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.Lhrdbf_66:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.Lhrdbf_66
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
	call .Lhrdbf_entry_hrdbf_local_nxvisit
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_67
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.Lhrdbf_68
	movl	$4, %r10d
.Lhrdbf_67:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_49
.Lhrdbf_68:
	movl	%eax, 24(%rbx)
	jmp	.Lhrdbf_49
.Lhrdbf_91:
	movl	$3, %r10d
	jmp	.Lhrdbf_49
	.size	hrntx_open, .-hrntx_open
	.p2align 4
	.type	hrdbf_local_cxleaf_header, @function
hrdbf_local_cxleaf_header:
.Lhrdbf_entry_hrdbf_local_cxleaf_header:
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
	jne	.Lhrdbf_121
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.Lhrdbf_123
.Lhrdbf_121:
	movl	$1, %eax
.Lhrdbf_115:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_123:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.Lhrdbf_115
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.Lhrdbf_115
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.Lhrdbf_115
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.Lhrdbf_121
	cmpl	%edi, %r12d
	jb	.Lhrdbf_121
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbf_115
	.size	hrdbf_local_cxleaf_header, .-hrdbf_local_cxleaf_header
	.p2align 4
	.type	hrdbf_local_cxkey, @function
hrdbf_local_cxkey:
.Lhrdbf_entry_hrdbf_local_cxkey:
	pushq	%r12
	movq	%rsi, %r10
	movl	%ecx, %r11d
	pushq	%rbp
	pushq	%rbx
	movl	%edx, %ebx
	movl	16(%rsi), %edx
	movl	20(%rsi), %ebp
	testl	%edx, %edx
	je	.Lhrdbf_125
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_126:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.Lhrdbf_126
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
	jne	.Lhrdbf_127
	testl	%edx, %edx
	je	.Lhrdbf_127
.Lhrdbf_129:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_127:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.Lhrdbf_129
.Lhrdbf_135:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbf_129
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbf_129
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.Lhrdbf_130
	xorl	%eax, %eax
	jmp	.Lhrdbf_131
	.p2align 4,,10
	.p2align 3
.Lhrdbf_148:
	movq	(%r9), %rcx
.Lhrdbf_131:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbf_148
.Lhrdbf_130:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.Lhrdbf_134
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_133:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_133
.Lhrdbf_134:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_125:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbf_135
	.size	hrdbf_local_cxkey, .-hrdbf_local_cxkey
	.p2align 4
	.type	hrdbf_local_cxvisit, @function
hrdbf_local_cxvisit:
.Lhrdbf_entry_hrdbf_local_cxvisit:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$328, %rsp
	movq	$512, 24(%rsp)
	cmpl	$64, %edx
	je	.Lhrdbf_152
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.Lhrdbf_204
.Lhrdbf_152:
	movl	$1, %r12d
.Lhrdbf_149:
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
.Lhrdbf_204:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.Lhrdbf_152
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.Lhrdbf_152
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
	jne	.Lhrdbf_152
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
	je	.Lhrdbf_153
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.Lhrdbf_152
.Lhrdbf_153:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_205
	cmpl	%r8d, %ecx
	jne	.Lhrdbf_152
	cmpl	%eax, 312(%rdx)
	jne	.Lhrdbf_152
.Lhrdbf_175:
	cmpl	$-1, %r9d
	je	.Lhrdbf_157
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.Lhrdbf_152
	testl	$511, %r9d
	jne	.Lhrdbf_152
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.Lhrdbf_152
.Lhrdbf_157:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.Lhrdbf_158
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbf_206
	cmpl	%esi, %eax
	jne	.Lhrdbf_152
.Lhrdbf_160:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbf_149
	testl	%r14d, %r14d
	je	.Lhrdbf_170
	movl	%r15d, %ecx
.Lhrdbf_161:
	leaq	20(%rsp), %rax
	movl	%r12d, %edx
	movq	%rbp, %rdi
	pushq	%rax
	leaq	32(%rsp), %r9
	leaq	72(%rsp), %r8
	leaq	40(%rsp), %rsi
	call .Lhrdbf_entry_hrdbf_local_cxkey
	popq	%rdx
	testl	%eax, %eax
	jne	.Lhrdbf_180
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbf_163
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.Lhrdbf_163
	cmpl	48(%rbx), %eax
	jbe	.Lhrdbf_163
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
	jne	.Lhrdbf_163
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
	je	.Lhrdbf_164
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.Lhrdbf_165
.Lhrdbf_208:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbf_207
	movq	%rdx, %rax
.Lhrdbf_165:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.Lhrdbf_208
.Lhrdbf_163:
	movl	$4, %r12d
	jmp	.Lhrdbf_149
	.p2align 4,,10
	.p2align 3
.Lhrdbf_205:
	cmpl	$-1, %r8d
	jne	.Lhrdbf_152
	jmp	.Lhrdbf_175
.Lhrdbf_158:
	testl	%r14d, %r14d
	je	.Lhrdbf_152
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.Lhrdbf_152
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.Lhrdbf_173:
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
	call .Lhrdbf_entry_hrdbf_local_cxvisit
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_201
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.Lhrdbf_152
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
	jne	.Lhrdbf_152
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.Lhrdbf_171
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.Lhrdbf_172
	.p2align 4,,10
	.p2align 3
.Lhrdbf_209:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_171
.Lhrdbf_172:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.Lhrdbf_209
	jmp	.Lhrdbf_152
.Lhrdbf_206:
	movl	%esi, 52(%rbx)
	jmp	.Lhrdbf_160
.Lhrdbf_171:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.Lhrdbf_201
	movzwl	%r11w, %ecx
	jmp	.Lhrdbf_173
.Lhrdbf_207:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_178
.Lhrdbf_203:
	movq	16(%r11), %rcx
.Lhrdbf_168:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.Lhrdbf_170
	movzwl	%r9w, %ecx
	jmp	.Lhrdbf_161
.Lhrdbf_201:
	movl	%r10d, %r12d
	jmp	.Lhrdbf_149
.Lhrdbf_164:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbf_203
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.Lhrdbf_176:
	cmpl	%r11d, %r8d
	ja	.Lhrdbf_168
	jmp	.Lhrdbf_152
.Lhrdbf_178:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.Lhrdbf_169
.Lhrdbf_167:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.Lhrdbf_176
	movq	%r15, %rsi
.Lhrdbf_169:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.Lhrdbf_167
	jb	.Lhrdbf_168
	jmp	.Lhrdbf_152
.Lhrdbf_180:
	movl	%eax, %r12d
	jmp	.Lhrdbf_149
.Lhrdbf_170:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbf_149
	.size	hrdbf_local_cxvisit, .-hrdbf_local_cxvisit
	.p2align 4
	.type	hrdbf_local_cxheader, @function
hrdbf_local_cxheader:
.Lhrdbf_entry_hrdbf_local_cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.Lhrdbf_210
	cmpb	$1, 15(%rdi)
	jne	.Lhrdbf_210
	cmpw	$1024, 16(%rdi)
	jne	.Lhrdbf_210
	cmpw	$512, 18(%rdi)
	jne	.Lhrdbf_210
	cmpw	$0, 502(%rdi)
	jne	.Lhrdbf_210
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.Lhrdbf_213
	.p2align 4,,10
	.p2align 3
.Lhrdbf_232:
	cmpl	$23, %eax
	ja	.Lhrdbf_220
.Lhrdbf_212:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbf_231
.Lhrdbf_213:
	cmpb	$0, (%rdi,%rax)
	je	.Lhrdbf_212
	testb	%cl, %cl
	je	.Lhrdbf_232
.Lhrdbf_220:
	movl	$2, %eax
.Lhrdbf_210:
	ret
.Lhrdbf_231:
	testl	%edx, %edx
	je	.Lhrdbf_214
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_210
	cmpb	$67, 21(%rdi)
	jne	.Lhrdbf_210
	cmpb	$72, 22(%rdi)
	jne	.Lhrdbf_210
	cmpb	$66, 23(%rdi)
	jne	.Lhrdbf_210
.Lhrdbf_214:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_210
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.Lhrdbf_210
	xorl	%eax, %eax
	cmpw	$0, 508(%rdi)
	setne	%al
	addl	%eax, %eax
	ret
	.size	hrdbf_local_cxheader, .-hrdbf_local_cxheader
	.p2align 4
	.type	hrntx_file_close.constprop.0, @function
hrntx_file_close.constprop.0:
.Lhrdbf_entry_hrntx_file_close.constprop.0:
	movq	hrdbf_app_order+32(%rip), %rdi
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_234
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_234
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_234:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_233
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_238
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_233:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_238:
	movl	$7, %r8d
	movl	%r8d, %eax
	ret
	.size	hrntx_file_close.constprop.0, .-hrntx_file_close.constprop.0
	.p2align 4
	.type	hrdbf_local_cxmark.isra.0, @function
hrdbf_local_cxmark.isra.0:
.Lhrdbf_entry_hrdbf_local_cxmark.isra.0:
	movl	%esi, %ecx
	shrl	$3, %esi
	movl	$1, %eax
	addq	%rsi, %rdi
	andl	$7, %ecx
	movzbl	(%rdi), %edx
	sall	%cl, %eax
	testb	%al, %dl
	jne	.Lhrdbf_243
	orl	%eax, %edx
	movb	%dl, (%rdi)
.Lhrdbf_243:
	ret
	.size	hrdbf_local_cxmark.isra.0, .-hrdbf_local_cxmark.isra.0
	.p2align 4
	.globl	hrcdx_open
	.type	hrcdx_open, @function
hrcdx_open:
.Lhrdbf_entry_hrcdx_open:
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
	ja	.Lhrdbf_249
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.Lhrdbf_249
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.Lhrdbf_249
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.Lhrdbf_249
	cmpb	$0, 40(%rcx)
	je	.Lhrdbf_249
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_245
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.Lhrdbf_245
	cmpw	$1, 510(%r12)
	jne	.Lhrdbf_245
	cmpb	$0, 512(%r12)
	jne	.Lhrdbf_245
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.Lhrdbf_249
	testl	$511, %r10d
	jne	.Lhrdbf_249
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.Lhrdbf_249
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.Lhrdbf_245
	cmpw	$1, 2(%r12,%rdx)
	jne	.Lhrdbf_245
	cmpl	$-1, 4(%r12,%rdx)
	jne	.Lhrdbf_249
	cmpl	$-1, 8(%r12,%rdx)
	jne	.Lhrdbf_249
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbf_245
	leaq	52(%rsp), %rax
	xorl	%edx, %edx
	movq	%r8, %r14
	movl	$10, %ecx
	pushq	%rax
	movq	16(%rsp), %rdi
	leaq	64(%rsp), %r9
	leaq	104(%rsp), %r8
	leaq	72(%rsp), %rsi
	call .Lhrdbf_entry_hrdbf_local_cxkey
	popq	%rdx
	testl	%eax, %eax
	jne	.Lhrdbf_245
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_249
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.Lhrdbf_249
	testl	$511, %r8d
	jne	.Lhrdbf_249
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.Lhrdbf_249
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.Lhrdbf_249
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.Lhrdbf_249
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.Lhrdbf_249
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_250
.Lhrdbf_323:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.Lhrdbf_287
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbf_322
.Lhrdbf_250:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbf_323
.Lhrdbf_287:
	movl	$2, %eax
	jmp	.Lhrdbf_245
	.p2align 4,,10
	.p2align 3
.Lhrdbf_249:
	movl	$1, %eax
.Lhrdbf_245:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_322:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_245
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbf_287
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.Lhrdbf_287
	cmpb	$0, (%r12,%rdx)
	jne	.Lhrdbf_287
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.Lhrdbf_251:
	cmpb	$0, (%rdi,%rdx)
	je	.Lhrdbf_287
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbf_251
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.Lhrdbf_252:
	cmpq	%r11, 40(%rsp)
	jbe	.Lhrdbf_287
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.Lhrdbf_261:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.Lhrdbf_255
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.Lhrdbf_256
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.Lhrdbf_256:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.Lhrdbf_257
	subl	$32, %esi
.Lhrdbf_257:
	cmpb	16(%rsp), %sil
	jne	.Lhrdbf_255
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbf_253
	cmpq	$11, %rdx
	jne	.Lhrdbf_261
	cmpq	$11, %rax
	jne	.Lhrdbf_255
.Lhrdbf_259:
	cmpl	%r11d, 36(%rsp)
	je	.Lhrdbf_287
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.Lhrdbf_287
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.Lhrdbf_286
	cmpw	12(%r12,%r9), %ax
	jne	.Lhrdbf_287
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.Lhrdbf_291
	testq	%r14, %r14
	jne	.Lhrdbf_293
	testl	%eax, %eax
	jne	.Lhrdbf_291
.Lhrdbf_293:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.Lhrdbf_291
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.Lhrdbf_291
	xorl	%edx, %edx
.Lhrdbf_263:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_263
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbf_264
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbf_264:
	testb	$2, %al
	jne	.Lhrdbf_265
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbf_265:
	movq	992(%rsp), %rdi
	movl	%r10d, %esi
	shrl	$9, %r8d
	shrl	$9, %esi
	call .Lhrdbf_entry_hrdbf_local_cxmark.isra.0
	movq	992(%rsp), %rdi
	movl	%r8d, %esi
	call .Lhrdbf_entry_hrdbf_local_cxmark.isra.0
	movq	992(%rsp), %rdi
	leal	1(%r8), %esi
	call .Lhrdbf_entry_hrdbf_local_cxmark.isra.0
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
.Lhrdbf_266:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbf_266
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call .Lhrdbf_entry_hrdbf_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbf_324
.Lhrdbf_267:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_245
.Lhrdbf_253:
	cmpq	$11, %rax
	je	.Lhrdbf_259
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbf_259
.Lhrdbf_255:
	addq	$1, %r11
	jmp	.Lhrdbf_252
.Lhrdbf_291:
	movl	$3, %eax
	jmp	.Lhrdbf_245
.Lhrdbf_286:
	movl	$5, %eax
	jmp	.Lhrdbf_245
.Lhrdbf_324:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.Lhrdbf_267
	xorl	%edx, %edx
	jmp	.Lhrdbf_269
.Lhrdbf_325:
	cmpq	$63, %rdx
	ja	.Lhrdbf_294
.Lhrdbf_269:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbf_268
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.Lhrdbf_268:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbf_325
.Lhrdbf_294:
	testl	%eax, %eax
	jne	.Lhrdbf_267
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbf_245
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.globl	hrdbf_close
	.type	hrdbf_close, @function
hrdbf_close:
.Lhrdbf_entry_hrdbf_close:
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
.Lhrdbf_entry_hrdbf_top:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_327
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_327:
	ret
	.size	hrdbf_top, .-hrdbf_top
	.p2align 4
	.globl	hrdbf_skip
	.type	hrdbf_skip, @function
hrdbf_skip:
.Lhrdbf_entry_hrdbf_skip:
	endbr64
	cmpb	$0, 40(%rdi)
	movq	%rdi, %rax
	movl	$6, %r8d
	je	.Lhrdbf_330
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_330
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_332
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
.Lhrdbf_334:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_344
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_330:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_332:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_335
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_330
	.p2align 4,,10
	.p2align 3
.Lhrdbf_344:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_330
	.p2align 4,,10
	.p2align 3
.Lhrdbf_335:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_334
	.size	hrdbf_skip, .-hrdbf_skip
	.p2align 4
	.globl	hrdbf_get
	.type	hrdbf_get, @function
hrdbf_get:
.Lhrdbf_entry_hrdbf_get:
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
	je	.Lhrdbf_424
	testl	%esi, %esi
	je	.Lhrdbf_425
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_425
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
	ja	.Lhrdbf_425
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_428
	cmpb	$78, %r8b
	je	.Lhrdbf_429
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_430
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_371
	cmpb	$89, %dl
	je	.Lhrdbf_371
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_425
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_424
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_424
	.p2align 4,,10
	.p2align 3
.Lhrdbf_425:
	xorl	%r8d, %r8d
.Lhrdbf_424:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_371:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_428:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_424
	.p2align 4,,10
	.p2align 3
.Lhrdbf_429:
	testl	%edi, %edi
	je	.Lhrdbf_425
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_350
	.p2align 4,,10
	.p2align 3
.Lhrdbf_351:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_425
.Lhrdbf_350:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_351
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_353
	.p2align 4,,10
	.p2align 3
.Lhrdbf_377:
	movl	%edx, %edi
.Lhrdbf_353:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_352
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_377
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_397
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_375:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_355:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_382
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_374:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_359
	.p2align 4,,10
	.p2align 3
.Lhrdbf_431:
	testl	%ebx, %ebx
	jne	.Lhrdbf_398
	movl	$1, %ebx
.Lhrdbf_356:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_358
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_359:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_431
.Lhrdbf_398:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_382
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_388
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_356
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_356
	.p2align 4,,10
	.p2align 3
.Lhrdbf_430:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_368:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_390
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_368
	jmp	.Lhrdbf_425
.Lhrdbf_390:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_367:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_391
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_367
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
	jbe	.Lhrdbf_424
	cmpl	$11, %edx
	ja	.Lhrdbf_424
	testl	%edi, %edi
	je	.Lhrdbf_424
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_432
.Lhrdbf_369:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_424
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_424
.Lhrdbf_358:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_345
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_345
	leal	1(%r13), %eax
	jbe	.Lhrdbf_360
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_361
	jmp	.Lhrdbf_388
	.p2align 4,,10
	.p2align 3
.Lhrdbf_362:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_388
.Lhrdbf_361:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_362
	testl	%r12d, %r12d
	jne	.Lhrdbf_373
.Lhrdbf_364:
	movq	%r11, %rax
.Lhrdbf_365:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_345:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_388:
	movl	$4, %r8d
	jmp	.Lhrdbf_345
.Lhrdbf_352:
	je	.Lhrdbf_347
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_355
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_375
	.p2align 4,,10
	.p2align 3
.Lhrdbf_347:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_345
.Lhrdbf_382:
	movl	$5, %r8d
	jmp	.Lhrdbf_345
.Lhrdbf_397:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_374
.Lhrdbf_391:
	movl	$5, %r8d
	jmp	.Lhrdbf_424
.Lhrdbf_432:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_369
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_370
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_369
.Lhrdbf_370:
	addl	$1, %r10d
	jmp	.Lhrdbf_369
.Lhrdbf_360:
	testl	%r12d, %r12d
	je	.Lhrdbf_364
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_365
.Lhrdbf_373:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_365
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_433
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_435
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_435:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_433:
	ret
	.size	hrdbf_deleted, .-hrdbf_deleted
	.p2align 4
	.globl	hrdbf_open
	.type	hrdbf_open, @function
hrdbf_open:
.Lhrdbf_entry_hrdbf_open:
	endbr64
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$2184, %rsp
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	$0, 80(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 104(%rsp)
	movl	$16842752, 116(%rsp)
	movb	$0, 120(%rsp)
	cmpq	$32, %rdx
	jbe	.Lhrdbf_474
	cmpb	$3, (%rsi)
	movl	$2, %eax
	jne	.Lhrdbf_438
	cmpb	$0, 14(%rsi)
	jne	.Lhrdbf_438
	cmpb	$0, 15(%rsi)
	jne	.Lhrdbf_438
	cmpb	$0, 28(%rsi)
	jne	.Lhrdbf_438
	cmpb	$0, 29(%rsi)
	jne	.Lhrdbf_438
	movzwl	8(%rsi), %eax
	movzwl	10(%rsi), %r13d
	movl	4(%rsi), %r15d
	movw	%ax, 112(%rsp)
	movw	%r13w, 114(%rsp)
	movl	%r15d, 96(%rsp)
	cmpw	$32, %ax
	jbe	.Lhrdbf_474
	movzwl	%r13w, %ecx
	movq	%rdi, %rbx
	movzwl	%ax, %edi
	movq	%rdx, %r8
	testl	%ecx, %ecx
	movl	%ecx, 20(%rsp)
	sete	%al
	cmpq	%rdx, %rdi
	movq	%rdi, (%rsp)
	seta	%dl
	orb	%dl, %al
	je	.Lhrdbf_490
	.p2align 4,,10
	.p2align 3
.Lhrdbf_474:
	movl	$1, %eax
.Lhrdbf_438:
	addq	$2184, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_490:
	leaq	-32(%rdi), %rdx
	movq	%rbx, 24(%rsp)
	leaq	32(%rsi), %r11
	xorl	%r9d, %r9d
	shrq	$5, %rdx
	movl	$1, %ecx
	movl	$32, %edi
	movq	%rsi, 32(%rsp)
	movq	%rdx, 8(%rsp)
	leaq	80(%rsp), %r10
	xorl	%r14d, %r14d
	movl	%ecx, %esi
	movq	%r8, 40(%rsp)
	movq	%rdi, %r8
.Lhrdbf_454:
	movzbl	(%r11), %ecx
	movl	%r14d, %edi
	cmpb	$13, %cl
	je	.Lhrdbf_491
	cmpq	8(%rsp), %r14
	je	.Lhrdbf_474
	cmpq	$4128, %r8
	je	.Lhrdbf_475
	movl	%r14d, %eax
	movl	%r14d, %ebx
	xorl	%edx, %edx
	jmp	.Lhrdbf_445
	.p2align 4,,10
	.p2align 3
.Lhrdbf_492:
	movzbl	(%r11,%rdx), %ecx
.Lhrdbf_445:
	movb	%cl, 42(%r10,%rdx)
	addq	$1, %rdx
	cmpq	$11, %rdx
	jne	.Lhrdbf_492
	movzbl	42(%r10), %r12d
	testb	%r12b, %r12b
	je	.Lhrdbf_474
	leal	1(%rax), %edx
	cmpl	$1, %edx
	jbe	.Lhrdbf_446
	leal	-1(%rax), %ebp
	leaq	149(%rsp), %rax
	xorl	%edi, %edi
	salq	$4, %rbp
	leaq	133(%rsp), %rcx
	addq	%rax, %rbp
	.p2align 4,,10
	.p2align 3
.Lhrdbf_447:
	leaq	-11(%rcx), %rax
	movl	%r12d, %edx
	jmp	.Lhrdbf_449
	.p2align 4,,10
	.p2align 3
.Lhrdbf_494:
	leaq	(%rdi,%rax), %rdx
	movzbl	(%rdx,%r9), %edx
.Lhrdbf_449:
	cmpb	%dl, (%rax)
	jne	.Lhrdbf_493
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_494
	movl	$1, %eax
	jmp	.Lhrdbf_438
	.p2align 4,,10
	.p2align 3
.Lhrdbf_493:
	addq	$16, %rcx
	subq	$16, %rdi
	cmpq	%rbp, %rcx
	jne	.Lhrdbf_447
.Lhrdbf_446:
	movzbl	11(%r11), %edx
	movzbl	16(%r11), %eax
	movw	%si, 56(%r10)
	movzbl	17(%r11), %ecx
	movb	%dl, 53(%r10)
	movb	%al, 54(%r10)
	movb	%cl, 55(%r10)
	testb	%al, %al
	je	.Lhrdbf_474
	cmpb	$67, %dl
	je	.Lhrdbf_495
	cmpb	$78, %dl
	je	.Lhrdbf_496
	cmpb	$76, %dl
	je	.Lhrdbf_497
	cmpb	$68, %dl
	jne	.Lhrdbf_473
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	jne	.Lhrdbf_474
.Lhrdbf_451:
	addl	%eax, %esi
	cmpl	$65535, %esi
	ja	.Lhrdbf_475
	addq	$32, %r8
	addq	$1, %r14
	addq	$32, %r11
	addq	$16, %r10
	addq	$16, %r9
	movl	$1, %eax
	cmpq	%r8, (%rsp)
	ja	.Lhrdbf_454
	jmp	.Lhrdbf_474
.Lhrdbf_495:
	testb	%cl, %cl
	je	.Lhrdbf_451
.Lhrdbf_473:
	movl	$3, %eax
	jmp	.Lhrdbf_438
	.p2align 4,,10
	.p2align 3
.Lhrdbf_496:
	cmpb	%cl, %al
	jbe	.Lhrdbf_475
	cmpb	$17, %cl
	jbe	.Lhrdbf_451
.Lhrdbf_475:
	movl	$4, %eax
	jmp	.Lhrdbf_438
.Lhrdbf_497:
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.Lhrdbf_451
	jmp	.Lhrdbf_474
	.p2align 4,,10
	.p2align 3
.Lhrdbf_491:
	movl	%esi, %edx
	movq	%r8, %rcx
	movq	24(%rsp), %rbx
	movq	32(%rsp), %rsi
	movq	40(%rsp), %r8
	testb	%al, %al
	je	.Lhrdbf_474
	movw	%r14w, 116(%rsp)
	cmpl	%edx, 20(%rsp)
	jne	.Lhrdbf_474
	testw	%r14w, %r14w
	je	.Lhrdbf_474
	movq	%rcx, %rax
	addq	$1, %rax
	jmp	.Lhrdbf_442
.Lhrdbf_455:
	addq	$1, %rax
	cmpb	$0, -1(%rsi,%rax)
	jne	.Lhrdbf_474
.Lhrdbf_442:
	cmpq	%rax, (%rsp)
	ja	.Lhrdbf_455
	movq	(%rsp), %rcx
	movq	%r8, %rax
	xorl	%edx, %edx
	movl	%r15d, %ebp
	subq	%rcx, %rax
	divq	%r13
	cmpq	%rax, %rbp
	ja	.Lhrdbf_474
	movq	%rbp, %rax
	imulq	%r13, %rax
	addq	%rcx, %rax
	cmpq	%rax, %r8
	je	.Lhrdbf_456
	movq	%r8, %rdx
	subq	%rax, %rdx
	subq	$1, %rdx
	jne	.Lhrdbf_474
	cmpb	$26, (%rsi,%rax)
	jne	.Lhrdbf_474
.Lhrdbf_456:
	testl	%r15d, %r15d
	movq	(%rsp), %r12
	movq	%rsi, 80(%rsp)
	sete	%al
	movq	%r8, 88(%rsp)
	xorl	%r14d, %r14d
	movb	%al, 119(%rsp)
	addq	%rsi, %r12
	movb	%al, 118(%rsp)
	movzwl	%di, %eax
	movb	$1, 120(%rsp)
	movl	%eax, (%rsp)
.Lhrdbf_457:
	cmpq	%r14, %rbp
	jbe	.Lhrdbf_498
	movzbl	(%r12), %eax
	cmpb	$32, %al
	je	.Lhrdbf_477
	cmpb	$42, %al
	jne	.Lhrdbf_476
.Lhrdbf_477:
	addq	$1, %r14
	movl	$1, %r15d
	movq	%r14, 104(%rsp)
	jmp	.Lhrdbf_459
.Lhrdbf_500:
	addl	$1, %r15d
	cmpl	%r15d, (%rsp)
	jb	.Lhrdbf_499
.Lhrdbf_459:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	je	.Lhrdbf_500
	jmp	.Lhrdbf_438
.Lhrdbf_498:
	movl	$262, %ecx
	movq	%rbx, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.Lhrdbf_438
.Lhrdbf_476:
	movl	$5, %eax
	jmp	.Lhrdbf_438
.Lhrdbf_499:
	addq	%r13, %r12
	jmp	.Lhrdbf_457
	.size	hrdbf_open, .-hrdbf_open
	.p2align 4
	.globl	hrv_date
	.type	hrv_date, @function
hrv_date:
.Lhrdbf_entry_hrv_date:
	endbr64
	movl	%edi, %edx
	movl	$11, %eax
	ret
	.size	hrv_date, .-hrv_date
	.p2align 4
	.globl	hrv_number
	.type	hrv_number, @function
hrv_number:
.Lhrdbf_entry_hrv_number:
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
.Lhrdbf_entry_hrv_validate:
	endbr64
	movzbl	%dil, %edx
	movl	$4, %eax
	cmpl	$12, %edx
	ja	.Lhrdbf_503
	je	.Lhrdbf_523
	cmpl	$5, %edx
	je	.Lhrdbf_506
	shrq	$8, %rdi
	jne	.Lhrdbf_524
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_503
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_503
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_503
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_503
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
	ja	.Lhrdbf_519
	testq	%rsi, %rsi
	je	.Lhrdbf_519
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_525
.Lhrdbf_508:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_523:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_503
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_526
.Lhrdbf_503:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_506:
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
.Lhrdbf_526:
	testb	$-1, %dh
	jne	.Lhrdbf_503
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
.Lhrdbf_524:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_519:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_525:
	testb	$3, %cl
	jne	.Lhrdbf_508
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_509
	addl	$1, %eax
	jmp	.Lhrdbf_508
.Lhrdbf_509:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_508
	.size	hrv_validate, .-hrv_validate
	.p2align 4
	.globl	hrv_valtype
	.type	hrv_valtype, @function
hrv_valtype:
.Lhrdbf_entry_hrv_valtype:
	endbr64
	movzbl	%dil, %edx
	movl	$63, %eax
	cmpb	$12, %dil
	ja	.Lhrdbf_527
	movzbl	hrdbf_local_CSWTCH.182(%rdx), %eax
.Lhrdbf_527:
	ret
	.size	hrv_valtype, .-hrv_valtype
	.p2align 4
	.globl	hrv_i64
	.type	hrv_i64, @function
hrv_i64:
.Lhrdbf_entry_hrv_i64:
	endbr64
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_530
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_540
	testl	%edx, %edx
	je	.Lhrdbf_533
	cmpl	$9, %edx
	je	.Lhrdbf_533
	movl	$1, %eax
.Lhrdbf_530:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_540:
	testl	$65280, %r9d
	jne	.Lhrdbf_541
.Lhrdbf_533:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_541:
	movl	$2, %eax
	ret
	.size	hrv_i64, .-hrv_i64
	.p2align 4
	.globl	hrv_equal
	.type	hrv_equal, @function
hrv_equal:
.Lhrdbf_entry_hrv_equal:
	endbr64
	pushq	%r13
	movq	%rsi, %r9
	movq	%rdx, %r10
	movq	%rcx, %r11
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	movq	%r8, %rbx
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_542
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_542
	movzbl	%bpl, %r13d
	movzbl	%r10b, %r12d
	cmpb	$11, %bpl
	jne	.Lhrdbf_544
	cmpl	$11, %r12d
	jne	.Lhrdbf_544
.Lhrdbf_557:
	xorl	%edx, %edx
	cmpq	%r11, %r9
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_542:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_544:
	cmpl	$1, %r13d
	je	.Lhrdbf_560
	cmpl	$1, %r12d
	je	.Lhrdbf_560
	cmpl	$3, %r13d
	jne	.Lhrdbf_547
	cmpl	$3, %r12d
	jne	.Lhrdbf_547
	testq	%r9, %r9
	sete	%dl
	testq	%r11, %r11
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_542
	.p2align 4,,10
	.p2align 3
.Lhrdbf_560:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_542
	.p2align 4,,10
	.p2align 3
.Lhrdbf_547:
	movq	%rbp, %rdi
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_542
	cmpl	$12, %r13d
	je	.Lhrdbf_583
	testl	%r13d, %r13d
	je	.Lhrdbf_550
	movl	$1, %eax
	cmpl	$9, %r13d
	jne	.Lhrdbf_542
.Lhrdbf_550:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_542
	cmpl	$12, %r12d
	je	.Lhrdbf_584
	testl	%r12d, %r12d
	je	.Lhrdbf_557
	cmpl	$9, %r12d
	je	.Lhrdbf_557
	movl	$1, %eax
	jmp	.Lhrdbf_542
	.p2align 4,,10
	.p2align 3
.Lhrdbf_583:
	testl	$65280, %ebp
	je	.Lhrdbf_550
.Lhrdbf_556:
	movl	$2, %eax
	jmp	.Lhrdbf_542
	.p2align 4,,10
	.p2align 3
.Lhrdbf_584:
	testl	$65280, %r10d
	je	.Lhrdbf_557
	jmp	.Lhrdbf_556
	.size	hrv_equal, .-hrv_equal
	.p2align 4
	.globl	hrv_empty
	.type	hrv_empty, @function
hrv_empty:
.Lhrdbf_entry_hrv_empty:
	endbr64
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_585
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_589
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_587
	cmpl	$1, %ecx
	je	.Lhrdbf_590
.Lhrdbf_589:
	movl	$1, %eax
.Lhrdbf_585:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_587:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_590:
	movl	$1, (%r11)
	ret
	.size	hrv_empty, .-hrv_empty
	.p2align 4
	.globl	hrv_render
	.type	hrv_render, @function
hrv_render:
.Lhrdbf_entry_hrv_render:
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
	call .Lhrdbf_entry_hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbf_591
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_638
	cmpl	$12, %eax
	jne	.Lhrdbf_617
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
.Lhrdbf_599:
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
	ja	.Lhrdbf_599
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_639
	movl	$1, %esi
.Lhrdbf_600:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_601:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_602
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_640
	subl	%eax, %r14d
	je	.Lhrdbf_610
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_609:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_609
.Lhrdbf_610:
	testq	%r11, %r11
	jns	.Lhrdbf_608
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_608:
	testl	%esi, %esi
	je	.Lhrdbf_611
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_613
	.p2align 4,,10
	.p2align 3
.Lhrdbf_621:
	movl	%edx, %eax
.Lhrdbf_613:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_612
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_612:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_621
	addl	%esi, %r14d
.Lhrdbf_611:
	testl	%r10d, %r10d
	je	.Lhrdbf_591
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_615:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_614
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_614:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_615
.Lhrdbf_591:
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
.Lhrdbf_638:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_602
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_595
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_597:
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
	jne	.Lhrdbf_597
	jmp	.Lhrdbf_591
	.p2align 4,,10
	.p2align 3
.Lhrdbf_617:
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
.Lhrdbf_639:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_600
	movl	%esi, %eax
	jmp	.Lhrdbf_601
	.p2align 4,,10
	.p2align 3
.Lhrdbf_602:
	movl	$3, %r8d
	jmp	.Lhrdbf_591
	.p2align 4,,10
	.p2align 3
.Lhrdbf_595:
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
	jmp	.Lhrdbf_591
	.p2align 4,,10
	.p2align 3
.Lhrdbf_640:
	testl	%r14d, %r14d
	je	.Lhrdbf_591
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_605:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_605
	jmp	.Lhrdbf_591
	.size	hrv_render, .-hrv_render
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lhrdbf_C0:
	.string	"DBF unknown value error"
	.text
	.p2align 4
	.globl	hrv_error_name
	.type	hrv_error_name, @function
hrv_error_name:
.Lhrdbf_entry_hrv_error_name:
	endbr64
	movl	$.Lhrdbf_C0, %eax
	cmpl	$4, %edi
	ja	.Lhrdbf_641
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.201(,%rdi,8), %rax
.Lhrdbf_641:
	ret
	.size	hrv_error_name, .-hrv_error_name
	.p2align 4
	.globl	hrdbf_file_close
	.type	hrdbf_file_close, @function
hrdbf_file_close:
.Lhrdbf_entry_hrdbf_file_close:
	endbr64
	movq	$0, (%rdi)
	movq	%rdi, %r8
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	2096(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_647
	movq	2104(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_648
.Lhrdbf_647:
	movq	$0, 2096(%r8)
	xorl	%eax, %eax
	movq	$0, 2104(%r8)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_648:
	movl	$7, %eax
	ret
	.size	hrdbf_file_close, .-hrdbf_file_close
	.p2align 4
	.type	hrdbf_app_fail, @function
hrdbf_app_fail:
.Lhrdbf_entry_hrdbf_app_fail:
	xorl	%edx, %edx
	cmpb	$0, (%rdi)
	movq	%rdi, %rsi
	je	.Lhrdbf_650
	.p2align 4,,10
	.p2align 3
.Lhrdbf_651:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_651
.Lhrdbf_650:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%r9, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.Lhrdbf_C1:
	.string	"hbc: DBF field decoding failed\n"
	.align 8
.Lhrdbf_C2:
	.string	"hbc: DBF field string allocation failed\n"
	.text
	.p2align 4
	.type	hrdbf_app_get_ord.part.0, @function
hrdbf_app_get_ord.part.0:
.Lhrdbf_entry_hrdbf_app_get_ord.part.0:
	pushq	%rbx
	movq	%rsi, %rbx
	movl	%edi, %esi
	movl	$hrdbf_app_state, %edi
	subq	$288, %rsp
	movq	%rsp, %rdx
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	jne	.Lhrdbf_668
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_669
	cmpb	$78, %al
	je	.Lhrdbf_670
	cmpb	$68, %al
	je	.Lhrdbf_671
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_669:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_672
.Lhrdbf_657:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_673
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_671:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_670:
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
.Lhrdbf_672:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_660
	.p2align 4,,10
	.p2align 3
.Lhrdbf_659:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_659
.Lhrdbf_660:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_657
.Lhrdbf_668:
	movl	$.Lhrdbf_C1, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_673:
	movl	$.Lhrdbf_C2, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
.Lhrdbf_entry_hrdbf_file_open:
	endbr64
	pushq	%r13
	movq	%rsi, %r8
	movl	%edx, %r9d
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$24, %rsp
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	2096(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_678
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_698
.Lhrdbf_678:
	xorl	%r10d, %r10d
	cmpl	$1, %r9d
	movq	$0, 2096(%rbp)
	movl	$257, %r9d
	sbbq	%rdx, %rdx
	movq	$-100, %rdi
	movq	$0, 2104(%rbp)
	andq	$-2, %rdx
	addq	$524290, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_676:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_676
	testq	%rax, %rax
	js	.Lhrdbf_698
	movl	$8, %r8d
	xorl	%r13d, %r13d
	movl	$2, %edx
	movq	%rbx, %rdi
	movq	%r8, %rax
	movq	%r13, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	testq	%rax, %rax
	js	.Lhrdbf_718
	cmpq	$32, %rax
	jle	.Lhrdbf_719
	cmpq	$67108864, %rax
	jg	.Lhrdbf_720
	movq	%r8, %rax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_721
	movq	%r12, 2104(%rbp)
	xorl	%r9d, %r9d
	movq	%r13, %rdi
	movq	%r12, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.Lhrdbf_687
	movq	$0, 2096(%rbp)
.Lhrdbf_688:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	$0, 2104(%rbp)
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_682
	.p2align 4,,10
	.p2align 3
.Lhrdbf_717:
	movl	$7, %r8d
	jmp	.Lhrdbf_682
	.p2align 4,,10
	.p2align 3
.Lhrdbf_698:
	movl	$7, %r8d
.Lhrdbf_674:
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_718:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
.Lhrdbf_682:
	movq	2096(%rbp), %rdi
	movq	$0, 0(%rbp)
	movq	$0, 8(%rbp)
	movl	$0, 16(%rbp)
	movq	$0, 24(%rbp)
	movl	$16842752, 36(%rbp)
	movb	$0, 40(%rbp)
	testq	%rdi, %rdi
	je	.Lhrdbf_697
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_698
.Lhrdbf_697:
	movq	$0, 2096(%rbp)
	movl	%r8d, %eax
	movq	$0, 2104(%rbp)
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_720:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_682
	jmp	.Lhrdbf_717
	.p2align 4,,10
	.p2align 3
.Lhrdbf_719:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_682
	jmp	.Lhrdbf_717
	.p2align 4,,10
	.p2align 3
.Lhrdbf_687:
	movq	%rax, 2096(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_688
	movq	2104(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_689
	jmp	.Lhrdbf_690
	.p2align 4,,10
	.p2align 3
.Lhrdbf_722:
	movq	2096(%rbp), %rsi
.Lhrdbf_689:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%r9, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_691
	testq	%rax, %rax
	jle	.Lhrdbf_701
	addq	%rax, %r8
.Lhrdbf_691:
	movq	2104(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_722
.Lhrdbf_690:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_693:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_693
	testq	%rax, %rax
	je	.Lhrdbf_694
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.Lhrdbf_682
.Lhrdbf_694:
	movq	2104(%rbp), %rdx
	movq	2096(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movl	%eax, %r8d
.Lhrdbf_692:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_717
	testl	%r8d, %r8d
	je	.Lhrdbf_674
	jmp	.Lhrdbf_682
	.p2align 4,,10
	.p2align 3
.Lhrdbf_721:
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_717
.Lhrdbf_701:
	movl	$7, %r8d
	jmp	.Lhrdbf_692
	.size	hrdbf_file_open, .-hrdbf_file_open
	.p2align 4
	.globl	hrntx_close
	.type	hrntx_close, @function
hrntx_close:
.Lhrdbf_entry_hrntx_close:
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
.Lhrdbf_entry_hrntx_seek:
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
	je	.Lhrdbf_725
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_730:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_743
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_727:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_743
.Lhrdbf_729:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.Lhrdbf_727
	jnb	.Lhrdbf_743
	leal	1(%rdi), %r10d
.Lhrdbf_726:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_730
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_734
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.Lhrdbf_733:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.Lhrdbf_735
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_736
	.p2align 4,,10
	.p2align 3
.Lhrdbf_768:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_735
.Lhrdbf_736:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.Lhrdbf_768
.Lhrdbf_734:
	testl	%ebp, %ebp
	je	.Lhrdbf_724
	testl	%r12d, %r12d
	jne	.Lhrdbf_769
	movl	%r10d, %r11d
.Lhrdbf_724:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_743:
	movl	%edi, %r11d
	jmp	.Lhrdbf_726
.Lhrdbf_735:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.Lhrdbf_724
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_737
	.p2align 4,,10
	.p2align 3
.Lhrdbf_742:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_738
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_741
	.p2align 4,,10
	.p2align 3
.Lhrdbf_739:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_738
.Lhrdbf_741:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.Lhrdbf_739
	jb	.Lhrdbf_738
	movl	%edi, %r11d
.Lhrdbf_740:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_742
.Lhrdbf_737:
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
.Lhrdbf_738:
	leal	1(%rdi), %r10d
	jmp	.Lhrdbf_740
.Lhrdbf_769:
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
.Lhrdbf_725:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_724
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.Lhrdbf_733
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata.str1.1
.Lhrdbf_C3:
	.string	"hbc: DBF/NTX close failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_close
	.type	hrdbf_app_close, @function
hrdbf_app_close:
.Lhrdbf_entry_hrdbf_app_close:
	endbr64
	movq	hrdbf_app_order+32(%rip), %rdi
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_771
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_771
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_771:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_772
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_780
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_772:
	movq	hrdbf_app_state+2096(%rip), %rdi
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_777
	movq	hrdbf_app_state+2104(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_786
.Lhrdbf_777:
	movq	$0, hrdbf_app_state+2096(%rip)
	movq	$0, hrdbf_app_state+2104(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%r8d, %r8d
	jne	.Lhrdbf_774
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_780:
	movl	$7, %r8d
	jmp	.Lhrdbf_772
.Lhrdbf_786:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbf_774:
	movl	$.Lhrdbf_C3, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C4:
	.string	"hbc: DBF only one workarea is supported\n"
	.align 8
.Lhrdbf_C5:
	.string	"hbc: DBF filename length outside supported range\n"
	.align 8
.Lhrdbf_C6:
	.string	"hbc: DBF filename contains NUL\n"
	.section	.rodata.str1.1
.Lhrdbf_C7:
	.string	"hbc: DBF index close failed\n"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C8:
	.string	"hbc: DBF open rejected (format, data, size, access mode or I/O)\n"
	.text
	.p2align 4
	.globl	hrdbf_app_open
	.type	hrdbf_app_open, @function
hrdbf_app_open:
.Lhrdbf_entry_hrdbf_app_open:
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
	je	.Lhrdbf_788
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_825
.Lhrdbf_788:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_826
	xorl	%r9d, %r9d
	jmp	.Lhrdbf_789
	.p2align 4,,10
	.p2align 3
.Lhrdbf_811:
	movq	%r10, %r9
.Lhrdbf_789:
	movzbl	(%rbx,%r9), %eax
	testb	%al, %al
	je	.Lhrdbf_827
	leaq	1(%r9), %r10
	movb	%al, (%rsp,%r9)
	cmpq	%r10, %rsi
	jne	.Lhrdbf_811
	movq	hrdbf_app_order+32(%rip), %r13
	movb	$0, (%rsp,%r10)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r13, %r13
	je	.Lhrdbf_828
	movl	$11, %r12d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r13, %rdi
	movq	%r12, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_794
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_798
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_797
.Lhrdbf_799:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_798:
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movq	$0, hrdbf_app_pos(%rip)
	setne	%al
	xorl	%ecx, %ecx
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_801:
	movzbl	(%rbx,%rax), %esi
	movq	%rax, %rdx
	addq	$1, %rax
	cmpb	$47, %sil
	cmove	%rax, %rcx
	cmpq	%rdx, %r9
	jne	.Lhrdbf_801
	cmpq	%r10, %rcx
	jnb	.Lhrdbf_802
	movq	%rcx, %rax
	jmp	.Lhrdbf_804
	.p2align 4,,10
	.p2align 3
.Lhrdbf_812:
	movq	%rdx, %rax
.Lhrdbf_804:
	cmpb	$46, (%rbx,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %r10
	cmpq	%r9, %rax
	jne	.Lhrdbf_812
.Lhrdbf_802:
	subq	%rcx, %r10
	leaq	(%rbx,%rcx), %rdi
	movl	$0, %edx
	movq	%r10, hrdbf_app_baselen(%rip)
	je	.Lhrdbf_809
	.p2align 4,,10
	.p2align 3
.Lhrdbf_805:
	movzbl	(%rdi,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rdx, %r10
	jne	.Lhrdbf_805
.Lhrdbf_809:
	xorl	%edx, %edx
	testq	%r8, %r8
	movq	%rsp, %rsi
	movl	$hrdbf_app_state, %edi
	setne	%dl
	call .Lhrdbf_entry_hrdbf_file_open
	testl	%eax, %eax
	jne	.Lhrdbf_829
	addq	$4104, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_794:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_797
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_797
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_797:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_828:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_798
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_799
	jmp	.Lhrdbf_797
.Lhrdbf_827:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_825:
	movl	$.Lhrdbf_C4, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_829:
	movl	$.Lhrdbf_C8, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_826:
	movl	$.Lhrdbf_C5, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.section	.rodata.str1.1
.Lhrdbf_C9:
	.string	"hbc: DBF no workarea is open\n"
	.text
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_836
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_837
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbf_838
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbf_835:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_838:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbf_835
	.p2align 4,,10
	.p2align 3
.Lhrdbf_837:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbf_836:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
.Lhrdbf_entry_hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_847
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_848
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rax
	testl	%esi, %esi
	jne	.Lhrdbf_849
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.Lhrdbf_844:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
.Lhrdbf_845:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%eax, %eax
	sete	%al
.Lhrdbf_842:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_849:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_844
	movq	hrdbf_app_order+16(%rip), %rdx
	movl	(%rdx,%rcx,8), %edx
	jmp	.Lhrdbf_845
	.p2align 4,,10
	.p2align 3
.Lhrdbf_848:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmovne	%rax, %rdx
	sete	%al
	movl	%eax, %ecx
	jmp	.Lhrdbf_842
.Lhrdbf_847:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_864
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_865
	testq	%rdi, %rdi
	je	.Lhrdbf_850
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbf_854
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.Lhrdbf_860
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.Lhrdbf_855:
	movq	%rsi, hrdbf_app_pos(%rip)
.Lhrdbf_856:
	cmpq	%rax, %rsi
	jnb	.Lhrdbf_858
.Lhrdbf_866:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.Lhrdbf_859:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbf_850:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_854:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.Lhrdbf_857
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	cmpq	%rax, %rsi
	jb	.Lhrdbf_866
.Lhrdbf_858:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbf_859
	.p2align 4,,10
	.p2align 3
.Lhrdbf_860:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.Lhrdbf_855
	.p2align 4,,10
	.p2align 3
.Lhrdbf_857:
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbf_856
	.p2align 4,,10
	.p2align 3
.Lhrdbf_865:
	movq	%rdi, %rsi
	movl	$hrdbf_app_state, %edi
	jmp .Lhrdbf_entry_hrdbf_skip
.Lhrdbf_864:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C10:
	.string	"hbc: CDX direct character key field width must be <=240\n"
	.align 8
.Lhrdbf_C11:
	.string	"hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\n"
	.align 8
.Lhrdbf_C12:
	.string	"hbc: DBF index only one index is supported\n"
	.align 8
.Lhrdbf_C13:
	.string	"hbc: DBF index filename length outside supported range\n"
	.align 8
.Lhrdbf_C14:
	.string	"hbc: DBF index filename contains NUL\n"
	.align 8
.Lhrdbf_C15:
	.string	"hbc: CDX must use a different basename from DBF; structural/autoopen indexes are outside this increment\n"
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
.Lhrdbf_entry_hrdbf_app_order_add:
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
	je	.Lhrdbf_994
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_995
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.Lhrdbf_996
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_870:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.Lhrdbf_997
	movb	%dl, 32(%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %dl
	leaq	32(%rsp), %r8
	cmove	%rax, %rcx
	cmpq	%rsi, %rax
	jne	.Lhrdbf_870
	movl	hrdbf_app_cdx(%rip), %ebp
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_873
	movq	%rsi, %rdx
	movq	%rcx, %rax
	xorl	%r9d, %r9d
	movl	$1, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_875:
	cmpb	$46, (%rdi,%rax)
	cmove	%rax, %rdx
	cmove	%r10d, %r9d
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbf_875
	testl	%ebp, %ebp
	jne	.Lhrdbf_998
	testl	%r9d, %r9d
	je	.Lhrdbf_878
.Lhrdbf_930:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, 32(%rsp,%rax)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_999
	movl	$11, %r9d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r10, %rdi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1000
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_888
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_927
.Lhrdbf_892:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_888:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_893:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_893
	testq	%rax, %rax
	js	.Lhrdbf_927
	movl	$8, %r8d
	xorl	%esi, %esi
	movl	$2, %edx
	movq	%rbx, %rdi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	testq	%rax, %rax
	js	.Lhrdbf_894
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.Lhrdbf_895
	cmpl	$1, %ebp
	movq	%r12, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.Lhrdbf_895
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_898
	movq	%r12, hrdbf_app_order+48(%rip)
	xorl	%r9d, %r9d
	movq	%r13, %rdi
	movq	%r12, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.Lhrdbf_899
	movq	$0, hrdbf_app_order+32(%rip)
.Lhrdbf_900:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbf_990
	.p2align 4,,10
	.p2align 3
.Lhrdbf_998:
	movq	hrdbf_app_baselen(%rip), %r11
	subq	%rcx, %rdx
	cmpq	%r11, %rdx
	je	.Lhrdbf_931
.Lhrdbf_880:
	movq	%rsi, %rax
	testl	%r9d, %r9d
	jne	.Lhrdbf_930
.Lhrdbf_929:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	movl	$100, %eax
	movb	$99, 33(%rsp,%rsi)
.Lhrdbf_928:
	movb	%al, 32(%rsp,%rdx)
	leaq	4(%rsi), %rax
	movb	$120, 35(%rsp,%rsi)
	jmp	.Lhrdbf_930
	.p2align 4,,10
	.p2align 3
.Lhrdbf_895:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rsi, %rdx
.Lhrdbf_993:
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r10d
	testq	%rax, %rax
	js	.Lhrdbf_992
.Lhrdbf_904:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_920
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r9, %rdi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_921
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_923
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_927
.Lhrdbf_925:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_923:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbf_927
	movl	$.Lhrdbf_C10, %edi
	cmpl	$3, %r10d
	je	.Lhrdbf_891
	.p2align 4,,10
	.p2align 3
.Lhrdbf_927:
	movl	$.Lhrdbf_C11, %edi
.Lhrdbf_891:
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_999:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_888
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_892
	jmp	.Lhrdbf_927
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1000:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_927
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_927
.Lhrdbf_924:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.Lhrdbf_927
	.p2align 4,,10
	.p2align 3
.Lhrdbf_878:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	xorl	%ebp, %ebp
	movl	$116, %eax
	movb	$110, 33(%rsp,%rsi)
	jmp	.Lhrdbf_928
.Lhrdbf_921:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_927
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_924
	jmp	.Lhrdbf_927
.Lhrdbf_906:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_992:
	movl	$7, %r10d
	jmp	.Lhrdbf_904
.Lhrdbf_873:
	testl	%ebp, %ebp
	je	.Lhrdbf_878
	movq	%rsi, %r11
	subq	%rcx, %r11
	cmpq	%r11, hrdbf_app_baselen(%rip)
	jne	.Lhrdbf_929
	xorl	%r9d, %r9d
.Lhrdbf_931:
	testq	%r11, %r11
	je	.Lhrdbf_881
	movl	$1, %r10d
	xorl	%edx, %edx
	leaq	(%rdi,%rcx), %r12
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_884:
	movzbl	(%r12,%rdx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %ecx
	cmpb	$26, %dil
	cmovb	%ecx, %eax
	cmpb	%al, hrdbf_app_basename(%rdx)
	cmovne	%ebx, %r10d
	addq	$1, %rdx
	cmpq	%r11, %rdx
	jne	.Lhrdbf_884
	testl	%r10d, %r10d
	je	.Lhrdbf_880
.Lhrdbf_881:
	movl	$.Lhrdbf_C15, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_894:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_904
.Lhrdbf_920:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_923
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_925
	jmp	.Lhrdbf_927
.Lhrdbf_899:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_900
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_901
	jmp	.Lhrdbf_902
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1001:
	movq	hrdbf_app_order+32(%rip), %rsi
.Lhrdbf_901:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%r9, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_905
	testq	%rax, %rax
	jle	.Lhrdbf_906
	addq	%rax, %r8
.Lhrdbf_905:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_1001
.Lhrdbf_902:
	leaq	31(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_907:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_907
	testq	%rax, %rax
	jne	.Lhrdbf_908
	cmpl	$1, %ebp
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.Lhrdbf_910
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
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.Lhrdbf_911
	movq	$0, hrdbf_app_order+40(%rip)
.Lhrdbf_912:
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_990:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_904
	jmp	.Lhrdbf_992
.Lhrdbf_908:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_904
.Lhrdbf_898:
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_904
.Lhrdbf_910:
	movl	$3, %eax
	movq	%r12, %rsi
	movq	%r12, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_904
	jmp	.Lhrdbf_992
.Lhrdbf_911:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbf_912
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
	je	.Lhrdbf_916
	cmpl	$5, %eax
	movq	%rbx, %rdi
	movq	%r13, %rax
	movq	%r12, %rsi
	movq	%r12, %rdx
	jne	.Lhrdbf_993
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_904
	jmp	.Lhrdbf_992
	.p2align 4,,10
	.p2align 3
.Lhrdbf_916:
	movq	%r13, %rax
	movq	%rbx, %rdi
	movq	%r12, %rsi
	movq	%r12, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_992
	call .Lhrdbf_entry_hrdbf_app_top
	addq	$4136, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_997:
	movl	$.Lhrdbf_C14, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_994:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_996:
	movl	$.Lhrdbf_C13, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_995:
	movl	$.Lhrdbf_C12, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
.Lhrdbf_entry_hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1016
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1017
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r9, %rdi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1007
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1011
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1010
.Lhrdbf_1012:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1011:
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1007:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1010
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1010
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1010:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1017:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1011
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1012
	jmp	.Lhrdbf_1010
.Lhrdbf_1016:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
.Lhrdbf_entry_hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1020
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbf_1020:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C16:
	.string	"hbc: DBF index seek requires an open index\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
.Lhrdbf_entry_hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1027
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_1028
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
	call .Lhrdbf_entry_hrntx_seek
	movl	12(%rsp), %edx
	movl	hrdbf_app_order+24(%rip), %esi
	movl	%eax, %eax
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%rsi, %rcx
	movl	%edx, hrdbf_app_found_flag(%rip)
	cmpq	%rsi, %rax
	jb	.Lhrdbf_1029
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.Lhrdbf_1025:
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
.Lhrdbf_1029:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.Lhrdbf_1025
.Lhrdbf_1028:
	movl	$.Lhrdbf_C16, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1027:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1032
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_1032:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1035
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_1035:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1038
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_1038:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1041
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_1041:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1046
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1042
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_1042:
	movq	%r8, %rax
	ret
.Lhrdbf_1046:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_deleted, .-hrdbf_app_deleted
	.p2align 4
	.globl	hrdbf_app_get
	.type	hrdbf_app_get, @function
hrdbf_app_get:
.Lhrdbf_entry_hrdbf_app_get:
	endbr64
	subq	$8, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1053
	testq	%rdi, %rdi
	jle	.Lhrdbf_1051
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.Lhrdbf_1054
.Lhrdbf_1051:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1054:
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.Lhrdbf_1053:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get, .-hrdbf_app_get
	.section	.rodata.str1.1
.Lhrdbf_C17:
	.string	"\n"
	.text
	.p2align 4
	.globl	hrdbf_app_get_name
	.type	hrdbf_app_get_name, @function
hrdbf_app_get_name:
.Lhrdbf_entry_hrdbf_app_get_name:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	je	.Lhrdbf_1056
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.Lhrdbf_1058
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1069:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1059:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_1060
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_1059
.Lhrdbf_1060:
	cmpq	%rax, %r9
	je	.Lhrdbf_1081
.Lhrdbf_1062:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.Lhrdbf_1069
.Lhrdbf_1058:
	movl	$1, %ebx
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbx, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rbx, %rax
	movq	%r10, %rsi
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.Lhrdbf_C17, %esi
	movq	%rbx, %rax
	movq	%rbx, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.Lhrdbf_1081:
	testq	%r9, %r9
	je	.Lhrdbf_1063
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_1067
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1082:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.Lhrdbf_1063
.Lhrdbf_1067:
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
	je	.Lhrdbf_1082
	cmpq	%rcx, %r9
	jne	.Lhrdbf_1062
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1063:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.Lhrdbf_1083
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1083:
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1056:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C18:
	.string	"hbc: DBF scalar render rejected\n"
	.text
	.p2align 4
	.globl	hrdbf_app_render
	.type	hrdbf_app_render, @function
hrdbf_app_render:
.Lhrdbf_entry_hrdbf_app_render:
	endbr64
	subq	$24, %rsp
	movl	$256, %ecx
	movq	$0, 8(%rsp)
	leaq	8(%rsp), %r8
	call .Lhrdbf_entry_hrv_render
	testl	%eax, %eax
	jne	.Lhrdbf_1087
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_1087:
	movl	$.Lhrdbf_C18, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C19:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.Lhrdbf_C20:
	.string	"hbc: DBF scalar cannot enter I64 operation\n"
	.text
	.p2align 4
	.globl	hrdbf_app_integer
	.type	hrdbf_app_integer, @function
hrdbf_app_integer:
.Lhrdbf_entry_hrdbf_app_integer:
	endbr64
	subq	$8, %rsp
	movq	%rdi, %r9
	movq	%rsi, %r10
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1089
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_1105
	testl	%eax, %eax
	je	.Lhrdbf_1097
	cmpl	$9, %eax
	jne	.Lhrdbf_1093
.Lhrdbf_1097:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1105:
	testl	$65280, %r9d
	je	.Lhrdbf_1097
.Lhrdbf_1092:
	movl	$.Lhrdbf_C19, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1089:
	cmpl	$2, %eax
	je	.Lhrdbf_1092
.Lhrdbf_1093:
	movl	$.Lhrdbf_C20, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C21:
	.string	"hbc: DBF scalar comparison is outside this increment\n"
	.text
	.p2align 4
	.globl	hrdbf_app_equal
	.type	hrdbf_app_equal, @function
hrdbf_app_equal:
.Lhrdbf_entry_hrdbf_app_equal:
	endbr64
	subq	$24, %rsp
	leaq	12(%rsp), %r8
	call .Lhrdbf_entry_hrv_equal
	cmpl	$2, %eax
	je	.Lhrdbf_1110
	testl	%eax, %eax
	jne	.Lhrdbf_1111
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_1110:
	movl	$.Lhrdbf_C19, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1111:
	movl	$.Lhrdbf_C21, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C22:
	.string	"hbc: DBF invalid Date comparison\n"
	.text
	.p2align 4
	.globl	hrdbf_app_compare
	.type	hrdbf_app_compare, @function
hrdbf_app_compare:
.Lhrdbf_entry_hrdbf_app_compare:
	endbr64
	pushq	%rbp
	movq	%rdi, %r9
	movq	%rsi, %rbp
	movq	%rdx, %r10
	pushq	%rbx
	movq	%rcx, %r11
	subq	$8, %rsp
	cmpb	$11, %dil
	jne	.Lhrdbf_1113
	cmpb	$11, %dl
	je	.Lhrdbf_1155
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1119
.Lhrdbf_1123:
	movl	$.Lhrdbf_C20, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1119:
	cmpl	$2, %eax
	jne	.Lhrdbf_1123
.Lhrdbf_1122:
	movl	$.Lhrdbf_C19, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1113:
	movzbl	%dil, %ebx
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1119
	cmpl	$12, %ebx
	jne	.Lhrdbf_1120
	testl	$65280, %r9d
	jne	.Lhrdbf_1122
.Lhrdbf_1121:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1119
	movzbl	%r10b, %eax
	cmpb	$12, %r10b
	je	.Lhrdbf_1156
	testl	%eax, %eax
	je	.Lhrdbf_1129
	cmpl	$9, %eax
	jne	.Lhrdbf_1123
.Lhrdbf_1129:
	cmpq	%r11, %rbp
	jl	.Lhrdbf_1131
	setg	%al
	movzbl	%al, %eax
.Lhrdbf_1112:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1120:
	testl	%ebx, %ebx
	je	.Lhrdbf_1121
	cmpl	$9, %ebx
	je	.Lhrdbf_1121
	jmp	.Lhrdbf_1123
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1131:
	addq	$8, %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1155:
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1116
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1116
	cmpq	%r11, %rbp
	jb	.Lhrdbf_1131
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbf_1112
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1156:
	testl	$65280, %r10d
	je	.Lhrdbf_1129
	jmp	.Lhrdbf_1122
.Lhrdbf_1116:
	movl	$.Lhrdbf_C22, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C24:
	.string	"hbc: DBF scalar Empty rejected\n"
	.text
	.p2align 4
	.globl	hrdbf_app_empty
	.type	hrdbf_app_empty, @function
hrdbf_app_empty:
.Lhrdbf_entry_hrdbf_app_empty:
	endbr64
	movzbl	%dil, %r10d
	movq	%rsi, %r9
	leal	-2(%r10), %eax
	andl	$-3, %eax
	jne	.Lhrdbf_1158
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_1168
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1180:
	btq	%rax, %rcx
	jc	.Lhrdbf_1172
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_1168
.Lhrdbf_1160:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_1180
.Lhrdbf_1172:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1158:
	cmpl	$8, %r10d
	je	.Lhrdbf_1181
	cmpl	$5, %r10d
	je	.Lhrdbf_1182
	cmpl	$7, %r10d
	je	.Lhrdbf_1172
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1165
	cmpl	$12, %r10d
	ja	.Lhrdbf_1165
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_1166
	cmpl	$1, %r10d
	je	.Lhrdbf_1173
.Lhrdbf_1165:
	movl	$.Lhrdbf_C24, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1168:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1181:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1177
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_1177:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1182:
	testq	%rdi, %rdi
	js	.Lhrdbf_1183
.Lhrdbf_1164:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C23(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_1183:
	movq	(%rsi), %r9
	jmp	.Lhrdbf_1164
.Lhrdbf_1166:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_1157:
	addq	$8, %rsp
	ret
.Lhrdbf_1173:
	movl	$1, %eax
	jmp	.Lhrdbf_1157
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C25:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C25, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.1
.Lhrdbf_C26:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C27:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C28:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C29:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C30:
	.string	"DBF value tag or metadata invalid"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.201, @object
	.size	hrdbf_local_CSWTCH.201, 40
hrdbf_local_CSWTCH.201:
.Lhrdbf_entry_hrdbf_local_CSWTCH.201:
	.quad	.Lhrdbf_C26
	.quad	.Lhrdbf_C27
	.quad	.Lhrdbf_C28
	.quad	.Lhrdbf_C29
	.quad	.Lhrdbf_C30
	.align 8
	.type	hrdbf_local_CSWTCH.182, @object
	.size	hrdbf_local_CSWTCH.182, 13
hrdbf_local_CSWTCH.182:
.Lhrdbf_entry_hrdbf_local_CSWTCH.182:
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
	.type	hrdbf_local_days.0, @object
	.size	hrdbf_local_days.0, 48
hrdbf_local_days.0:
.Lhrdbf_entry_hrdbf_local_days.0:
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
	.type	hrdbf_local_days.1, @object
	.size	hrdbf_local_days.1, 12
hrdbf_local_days.1:
.Lhrdbf_entry_hrdbf_local_days.1:
	.ascii	"\037\034\037\036\037\036\037\037\036\037\036\037"
	.align 32
	.type	hrdbf_app_pre_field, @object
	.size	hrdbf_app_pre_field, 44
hrdbf_app_pre_field:
.Lhrdbf_entry_hrdbf_app_pre_field:
	.string	"hbc: DBF field not found in the open area: "
	.local	hrdbf_app_baselen
	.comm	hrdbf_app_baselen,8,8
	.local	hrdbf_app_basename
	.comm	hrdbf_app_basename,4096,32
	.local	hrdbf_app_cdx
	.comm	hrdbf_app_cdx,4,4
	.local	hrdbf_app_found_flag
	.comm	hrdbf_app_found_flag,4,4
	.local	hrdbf_app_pos
	.comm	hrdbf_app_pos,8,8
	.local	hrdbf_app_order
	.comm	hrdbf_app_order,64,32
	.local	hrdbf_app_state
	.comm	hrdbf_app_state,2112,32
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.Lhrdbf_C23:
	.long	0
	.long	0
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
