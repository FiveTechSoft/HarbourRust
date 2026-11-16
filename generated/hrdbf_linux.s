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
	.type	hrdbf_local_bn_shl, @function
hrdbf_local_bn_shl:
.Lhrdbf_entry_hrdbf_local_bn_shl:
	pushq	%r12
	movl	%esi, %r10d
	pushq	%rbp
	shrl	$5, %r10d
	pushq	%rbx
	movl	288(%rdi), %r12d
	leal	(%r12,%r10), %r8d
	cmpl	$71, %r8d
	ja	.Lhrdbf_10
	movl	%esi, %ebp
	movq	%rdi, %rdx
	movl	%esi, %r9d
	andl	$31, %ebp
	je	.Lhrdbf_13
	testl	%r12d, %r12d
	je	.Lhrdbf_14
	movl	$32, %r11d
	leal	-1(%r12), %ecx
	movq	%rdi, %rax
	xorl	%r8d, %r8d
	subl	%ebp, %r11d
	leaq	4(%rdi,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_15:
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
	jne	.Lhrdbf_15
	testl	%edi, %edi
	je	.Lhrdbf_19
	leal	1(%r12), %eax
	movl	%eax, 288(%rdx)
	movl	%edi, (%rdx,%r12,4)
.Lhrdbf_19:
	cmpl	$31, %r9d
	jbe	.Lhrdbf_10
	movl	288(%rdx), %r8d
	leal	-1(%r8), %ecx
	addl	%r10d, %r8d
	jmp	.Lhrdbf_24
	.p2align 4,,10
	.p2align 3
.Lhrdbf_13:
	cmpl	$31, %esi
	jbe	.Lhrdbf_10
	leal	-1(%r12), %ecx
	testl	%r12d, %r12d
	je	.Lhrdbf_17
.Lhrdbf_24:
	movl	%ecx, %eax
	addl	%r10d, %ecx
	leaq	(%rdx,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_20:
	movl	(%rax), %edi
	movl	%ecx, %esi
	subl	$1, %ecx
	movl	%edi, (%rdx,%rsi,4)
	movq	%rax, %rsi
	subq	$4, %rax
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_20
.Lhrdbf_17:
	testl	%r10d, %r10d
	je	.Lhrdbf_23
	leal	-1(%r10), %ecx
	movq	%rdx, %rax
	leaq	4(%rdx,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_22:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_22
.Lhrdbf_23:
	movl	%r8d, 288(%rdx)
.Lhrdbf_10:
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_14:
	cmpl	$31, %esi
	jbe	.Lhrdbf_10
	movl	%r10d, %r8d
	jmp	.Lhrdbf_17
	.size	hrdbf_local_bn_shl, .-hrdbf_local_bn_shl
	.p2align 4
	.type	hrdbf_local_bn_divmod_1e9, @function
hrdbf_local_bn_divmod_1e9:
.Lhrdbf_entry_hrdbf_local_bn_divmod_1e9:
	pushq	%rbx
	movl	288(%rdi), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbf_43
	movabs	$19342813113834067, %r11
	movq	%rdi, %r9
	leal	-1(%rbx), %edi
	movl	%edi, %eax
	leaq	(%r9,%rax,4), %r8
	xorl	%eax, %eax
	movq	%r8, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_40:
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
	jne	.Lhrdbf_40
	cmpl	$1, %ebx
	jne	.Lhrdbf_41
	jmp	.Lhrdbf_38
	.p2align 4,,10
	.p2align 3
.Lhrdbf_42:
	movl	%edi, 288(%r9)
	subq	$4, %r8
	subl	$1, %edi
	je	.Lhrdbf_38
.Lhrdbf_41:
	movl	(%r8), %edx
	testl	%edx, %edx
	je	.Lhrdbf_42
.Lhrdbf_38:
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_43:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.size	hrdbf_local_bn_divmod_1e9, .-hrdbf_local_bn_divmod_1e9
	.p2align 4
	.type	hrdbf_local_fset, @function
hrdbf_local_fset:
.Lhrdbf_entry_hrdbf_local_fset:
	leaq	2289(%rdi), %rax
	addq	$2448, %rdi
	jmp	.Lhrdbf_51
	.p2align 4,,10
	.p2align 3
.Lhrdbf_53:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_52
.Lhrdbf_51:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_53
.Lhrdbf_52:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_fset, .-hrdbf_local_fset
	.p2align 4
	.type	hrdbf_local_fcat, @function
hrdbf_local_fcat:
.Lhrdbf_entry_hrdbf_local_fcat:
	leaq	2289(%rdi), %rax
	addq	$2448, %rdi
	jmp	.Lhrdbf_55
	.p2align 4,,10
	.p2align 3
.Lhrdbf_57:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_56
.Lhrdbf_55:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_57
	jmp	.Lhrdbf_61
	.p2align 4,,10
	.p2align 3
.Lhrdbf_59:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.Lhrdbf_61:
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_56
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_59
.Lhrdbf_56:
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
	ja	.Lhrdbf_66
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.Lhrdbf_66
	testl	$1023, %esi
	jne	.Lhrdbf_66
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.Lhrdbf_66
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
	jne	.Lhrdbf_66
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.Lhrdbf_66
	testw	%r13w, %r13w
	jne	.Lhrdbf_90
	testl	%esi, %esi
	je	.Lhrdbf_90
	.p2align 4,,10
	.p2align 3
.Lhrdbf_66:
	movl	$1, %eax
.Lhrdbf_62:
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
.Lhrdbf_90:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.Lhrdbf_71:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.Lhrdbf_66
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.Lhrdbf_66
	testw	%r11w, %r11w
	je	.Lhrdbf_68
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_70:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.Lhrdbf_69
	cmpl	%r10d, %edx
	jl	.Lhrdbf_66
.Lhrdbf_69:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.Lhrdbf_70
.Lhrdbf_68:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.Lhrdbf_71
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.Lhrdbf_72
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.Lhrdbf_106
	cmpl	%esi, %eax
	jne	.Lhrdbf_66
.Lhrdbf_72:
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
.Lhrdbf_86:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.Lhrdbf_66
	testl	%r15d, %r15d
	jne	.Lhrdbf_74
.Lhrdbf_77:
	cmpq	%r13, 8(%rsp)
	je	.Lhrdbf_75
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbf_79
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.Lhrdbf_79
	cmpl	36(%rbp), %edx
	jbe	.Lhrdbf_79
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
	jne	.Lhrdbf_79
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
	je	.Lhrdbf_80
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.Lhrdbf_81
	.p2align 4,,10
	.p2align 3
.Lhrdbf_108:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.Lhrdbf_107
.Lhrdbf_81:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.Lhrdbf_108
.Lhrdbf_79:
	movl	$4, %eax
	jmp	.Lhrdbf_62
.Lhrdbf_74:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call .Lhrdbf_entry_hrdbf_local_nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.Lhrdbf_77
	jmp	.Lhrdbf_62
	.p2align 4,,10
	.p2align 3
.Lhrdbf_107:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_89
.Lhrdbf_105:
	movq	16(%rdi), %rsi
.Lhrdbf_84:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.Lhrdbf_86
.Lhrdbf_75:
	xorl	%eax, %eax
	jmp	.Lhrdbf_62
.Lhrdbf_106:
	movl	%esi, 40(%rbp)
	jmp	.Lhrdbf_72
.Lhrdbf_89:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.Lhrdbf_85
.Lhrdbf_83:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.Lhrdbf_87
.Lhrdbf_85:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.Lhrdbf_83
	jb	.Lhrdbf_84
	jmp	.Lhrdbf_66
.Lhrdbf_80:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_105
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.Lhrdbf_87:
	cmpl	%r11d, %eax
	ja	.Lhrdbf_84
	jmp	.Lhrdbf_66
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
	ja	.Lhrdbf_109
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrdbf_109
	testl	$1023, %edx
	jne	.Lhrdbf_109
	testq	%rbp, %rbp
	je	.Lhrdbf_109
	cmpb	$0, 40(%rbp)
	je	.Lhrdbf_109
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.Lhrdbf_109
	cmpw	$0, 16(%rsi)
	jne	.Lhrdbf_109
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.Lhrdbf_112
	.p2align 4,,10
	.p2align 3
.Lhrdbf_111:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.Lhrdbf_173
.Lhrdbf_112:
	cmpq	$11, %rcx
	jbe	.Lhrdbf_111
	cmpb	$0, 538(%rax,%rcx)
	je	.Lhrdbf_111
.Lhrdbf_145:
	movl	$2, %r10d
.Lhrdbf_109:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_173:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbf_109
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.Lhrdbf_109
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.Lhrdbf_109
	movl	%esi, %ecx
	shrw $1, %cx
	cmpw	20(%rax), %cx
	jne	.Lhrdbf_109
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbf_113
	jmp	.Lhrdbf_109
	.p2align 4,,10
	.p2align 3
.Lhrdbf_114:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.Lhrdbf_145
.Lhrdbf_113:
	cmpb	$0, 22(%rax,%r12)
	jne	.Lhrdbf_114
	testq	%r12, %r12
	je	.Lhrdbf_145
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbf_145
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.Lhrdbf_115:
	xorl	%esi, %esi
	jmp	.Lhrdbf_124
	.p2align 4,,10
	.p2align 3
.Lhrdbf_174:
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
	jne	.Lhrdbf_117
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.Lhrdbf_116
	cmpq	$10, %rsi
	ja	.Lhrdbf_116
.Lhrdbf_124:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_174
.Lhrdbf_117:
	cmpq	%r12, %rsi
	je	.Lhrdbf_129
.Lhrdbf_121:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.Lhrdbf_115
	jmp	.Lhrdbf_145
.Lhrdbf_116:
	cmpq	%r12, %rsi
	jne	.Lhrdbf_121
	cmpq	$11, %rsi
	je	.Lhrdbf_122
.Lhrdbf_129:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.Lhrdbf_121
.Lhrdbf_122:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.Lhrdbf_145
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbf_109
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.Lhrdbf_109
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.Lhrdbf_151
	testq	%r8, %r8
	jne	.Lhrdbf_152
	testl	%ecx, %ecx
	jne	.Lhrdbf_151
.Lhrdbf_152:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.Lhrdbf_151
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.Lhrdbf_151
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.Lhrdbf_126:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.Lhrdbf_126
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
	jne	.Lhrdbf_127
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.Lhrdbf_128
	movl	$4, %r10d
.Lhrdbf_127:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_109
.Lhrdbf_128:
	movl	%eax, 24(%rbx)
	jmp	.Lhrdbf_109
.Lhrdbf_151:
	movl	$3, %r10d
	jmp	.Lhrdbf_109
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
	jne	.Lhrdbf_181
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.Lhrdbf_183
.Lhrdbf_181:
	movl	$1, %eax
.Lhrdbf_175:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_183:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.Lhrdbf_175
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.Lhrdbf_175
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.Lhrdbf_175
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.Lhrdbf_181
	cmpl	%edi, %r12d
	jb	.Lhrdbf_181
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbf_175
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
	je	.Lhrdbf_185
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_186:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.Lhrdbf_186
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
	jne	.Lhrdbf_187
	testl	%edx, %edx
	je	.Lhrdbf_187
.Lhrdbf_189:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_187:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.Lhrdbf_189
.Lhrdbf_195:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbf_189
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbf_189
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.Lhrdbf_190
	xorl	%eax, %eax
	jmp	.Lhrdbf_191
	.p2align 4,,10
	.p2align 3
.Lhrdbf_208:
	movq	(%r9), %rcx
.Lhrdbf_191:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbf_208
.Lhrdbf_190:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.Lhrdbf_194
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_193:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_193
.Lhrdbf_194:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_185:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbf_195
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
	je	.Lhrdbf_212
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.Lhrdbf_264
.Lhrdbf_212:
	movl	$1, %r12d
.Lhrdbf_209:
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
.Lhrdbf_264:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.Lhrdbf_212
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.Lhrdbf_212
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
	jne	.Lhrdbf_212
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
	je	.Lhrdbf_213
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.Lhrdbf_212
.Lhrdbf_213:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_265
	cmpl	%r8d, %ecx
	jne	.Lhrdbf_212
	cmpl	%eax, 312(%rdx)
	jne	.Lhrdbf_212
.Lhrdbf_235:
	cmpl	$-1, %r9d
	je	.Lhrdbf_217
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.Lhrdbf_212
	testl	$511, %r9d
	jne	.Lhrdbf_212
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.Lhrdbf_212
.Lhrdbf_217:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.Lhrdbf_218
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbf_266
	cmpl	%esi, %eax
	jne	.Lhrdbf_212
.Lhrdbf_220:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbf_209
	testl	%r14d, %r14d
	je	.Lhrdbf_230
	movl	%r15d, %ecx
.Lhrdbf_221:
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
	jne	.Lhrdbf_240
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbf_223
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.Lhrdbf_223
	cmpl	48(%rbx), %eax
	jbe	.Lhrdbf_223
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
	jne	.Lhrdbf_223
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
	je	.Lhrdbf_224
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.Lhrdbf_225
.Lhrdbf_268:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbf_267
	movq	%rdx, %rax
.Lhrdbf_225:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.Lhrdbf_268
.Lhrdbf_223:
	movl	$4, %r12d
	jmp	.Lhrdbf_209
	.p2align 4,,10
	.p2align 3
.Lhrdbf_265:
	cmpl	$-1, %r8d
	jne	.Lhrdbf_212
	jmp	.Lhrdbf_235
.Lhrdbf_218:
	testl	%r14d, %r14d
	je	.Lhrdbf_212
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.Lhrdbf_212
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.Lhrdbf_233:
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
	jne	.Lhrdbf_261
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.Lhrdbf_212
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
	jne	.Lhrdbf_212
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.Lhrdbf_231
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.Lhrdbf_232
	.p2align 4,,10
	.p2align 3
.Lhrdbf_269:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_231
.Lhrdbf_232:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.Lhrdbf_269
	jmp	.Lhrdbf_212
.Lhrdbf_266:
	movl	%esi, 52(%rbx)
	jmp	.Lhrdbf_220
.Lhrdbf_231:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.Lhrdbf_261
	movzwl	%r11w, %ecx
	jmp	.Lhrdbf_233
.Lhrdbf_267:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_238
.Lhrdbf_263:
	movq	16(%r11), %rcx
.Lhrdbf_228:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.Lhrdbf_230
	movzwl	%r9w, %ecx
	jmp	.Lhrdbf_221
.Lhrdbf_261:
	movl	%r10d, %r12d
	jmp	.Lhrdbf_209
.Lhrdbf_224:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbf_263
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.Lhrdbf_236:
	cmpl	%r11d, %r8d
	ja	.Lhrdbf_228
	jmp	.Lhrdbf_212
.Lhrdbf_238:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.Lhrdbf_229
.Lhrdbf_227:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.Lhrdbf_236
	movq	%r15, %rsi
.Lhrdbf_229:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.Lhrdbf_227
	jb	.Lhrdbf_228
	jmp	.Lhrdbf_212
.Lhrdbf_240:
	movl	%eax, %r12d
	jmp	.Lhrdbf_209
.Lhrdbf_230:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbf_209
	.size	hrdbf_local_cxvisit, .-hrdbf_local_cxvisit
	.p2align 4
	.type	hrdbf_local_cxheader, @function
hrdbf_local_cxheader:
.Lhrdbf_entry_hrdbf_local_cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.Lhrdbf_270
	cmpb	$1, 15(%rdi)
	jne	.Lhrdbf_270
	cmpw	$1024, 16(%rdi)
	jne	.Lhrdbf_270
	cmpw	$512, 18(%rdi)
	jne	.Lhrdbf_270
	cmpw	$0, 502(%rdi)
	jne	.Lhrdbf_270
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.Lhrdbf_273
	.p2align 4,,10
	.p2align 3
.Lhrdbf_292:
	cmpl	$23, %eax
	ja	.Lhrdbf_280
.Lhrdbf_272:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbf_291
.Lhrdbf_273:
	cmpb	$0, (%rdi,%rax)
	je	.Lhrdbf_272
	testb	%cl, %cl
	je	.Lhrdbf_292
.Lhrdbf_280:
	movl	$2, %eax
.Lhrdbf_270:
	ret
.Lhrdbf_291:
	testl	%edx, %edx
	je	.Lhrdbf_274
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_270
	cmpb	$67, 21(%rdi)
	jne	.Lhrdbf_270
	cmpb	$72, 22(%rdi)
	jne	.Lhrdbf_270
	cmpb	$66, 23(%rdi)
	jne	.Lhrdbf_270
.Lhrdbf_274:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_270
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.Lhrdbf_270
	xorl	%eax, %eax
	cmpw	$0, 508(%rdi)
	setne	%al
	addl	%eax, %eax
	ret
	.size	hrdbf_local_cxheader, .-hrdbf_local_cxheader
	.p2align 4
	.type	hrdbf_file_append.part.0, @function
hrdbf_file_append.part.0:
.Lhrdbf_entry_hrdbf_file_append.part.0:
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
	ja	.Lhrdbf_293
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
	jbe	.Lhrdbf_293
	testq	%r13, %r13
	je	.Lhrdbf_293
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.Lhrdbf_298
	.p2align 4,,10
	.p2align 3
.Lhrdbf_295:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.Lhrdbf_295
.Lhrdbf_298:
	leaq	0(%r13,%rbp), %r8
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r8, %rdx
	je	.Lhrdbf_297
	.p2align 4,,10
	.p2align 3
.Lhrdbf_296:
	movb	$32, (%r8,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbf_296
	addq	%r8, %rdx
.Lhrdbf_297:
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
	js	.Lhrdbf_299
	movabs	$1749024623285053783, %rdx
	movq	(%rsp), %rcx
	movabs	$4137408090565272301, %rsi
	movabs	$-1896998432287073591, %rdi
	movabs	$3234497591006606311, %r11
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
	movabs	$7429236654343298871, %rdx
	subq	%rdi, %rcx
	movq	%rcx, %rax
	mulq	%rdx
	movq	%rcx, %rax
	shrq	$2, %rcx
	subq	%rdx, %rax
	shrq $1, %rax
	leaq	(%rdx,%rax), %rdi
	leaq	(%rsi,%rsi,4), %rax
	movabs	$2070078458244228039, %rdx
	leaq	(%rax,%rax,4), %r9
	movq	%rcx, %rax
	shrq	$8, %rdi
	mulq	%rdx
	movq	%rcx, %rax
	salq	$4, %r9
	addq	%rdi, %r9
	shrq	$10, %rdx
	leaq	(%rdx,%r10), %rsi
	movabs	$-3689348814741910323, %r10
	mulq	%r11
	leaq	(%rdi,%rdi,8), %rax
	leaq	(%rdi,%rax,8), %rax
	leaq	(%rax,%rax,4), %rax
	shrq	$6, %rdx
	subq	%rdx, %rsi
	movabs	$3858142551364089227, %rdx
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
	jbe	.Lhrdbf_333
	subq	$9, %rsi
	cmpq	$3, %rsi
	adcq	$0, %r9
.Lhrdbf_301:
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
.Lhrdbf_304:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_304
	testq	%rax, %rax
	jle	.Lhrdbf_299
	cmpq	%rdx, %rax
	ja	.Lhrdbf_299
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_304
	leaq	28(%r13), %rsi
	movl	$18, %r9d
	movl	$1, %edx
.Lhrdbf_305:
	movq	2280(%rbx), %rdi
	movl	$28, %r10d
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_305
	cmpq	$1, %rax
	jne	.Lhrdbf_299
	movl	$18, %r9d
	movq	%r8, %rsi
	movq	%rbp, %r10
	movq	%r12, %rdx
.Lhrdbf_306:
	movq	2280(%rbx), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_306
	testq	%rax, %rax
	jle	.Lhrdbf_299
	cmpq	%rdx, %rax
	ja	.Lhrdbf_299
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_306
	movq	2256(%rbx), %rdi
	movq	2264(%rbx), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_299
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
.Lhrdbf_293:
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
.Lhrdbf_299:
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
.Lhrdbf_333:
	addq	$3, %rsi
	jmp	.Lhrdbf_301
	.size	hrdbf_file_append.part.0, .-hrdbf_file_append.part.0
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
	je	.Lhrdbf_335
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
	js	.Lhrdbf_335
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_335:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_334
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_339
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_334:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_339:
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
	jmp	.Lhrdbf_345
	.p2align 4,,10
	.p2align 3
.Lhrdbf_347:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_346
.Lhrdbf_345:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_347
.Lhrdbf_346:
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
	jne	.Lhrdbf_348
	orl	%eax, %edx
	movb	%dl, (%rdi)
.Lhrdbf_348:
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
	ja	.Lhrdbf_354
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.Lhrdbf_354
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.Lhrdbf_354
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.Lhrdbf_354
	cmpb	$0, 40(%rcx)
	je	.Lhrdbf_354
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_350
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.Lhrdbf_350
	cmpw	$1, 510(%r12)
	jne	.Lhrdbf_350
	cmpb	$0, 512(%r12)
	jne	.Lhrdbf_350
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.Lhrdbf_354
	testl	$511, %r10d
	jne	.Lhrdbf_354
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.Lhrdbf_354
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.Lhrdbf_350
	cmpw	$1, 2(%r12,%rdx)
	jne	.Lhrdbf_350
	cmpl	$-1, 4(%r12,%rdx)
	jne	.Lhrdbf_354
	cmpl	$-1, 8(%r12,%rdx)
	jne	.Lhrdbf_354
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbf_350
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
	jne	.Lhrdbf_350
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_354
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.Lhrdbf_354
	testl	$511, %r8d
	jne	.Lhrdbf_354
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.Lhrdbf_354
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.Lhrdbf_354
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.Lhrdbf_354
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.Lhrdbf_354
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_355
.Lhrdbf_428:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.Lhrdbf_392
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbf_427
.Lhrdbf_355:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbf_428
.Lhrdbf_392:
	movl	$2, %eax
	jmp	.Lhrdbf_350
	.p2align 4,,10
	.p2align 3
.Lhrdbf_354:
	movl	$1, %eax
.Lhrdbf_350:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_427:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_350
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbf_392
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.Lhrdbf_392
	cmpb	$0, (%r12,%rdx)
	jne	.Lhrdbf_392
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.Lhrdbf_356:
	cmpb	$0, (%rdi,%rdx)
	je	.Lhrdbf_392
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbf_356
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.Lhrdbf_357:
	cmpq	%r11, 40(%rsp)
	jbe	.Lhrdbf_392
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.Lhrdbf_366:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.Lhrdbf_360
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.Lhrdbf_361
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.Lhrdbf_361:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.Lhrdbf_362
	subl	$32, %esi
.Lhrdbf_362:
	cmpb	16(%rsp), %sil
	jne	.Lhrdbf_360
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbf_358
	cmpq	$11, %rdx
	jne	.Lhrdbf_366
	cmpq	$11, %rax
	jne	.Lhrdbf_360
.Lhrdbf_364:
	cmpl	%r11d, 36(%rsp)
	je	.Lhrdbf_392
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.Lhrdbf_392
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.Lhrdbf_391
	cmpw	12(%r12,%r9), %ax
	jne	.Lhrdbf_392
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.Lhrdbf_396
	testq	%r14, %r14
	jne	.Lhrdbf_398
	testl	%eax, %eax
	jne	.Lhrdbf_396
.Lhrdbf_398:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.Lhrdbf_396
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.Lhrdbf_396
	xorl	%edx, %edx
.Lhrdbf_368:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_368
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbf_369
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbf_369:
	testb	$2, %al
	jne	.Lhrdbf_370
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbf_370:
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
.Lhrdbf_371:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbf_371
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call .Lhrdbf_entry_hrdbf_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbf_429
.Lhrdbf_372:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_350
.Lhrdbf_358:
	cmpq	$11, %rax
	je	.Lhrdbf_364
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbf_364
.Lhrdbf_360:
	addq	$1, %r11
	jmp	.Lhrdbf_357
.Lhrdbf_396:
	movl	$3, %eax
	jmp	.Lhrdbf_350
.Lhrdbf_391:
	movl	$5, %eax
	jmp	.Lhrdbf_350
.Lhrdbf_429:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.Lhrdbf_372
	xorl	%edx, %edx
	jmp	.Lhrdbf_374
.Lhrdbf_430:
	cmpq	$63, %rdx
	ja	.Lhrdbf_399
.Lhrdbf_374:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbf_373
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.Lhrdbf_373:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbf_430
.Lhrdbf_399:
	testl	%eax, %eax
	jne	.Lhrdbf_372
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbf_350
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	hrdbf_local_put_number.isra.0, @function
hrdbf_local_put_number.isra.0:
.Lhrdbf_entry_hrdbf_local_put_number.isra.0:
	movl	%esi, %r11d
	movl	$3, %r10d
	movl	%edx, %esi
	cmpb	$78, %r11b
	jne	.Lhrdbf_431
	movzwl	%cx, %ecx
	leaq	(%rdi,%rcx), %rdx
	movzbl	%sil, %ecx
	cmpl	%r9d, %ecx
	jb	.Lhrdbf_452
	subl	%r9d, %ecx
	je	.Lhrdbf_437
	leal	-1(%rcx), %edi
	movq	%rdx, %rax
	addq	%rdx, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_438:
	movq	%rax, %rsi
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdi, %rsi
	jne	.Lhrdbf_438
.Lhrdbf_437:
	testl	%r9d, %r9d
	je	.Lhrdbf_436
	leal	-1(%r9), %eax
	leaq	1(%r8,%rax), %rdi
	movl	%ecx, %eax
	subl	%r8d, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_439:
	movzbl	(%r8), %esi
	leal	(%rax,%r8), %ecx
	addq	$1, %r8
	movb	%sil, (%rdx,%rcx)
	cmpq	%rdi, %r8
	jne	.Lhrdbf_439
.Lhrdbf_436:
	xorl	%r10d, %r10d
.Lhrdbf_431:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_452:
	movq	%rdx, %rax
	movzbl	%sil, %edx
	addq	%rax, %rdx
	testl	%ecx, %ecx
	je	.Lhrdbf_436
	.p2align 4,,10
	.p2align 3
.Lhrdbf_435:
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_436
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_435
	jmp	.Lhrdbf_436
	.size	hrdbf_local_put_number.isra.0, .-hrdbf_local_put_number.isra.0
	.p2align 4
	.type	hrdbf_write_number_scaled.part.0, @function
hrdbf_write_number_scaled.part.0:
.Lhrdbf_entry_hrdbf_write_number_scaled.part.0:
	pushq	%r14
	movl	$4, %eax
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$112, %rsp
	movzbl	13(%rsi), %r13d
	cmpb	$17, %r13b
	ja	.Lhrdbf_453
	movzbl	12(%rsi), %r12d
	movq	%rsi, %r10
	cmpl	$17, %ecx
	ja	.Lhrdbf_479
	cmpb	%r12b, %r13b
	jnb	.Lhrdbf_479
	movq	%rdi, %rbp
	movq	%rdx, %rsi
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jns	.Lhrdbf_455
	negq	%rsi
	movl	$1, %r8d
.Lhrdbf_455:
	movzbl	%r13b, %ebx
	cmpl	%ebx, %ecx
	jbe	.Lhrdbf_456
	subl	%ebx, %ecx
	je	.Lhrdbf_457
	xorl	%eax, %eax
	movl	$1, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_458:
	leaq	(%rdi,%rdi,4), %rdi
	addl	$1, %eax
	addq	%rdi, %rdi
	cmpl	%eax, %ecx
	jne	.Lhrdbf_458
	movq	%rsi, %rax
	xorl	%edx, %edx
	divq	%rdi
	shrq $1, %rdi
	movq	%rax, %rsi
	cmpq	%rdi, %rdx
	jb	.Lhrdbf_459
.Lhrdbf_457:
	addq	$1, %rsi
.Lhrdbf_459:
	movabs	$-3689348814741910323, %r9
	movq	%rsp, %rdi
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_464:
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
	ja	.Lhrdbf_464
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
	ja	.Lhrdbf_507
	testl	%r8d, %r8d
	je	.Lhrdbf_470
	movb	$45, 48(%rsp)
.Lhrdbf_470:
	cmpl	%ecx, %ebx
	jb	.Lhrdbf_508
	leal	1(%r8), %r9d
	movl	%r8d, %r8d
	movb	$48, 48(%rsp,%r8)
.Lhrdbf_472:
	testb	%r13b, %r13b
	je	.Lhrdbf_474
	cmpl	%ecx, %ebx
	movl	%r9d, %edx
	leal	1(%r9), %eax
	cmovbe	%ebx, %ecx
	movb	$46, 48(%rsp,%rdx)
	subl	%ecx, %ebx
	je	.Lhrdbf_475
	leal	1(%rbx,%r9), %edi
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_476:
	movl	%edx, %esi
	addl	$1, %edx
	movb	$48, 48(%rsp,%rsi)
	cmpl	%edx, %edi
	jne	.Lhrdbf_476
	addl	%ebx, %eax
.Lhrdbf_475:
	leal	(%rcx,%rax), %r9d
	leal	-1(%rcx,%rax), %esi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_477:
	movl	%esi, %ecx
	movl	%eax, %edx
	subl	%eax, %ecx
	addl	$1, %eax
	movzbl	(%rsp,%rcx), %ecx
	movb	%cl, 48(%rsp,%rdx)
	cmpl	%eax, %r9d
	jne	.Lhrdbf_477
.Lhrdbf_474:
	movzbl	11(%r10), %esi
	leaq	48(%rsp), %r8
	movl	%r14d, %ecx
	movl	%r12d, %edx
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_put_number.isra.0
.Lhrdbf_453:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_479:
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
.Lhrdbf_456:
	jnb	.Lhrdbf_459
	movl	%ebx, %edi
	subl	%ecx, %edi
	je	.Lhrdbf_459
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rsi
	ja	.Lhrdbf_460
	xorl	%eax, %eax
	jmp	.Lhrdbf_461
	.p2align 4,,10
	.p2align 3
.Lhrdbf_463:
	cmpq	%rdx, %rsi
	ja	.Lhrdbf_460
.Lhrdbf_461:
	leaq	(%rsi,%rsi,4), %rsi
	addl	$1, %eax
	addq	%rsi, %rsi
	cmpl	%eax, %edi
	jne	.Lhrdbf_463
	jmp	.Lhrdbf_459
	.p2align 4,,10
	.p2align 3
.Lhrdbf_508:
	testl	%r9d, %r9d
	je	.Lhrdbf_483
	movl	%edx, %r9d
	addl	%r8d, %r11d
	jmp	.Lhrdbf_473
	.p2align 4,,10
	.p2align 3
.Lhrdbf_509:
	movl	%r11d, %eax
	movl	%esi, %r8d
	subl	%esi, %eax
	movzbl	(%rsp,%rax), %eax
.Lhrdbf_473:
	leal	1(%r8), %esi
	movl	%r8d, %r8d
	movb	%al, 48(%rsp,%r8)
	cmpl	%esi, %edx
	jne	.Lhrdbf_509
	jmp	.Lhrdbf_472
	.p2align 4,,10
	.p2align 3
.Lhrdbf_507:
	xorl	%eax, %eax
	leaq	0(%rbp,%r14), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_468:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbf_468
	xorl	%eax, %eax
.Lhrdbf_510:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_460:
	movzwl	14(%r10), %edx
	xorl	%eax, %eax
	addq	%rbp, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_462:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r12d
	ja	.Lhrdbf_462
	xorl	%eax, %eax
	jmp	.Lhrdbf_510
.Lhrdbf_483:
	movl	%r8d, %r9d
	jmp	.Lhrdbf_472
	.size	hrdbf_write_number_scaled.part.0, .-hrdbf_write_number_scaled.part.0
	.p2align 4
	.type	hrdbf_local_bn_shr_round, @function
hrdbf_local_bn_shr_round:
.Lhrdbf_entry_hrdbf_local_bn_shr_round:
	movl	288(%rdi), %r9d
	movl	%esi, %r8d
	movl	%r9d, %esi
	sall	$5, %esi
	cmpl	%r8d, %esi
	jbe	.Lhrdbf_556
	leal	-1(%r8), %edx
	xorl	%r10d, %r10d
	cmpl	%edx, %esi
	ja	.Lhrdbf_557
.Lhrdbf_518:
	cmpl	$1, %r8d
	je	.Lhrdbf_519
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_522
	.p2align 4,,10
	.p2align 3
.Lhrdbf_520:
	addl	$1, %ecx
	cmpl	%ecx, %edx
	je	.Lhrdbf_519
.Lhrdbf_522:
	cmpl	%ecx, %esi
	jbe	.Lhrdbf_520
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbf_520
	testl	%r10d, %r10d
	movl	$3, %edx
	cmovne	%edx, %eax
.Lhrdbf_533:
	cmpl	$31, %r8d
	jbe	.Lhrdbf_527
	movl	%r8d, %r11d
	shrl	$5, %r11d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbf_529
	leal	-1(%r9), %ecx
	movq	%rdi, %rdx
	movl	%r11d, %esi
	subl	%r11d, %ecx
	leaq	4(%rdi,%rcx,4), %r10
	.p2align 4,,10
	.p2align 3
.Lhrdbf_528:
	movl	(%rdx,%rsi,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%r10, %rdx
	jne	.Lhrdbf_528
.Lhrdbf_529:
	movl	%r9d, %edx
	subl	%r11d, %edx
	movl	%edx, 288(%rdi)
	cmpl	%edx, %r9d
	jbe	.Lhrdbf_527
	movl	%edx, %ecx
	leal	-1(%r11), %esi
	leaq	(%rdi,%rcx,4), %rdx
	addq	%rsi, %rcx
	leaq	4(%rdi,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_530:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_530
.Lhrdbf_527:
	andl	$31, %r8d
	jne	.Lhrdbf_524
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_557:
	movl	%edx, %eax
	movl	%edx, %ecx
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %r10d
	shrl	%cl, %r10d
	andl	$1, %r10d
	jmp	.Lhrdbf_518
	.p2align 4,,10
	.p2align 3
.Lhrdbf_556:
	xorl	%eax, %eax
	testl	%esi, %esi
	je	.Lhrdbf_513
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_515:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r9d
	addl	$1, %ecx
	cmpl	%ecx, %esi
	jne	.Lhrdbf_515
	testl	%eax, %eax
	je	.Lhrdbf_513
	xorl	%r10d, %r10d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_516:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %r10d
	cmpl	%ecx, %esi
	jne	.Lhrdbf_516
	subl	$1, %r8d
	cmpl	%r9d, %r8d
	ja	.Lhrdbf_513
	sete	%al
	xorl	%edx, %edx
	cmpl	$1, %r10d
	sete	%dl
	andl	%eax, %edx
	movl	$3, %eax
	subl	%edx, %eax
.Lhrdbf_513:
	movl	$1, 288(%rdi)
	movl	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_519:
	leal	(%r10,%r10), %eax
	jmp	.Lhrdbf_533
	.p2align 4,,10
	.p2align 3
.Lhrdbf_524:
	movl	288(%rdi), %ecx
	pushq	%rbx
	leal	-1(%rcx), %ebx
	cmpl	$1, %ecx
	jbe	.Lhrdbf_531
	movl	$32, %r10d
	subl	$2, %ecx
	movq	%rdi, %rdx
	subl	%r8d, %r10d
	leaq	4(%rdi,%rcx,4), %r11
	.p2align 4,,10
	.p2align 3
.Lhrdbf_532:
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
	jne	.Lhrdbf_532
	movl	%ebx, %esi
	movl	%r8d, %ecx
	movl	(%rdi,%rsi,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%rdi,%rsi,4)
	testl	%edx, %edx
	je	.Lhrdbf_558
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_558:
	movl	%ebx, 288(%rdi)
	popq	%rbx
	ret
.Lhrdbf_531:
	movl	%r8d, %ecx
	shrl	%cl, (%rdi,%rbx,4)
	popq	%rbx
	ret
	.size	hrdbf_local_bn_shr_round, .-hrdbf_local_bn_shr_round
	.p2align 4
	.type	hrdbf_local_fdec, @function
hrdbf_local_fdec:
.Lhrdbf_entry_hrdbf_local_fdec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabs	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_560:
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
	jbe	.Lhrdbf_570
	cmpl	$19, %r8d
	jbe	.Lhrdbf_560
.Lhrdbf_570:
	leaq	2289(%rdi), %r10
	leaq	2448(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_568:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_562
	.p2align 4,,10
	.p2align 3
.Lhrdbf_564:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_563
.Lhrdbf_562:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_564
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_565
	jmp	.Lhrdbf_563
	.p2align 4,,10
	.p2align 3
.Lhrdbf_566:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_563
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_565:
	testb	%cl, %cl
	jne	.Lhrdbf_566
.Lhrdbf_563:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_559
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_568
.Lhrdbf_559:
	addq	$56, %rsp
	ret
	.size	hrdbf_local_fdec, .-hrdbf_local_fdec
	.section	.rodata
.Lhrdbf_C0:
	.string	" (errno "
	.text
	.p2align 4
	.type	hrdbf_local_ferr, @function
hrdbf_local_ferr:
.Lhrdbf_entry_hrdbf_local_ferr:
	leaq	2289(%rdi), %r11
	pushq	%rbx
	leaq	2448(%rdi), %rbx
	movq	%r11, %rax
	jmp	.Lhrdbf_578
	.p2align 4,,10
	.p2align 3
.Lhrdbf_580:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_579
.Lhrdbf_578:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_580
.Lhrdbf_579:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.Lhrdbf_582
	.p2align 4,,10
	.p2align 3
.Lhrdbf_584:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_583
.Lhrdbf_582:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_584
	cmpq	%rax, %rbx
	jbe	.Lhrdbf_583
	movl	$32, %esi
	movl	$.Lhrdbf_C0, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_585:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_583
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.Lhrdbf_585
.Lhrdbf_583:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call .Lhrdbf_entry_hrdbf_local_fdec
	jmp	.Lhrdbf_586
	.p2align 4,,10
	.p2align 3
.Lhrdbf_588:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.Lhrdbf_587
.Lhrdbf_586:
	cmpb	$0, (%r11)
	jne	.Lhrdbf_588
	cmpq	%r11, %rbx
	jbe	.Lhrdbf_587
	movb	$41, (%r11)
	addq	$1, %r11
.Lhrdbf_587:
	movb	$0, (%r11)
	popq	%rbx
	ret
	.size	hrdbf_local_ferr, .-hrdbf_local_ferr
	.p2align 4
	.type	hrdbf_fmt_harbour.part.0, @function
hrdbf_fmt_harbour.part.0:
.Lhrdbf_entry_hrdbf_fmt_harbour.part.0:
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
	je	.Lhrdbf_601
	movabs	$4503599627370495, %rax
	andq	40(%rsp), %rax
	movq	%rdi, %rbx
	movq	%rax, 8(%rsp)
	testq	%r9, %r9
	je	.Lhrdbf_835
	btsq	$52, 8(%rsp)
	movq	8(%rsp), %rax
	movl	$2, %edi
	leal	-1075(%r9), %r15d
	subl	$735, %r9d
	movl	%eax, %ecx
	movl	%r9d, %r10d
	shrq	$32, %rax
.Lhrdbf_599:
	movl	%ecx, 48(%rsp)
	movl	$340, %esi
	xorl	%r8d, %r8d
	movl	%eax, 52(%rsp)
	movl	%edi, 336(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbf_604:
	leal	-1(%rdi), %eax
	leaq	48(%rsp), %rdx
	leaq	52(%rsp,%rax,4), %r11
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_605:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%r11, %rdx
	jne	.Lhrdbf_605
	testq	%rax, %rax
	je	.Lhrdbf_606
	movl	%edi, %edx
	movl	$1, %r8d
	addl	$1, %edi
	movl	%eax, 48(%rsp,%rdx,4)
.Lhrdbf_606:
	subl	$1, %esi
	jne	.Lhrdbf_604
	testb	%r8b, %r8b
	je	.Lhrdbf_608
	movl	%edi, 336(%rsp)
.Lhrdbf_608:
	movl	%r10d, %esi
	testl	%r9d, %r9d
	js	.Lhrdbf_609
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	336(%rsp), %eax
.Lhrdbf_610:
	xorl	%ebp, %ebp
	jmp	.Lhrdbf_614
	.p2align 4,,10
	.p2align 3
.Lhrdbf_615:
	cmpq	$80, %rbp
	je	.Lhrdbf_836
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_divmod_1e9
	movl	%eax, 1264(%rsp,%rbp,4)
	movl	336(%rsp), %eax
	addq	$1, %rbp
.Lhrdbf_614:
	movl	%ebp, %r8d
	cmpl	$1, %eax
	jne	.Lhrdbf_615
	movl	48(%rsp), %r9d
	testl	%r9d, %r9d
	jne	.Lhrdbf_615
	testl	%ebp, %ebp
	jne	.Lhrdbf_837
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbf_600
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jnb	.Lhrdbf_838
.Lhrdbf_601:
	xorl	%eax, %eax
.Lhrdbf_593:
	addq	$2312, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_835:
	testq	%rax, %rax
	jne	.Lhrdbf_839
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbf_600
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jb	.Lhrdbf_601
	movl	$11824, %ecx
	leaq	2(%rdi), %rdx
	movw	%cx, (%rdi)
	movl	16(%rsp), %edi
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.Lhrdbf_603:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbf_603
	jmp	.Lhrdbf_593
.Lhrdbf_600:
	movl	36(%rsp), %r10d
	testl	%r10d, %r10d
	je	.Lhrdbf_601
	movb	$48, (%rbx)
	movl	$1, %eax
	jmp	.Lhrdbf_593
.Lhrdbf_839:
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
	jmp	.Lhrdbf_599
.Lhrdbf_609:
	negl	%esi
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shr_round
	movl	%eax, %r8d
	movl	336(%rsp), %eax
	cmpl	$1, %r8d
	jbe	.Lhrdbf_610
	testl	%eax, %eax
	je	.Lhrdbf_709
	leal	-1(%rax), %edx
	movq	%rdi, %rsi
	leaq	52(%rsp,%rdx,4), %rdi
	movl	$1, %edx
.Lhrdbf_613:
	movl	(%rsi), %ecx
	addq	$4, %rsi
	addq	%rcx, %rdx
	movl	%edx, -4(%rsi)
	shrq	$32, %rdx
	cmpq	%rdi, %rsi
	jne	.Lhrdbf_613
	testq	%rdx, %rdx
	je	.Lhrdbf_610
	leal	1(%rax), %edx
.Lhrdbf_612:
	movl	$1, 48(%rsp,%rax,4)
	movl	%edx, %eax
	movl	%edx, 336(%rsp)
	jmp	.Lhrdbf_610
.Lhrdbf_836:
	movl	$79, %r8d
.Lhrdbf_618:
	movl	%r8d, %eax
	movl	$1, %ecx
	movl	$3435973837, %r9d
	movl	1264(%rsp,%rax,4), %esi
.Lhrdbf_622:
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
	ja	.Lhrdbf_622
	leaq	1584(%rsp), %r13
	leal	-1(%r12), %ecx
	leaq	1585(%rsp), %rax
	movq	%rcx, %r11
	leal	-1(%r12,%r13), %esi
	addq	%rax, %rcx
	movq	%r13, %rax
	jmp	.Lhrdbf_624
.Lhrdbf_840:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	960(%rsp,%rdx), %edx
.Lhrdbf_624:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_840
	testl	%r8d, %r8d
	je	.Lhrdbf_625
	leaq	1264(%rsp), %r14
	leal	-1(%r8), %eax
	movl	$3435973837, %r10d
	leaq	(%r14,%rax,4), %rbp
.Lhrdbf_627:
	movl	%r11d, %edi
	movl	0(%rbp), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_626:
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
	jne	.Lhrdbf_626
	leaq	-4(%rbp), %rax
	cmpq	%r14, %rbp
	je	.Lhrdbf_841
	movq	%rax, %rbp
	jmp	.Lhrdbf_627
.Lhrdbf_841:
	leal	(%r8,%r8,8), %eax
	addl	%eax, %r12d
.Lhrdbf_625:
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
.Lhrdbf_629:
	leal	-1(%r8), %eax
	leaq	352(%rsp), %rcx
	leaq	356(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_630:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_630
	testq	%rax, %rax
	je	.Lhrdbf_631
	movl	%r8d, %edx
	movl	$1, %r9d
	addl	$1, %r8d
	movl	%eax, 352(%rsp,%rdx,4)
.Lhrdbf_631:
	subl	$1, %edi
	jne	.Lhrdbf_629
	testb	%r9b, %r9b
	je	.Lhrdbf_633
	movl	%r8d, 640(%rsp)
.Lhrdbf_633:
	leal	339(%r15), %ebp
	leaq	352(%rsp), %rdi
	movl	%ebp, %esi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	cmpl	$-1074, %r15d
	movabs	$4503599627370496, %rax
	setne	%r9b
	cmpq	%rax, 8(%rsp)
	sete	%al
	andb	%al, %r9b
	je	.Lhrdbf_634
	movl	$340, %r10d
	xorl	%ebp, %ebp
	movl	$2, %r11d
	movabs	$18014398509481983, %rax
	movq	%rax, 656(%rsp)
	leaq	656(%rsp), %rdi
	leaq	660(%rsp), %r8
	movl	$2, 944(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbf_635:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_636:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rsi, %rcx
	jne	.Lhrdbf_636
	testq	%rax, %rax
	je	.Lhrdbf_637
	movl	%r11d, %edx
	movl	%r9d, %ebp
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.Lhrdbf_637:
	subl	$1, %r10d
	jne	.Lhrdbf_635
	testb	%bpl, %bpl
	je	.Lhrdbf_639
	movl	%r11d, 944(%rsp)
.Lhrdbf_639:
	leal	338(%r15), %esi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
.Lhrdbf_640:
	leaq	960(%rsp), %r8
	cmpl	$1, %r12d
	je	.Lhrdbf_677
	leal	1(%r12), %eax
	leaq	960(%rsp), %r8
	movq	%rbx, 24(%rsp)
	movl	$2, %r14d
	movl	%eax, 32(%rsp)
	leaq	1585(%rsp), %rbp
	movl	$1, %r15d
	movq	%r8, %rbx
.Lhrdbf_673:
	movl	%r15d, 4(%rsp)
	movq	%r13, %rdx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_647:
	movzbl	(%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpq	%rdx, %rbp
	jne	.Lhrdbf_647
	cmpb	$53, 0(%rbp)
	ja	.Lhrdbf_648
	je	.Lhrdbf_842
.Lhrdbf_649:
	movl	32(%rsp), %r10d
	movq	%r10, %rcx
	subq	%r14, %rcx
	cmpq	$9, %rsi
	ja	.Lhrdbf_843
.Lhrdbf_651:
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
	je	.Lhrdbf_655
	.p2align 4,,10
	.p2align 3
.Lhrdbf_654:
	leal	-1(%rdi), %eax
	movq	%rbx, %rcx
	leaq	964(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_656:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_656
	testq	%rax, %rax
	je	.Lhrdbf_657
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 960(%rsp,%rdx,4)
.Lhrdbf_657:
	addl	$1, %r9d
	cmpl	%r10d, %r9d
	jne	.Lhrdbf_654
	testb	%r11b, %r11b
	je	.Lhrdbf_655
	movl	%edi, 1248(%rsp)
.Lhrdbf_655:
	movl	%r10d, %esi
	movq	%rbx, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	1248(%rsp), %esi
	cmpl	944(%rsp), %esi
	je	.Lhrdbf_660
	jnb	.Lhrdbf_661
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_662
	movl	$-1, %ecx
	leal	-1(%rsi), %eax
	jmp	.Lhrdbf_669
	.p2align 4,,10
	.p2align 3
.Lhrdbf_672:
	movl	%eax, %edx
	subl	$1, %eax
	movl	352(%rsp,%rdx,4), %edi
	cmpl	%edi, 960(%rsp,%rdx,4)
	jne	.Lhrdbf_844
.Lhrdbf_669:
	cmpl	$-1, %eax
	jne	.Lhrdbf_672
.Lhrdbf_668:
	testb	$1, 8(%rsp)
	je	.Lhrdbf_824
.Lhrdbf_662:
	movl	%r14d, %eax
	addq	$1, %r15
	addq	$1, %r14
	addq	$1, %rbp
	cmpl	$17, %eax
	ja	.Lhrdbf_825
	cmpl	%r12d, %eax
	jb	.Lhrdbf_673
.Lhrdbf_825:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
.Lhrdbf_677:
	movl	$17, %eax
	cmpl	%eax, %r12d
	cmovbe	%r12d, %eax
	movl	%eax, 4(%rsp)
.Lhrdbf_675:
	movl	4(%rsp), %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
.Lhrdbf_678:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpl	%edx, %edi
	ja	.Lhrdbf_678
	movl	4(%rsp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_679
	cmpb	$53, 1584(%rsp,%rax)
	ja	.Lhrdbf_680
	jne	.Lhrdbf_679
	testb	$1, %sil
	jne	.Lhrdbf_680
	movl	4(%rsp), %eax
	addl	$1, %eax
	cmpl	%r12d, %eax
	jb	.Lhrdbf_681
	jmp	.Lhrdbf_679
	.p2align 4,,10
	.p2align 3
.Lhrdbf_845:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.Lhrdbf_679
.Lhrdbf_681:
	cmpb	$48, 0(%r13,%rax)
	je	.Lhrdbf_845
.Lhrdbf_680:
	addq	$1, %rsi
.Lhrdbf_679:
	movabs	$-3689348814741910323, %r9
	xorl	%ecx, %ecx
.Lhrdbf_682:
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
	ja	.Lhrdbf_682
	cmpl	4(%rsp), %ecx
	jbe	.Lhrdbf_683
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 20(%rsp)
	testl	%edi, %edi
	je	.Lhrdbf_687
	leal	-1(%rdi), %eax
	movl	%edi, %ecx
	movq	%rax, %rdx
	movzbl	960(%rsp,%rax), %eax
	movl	%edx, %edi
.Lhrdbf_683:
	xorl	%edx, %edx
	jmp	.Lhrdbf_685
.Lhrdbf_846:
	movl	%edi, %eax
	subl	%edx, %eax
	movzbl	960(%rsp,%rax), %eax
.Lhrdbf_685:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbf_846
	cmpl	$1, %ecx
	jbe	.Lhrdbf_686
.Lhrdbf_847:
	leal	-1(%rcx), %edx
	cmpb	$48, 1584(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbf_686
	movl	%eax, %ecx
.Lhrdbf_687:
	cmpl	$1, %ecx
	ja	.Lhrdbf_847
.Lhrdbf_686:
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
	jle	.Lhrdbf_848
	movl	%ecx, %esi
	cmpq	%rsi, %rax
	jge	.Lhrdbf_692
	cmpb	$52, 1584(%rsp,%rax)
	movl	%eax, %ecx
	jbe	.Lhrdbf_698
	leal	-1(%rax), %esi
	movq	%rsi, %rax
	addq	%r13, %rsi
	subl	%esi, %eax
	jmp	.Lhrdbf_695
.Lhrdbf_694:
	movb	$48, (%rsi)
	leaq	-1(%rsi), %r10
	cmpq	%rsi, %r13
	je	.Lhrdbf_849
	movq	%r10, %rsi
.Lhrdbf_695:
	movzbl	(%rsi), %r10d
	leal	(%rax,%rsi), %r11d
	cmpb	$57, %r10b
	je	.Lhrdbf_694
	movl	%r11d, %eax
	addl	$1, %r10d
	movb	%r10b, 1584(%rsp,%rax)
	jmp	.Lhrdbf_698
	.p2align 4,,10
	.p2align 3
.Lhrdbf_660:
	leal	-1(%rsi), %eax
	movl	%eax, %edx
	jmp	.Lhrdbf_665
	.p2align 4,,10
	.p2align 3
.Lhrdbf_667:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	656(%rsp,%rcx,4), %edi
	cmpl	%edi, 960(%rsp,%rcx,4)
	jne	.Lhrdbf_850
.Lhrdbf_665:
	cmpl	$-1, %edx
	jne	.Lhrdbf_667
	xorl	%ecx, %ecx
	cmpl	%esi, 640(%rsp)
	je	.Lhrdbf_669
	jmp	.Lhrdbf_668
.Lhrdbf_842:
	testb	$1, %sil
	jne	.Lhrdbf_648
	cmpl	%r14d, %r12d
	jbe	.Lhrdbf_649
	movq	%r14, %rax
	jmp	.Lhrdbf_650
.Lhrdbf_851:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.Lhrdbf_649
.Lhrdbf_650:
	cmpb	$48, 0(%r13,%rax)
	je	.Lhrdbf_851
.Lhrdbf_648:
	addq	$1, %rsi
	jmp	.Lhrdbf_649
.Lhrdbf_843:
	movq	%rsi, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_652:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rdi
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rdi
	ja	.Lhrdbf_652
	cmpl	%r9d, 4(%rsp)
	jnb	.Lhrdbf_651
	movabs	$-3689348814741910323, %rax
	movq	%r10, %rcx
	mulq	%rsi
	subq	%r15, %rcx
	movq	%rdx, %rsi
	shrq	$3, %rsi
	jmp	.Lhrdbf_651
.Lhrdbf_850:
	jnb	.Lhrdbf_666
	movl	$-1, %ecx
	cmpl	640(%rsp), %esi
	je	.Lhrdbf_669
	jmp	.Lhrdbf_662
.Lhrdbf_844:
	jnb	.Lhrdbf_671
	cmpl	$1, %ecx
	je	.Lhrdbf_824
.Lhrdbf_671:
	testl	%ecx, %ecx
	jne	.Lhrdbf_662
	jmp	.Lhrdbf_668
.Lhrdbf_661:
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_833
	movl	$1, %ecx
	leal	-1(%rsi), %eax
	jmp	.Lhrdbf_669
.Lhrdbf_833:
	jnb	.Lhrdbf_662
.Lhrdbf_824:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
	jmp	.Lhrdbf_675
.Lhrdbf_666:
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_833
	movl	$1, %ecx
	jmp	.Lhrdbf_669
.Lhrdbf_852:
	leal	-1(%rcx), %esi
	cmpb	$48, 1584(%rsp,%rsi)
	movq	%rsi, %rax
	jne	.Lhrdbf_832
	movl	%eax, %ecx
.Lhrdbf_698:
	cmpl	$1, %ecx
	jne	.Lhrdbf_852
.Lhrdbf_697:
	xorl	%eax, %eax
	movl	$0, %esi
	cmpb	$48, 1584(%rsp)
	movl	$1, %ecx
	cmovne	%r8, %rax
	cmove	%esi, %edx
	jmp	.Lhrdbf_690
	.p2align 4,,10
	.p2align 3
.Lhrdbf_634:
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
.Lhrdbf_642:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_643:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_643
	testq	%rax, %rax
	je	.Lhrdbf_644
	movl	%r11d, %edx
	movl	$1, %r9d
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.Lhrdbf_644:
	subl	$1, %r10d
	jne	.Lhrdbf_642
	testb	%r9b, %r9b
	je	.Lhrdbf_646
	movl	%r11d, 944(%rsp)
.Lhrdbf_646:
	movl	%ebp, %esi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	jmp	.Lhrdbf_640
.Lhrdbf_692:
	cmpl	$1, %ecx
	je	.Lhrdbf_697
.Lhrdbf_832:
	movq	%r8, %rax
.Lhrdbf_690:
	movl	20(%rsp), %r14d
	movl	$1, %r8d
	leal	1(%r14), %esi
	testl	%r14d, %r14d
	movslq	%esi, %rsi
	cmovs	%r8, %rsi
.Lhrdbf_699:
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
	jg	.Lhrdbf_601
	testl	%edx, %edx
	jne	.Lhrdbf_853
	movq	%rbx, %rsi
	movl	$1, %eax
.Lhrdbf_701:
	movl	20(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbf_702
	leal	1(%rdi), %eax
	xorl	%esi, %esi
	movslq	%eax, %r9
.Lhrdbf_704:
	leal	(%rdx,%rsi), %edi
	movl	$48, %r8d
	cmpl	%ecx, %esi
	jnb	.Lhrdbf_703
	movzbl	0(%r13,%rsi), %r8d
.Lhrdbf_703:
	addq	$1, %rsi
	movb	%r8b, (%rbx,%rdi)
	cmpq	%rsi, %r9
	jne	.Lhrdbf_704
	addl	%edx, %eax
.Lhrdbf_705:
	movl	16(%rsp), %r10d
	testl	%r10d, %r10d
	je	.Lhrdbf_593
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
	jmp	.Lhrdbf_707
.Lhrdbf_727:
	movl	%eax, %edx
.Lhrdbf_707:
	movl	$48, %r8d
	testq	%rsi, %rsi
	js	.Lhrdbf_706
	leal	(%r9,%rdx), %eax
	cmpl	%ecx, %eax
	jnb	.Lhrdbf_706
	movzbl	0(%r13,%rsi), %r8d
.Lhrdbf_706:
	leal	1(%rdx), %eax
	movb	%r8b, (%rbx,%rdx)
	addq	$1, %rsi
	cmpl	%r10d, %eax
	jne	.Lhrdbf_727
	movl	16(%rsp), %eax
	addl	%edi, %eax
	jmp	.Lhrdbf_593
.Lhrdbf_848:
	jne	.Lhrdbf_689
	cmpb	$52, 1584(%rsp)
	jbe	.Lhrdbf_689
	negl	%esi
	movb	$49, 1584(%rsp)
	movq	%r8, %rax
	movl	$1, %ecx
	movl	%esi, 20(%rsp)
	jmp	.Lhrdbf_690
.Lhrdbf_689:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %esi
	movl	$1, %ecx
	movb	$48, 1584(%rsp)
	movl	$0, 20(%rsp)
	jmp	.Lhrdbf_699
.Lhrdbf_853:
	movb	$45, (%rbx)
	leaq	1(%rbx), %rsi
	movl	$2, %eax
	jmp	.Lhrdbf_701
.Lhrdbf_837:
	subl	$1, %r8d
	jmp	.Lhrdbf_618
.Lhrdbf_838:
	movl	16(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rbx)
	leaq	2(%rbx), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.Lhrdbf_621:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_621
	jmp	.Lhrdbf_593
.Lhrdbf_702:
	movb	$48, (%rsi)
	jmp	.Lhrdbf_705
.Lhrdbf_709:
	movl	$1, %edx
	jmp	.Lhrdbf_612
.Lhrdbf_849:
	movb	$49, 1584(%rsp)
	movl	%r9d, 20(%rsp)
	jmp	.Lhrdbf_698
	.size	hrdbf_fmt_harbour.part.0, .-hrdbf_fmt_harbour.part.0
	.p2align 4
	.type	hrdbf_write_number_double.part.0, @function
hrdbf_write_number_double.part.0:
.Lhrdbf_entry_hrdbf_write_number_double.part.0:
	movzbl	13(%rsi), %edx
	movl	$4, %eax
	cmpb	$17, %dl
	ja	.Lhrdbf_861
	pushq	%rbp
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$408, %rsp
	cmpb	12(%rsi), %dl
	jnb	.Lhrdbf_854
	movq	%rdi, %rbp
	movl	$400, %esi
	movq	%rsp, %rdi
	call .Lhrdbf_entry_hrdbf_fmt_harbour.part.0
	movl	%eax, %r9d
	movl	$5, %eax
	testl	%r9d, %r9d
	je	.Lhrdbf_854
	movzwl	14(%rbx), %ecx
	movzbl	12(%rbx), %edx
	movq	%rsp, %r8
	movq	%rbp, %rdi
	movzbl	11(%rbx), %esi
	call .Lhrdbf_entry_hrdbf_local_put_number.isra.0
.Lhrdbf_854:
	addq	$408, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_861:
	ret
	.size	hrdbf_write_number_double.part.0, .-hrdbf_write_number_double.part.0
	.p2align 4
	.type	hrdbf_local_ddec, @function
hrdbf_local_ddec:
.Lhrdbf_entry_hrdbf_local_ddec:
	subq	$56, %rsp
	xorl	%r8d, %r8d
	movabs	$-3689348814741910323, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_865:
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
	jbe	.Lhrdbf_875
	cmpl	$19, %r8d
	jbe	.Lhrdbf_865
.Lhrdbf_875:
	leaq	2090(%rdi), %r10
	leaq	2249(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_873:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_867
	.p2align 4,,10
	.p2align 3
.Lhrdbf_869:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_868
.Lhrdbf_867:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_869
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_870
	jmp	.Lhrdbf_868
	.p2align 4,,10
	.p2align 3
.Lhrdbf_871:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_868
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_870:
	testb	%cl, %cl
	jne	.Lhrdbf_871
.Lhrdbf_868:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_864
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_873
.Lhrdbf_864:
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
.Lhrdbf_883:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.Lhrdbf_882
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	2090(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.Lhrdbf_885
	.p2align 4,,10
	.p2align 3
.Lhrdbf_887:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.Lhrdbf_886
.Lhrdbf_885:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_887
	cmpq	%rdx, %rax
	jnb	.Lhrdbf_886
	movb	%cl, (%rax)
	addq	$1, %rax
.Lhrdbf_886:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.Lhrdbf_883
.Lhrdbf_882:
	ret
	.size	hrdbf_local_dname, .-hrdbf_local_dname
	.section	.rodata
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
	jmp	.Lhrdbf_892
	.p2align 4,,10
	.p2align 3
.Lhrdbf_894:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_893
.Lhrdbf_892:
	cmpb	$0, (%rdx)
	jne	.Lhrdbf_894
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.Lhrdbf_895
	jmp	.Lhrdbf_893
	.p2align 4,,10
	.p2align 3
.Lhrdbf_897:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_893
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.Lhrdbf_895:
	testb	%cl, %cl
	jne	.Lhrdbf_897
.Lhrdbf_893:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.Lhrdbf_C1(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbf_899
	.p2align 4,,10
	.p2align 3
.Lhrdbf_901:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_900
.Lhrdbf_899:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_901
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.Lhrdbf_902
	jmp	.Lhrdbf_900
	.p2align 4,,10
	.p2align 3
.Lhrdbf_903:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_900
.Lhrdbf_902:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_903
.Lhrdbf_900:
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
	je	.Lhrdbf_912
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_912:
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
	je	.Lhrdbf_915
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_915
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_917
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
.Lhrdbf_919:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_929
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_915:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_917:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_920
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_915
	.p2align 4,,10
	.p2align 3
.Lhrdbf_929:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_915
	.p2align 4,,10
	.p2align 3
.Lhrdbf_920:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_919
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
	je	.Lhrdbf_1009
	testl	%esi, %esi
	je	.Lhrdbf_1010
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_1010
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
	ja	.Lhrdbf_1010
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_1013
	cmpb	$78, %r8b
	je	.Lhrdbf_1014
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_1015
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_956
	cmpb	$89, %dl
	je	.Lhrdbf_956
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_1010
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_1009
	movabs	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_1009
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1010:
	xorl	%r8d, %r8d
.Lhrdbf_1009:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_956:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1013:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1009
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1014:
	testl	%edi, %edi
	je	.Lhrdbf_1010
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_935
	.p2align 4,,10
	.p2align 3
.Lhrdbf_936:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_1010
.Lhrdbf_935:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_936
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_938
	.p2align 4,,10
	.p2align 3
.Lhrdbf_962:
	movl	%edx, %edi
.Lhrdbf_938:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_937
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_962
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_982
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_960:
	movabs	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabs	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_940:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_967
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_959:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabs	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_944
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1016:
	testl	%ebx, %ebx
	jne	.Lhrdbf_983
	movl	$1, %ebx
.Lhrdbf_941:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_943
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_944:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_1016
.Lhrdbf_983:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_967
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_973
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_941
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_941
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1015:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_953:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_975
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_953
	jmp	.Lhrdbf_1010
.Lhrdbf_975:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_952:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_976
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_952
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
	jbe	.Lhrdbf_1009
	cmpl	$11, %edx
	ja	.Lhrdbf_1009
	testl	%edi, %edi
	je	.Lhrdbf_1009
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_1017
.Lhrdbf_954:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_1009
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1009
.Lhrdbf_943:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_930
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_930
	leal	1(%r13), %eax
	jbe	.Lhrdbf_945
	movabs	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_946
	jmp	.Lhrdbf_973
	.p2align 4,,10
	.p2align 3
.Lhrdbf_947:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_973
.Lhrdbf_946:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_947
	testl	%r12d, %r12d
	jne	.Lhrdbf_958
.Lhrdbf_949:
	movq	%r11, %rax
.Lhrdbf_950:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_930:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_973:
	movl	$4, %r8d
	jmp	.Lhrdbf_930
.Lhrdbf_937:
	je	.Lhrdbf_932
	movabs	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_940
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_960
	.p2align 4,,10
	.p2align 3
.Lhrdbf_932:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_930
.Lhrdbf_967:
	movl	$5, %r8d
	jmp	.Lhrdbf_930
.Lhrdbf_982:
	movabs	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_959
.Lhrdbf_976:
	movl	$5, %r8d
	jmp	.Lhrdbf_1009
.Lhrdbf_1017:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_954
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_955
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_954
.Lhrdbf_955:
	addl	$1, %r10d
	jmp	.Lhrdbf_954
.Lhrdbf_945:
	testl	%r12d, %r12d
	je	.Lhrdbf_949
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_950
.Lhrdbf_958:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_950
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_1018
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_1020
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_1020:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_1018:
	ret
	.size	hrdbf_deleted, .-hrdbf_deleted
	.section	.rodata
	.align 8
.Lhrdbf_C2:
	.string	"' numeric content overflows int64"
	.align 8
.Lhrdbf_C3:
	.string	"' content is not valid for its type"
	.align 8
.Lhrdbf_C4:
	.string	"file has fewer than the 33 header bytes"
	.section	.rodata
.Lhrdbf_C5:
	.string	"version byte 0x"
	.section	.rodata
	.align 8
.Lhrdbf_C6:
	.string	" is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)"
	.section	.rodata
.Lhrdbf_C7:
	.string	"implausible header length "
.Lhrdbf_C8:
	.string	" or record length "
.Lhrdbf_C9:
	.string	" for file size "
.Lhrdbf_C10:
	.string	"field descriptor "
	.section	.rodata
	.align 8
.Lhrdbf_C11:
	.string	" truncated before end of header"
	.align 8
.Lhrdbf_C12:
	.string	"more than 128 field descriptors"
	.section	.rodata
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
	.section	.rodata
	.align 8
.Lhrdbf_C23:
	.string	"' width must be 1 with no decimals"
	.section	.rodata
.Lhrdbf_C24:
	.string	"D field '"
	.section	.rodata
	.align 8
.Lhrdbf_C25:
	.string	"' width must be 8 with no decimals"
	.section	.rodata
.Lhrdbf_C26:
	.string	"' has unsupported type '"
.Lhrdbf_C27:
	.string	"' (only C/N/D/L, no memo)"
	.section	.rodata
	.align 8
.Lhrdbf_C28:
	.string	"field widths exceed the 65535 record limit"
	.align 8
.Lhrdbf_C29:
	.string	"field descriptors not terminated by 0x0D"
	.section	.rodata
.Lhrdbf_C30:
	.string	"table declares no fields"
	.section	.rodata
	.align 8
.Lhrdbf_C31:
	.string	"field widths plus delete flag sum to "
	.section	.rodata
.Lhrdbf_C32:
	.string	" but header record length is "
	.section	.rodata
	.align 8
.Lhrdbf_C33:
	.string	"nonzero byte between field descriptors and header end"
	.section	.rodata
.Lhrdbf_C34:
	.string	"header record count "
.Lhrdbf_C35:
	.string	" exceeds the "
.Lhrdbf_C36:
	.string	" records physically present"
	.section	.rodata
	.align 8
.Lhrdbf_C37:
	.string	"unexpected trailing bytes after the last record (no 0x1A terminator)"
	.section	.rodata
.Lhrdbf_C38:
	.string	"record "
.Lhrdbf_C39:
	.string	" has delete flag 0x"
.Lhrdbf_C40:
	.string	" (expected space or '*')"
.Lhrdbf_C41:
	.string	" field '"
	.section	.rodata
	.align 8
.Lhrdbf_C42:
	.string	" (logical byte must be T/F/Y/N/?/space)"
	.section	.rodata
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
	jbe	.Lhrdbf_1099
	cmpb	$3, (%rsi)
	movq	%rsi, %r10
	jne	.Lhrdbf_1100
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
	jbe	.Lhrdbf_1027
	testl	%edi, %edi
	sete	%dl
	cmpq	%rbx, %r11
	setb	%al
	orb	%al, %dl
	je	.Lhrdbf_1028
.Lhrdbf_1027:
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
.Lhrdbf_1023:
	addq	$2344, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_1028:
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
.Lhrdbf_1052:
	movzbl	(%rdi), %r12d
	movq	%r13, %rsi
	movzwl	8(%rsp), %ecx
	salq	$5, %rsi
	cmpb	$13, %r12b
	je	.Lhrdbf_1101
	cmpq	%r13, 24(%rsp)
	je	.Lhrdbf_1102
	cmpq	$129, %r13
	je	.Lhrdbf_1103
	movw	%r13w, 22(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbf_1036
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1104:
	movzbl	(%rdi,%rax), %r12d
.Lhrdbf_1036:
	movb	%r12b, 42(%rbx,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_1104
	movzbl	-11(%r9), %r14d
	testb	%r14b, %r14b
	je	.Lhrdbf_1037
	cmpl	$1, %r13d
	jbe	.Lhrdbf_1038
	leal	-1(%r13), %r12d
	xorl	%esi, %esi
	salq	$4, %r12
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1039:
	movq	%r15, %rax
	movl	%r14d, %edx
	jmp	.Lhrdbf_1042
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1106:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbf_1042:
	leaq	(%rax,%r8), %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.Lhrdbf_1105
	cmpq	%r9, %rax
	jne	.Lhrdbf_1106
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
	jmp	.Lhrdbf_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1105:
	addq	$16, %rsi
	cmpq	%r12, %rsi
	jne	.Lhrdbf_1039
.Lhrdbf_1038:
	movzbl	11(%rdi), %edx
	movzbl	16(%rdi), %eax
	movw	%r10w, 3(%r9)
	movzbl	17(%rdi), %ecx
	movb	%dl, (%r9)
	movb	%al, 1(%r9)
	movb	%cl, 2(%r9)
	testb	%al, %al
	je	.Lhrdbf_1107
	cmpb	$67, %dl
	je	.Lhrdbf_1108
	cmpb	$78, %dl
	je	.Lhrdbf_1109
	cmpb	$76, %dl
	je	.Lhrdbf_1110
	cmpb	$68, %dl
	jne	.Lhrdbf_1049
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	je	.Lhrdbf_1045
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
	jmp	.Lhrdbf_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1099:
	movl	$.Lhrdbf_C4, %esi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1100:
	movl	$.Lhrdbf_C5, %esi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movzbl	(%r10), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dhex
	movl	$.Lhrdbf_C6, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1108:
	testb	%cl, %cl
	jne	.Lhrdbf_1111
.Lhrdbf_1045:
	addl	%eax, %r10d
	cmpl	$65535, %r10d
	ja	.Lhrdbf_1112
	addq	$1, %r13
	addq	$32, %rdi
	addq	$16, %rbx
	addq	$16, %r15
	addl	$1, 8(%rsp)
	subq	$16, %r8
	addq	$16, %r9
	movl	$1, %edx
	cmpq	%r13, 32(%rsp)
	jne	.Lhrdbf_1052
	movl	$.Lhrdbf_C29, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1109:
	cmpb	$17, %cl
	ja	.Lhrdbf_1069
	cmpb	%cl, %al
	ja	.Lhrdbf_1045
.Lhrdbf_1069:
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
	jmp	.Lhrdbf_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1110:
	movslq	8(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.Lhrdbf_1045
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
	jmp	.Lhrdbf_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1102:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1103:
	movl	$.Lhrdbf_C12, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$4, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1101:
	movl	%r10d, %ebx
	movq	40(%rsp), %r10
	testb	%dl, %dl
	je	.Lhrdbf_1030
	movw	%cx, 116(%rsp)
	testw	%cx, %cx
	je	.Lhrdbf_1030
	addq	$1, %rsi
	cmpl	%ebx, 16(%rsp)
	je	.Lhrdbf_1054
	jmp	.Lhrdbf_1113
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1055:
	addq	$1, %rsi
	cmpb	$0, -1(%r10,%rsi)
	jne	.Lhrdbf_1114
.Lhrdbf_1054:
	cmpq	(%rsp), %rsi
	jb	.Lhrdbf_1055
	movl	%ebx, %ecx
	movq	%r11, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%rcx
	movl	12(%rsp), %r13d
	movq	%rax, %r12
	cmpq	%rax, %r13
	ja	.Lhrdbf_1115
	movq	%r13, %rax
	imulq	%rcx, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r11
	je	.Lhrdbf_1057
	movq	%r11, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbf_1058
	cmpb	$26, (%r10,%rax)
	je	.Lhrdbf_1057
.Lhrdbf_1058:
	movl	$.Lhrdbf_C37, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1037:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1107:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1114:
	movl	$.Lhrdbf_C33, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1112:
	movl	$.Lhrdbf_C28, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$4, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1111:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1113:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1030:
	movl	$.Lhrdbf_C30, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset.constprop.0
	movl	$1, %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1049:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1057:
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
	je	.Lhrdbf_1066
	movq	%rbp, (%rsp)
	movq	%rcx, %rbp
.Lhrdbf_1065:
	movzbl	(%rbx), %r12d
	addq	$1, %r14
	cmpb	$32, %r12b
	je	.Lhrdbf_1060
	cmpb	$42, %r12b
	jne	.Lhrdbf_1116
.Lhrdbf_1060:
	movq	%r14, 104(%rsp)
	movl	$1, %r15d
	jmp	.Lhrdbf_1064
.Lhrdbf_1061:
	addl	$1, %r15d
	cmpl	8(%rsp), %r15d
	ja	.Lhrdbf_1117
.Lhrdbf_1064:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	je	.Lhrdbf_1061
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
	je	.Lhrdbf_1118
.Lhrdbf_1063:
	cmpb	$42, %r12b
	jne	.Lhrdbf_1023
	movl	$.Lhrdbf_C43, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	(%rsp), %eax
	jmp	.Lhrdbf_1023
.Lhrdbf_1117:
	addq	%rbp, %rbx
	cmpq	%r14, %r13
	jne	.Lhrdbf_1065
	movq	(%rsp), %rbp
.Lhrdbf_1066:
	movl	$282, %ecx
	movq	%rbp, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.Lhrdbf_1023
.Lhrdbf_1115:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1116:
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
	jmp	.Lhrdbf_1023
.Lhrdbf_1118:
	movl	$.Lhrdbf_C42, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	(%rsp), %eax
	jmp	.Lhrdbf_1063
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
	ja	.Lhrdbf_1121
	je	.Lhrdbf_1141
	cmpl	$5, %edx
	je	.Lhrdbf_1124
	shrq	$8, %rdi
	jne	.Lhrdbf_1142
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_1121
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_1121
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1121
	movabs	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_1121
	movabs	$2951479051793528259, %r8
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
	ja	.Lhrdbf_1137
	testq	%rsi, %rsi
	je	.Lhrdbf_1137
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_1143
.Lhrdbf_1126:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1141:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_1121
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_1144
.Lhrdbf_1121:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1124:
	movabs	$-9223372036854775803, %rax
	movq	%rdi, %rdx
	shrq	$63, %rdx
	cmpq	%rax, %rdi
	setne	%al
	andl	%edx, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1144:
	testb	$-1, %dh
	jne	.Lhrdbf_1121
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
.Lhrdbf_1142:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1137:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1143:
	testb	$3, %cl
	jne	.Lhrdbf_1126
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_1127
	addl	$1, %eax
	jmp	.Lhrdbf_1126
.Lhrdbf_1127:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_1126
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
	ja	.Lhrdbf_1145
	movzbl	hrdbf_local_CSWTCH.320(%rdx), %eax
.Lhrdbf_1145:
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
	jne	.Lhrdbf_1148
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_1158
	testl	%edx, %edx
	je	.Lhrdbf_1151
	cmpl	$9, %edx
	je	.Lhrdbf_1151
	movl	$1, %eax
.Lhrdbf_1148:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1158:
	testl	$65280, %r9d
	jne	.Lhrdbf_1159
.Lhrdbf_1151:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1159:
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
	jne	.Lhrdbf_1160
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1160
	movzbl	%bpl, %r13d
	movzbl	%r10b, %r12d
	cmpb	$11, %bpl
	jne	.Lhrdbf_1162
	cmpl	$11, %r12d
	jne	.Lhrdbf_1162
.Lhrdbf_1175:
	xorl	%edx, %edx
	cmpq	%r11, %r9
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_1160:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1162:
	cmpl	$1, %r13d
	je	.Lhrdbf_1178
	cmpl	$1, %r12d
	je	.Lhrdbf_1178
	cmpl	$3, %r13d
	jne	.Lhrdbf_1165
	cmpl	$3, %r12d
	jne	.Lhrdbf_1165
	testq	%r9, %r9
	sete	%dl
	testq	%r11, %r11
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1178:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1165:
	movq	%rbp, %rdi
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1160
	cmpl	$12, %r13d
	je	.Lhrdbf_1201
	testl	%r13d, %r13d
	je	.Lhrdbf_1168
	movl	$1, %eax
	cmpl	$9, %r13d
	jne	.Lhrdbf_1160
.Lhrdbf_1168:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1160
	cmpl	$12, %r12d
	je	.Lhrdbf_1202
	testl	%r12d, %r12d
	je	.Lhrdbf_1175
	cmpl	$9, %r12d
	je	.Lhrdbf_1175
	movl	$1, %eax
	jmp	.Lhrdbf_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1201:
	testl	$65280, %ebp
	je	.Lhrdbf_1168
.Lhrdbf_1174:
	movl	$2, %eax
	jmp	.Lhrdbf_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1202:
	testl	$65280, %r10d
	je	.Lhrdbf_1175
	jmp	.Lhrdbf_1174
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
	jne	.Lhrdbf_1203
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_1207
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_1205
	cmpl	$1, %ecx
	je	.Lhrdbf_1208
.Lhrdbf_1207:
	movl	$1, %eax
.Lhrdbf_1203:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1205:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1208:
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
	jne	.Lhrdbf_1209
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_1256
	cmpl	$12, %eax
	jne	.Lhrdbf_1235
	movl	%r10d, %r14d
	movl	%r10d, %eax
	negq	%rcx
	movl	$1, %esi
	shrl	$16, %r14d
	testq	%r11, %r11
	movzbl	%ah, %eax
	movabs	$-3689348814741910323, %r13
	cmovns	%r11, %rcx
	movl	%eax, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1217:
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
	ja	.Lhrdbf_1217
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_1257
	movl	$1, %esi
.Lhrdbf_1218:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_1219:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_1220
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_1258
	subl	%eax, %r14d
	je	.Lhrdbf_1228
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1227:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1227
.Lhrdbf_1228:
	testq	%r11, %r11
	jns	.Lhrdbf_1226
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_1226:
	testl	%esi, %esi
	je	.Lhrdbf_1229
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_1231
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1239:
	movl	%edx, %eax
.Lhrdbf_1231:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_1230
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_1230:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_1239
	addl	%esi, %r14d
.Lhrdbf_1229:
	testl	%r10d, %r10d
	je	.Lhrdbf_1209
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1233:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_1232
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_1232:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_1233
.Lhrdbf_1209:
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
.Lhrdbf_1256:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_1220
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_1213
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1215:
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
	jne	.Lhrdbf_1215
	jmp	.Lhrdbf_1209
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1235:
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
.Lhrdbf_1257:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_1218
	movl	%esi, %eax
	jmp	.Lhrdbf_1219
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1220:
	movl	$3, %r8d
	jmp	.Lhrdbf_1209
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1213:
	movq	%r11, %rax
	movb	$47, 2(%r9)
	movabs	$3777893186295716171, %rdx
	movabs	$2951479051793528259, %rdi
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
	jmp	.Lhrdbf_1209
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1258:
	testl	%r14d, %r14d
	je	.Lhrdbf_1209
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1223:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_1223
	jmp	.Lhrdbf_1209
	.size	hrv_render, .-hrv_render
	.section	.rodata
.Lhrdbf_C46:
	.string	"DBF unknown value error"
	.text
	.p2align 4
	.globl	hrv_error_name
	.type	hrv_error_name, @function
hrv_error_name:
.Lhrdbf_entry_hrv_error_name:
	endbr64
	movl	$.Lhrdbf_C46, %eax
	cmpl	$4, %edi
	ja	.Lhrdbf_1259
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.339(,%rdi,8), %rax
.Lhrdbf_1259:
	ret
	.size	hrv_error_name, .-hrv_error_name
	.p2align 4
	.globl	hrdbf_fmt_fixed
	.type	hrdbf_fmt_fixed, @function
hrdbf_fmt_fixed:
.Lhrdbf_entry_hrdbf_fmt_fixed:
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
	ja	.Lhrdbf_1265
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
	je	.Lhrdbf_1265
	movabs	$4503599627370495, %rcx
	andq	%rcx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbf_1360
	btsq	$52, %rax
	subl	$1075, %edx
	movl	$2, %edi
	movl	%eax, %ecx
	movslq	%edx, %r9
	shrq	$32, %rax
.Lhrdbf_1269:
	movl	%ecx, 224(%rsp)
	leaq	224(%rsp), %r14
	movl	%eax, 228(%rsp)
	movl	%edi, 512(%rsp)
	testl	%ebx, %ebx
	je	.Lhrdbf_1276
	xorl	%r10d, %r10d
	xorl	%r8d, %r8d
	leaq	224(%rsp), %r14
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1275:
	leal	-1(%rdi), %eax
	movq	%r14, %rdx
	leaq	228(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1277:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_1277
	testq	%rax, %rax
	je	.Lhrdbf_1278
	movl	%edi, %edx
	movl	$1, %r10d
	addl	$1, %edi
	movl	%eax, 224(%rsp,%rdx,4)
.Lhrdbf_1278:
	addl	$1, %r8d
	cmpl	%r8d, %ebx
	jne	.Lhrdbf_1275
	testb	%r10b, %r10b
	je	.Lhrdbf_1276
	movl	%edi, 512(%rsp)
.Lhrdbf_1276:
	movl	%ebx, %esi
	addq	%r9, %rsi
	js	.Lhrdbf_1281
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	512(%rsp), %r10d
.Lhrdbf_1282:
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_1288
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1289:
	cmpq	$48, %r12
	je	.Lhrdbf_1361
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_divmod_1e9
	movl	512(%rsp), %r10d
	movl	%eax, 32(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbf_1288:
	movl	%r12d, %r13d
	cmpl	$1, %r10d
	jne	.Lhrdbf_1289
	movl	224(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_1289
	testl	%r12d, %r12d
	jne	.Lhrdbf_1362
	movl	$0, 32(%rsp)
	movl	$48, %edx
	movb	$48, 22(%rsp)
.Lhrdbf_1294:
	leal	-1(%r10), %eax
	leaq	528(%rsp), %r14
	movq	%rax, %r11
	leaq	529(%rsp,%rax), %rcx
	leal	-1(%r10,%r14), %esi
	movq	%r14, %rax
	jmp	.Lhrdbf_1297
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1363:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	22(%rsp,%rdx), %edx
.Lhrdbf_1297:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_1363
	testl	%r13d, %r13d
	je	.Lhrdbf_1298
	leaq	32(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1300:
	movl	%r11d, %edi
	movl	(%r12), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1299:
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
	jne	.Lhrdbf_1299
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbf_1364
	movq	%rax, %r12
	jmp	.Lhrdbf_1300
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1265:
	xorl	%eax, %eax
.Lhrdbf_1262:
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
.Lhrdbf_1360:
	testq	%rax, %rax
	jne	.Lhrdbf_1365
	cmpq	$0, 8(%rsp)
	jne	.Lhrdbf_1366
	xorl	%edx, %edx
.Lhrdbf_1270:
	testl	%ebx, %ebx
	je	.Lhrdbf_1271
	leal	2(%rdx,%rbx), %esi
	cmpl	4(%rsp), %esi
	ja	.Lhrdbf_1265
	movl	%edx, %eax
	movb	$48, 0(%rbp,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, 0(%rbp,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1273:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 0(%rbp,%rcx)
	cmpl	%edx, %esi
	jne	.Lhrdbf_1273
	addl	%ebx, %eax
	jmp	.Lhrdbf_1262
.Lhrdbf_1366:
	movl	4(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_1265
	movb	$45, 0(%rbp)
	movl	$1, %edx
	jmp	.Lhrdbf_1270
.Lhrdbf_1281:
	negl	%esi
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shr_round
	movl	512(%rsp), %r10d
	cmpl	$3, %eax
	je	.Lhrdbf_1367
	cmpl	$2, %eax
	jne	.Lhrdbf_1282
	movl	224(%rsp), %ecx
	movl	%ecx, %edx
	andl	$1, %edx
	je	.Lhrdbf_1282
	testl	%r10d, %r10d
	je	.Lhrdbf_1315
.Lhrdbf_1285:
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.Lhrdbf_1287
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1368:
	movl	(%r14,%rdx,4), %ecx
.Lhrdbf_1287:
	addq	%rcx, %rax
	movl	%eax, (%r14,%rdx,4)
	addq	$1, %rdx
	shrq	$32, %rax
	cmpl	%edx, %r10d
	ja	.Lhrdbf_1368
	testq	%rax, %rax
	je	.Lhrdbf_1282
	movl	%r10d, %eax
	addl	$1, %r10d
.Lhrdbf_1284:
	movl	%r10d, 512(%rsp)
	movl	$1, 224(%rsp,%rax,4)
	jmp	.Lhrdbf_1282
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1364:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %r10d
.Lhrdbf_1298:
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
	ja	.Lhrdbf_1265
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.Lhrdbf_1303
	movb	$45, 0(%rbp)
	movl	$1, %edx
.Lhrdbf_1303:
	cmpl	%r10d, %ebx
	jnb	.Lhrdbf_1304
	testl	%eax, %eax
	je	.Lhrdbf_1320
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1306:
	movzbl	(%r14), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbf_1306
.Lhrdbf_1305:
	testl	%ebx, %ebx
	je	.Lhrdbf_1262
.Lhrdbf_1307:
	cmpl	%r10d, %ebx
	movl	%r10d, %edi
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %edi
	movb	$46, 0(%rbp,%rcx)
	subl	%edi, %ebx
	je	.Lhrdbf_1308
	leal	1(%rbx,%rax), %esi
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1309:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, 0(%rbp,%rcx)
	cmpl	%esi, %eax
	jne	.Lhrdbf_1309
	addl	%ebx, %edx
.Lhrdbf_1308:
	subl	%edi, %r10d
	leal	(%rdi,%rdx), %eax
	subl	%edx, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1310:
	leal	(%r10,%rdx), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	528(%rsp,%rsi), %esi
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbf_1310
	jmp	.Lhrdbf_1262
.Lhrdbf_1361:
	movl	220(%rsp), %ecx
	movl	$47, %r13d
.Lhrdbf_1292:
	movl	$1, %esi
	movl	$3435973837, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1295:
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
	ja	.Lhrdbf_1295
	jmp	.Lhrdbf_1294
.Lhrdbf_1365:
	movl	%eax, %ecx
	shrq	$32, %rax
	movl	$0, %edx
	movq	$-1074, %r9
	cmpq	$1, %rax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rax, %rax
	cmove	%edx, %eax
	jmp	.Lhrdbf_1269
.Lhrdbf_1271:
	leal	1(%rdx), %eax
	cmpl	4(%rsp), %eax
	ja	.Lhrdbf_1265
	movb	$48, 0(%rbp,%rdx)
	jmp	.Lhrdbf_1262
.Lhrdbf_1304:
	movb	$48, 0(%rbp,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbf_1307
.Lhrdbf_1367:
	testl	%r10d, %r10d
	je	.Lhrdbf_1314
	movl	224(%rsp), %ecx
	jmp	.Lhrdbf_1285
.Lhrdbf_1320:
	movl	%edx, %eax
	jmp	.Lhrdbf_1305
.Lhrdbf_1315:
	xorl	%eax, %eax
	movl	%edx, %r10d
	jmp	.Lhrdbf_1284
.Lhrdbf_1314:
	xorl	%eax, %eax
	movl	$1, %r10d
	jmp	.Lhrdbf_1284
.Lhrdbf_1362:
	leal	-1(%r12), %eax
	movl	32(%rsp,%rax,4), %ecx
	movq	%rax, %r13
	jmp	.Lhrdbf_1292
	.size	hrdbf_fmt_fixed, .-hrdbf_fmt_fixed
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.type	hrdbf_fmt_harbour, @function
hrdbf_fmt_harbour:
.Lhrdbf_entry_hrdbf_fmt_harbour:
	endbr64
	cmpl	$32, %edx
	ja	.Lhrdbf_1370
	jmp .Lhrdbf_entry_hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1370:
	xorl	%eax, %eax
	ret
	.size	hrdbf_fmt_harbour, .-hrdbf_fmt_harbour
	.p2align 4
	.globl	hrdbf_write_char
	.type	hrdbf_write_char, @function
hrdbf_write_char:
.Lhrdbf_entry_hrdbf_write_char:
	endbr64
	cmpb	$67, 11(%rsi)
	movl	$3, %eax
	jne	.Lhrdbf_1371
	movzwl	14(%rsi), %eax
	addq	%rax, %rdi
	movzbl	12(%rsi), %eax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	testq	%rcx, %rcx
	je	.Lhrdbf_1373
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1374:
	movzbl	(%rdx,%rax), %r8d
	movb	%r8b, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_1374
	movzbl	12(%rsi), %eax
.Lhrdbf_1373:
	cmpq	%rcx, %rax
	jbe	.Lhrdbf_1376
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1375:
	movb	$32, (%rdi,%rcx)
	movzbl	12(%rsi), %eax
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_1375
.Lhrdbf_1376:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1371:
	ret
	.size	hrdbf_write_char, .-hrdbf_write_char
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.type	hrdbf_write_number_scaled, @function
hrdbf_write_number_scaled:
.Lhrdbf_entry_hrdbf_write_number_scaled:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.Lhrdbf_1385
	jmp .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1385:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_scaled, .-hrdbf_write_number_scaled
	.p2align 4
	.globl	hrdbf_write_number_double
	.type	hrdbf_write_number_double, @function
hrdbf_write_number_double:
.Lhrdbf_entry_hrdbf_write_number_double:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.Lhrdbf_1387
	jmp .Lhrdbf_entry_hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1387:
	movl	$3, %eax
	ret
	.size	hrdbf_write_number_double, .-hrdbf_write_number_double
	.p2align 4
	.globl	hrdbf_write_date
	.type	hrdbf_write_date, @function
hrdbf_write_date:
.Lhrdbf_entry_hrdbf_write_date:
	endbr64
	cmpb	$68, 11(%rsi)
	movl	%edx, %ecx
	movl	$3, %r8d
	jne	.Lhrdbf_1388
	movzwl	14(%rsi), %eax
	addq	%rdi, %rax
	testl	%edx, %edx
	je	.Lhrdbf_1403
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
	ja	.Lhrdbf_1388
	cmpl	$9999, %ecx
	jbe	.Lhrdbf_1388
	testl	%edi, %edi
	je	.Lhrdbf_1388
	leal	-2(%rdx), %ecx
	movl	$31, %r10d
	cmpl	$9, %ecx
	jbe	.Lhrdbf_1404
.Lhrdbf_1392:
	movl	$3518437209, %esi
	imulq	%r9, %rsi
	shrq	$45, %rsi
	cmpl	$2, %edx
	je	.Lhrdbf_1405
.Lhrdbf_1393:
	movl	$5, %r8d
	cmpl	%edi, %r10d
	jb	.Lhrdbf_1388
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
.Lhrdbf_1388:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1403:
	leaq	8(%rax), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1391:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1391
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1388
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1404:
	movl	hrdbf_local_CSWTCH.348(,%rcx,4), %r10d
	jmp	.Lhrdbf_1392
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1405:
	testb	$3, %sil
	jne	.Lhrdbf_1393
	imull	$-1030792151, %esi, %ecx
	movl	%ecx, %r8d
	rorl	$2, %r8d
	cmpl	$42949672, %r8d
	ja	.Lhrdbf_1394
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbf_1393
.Lhrdbf_1394:
	addl	$1, %r10d
	jmp	.Lhrdbf_1393
	.size	hrdbf_write_date, .-hrdbf_write_date
	.p2align 4
	.globl	hrdbf_write_logical
	.type	hrdbf_write_logical, @function
hrdbf_write_logical:
.Lhrdbf_entry_hrdbf_write_logical:
	endbr64
	cmpb	$76, 11(%rsi)
	movl	$3, %eax
	jne	.Lhrdbf_1406
	cmpb	$1, %dl
	movzwl	14(%rsi), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	xorl	%eax, %eax
.Lhrdbf_1406:
	ret
	.size	hrdbf_write_logical, .-hrdbf_write_logical
	.p2align 4
	.globl	hrdbf_write_blank
	.type	hrdbf_write_blank, @function
hrdbf_write_blank:
.Lhrdbf_entry_hrdbf_write_blank:
	endbr64
	movzbl	11(%rsi), %eax
	movzwl	14(%rsi), %edx
	leal	-67(%rax), %ecx
	cmpb	$1, %cl
	jbe	.Lhrdbf_1418
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbf_1417
.Lhrdbf_1418:
	movzbl	12(%rsi), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_1416
	leaq	(%rdi,%rdx), %rax
	subl	$1, %ecx
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1415:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1415
.Lhrdbf_1416:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1417:
	movl	$3, %eax
	ret
	.size	hrdbf_write_blank, .-hrdbf_write_blank
	.p2align 4
	.globl	hrdbf_write_deleted
	.type	hrdbf_write_deleted, @function
hrdbf_write_deleted:
.Lhrdbf_entry_hrdbf_write_deleted:
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
.Lhrdbf_entry_hrdbf_file_close:
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
	je	.Lhrdbf_1429
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
	js	.Lhrdbf_1435
.Lhrdbf_1429:
	xorl	%r9d, %r9d
.Lhrdbf_1428:
	movq	2256(%r8), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1426
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1431
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.Lhrdbf_1426:
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1435:
	movl	$7, %r9d
	jmp	.Lhrdbf_1428
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1431:
	movl	$7, %r9d
	movl	%r9d, %eax
	ret
	.size	hrdbf_file_close, .-hrdbf_file_close
	.section	.rodata
	.align 8
.Lhrdbf_C47:
	.string	"OS open failed (missing file, permission or sharing conflict)"
	.section	.rodata
.Lhrdbf_C48:
	.string	"OS seek failed"
.Lhrdbf_C49:
	.string	"file size "
.Lhrdbf_C50:
	.string	" exceeds the 64 MiB limit"
	.section	.rodata
	.align 8
.Lhrdbf_C51:
	.string	"out of memory snapshotting the file"
	.section	.rodata
.Lhrdbf_C52:
	.string	"OS read failed"
	.section	.rodata
	.align 8
.Lhrdbf_C53:
	.string	"file changed size while being read"
	.text
	.p2align 4
	.type	hrdbf_file_open.part.0, @function
hrdbf_file_open.part.0:
.Lhrdbf_entry_hrdbf_file_open.part.0:
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
.Lhrdbf_1437:
	movq	%r8, %rax
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_1437
	testq	%rax, %rax
	js	.Lhrdbf_1475
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
	movl	$.Lhrdbf_C48, %esi
	movq	%rax, %r13
	movq	%rax, %rdx
	testq	%rax, %rax
	js	.Lhrdbf_1473
	cmpq	$32, %rax
	jle	.Lhrdbf_1476
	cmpq	$67108864, %rax
	jg	.Lhrdbf_1477
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1478
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
	jb	.Lhrdbf_1446
	movq	$0, 2256(%rbp)
.Lhrdbf_1447:
	movq	$0, 2264(%rbp)
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C51, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
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
	js	.Lhrdbf_1474
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1441:
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r10d
.Lhrdbf_1436:
	addq	$24, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1481:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C52, %esi
.Lhrdbf_1473:
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
.Lhrdbf_1472:
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
	jmp	.Lhrdbf_1441
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1446:
	movq	%rax, 2256(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_1447
	movq	2264(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.Lhrdbf_1448
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1449:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1452:
	movq	%r8, %rax
	movq	%r12, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_1452
	testq	%rax, %rax
	jne	.Lhrdbf_1479
	movq	2264(%rbp), %rdx
	movq	2256(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1454
	movl	2272(%rbp), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_1480
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
	jns	.Lhrdbf_1436
	jmp	.Lhrdbf_1474
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1482:
	movq	2256(%rbp), %rsi
.Lhrdbf_1448:
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
	je	.Lhrdbf_1450
	testq	%rax, %rax
	jle	.Lhrdbf_1481
	addq	%rax, %r8
.Lhrdbf_1450:
	movq	2264(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_1482
	jmp	.Lhrdbf_1449
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1477:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C49, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fdec
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C50, %esi
	call .Lhrdbf_entry_hrdbf_local_fcat
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
	jns	.Lhrdbf_1441
	jmp	.Lhrdbf_1474
.Lhrdbf_1479:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C53, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_1474:
	movl	$7, %r10d
	jmp	.Lhrdbf_1441
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1476:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C4, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
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
	jns	.Lhrdbf_1441
	jmp	.Lhrdbf_1474
.Lhrdbf_1475:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C47, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
	movl	$7, %r10d
	jmp	.Lhrdbf_1436
.Lhrdbf_1478:
	movl	$.Lhrdbf_C48, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fset
	jmp	.Lhrdbf_1472
.Lhrdbf_1454:
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
	jns	.Lhrdbf_1441
	jmp	.Lhrdbf_1474
.Lhrdbf_1480:
	movq	%r12, 2280(%rbp)
	movb	$1, 2288(%rbp)
	jmp	.Lhrdbf_1436
	.size	hrdbf_file_open.part.0, .-hrdbf_file_open.part.0
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
# 12 "runtime/hrdbf_file_linux.c" 1
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
	je	.Lhrdbf_1485
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1486:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_1486
.Lhrdbf_1485:
	movl	$1, %eax
	movl	$2, %edi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrdbf_app_exit
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.section	.rodata
	.align 8
.Lhrdbf_C54:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbf_C55:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,115,116,114,105,110,103,32,97,108,108,111,99,97,116,105,111,110,32,102,97,105,108,101,100,10,0
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
	jne	.Lhrdbf_1503
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_1504
	cmpb	$78, %al
	je	.Lhrdbf_1505
	cmpb	$68, %al
	je	.Lhrdbf_1506
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1504:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_1507
.Lhrdbf_1492:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_1508
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1506:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1505:
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
.Lhrdbf_1507:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_1495
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1494:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1494
.Lhrdbf_1495:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_1492
.Lhrdbf_1503:
	movl	$.Lhrdbf_C54, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1508:
	movl	$.Lhrdbf_C55, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.section	.rodata
.Lhrdbf_C56:
	.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.section	.rodata
	.align 8
.Lhrdbf_C57:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbf_C58:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbf_C59:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,110,111,32,114,101,99,111,114,100,32,112,111,115,105,116,105,111,110,101,100,10,0
	.text
	.p2align 4
	.type	hrdbf_app_require_writable, @function
hrdbf_app_require_writable:
.Lhrdbf_entry_hrdbf_app_require_writable:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1514
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1515
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_1516
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbf_1517
	ret
.Lhrdbf_1514:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1517:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1516:
	movl	$.Lhrdbf_C58, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1515:
	movl	$.Lhrdbf_C57, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_require_writable, .-hrdbf_app_require_writable
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
.Lhrdbf_entry_hrdbf_file_open:
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
	jne	.Lhrdbf_1519
	movq	2256(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1521
	movq	2264(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1518
.Lhrdbf_1527:
	movq	$0, 2256(%r8)
	movq	$0, 2264(%r8)
.Lhrdbf_1521:
	movl	%r9d, %edx
	movq	%r10, %rsi
	movq	%r8, %rdi
	jmp .Lhrdbf_entry_hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1519:
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
	js	.Lhrdbf_1531
	testq	%rdi, %rdi
	je	.Lhrdbf_1521
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1527
.Lhrdbf_1518:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1531:
	testq	%rdi, %rdi
	je	.Lhrdbf_1518
	movq	2264(%r8), %rsi
	movl	$11, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1518
	movq	$0, 2256(%r8)
	movl	$7, %eax
	movq	$0, 2264(%r8)
	ret
	.size	hrdbf_file_open, .-hrdbf_file_open
	.p2align 4
	.globl	hrdbf_file_write_record
	.type	hrdbf_file_write_record, @function
hrdbf_file_write_record:
.Lhrdbf_entry_hrdbf_file_write_record:
	endbr64
	movl	2272(%rdi), %edx
	movq	%rdi, %r8
	movl	$6, %eax
	testl	%edx, %edx
	je	.Lhrdbf_1532
	cmpb	$0, 2288(%rdi)
	je	.Lhrdbf_1532
	cmpb	$0, 40(%rdi)
	je	.Lhrdbf_1532
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1532
	movl	16(%rdi), %edx
	cmpq	%rsi, %rdx
	jb	.Lhrdbf_1532
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
	je	.Lhrdbf_1536
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1534:
	movq	2280(%r8), %rdi
	movq	%r9, %rax
#APP
# 13 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_1534
	testq	%rax, %rax
	jle	.Lhrdbf_1542
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1542
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_1534
.Lhrdbf_1536:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1542:
	movl	$7, %eax
.Lhrdbf_1532:
	ret
	.size	hrdbf_file_write_record, .-hrdbf_file_write_record
	.p2align 4
	.globl	hrdbf_file_append
	.type	hrdbf_file_append, @function
hrdbf_file_append:
.Lhrdbf_entry_hrdbf_file_append:
	endbr64
	movl	2272(%rdi), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1551
	cmpb	$0, 2288(%rdi)
	je	.Lhrdbf_1551
	cmpb	$0, 40(%rdi)
	je	.Lhrdbf_1551
	jmp .Lhrdbf_entry_hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1551:
	movl	$6, %eax
	ret
	.size	hrdbf_file_append, .-hrdbf_file_append
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
	je	.Lhrdbf_1558
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1563:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl $1, %edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_1576
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1562
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1560:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1576
.Lhrdbf_1562:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.Lhrdbf_1560
	jnb	.Lhrdbf_1576
	leal	1(%rdi), %r10d
.Lhrdbf_1559:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_1563
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_1567
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.Lhrdbf_1566:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.Lhrdbf_1568
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1569
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1601:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1568
.Lhrdbf_1569:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.Lhrdbf_1601
.Lhrdbf_1567:
	testl	%ebp, %ebp
	je	.Lhrdbf_1557
	testl	%r12d, %r12d
	jne	.Lhrdbf_1602
	movl	%r10d, %r11d
.Lhrdbf_1557:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1576:
	movl	%edi, %r11d
	jmp	.Lhrdbf_1559
.Lhrdbf_1568:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.Lhrdbf_1557
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_1570
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1575:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl $1, %edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_1571
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1574
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1572:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1571
.Lhrdbf_1574:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.Lhrdbf_1572
	jb	.Lhrdbf_1571
	movl	%edi, %r11d
.Lhrdbf_1573:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_1575
.Lhrdbf_1570:
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
.Lhrdbf_1571:
	leal	1(%rdi), %r10d
	jmp	.Lhrdbf_1573
.Lhrdbf_1602:
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
.Lhrdbf_1558:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_1557
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.Lhrdbf_1566
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata
.Lhrdbf_C60:
	.byte 104,98,99,58,32,68,66,70,47,78,84,88,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
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
	je	.Lhrdbf_1604
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
	js	.Lhrdbf_1604
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_1604:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1605
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1616
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1605:
	cmpb	$0, hrdbf_app_state+2288(%rip)
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+2272(%rip)
	je	.Lhrdbf_1610
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
	js	.Lhrdbf_1623
.Lhrdbf_1610:
	movq	hrdbf_app_state+2256(%rip), %rdi
	xorl	%r9d, %r9d
	testq	%rdi, %rdi
	je	.Lhrdbf_1608
.Lhrdbf_1607:
	movq	hrdbf_app_state+2264(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1611
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%r9d, %r8d
	movq	$0, hrdbf_app_state+2264(%rip)
.Lhrdbf_1608:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%r8d, %r8d
	jne	.Lhrdbf_1613
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1623:
	movq	hrdbf_app_state+2256(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1611
	movl	$7, %r9d
	jmp	.Lhrdbf_1607
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1616:
	movl	$7, %r8d
	jmp	.Lhrdbf_1605
.Lhrdbf_1611:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbf_1613:
	movl	$.Lhrdbf_C60, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata
.Lhrdbf_C61:
	.string	"table format not supported"
	.section	.rodata
	.align 8
.Lhrdbf_C62:
	.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbf_C63:
	.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbf_C64:
	.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.section	.rodata
.Lhrdbf_C65:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
.Lhrdbf_C66:
	.string	"hbc: DBF open rejected: "
.Lhrdbf_C67:
	.byte 10,0
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
	je	.Lhrdbf_1625
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_1673
.Lhrdbf_1625:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_1674
	xorl	%r9d, %r9d
	jmp	.Lhrdbf_1626
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1654:
	movq	%r10, %r9
.Lhrdbf_1626:
	movzbl	(%rbx,%r9), %eax
	testb	%al, %al
	je	.Lhrdbf_1675
	leaq	1(%r9), %r10
	movb	%al, (%rsp,%r9)
	cmpq	%r10, %rsi
	jne	.Lhrdbf_1654
	movq	hrdbf_app_order+32(%rip), %r13
	movb	$0, (%rsp,%r10)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r13, %r13
	je	.Lhrdbf_1676
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
	js	.Lhrdbf_1631
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1635
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1634
.Lhrdbf_1636:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1635:
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
.Lhrdbf_1638:
	movzbl	(%rbx,%rax), %esi
	movq	%rax, %rdx
	addq	$1, %rax
	cmpb	$47, %sil
	cmove	%rax, %rcx
	cmpq	%rdx, %r9
	jne	.Lhrdbf_1638
	cmpq	%r10, %rcx
	jnb	.Lhrdbf_1639
	movq	%rcx, %rax
	jmp	.Lhrdbf_1641
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1655:
	movq	%rdx, %rax
.Lhrdbf_1641:
	cmpb	$46, (%rbx,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %r10
	cmpq	%r9, %rax
	jne	.Lhrdbf_1655
.Lhrdbf_1639:
	subq	%rcx, %r10
	leaq	(%rbx,%rcx), %rdi
	movl	$0, %edx
	movq	%r10, hrdbf_app_baselen(%rip)
	je	.Lhrdbf_1646
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1642:
	movzbl	(%rdi,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rdx, %r10
	jne	.Lhrdbf_1642
.Lhrdbf_1646:
	xorl	%r10d, %r10d
	movl	$hrdbf_app_state, %edi
	testq	%r8, %r8
	movb	$0, hrdbf_app_state+2289(%rip)
	setne	%r10b
	call .Lhrdbf_entry_hrdbf_file_close
	testl	%eax, %eax
	jne	.Lhrdbf_1643
	movl	%r10d, %edx
	movq	%rsp, %rsi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbf_1643
	addq	$4104, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1631:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1634
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r12, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1634
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1634:
	movl	$.Lhrdbf_C65, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1676:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1635
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r13, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1636
	jmp	.Lhrdbf_1634
.Lhrdbf_1675:
	movl	$.Lhrdbf_C64, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1674:
	movl	$.Lhrdbf_C63, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1673:
	movl	$.Lhrdbf_C62, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1643:
	cmpb	$0, hrdbf_app_state+2289(%rip)
	movl	$hrdbf_app_state+2289, %r8d
	movl	$hrdbf_app_state+2090, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.Lhrdbf_1649
	subl	$2, %eax
	movl	$.Lhrdbf_C61, %r8d
	cmpl	$6, %eax
	ja	.Lhrdbf_1649
	movq	hrdbf_local_CSWTCH.377(,%rax,8), %r8
.Lhrdbf_1649:
	xorl	%edx, %edx
.Lhrdbf_1650:
	addq	$1, %rdx
	cmpb	$0, .Lhrdbf_C66(%rdx)
	jne	.Lhrdbf_1650
	movl	$1, %eax
	movl	$2, %edi
	movl	$.Lhrdbf_C66, %esi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.Lhrdbf_1651
.Lhrdbf_1652:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.Lhrdbf_1652
.Lhrdbf_1651:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$.Lhrdbf_C67, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrdbf_app_exit
	.size	hrdbf_app_open, .-hrdbf_app_open
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1683
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1684
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbf_1685
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbf_1682:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1685:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbf_1682
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1684:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbf_1683:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
.Lhrdbf_entry_hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1694
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1695
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rax
	testl	%esi, %esi
	jne	.Lhrdbf_1696
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.Lhrdbf_1691:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
.Lhrdbf_1692:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%eax, %eax
	sete	%al
.Lhrdbf_1689:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1696:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_1691
	movq	hrdbf_app_order+16(%rip), %rdx
	movl	(%rdx,%rcx,8), %edx
	jmp	.Lhrdbf_1692
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1695:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmovne	%rax, %rdx
	sete	%al
	movl	%eax, %ecx
	jmp	.Lhrdbf_1689
.Lhrdbf_1694:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1711
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1712
	testq	%rdi, %rdi
	je	.Lhrdbf_1697
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbf_1701
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.Lhrdbf_1707
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.Lhrdbf_1702:
	movq	%rsi, hrdbf_app_pos(%rip)
.Lhrdbf_1703:
	cmpq	%rax, %rsi
	jnb	.Lhrdbf_1705
.Lhrdbf_1713:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.Lhrdbf_1706:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbf_1697:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1701:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.Lhrdbf_1704
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	cmpq	%rax, %rsi
	jb	.Lhrdbf_1713
.Lhrdbf_1705:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbf_1706
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1707:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.Lhrdbf_1702
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1704:
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbf_1703
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1712:
	movq	%rdi, %rsi
	movl	$hrdbf_app_state, %edi
	jmp .Lhrdbf_entry_hrdbf_skip
.Lhrdbf_1711:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata
	.align 8
.Lhrdbf_C68:
	.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbf_C69:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbf_C70:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbf_C71:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbf_C72:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbf_C73:
	.byte 104,98,99,58,32,67,68,88,32,109,117,115,116,32,117,115,101,32,97,32,100,105,102,102,101,114,101,110,116,32,98,97,115,101,110,97,109,101,32,102,114,111,109,32,68,66,70,59,32,115,116,114,117,99,116,117,114,97,108,47,97,117,116,111,111,112,101,110,32,105,110,100,101,120,101,115,32,97,114,101,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
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
	je	.Lhrdbf_1841
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_1842
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.Lhrdbf_1843
	xorl	%ecx, %ecx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1717:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.Lhrdbf_1844
	movb	%dl, 32(%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %dl
	leaq	32(%rsp), %r8
	cmove	%rax, %rcx
	cmpq	%rsi, %rax
	jne	.Lhrdbf_1717
	movl	hrdbf_app_cdx(%rip), %ebp
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_1720
	movq	%rsi, %rdx
	movq	%rcx, %rax
	xorl	%r9d, %r9d
	movl	$1, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1722:
	cmpb	$46, (%rdi,%rax)
	cmove	%rax, %rdx
	cmove	%r10d, %r9d
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbf_1722
	testl	%ebp, %ebp
	jne	.Lhrdbf_1845
	testl	%r9d, %r9d
	je	.Lhrdbf_1725
.Lhrdbf_1777:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, 32(%rsp,%rax)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_1846
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
	js	.Lhrdbf_1847
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1735
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1774
.Lhrdbf_1739:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1735:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1740:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 14 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_1740
	testq	%rax, %rax
	js	.Lhrdbf_1774
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
	js	.Lhrdbf_1741
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.Lhrdbf_1742
	cmpl	$1, %ebp
	movq	%r12, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.Lhrdbf_1742
	movq	%r8, %rax
	movq	%rdx, %rsi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1745
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
	jb	.Lhrdbf_1746
	movq	$0, hrdbf_app_order+32(%rip)
.Lhrdbf_1747:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbf_1837
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1845:
	movq	hrdbf_app_baselen(%rip), %r11
	subq	%rcx, %rdx
	cmpq	%r11, %rdx
	je	.Lhrdbf_1778
.Lhrdbf_1727:
	movq	%rsi, %rax
	testl	%r9d, %r9d
	jne	.Lhrdbf_1777
.Lhrdbf_1776:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	movl	$100, %eax
	movb	$99, 33(%rsp,%rsi)
.Lhrdbf_1775:
	movb	%al, 32(%rsp,%rdx)
	leaq	4(%rsi), %rax
	movb	$120, 35(%rsp,%rsi)
	jmp	.Lhrdbf_1777
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1742:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rsi, %rdx
.Lhrdbf_1840:
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r10d
	testq	%rax, %rax
	js	.Lhrdbf_1839
.Lhrdbf_1751:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1767
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
	js	.Lhrdbf_1768
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1770
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1774
.Lhrdbf_1772:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1770:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbf_1774
	movl	$.Lhrdbf_C68, %edi
	cmpl	$3, %r10d
	je	.Lhrdbf_1738
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1774:
	movl	$.Lhrdbf_C69, %edi
.Lhrdbf_1738:
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1846:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1735
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1739
	jmp	.Lhrdbf_1774
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1847:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1774
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1774
.Lhrdbf_1771:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.Lhrdbf_1774
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1725:
	movb	$46, 32(%rsp,%rsi)
	leaq	2(%rsi), %rdx
	xorl	%ebp, %ebp
	movl	$116, %eax
	movb	$110, 33(%rsp,%rsi)
	jmp	.Lhrdbf_1775
.Lhrdbf_1768:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1774
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1771
	jmp	.Lhrdbf_1774
.Lhrdbf_1753:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_1839:
	movl	$7, %r10d
	jmp	.Lhrdbf_1751
.Lhrdbf_1720:
	testl	%ebp, %ebp
	je	.Lhrdbf_1725
	movq	%rsi, %r11
	subq	%rcx, %r11
	cmpq	%r11, hrdbf_app_baselen(%rip)
	jne	.Lhrdbf_1776
	xorl	%r9d, %r9d
.Lhrdbf_1778:
	testq	%r11, %r11
	je	.Lhrdbf_1728
	movl	$1, %r10d
	xorl	%edx, %edx
	leaq	(%rdi,%rcx), %r12
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1731:
	movzbl	(%r12,%rdx), %eax
	leal	-97(%rax), %edi
	leal	-32(%rax), %ecx
	cmpb	$26, %dil
	cmovb	%ecx, %eax
	cmpb	%al, hrdbf_app_basename(%rdx)
	cmovne	%ebx, %r10d
	addq	$1, %rdx
	cmpq	%r11, %rdx
	jne	.Lhrdbf_1731
	testl	%r10d, %r10d
	je	.Lhrdbf_1727
.Lhrdbf_1728:
	movl	$.Lhrdbf_C73, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1741:
	movl	$3, %eax
	movq	%rsi, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1751
.Lhrdbf_1767:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1770
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1772
	jmp	.Lhrdbf_1774
.Lhrdbf_1746:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_1747
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_1748
	jmp	.Lhrdbf_1749
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1848:
	movq	hrdbf_app_order+32(%rip), %rsi
.Lhrdbf_1748:
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
	je	.Lhrdbf_1752
	testq	%rax, %rax
	jle	.Lhrdbf_1753
	addq	%rax, %r8
.Lhrdbf_1752:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_1848
.Lhrdbf_1749:
	leaq	31(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1754:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_1754
	testq	%rax, %rax
	jne	.Lhrdbf_1755
	cmpl	$1, %ebp
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.Lhrdbf_1757
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
	jb	.Lhrdbf_1758
	movq	$0, hrdbf_app_order+40(%rip)
.Lhrdbf_1759:
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1837:
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
	jns	.Lhrdbf_1751
	jmp	.Lhrdbf_1839
.Lhrdbf_1755:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1751
.Lhrdbf_1745:
	movl	$3, %eax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r10d
	jmp	.Lhrdbf_1751
.Lhrdbf_1757:
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
	jns	.Lhrdbf_1751
	jmp	.Lhrdbf_1839
.Lhrdbf_1758:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbf_1759
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
	je	.Lhrdbf_1763
	cmpl	$5, %eax
	movq	%rbx, %rdi
	movq	%r13, %rax
	movq	%r12, %rsi
	movq	%r12, %rdx
	jne	.Lhrdbf_1840
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$3, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_1751
	jmp	.Lhrdbf_1839
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1763:
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
	js	.Lhrdbf_1839
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
.Lhrdbf_1844:
	movl	$.Lhrdbf_C72, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1841:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1843:
	movl	$.Lhrdbf_C71, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1842:
	movl	$.Lhrdbf_C70, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
.Lhrdbf_entry_hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1863
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1864
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
	js	.Lhrdbf_1854
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1858
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1857
.Lhrdbf_1859:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1858:
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1854:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1857
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_1857
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1857:
	movl	$.Lhrdbf_C65, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1864:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1858
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_1859
	jmp	.Lhrdbf_1857
.Lhrdbf_1863:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
.Lhrdbf_entry_hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1867
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbf_1867:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata
	.align 8
.Lhrdbf_C74:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
.Lhrdbf_entry_hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1874
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_1875
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
	jb	.Lhrdbf_1876
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.Lhrdbf_1872:
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
.Lhrdbf_1876:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.Lhrdbf_1872
.Lhrdbf_1875:
	movl	$.Lhrdbf_C74, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1874:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1879
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_1879:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1882
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_1882:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1885
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_1885:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1888
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_1888:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1893
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1889
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_1889:
	movq	%r8, %rax
	ret
.Lhrdbf_1893:
	movl	$.Lhrdbf_C56, %edi
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
	je	.Lhrdbf_1900
	testq	%rdi, %rdi
	jle	.Lhrdbf_1898
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.Lhrdbf_1901
.Lhrdbf_1898:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1901:
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.Lhrdbf_1900:
	movl	$.Lhrdbf_C56, %edi
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
	je	.Lhrdbf_1903
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.Lhrdbf_1905
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1916:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1906:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_1907
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_1906
.Lhrdbf_1907:
	cmpq	%rax, %r9
	je	.Lhrdbf_1928
.Lhrdbf_1909:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.Lhrdbf_1916
.Lhrdbf_1905:
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
	movl	$.Lhrdbf_C67, %esi
	movq	%rbx, %rax
	movq	%rbx, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
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
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
	.p2align 4,,10
	.p2align 3
#NO_APP
.Lhrdbf_1928:
	testq	%r9, %r9
	je	.Lhrdbf_1910
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_1914
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1929:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.Lhrdbf_1910
.Lhrdbf_1914:
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
	je	.Lhrdbf_1929
	cmpq	%rcx, %r9
	jne	.Lhrdbf_1909
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1910:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.Lhrdbf_1930
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1930:
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_1903:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata
	.align 8
.Lhrdbf_C75:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbf_C76:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbf_C77:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbf_C78:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_fieldput
	.type	hrdbf_app_fieldput, @function
hrdbf_app_fieldput:
.Lhrdbf_entry_hrdbf_app_fieldput:
	endbr64
	pushq	%r12
	movq	%rdi, %r10
	movq	%rdx, %r12
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$8, %rsp
	call .Lhrdbf_entry_hrdbf_app_require_writable
	testq	%r10, %r10
	jle	.Lhrdbf_1932
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%r10, %rax
	jl	.Lhrdbf_1932
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
	je	.Lhrdbf_1934
	ja	.Lhrdbf_1935
	cmpb	$67, %dl
	je	.Lhrdbf_1936
	cmpb	$68, %dl
	jne	.Lhrdbf_1938
	cmpl	$11, %ecx
	je	.Lhrdbf_1993
	cmpl	$1, %ecx
	jne	.Lhrdbf_1938
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_1947
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_1958
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1994:
	addq	$1, %rdx
.Lhrdbf_1958:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_1994
.Lhrdbf_1943:
	movq	hrdbf_app_state+24(%rip), %rsi
.Lhrdbf_1947:
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbf_1995
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1935:
	cmpb	$78, %dl
	jne	.Lhrdbf_1938
	cmpl	$12, %ecx
	je	.Lhrdbf_1996
	testl	%ecx, %ecx
	je	.Lhrdbf_1966
	cmpl	$9, %ecx
	je	.Lhrdbf_1966
	cmpl	$5, %ecx
	je	.Lhrdbf_1997
	cmpl	$1, %ecx
	jne	.Lhrdbf_1938
	salq	$4, %rdi
	movzbl	hrdbf_app_state+54(%rdi), %ecx
	movzwl	hrdbf_app_state+56(%rdi), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_1947
	addq	%rax, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.Lhrdbf_1956
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1998:
	addq	$1, %rax
.Lhrdbf_1956:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rax, %rcx
	jne	.Lhrdbf_1998
	jmp	.Lhrdbf_1943
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1936:
	leal	-2(%rcx), %edx
	andl	$-3, %edx
	je	.Lhrdbf_1999
	cmpl	$1, %ecx
	jne	.Lhrdbf_1938
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_1947
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_1948
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2000:
	addq	$1, %rdx
.Lhrdbf_1948:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_2000
	jmp	.Lhrdbf_1943
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1934:
	cmpl	$3, %ecx
	je	.Lhrdbf_2001
	cmpl	$1, %ecx
	jne	.Lhrdbf_1938
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_1947
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_1961
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2002:
	addq	$1, %rdx
.Lhrdbf_1961:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_2002
	jmp	.Lhrdbf_1943
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2001:
	cmpq	$1, %r12
	movzwl	24(%r10), %ecx
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rax,%rcx)
	movq	hrdbf_app_state+24(%rip), %rsi
	jmp	.Lhrdbf_1947
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1999:
	movzwl	24(%r10), %ecx
	movzbl	22(%r10), %edx
	addq	%rax, %rcx
	movq	-8(%r12), %rax
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rax, %rax
	je	.Lhrdbf_1941
	movq	%rcx, %rsi
	leaq	(%r12,%rax), %r8
	subq	%r12, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1942:
	movzbl	(%r12), %edx
	movb	%dl, (%rsi,%r12)
	addq	$1, %r12
	cmpq	%r8, %r12
	jne	.Lhrdbf_1942
	movq	%rdi, %rdx
	salq	$4, %rdx
	movzbl	hrdbf_app_state+54(%rdx), %edx
.Lhrdbf_1941:
	cmpq	%rdx, %rax
	jnb	.Lhrdbf_1943
	salq	$4, %rdi
	leaq	hrdbf_app_state+32(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1944:
	movb	$32, (%rcx,%rax)
	movzbl	22(%rsi), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbf_1944
	jmp	.Lhrdbf_1943
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1993:
	movl	%r12d, %edx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_date
.Lhrdbf_1950:
	cmpl	$3, %eax
	je	.Lhrdbf_1938
	testl	%eax, %eax
	je	.Lhrdbf_1943
	movl	$.Lhrdbf_C77, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1996:
	movzbl	%bh, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbf_1950
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1966:
	xorl	%ecx, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbf_1950
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1997:
	testq	%rbx, %rbx
	jns	.Lhrdbf_1954
	movq	(%r12), %r12
.Lhrdbf_1954:
	movq	%r12, %xmm0
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_double.part.0
	jmp	.Lhrdbf_1950
.Lhrdbf_1938:
	movl	$.Lhrdbf_C76, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1932:
	movl	$.Lhrdbf_C75, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1995:
	movl	$.Lhrdbf_C78, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_fieldput, .-hrdbf_app_fieldput
	.p2align 4
	.globl	hrdbf_app_set_name
	.type	hrdbf_app_set_name, @function
hrdbf_app_set_name:
.Lhrdbf_entry_hrdbf_app_set_name:
	endbr64
	pushq	%r12
	movq	%rsi, %r10
	movq	%rcx, %r12
	pushq	%rbp
	movq	%rdx, %rbp
	pushq	%rbx
	movq	%rdi, %rbx
	call .Lhrdbf_entry_hrdbf_app_require_writable
	movzwl	hrdbf_app_state+36(%rip), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_2004
	movl	$hrdbf_app_state+42, %esi
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2014:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2005:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_2006
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_2005
.Lhrdbf_2006:
	cmpq	%rax, %r10
	je	.Lhrdbf_2027
.Lhrdbf_2008:
	addl	$1, %r9d
	addq	$16, %rsi
	cmpl	%r9d, %r11d
	jne	.Lhrdbf_2014
.Lhrdbf_2004:
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
	movl	$.Lhrdbf_C67, %esi
	movq	%rbp, %rax
	movq	%rbp, %rdx
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
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
.Lhrdbf_2027:
	testq	%r10, %r10
	je	.Lhrdbf_2009
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_2013
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2028:
	addq	$1, %rcx
	cmpq	%rcx, %r10
	je	.Lhrdbf_2009
.Lhrdbf_2013:
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
	je	.Lhrdbf_2028
	cmpq	%rcx, %r10
	jne	.Lhrdbf_2008
.Lhrdbf_2009:
	popq	%rbx
	movq	%r12, %rdx
	leal	1(%r9), %edi
	movq	%rbp, %rsi
	popq	%rbp
	popq	%r12
	jmp .Lhrdbf_entry_hrdbf_app_fieldput
	.size	hrdbf_app_set_name, .-hrdbf_app_set_name
	.section	.rodata
.Lhrdbf_C79:
	.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_append
	.type	hrdbf_app_append, @function
hrdbf_app_append:
.Lhrdbf_entry_hrdbf_app_append:
	endbr64
	subq	$24, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2037
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2038
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_2039
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbf_2040
	cmpb	$0, hrdbf_app_state+2288(%rip)
	je	.Lhrdbf_2035
	leaq	12(%rsp), %rsi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbf_2035
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	12(%rsp), %eax
	addq	$24, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2035:
	movl	$.Lhrdbf_C79, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2037:
	movl	$.Lhrdbf_C56, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2040:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2039:
	movl	$.Lhrdbf_C58, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2038:
	movl	$.Lhrdbf_C57, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_append, .-hrdbf_app_append
	.section	.rodata
	.align 8
.Lhrdbf_C80:
	.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,114,101,110,100,101,114,32,114,101,106,101,99,116,101,100,10,0
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
	jne	.Lhrdbf_2044
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_2044:
	movl	$.Lhrdbf_C80, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata
	.align 8
.Lhrdbf_C81:
	.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbf_C82:
	.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
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
	jne	.Lhrdbf_2046
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_2062
	testl	%eax, %eax
	je	.Lhrdbf_2054
	cmpl	$9, %eax
	jne	.Lhrdbf_2050
.Lhrdbf_2054:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2062:
	testl	$65280, %r9d
	je	.Lhrdbf_2054
.Lhrdbf_2049:
	movl	$.Lhrdbf_C81, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2046:
	cmpl	$2, %eax
	je	.Lhrdbf_2049
.Lhrdbf_2050:
	movl	$.Lhrdbf_C82, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata
	.align 8
.Lhrdbf_C83:
	.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,99,111,109,112,97,114,105,115,111,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
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
	je	.Lhrdbf_2067
	testl	%eax, %eax
	jne	.Lhrdbf_2068
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_2067:
	movl	$.Lhrdbf_C81, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2068:
	movl	$.Lhrdbf_C83, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata
	.align 8
.Lhrdbf_C84:
	.byte 104,98,99,58,32,68,66,70,32,105,110,118,97,108,105,100,32,68,97,116,101,32,99,111,109,112,97,114,105,115,111,110,10,0
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
	jne	.Lhrdbf_2070
	cmpb	$11, %dl
	je	.Lhrdbf_2112
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2076
.Lhrdbf_2080:
	movl	$.Lhrdbf_C82, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2076:
	cmpl	$2, %eax
	jne	.Lhrdbf_2080
.Lhrdbf_2079:
	movl	$.Lhrdbf_C81, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2070:
	movzbl	%dil, %ebx
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2076
	cmpl	$12, %ebx
	jne	.Lhrdbf_2077
	testl	$65280, %r9d
	jne	.Lhrdbf_2079
.Lhrdbf_2078:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2076
	movzbl	%r10b, %eax
	cmpb	$12, %r10b
	je	.Lhrdbf_2113
	testl	%eax, %eax
	je	.Lhrdbf_2086
	cmpl	$9, %eax
	jne	.Lhrdbf_2080
.Lhrdbf_2086:
	cmpq	%r11, %rbp
	jl	.Lhrdbf_2088
	setg	%al
	movzbl	%al, %eax
.Lhrdbf_2069:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2077:
	testl	%ebx, %ebx
	je	.Lhrdbf_2078
	cmpl	$9, %ebx
	je	.Lhrdbf_2078
	jmp	.Lhrdbf_2080
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2088:
	addq	$8, %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2112:
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2073
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2073
	cmpq	%r11, %rbp
	jb	.Lhrdbf_2088
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbf_2069
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2113:
	testl	$65280, %r10d
	je	.Lhrdbf_2086
	jmp	.Lhrdbf_2079
.Lhrdbf_2073:
	movl	$.Lhrdbf_C84, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata
	.align 8
.Lhrdbf_C86:
	.byte 104,98,99,58,32,68,66,70,32,115,99,97,108,97,114,32,69,109,112,116,121,32,114,101,106,101,99,116,101,100,10,0
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
	jne	.Lhrdbf_2115
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_2125
	movabs	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_2117
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2137:
	btq	%rax, %rcx
	jc	.Lhrdbf_2129
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_2125
.Lhrdbf_2117:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_2137
.Lhrdbf_2129:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2115:
	cmpl	$8, %r10d
	je	.Lhrdbf_2138
	cmpl	$5, %r10d
	je	.Lhrdbf_2139
	cmpl	$7, %r10d
	je	.Lhrdbf_2129
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2122
	cmpl	$12, %r10d
	ja	.Lhrdbf_2122
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_2123
	cmpl	$1, %r10d
	je	.Lhrdbf_2130
.Lhrdbf_2122:
	movl	$.Lhrdbf_C86, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2125:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2138:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_2134
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_2134:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2139:
	testq	%rdi, %rdi
	js	.Lhrdbf_2140
.Lhrdbf_2121:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C85(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_2140:
	movq	(%rsi), %r9
	jmp	.Lhrdbf_2121
.Lhrdbf_2123:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_2114:
	addq	$8, %rsp
	ret
.Lhrdbf_2130:
	movl	$1, %eax
	jmp	.Lhrdbf_2114
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata
	.align 8
.Lhrdbf_C87:
	.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C87, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata
	.align 8
.Lhrdbf_C88:
	.string	"unsupported table version or header flags"
	.section	.rodata
.Lhrdbf_C89:
	.string	"unsupported field type"
	.section	.rodata
	.align 8
.Lhrdbf_C90:
	.string	"size or field-count limit exceeded"
	.section	.rodata
.Lhrdbf_C91:
	.string	"record content invalid"
.Lhrdbf_C92:
	.string	"I/O error"
.Lhrdbf_C93:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.377, @object
	.size	hrdbf_local_CSWTCH.377, 56
hrdbf_local_CSWTCH.377:
.Lhrdbf_entry_hrdbf_local_CSWTCH.377:
	.quad	.Lhrdbf_C88
	.quad	.Lhrdbf_C89
	.quad	.Lhrdbf_C90
	.quad	.Lhrdbf_C91
	.quad	.Lhrdbf_C61
	.quad	.Lhrdbf_C92
	.quad	.Lhrdbf_C93
	.align 32
	.type	hrdbf_local_CSWTCH.348, @object
	.size	hrdbf_local_CSWTCH.348, 40
hrdbf_local_CSWTCH.348:
.Lhrdbf_entry_hrdbf_local_CSWTCH.348:
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
	.section	.rodata
.Lhrdbf_C94:
	.string	"ok"
	.section	.rodata
	.align 8
.Lhrdbf_C95:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C96:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C97:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C98:
	.string	"DBF value tag or metadata invalid"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.339, @object
	.size	hrdbf_local_CSWTCH.339, 40
hrdbf_local_CSWTCH.339:
.Lhrdbf_entry_hrdbf_local_CSWTCH.339:
	.quad	.Lhrdbf_C94
	.quad	.Lhrdbf_C95
	.quad	.Lhrdbf_C96
	.quad	.Lhrdbf_C97
	.quad	.Lhrdbf_C98
	.align 8
	.type	hrdbf_local_CSWTCH.320, @object
	.size	hrdbf_local_CSWTCH.320, 13
hrdbf_local_CSWTCH.320:
.Lhrdbf_entry_hrdbf_local_CSWTCH.320:
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
	.byte 31,28,31,30,31,30,31,31,30,31,30,31
	.align 32
	.type	hrdbf_app_pre_field, @object
	.size	hrdbf_app_pre_field, 44
hrdbf_app_pre_field:
.Lhrdbf_entry_hrdbf_app_pre_field:
	.string	"hbc: DBF field not found in the open area: "

.bss
.balign 8
hrdbf_app_baselen:
.Lhrdbf_entry_hrdbf_app_baselen:
.zero 8
.text

.bss
.balign 32
hrdbf_app_basename:
.Lhrdbf_entry_hrdbf_app_basename:
.zero 4096
.text

.bss
.balign 4
hrdbf_app_cdx:
.Lhrdbf_entry_hrdbf_app_cdx:
.zero 4
.text

.bss
.balign 4
hrdbf_app_found_flag:
.Lhrdbf_entry_hrdbf_app_found_flag:
.zero 4
.text

.bss
.balign 8
hrdbf_app_pos:
.Lhrdbf_entry_hrdbf_app_pos:
.zero 8
.text

.bss
.balign 32
hrdbf_app_order:
.Lhrdbf_entry_hrdbf_app_order:
.zero 64
.text

.bss
.balign 32
hrdbf_app_state:
.Lhrdbf_entry_hrdbf_app_state:
.zero 2456
.text
	.section	.rodata
	.align 8
.Lhrdbf_C85:
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
