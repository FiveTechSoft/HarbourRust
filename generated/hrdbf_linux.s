	.text
	.p2align 4
	.type	hrdbf_local_dcat, @function
hrdbf_local_dcat:
.Lhrdbf_entry_hrdbf_local_dcat:
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	jmp	.Lhrdbf_2
	.p2align 4,,10
	.p2align 3
.Lhrdbf_4:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_3
.Lhrdbf_2:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_4
	jmp	.Lhrdbf_8
	.p2align 4,,10
	.p2align 3
.Lhrdbf_6:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.Lhrdbf_8:
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_3
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_6
.Lhrdbf_3:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_dcat, .-hrdbf_local_dcat
	.p2align 4
	.type	hrdbf_local_fset, @function
hrdbf_local_fset:
.Lhrdbf_entry_hrdbf_local_fset:
	leaq	2272(%rdi), %rax
	addq	$2431, %rdi
	jmp	.Lhrdbf_11
	.p2align 4,,10
	.p2align 3
.Lhrdbf_13:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_12
.Lhrdbf_11:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_13
.Lhrdbf_12:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_fset, .-hrdbf_local_fset
	.p2align 4
	.type	hrdbf_local_fcat, @function
hrdbf_local_fcat:
.Lhrdbf_entry_hrdbf_local_fcat:
	leaq	2272(%rdi), %rax
	addq	$2431, %rdi
	jmp	.Lhrdbf_15
	.p2align 4,,10
	.p2align 3
.Lhrdbf_17:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_16
.Lhrdbf_15:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_17
	jmp	.Lhrdbf_21
	.p2align 4,,10
	.p2align 3
.Lhrdbf_19:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.Lhrdbf_21:
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_16
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_19
.Lhrdbf_16:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_fcat, .-hrdbf_local_fcat
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
	ja	.Lhrdbf_26
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.Lhrdbf_26
	testl	$1023, %esi
	jne	.Lhrdbf_26
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.Lhrdbf_26
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
	jne	.Lhrdbf_26
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.Lhrdbf_26
	testw	%r13w, %r13w
	jne	.Lhrdbf_50
	testl	%esi, %esi
	je	.Lhrdbf_50
	.p2align 4,,10
	.p2align 3
.Lhrdbf_26:
	movl	$1, %eax
.Lhrdbf_22:
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
.Lhrdbf_50:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.Lhrdbf_31:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.Lhrdbf_26
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.Lhrdbf_26
	testw	%r11w, %r11w
	je	.Lhrdbf_28
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_30:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.Lhrdbf_29
	cmpl	%r10d, %edx
	jl	.Lhrdbf_26
.Lhrdbf_29:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.Lhrdbf_30
.Lhrdbf_28:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.Lhrdbf_31
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.Lhrdbf_32
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.Lhrdbf_66
	cmpl	%esi, %eax
	jne	.Lhrdbf_26
.Lhrdbf_32:
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
.Lhrdbf_46:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.Lhrdbf_26
	testl	%r15d, %r15d
	jne	.Lhrdbf_34
.Lhrdbf_37:
	cmpq	%r13, 8(%rsp)
	je	.Lhrdbf_35
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbf_39
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.Lhrdbf_39
	cmpl	36(%rbp), %edx
	jbe	.Lhrdbf_39
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
	jne	.Lhrdbf_39
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
	je	.Lhrdbf_40
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.Lhrdbf_41
	.p2align 4,,10
	.p2align 3
.Lhrdbf_68:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.Lhrdbf_67
.Lhrdbf_41:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.Lhrdbf_68
.Lhrdbf_39:
	movl	$4, %eax
	jmp	.Lhrdbf_22
.Lhrdbf_34:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call .Lhrdbf_entry_hrdbf_local_nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.Lhrdbf_37
	jmp	.Lhrdbf_22
	.p2align 4,,10
	.p2align 3
.Lhrdbf_67:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_49
.Lhrdbf_65:
	movq	16(%rdi), %rsi
.Lhrdbf_44:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.Lhrdbf_46
.Lhrdbf_35:
	xorl	%eax, %eax
	jmp	.Lhrdbf_22
.Lhrdbf_66:
	movl	%esi, 40(%rbp)
	jmp	.Lhrdbf_32
.Lhrdbf_49:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.Lhrdbf_45
.Lhrdbf_43:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.Lhrdbf_47
.Lhrdbf_45:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.Lhrdbf_43
	jb	.Lhrdbf_44
	jmp	.Lhrdbf_26
.Lhrdbf_40:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_65
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.Lhrdbf_47:
	cmpl	%r11d, %eax
	ja	.Lhrdbf_44
	jmp	.Lhrdbf_26
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
	ja	.Lhrdbf_69
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrdbf_69
	testl	$1023, %edx
	jne	.Lhrdbf_69
	testq	%rbp, %rbp
	je	.Lhrdbf_69
	cmpb	$0, 40(%rbp)
	je	.Lhrdbf_69
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.Lhrdbf_69
	cmpw	$0, 16(%rsi)
	jne	.Lhrdbf_69
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.Lhrdbf_72
	.p2align 4,,10
	.p2align 3
.Lhrdbf_71:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.Lhrdbf_133
.Lhrdbf_72:
	cmpq	$11, %rcx
	jbe	.Lhrdbf_71
	cmpb	$0, 538(%rax,%rcx)
	je	.Lhrdbf_71
.Lhrdbf_105:
	movl	$2, %r10d
.Lhrdbf_69:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_133:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbf_69
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.Lhrdbf_69
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.Lhrdbf_69
	movl	%esi, %ecx
	shrw	%cx
	cmpw	20(%rax), %cx
	jne	.Lhrdbf_69
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbf_73
	jmp	.Lhrdbf_69
	.p2align 4,,10
	.p2align 3
.Lhrdbf_74:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.Lhrdbf_105
.Lhrdbf_73:
	cmpb	$0, 22(%rax,%r12)
	jne	.Lhrdbf_74
	testq	%r12, %r12
	je	.Lhrdbf_105
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbf_105
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.Lhrdbf_75:
	xorl	%esi, %esi
	jmp	.Lhrdbf_84
	.p2align 4,,10
	.p2align 3
.Lhrdbf_134:
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
	jne	.Lhrdbf_77
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.Lhrdbf_76
	cmpq	$10, %rsi
	ja	.Lhrdbf_76
.Lhrdbf_84:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_134
.Lhrdbf_77:
	cmpq	%r12, %rsi
	je	.Lhrdbf_89
.Lhrdbf_81:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.Lhrdbf_75
	jmp	.Lhrdbf_105
.Lhrdbf_76:
	cmpq	%r12, %rsi
	jne	.Lhrdbf_81
	cmpq	$11, %rsi
	je	.Lhrdbf_82
.Lhrdbf_89:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.Lhrdbf_81
.Lhrdbf_82:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.Lhrdbf_105
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbf_69
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.Lhrdbf_69
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.Lhrdbf_111
	testq	%r8, %r8
	jne	.Lhrdbf_112
	testl	%ecx, %ecx
	jne	.Lhrdbf_111
.Lhrdbf_112:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.Lhrdbf_111
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.Lhrdbf_111
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.Lhrdbf_86:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.Lhrdbf_86
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
	jne	.Lhrdbf_87
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.Lhrdbf_88
	movl	$4, %r10d
.Lhrdbf_87:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_69
.Lhrdbf_88:
	movl	%eax, 24(%rbx)
	jmp	.Lhrdbf_69
.Lhrdbf_111:
	movl	$3, %r10d
	jmp	.Lhrdbf_69
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
	jne	.Lhrdbf_141
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.Lhrdbf_143
.Lhrdbf_141:
	movl	$1, %eax
.Lhrdbf_135:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_143:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.Lhrdbf_135
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.Lhrdbf_135
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.Lhrdbf_135
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.Lhrdbf_141
	cmpl	%edi, %r12d
	jb	.Lhrdbf_141
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbf_135
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
	je	.Lhrdbf_145
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_146:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.Lhrdbf_146
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
	jne	.Lhrdbf_147
	testl	%edx, %edx
	je	.Lhrdbf_147
.Lhrdbf_149:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_147:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.Lhrdbf_149
.Lhrdbf_155:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbf_149
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbf_149
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.Lhrdbf_150
	xorl	%eax, %eax
	jmp	.Lhrdbf_151
	.p2align 4,,10
	.p2align 3
.Lhrdbf_168:
	movq	(%r9), %rcx
.Lhrdbf_151:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbf_168
.Lhrdbf_150:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.Lhrdbf_154
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_153:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_153
.Lhrdbf_154:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_145:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbf_155
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
	je	.Lhrdbf_172
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.Lhrdbf_224
.Lhrdbf_172:
	movl	$1, %r12d
.Lhrdbf_169:
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
.Lhrdbf_224:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.Lhrdbf_172
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.Lhrdbf_172
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
	jne	.Lhrdbf_172
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
	je	.Lhrdbf_173
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.Lhrdbf_172
.Lhrdbf_173:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_225
	cmpl	%r8d, %ecx
	jne	.Lhrdbf_172
	cmpl	%eax, 312(%rdx)
	jne	.Lhrdbf_172
.Lhrdbf_195:
	cmpl	$-1, %r9d
	je	.Lhrdbf_177
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.Lhrdbf_172
	testl	$511, %r9d
	jne	.Lhrdbf_172
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.Lhrdbf_172
.Lhrdbf_177:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.Lhrdbf_178
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbf_226
	cmpl	%esi, %eax
	jne	.Lhrdbf_172
.Lhrdbf_180:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbf_169
	testl	%r14d, %r14d
	je	.Lhrdbf_190
	movl	%r15d, %ecx
.Lhrdbf_181:
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
	jne	.Lhrdbf_200
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbf_183
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.Lhrdbf_183
	cmpl	48(%rbx), %eax
	jbe	.Lhrdbf_183
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
	jne	.Lhrdbf_183
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
	je	.Lhrdbf_184
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.Lhrdbf_185
.Lhrdbf_228:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbf_227
	movq	%rdx, %rax
.Lhrdbf_185:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.Lhrdbf_228
.Lhrdbf_183:
	movl	$4, %r12d
	jmp	.Lhrdbf_169
	.p2align 4,,10
	.p2align 3
.Lhrdbf_225:
	cmpl	$-1, %r8d
	jne	.Lhrdbf_172
	jmp	.Lhrdbf_195
.Lhrdbf_178:
	testl	%r14d, %r14d
	je	.Lhrdbf_172
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.Lhrdbf_172
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.Lhrdbf_193:
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
	jne	.Lhrdbf_221
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.Lhrdbf_172
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
	jne	.Lhrdbf_172
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.Lhrdbf_191
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.Lhrdbf_192
	.p2align 4,,10
	.p2align 3
.Lhrdbf_229:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_191
.Lhrdbf_192:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.Lhrdbf_229
	jmp	.Lhrdbf_172
.Lhrdbf_226:
	movl	%esi, 52(%rbx)
	jmp	.Lhrdbf_180
.Lhrdbf_191:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.Lhrdbf_221
	movzwl	%r11w, %ecx
	jmp	.Lhrdbf_193
.Lhrdbf_227:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_198
.Lhrdbf_223:
	movq	16(%r11), %rcx
.Lhrdbf_188:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.Lhrdbf_190
	movzwl	%r9w, %ecx
	jmp	.Lhrdbf_181
.Lhrdbf_221:
	movl	%r10d, %r12d
	jmp	.Lhrdbf_169
.Lhrdbf_184:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbf_223
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.Lhrdbf_196:
	cmpl	%r11d, %r8d
	ja	.Lhrdbf_188
	jmp	.Lhrdbf_172
.Lhrdbf_198:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.Lhrdbf_189
.Lhrdbf_187:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.Lhrdbf_196
	movq	%r15, %rsi
.Lhrdbf_189:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.Lhrdbf_187
	jb	.Lhrdbf_188
	jmp	.Lhrdbf_172
.Lhrdbf_200:
	movl	%eax, %r12d
	jmp	.Lhrdbf_169
.Lhrdbf_190:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbf_169
	.size	hrdbf_local_cxvisit, .-hrdbf_local_cxvisit
	.p2align 4
	.type	hrdbf_local_cxheader, @function
hrdbf_local_cxheader:
.Lhrdbf_entry_hrdbf_local_cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.Lhrdbf_230
	cmpb	$1, 15(%rdi)
	jne	.Lhrdbf_230
	cmpw	$1024, 16(%rdi)
	jne	.Lhrdbf_230
	cmpw	$512, 18(%rdi)
	jne	.Lhrdbf_230
	cmpw	$0, 502(%rdi)
	jne	.Lhrdbf_230
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.Lhrdbf_233
	.p2align 4,,10
	.p2align 3
.Lhrdbf_252:
	cmpl	$23, %eax
	ja	.Lhrdbf_240
.Lhrdbf_232:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbf_251
.Lhrdbf_233:
	cmpb	$0, (%rdi,%rax)
	je	.Lhrdbf_232
	testb	%cl, %cl
	je	.Lhrdbf_252
.Lhrdbf_240:
	movl	$2, %eax
.Lhrdbf_230:
	ret
.Lhrdbf_251:
	testl	%edx, %edx
	je	.Lhrdbf_234
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_230
	cmpb	$67, 21(%rdi)
	jne	.Lhrdbf_230
	cmpb	$72, 22(%rdi)
	jne	.Lhrdbf_230
	cmpb	$66, 23(%rdi)
	jne	.Lhrdbf_230
.Lhrdbf_234:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_230
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.Lhrdbf_230
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
	je	.Lhrdbf_254
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
	js	.Lhrdbf_254
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_254:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_253
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_258
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_253:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_258:
	movl	$7, %r8d
	movl	%r8d, %eax
	ret
	.size	hrntx_file_close.constprop.0, .-hrntx_file_close.constprop.0
	.p2align 4
	.type	hrdbf_local_dset.constprop.0, @function
hrdbf_local_dset.constprop.0:
.Lhrdbf_entry_hrdbf_local_dset.constprop.0:
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	jmp	.Lhrdbf_264
	.p2align 4,,10
	.p2align 3
.Lhrdbf_266:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_265
.Lhrdbf_264:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_266
.Lhrdbf_265:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_dset.constprop.0, .-hrdbf_local_dset.constprop.0
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
	jne	.Lhrdbf_267
	orl	%eax, %edx
	movb	%dl, (%rdi)
.Lhrdbf_267:
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
	ja	.Lhrdbf_273
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.Lhrdbf_273
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.Lhrdbf_273
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.Lhrdbf_273
	cmpb	$0, 40(%rcx)
	je	.Lhrdbf_273
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_269
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.Lhrdbf_269
	cmpw	$1, 510(%r12)
	jne	.Lhrdbf_269
	cmpb	$0, 512(%r12)
	jne	.Lhrdbf_269
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.Lhrdbf_273
	testl	$511, %r10d
	jne	.Lhrdbf_273
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.Lhrdbf_273
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.Lhrdbf_269
	cmpw	$1, 2(%r12,%rdx)
	jne	.Lhrdbf_269
	cmpl	$-1, 4(%r12,%rdx)
	jne	.Lhrdbf_273
	cmpl	$-1, 8(%r12,%rdx)
	jne	.Lhrdbf_273
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbf_269
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
	jne	.Lhrdbf_269
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_273
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.Lhrdbf_273
	testl	$511, %r8d
	jne	.Lhrdbf_273
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.Lhrdbf_273
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.Lhrdbf_273
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.Lhrdbf_273
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.Lhrdbf_273
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_274
.Lhrdbf_347:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.Lhrdbf_311
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbf_346
.Lhrdbf_274:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbf_347
.Lhrdbf_311:
	movl	$2, %eax
	jmp	.Lhrdbf_269
	.p2align 4,,10
	.p2align 3
.Lhrdbf_273:
	movl	$1, %eax
.Lhrdbf_269:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_346:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_269
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbf_311
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.Lhrdbf_311
	cmpb	$0, (%r12,%rdx)
	jne	.Lhrdbf_311
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.Lhrdbf_275:
	cmpb	$0, (%rdi,%rdx)
	je	.Lhrdbf_311
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbf_275
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.Lhrdbf_276:
	cmpq	%r11, 40(%rsp)
	jbe	.Lhrdbf_311
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.Lhrdbf_285:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.Lhrdbf_279
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.Lhrdbf_280
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.Lhrdbf_280:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.Lhrdbf_281
	subl	$32, %esi
.Lhrdbf_281:
	cmpb	16(%rsp), %sil
	jne	.Lhrdbf_279
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbf_277
	cmpq	$11, %rdx
	jne	.Lhrdbf_285
	cmpq	$11, %rax
	jne	.Lhrdbf_279
.Lhrdbf_283:
	cmpl	%r11d, 36(%rsp)
	je	.Lhrdbf_311
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.Lhrdbf_311
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.Lhrdbf_310
	cmpw	12(%r12,%r9), %ax
	jne	.Lhrdbf_311
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.Lhrdbf_315
	testq	%r14, %r14
	jne	.Lhrdbf_317
	testl	%eax, %eax
	jne	.Lhrdbf_315
.Lhrdbf_317:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.Lhrdbf_315
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.Lhrdbf_315
	xorl	%edx, %edx
.Lhrdbf_287:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_287
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbf_288
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbf_288:
	testb	$2, %al
	jne	.Lhrdbf_289
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbf_289:
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
.Lhrdbf_290:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbf_290
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call .Lhrdbf_entry_hrdbf_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbf_348
.Lhrdbf_291:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_269
.Lhrdbf_277:
	cmpq	$11, %rax
	je	.Lhrdbf_283
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbf_283
.Lhrdbf_279:
	addq	$1, %r11
	jmp	.Lhrdbf_276
.Lhrdbf_315:
	movl	$3, %eax
	jmp	.Lhrdbf_269
.Lhrdbf_310:
	movl	$5, %eax
	jmp	.Lhrdbf_269
.Lhrdbf_348:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.Lhrdbf_291
	xorl	%edx, %edx
	jmp	.Lhrdbf_293
.Lhrdbf_349:
	cmpq	$63, %rdx
	ja	.Lhrdbf_318
.Lhrdbf_293:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbf_292
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.Lhrdbf_292:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbf_349
.Lhrdbf_318:
	testl	%eax, %eax
	jne	.Lhrdbf_291
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbf_269
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	hrdbf_local_fdec, @function
hrdbf_local_fdec:
.Lhrdbf_entry_hrdbf_local_fdec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabsq	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_351:
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
	jbe	.Lhrdbf_361
	cmpl	$19, %r8d
	jbe	.Lhrdbf_351
.Lhrdbf_361:
	leaq	2272(%rdi), %r10
	leaq	2431(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_359:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_353
	.p2align 4,,10
	.p2align 3
.Lhrdbf_355:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_354
.Lhrdbf_353:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_355
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_356
	jmp	.Lhrdbf_354
	.p2align 4,,10
	.p2align 3
.Lhrdbf_357:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_354
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_356:
	testb	%cl, %cl
	jne	.Lhrdbf_357
.Lhrdbf_354:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_350
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_359
.Lhrdbf_350:
	addq	$56, %rsp
	ret
	.size	hrdbf_local_fdec, .-hrdbf_local_fdec
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lhrdbf_C0:
	.string	" (errno "
	.text
	.p2align 4
	.type	hrdbf_local_ferr, @function
hrdbf_local_ferr:
.Lhrdbf_entry_hrdbf_local_ferr:
	leaq	2272(%rdi), %r11
	pushq	%rbx
	leaq	2431(%rdi), %rbx
	movq	%r11, %rax
	jmp	.Lhrdbf_369
	.p2align 4,,10
	.p2align 3
.Lhrdbf_371:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_370
.Lhrdbf_369:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_371
.Lhrdbf_370:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.Lhrdbf_373
	.p2align 4,,10
	.p2align 3
.Lhrdbf_375:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_374
.Lhrdbf_373:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_375
	cmpq	%rax, %rbx
	jbe	.Lhrdbf_374
	movl	$32, %esi
	movl	$.Lhrdbf_C0, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_376:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_374
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.Lhrdbf_376
.Lhrdbf_374:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call .Lhrdbf_entry_hrdbf_local_fdec
	jmp	.Lhrdbf_377
	.p2align 4,,10
	.p2align 3
.Lhrdbf_379:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.Lhrdbf_378
.Lhrdbf_377:
	cmpb	$0, (%r11)
	jne	.Lhrdbf_379
	cmpq	%r11, %rbx
	jbe	.Lhrdbf_378
	movb	$41, (%r11)
	addq	$1, %r11
.Lhrdbf_378:
	movb	$0, (%r11)
	popq	%rbx
	ret
	.size	hrdbf_local_ferr, .-hrdbf_local_ferr
	.p2align 4
	.type	hrdbf_local_ddec, @function
hrdbf_local_ddec:
.Lhrdbf_entry_hrdbf_local_ddec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabsq	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_385:
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
	jbe	.Lhrdbf_395
	cmpl	$19, %r8d
	jbe	.Lhrdbf_385
.Lhrdbf_395:
	leaq	2090(%rdi), %r10
	leaq	2249(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_393:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_387
	.p2align 4,,10
	.p2align 3
.Lhrdbf_389:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_388
.Lhrdbf_387:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_389
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_390
	jmp	.Lhrdbf_388
	.p2align 4,,10
	.p2align 3
.Lhrdbf_391:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_388
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_390:
	testb	%cl, %cl
	jne	.Lhrdbf_391
.Lhrdbf_388:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_384
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_393
.Lhrdbf_384:
	addq	$56, %rsp
	ret
	.size	hrdbf_local_ddec, .-hrdbf_local_ddec
	.p2align 4
	.type	hrdbf_local_dname, @function
hrdbf_local_dname:
.Lhrdbf_entry_hrdbf_local_dname:
	xorl	%r8d, %r8d
	movl	$63, %r9d
	leaq	2249(%rdi), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_403:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.Lhrdbf_402
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	2090(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.Lhrdbf_405
	.p2align 4,,10
	.p2align 3
.Lhrdbf_407:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.Lhrdbf_406
.Lhrdbf_405:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_407
	cmpq	%rdx, %rax
	jnb	.Lhrdbf_406
	movb	%cl, (%rax)
	addq	$1, %rax
.Lhrdbf_406:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.Lhrdbf_403
.Lhrdbf_402:
	ret
	.size	hrdbf_local_dname, .-hrdbf_local_dname
	.section	.rodata.str1.1
.Lhrdbf_C1:
	.string	"0123456789ABCDEF"
	.text
	.p2align 4
	.type	hrdbf_local_dhex, @function
hrdbf_local_dhex:
.Lhrdbf_entry_hrdbf_local_dhex:
	movl	%esi, %eax
	subq	$16, %rsp
	shrl	$4, %eax
	movb	$0, 15(%rsp)
	movzbl	.Lhrdbf_C1(%rax), %ecx
	leaq	2090(%rdi), %rax
	addq	$2249, %rdi
	movq	%rax, %rdx
	movb	%cl, 14(%rsp)
	jmp	.Lhrdbf_412
	.p2align 4,,10
	.p2align 3
.Lhrdbf_414:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_413
.Lhrdbf_412:
	cmpb	$0, (%rdx)
	jne	.Lhrdbf_414
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.Lhrdbf_415
	jmp	.Lhrdbf_413
	.p2align 4,,10
	.p2align 3
.Lhrdbf_417:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_413
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.Lhrdbf_415:
	testb	%cl, %cl
	jne	.Lhrdbf_417
.Lhrdbf_413:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.Lhrdbf_C1(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbf_419
	.p2align 4,,10
	.p2align 3
.Lhrdbf_421:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_420
.Lhrdbf_419:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_421
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.Lhrdbf_422
	jmp	.Lhrdbf_420
	.p2align 4,,10
	.p2align 3
.Lhrdbf_423:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_420
.Lhrdbf_422:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_423
.Lhrdbf_420:
	movb	$0, (%rax)
	addq	$16, %rsp
	ret
	.size	hrdbf_local_dhex, .-hrdbf_local_dhex
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
	je	.Lhrdbf_432
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_432:
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
	je	.Lhrdbf_435
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_435
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_437
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
.Lhrdbf_439:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_449
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_435:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_437:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_440
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_435
	.p2align 4,,10
	.p2align 3
.Lhrdbf_449:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_435
	.p2align 4,,10
	.p2align 3
.Lhrdbf_440:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_439
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
	je	.Lhrdbf_529
	testl	%esi, %esi
	je	.Lhrdbf_530
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_530
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
	ja	.Lhrdbf_530
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_533
	cmpb	$78, %r8b
	je	.Lhrdbf_534
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_535
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_476
	cmpb	$89, %dl
	je	.Lhrdbf_476
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_530
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_529
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_529
	.p2align 4,,10
	.p2align 3
.Lhrdbf_530:
	xorl	%r8d, %r8d
.Lhrdbf_529:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_476:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_533:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_529
	.p2align 4,,10
	.p2align 3
.Lhrdbf_534:
	testl	%edi, %edi
	je	.Lhrdbf_530
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_455
	.p2align 4,,10
	.p2align 3
.Lhrdbf_456:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_530
.Lhrdbf_455:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_456
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_458
	.p2align 4,,10
	.p2align 3
.Lhrdbf_482:
	movl	%edx, %edi
.Lhrdbf_458:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_457
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_482
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_502
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_480:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_460:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_487
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_479:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_464
	.p2align 4,,10
	.p2align 3
.Lhrdbf_536:
	testl	%ebx, %ebx
	jne	.Lhrdbf_503
	movl	$1, %ebx
.Lhrdbf_461:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_463
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_464:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_536
.Lhrdbf_503:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_487
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_493
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_461
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_461
	.p2align 4,,10
	.p2align 3
.Lhrdbf_535:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_473:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_495
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_473
	jmp	.Lhrdbf_530
.Lhrdbf_495:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_472:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_496
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_472
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
	jbe	.Lhrdbf_529
	cmpl	$11, %edx
	ja	.Lhrdbf_529
	testl	%edi, %edi
	je	.Lhrdbf_529
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_537
.Lhrdbf_474:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_529
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_529
.Lhrdbf_463:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_450
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_450
	leal	1(%r13), %eax
	jbe	.Lhrdbf_465
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_466
	jmp	.Lhrdbf_493
	.p2align 4,,10
	.p2align 3
.Lhrdbf_467:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_493
.Lhrdbf_466:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_467
	testl	%r12d, %r12d
	jne	.Lhrdbf_478
.Lhrdbf_469:
	movq	%r11, %rax
.Lhrdbf_470:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_450:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_493:
	movl	$4, %r8d
	jmp	.Lhrdbf_450
.Lhrdbf_457:
	je	.Lhrdbf_452
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_460
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_480
	.p2align 4,,10
	.p2align 3
.Lhrdbf_452:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_450
.Lhrdbf_487:
	movl	$5, %r8d
	jmp	.Lhrdbf_450
.Lhrdbf_502:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_479
.Lhrdbf_496:
	movl	$5, %r8d
	jmp	.Lhrdbf_529
.Lhrdbf_537:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_474
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_475
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_474
.Lhrdbf_475:
	addl	$1, %r10d
	jmp	.Lhrdbf_474
.Lhrdbf_465:
	testl	%r12d, %r12d
	je	.Lhrdbf_469
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_470
.Lhrdbf_478:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_470
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_538
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_540
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_540:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_538:
	ret
	.size	hrdbf_deleted, .-hrdbf_deleted
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.Lhrdbf_C2:
	.string	"' numeric content overflows int64"
	.align 8
.Lhrdbf_C3:
	.string	"' content is not valid for its type"
	.align 8
.Lhrdbf_C4:
	.string	"file has fewer than the 33 header bytes"
	.section	.rodata.str1.1
.Lhrdbf_C5:
	.string	"version byte 0x"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C6:
	.string	" is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)"
	.section	.rodata.str1.1
.Lhrdbf_C7:
	.string	"implausible header length "
.Lhrdbf_C8:
	.string	" or record length "
.Lhrdbf_C9:
	.string	" for file size "
.Lhrdbf_C10:
	.string	"field descriptor "
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C11:
	.string	" truncated before end of header"
	.align 8
.Lhrdbf_C12:
	.string	"more than 128 field descriptors"
	.section	.rodata.str1.1
.Lhrdbf_C13:
	.string	" has an empty name"
.Lhrdbf_C14:
	.string	"field '"
.Lhrdbf_C15:
	.string	"' has zero width"
.Lhrdbf_C16:
	.string	"C field '"
.Lhrdbf_C17:
	.string	"' declares decimals"
.Lhrdbf_C18:
	.string	"N field '"
.Lhrdbf_C19:
	.string	"' width "
.Lhrdbf_C20:
	.string	" / decimals "
.Lhrdbf_C21:
	.string	" outside supported range"
.Lhrdbf_C22:
	.string	"L field '"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C23:
	.string	"' width must be 1 with no decimals"
	.section	.rodata.str1.1
.Lhrdbf_C24:
	.string	"D field '"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C25:
	.string	"' width must be 8 with no decimals"
	.section	.rodata.str1.1
.Lhrdbf_C26:
	.string	"' has unsupported type '"
.Lhrdbf_C27:
	.string	"' (only C/N/D/L, no memo)"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C28:
	.string	"field widths exceed the 65535 record limit"
	.align 8
.Lhrdbf_C29:
	.string	"field descriptors not terminated by 0x0D"
	.section	.rodata.str1.1
.Lhrdbf_C30:
	.string	"table declares no fields"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C31:
	.string	"field widths plus delete flag sum to "
	.section	.rodata.str1.1
.Lhrdbf_C32:
	.string	" but header record length is "
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C33:
	.string	"nonzero byte between field descriptors and header end"
	.section	.rodata.str1.1
.Lhrdbf_C34:
	.string	"header record count "
.Lhrdbf_C35:
	.string	" exceeds the "
.Lhrdbf_C36:
	.string	" records physically present"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C37:
	.string	"unexpected trailing bytes after the last record (no 0x1A terminator)"
	.section	.rodata.str1.1
.Lhrdbf_C38:
	.string	"record "
.Lhrdbf_C39:
	.string	" has delete flag 0x"
.Lhrdbf_C40:
	.string	" (expected space or '*')"
.Lhrdbf_C41:
	.string	" field '"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C42:
	.string	" (logical byte must be T/F/Y/N/?/space)"
	.section	.rodata.str1.1
.Lhrdbf_C43:
	.string	" inside a deleted record"
.Lhrdbf_C44:
	.string	"duplicate field name '"
.Lhrdbf_C45:
	.string	"'"
	.text
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
	jbe	.Lhrdbf_619
	cmpb	$3, (%rsi)
	movq	%rsi, %r10
	jne	.Lhrdbf_620
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
	jbe	.Lhrdbf_547
	testl	%edi, %edi
	sete	%dl
	cmpq	%rbx, %r11
	setb	%al
	orb	%al, %dl
	je	.Lhrdbf_548
.Lhrdbf_547:
	movl	$.Lhrdbf_C7, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	(%rsp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C8, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzwl	20(%rsp), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C9, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movq	%r11, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$1, %eax
.Lhrdbf_543:
	addq	$2344, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_548:
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
.Lhrdbf_572:
	movzbl	(%rdi), %r12d
	movq	%r13, %rsi
	movzwl	8(%rsp), %ecx
	salq	$5, %rsi
	cmpb	$13, %r12b
	je	.Lhrdbf_621
	cmpq	%r13, 24(%rsp)
	je	.Lhrdbf_622
	cmpq	$129, %r13
	je	.Lhrdbf_623
	movw	%r13w, 22(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbf_556
	.p2align 4,,10
	.p2align 3
.Lhrdbf_624:
	movzbl	(%rdi,%rax), %r12d
.Lhrdbf_556:
	movb	%r12b, 42(%rbx,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_624
	movzbl	-11(%r9), %r14d
	testb	%r14b, %r14b
	je	.Lhrdbf_557
	cmpl	$1, %r13d
	jbe	.Lhrdbf_558
	leal	-1(%r13), %r12d
	xorl	%esi, %esi
	salq	$4, %r12
	.p2align 4,,10
	.p2align 3
.Lhrdbf_559:
	movq	%r15, %rax
	movl	%r14d, %edx
	jmp	.Lhrdbf_562
	.p2align 4,,10
	.p2align 3
.Lhrdbf_626:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbf_562:
	leaq	(%rax,%r8), %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.Lhrdbf_625
	cmpq	%r9, %rax
	jne	.Lhrdbf_626
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C44, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C45, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
	.p2align 4,,10
	.p2align 3
.Lhrdbf_625:
	addq	$16, %rsi
	cmpq	%r12, %rsi
	jne	.Lhrdbf_559
.Lhrdbf_558:
	movzbl	11(%rdi), %edx
	movzbl	16(%rdi), %eax
	movw	%r10w, 3(%r9)
	movzbl	17(%rdi), %ecx
	movb	%dl, (%r9)
	movb	%al, 1(%r9)
	movb	%cl, 2(%r9)
	testb	%al, %al
	je	.Lhrdbf_627
	cmpb	$67, %dl
	je	.Lhrdbf_628
	cmpb	$78, %dl
	je	.Lhrdbf_629
	cmpb	$76, %dl
	je	.Lhrdbf_630
	cmpb	$68, %dl
	jne	.Lhrdbf_569
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	je	.Lhrdbf_565
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C24, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C25, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
	.p2align 4,,10
	.p2align 3
.Lhrdbf_619:
	movl	$.Lhrdbf_C4, %esi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_620:
	movl	$.Lhrdbf_C5, %esi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movzbl	(%r10), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dhex
	movl	$.Lhrdbf_C6, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_628:
	testb	%cl, %cl
	jne	.Lhrdbf_631
.Lhrdbf_565:
	addl	%eax, %r10d
	cmpl	$65535, %r10d
	ja	.Lhrdbf_632
	addq	$1, %r13
	addq	$32, %rdi
	addq	$16, %rbx
	addq	$16, %r15
	addl	$1, 8(%rsp)
	subq	$16, %r8
	addq	$16, %r9
	movl	$1, %edx
	cmpq	%r13, 32(%rsp)
	jne	.Lhrdbf_572
	movl	$.Lhrdbf_C29, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_629:
	cmpb	$17, %cl
	ja	.Lhrdbf_589
	cmpb	%cl, %al
	ja	.Lhrdbf_565
.Lhrdbf_589:
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C18, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movslq	8(%rsp), %r11
	movq	%rbp, %rdi
	leal	2(%r11), %eax
	addq	$2, %r11
	cltq
	salq	$4, %r11
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C19, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	102(%rsp,%r11), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C20, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	103(%rsp,%r11), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C21, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$4, %eax
	jmp	.Lhrdbf_543
	.p2align 4,,10
	.p2align 3
.Lhrdbf_630:
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.Lhrdbf_565
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C22, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C23, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
	.p2align 4,,10
	.p2align 3
.Lhrdbf_622:
	leal	1(%rcx), %r8d
	movl	$1, %eax
	testb	%dl, %dl
	movl	$.Lhrdbf_C10, %esi
	movzwl	%r8w, %r8d
	movq	%rbp, %rdi
	cmove	%rax, %r8
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	%rbp, %rdi
	movq	%r8, %rsi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C11, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_623:
	movl	$.Lhrdbf_C12, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$4, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_621:
	movl	%r10d, %ebx
	movq	40(%rsp), %r10
	testb	%dl, %dl
	je	.Lhrdbf_550
	movw	%cx, 116(%rsp)
	testw	%cx, %cx
	je	.Lhrdbf_550
	addq	$1, %rsi
	cmpl	%ebx, 16(%rsp)
	je	.Lhrdbf_574
	jmp	.Lhrdbf_633
	.p2align 4,,10
	.p2align 3
.Lhrdbf_575:
	addq	$1, %rsi
	cmpb	$0, -1(%r10,%rsi)
	jne	.Lhrdbf_634
.Lhrdbf_574:
	cmpq	(%rsp), %rsi
	jb	.Lhrdbf_575
	movl	%ebx, %ecx
	movq	%r11, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%rcx
	movl	12(%rsp), %r13d
	movq	%rax, %r12
	cmpq	%rax, %r13
	ja	.Lhrdbf_635
	movq	%r13, %rax
	imulq	%rcx, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r11
	je	.Lhrdbf_577
	movq	%r11, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbf_578
	cmpb	$26, (%r10,%rax)
	je	.Lhrdbf_577
.Lhrdbf_578:
	movl	$.Lhrdbf_C37, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_557:
	movl	$.Lhrdbf_C10, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C13, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_627:
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C14, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C15, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_634:
	movl	$.Lhrdbf_C33, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_632:
	movl	$.Lhrdbf_C28, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$4, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_631:
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C16, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %eax
	movq	%rbp, %rdi
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C17, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_633:
	movl	$.Lhrdbf_C31, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	%ebx, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C32, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzwl	20(%rsp), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_550:
	movl	$.Lhrdbf_C30, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_569:
	movzwl	22(%rsp), %eax
	movl	$.Lhrdbf_C14, %esi
	movq	%rbp, %rdi
	movw	%ax, 116(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	8(%rsp), %ebx
	movq	%rbp, %rdi
	leal	2(%rbx), %eax
	cltq
	salq	$4, %rax
	leaq	90(%rsp,%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C26, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
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
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$.Lhrdbf_C27, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_577:
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
	je	.Lhrdbf_586
	movq	%rbp, (%rsp)
	movq	%rcx, %rbp
.Lhrdbf_585:
	movzbl	(%rbx), %r12d
	addq	$1, %r14
	cmpb	$32, %r12b
	je	.Lhrdbf_580
	cmpb	$42, %r12b
	jne	.Lhrdbf_636
.Lhrdbf_580:
	movq	%r14, 104(%rsp)
	movl	$1, %r15d
	jmp	.Lhrdbf_584
.Lhrdbf_581:
	addl	$1, %r15d
	cmpl	8(%rsp), %r15d
	ja	.Lhrdbf_637
.Lhrdbf_584:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	je	.Lhrdbf_581
	movq	(%rsp), %rbp
	movl	$.Lhrdbf_C38, %esi
	movl	%eax, 8(%rsp)
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	%r14, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C41, %esi
	movq	%rbp, %rdi
	leal	-1(%r15), %r10d
	call .Lhrdbf_entry_hrdbf_local_dcat
	leal	1(%r15), %edx
	movq	%rbp, %rdi
	salq	$4, %rdx
	leaq	90(%rsp,%rdx), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	8(%rsp), %eax
	movl	$.Lhrdbf_C3, %edx
	movl	$.Lhrdbf_C2, %esi
	cmpl	$4, %eax
	movl	%eax, (%rsp)
	cmovne	%rdx, %rsi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	%r10d, %edx
	movl	(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 133(%rsp,%rdx)
	je	.Lhrdbf_638
.Lhrdbf_583:
	cmpb	$42, %r12b
	jne	.Lhrdbf_543
	movl	$.Lhrdbf_C43, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	(%rsp), %eax
	jmp	.Lhrdbf_543
.Lhrdbf_637:
	addq	%rbp, %rbx
	cmpq	%r14, %r13
	jne	.Lhrdbf_585
	movq	(%rsp), %rbp
.Lhrdbf_586:
	movl	$282, %ecx
	movq	%rbp, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.Lhrdbf_543
.Lhrdbf_635:
	movl	$.Lhrdbf_C34, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C35, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movq	%r12, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C36, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_636:
	movq	(%rsp), %rbp
	movl	$.Lhrdbf_C38, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movq	%r14, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C39, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	%r12b, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dhex
	movl	$.Lhrdbf_C40, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$5, %eax
	jmp	.Lhrdbf_543
.Lhrdbf_638:
	movl	$.Lhrdbf_C42, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	(%rsp), %eax
	jmp	.Lhrdbf_583
	.size	hrdbf_open, .-hrdbf_open
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C46:
	.string	"OS open failed (missing file, permission or sharing conflict)"
	.section	.rodata.str1.1
.Lhrdbf_C47:
	.string	"OS seek failed"
.Lhrdbf_C48:
	.string	"file size "
.Lhrdbf_C49:
	.string	" exceeds the 64 MiB limit"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C50:
	.string	"out of memory snapshotting the file"
	.section	.rodata.str1.1
.Lhrdbf_C51:
	.string	"OS read failed"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C52:
	.string	"file changed size while being read"
	.text
	.p2align 4
	.type	hrdbf_file_open.part.0, @function
hrdbf_file_open.part.0:
.Lhrdbf_entry_hrdbf_file_open.part.0:
	pushq	%r13
	xorl	%r10d, %r10d
	movl	$257, %r8d
	pushq	%r12
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$24, %rsp
	cmpl	$1, %edx
	movb	$0, 2272(%rdi)
	movq	$-100, %rdi
	sbbq	%rdx, %rdx
	andq	$-2, %rdx
	addq	$524290, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_640:
	movq	%r8, %rax
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_640
	testq	%rax, %rax
	js	.Lhrdbf_680
	movl	$8, %r8d
	xorl	%ebx, %ebx
	movl	$2, %edx
	movq	%r12, %rdi
	movq	%r8, %rax
	movq	%rbx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.Lhrdbf_C47, %esi
	movq	%rax, %r13
	movq	%rax, %rdx
	testq	%rax, %rax
	js	.Lhrdbf_677
	cmpq	$32, %rax
	jle	.Lhrdbf_681
	cmpq	$67108864, %rax
	jg	.Lhrdbf_682
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_683
	movq	%r13, 2264(%rbp)
	xorl	%r9d, %r9d
	movq	%rbx, %rdi
	movq	%r13, %rsi
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
	jb	.Lhrdbf_649
	movq	$0, 2256(%rbp)
.Lhrdbf_650:
	movq	$0, 2264(%rbp)
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C50, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$8, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_678
	.p2align 4,,10
	.p2align 3
.Lhrdbf_644:
	movq	2256(%rbp), %rdi
	movq	$0, 0(%rbp)
	movq	$0, 8(%rbp)
	movl	$0, 16(%rbp)
	movq	$0, 24(%rbp)
	movl	$16842752, 36(%rbp)
	movb	$0, 40(%rbp)
	testq	%rdi, %rdi
	je	.Lhrdbf_658
	movq	2264(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_684
.Lhrdbf_658:
	movq	$0, 2256(%rbp)
	movq	$0, 2264(%rbp)
.Lhrdbf_639:
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_686:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C51, %esi
.Lhrdbf_677:
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
.Lhrdbf_676:
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.Lhrdbf_644
	.p2align 4,,10
	.p2align 3
.Lhrdbf_649:
	movq	%rax, 2256(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_650
	movq	2264(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.Lhrdbf_651
	.p2align 4,,10
	.p2align 3
.Lhrdbf_652:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_655:
	movq	%r8, %rax
	movq	%r12, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_655
	testq	%rax, %rax
	jne	.Lhrdbf_685
	movq	2264(%rbp), %rdx
	movq	2256(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	movl	%eax, %r8d
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_678
	testl	%r8d, %r8d
	jne	.Lhrdbf_644
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_687:
	movq	2256(%rbp), %rsi
.Lhrdbf_651:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%rbx, %rax
	movq	%r12, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_653
	testq	%rax, %rax
	jle	.Lhrdbf_686
	addq	%rax, %r8
.Lhrdbf_653:
	movq	2264(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_687
	jmp	.Lhrdbf_652
	.p2align 4,,10
	.p2align 3
.Lhrdbf_682:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C48, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fdec
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C49, %esi
	call .Lhrdbf_entry_hrdbf_local_fcat
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_644
	jmp	.Lhrdbf_678
.Lhrdbf_685:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C52, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_678:
	movl	$7, %r8d
	jmp	.Lhrdbf_644
	.p2align 4,,10
	.p2align 3
.Lhrdbf_681:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C4, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_644
	jmp	.Lhrdbf_678
.Lhrdbf_680:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C46, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
	movl	$7, %r8d
	jmp	.Lhrdbf_639
.Lhrdbf_683:
	movl	$.Lhrdbf_C47, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fset
	jmp	.Lhrdbf_676
.Lhrdbf_684:
	movl	$7, %r8d
	jmp	.Lhrdbf_639
	.size	hrdbf_file_open.part.0, .-hrdbf_file_open.part.0
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
	ja	.Lhrdbf_690
	je	.Lhrdbf_710
	cmpl	$5, %edx
	je	.Lhrdbf_693
	shrq	$8, %rdi
	jne	.Lhrdbf_711
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_690
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_690
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_690
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_690
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
	ja	.Lhrdbf_706
	testq	%rsi, %rsi
	je	.Lhrdbf_706
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_712
.Lhrdbf_695:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_710:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_690
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_713
.Lhrdbf_690:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_693:
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
.Lhrdbf_713:
	testb	$-1, %dh
	jne	.Lhrdbf_690
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
.Lhrdbf_711:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_706:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_712:
	testb	$3, %cl
	jne	.Lhrdbf_695
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_696
	addl	$1, %eax
	jmp	.Lhrdbf_695
.Lhrdbf_696:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_695
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
	ja	.Lhrdbf_714
	movzbl	hrdbf_local_CSWTCH.202(%rdx), %eax
.Lhrdbf_714:
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
	jne	.Lhrdbf_717
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_727
	testl	%edx, %edx
	je	.Lhrdbf_720
	cmpl	$9, %edx
	je	.Lhrdbf_720
	movl	$1, %eax
.Lhrdbf_717:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_727:
	testl	$65280, %r9d
	jne	.Lhrdbf_728
.Lhrdbf_720:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_728:
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
	jne	.Lhrdbf_729
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_729
	movzbl	%bpl, %r13d
	movzbl	%r10b, %r12d
	cmpb	$11, %bpl
	jne	.Lhrdbf_731
	cmpl	$11, %r12d
	jne	.Lhrdbf_731
.Lhrdbf_744:
	xorl	%edx, %edx
	cmpq	%r11, %r9
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_729:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_731:
	cmpl	$1, %r13d
	je	.Lhrdbf_747
	cmpl	$1, %r12d
	je	.Lhrdbf_747
	cmpl	$3, %r13d
	jne	.Lhrdbf_734
	cmpl	$3, %r12d
	jne	.Lhrdbf_734
	testq	%r9, %r9
	sete	%dl
	testq	%r11, %r11
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_747:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_734:
	movq	%rbp, %rdi
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_729
	cmpl	$12, %r13d
	je	.Lhrdbf_770
	testl	%r13d, %r13d
	je	.Lhrdbf_737
	movl	$1, %eax
	cmpl	$9, %r13d
	jne	.Lhrdbf_729
.Lhrdbf_737:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_729
	cmpl	$12, %r12d
	je	.Lhrdbf_771
	testl	%r12d, %r12d
	je	.Lhrdbf_744
	cmpl	$9, %r12d
	je	.Lhrdbf_744
	movl	$1, %eax
	jmp	.Lhrdbf_729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_770:
	testl	$65280, %ebp
	je	.Lhrdbf_737
.Lhrdbf_743:
	movl	$2, %eax
	jmp	.Lhrdbf_729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_771:
	testl	$65280, %r10d
	je	.Lhrdbf_744
	jmp	.Lhrdbf_743
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
	jne	.Lhrdbf_772
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_776
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_774
	cmpl	$1, %ecx
	je	.Lhrdbf_777
.Lhrdbf_776:
	movl	$1, %eax
.Lhrdbf_772:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_774:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_777:
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
	jne	.Lhrdbf_778
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_825
	cmpl	$12, %eax
	jne	.Lhrdbf_804
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
.Lhrdbf_786:
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
	ja	.Lhrdbf_786
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_826
	movl	$1, %esi
.Lhrdbf_787:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_788:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_789
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_827
	subl	%eax, %r14d
	je	.Lhrdbf_797
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_796:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_796
.Lhrdbf_797:
	testq	%r11, %r11
	jns	.Lhrdbf_795
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_795:
	testl	%esi, %esi
	je	.Lhrdbf_798
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_800
	.p2align 4,,10
	.p2align 3
.Lhrdbf_808:
	movl	%edx, %eax
.Lhrdbf_800:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_799
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_799:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_808
	addl	%esi, %r14d
.Lhrdbf_798:
	testl	%r10d, %r10d
	je	.Lhrdbf_778
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_802:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_801
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_801:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_802
.Lhrdbf_778:
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
.Lhrdbf_825:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_789
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_782
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_784:
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
	jne	.Lhrdbf_784
	jmp	.Lhrdbf_778
	.p2align 4,,10
	.p2align 3
.Lhrdbf_804:
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
.Lhrdbf_826:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_787
	movl	%esi, %eax
	jmp	.Lhrdbf_788
	.p2align 4,,10
	.p2align 3
.Lhrdbf_789:
	movl	$3, %r8d
	jmp	.Lhrdbf_778
	.p2align 4,,10
	.p2align 3
.Lhrdbf_782:
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
	jmp	.Lhrdbf_778
	.p2align 4,,10
	.p2align 3
.Lhrdbf_827:
	testl	%r14d, %r14d
	je	.Lhrdbf_778
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_792:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_792
	jmp	.Lhrdbf_778
	.size	hrv_render, .-hrv_render
	.section	.rodata.str1.1
.Lhrdbf_C53:
	.string	"DBF unknown value error"
	.text
	.p2align 4
	.globl	hrv_error_name
	.type	hrv_error_name, @function
hrv_error_name:
.Lhrdbf_entry_hrv_error_name:
	endbr64
	movl	$.Lhrdbf_C53, %eax
	cmpl	$4, %edi
	ja	.Lhrdbf_828
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.221(,%rdi,8), %rax
.Lhrdbf_828:
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
	movq	2256(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_834
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_835
.Lhrdbf_834:
	movq	$0, 2256(%r8)
	xorl	%eax, %eax
	movq	$0, 2264(%r8)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_835:
	movl	$7, %eax
	ret
	.size	hrdbf_file_close, .-hrdbf_file_close
	.p2align 4
	.type	hrdbf_app_exit, @function
hrdbf_app_exit:
.Lhrdbf_entry_hrdbf_app_exit:
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movl	$1, %edi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	.size	hrdbf_app_exit, .-hrdbf_app_exit
	.p2align 4
	.type	hrdbf_app_fail, @function
hrdbf_app_fail:
.Lhrdbf_entry_hrdbf_app_fail:
	xorl	%edx, %edx
	cmpb	$0, (%rdi)
	movq	%rdi, %rsi
	je	.Lhrdbf_838
	.p2align 4,,10
	.p2align 3
.Lhrdbf_839:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_839
.Lhrdbf_838:
	movl	$1, %eax
	movl	$2, %edi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrdbf_app_exit
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C54:
	.string	"hbc: DBF field decoding failed\n"
	.align 8
.Lhrdbf_C55:
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
	jne	.Lhrdbf_856
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_857
	cmpb	$78, %al
	je	.Lhrdbf_858
	cmpb	$68, %al
	je	.Lhrdbf_859
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_857:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_860
.Lhrdbf_845:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_861
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_859:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_858:
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
.Lhrdbf_860:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_848
	.p2align 4,,10
	.p2align 3
.Lhrdbf_847:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_847
.Lhrdbf_848:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_845
.Lhrdbf_856:
	movl	$.Lhrdbf_C54, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_861:
	movl	$.Lhrdbf_C55, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
.Lhrdbf_entry_hrdbf_file_open:
	endbr64
	movb	$0, 2272(%rdi)
	movq	%rdi, %r8
	movq	%rsi, %r9
	movl	%edx, %r10d
	movq	$0, (%rdi)
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movq	2256(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_864
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_865
.Lhrdbf_864:
	movl	%r10d, %edx
	movq	%r9, %rsi
	movq	%r8, %rdi
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
	jmp .Lhrdbf_entry_hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_865:
	movl	$7, %eax
	ret
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
	je	.Lhrdbf_868
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_873:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_886
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_872
	.p2align 4,,10
	.p2align 3
.Lhrdbf_870:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_886
.Lhrdbf_872:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.Lhrdbf_870
	jnb	.Lhrdbf_886
	leal	1(%rdi), %r10d
.Lhrdbf_869:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_873
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_877
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.Lhrdbf_876:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.Lhrdbf_878
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_879
	.p2align 4,,10
	.p2align 3
.Lhrdbf_911:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_878
.Lhrdbf_879:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.Lhrdbf_911
.Lhrdbf_877:
	testl	%ebp, %ebp
	je	.Lhrdbf_867
	testl	%r12d, %r12d
	jne	.Lhrdbf_912
	movl	%r10d, %r11d
.Lhrdbf_867:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_886:
	movl	%edi, %r11d
	jmp	.Lhrdbf_869
.Lhrdbf_878:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.Lhrdbf_867
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_880
	.p2align 4,,10
	.p2align 3
.Lhrdbf_885:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_881
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_884
	.p2align 4,,10
	.p2align 3
.Lhrdbf_882:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_881
.Lhrdbf_884:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.Lhrdbf_882
	jb	.Lhrdbf_881
	movl	%edi, %r11d
.Lhrdbf_883:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_885
.Lhrdbf_880:
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
.Lhrdbf_881:
	leal	1(%rdi), %r10d
	jmp	.Lhrdbf_883
.Lhrdbf_912:
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
.Lhrdbf_868:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_867
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.Lhrdbf_876
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata.str1.1
.Lhrdbf_C56:
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
	je	.Lhrdbf_914
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
	js	.Lhrdbf_914
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_914:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_915
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_923
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_915:
	movq	hrdbf_app_state+2256(%rip), %rdi
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_920
	movq	hrdbf_app_state+2264(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_929
.Lhrdbf_920:
	movq	$0, hrdbf_app_state+2256(%rip)
	movq	$0, hrdbf_app_state+2264(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%r8d, %r8d
	jne	.Lhrdbf_917
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_923:
	movl	$7, %r8d
	jmp	.Lhrdbf_915
.Lhrdbf_929:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbf_917:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata.str1.1
.Lhrdbf_C57:
	.string	"table format not supported"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C58:
	.string	"hbc: DBF only one workarea is supported\n"
	.align 8
.Lhrdbf_C59:
	.string	"hbc: DBF filename length outside supported range\n"
	.align 8
.Lhrdbf_C60:
	.string	"hbc: DBF filename contains NUL\n"
	.section	.rodata.str1.1
.Lhrdbf_C61:
	.string	"hbc: DBF index close failed\n"
.Lhrdbf_C62:
	.string	"hbc: DBF open rejected: "
.Lhrdbf_C63:
	.string	"\n"
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
	je	.Lhrdbf_931
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_980
.Lhrdbf_931:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_981
	xorl	%r9d, %r9d
	jmp	.Lhrdbf_932
	.p2align 4,,10
	.p2align 3
.Lhrdbf_961:
	movq	%r10, %r9
.Lhrdbf_932:
	movzbl	(%rbx,%r9), %eax
	testb	%al, %al
	je	.Lhrdbf_982
	leaq	1(%r9), %r10
	movb	%al, (%rsp,%r9)
	cmpq	%r10, %rsi
	jne	.Lhrdbf_961
	movq	hrdbf_app_order+32(%rip), %r13
	movb	$0, (%rsp,%r10)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r13, %r13
	je	.Lhrdbf_983
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
	js	.Lhrdbf_984
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_940
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_941
.Lhrdbf_942:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_940:
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
.Lhrdbf_944:
	movzbl	(%rbx,%rax), %esi
	movq	%rax, %rdx
	addq	$1, %rax
	cmpb	$47, %sil
	cmove	%rax, %rcx
	cmpq	%rdx, %r9
	jne	.Lhrdbf_944
	cmpq	%r10, %rcx
	jnb	.Lhrdbf_945
	movq	%rcx, %rax
	jmp	.Lhrdbf_947
	.p2align 4,,10
	.p2align 3
.Lhrdbf_962:
	movq	%rdx, %rax
.Lhrdbf_947:
	cmpb	$46, (%rbx,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %r10
	cmpq	%r9, %rax
	jne	.Lhrdbf_962
.Lhrdbf_945:
	subq	%rcx, %r10
	leaq	(%rbx,%rcx), %rdi
	movl	$0, %edx
	movq	%r10, hrdbf_app_baselen(%rip)
	je	.Lhrdbf_952
	.p2align 4,,10
	.p2align 3
.Lhrdbf_948:
	movzbl	(%rdi,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rdx, %r10
	jne	.Lhrdbf_948
.Lhrdbf_952:
	testq	%r8, %r8
	movq	hrdbf_app_state+2256(%rip), %rdi
	movb	$0, hrdbf_app_state+2272(%rip)
	setne	%r8b
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movzbl	%r8b, %r8d
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_950
	movq	hrdbf_app_state+2264(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_985
.Lhrdbf_950:
	movl	%r8d, %edx
	movq	%rsp, %rsi
	movl	$hrdbf_app_state, %edi
	movq	$0, hrdbf_app_state+2256(%rip)
	movq	$0, hrdbf_app_state+2264(%rip)
	call .Lhrdbf_entry_hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbf_953
	addq	$4104, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_984:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_941
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_941
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_941:
	movl	$.Lhrdbf_C61, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_983:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_940
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_942
	jmp	.Lhrdbf_941
.Lhrdbf_985:
	movl	$7, %eax
.Lhrdbf_953:
	cmpb	$0, hrdbf_app_state+2272(%rip)
	movl	$hrdbf_app_state+2272, %r8d
	movl	$hrdbf_app_state+2090, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.Lhrdbf_956
	subl	$2, %eax
	movl	$.Lhrdbf_C57, %r8d
	cmpl	$6, %eax
	ja	.Lhrdbf_956
	movq	hrdbf_local_CSWTCH.244(,%rax,8), %r8
.Lhrdbf_956:
	xorl	%edx, %edx
.Lhrdbf_957:
	addq	$1, %rdx
	cmpb	$0, .Lhrdbf_C62(%rdx)
	jne	.Lhrdbf_957
	movl	$1, %eax
	movl	$2, %edi
	movl	$.Lhrdbf_C62, %esi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.Lhrdbf_958
.Lhrdbf_959:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.Lhrdbf_959
.Lhrdbf_958:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.Lhrdbf_C63, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbf_982:
	movl	$.Lhrdbf_C60, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_981:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_980:
	movl	$.Lhrdbf_C58, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.section	.rodata.str1.1
.Lhrdbf_C64:
	.string	"hbc: DBF no workarea is open\n"
	.text
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_992
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_993
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbf_994
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbf_991:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_994:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbf_991
	.p2align 4,,10
	.p2align 3
.Lhrdbf_993:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbf_992:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
.Lhrdbf_entry_hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1003
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1004
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rax
	testl	%esi, %esi
	jne	.Lhrdbf_1005
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.Lhrdbf_1000:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
.Lhrdbf_1001:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%eax, %eax
	sete	%al
.Lhrdbf_998:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1005:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_1000
	movq	hrdbf_app_order+16(%rip), %rdx
	movl	(%rdx,%rcx,8), %edx
	jmp	.Lhrdbf_1001
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1004:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmovne	%rax, %rdx
	sete	%al
	movl	%eax, %ecx
	jmp	.Lhrdbf_998
.Lhrdbf_1003:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1020
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1021
	testq	%rdi, %rdi
	je	.Lhrdbf_1006
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbf_1010
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.Lhrdbf_1016
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.Lhrdbf_1011:
	movq	%rsi, hrdbf_app_pos(%rip)
.Lhrdbf_1012:
	cmpq	%rax, %rsi
	jnb	.Lhrdbf_1014
.Lhrdbf_1022:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.Lhrdbf_1015:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbf_1006:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1010:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.Lhrdbf_1013
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	cmpq	%rax, %rsi
	jb	.Lhrdbf_1022
.Lhrdbf_1014:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbf_1015
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1016:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.Lhrdbf_1011
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1013:
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbf_1012
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1021:
	movq	%rdi, %rsi
	movl	$hrdbf_app_state, %edi
	jmp .Lhrdbf_entry_hrdbf_skip
.Lhrdbf_1020:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C65:
	.string	"hbc: CDX direct character key field width must be <=240\n"
	.align 8
.Lhrdbf_C66:
	.string	"hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\n"
	.align 8
.Lhrdbf_C67:
	.string	"hbc: DBF index only one index is supported\n"
	.align 8
.Lhrdbf_C68:
	.string	"hbc: DBF index filename length outside supported range\n"
	.align 8
.Lhrdbf_C69:
	.string	"hbc: DBF index filename contains NUL\n"
	.align 8
.Lhrdbf_C70:
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
	je	.Lhrdbf_1150
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_1151
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.Lhrdbf_1152
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1026:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.Lhrdbf_1153
	movb	%dl, 32(%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %dl
	leaq	32(%rsp), %r8
	cmove	%rax, %rcx
	cmpq	%rsi, %rax
	jne	.Lhrdbf_1026
	movl	hrdbf_app_cdx(%rip), %ebp
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_1029
	movq	%rsi, %rdx
	movq	%rcx, %rax
	xorl	%r9d, %r9d
	movl	$1, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1031:
	cmpb	$46, (%rdi,%rax)
	cmove	%rax, %rdx
	cmove	%r10d, %r9d
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbf_1031
	testl	%ebp, %ebp
	jne	.Lhrdbf_1154
	testl	%r9d, %r9d
	je	.Lhrdbf_1034
.Lhrdbf_1086:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, 32(%rsp,%rax)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_1155
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
	js	.Lhrdbf_1156
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1044
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1083
.Lhrdbf_1048:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1044:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1049:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_1049
	testq	%rax, %rax
	js	.Lhrdbf_1083
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
	js	.Lhrdbf_1050
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.Lhrdbf_1051
	cmpl	$1, %ebp
	movq	%r12, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.Lhrdbf_1051
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1054
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
	jb	.Lhrdbf_1055
	movq	$0, hrdbf_app_order+32(%rip)
.Lhrdbf_1056:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbf_1146
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1154:
	movq	hrdbf_app_baselen(%rip), %r11
	subq	%rcx, %rdx
	cmpq	%r11, %rdx
	je	.Lhrdbf_1087
.Lhrdbf_1036:
	movq	%rsi, %rax
	testl	%r9d, %r9d
	jne	.Lhrdbf_1086
.Lhrdbf_1085:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	movl	$100, %eax
	movb	$99, 33(%rsp,%rsi)
.Lhrdbf_1084:
	movb	%al, 32(%rsp,%rdx)
	leaq	4(%rsi), %rax
	movb	$120, 35(%rsp,%rsi)
	jmp	.Lhrdbf_1086
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1051:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rsi, %rdx
.Lhrdbf_1149:
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r10d
	testq	%rax, %rax
	js	.Lhrdbf_1148
.Lhrdbf_1060:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1076
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
	js	.Lhrdbf_1077
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1079
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1083
.Lhrdbf_1081:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1079:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbf_1083
	movl	$.Lhrdbf_C65, %edi
	cmpl	$3, %r10d
	je	.Lhrdbf_1047
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1083:
	movl	$.Lhrdbf_C66, %edi
.Lhrdbf_1047:
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1155:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1044
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1048
	jmp	.Lhrdbf_1083
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1156:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1083
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1083
.Lhrdbf_1080:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.Lhrdbf_1083
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1034:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	xorl	%ebp, %ebp
	movl	$116, %eax
	movb	$110, 33(%rsp,%rsi)
	jmp	.Lhrdbf_1084
.Lhrdbf_1077:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1083
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1080
	jmp	.Lhrdbf_1083
.Lhrdbf_1062:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_1148:
	movl	$7, %r10d
	jmp	.Lhrdbf_1060
.Lhrdbf_1029:
	testl	%ebp, %ebp
	je	.Lhrdbf_1034
	movq	%rsi, %r11
	subq	%rcx, %r11
	cmpq	%r11, hrdbf_app_baselen(%rip)
	jne	.Lhrdbf_1085
	xorl	%r9d, %r9d
.Lhrdbf_1087:
	testq	%r11, %r11
	je	.Lhrdbf_1037
	movl	$1, %r10d
	xorl	%edx, %edx
	leaq	(%rdi,%rcx), %r12
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1040:
	movzbl	(%r12,%rdx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %ecx
	cmpb	$26, %dil
	cmovb	%ecx, %eax
	cmpb	%al, hrdbf_app_basename(%rdx)
	cmovne	%ebx, %r10d
	addq	$1, %rdx
	cmpq	%r11, %rdx
	jne	.Lhrdbf_1040
	testl	%r10d, %r10d
	je	.Lhrdbf_1036
.Lhrdbf_1037:
	movl	$.Lhrdbf_C70, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1050:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1060
.Lhrdbf_1076:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1079
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1081
	jmp	.Lhrdbf_1083
.Lhrdbf_1055:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_1056
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_1057
	jmp	.Lhrdbf_1058
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1157:
	movq	hrdbf_app_order+32(%rip), %rsi
.Lhrdbf_1057:
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
	je	.Lhrdbf_1061
	testq	%rax, %rax
	jle	.Lhrdbf_1062
	addq	%rax, %r8
.Lhrdbf_1061:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_1157
.Lhrdbf_1058:
	leaq	31(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1063:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_1063
	testq	%rax, %rax
	jne	.Lhrdbf_1064
	cmpl	$1, %ebp
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.Lhrdbf_1066
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
	jb	.Lhrdbf_1067
	movq	$0, hrdbf_app_order+40(%rip)
.Lhrdbf_1068:
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1146:
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
	jns	.Lhrdbf_1060
	jmp	.Lhrdbf_1148
.Lhrdbf_1064:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1060
.Lhrdbf_1054:
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1060
.Lhrdbf_1066:
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
	jns	.Lhrdbf_1060
	jmp	.Lhrdbf_1148
.Lhrdbf_1067:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbf_1068
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
	je	.Lhrdbf_1072
	cmpl	$5, %eax
	movq	%rbx, %rdi
	movq	%r13, %rax
	movq	%r12, %rsi
	movq	%r12, %rdx
	jne	.Lhrdbf_1149
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_1060
	jmp	.Lhrdbf_1148
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1072:
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
	js	.Lhrdbf_1148
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
.Lhrdbf_1153:
	movl	$.Lhrdbf_C69, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1150:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1152:
	movl	$.Lhrdbf_C68, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1151:
	movl	$.Lhrdbf_C67, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
.Lhrdbf_entry_hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1172
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1173
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
	js	.Lhrdbf_1163
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1167
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1166
.Lhrdbf_1168:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1167:
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1163:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1166
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1166
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1166:
	movl	$.Lhrdbf_C61, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1173:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1167
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1168
	jmp	.Lhrdbf_1166
.Lhrdbf_1172:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
.Lhrdbf_entry_hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1176
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbf_1176:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C71:
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
	je	.Lhrdbf_1183
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_1184
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
	jb	.Lhrdbf_1185
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.Lhrdbf_1181:
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
.Lhrdbf_1185:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.Lhrdbf_1181
.Lhrdbf_1184:
	movl	$.Lhrdbf_C71, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1183:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1188
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_1188:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1191
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_1191:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1194
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_1194:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1197
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_1197:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1202
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1198
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_1198:
	movq	%r8, %rax
	ret
.Lhrdbf_1202:
	movl	$.Lhrdbf_C64, %edi
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
	je	.Lhrdbf_1209
	testq	%rdi, %rdi
	jle	.Lhrdbf_1207
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.Lhrdbf_1210
.Lhrdbf_1207:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1210:
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.Lhrdbf_1209:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get, .-hrdbf_app_get
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
	je	.Lhrdbf_1212
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.Lhrdbf_1214
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1225:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1215:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_1216
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_1215
.Lhrdbf_1216:
	cmpq	%rax, %r9
	je	.Lhrdbf_1237
.Lhrdbf_1218:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.Lhrdbf_1225
.Lhrdbf_1214:
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
	movl	$.Lhrdbf_C63, %esi
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
.Lhrdbf_1237:
	testq	%r9, %r9
	je	.Lhrdbf_1219
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_1223
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1238:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.Lhrdbf_1219
.Lhrdbf_1223:
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
	je	.Lhrdbf_1238
	cmpq	%rcx, %r9
	jne	.Lhrdbf_1218
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1219:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.Lhrdbf_1239
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1239:
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1212:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C72:
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
	jne	.Lhrdbf_1243
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_1243:
	movl	$.Lhrdbf_C72, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C73:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.Lhrdbf_C74:
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
	jne	.Lhrdbf_1245
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_1261
	testl	%eax, %eax
	je	.Lhrdbf_1253
	cmpl	$9, %eax
	jne	.Lhrdbf_1249
.Lhrdbf_1253:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1261:
	testl	$65280, %r9d
	je	.Lhrdbf_1253
.Lhrdbf_1248:
	movl	$.Lhrdbf_C73, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1245:
	cmpl	$2, %eax
	je	.Lhrdbf_1248
.Lhrdbf_1249:
	movl	$.Lhrdbf_C74, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C75:
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
	je	.Lhrdbf_1266
	testl	%eax, %eax
	jne	.Lhrdbf_1267
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_1266:
	movl	$.Lhrdbf_C73, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1267:
	movl	$.Lhrdbf_C75, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C76:
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
	jne	.Lhrdbf_1269
	cmpb	$11, %dl
	je	.Lhrdbf_1311
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1275
.Lhrdbf_1279:
	movl	$.Lhrdbf_C74, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1275:
	cmpl	$2, %eax
	jne	.Lhrdbf_1279
.Lhrdbf_1278:
	movl	$.Lhrdbf_C73, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1269:
	movzbl	%dil, %ebx
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1275
	cmpl	$12, %ebx
	jne	.Lhrdbf_1276
	testl	$65280, %r9d
	jne	.Lhrdbf_1278
.Lhrdbf_1277:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1275
	movzbl	%r10b, %eax
	cmpb	$12, %r10b
	je	.Lhrdbf_1312
	testl	%eax, %eax
	je	.Lhrdbf_1285
	cmpl	$9, %eax
	jne	.Lhrdbf_1279
.Lhrdbf_1285:
	cmpq	%r11, %rbp
	jl	.Lhrdbf_1287
	setg	%al
	movzbl	%al, %eax
.Lhrdbf_1268:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1276:
	testl	%ebx, %ebx
	je	.Lhrdbf_1277
	cmpl	$9, %ebx
	je	.Lhrdbf_1277
	jmp	.Lhrdbf_1279
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1287:
	addq	$8, %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1311:
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1272
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1272
	cmpq	%r11, %rbp
	jb	.Lhrdbf_1287
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbf_1268
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1312:
	testl	$65280, %r10d
	je	.Lhrdbf_1285
	jmp	.Lhrdbf_1278
.Lhrdbf_1272:
	movl	$.Lhrdbf_C76, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C78:
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
	jne	.Lhrdbf_1314
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_1324
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_1316
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1336:
	btq	%rax, %rcx
	jc	.Lhrdbf_1328
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_1324
.Lhrdbf_1316:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_1336
.Lhrdbf_1328:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1314:
	cmpl	$8, %r10d
	je	.Lhrdbf_1337
	cmpl	$5, %r10d
	je	.Lhrdbf_1338
	cmpl	$7, %r10d
	je	.Lhrdbf_1328
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1321
	cmpl	$12, %r10d
	ja	.Lhrdbf_1321
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_1322
	cmpl	$1, %r10d
	je	.Lhrdbf_1329
.Lhrdbf_1321:
	movl	$.Lhrdbf_C78, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1324:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1337:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1333
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_1333:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1338:
	testq	%rdi, %rdi
	js	.Lhrdbf_1339
.Lhrdbf_1320:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C77(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_1339:
	movq	(%rsi), %r9
	jmp	.Lhrdbf_1320
.Lhrdbf_1322:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_1313:
	addq	$8, %rsp
	ret
.Lhrdbf_1329:
	movl	$1, %eax
	jmp	.Lhrdbf_1313
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C79:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C79, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C80:
	.string	"unsupported table version or header flags"
	.section	.rodata.str1.1
.Lhrdbf_C81:
	.string	"unsupported field type"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C82:
	.string	"size or field-count limit exceeded"
	.section	.rodata.str1.1
.Lhrdbf_C83:
	.string	"record content invalid"
.Lhrdbf_C84:
	.string	"I/O error"
.Lhrdbf_C85:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.244, @object
	.size	hrdbf_local_CSWTCH.244, 56
hrdbf_local_CSWTCH.244:
.Lhrdbf_entry_hrdbf_local_CSWTCH.244:
	.quad	.Lhrdbf_C80
	.quad	.Lhrdbf_C81
	.quad	.Lhrdbf_C82
	.quad	.Lhrdbf_C83
	.quad	.Lhrdbf_C57
	.quad	.Lhrdbf_C84
	.quad	.Lhrdbf_C85
	.section	.rodata.str1.1
.Lhrdbf_C86:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C87:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C88:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C89:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C90:
	.string	"DBF value tag or metadata invalid"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.221, @object
	.size	hrdbf_local_CSWTCH.221, 40
hrdbf_local_CSWTCH.221:
.Lhrdbf_entry_hrdbf_local_CSWTCH.221:
	.quad	.Lhrdbf_C86
	.quad	.Lhrdbf_C87
	.quad	.Lhrdbf_C88
	.quad	.Lhrdbf_C89
	.quad	.Lhrdbf_C90
	.align 8
	.type	hrdbf_local_CSWTCH.202, @object
	.size	hrdbf_local_CSWTCH.202, 13
hrdbf_local_CSWTCH.202:
.Lhrdbf_entry_hrdbf_local_CSWTCH.202:
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
	.comm	hrdbf_app_state,2432,32
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.Lhrdbf_C77:
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
