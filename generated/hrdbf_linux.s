	.text
	.p2align 4
	.type	hrdbf_local_dset, @function
hrdbf_local_dset:
.Lhrdbf_entry_hrdbf_local_dset:
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	jmp	.Lhrdbf_2
	.p2align 4,,10
	.p2align 3
.Lhrdbf_4:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_3
.Lhrdbf_2:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_4
.Lhrdbf_3:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_dset, .-hrdbf_local_dset
	.p2align 4
	.type	hrdbf_local_dcat, @function
hrdbf_local_dcat:
.Lhrdbf_entry_hrdbf_local_dcat:
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	jmp	.Lhrdbf_7
	.p2align 4,,10
	.p2align 3
.Lhrdbf_9:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_8
.Lhrdbf_7:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_9
	jmp	.Lhrdbf_13
	.p2align 4,,10
	.p2align 3
.Lhrdbf_11:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.Lhrdbf_13:
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_8
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_11
.Lhrdbf_8:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_dcat, .-hrdbf_local_dcat
	.p2align 4
	.type	hrv_to_double, @function
hrv_to_double:
.Lhrdbf_entry_hrv_to_double:
	movl	%edi, %eax
	movq	%rsi, %r9
	andl	$255, %eax
	je	.Lhrdbf_24
	cmpl	$9, %eax
	je	.Lhrdbf_24
	cmpl	$12, %eax
	je	.Lhrdbf_29
	movl	$1, %r8d
	cmpl	$5, %eax
	je	.Lhrdbf_30
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_24:
	pxor	%xmm0, %xmm0
	xorl	%r8d, %r8d
	cvtsi2sdq	%rsi, %xmm0
	movl	%r8d, %eax
	movsd	%xmm0, (%rdx)
	movl	$0, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_30:
	testq	%rdi, %rdi
	js	.Lhrdbf_31
	shrq	$8, %rdi
	movl	$2, %eax
	testl	%edi, %edi
	cmove	%eax, %edi
.Lhrdbf_22:
	xorl	%r8d, %r8d
	movq	%r9, (%rdx)
	movl	%r8d, %eax
	movl	%edi, (%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_29:
	movl	%edi, %eax
	pxor	%xmm0, %xmm0
	andl	$65280, %edi
	movzbl	%ah, %eax
	cvtsi2sdq	%rsi, %xmm0
	movl	%eax, %r8d
	je	.Lhrdbf_19
	movsd	.Lhrdbf_C0(%rip), %xmm1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_20:
	divsd	%xmm1, %xmm0
	addl	$1, %eax
	cmpl	%r8d, %eax
	jne	.Lhrdbf_20
.Lhrdbf_19:
	movsd	%xmm0, (%rdx)
	movl	%r8d, (%rcx)
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_31:
	movq	(%rsi), %r9
	movzwl	8(%rsi), %edi
	jmp	.Lhrdbf_22
	.size	hrv_to_double, .-hrv_to_double
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
	ja	.Lhrdbf_32
	movl	%esi, %ebp
	movq	%rdi, %rdx
	movl	%esi, %r9d
	andl	$31, %ebp
	je	.Lhrdbf_35
	testl	%r12d, %r12d
	je	.Lhrdbf_36
	movl	$32, %r11d
	leal	-1(%r12), %ecx
	movq	%rdi, %rax
	xorl	%r8d, %r8d
	subl	%ebp, %r11d
	leaq	4(%rdi,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_37:
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
	jne	.Lhrdbf_37
	testl	%edi, %edi
	je	.Lhrdbf_41
	leal	1(%r12), %eax
	movl	%eax, 288(%rdx)
	movl	%edi, (%rdx,%r12,4)
.Lhrdbf_41:
	cmpl	$31, %r9d
	jbe	.Lhrdbf_32
	movl	288(%rdx), %r8d
	leal	-1(%r8), %ecx
	addl	%r10d, %r8d
	jmp	.Lhrdbf_46
	.p2align 4,,10
	.p2align 3
.Lhrdbf_35:
	cmpl	$31, %esi
	jbe	.Lhrdbf_32
	leal	-1(%r12), %ecx
	testl	%r12d, %r12d
	je	.Lhrdbf_39
.Lhrdbf_46:
	movl	%ecx, %eax
	addl	%r10d, %ecx
	leaq	(%rdx,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_42:
	movl	(%rax), %edi
	movl	%ecx, %esi
	subl	$1, %ecx
	movl	%edi, (%rdx,%rsi,4)
	movq	%rax, %rsi
	subq	$4, %rax
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_42
.Lhrdbf_39:
	testl	%r10d, %r10d
	je	.Lhrdbf_45
	leal	-1(%r10), %ecx
	movq	%rdx, %rax
	leaq	4(%rdx,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_44:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_44
.Lhrdbf_45:
	movl	%r8d, 288(%rdx)
.Lhrdbf_32:
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_36:
	cmpl	$31, %esi
	jbe	.Lhrdbf_32
	movl	%r10d, %r8d
	jmp	.Lhrdbf_39
	.size	hrdbf_local_bn_shl, .-hrdbf_local_bn_shl
	.p2align 4
	.type	hrdbf_local_bn_divmod_1e9, @function
hrdbf_local_bn_divmod_1e9:
.Lhrdbf_entry_hrdbf_local_bn_divmod_1e9:
	pushq	%rbx
	movl	288(%rdi), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbf_65
	movabs	$19342813113834067, %r11
	movq	%rdi, %r9
	leal	-1(%rbx), %edi
	movl	%edi, %eax
	leaq	(%r9,%rax,4), %r8
	xorl	%eax, %eax
	movq	%r8, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_62:
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
	jne	.Lhrdbf_62
	cmpl	$1, %ebx
	jne	.Lhrdbf_63
	jmp	.Lhrdbf_60
	.p2align 4,,10
	.p2align 3
.Lhrdbf_64:
	movl	%edi, 288(%r9)
	subq	$4, %r8
	subl	$1, %edi
	je	.Lhrdbf_60
.Lhrdbf_63:
	movl	(%r8), %edx
	testl	%edx, %edx
	je	.Lhrdbf_64
.Lhrdbf_60:
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_65:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.size	hrdbf_local_bn_divmod_1e9, .-hrdbf_local_bn_divmod_1e9
	.p2align 4
	.type	hrdbf_local_fset, @function
hrdbf_local_fset:
.Lhrdbf_entry_hrdbf_local_fset:
	leaq	32977(%rdi), %rax
	addq	$33136, %rdi
	jmp	.Lhrdbf_73
	.p2align 4,,10
	.p2align 3
.Lhrdbf_75:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_74
.Lhrdbf_73:
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_75
.Lhrdbf_74:
	movb	$0, (%rax)
	ret
	.size	hrdbf_local_fset, .-hrdbf_local_fset
	.p2align 4
	.type	hrdbf_local_fcat, @function
hrdbf_local_fcat:
.Lhrdbf_entry_hrdbf_local_fcat:
	leaq	32977(%rdi), %rax
	addq	$33136, %rdi
	jmp	.Lhrdbf_77
	.p2align 4,,10
	.p2align 3
.Lhrdbf_79:
	addq	$1, %rax
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_78
.Lhrdbf_77:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_79
	jmp	.Lhrdbf_83
	.p2align 4,,10
	.p2align 3
.Lhrdbf_81:
	movb	%dl, (%rax)
	addq	$1, %rsi
	addq	$1, %rax
.Lhrdbf_83:
	cmpq	%rax, %rdi
	jbe	.Lhrdbf_78
	movzbl	(%rsi), %edx
	testb	%dl, %dl
	jne	.Lhrdbf_81
.Lhrdbf_78:
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
	ja	.Lhrdbf_88
	movl	%esi, %ebx
	testl	%esi, %esi
	je	.Lhrdbf_88
	testl	$1023, %esi
	jne	.Lhrdbf_88
	movq	8(%rax), %rax
	movq	%rdi, %rbp
	movl	%esi, %edi
	subq	$1024, %rax
	cmpq	%rax, %rdi
	ja	.Lhrdbf_88
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
	jne	.Lhrdbf_88
	orl	%edx, %ecx
	leaq	(%r12,%rdi), %r14
	movb	%cl, (%rax)
	movzwl	(%r14), %r13d
	movzwl	32(%rbp), %eax
	cmpw	%r13w, %ax
	jb	.Lhrdbf_88
	testw	%r13w, %r13w
	jne	.Lhrdbf_112
	testl	%esi, %esi
	je	.Lhrdbf_112
	.p2align 4,,10
	.p2align 3
.Lhrdbf_88:
	movl	$1, %eax
.Lhrdbf_84:
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
.Lhrdbf_112:
	leal	4(%rax,%rax), %eax
	xorl	%r11d, %r11d
	leaq	4(%r14), %r15
	movl	%eax, 8(%rsp)
.Lhrdbf_93:
	movzwl	%r11w, %eax
	movzwl	2(%r14,%rax,2), %r8d
	movq	%r8, %rax
	cmpl	8(%rsp), %r8d
	jl	.Lhrdbf_88
	movzwl	34(%rbp), %edx
	addq	%rdx, %rax
	movq	%rdx, %rdi
	cmpq	$1024, %rax
	ja	.Lhrdbf_88
	testw	%r11w, %r11w
	je	.Lhrdbf_90
	leal	-1(%r11), %edx
	leaq	2(%r14), %rax
	movzwl	%dx, %edx
	leal	(%r8,%rdi), %r10d
	leaq	(%r15,%rdx,2), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbf_92:
	movzwl	(%rax), %edx
	leal	(%rdx,%rdi), %ecx
	cmpl	%ecx, %r8d
	jge	.Lhrdbf_91
	cmpl	%r10d, %edx
	jl	.Lhrdbf_88
.Lhrdbf_91:
	addq	$2, %rax
	cmpq	%r9, %rax
	jne	.Lhrdbf_92
.Lhrdbf_90:
	addl	$1, %r11d
	cmpw	%r13w, %r11w
	jbe	.Lhrdbf_93
	movzwl	2(%r14), %eax
	movl	(%r14,%rax), %r15d
	testl	%r15d, %r15d
	jne	.Lhrdbf_94
	movl	40(%rbp), %eax
	testl	%eax, %eax
	js	.Lhrdbf_128
	cmpl	%esi, %eax
	jne	.Lhrdbf_88
.Lhrdbf_94:
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
.Lhrdbf_108:
	movzwl	2(%r13), %ecx
	movl	(%r14,%rcx), %esi
	movq	%rcx, %r8
	testl	%esi, %esi
	setne	%al
	cmpb	23(%rsp), %al
	jne	.Lhrdbf_88
	testl	%r15d, %r15d
	jne	.Lhrdbf_96
.Lhrdbf_99:
	cmpq	%r13, 8(%rsp)
	je	.Lhrdbf_97
	movl	4(%r14,%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbf_101
	movq	8(%rbp), %rdx
	movl	16(%rdx), %edx
	cmpl	%eax, %edx
	jb	.Lhrdbf_101
	cmpl	36(%rbp), %edx
	jbe	.Lhrdbf_101
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
	jne	.Lhrdbf_101
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
	je	.Lhrdbf_102
	xorl	%edx, %edx
	leaq	(%r12,%r8), %rsi
	addq	%r11, %rcx
	jmp	.Lhrdbf_103
	.p2align 4,,10
	.p2align 3
.Lhrdbf_130:
	addq	$1, %rdx
	cmpq	%rdx, %r9
	je	.Lhrdbf_129
.Lhrdbf_103:
	movzbl	(%rcx,%rdx), %r11d
	cmpb	%r11b, (%rsi,%rdx)
	je	.Lhrdbf_130
.Lhrdbf_101:
	movl	$4, %eax
	jmp	.Lhrdbf_84
.Lhrdbf_96:
	movl	40(%rsp), %edx
	movq	%rbp, %rdi
	movl	%ecx, 44(%rsp)
	movq	%rcx, 32(%rsp)
	call .Lhrdbf_entry_hrdbf_local_nxvisit
	movq	32(%rsp), %rcx
	movl	44(%rsp), %r8d
	testl	%eax, %eax
	je	.Lhrdbf_99
	jmp	.Lhrdbf_84
	.p2align 4,,10
	.p2align 3
.Lhrdbf_129:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_111
.Lhrdbf_127:
	movq	16(%rdi), %rsi
.Lhrdbf_106:
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$2, %r13
	leaq	(%rsi,%rcx,8), %rcx
	movl	%eax, (%rcx)
	movl	%r10d, 4(%rcx)
	movl	%edx, 36(%rbp)
	cmpq	%r13, 24(%rsp)
	jne	.Lhrdbf_108
.Lhrdbf_97:
	xorl	%eax, %eax
	jmp	.Lhrdbf_84
.Lhrdbf_128:
	movl	%esi, 40(%rbp)
	jmp	.Lhrdbf_94
.Lhrdbf_111:
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	addq	%r12, %r9
	leaq	(%rsi,%rcx,8), %rcx
	movl	4(%rcx), %edi
	movl	(%rcx), %r11d
	addq	%rdi, %r9
	leaq	(%r12,%rdi), %rcx
	movq	%r9, 32(%rsp)
	jmp	.Lhrdbf_107
.Lhrdbf_105:
	addq	$1, %rcx
	cmpq	32(%rsp), %rcx
	je	.Lhrdbf_109
.Lhrdbf_107:
	movq	%rcx, %r9
	subq	%rdi, %r9
	movzbl	(%r9,%r8), %r9d
	cmpb	%r9b, (%rcx)
	je	.Lhrdbf_105
	jb	.Lhrdbf_106
	jmp	.Lhrdbf_88
.Lhrdbf_102:
	movl	36(%rbp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_127
	movq	16(%rdi), %rsi
	leal	-1(%rdx), %ecx
	movl	(%rsi,%rcx,8), %r11d
.Lhrdbf_109:
	cmpl	%r11d, %eax
	ja	.Lhrdbf_106
	jmp	.Lhrdbf_88
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
	ja	.Lhrdbf_131
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrdbf_131
	testl	$1023, %edx
	jne	.Lhrdbf_131
	testq	%rbp, %rbp
	je	.Lhrdbf_131
	cmpb	$0, 40(%rbp)
	je	.Lhrdbf_131
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.Lhrdbf_131
	cmpw	$0, 16(%rsi)
	jne	.Lhrdbf_131
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.Lhrdbf_134
	.p2align 4,,10
	.p2align 3
.Lhrdbf_133:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.Lhrdbf_195
.Lhrdbf_134:
	cmpq	$11, %rcx
	jbe	.Lhrdbf_133
	cmpb	$0, 538(%rax,%rcx)
	je	.Lhrdbf_133
.Lhrdbf_167:
	movl	$2, %r10d
.Lhrdbf_131:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_195:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbf_131
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.Lhrdbf_131
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.Lhrdbf_131
	movl	%esi, %ecx
	shrw $1, %cx
	cmpw	20(%rax), %cx
	jne	.Lhrdbf_131
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbf_135
	jmp	.Lhrdbf_131
	.p2align 4,,10
	.p2align 3
.Lhrdbf_136:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.Lhrdbf_167
.Lhrdbf_135:
	cmpb	$0, 22(%rax,%r12)
	jne	.Lhrdbf_136
	testq	%r12, %r12
	je	.Lhrdbf_167
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbf_167
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.Lhrdbf_137:
	xorl	%esi, %esi
	jmp	.Lhrdbf_146
	.p2align 4,,10
	.p2align 3
.Lhrdbf_196:
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
	jne	.Lhrdbf_139
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.Lhrdbf_138
	cmpq	$10, %rsi
	ja	.Lhrdbf_138
.Lhrdbf_146:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_196
.Lhrdbf_139:
	cmpq	%r12, %rsi
	je	.Lhrdbf_151
.Lhrdbf_143:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.Lhrdbf_137
	jmp	.Lhrdbf_167
.Lhrdbf_138:
	cmpq	%r12, %rsi
	jne	.Lhrdbf_143
	cmpq	$11, %rsi
	je	.Lhrdbf_144
.Lhrdbf_151:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.Lhrdbf_143
.Lhrdbf_144:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.Lhrdbf_167
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbf_131
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.Lhrdbf_131
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.Lhrdbf_173
	testq	%r8, %r8
	jne	.Lhrdbf_174
	testl	%ecx, %ecx
	jne	.Lhrdbf_173
.Lhrdbf_174:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.Lhrdbf_173
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.Lhrdbf_173
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.Lhrdbf_148:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.Lhrdbf_148
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
	jne	.Lhrdbf_149
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.Lhrdbf_150
	movl	$4, %r10d
.Lhrdbf_149:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_131
.Lhrdbf_150:
	movl	%eax, 24(%rbx)
	jmp	.Lhrdbf_131
.Lhrdbf_173:
	movl	$3, %r10d
	jmp	.Lhrdbf_131
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
	jne	.Lhrdbf_203
	movl	%r10d, %r15d
	subl	$1, %r15d
	cmpb	$5, %r15b
	jbe	.Lhrdbf_205
.Lhrdbf_203:
	movl	$1, %eax
.Lhrdbf_197:
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_205:
	movl	%esi, %edi
	movl	%r9d, %esi
	addl	%ecx, %r9d
	movl	$1, %eax
	addl	%r14d, %r9d
	leal	0(,%r10,8), %edx
	cmpl	%edx, %r9d
	jne	.Lhrdbf_197
	movl	$1, %edx
	salq	%cl, %rdx
	subl	$1, %edx
	cmpl	%r11d, %edx
	jne	.Lhrdbf_197
	movl	%eax, %edx
	movl	%esi, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebx
	jne	.Lhrdbf_197
	movl	%r14d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r12d, %eax
	setne	%al
	cmpl	%edi, %ebx
	setb	%dl
	orb	%dl, %al
	jne	.Lhrdbf_203
	cmpl	%edi, %r12d
	jb	.Lhrdbf_203
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%r10d
	cmpl	%eax, %r13d
	seta	%al
	cmpw	$488, %bp
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbf_197
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
	je	.Lhrdbf_207
	movl	%ebx, %ecx
	xorl	%esi, %esi
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_208:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%rdi,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %rsi
	cmpl	%r12d, %eax
	jne	.Lhrdbf_208
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
	jne	.Lhrdbf_209
	testl	%edx, %edx
	je	.Lhrdbf_209
.Lhrdbf_211:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_209:
	addl	%ebp, %ecx
	shrq	%cl, %rsi
	andl	%esi, %eax
	movl	%eax, %ebx
	leal	(%rdx,%rax), %eax
	cmpl	%eax, %r11d
	jb	.Lhrdbf_211
.Lhrdbf_217:
	movl	%r11d, %esi
	movq	(%r9), %rcx
	subl	%eax, %esi
	movl	%esi, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbf_211
	movzwl	(%r10), %eax
	movl	16(%r10), %r10d
	subq	%rbp, %rcx
	imulq	%r10, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbf_211
	movq	%rcx, (%r9)
	testl	%esi, %esi
	je	.Lhrdbf_212
	xorl	%eax, %eax
	jmp	.Lhrdbf_213
	.p2align 4,,10
	.p2align 3
.Lhrdbf_230:
	movq	(%r9), %rcx
.Lhrdbf_213:
	leaq	(%rdi,%rax), %rsi
	movzbl	(%rsi,%rcx), %esi
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%sil, (%r8,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbf_230
.Lhrdbf_212:
	movl	%r11d, %eax
	subl	%ebx, %eax
	cmpl	%eax, %r11d
	jbe	.Lhrdbf_216
	movl	%eax, %edx
	leal	-1(%rbx), %ecx
	leaq	(%r8,%rdx), %rax
	leaq	1(%r8,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_215:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_215
.Lhrdbf_216:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_207:
	movq	32(%rsp), %rax
	xorl	%ebx, %ebx
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbf_217
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
	je	.Lhrdbf_234
	movl	%esi, %eax
	movq	%rdi, %rbx
	movl	%edx, %esi
	movq	8(%rdi), %rdx
	cmpl	$1023, %eax
	ja	.Lhrdbf_286
.Lhrdbf_234:
	movl	$1, %r12d
.Lhrdbf_231:
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
.Lhrdbf_286:
	movl	%eax, %r15d
	andl	$511, %r15d
	jne	.Lhrdbf_234
	movl	%eax, %ebp
	subq	$512, %rdx
	cmpq	%rbp, %rdx
	jb	.Lhrdbf_234
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
	jne	.Lhrdbf_234
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
	je	.Lhrdbf_235
	cmpl	$1, %esi
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%edx, %ecx
	jne	.Lhrdbf_234
.Lhrdbf_235:
	movl	%esi, %edx
	movl	4(%rbp), %r8d
	movl	8(%rbp), %r9d
	leaq	(%rbx,%rdx,4), %rdx
	movl	56(%rdx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_287
	cmpl	%r8d, %ecx
	jne	.Lhrdbf_234
	cmpl	%eax, 312(%rdx)
	jne	.Lhrdbf_234
.Lhrdbf_257:
	cmpl	$-1, %r9d
	je	.Lhrdbf_239
	movq	8(%rbx), %rcx
	cmpl	$1023, %r9d
	jbe	.Lhrdbf_234
	testl	$511, %r9d
	jne	.Lhrdbf_234
	movl	%r9d, %r8d
	subq	$512, %rcx
	cmpq	%rcx, %r8
	ja	.Lhrdbf_234
.Lhrdbf_239:
	andl	$2, %edi
	movl	%eax, 56(%rdx)
	movzwl	%r13w, %r14d
	movl	%r9d, 312(%rdx)
	je	.Lhrdbf_240
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbf_288
	cmpl	%esi, %eax
	jne	.Lhrdbf_234
.Lhrdbf_242:
	movq	24(%rbx), %rax
	leaq	32(%rsp), %rdx
	movq	%rbp, %rdi
	movzwl	28(%rax), %r15d
	movl	%r15d, %esi
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbf_231
	testl	%r14d, %r14d
	je	.Lhrdbf_252
	movl	%r15d, %ecx
.Lhrdbf_243:
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
	jne	.Lhrdbf_262
	movl	20(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbf_245
	movq	16(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%eax, %r8d
	ja	.Lhrdbf_245
	cmpl	48(%rbx), %eax
	jbe	.Lhrdbf_245
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
	jne	.Lhrdbf_245
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
	je	.Lhrdbf_246
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %rsi
	jmp	.Lhrdbf_247
.Lhrdbf_290:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbf_289
	movq	%rdx, %rax
.Lhrdbf_247:
	movzbl	(%rsi,%rax), %edx
	cmpb	%dl, 64(%rsp,%rax)
	je	.Lhrdbf_290
.Lhrdbf_245:
	movl	$4, %r12d
	jmp	.Lhrdbf_231
	.p2align 4,,10
	.p2align 3
.Lhrdbf_287:
	cmpl	$-1, %r8d
	jne	.Lhrdbf_234
	jmp	.Lhrdbf_257
.Lhrdbf_240:
	testl	%r14d, %r14d
	je	.Lhrdbf_234
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r8d
	divl	%r8d
	cmpl	%r14d, %eax
	jb	.Lhrdbf_234
	leal	1(%rsi), %r13d
	movl	48(%rbx), %edi
	movl	%r14d, 12(%rsp)
	movzwl	%cx, %edx
	movl	%r13d, %r14d
	movq	%rbp, %r13
	movq	%rbx, %rbp
.Lhrdbf_255:
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
	jne	.Lhrdbf_283
	movl	48(%rbp), %edi
	cmpl	%r12d, %edi
	je	.Lhrdbf_234
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
	jne	.Lhrdbf_234
	movq	16(%rbp), %rax
	movq	(%rax), %r9
	testq	%rdx, %rdx
	je	.Lhrdbf_253
	movl	%ebx, %ecx
	xorl	%eax, %eax
	addq	%r9, %rsi
	addq	%r13, %rcx
	jmp	.Lhrdbf_254
	.p2align 4,,10
	.p2align 3
.Lhrdbf_291:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_253
.Lhrdbf_254:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, 12(%rax,%rcx)
	je	.Lhrdbf_291
	jmp	.Lhrdbf_234
.Lhrdbf_288:
	movl	%esi, 52(%rbx)
	jmp	.Lhrdbf_242
.Lhrdbf_253:
	addl	$1, %r15d
	cmpl	%r15d, 12(%rsp)
	je	.Lhrdbf_283
	movzwl	%r11w, %ecx
	jmp	.Lhrdbf_255
.Lhrdbf_289:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_260
.Lhrdbf_285:
	movq	16(%r11), %rcx
.Lhrdbf_250:
	movl	%edx, %eax
	addl	$1, %r12d
	addl	$1, %edx
	leaq	(%rcx,%rax,8), %rax
	movl	%r8d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r14d
	je	.Lhrdbf_252
	movzwl	%r9w, %ecx
	jmp	.Lhrdbf_243
.Lhrdbf_283:
	movl	%r10d, %r12d
	jmp	.Lhrdbf_231
.Lhrdbf_246:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbf_285
	movq	16(%r11), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %r11d
.Lhrdbf_258:
	cmpl	%r11d, %r8d
	ja	.Lhrdbf_250
	jmp	.Lhrdbf_234
.Lhrdbf_260:
	movq	16(%r11), %rcx
	leal	-1(%rdx), %esi
	leaq	(%rcx,%rsi,8), %rsi
	movl	4(%rsi), %r15d
	movl	(%rsi), %r11d
	xorl	%esi, %esi
	addq	%r15, %r10
	jmp	.Lhrdbf_251
.Lhrdbf_249:
	leaq	1(%rsi), %r15
	cmpq	%rax, %rsi
	je	.Lhrdbf_258
	movq	%r15, %rsi
.Lhrdbf_251:
	movzbl	64(%rsp,%rsi), %r15d
	cmpb	%r15b, (%r10,%rsi)
	je	.Lhrdbf_249
	jb	.Lhrdbf_250
	jmp	.Lhrdbf_234
.Lhrdbf_262:
	movl	%eax, %r12d
	jmp	.Lhrdbf_231
.Lhrdbf_252:
	movl	48(%rsp), %edx
	movq	24(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%r13, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	34(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbf_231
	.size	hrdbf_local_cxvisit, .-hrdbf_local_cxvisit
	.p2align 4
	.type	hrdbf_local_cxheader, @function
hrdbf_local_cxheader:
.Lhrdbf_entry_hrdbf_local_cxheader:
	movzbl	14(%rdi), %ecx
	movl	$2, %eax
	cmpl	%esi, %ecx
	jne	.Lhrdbf_292
	cmpb	$1, 15(%rdi)
	jne	.Lhrdbf_292
	cmpw	$1024, 16(%rdi)
	jne	.Lhrdbf_292
	cmpw	$512, 18(%rdi)
	jne	.Lhrdbf_292
	cmpw	$0, 502(%rdi)
	jne	.Lhrdbf_292
	movl	%edx, %ecx
	movl	$20, %eax
	xorl	$1, %ecx
	andl	$1, %ecx
	jmp	.Lhrdbf_295
	.p2align 4,,10
	.p2align 3
.Lhrdbf_314:
	cmpl	$23, %eax
	ja	.Lhrdbf_302
.Lhrdbf_294:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbf_313
.Lhrdbf_295:
	cmpb	$0, (%rdi,%rax)
	je	.Lhrdbf_294
	testb	%cl, %cl
	je	.Lhrdbf_314
.Lhrdbf_302:
	movl	$2, %eax
.Lhrdbf_292:
	ret
.Lhrdbf_313:
	testl	%edx, %edx
	je	.Lhrdbf_296
	cmpb	$82, 20(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_292
	cmpb	$67, 21(%rdi)
	jne	.Lhrdbf_292
	cmpb	$72, 22(%rdi)
	jne	.Lhrdbf_292
	cmpb	$66, 23(%rdi)
	jne	.Lhrdbf_292
.Lhrdbf_296:
	cmpw	$1, 506(%rdi)
	movl	$2, %eax
	jne	.Lhrdbf_292
	movzwl	504(%rdi), %esi
	cmpw	%si, 510(%rdi)
	jne	.Lhrdbf_292
	xorl	%eax, %eax
	cmpw	$0, 508(%rdi)
	setne	%al
	addl	%eax, %eax
	ret
	.size	hrdbf_local_cxheader, .-hrdbf_local_cxheader
	.p2align 4
	.type	hrdbf_app_pad_ll, @function
hrdbf_app_pad_ll:
.Lhrdbf_entry_hrdbf_app_pad_ll:
	pushq	%rbx
	movl	%esi, %r9d
	movq	%rdi, %r11
	movq	%rdx, %r8
	movq	%rdi, %rsi
	subq	$32, %rsp
	testq	%rdi, %rdi
	js	.Lhrdbf_334
	jne	.Lhrdbf_317
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r9
	je	.Lhrdbf_319
.Lhrdbf_318:
	leaq	(%r8,%rsi), %rax
	leaq	(%rax,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_323:
	movb	$48, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_323
	addq	%rsi, %r9
.Lhrdbf_319:
	movq	%rsp, %rdi
	leaq	-1(%rsp,%rcx), %rax
	leaq	(%r8,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_324:
	movzbl	(%rax), %esi
	addq	$1, %rdx
	movb	%sil, -1(%rdx)
	movq	%rax, %rsi
	subq	$1, %rax
	cmpq	%rsi, %rdi
	jne	.Lhrdbf_324
	addq	$32, %rsp
	leaq	(%rcx,%r9), %rax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_334:
	negq	%rsi
.Lhrdbf_317:
	movabs	$-3689348814741910323, %rbx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_320:
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
	ja	.Lhrdbf_320
	testq	%r11, %r11
	jns	.Lhrdbf_326
	movb	$45, (%r8)
	addq	$2, %r10
	movl	$1, %esi
.Lhrdbf_321:
	subq	%r10, %r9
	jne	.Lhrdbf_318
	movq	%rsi, %r9
	jmp	.Lhrdbf_319
.Lhrdbf_326:
	movq	%rcx, %r10
	xorl	%esi, %esi
	jmp	.Lhrdbf_321
	.size	hrdbf_app_pad_ll, .-hrdbf_app_pad_ll
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
	cmpq	$1073741824, %r14
	ja	.Lhrdbf_335
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
	syscall
	leaq	4095(%rax), %rdx
	movq	%rax, %r13
	movl	$8, %eax
	cmpq	$4094, %rdx
	jbe	.Lhrdbf_335
	testq	%r13, %r13
	je	.Lhrdbf_335
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 32952(%rbx)
	je	.Lhrdbf_340
	.p2align 4,,10
	.p2align 3
.Lhrdbf_337:
	movq	32944(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	32952(%rbx), %rax
	jb	.Lhrdbf_337
.Lhrdbf_340:
	leaq	0(%r13,%rbp), %r8
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r8, %rdx
	je	.Lhrdbf_339
	.p2align 4,,10
	.p2align 3
.Lhrdbf_338:
	movb	$32, (%r8,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbf_338
	addq	%r8, %rdx
.Lhrdbf_339:
	movb	$26, (%rdx)
	xorl	%edx, %edx
	movq	%rsp, %rsi
	movl	$228, %eax
	movq	%rdx, %rdi
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_341
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
	jbe	.Lhrdbf_375
	subq	$9, %rsi
	cmpq	$3, %rsi
	adcq	$0, %r9
.Lhrdbf_343:
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
.Lhrdbf_346:
	movq	32968(%rbx), %rdi
	movq	%r9, %rax
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_346
	testq	%rax, %rax
	jle	.Lhrdbf_341
	cmpq	%rdx, %rax
	ja	.Lhrdbf_341
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_346
	leaq	28(%r13), %rsi
	movl	$18, %r9d
	movl	$1, %edx
.Lhrdbf_347:
	movq	32968(%rbx), %rdi
	movl	$28, %r10d
	movq	%r9, %rax
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_347
	cmpq	$1, %rax
	jne	.Lhrdbf_341
	movl	$18, %r9d
	movq	%r8, %rsi
	movq	%rbp, %r10
	movq	%r12, %rdx
.Lhrdbf_348:
	movq	32968(%rbx), %rdi
	movq	%r9, %rax
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_348
	testq	%rax, %rax
	jle	.Lhrdbf_341
	cmpq	%rdx, %rax
	ja	.Lhrdbf_341
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_348
	movq	32944(%rbx), %rdi
	movq	32952(%rbx), %rsi
	movl	$11, %eax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_341
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
.Lhrdbf_335:
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
.Lhrdbf_341:
	movl	$11, %eax
	xorl	%edx, %edx
	movq	%r13, %rdi
	movq	%r14, %rsi
	syscall
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
.Lhrdbf_375:
	addq	$3, %rsi
	jmp	.Lhrdbf_343
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
	je	.Lhrdbf_377
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	movl	$7, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_377
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_377:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_376
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_381
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_376:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_381:
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
	jne	.Lhrdbf_386
	orl	%eax, %edx
	movb	%dl, (%rdi)
.Lhrdbf_386:
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
	ja	.Lhrdbf_392
	movq	%rsi, %r12
	testq	%rsi, %rsi
	je	.Lhrdbf_392
	movq	%rdx, %rbp
	testl	$511, %edx
	jne	.Lhrdbf_392
	movq	%rcx, %r13
	testq	%rcx, %rcx
	je	.Lhrdbf_392
	cmpb	$0, 40(%rcx)
	je	.Lhrdbf_392
	movq	%rdi, %rbx
	movl	$1, %edx
	movl	$224, %esi
	movq	%r12, %rdi
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_388
	cmpw	$10, 12(%r12)
	movl	$2, %eax
	jne	.Lhrdbf_388
	cmpw	$1, 510(%r12)
	jne	.Lhrdbf_388
	cmpb	$0, 512(%r12)
	jne	.Lhrdbf_388
	movl	(%r12), %r10d
	cmpl	$1023, %r10d
	jbe	.Lhrdbf_392
	testl	$511, %r10d
	jne	.Lhrdbf_392
	movl	%r10d, %edx
	leaq	-512(%rbp), %r11
	cmpq	%r11, %rdx
	ja	.Lhrdbf_392
	leaq	(%r12,%rdx), %rdi
	cmpw	$3, (%rdi)
	jne	.Lhrdbf_388
	cmpw	$1, 2(%r12,%rdx)
	jne	.Lhrdbf_388
	cmpl	$-1, 4(%r12,%rdx)
	jne	.Lhrdbf_392
	cmpl	$-1, 8(%r12,%rdx)
	jne	.Lhrdbf_392
	leaq	64(%rsp), %rdx
	movl	$10, %esi
	movl	%r10d, 24(%rsp)
	movq	%r9, %r15
	movq	%r11, 16(%rsp)
	movq	%rdi, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbf_388
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
	jne	.Lhrdbf_388
	movl	80(%rsp), %eax
	leal	24(%rax), %edx
	movq	56(%rsp), %rax
	subq	%rdx, %rax
	movzwl	66(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_392
	movl	52(%rsp), %r8d
	cmpl	$1023, %r8d
	jbe	.Lhrdbf_392
	testl	$511, %r8d
	jne	.Lhrdbf_392
	movq	16(%rsp), %r11
	movl	%r8d, %r9d
	cmpq	%r9, %r11
	jb	.Lhrdbf_392
	leaq	-1024(%rbp), %rax
	cmpq	%r9, %rax
	jb	.Lhrdbf_392
	movl	24(%rsp), %r10d
	cmpl	%r10d, %r8d
	je	.Lhrdbf_392
	leal	512(%r8), %r11d
	cmpl	%r10d, %r11d
	je	.Lhrdbf_392
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_393
.Lhrdbf_466:
	movq	%rdx, %rsi
	shrq	%cl, %rsi
	movq	%rsi, %rcx
	andb	$1, %cl
	je	.Lhrdbf_430
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbf_465
.Lhrdbf_393:
	movzbl	96(%rsp,%rax), %ecx
	movb	%cl, 8(%rsp)
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbf_466
.Lhrdbf_430:
	movl	$2, %eax
	jmp	.Lhrdbf_388
	.p2align 4,,10
	.p2align 3
.Lhrdbf_392:
	movl	$1, %eax
.Lhrdbf_388:
	addq	$936, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_465:
	leaq	(%r12,%r9), %rax
	xorl	%edx, %edx
	movl	$96, %esi
	movq	%rax, %rdi
	movq	%rax, 24(%rsp)
	call .Lhrdbf_entry_hrdbf_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbf_388
	movzwl	510(%r12,%r9), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbf_430
	leaq	(%r11,%rax), %rdx
	cmpb	$0, -1(%r12,%rdx)
	jne	.Lhrdbf_430
	cmpb	$0, (%r12,%rdx)
	jne	.Lhrdbf_430
	xorl	%edx, %edx
	leaq	(%r12,%r11), %rdi
	subq	$1, %rax
.Lhrdbf_394:
	cmpb	$0, (%rdi,%rdx)
	je	.Lhrdbf_430
	addq	$1, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbf_394
	movzwl	36(%r13), %ecx
	xorl	%r11d, %r11d
	movl	%ecx, 36(%rsp)
	movzwl	%cx, %ecx
	movq	%rcx, 40(%rsp)
.Lhrdbf_395:
	cmpq	%r11, 40(%rsp)
	jbe	.Lhrdbf_430
	movq	%r11, %rdx
	salq	$4, %rdx
	leaq	0(%r13,%rdx), %rcx
	xorl	%edx, %edx
	movq	%rcx, 8(%rsp)
.Lhrdbf_404:
	movq	8(%rsp), %rcx
	movzbl	42(%rcx,%rdx), %ecx
	movb	%cl, 16(%rsp)
	testb	%cl, %cl
	je	.Lhrdbf_398
	leal	-97(%rcx), %esi
	cmpb	$25, %sil
	ja	.Lhrdbf_399
	subl	$32, %ecx
	movb	%cl, 16(%rsp)
.Lhrdbf_399:
	movzbl	(%rdi,%rdx), %esi
	leal	-97(%rsi), %ecx
	cmpb	$25, %cl
	ja	.Lhrdbf_400
	subl	$32, %esi
.Lhrdbf_400:
	cmpb	16(%rsp), %sil
	jne	.Lhrdbf_398
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbf_396
	cmpq	$11, %rdx
	jne	.Lhrdbf_404
	cmpq	$11, %rax
	jne	.Lhrdbf_398
.Lhrdbf_402:
	cmpl	%r11d, 36(%rsp)
	je	.Lhrdbf_430
	movq	8(%rsp), %rax
	cmpb	$67, 53(%rax)
	jne	.Lhrdbf_430
	movzbl	54(%rax), %eax
	cmpb	$-16, %al
	ja	.Lhrdbf_429
	cmpw	12(%r12,%r9), %ax
	jne	.Lhrdbf_430
	movl	16(%r13), %eax
	cmpq	%r15, %rax
	ja	.Lhrdbf_434
	testq	%r14, %r14
	jne	.Lhrdbf_436
	testl	%eax, %eax
	jne	.Lhrdbf_434
.Lhrdbf_436:
	movq	%rbp, %r9
	addq	$7, %rax
	shrq	$9, %r9
	shrq	$3, %rax
	addq	$7, %r9
	shrq	$3, %r9
	cmpq	$0, 992(%rsp)
	je	.Lhrdbf_434
	addq	%r9, %rax
	cmpq	1000(%rsp), %rax
	ja	.Lhrdbf_434
	xorl	%edx, %edx
.Lhrdbf_406:
	movq	992(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbf_406
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbf_407
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbf_407:
	testb	$2, %al
	jne	.Lhrdbf_408
	movq	992(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbf_408:
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
.Lhrdbf_409:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbf_409
	movq	24(%rsp), %rax
	xorl	%edx, %edx
	leaq	352(%rsp), %rdi
	movl	(%rax), %esi
	call .Lhrdbf_entry_hrdbf_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbf_467
.Lhrdbf_410:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_388
.Lhrdbf_396:
	cmpq	$11, %rax
	je	.Lhrdbf_402
	movq	%r11, %rdx
	salq	$4, %rdx
	addq	%r13, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbf_402
.Lhrdbf_398:
	addq	$1, %r11
	jmp	.Lhrdbf_395
.Lhrdbf_434:
	movl	$3, %eax
	jmp	.Lhrdbf_388
.Lhrdbf_429:
	movl	$5, %eax
	jmp	.Lhrdbf_388
.Lhrdbf_467:
	movl	400(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%r13), %ecx
	jne	.Lhrdbf_410
	xorl	%edx, %edx
	jmp	.Lhrdbf_412
.Lhrdbf_468:
	cmpq	$63, %rdx
	ja	.Lhrdbf_437
.Lhrdbf_412:
	movl	408(%rsp,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbf_411
	xorl	%eax, %eax
	cmpl	$-1, 664(%rsp,%rdx,4)
	setne	%al
.Lhrdbf_411:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbf_468
.Lhrdbf_437:
	testl	%eax, %eax
	jne	.Lhrdbf_410
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbf_388
	.size	hrcdx_open, .-hrcdx_open
	.p2align 4
	.type	hrdbf_local_put_number.isra.0, @function
hrdbf_local_put_number.isra.0:
.Lhrdbf_entry_hrdbf_local_put_number.isra.0:
	movl	%esi, %r11d
	movl	$3, %r10d
	movl	%edx, %esi
	cmpb	$78, %r11b
	jne	.Lhrdbf_469
	movzwl	%cx, %ecx
	leaq	(%rdi,%rcx), %rdx
	movzbl	%sil, %ecx
	cmpl	%r9d, %ecx
	jb	.Lhrdbf_490
	subl	%r9d, %ecx
	je	.Lhrdbf_475
	leal	-1(%rcx), %edi
	movq	%rdx, %rax
	addq	%rdx, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_476:
	movq	%rax, %rsi
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdi, %rsi
	jne	.Lhrdbf_476
.Lhrdbf_475:
	testl	%r9d, %r9d
	je	.Lhrdbf_474
	leal	-1(%r9), %eax
	leaq	1(%r8,%rax), %rdi
	movl	%ecx, %eax
	subl	%r8d, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_477:
	movzbl	(%r8), %esi
	leal	(%rax,%r8), %ecx
	addq	$1, %r8
	movb	%sil, (%rdx,%rcx)
	cmpq	%rdi, %r8
	jne	.Lhrdbf_477
.Lhrdbf_474:
	xorl	%r10d, %r10d
.Lhrdbf_469:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_490:
	movq	%rdx, %rax
	movzbl	%sil, %edx
	addq	%rax, %rdx
	testl	%ecx, %ecx
	je	.Lhrdbf_474
	.p2align 4,,10
	.p2align 3
.Lhrdbf_473:
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_474
	movb	$42, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbf_473
	jmp	.Lhrdbf_474
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
	ja	.Lhrdbf_491
	movzbl	12(%rsi), %r12d
	movq	%rsi, %r10
	cmpl	$17, %ecx
	ja	.Lhrdbf_517
	cmpb	%r12b, %r13b
	jnb	.Lhrdbf_517
	movq	%rdi, %rbp
	movq	%rdx, %rsi
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jns	.Lhrdbf_493
	negq	%rsi
	movl	$1, %r8d
.Lhrdbf_493:
	movzbl	%r13b, %ebx
	cmpl	%ebx, %ecx
	jbe	.Lhrdbf_494
	subl	%ebx, %ecx
	je	.Lhrdbf_495
	xorl	%eax, %eax
	movl	$1, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_496:
	leaq	(%rdi,%rdi,4), %rdi
	addl	$1, %eax
	addq	%rdi, %rdi
	cmpl	%eax, %ecx
	jne	.Lhrdbf_496
	movq	%rsi, %rax
	xorl	%edx, %edx
	divq	%rdi
	shrq $1, %rdi
	movq	%rax, %rsi
	cmpq	%rdi, %rdx
	jb	.Lhrdbf_497
.Lhrdbf_495:
	addq	$1, %rsi
.Lhrdbf_497:
	movabs	$-3689348814741910323, %r9
	movq	%rsp, %rdi
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_502:
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
	ja	.Lhrdbf_502
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
	ja	.Lhrdbf_545
	testl	%r8d, %r8d
	je	.Lhrdbf_508
	movb	$45, 48(%rsp)
.Lhrdbf_508:
	cmpl	%ecx, %ebx
	jb	.Lhrdbf_546
	leal	1(%r8), %r9d
	movl	%r8d, %r8d
	movb	$48, 48(%rsp,%r8)
.Lhrdbf_510:
	testb	%r13b, %r13b
	je	.Lhrdbf_512
	cmpl	%ecx, %ebx
	movl	%r9d, %edx
	leal	1(%r9), %eax
	cmovbe	%ebx, %ecx
	movb	$46, 48(%rsp,%rdx)
	subl	%ecx, %ebx
	je	.Lhrdbf_513
	leal	1(%rbx,%r9), %edi
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_514:
	movl	%edx, %esi
	addl	$1, %edx
	movb	$48, 48(%rsp,%rsi)
	cmpl	%edx, %edi
	jne	.Lhrdbf_514
	addl	%ebx, %eax
.Lhrdbf_513:
	leal	(%rcx,%rax), %r9d
	leal	-1(%rcx,%rax), %esi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_515:
	movl	%esi, %ecx
	movl	%eax, %edx
	subl	%eax, %ecx
	addl	$1, %eax
	movzbl	(%rsp,%rcx), %ecx
	movb	%cl, 48(%rsp,%rdx)
	cmpl	%eax, %r9d
	jne	.Lhrdbf_515
.Lhrdbf_512:
	movzbl	11(%r10), %esi
	leaq	48(%rsp), %r8
	movl	%r14d, %ecx
	movl	%r12d, %edx
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_put_number.isra.0
.Lhrdbf_491:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_517:
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
.Lhrdbf_494:
	jnb	.Lhrdbf_497
	movl	%ebx, %edi
	subl	%ecx, %edi
	je	.Lhrdbf_497
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rsi
	ja	.Lhrdbf_498
	xorl	%eax, %eax
	jmp	.Lhrdbf_499
	.p2align 4,,10
	.p2align 3
.Lhrdbf_501:
	cmpq	%rdx, %rsi
	ja	.Lhrdbf_498
.Lhrdbf_499:
	leaq	(%rsi,%rsi,4), %rsi
	addl	$1, %eax
	addq	%rsi, %rsi
	cmpl	%eax, %edi
	jne	.Lhrdbf_501
	jmp	.Lhrdbf_497
	.p2align 4,,10
	.p2align 3
.Lhrdbf_546:
	testl	%r9d, %r9d
	je	.Lhrdbf_521
	movl	%edx, %r9d
	addl	%r8d, %r11d
	jmp	.Lhrdbf_511
	.p2align 4,,10
	.p2align 3
.Lhrdbf_547:
	movl	%r11d, %eax
	movl	%esi, %r8d
	subl	%esi, %eax
	movzbl	(%rsp,%rax), %eax
.Lhrdbf_511:
	leal	1(%r8), %esi
	movl	%r8d, %r8d
	movb	%al, 48(%rsp,%r8)
	cmpl	%esi, %edx
	jne	.Lhrdbf_547
	jmp	.Lhrdbf_510
	.p2align 4,,10
	.p2align 3
.Lhrdbf_545:
	xorl	%eax, %eax
	leaq	0(%rbp,%r14), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_506:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbf_506
	xorl	%eax, %eax
.Lhrdbf_548:
	addq	$112, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_498:
	movzwl	14(%r10), %edx
	xorl	%eax, %eax
	addq	%rbp, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_500:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r12d
	ja	.Lhrdbf_500
	xorl	%eax, %eax
	jmp	.Lhrdbf_548
.Lhrdbf_521:
	movl	%r8d, %r9d
	jmp	.Lhrdbf_510
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
	jbe	.Lhrdbf_594
	leal	-1(%r8), %edx
	xorl	%r10d, %r10d
	cmpl	%edx, %esi
	ja	.Lhrdbf_595
.Lhrdbf_556:
	cmpl	$1, %r8d
	je	.Lhrdbf_557
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_560
	.p2align 4,,10
	.p2align 3
.Lhrdbf_558:
	addl	$1, %ecx
	cmpl	%ecx, %edx
	je	.Lhrdbf_557
.Lhrdbf_560:
	cmpl	%ecx, %esi
	jbe	.Lhrdbf_558
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbf_558
	testl	%r10d, %r10d
	movl	$3, %edx
	cmovne	%edx, %eax
.Lhrdbf_571:
	cmpl	$31, %r8d
	jbe	.Lhrdbf_565
	movl	%r8d, %r11d
	shrl	$5, %r11d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbf_567
	leal	-1(%r9), %ecx
	movq	%rdi, %rdx
	movl	%r11d, %esi
	subl	%r11d, %ecx
	leaq	4(%rdi,%rcx,4), %r10
	.p2align 4,,10
	.p2align 3
.Lhrdbf_566:
	movl	(%rdx,%rsi,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%r10, %rdx
	jne	.Lhrdbf_566
.Lhrdbf_567:
	movl	%r9d, %edx
	subl	%r11d, %edx
	movl	%edx, 288(%rdi)
	cmpl	%edx, %r9d
	jbe	.Lhrdbf_565
	movl	%edx, %ecx
	leal	-1(%r11), %esi
	leaq	(%rdi,%rcx,4), %rdx
	addq	%rsi, %rcx
	leaq	4(%rdi,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_568:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_568
.Lhrdbf_565:
	andl	$31, %r8d
	jne	.Lhrdbf_562
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_595:
	movl	%edx, %eax
	movl	%edx, %ecx
	shrl	$5, %eax
	movl	(%rdi,%rax,4), %r10d
	shrl	%cl, %r10d
	andl	$1, %r10d
	jmp	.Lhrdbf_556
	.p2align 4,,10
	.p2align 3
.Lhrdbf_594:
	xorl	%eax, %eax
	testl	%esi, %esi
	je	.Lhrdbf_551
	xorl	%r9d, %r9d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_553:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r9d
	addl	$1, %ecx
	cmpl	%ecx, %esi
	jne	.Lhrdbf_553
	testl	%eax, %eax
	je	.Lhrdbf_551
	xorl	%r10d, %r10d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_554:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%rdi,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %r10d
	cmpl	%ecx, %esi
	jne	.Lhrdbf_554
	subl	$1, %r8d
	cmpl	%r9d, %r8d
	ja	.Lhrdbf_551
	sete	%al
	xorl	%edx, %edx
	cmpl	$1, %r10d
	sete	%dl
	andl	%eax, %edx
	movl	$3, %eax
	subl	%edx, %eax
.Lhrdbf_551:
	movl	$1, 288(%rdi)
	movl	$0, (%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_557:
	leal	(%r10,%r10), %eax
	jmp	.Lhrdbf_571
	.p2align 4,,10
	.p2align 3
.Lhrdbf_562:
	movl	288(%rdi), %ecx
	pushq	%rbx
	leal	-1(%rcx), %ebx
	cmpl	$1, %ecx
	jbe	.Lhrdbf_569
	movl	$32, %r10d
	subl	$2, %ecx
	movq	%rdi, %rdx
	subl	%r8d, %r10d
	leaq	4(%rdi,%rcx,4), %r11
	.p2align 4,,10
	.p2align 3
.Lhrdbf_570:
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
	jne	.Lhrdbf_570
	movl	%ebx, %esi
	movl	%r8d, %ecx
	movl	(%rdi,%rsi,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%rdi,%rsi,4)
	testl	%edx, %edx
	je	.Lhrdbf_596
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_596:
	movl	%ebx, 288(%rdi)
	popq	%rbx
	ret
.Lhrdbf_569:
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
.Lhrdbf_598:
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
	jbe	.Lhrdbf_608
	cmpl	$19, %r8d
	jbe	.Lhrdbf_598
.Lhrdbf_608:
	leaq	32977(%rdi), %r10
	leaq	33136(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_606:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_600
	.p2align 4,,10
	.p2align 3
.Lhrdbf_602:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_601
.Lhrdbf_600:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_602
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_603
	jmp	.Lhrdbf_601
	.p2align 4,,10
	.p2align 3
.Lhrdbf_604:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_601
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_603:
	testb	%cl, %cl
	jne	.Lhrdbf_604
.Lhrdbf_601:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_597
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_606
.Lhrdbf_597:
	addq	$56, %rsp
	ret
	.size	hrdbf_local_fdec, .-hrdbf_local_fdec
	.section	.rodata
.Lhrdbf_C1:
	.string	" (errno "
	.text
	.p2align 4
	.type	hrdbf_local_ferr, @function
hrdbf_local_ferr:
.Lhrdbf_entry_hrdbf_local_ferr:
	leaq	32977(%rdi), %r11
	pushq	%rbx
	leaq	33136(%rdi), %rbx
	movq	%r11, %rax
	jmp	.Lhrdbf_616
	.p2align 4,,10
	.p2align 3
.Lhrdbf_618:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rsi
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_617
.Lhrdbf_616:
	movzbl	(%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_618
.Lhrdbf_617:
	movb	$0, (%rax)
	movq	%r11, %rax
	jmp	.Lhrdbf_620
	.p2align 4,,10
	.p2align 3
.Lhrdbf_622:
	addq	$1, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_621
.Lhrdbf_620:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_622
	cmpq	%rax, %rbx
	jbe	.Lhrdbf_621
	movl	$32, %esi
	movl	$.Lhrdbf_C1, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_623:
	movb	%sil, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbf_621
	movzbl	(%rcx), %esi
	testb	%sil, %sil
	jne	.Lhrdbf_623
.Lhrdbf_621:
	movq	%rdx, %rsi
	movb	$0, (%rax)
	negq	%rsi
	cmovs	%rdx, %rsi
	call .Lhrdbf_entry_hrdbf_local_fdec
	jmp	.Lhrdbf_624
	.p2align 4,,10
	.p2align 3
.Lhrdbf_626:
	addq	$1, %r11
	cmpq	%rbx, %r11
	jnb	.Lhrdbf_625
.Lhrdbf_624:
	cmpb	$0, (%r11)
	jne	.Lhrdbf_626
	cmpq	%r11, %rbx
	jbe	.Lhrdbf_625
	movb	$41, (%r11)
	addq	$1, %r11
.Lhrdbf_625:
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
	je	.Lhrdbf_639
	movabs	$4503599627370495, %rax
	andq	40(%rsp), %rax
	movq	%rdi, %rbx
	movq	%rax, 8(%rsp)
	testq	%r9, %r9
	je	.Lhrdbf_873
	btsq	$52, 8(%rsp)
	movq	8(%rsp), %rax
	movl	$2, %edi
	leal	-1075(%r9), %r15d
	subl	$735, %r9d
	movl	%eax, %ecx
	movl	%r9d, %r10d
	shrq	$32, %rax
.Lhrdbf_637:
	movl	%ecx, 48(%rsp)
	movl	$340, %esi
	xorl	%r8d, %r8d
	movl	%eax, 52(%rsp)
	movl	%edi, 336(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbf_642:
	leal	-1(%rdi), %eax
	leaq	48(%rsp), %rdx
	leaq	52(%rsp,%rax,4), %r11
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_643:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%r11, %rdx
	jne	.Lhrdbf_643
	testq	%rax, %rax
	je	.Lhrdbf_644
	movl	%edi, %edx
	movl	$1, %r8d
	addl	$1, %edi
	movl	%eax, 48(%rsp,%rdx,4)
.Lhrdbf_644:
	subl	$1, %esi
	jne	.Lhrdbf_642
	testb	%r8b, %r8b
	je	.Lhrdbf_646
	movl	%edi, 336(%rsp)
.Lhrdbf_646:
	movl	%r10d, %esi
	testl	%r9d, %r9d
	js	.Lhrdbf_647
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	336(%rsp), %eax
.Lhrdbf_648:
	xorl	%ebp, %ebp
	jmp	.Lhrdbf_652
	.p2align 4,,10
	.p2align 3
.Lhrdbf_653:
	cmpq	$80, %rbp
	je	.Lhrdbf_874
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_divmod_1e9
	movl	%eax, 1264(%rsp,%rbp,4)
	movl	336(%rsp), %eax
	addq	$1, %rbp
.Lhrdbf_652:
	movl	%ebp, %r8d
	cmpl	$1, %eax
	jne	.Lhrdbf_653
	movl	48(%rsp), %r9d
	testl	%r9d, %r9d
	jne	.Lhrdbf_653
	testl	%ebp, %ebp
	jne	.Lhrdbf_875
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbf_638
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jnb	.Lhrdbf_876
.Lhrdbf_639:
	xorl	%eax, %eax
.Lhrdbf_631:
	addq	$2312, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_873:
	testq	%rax, %rax
	jne	.Lhrdbf_877
	movl	16(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbf_638
	addl	$2, %eax
	cmpl	%eax, 36(%rsp)
	jb	.Lhrdbf_639
	movl	$11824, %ecx
	leaq	2(%rdi), %rdx
	movw	%cx, (%rdi)
	movl	16(%rsp), %edi
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.Lhrdbf_641:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbf_641
	jmp	.Lhrdbf_631
.Lhrdbf_638:
	movl	36(%rsp), %r10d
	testl	%r10d, %r10d
	je	.Lhrdbf_639
	movb	$48, (%rbx)
	movl	$1, %eax
	jmp	.Lhrdbf_631
.Lhrdbf_877:
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
	jmp	.Lhrdbf_637
.Lhrdbf_647:
	negl	%esi
	leaq	48(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shr_round
	movl	%eax, %r8d
	movl	336(%rsp), %eax
	cmpl	$1, %r8d
	jbe	.Lhrdbf_648
	testl	%eax, %eax
	je	.Lhrdbf_747
	leal	-1(%rax), %edx
	movq	%rdi, %rsi
	leaq	52(%rsp,%rdx,4), %rdi
	movl	$1, %edx
.Lhrdbf_651:
	movl	(%rsi), %ecx
	addq	$4, %rsi
	addq	%rcx, %rdx
	movl	%edx, -4(%rsi)
	shrq	$32, %rdx
	cmpq	%rdi, %rsi
	jne	.Lhrdbf_651
	testq	%rdx, %rdx
	je	.Lhrdbf_648
	leal	1(%rax), %edx
.Lhrdbf_650:
	movl	$1, 48(%rsp,%rax,4)
	movl	%edx, %eax
	movl	%edx, 336(%rsp)
	jmp	.Lhrdbf_648
.Lhrdbf_874:
	movl	$79, %r8d
.Lhrdbf_656:
	movl	%r8d, %eax
	movl	$1, %ecx
	movl	$3435973837, %r9d
	movl	1264(%rsp,%rax,4), %esi
.Lhrdbf_660:
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
	ja	.Lhrdbf_660
	leaq	1584(%rsp), %r13
	leal	-1(%r12), %ecx
	leaq	1585(%rsp), %rax
	movq	%rcx, %r11
	leal	-1(%r12,%r13), %esi
	addq	%rax, %rcx
	movq	%r13, %rax
	jmp	.Lhrdbf_662
.Lhrdbf_878:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	960(%rsp,%rdx), %edx
.Lhrdbf_662:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_878
	testl	%r8d, %r8d
	je	.Lhrdbf_663
	leaq	1264(%rsp), %r14
	leal	-1(%r8), %eax
	movl	$3435973837, %r10d
	leaq	(%r14,%rax,4), %rbp
.Lhrdbf_665:
	movl	%r11d, %edi
	movl	0(%rbp), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_664:
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
	jne	.Lhrdbf_664
	leaq	-4(%rbp), %rax
	cmpq	%r14, %rbp
	je	.Lhrdbf_879
	movq	%rax, %rbp
	jmp	.Lhrdbf_665
.Lhrdbf_879:
	leal	(%r8,%r8,8), %eax
	addl	%eax, %r12d
.Lhrdbf_663:
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
.Lhrdbf_667:
	leal	-1(%r8), %eax
	leaq	352(%rsp), %rcx
	leaq	356(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_668:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_668
	testq	%rax, %rax
	je	.Lhrdbf_669
	movl	%r8d, %edx
	movl	$1, %r9d
	addl	$1, %r8d
	movl	%eax, 352(%rsp,%rdx,4)
.Lhrdbf_669:
	subl	$1, %edi
	jne	.Lhrdbf_667
	testb	%r9b, %r9b
	je	.Lhrdbf_671
	movl	%r8d, 640(%rsp)
.Lhrdbf_671:
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
	je	.Lhrdbf_672
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
.Lhrdbf_673:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_674:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rsi, %rcx
	jne	.Lhrdbf_674
	testq	%rax, %rax
	je	.Lhrdbf_675
	movl	%r11d, %edx
	movl	%r9d, %ebp
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.Lhrdbf_675:
	subl	$1, %r10d
	jne	.Lhrdbf_673
	testb	%bpl, %bpl
	je	.Lhrdbf_677
	movl	%r11d, 944(%rsp)
.Lhrdbf_677:
	leal	338(%r15), %esi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
.Lhrdbf_678:
	leaq	960(%rsp), %r8
	cmpl	$1, %r12d
	je	.Lhrdbf_715
	leal	1(%r12), %eax
	leaq	960(%rsp), %r8
	movq	%rbx, 24(%rsp)
	movl	$2, %r14d
	movl	%eax, 32(%rsp)
	leaq	1585(%rsp), %rbp
	movl	$1, %r15d
	movq	%r8, %rbx
.Lhrdbf_711:
	movl	%r15d, 4(%rsp)
	movq	%r13, %rdx
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_685:
	movzbl	(%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpq	%rdx, %rbp
	jne	.Lhrdbf_685
	cmpb	$53, 0(%rbp)
	ja	.Lhrdbf_686
	je	.Lhrdbf_880
.Lhrdbf_687:
	movl	32(%rsp), %r10d
	movq	%r10, %rcx
	subq	%r14, %rcx
	cmpq	$9, %rsi
	ja	.Lhrdbf_881
.Lhrdbf_689:
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
	je	.Lhrdbf_693
	.p2align 4,,10
	.p2align 3
.Lhrdbf_692:
	leal	-1(%rdi), %eax
	movq	%rbx, %rcx
	leaq	964(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_694:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_694
	testq	%rax, %rax
	je	.Lhrdbf_695
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 960(%rsp,%rdx,4)
.Lhrdbf_695:
	addl	$1, %r9d
	cmpl	%r10d, %r9d
	jne	.Lhrdbf_692
	testb	%r11b, %r11b
	je	.Lhrdbf_693
	movl	%edi, 1248(%rsp)
.Lhrdbf_693:
	movl	%r10d, %esi
	movq	%rbx, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	1248(%rsp), %esi
	cmpl	944(%rsp), %esi
	je	.Lhrdbf_698
	jnb	.Lhrdbf_699
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_700
	movl	$-1, %ecx
	leal	-1(%rsi), %eax
	jmp	.Lhrdbf_707
	.p2align 4,,10
	.p2align 3
.Lhrdbf_710:
	movl	%eax, %edx
	subl	$1, %eax
	movl	352(%rsp,%rdx,4), %edi
	cmpl	%edi, 960(%rsp,%rdx,4)
	jne	.Lhrdbf_882
.Lhrdbf_707:
	cmpl	$-1, %eax
	jne	.Lhrdbf_710
.Lhrdbf_706:
	testb	$1, 8(%rsp)
	je	.Lhrdbf_862
.Lhrdbf_700:
	movl	%r14d, %eax
	addq	$1, %r15
	addq	$1, %r14
	addq	$1, %rbp
	cmpl	$17, %eax
	ja	.Lhrdbf_863
	cmpl	%r12d, %eax
	jb	.Lhrdbf_711
.Lhrdbf_863:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
.Lhrdbf_715:
	movl	$17, %eax
	cmpl	%eax, %r12d
	cmovbe	%r12d, %eax
	movl	%eax, 4(%rsp)
.Lhrdbf_713:
	movl	4(%rsp), %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
.Lhrdbf_716:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%rsi,%rsi,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %rsi
	cmpl	%edx, %edi
	ja	.Lhrdbf_716
	movl	4(%rsp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_717
	cmpb	$53, 1584(%rsp,%rax)
	ja	.Lhrdbf_718
	jne	.Lhrdbf_717
	testb	$1, %sil
	jne	.Lhrdbf_718
	movl	4(%rsp), %eax
	addl	$1, %eax
	cmpl	%r12d, %eax
	jb	.Lhrdbf_719
	jmp	.Lhrdbf_717
	.p2align 4,,10
	.p2align 3
.Lhrdbf_883:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.Lhrdbf_717
.Lhrdbf_719:
	cmpb	$48, 0(%r13,%rax)
	je	.Lhrdbf_883
.Lhrdbf_718:
	addq	$1, %rsi
.Lhrdbf_717:
	movabs	$-3689348814741910323, %r9
	xorl	%ecx, %ecx
.Lhrdbf_720:
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
	ja	.Lhrdbf_720
	cmpl	4(%rsp), %ecx
	jbe	.Lhrdbf_721
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 20(%rsp)
	testl	%edi, %edi
	je	.Lhrdbf_725
	leal	-1(%rdi), %eax
	movl	%edi, %ecx
	movq	%rax, %rdx
	movzbl	960(%rsp,%rax), %eax
	movl	%edx, %edi
.Lhrdbf_721:
	xorl	%edx, %edx
	jmp	.Lhrdbf_723
.Lhrdbf_884:
	movl	%edi, %eax
	subl	%edx, %eax
	movzbl	960(%rsp,%rax), %eax
.Lhrdbf_723:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbf_884
	cmpl	$1, %ecx
	jbe	.Lhrdbf_724
.Lhrdbf_885:
	leal	-1(%rcx), %edx
	cmpb	$48, 1584(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbf_724
	movl	%eax, %ecx
.Lhrdbf_725:
	cmpl	$1, %ecx
	ja	.Lhrdbf_885
.Lhrdbf_724:
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
	jle	.Lhrdbf_886
	movl	%ecx, %esi
	cmpq	%rsi, %rax
	jge	.Lhrdbf_730
	cmpb	$52, 1584(%rsp,%rax)
	movl	%eax, %ecx
	jbe	.Lhrdbf_736
	leal	-1(%rax), %esi
	movq	%rsi, %rax
	addq	%r13, %rsi
	subl	%esi, %eax
	jmp	.Lhrdbf_733
.Lhrdbf_732:
	movb	$48, (%rsi)
	leaq	-1(%rsi), %r10
	cmpq	%rsi, %r13
	je	.Lhrdbf_887
	movq	%r10, %rsi
.Lhrdbf_733:
	movzbl	(%rsi), %r10d
	leal	(%rax,%rsi), %r11d
	cmpb	$57, %r10b
	je	.Lhrdbf_732
	movl	%r11d, %eax
	addl	$1, %r10d
	movb	%r10b, 1584(%rsp,%rax)
	jmp	.Lhrdbf_736
	.p2align 4,,10
	.p2align 3
.Lhrdbf_698:
	leal	-1(%rsi), %eax
	movl	%eax, %edx
	jmp	.Lhrdbf_703
	.p2align 4,,10
	.p2align 3
.Lhrdbf_705:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	656(%rsp,%rcx,4), %edi
	cmpl	%edi, 960(%rsp,%rcx,4)
	jne	.Lhrdbf_888
.Lhrdbf_703:
	cmpl	$-1, %edx
	jne	.Lhrdbf_705
	xorl	%ecx, %ecx
	cmpl	%esi, 640(%rsp)
	je	.Lhrdbf_707
	jmp	.Lhrdbf_706
.Lhrdbf_880:
	testb	$1, %sil
	jne	.Lhrdbf_686
	cmpl	%r14d, %r12d
	jbe	.Lhrdbf_687
	movq	%r14, %rax
	jmp	.Lhrdbf_688
.Lhrdbf_889:
	addq	$1, %rax
	cmpl	%eax, %r12d
	jbe	.Lhrdbf_687
.Lhrdbf_688:
	cmpb	$48, 0(%r13,%rax)
	je	.Lhrdbf_889
.Lhrdbf_686:
	addq	$1, %rsi
	jmp	.Lhrdbf_687
.Lhrdbf_881:
	movq	%rsi, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_690:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rdi
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rdi
	ja	.Lhrdbf_690
	cmpl	%r9d, 4(%rsp)
	jnb	.Lhrdbf_689
	movabs	$-3689348814741910323, %rax
	movq	%r10, %rcx
	mulq	%rsi
	subq	%r15, %rcx
	movq	%rdx, %rsi
	shrq	$3, %rsi
	jmp	.Lhrdbf_689
.Lhrdbf_888:
	jnb	.Lhrdbf_704
	movl	$-1, %ecx
	cmpl	640(%rsp), %esi
	je	.Lhrdbf_707
	jmp	.Lhrdbf_700
.Lhrdbf_882:
	jnb	.Lhrdbf_709
	cmpl	$1, %ecx
	je	.Lhrdbf_862
.Lhrdbf_709:
	testl	%ecx, %ecx
	jne	.Lhrdbf_700
	jmp	.Lhrdbf_706
.Lhrdbf_699:
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_871
	movl	$1, %ecx
	leal	-1(%rsi), %eax
	jmp	.Lhrdbf_707
.Lhrdbf_871:
	jnb	.Lhrdbf_700
.Lhrdbf_862:
	movq	%rbx, %r8
	movq	24(%rsp), %rbx
	jmp	.Lhrdbf_713
.Lhrdbf_704:
	cmpl	640(%rsp), %esi
	jne	.Lhrdbf_871
	movl	$1, %ecx
	jmp	.Lhrdbf_707
.Lhrdbf_890:
	leal	-1(%rcx), %esi
	cmpb	$48, 1584(%rsp,%rsi)
	movq	%rsi, %rax
	jne	.Lhrdbf_870
	movl	%eax, %ecx
.Lhrdbf_736:
	cmpl	$1, %ecx
	jne	.Lhrdbf_890
.Lhrdbf_735:
	xorl	%eax, %eax
	movl	$0, %esi
	cmpb	$48, 1584(%rsp)
	movl	$1, %ecx
	cmovne	%r8, %rax
	cmove	%esi, %edx
	jmp	.Lhrdbf_728
	.p2align 4,,10
	.p2align 3
.Lhrdbf_672:
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
.Lhrdbf_680:
	leal	-1(%r11), %eax
	movq	%rdi, %rcx
	leaq	(%r8,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_681:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %rsi
	jne	.Lhrdbf_681
	testq	%rax, %rax
	je	.Lhrdbf_682
	movl	%r11d, %edx
	movl	$1, %r9d
	addl	$1, %r11d
	movl	%eax, 656(%rsp,%rdx,4)
.Lhrdbf_682:
	subl	$1, %r10d
	jne	.Lhrdbf_680
	testb	%r9b, %r9b
	je	.Lhrdbf_684
	movl	%r11d, 944(%rsp)
.Lhrdbf_684:
	movl	%ebp, %esi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	jmp	.Lhrdbf_678
.Lhrdbf_730:
	cmpl	$1, %ecx
	je	.Lhrdbf_735
.Lhrdbf_870:
	movq	%r8, %rax
.Lhrdbf_728:
	movl	20(%rsp), %r14d
	movl	$1, %r8d
	leal	1(%r14), %esi
	testl	%r14d, %r14d
	movslq	%esi, %rsi
	cmovs	%r8, %rsi
.Lhrdbf_737:
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
	jg	.Lhrdbf_639
	testl	%edx, %edx
	jne	.Lhrdbf_891
	movq	%rbx, %rsi
	movl	$1, %eax
.Lhrdbf_739:
	movl	20(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbf_740
	leal	1(%rdi), %eax
	xorl	%esi, %esi
	movslq	%eax, %r9
.Lhrdbf_742:
	leal	(%rdx,%rsi), %edi
	movl	$48, %r8d
	cmpl	%ecx, %esi
	jnb	.Lhrdbf_741
	movzbl	0(%r13,%rsi), %r8d
.Lhrdbf_741:
	addq	$1, %rsi
	movb	%r8b, (%rbx,%rdi)
	cmpq	%rsi, %r9
	jne	.Lhrdbf_742
	addl	%edx, %eax
.Lhrdbf_743:
	movl	16(%rsp), %r10d
	testl	%r10d, %r10d
	je	.Lhrdbf_631
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
	jmp	.Lhrdbf_745
.Lhrdbf_765:
	movl	%eax, %edx
.Lhrdbf_745:
	movl	$48, %r8d
	testq	%rsi, %rsi
	js	.Lhrdbf_744
	leal	(%r9,%rdx), %eax
	cmpl	%ecx, %eax
	jnb	.Lhrdbf_744
	movzbl	0(%r13,%rsi), %r8d
.Lhrdbf_744:
	leal	1(%rdx), %eax
	movb	%r8b, (%rbx,%rdx)
	addq	$1, %rsi
	cmpl	%r10d, %eax
	jne	.Lhrdbf_765
	movl	16(%rsp), %eax
	addl	%edi, %eax
	jmp	.Lhrdbf_631
.Lhrdbf_886:
	jne	.Lhrdbf_727
	cmpb	$52, 1584(%rsp)
	jbe	.Lhrdbf_727
	negl	%esi
	movb	$49, 1584(%rsp)
	movq	%r8, %rax
	movl	$1, %ecx
	movl	%esi, 20(%rsp)
	jmp	.Lhrdbf_728
.Lhrdbf_727:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %esi
	movl	$1, %ecx
	movb	$48, 1584(%rsp)
	movl	$0, 20(%rsp)
	jmp	.Lhrdbf_737
.Lhrdbf_891:
	movb	$45, (%rbx)
	leaq	1(%rbx), %rsi
	movl	$2, %eax
	jmp	.Lhrdbf_739
.Lhrdbf_875:
	subl	$1, %r8d
	jmp	.Lhrdbf_656
.Lhrdbf_876:
	movl	16(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rbx)
	leaq	2(%rbx), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rbx,%rcx), %rcx
.Lhrdbf_659:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_659
	jmp	.Lhrdbf_631
.Lhrdbf_740:
	movb	$48, (%rsi)
	jmp	.Lhrdbf_743
.Lhrdbf_747:
	movl	$1, %edx
	jmp	.Lhrdbf_650
.Lhrdbf_887:
	movb	$49, 1584(%rsp)
	movl	%r9d, 20(%rsp)
	jmp	.Lhrdbf_736
	.size	hrdbf_fmt_harbour.part.0, .-hrdbf_fmt_harbour.part.0
	.p2align 4
	.type	hrdbf_write_number_double.part.0, @function
hrdbf_write_number_double.part.0:
.Lhrdbf_entry_hrdbf_write_number_double.part.0:
	movzbl	13(%rsi), %edx
	movl	$4, %eax
	cmpb	$17, %dl
	ja	.Lhrdbf_899
	pushq	%rbp
	pushq	%rbx
	movq	%rsi, %rbx
	subq	$408, %rsp
	cmpb	12(%rsi), %dl
	jnb	.Lhrdbf_892
	movq	%rdi, %rbp
	movl	$400, %esi
	movq	%rsp, %rdi
	call .Lhrdbf_entry_hrdbf_fmt_harbour.part.0
	movl	%eax, %r9d
	movl	$5, %eax
	testl	%r9d, %r9d
	je	.Lhrdbf_892
	movzwl	14(%rbx), %ecx
	movzbl	12(%rbx), %edx
	movq	%rsp, %r8
	movq	%rbp, %rdi
	movzbl	11(%rbx), %esi
	call .Lhrdbf_entry_hrdbf_local_put_number.isra.0
.Lhrdbf_892:
	addq	$408, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_899:
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
.Lhrdbf_903:
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
	jbe	.Lhrdbf_913
	cmpl	$19, %r8d
	jbe	.Lhrdbf_903
.Lhrdbf_913:
	leaq	32778(%rdi), %r10
	leaq	32937(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_911:
	movb	%cl, 14(%rsp)
	leal	-1(%r8), %r9d
	movq	%r10, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbf_905
	.p2align 4,,10
	.p2align 3
.Lhrdbf_907:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_906
.Lhrdbf_905:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_907
	leaq	14(%rsp), %rdx
	cmpq	%rsi, %rax
	jb	.Lhrdbf_908
	jmp	.Lhrdbf_906
	.p2align 4,,10
	.p2align 3
.Lhrdbf_909:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %rdi
	cmpq	%rsi, %rax
	jnb	.Lhrdbf_906
	movzbl	1(%rdx), %ecx
	movq	%rdi, %rdx
.Lhrdbf_908:
	testb	%cl, %cl
	jne	.Lhrdbf_909
.Lhrdbf_906:
	movb	$0, (%rax)
	testl	%r9d, %r9d
	je	.Lhrdbf_902
	leal	-2(%r8), %eax
	movl	%r9d, %r8d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbf_911
.Lhrdbf_902:
	addq	$56, %rsp
	ret
	.size	hrdbf_local_ddec, .-hrdbf_local_ddec
	.p2align 4
	.type	hrdbf_local_dname, @function
hrdbf_local_dname:
.Lhrdbf_entry_hrdbf_local_dname:
	xorl	%r8d, %r8d
	movl	$63, %r9d
	leaq	32937(%rdi), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_921:
	movl	%r8d, %eax
	movzbl	(%rsi,%rax), %ecx
	testb	%cl, %cl
	je	.Lhrdbf_920
	leal	-32(%rcx), %eax
	cmpb	$95, %al
	leaq	32778(%rdi), %rax
	cmovnb	%r9d, %ecx
	jmp	.Lhrdbf_923
	.p2align 4,,10
	.p2align 3
.Lhrdbf_925:
	addq	$1, %rax
	cmpq	%rax, %rdx
	jbe	.Lhrdbf_924
.Lhrdbf_923:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_925
	cmpq	%rdx, %rax
	jnb	.Lhrdbf_924
	movb	%cl, (%rax)
	addq	$1, %rax
.Lhrdbf_924:
	addl	$1, %r8d
	movb	$0, (%rax)
	cmpl	$11, %r8d
	jne	.Lhrdbf_921
.Lhrdbf_920:
	ret
	.size	hrdbf_local_dname, .-hrdbf_local_dname
	.p2align 4
	.type	hrntx_file_open.part.0.constprop.0, @function
hrntx_file_open.part.0.constprop.0:
.Lhrdbf_entry_hrntx_file_open.part.0.constprop.0:
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
.Lhrdbf_930:
	movq	%r9, %rax
	movq	%r8, %rsi
	syscall
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_930
	testq	%rax, %rax
	js	.Lhrdbf_985
	movl	$8, %r8d
	xorl	%esi, %esi
	movl	$2, %edx
	movq	%rbx, %rdi
	movq	%r8, %rax
	syscall
	movq	%rax, %rbp
	testq	%rax, %rax
	js	.Lhrdbf_933
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.Lhrdbf_989
	cmpl	$1, %r12d
	movq	%rbp, %rax
	sbbq	%rcx, %rcx
	cqto
	andl	$512, %ecx
	addq	$512, %rcx
	idivq	%rcx
	movq	%rdx, %r13
	testq	%rdx, %rdx
	jne	.Lhrdbf_938
	movq	%r8, %rax
	movq	%rdx, %rsi
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_939
	movq	%rbp, hrdbf_app_order+48(%rip)
	xorl	%r9d, %r9d
	movq	%r13, %rdi
	movq	%rbp, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
	syscall
	cmpq	$-4095, %rax
	jb	.Lhrdbf_940
	movq	$0, hrdbf_app_order+32(%rip)
.Lhrdbf_941:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbf_982
	.p2align 4,,10
	.p2align 3
.Lhrdbf_989:
	movl	$3, %eax
	movq	%rsi, %rdx
.Lhrdbf_988:
	syscall
	movl	$1, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_983
.Lhrdbf_936:
	movq	hrdbf_app_order+32(%rip), %r10
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_958
	movl	$11, %r9d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r10, %rdi
	movq	%r9, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_959
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_929
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_985
.Lhrdbf_984:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_929:
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
.Lhrdbf_959:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_985
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_985
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_985:
	movl	$7, %r8d
	jmp	.Lhrdbf_929
	.p2align 4,,10
	.p2align 3
.Lhrdbf_933:
	movl	$3, %eax
	movq	%rsi, %rdx
	syscall
	movl	$7, %r8d
	jmp	.Lhrdbf_936
.Lhrdbf_939:
	movl	$3, %eax
	syscall
	movl	$7, %r8d
	jmp	.Lhrdbf_936
.Lhrdbf_945:
	movl	$3, %eax
	movq	%r9, %rsi
	movq	%r9, %rdx
	syscall
.Lhrdbf_983:
	movl	$7, %r8d
	jmp	.Lhrdbf_936
	.p2align 4,,10
	.p2align 3
.Lhrdbf_958:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_929
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_984
	jmp	.Lhrdbf_985
	.p2align 4,,10
	.p2align 3
.Lhrdbf_938:
	movl	$3, %eax
	movq	%rsi, %rdx
	jmp	.Lhrdbf_988
	.p2align 4,,10
	.p2align 3
.Lhrdbf_940:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_941
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_942
	jmp	.Lhrdbf_943
	.p2align 4,,10
	.p2align 3
.Lhrdbf_990:
	movq	hrdbf_app_order+32(%rip), %rsi
.Lhrdbf_942:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%r9, %rax
	movq	%rbx, %rdi
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_944
	testq	%rax, %rax
	jle	.Lhrdbf_945
	addq	%rax, %r8
.Lhrdbf_944:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_990
.Lhrdbf_943:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_946:
	movq	%r8, %rax
	movq	%rbx, %rdi
	syscall
	movq	%rax, %rbp
	cmpq	$-4, %rax
	je	.Lhrdbf_946
	testq	%rax, %rax
	jne	.Lhrdbf_947
	cmpl	$1, %r12d
	movl	hrdbf_app_state+16(%rip), %esi
	movq	hrdbf_app_order+48(%rip), %rax
	sbbq	%rcx, %rcx
	andl	$512, %ecx
	leaq	0(,%rsi,8), %r15
	addq	$512, %rcx
	cmpq	$8388608, %rsi
	ja	.Lhrdbf_949
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
	syscall
	cmpq	$-4095, %rax
	jb	.Lhrdbf_950
	movq	$0, hrdbf_app_order+40(%rip)
.Lhrdbf_951:
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_982:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
	syscall
	movl	$8, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_936
	jmp	.Lhrdbf_983
.Lhrdbf_949:
	movl	$3, %eax
	movq	%rbp, %rsi
	movq	%rbp, %rdx
	syscall
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_936
	jmp	.Lhrdbf_983
.Lhrdbf_947:
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
	syscall
	movl	$7, %r8d
	jmp	.Lhrdbf_936
.Lhrdbf_950:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbf_951
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
	je	.Lhrdbf_955
	cmpl	$5, %r8d
	jne	.Lhrdbf_988
	syscall
	movl	$3, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_936
	jmp	.Lhrdbf_983
	.p2align 4,,10
	.p2align 3
.Lhrdbf_955:
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_929
	jmp	.Lhrdbf_983
	.size	hrntx_file_open.part.0.constprop.0, .-hrntx_file_open.part.0.constprop.0
	.section	.rodata
.Lhrdbf_C2:
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
	movzbl	.Lhrdbf_C2(%rax), %ecx
	leaq	32778(%rdi), %rax
	addq	$32937, %rdi
	movq	%rax, %rdx
	movb	%cl, 14(%rsp)
	jmp	.Lhrdbf_992
	.p2align 4,,10
	.p2align 3
.Lhrdbf_994:
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_993
.Lhrdbf_992:
	cmpb	$0, (%rdx)
	jne	.Lhrdbf_994
	leaq	14(%rsp), %r8
	cmpq	%rdi, %rdx
	jb	.Lhrdbf_995
	jmp	.Lhrdbf_993
	.p2align 4,,10
	.p2align 3
.Lhrdbf_997:
	movb	%cl, (%rdx)
	addq	$1, %rdx
	leaq	1(%r8), %r9
	cmpq	%rdi, %rdx
	jnb	.Lhrdbf_993
	movzbl	1(%r8), %ecx
	movq	%r9, %r8
.Lhrdbf_995:
	testb	%cl, %cl
	jne	.Lhrdbf_997
.Lhrdbf_993:
	andl	$15, %esi
	movb	$0, (%rdx)
	movzbl	.Lhrdbf_C2(%rsi), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbf_999
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1001:
	addq	$1, %rax
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_1000
.Lhrdbf_999:
	cmpb	$0, (%rax)
	jne	.Lhrdbf_1001
	leaq	14(%rsp), %rdx
	cmpq	%rdi, %rax
	jb	.Lhrdbf_1002
	jmp	.Lhrdbf_1000
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1003:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rdi, %rax
	jnb	.Lhrdbf_1000
.Lhrdbf_1002:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_1003
.Lhrdbf_1000:
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
	je	.Lhrdbf_1012
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_1012:
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
	je	.Lhrdbf_1015
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_1015
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_1017
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
.Lhrdbf_1019:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_1029
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_1015:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1017:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_1020
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_1015
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1029:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_1015
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1020:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_1019
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
	je	.Lhrdbf_1109
	testl	%esi, %esi
	je	.Lhrdbf_1110
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_1110
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
	ja	.Lhrdbf_1110
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_1113
	cmpb	$78, %r8b
	je	.Lhrdbf_1114
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_1115
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_1056
	cmpb	$89, %dl
	je	.Lhrdbf_1056
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_1110
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_1109
	movabs	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_1109
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1110:
	xorl	%r8d, %r8d
.Lhrdbf_1109:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1056:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1113:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1109
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1114:
	testl	%edi, %edi
	je	.Lhrdbf_1110
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_1035
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1036:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_1110
.Lhrdbf_1035:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_1036
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_1038
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1062:
	movl	%edx, %edi
.Lhrdbf_1038:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_1037
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_1062
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_1082
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_1060:
	movabs	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabs	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_1040:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_1067
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_1059:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabs	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_1044
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1116:
	testl	%ebx, %ebx
	jne	.Lhrdbf_1083
	movl	$1, %ebx
.Lhrdbf_1041:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_1043
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_1044:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_1116
.Lhrdbf_1083:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_1067
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_1073
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_1041
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_1041
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1115:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1053:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_1075
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1053
	jmp	.Lhrdbf_1110
.Lhrdbf_1075:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1052:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_1076
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_1052
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
	jbe	.Lhrdbf_1109
	cmpl	$11, %edx
	ja	.Lhrdbf_1109
	testl	%edi, %edi
	je	.Lhrdbf_1109
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_1117
.Lhrdbf_1054:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_1109
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1109
.Lhrdbf_1043:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_1030
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_1030
	leal	1(%r13), %eax
	jbe	.Lhrdbf_1045
	movabs	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_1046
	jmp	.Lhrdbf_1073
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1047:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_1073
.Lhrdbf_1046:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_1047
	testl	%r12d, %r12d
	jne	.Lhrdbf_1058
.Lhrdbf_1049:
	movq	%r11, %rax
.Lhrdbf_1050:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_1030:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_1073:
	movl	$4, %r8d
	jmp	.Lhrdbf_1030
.Lhrdbf_1037:
	je	.Lhrdbf_1032
	movabs	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_1040
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_1060
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1032:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1030
.Lhrdbf_1067:
	movl	$5, %r8d
	jmp	.Lhrdbf_1030
.Lhrdbf_1082:
	movabs	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_1059
.Lhrdbf_1076:
	movl	$5, %r8d
	jmp	.Lhrdbf_1109
.Lhrdbf_1117:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_1054
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_1055
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_1054
.Lhrdbf_1055:
	addl	$1, %r10d
	jmp	.Lhrdbf_1054
.Lhrdbf_1045:
	testl	%r12d, %r12d
	je	.Lhrdbf_1049
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_1050
.Lhrdbf_1058:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_1050
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_1118
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_1120
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_1120:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_1118:
	ret
	.size	hrdbf_deleted, .-hrdbf_deleted
	.section	.rodata
	.align 8
.Lhrdbf_C3:
	.string	"' numeric content overflows int64"
	.align 8
.Lhrdbf_C4:
	.string	"' content is not valid for its type"
	.align 8
.Lhrdbf_C5:
	.string	"file has fewer than the 33 header bytes"
	.section	.rodata
.Lhrdbf_C6:
	.string	"version byte 0x"
	.section	.rodata
	.align 8
.Lhrdbf_C7:
	.string	" is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)"
	.section	.rodata
.Lhrdbf_C8:
	.string	"implausible header length "
.Lhrdbf_C9:
	.string	" or record length "
.Lhrdbf_C10:
	.string	" for file size "
.Lhrdbf_C11:
	.string	"field descriptor "
	.section	.rodata
	.align 8
.Lhrdbf_C12:
	.string	" truncated before end of header"
	.align 8
.Lhrdbf_C13:
	.string	"more than 2046 field descriptors"
	.section	.rodata
.Lhrdbf_C14:
	.string	" has an empty name"
.Lhrdbf_C15:
	.string	"field '"
.Lhrdbf_C16:
	.string	"' has zero width"
.Lhrdbf_C17:
	.string	"C field '"
.Lhrdbf_C18:
	.string	"' declares decimals"
.Lhrdbf_C19:
	.string	"N field '"
.Lhrdbf_C20:
	.string	"' width "
.Lhrdbf_C21:
	.string	" / decimals "
.Lhrdbf_C22:
	.string	" outside supported range"
.Lhrdbf_C23:
	.string	"L field '"
	.section	.rodata
	.align 8
.Lhrdbf_C24:
	.string	"' width must be 1 with no decimals"
	.section	.rodata
.Lhrdbf_C25:
	.string	"D field '"
	.section	.rodata
	.align 8
.Lhrdbf_C26:
	.string	"' width must be 8 with no decimals"
	.section	.rodata
.Lhrdbf_C27:
	.string	"' has unsupported type '"
.Lhrdbf_C28:
	.string	"' (only C/N/D/L, no memo)"
	.section	.rodata
	.align 8
.Lhrdbf_C29:
	.string	"field widths exceed the 65535 record limit"
	.align 8
.Lhrdbf_C30:
	.string	"field descriptors not terminated by 0x0D"
	.section	.rodata
.Lhrdbf_C31:
	.string	"table declares no fields"
	.section	.rodata
	.align 8
.Lhrdbf_C32:
	.string	"field widths plus delete flag sum to "
	.section	.rodata
.Lhrdbf_C33:
	.string	" but header record length is "
	.section	.rodata
	.align 8
.Lhrdbf_C34:
	.string	"nonzero byte between field descriptors and header end"
	.section	.rodata
.Lhrdbf_C35:
	.string	"header record count "
.Lhrdbf_C36:
	.string	" exceeds the "
.Lhrdbf_C37:
	.string	" records physically present"
	.section	.rodata
	.align 8
.Lhrdbf_C38:
	.string	"unexpected trailing bytes after the last record (no 0x1A terminator)"
	.section	.rodata
.Lhrdbf_C39:
	.string	"record "
.Lhrdbf_C40:
	.string	" has delete flag 0x"
.Lhrdbf_C41:
	.string	" (expected space or '*')"
.Lhrdbf_C42:
	.string	" field '"
	.section	.rodata
	.align 8
.Lhrdbf_C43:
	.string	" (logical byte must be T/F/Y/N/?/space)"
	.section	.rodata
.Lhrdbf_C44:
	.string	" inside a deleted record"
.Lhrdbf_C45:
	.string	"duplicate field name '"
.Lhrdbf_C46:
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
	jbe	.Lhrdbf_1196
	cmpb	$3, (%rsi)
	movq	%rsi, %rbx
	jne	.Lhrdbf_1197
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
	jbe	.Lhrdbf_1127
	movzwl	%r13w, %eax
	movq	%rax, (%rsp)
	testl	%edi, %edi
	je	.Lhrdbf_1127
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1127
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
.Lhrdbf_1151:
	cmpb	$13, (%r9)
	je	.Lhrdbf_1198
	cmpq	16(%rsp), %r12
	je	.Lhrdbf_1199
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	cmpw	$2046, %ax
	je	.Lhrdbf_1200
	leal	1(%rax), %ecx
	movzwl	%ax, %r8d
	movzwl	%ax, %r15d
	xorl	%eax, %eax
	movw	%cx, hrdbf_open_tmp+36(%rip)
	salq	$4, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1135:
	movzbl	(%r9,%rax), %edx
	movb	%dl, hrdbf_open_tmp+42(%r8,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_1135
	movq	%r15, %rax
	salq	$4, %rax
	movzbl	hrdbf_open_tmp+42(%rax), %r11d
	testb	%r11b, %r11b
	je	.Lhrdbf_1136
	movzwl	%cx, %eax
	cmpw	$1, %cx
	jbe	.Lhrdbf_1137
	leal	-1(%rax), %r10d
	leaq	hrdbf_open_tmp+43(%r8), %r13
	xorl	%esi, %esi
	salq	$4, %r10
	leaq	hrdbf_open_tmp+53(%r8), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1138:
	movq	%r13, %rax
	movl	%r11d, %edx
	jmp	.Lhrdbf_1141
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1202:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbf_1141:
	movq	%rax, %rcx
	subq	%r8, %rcx
	cmpb	%dl, -1(%rcx,%rsi)
	jne	.Lhrdbf_1201
	cmpq	%rdi, %rax
	jne	.Lhrdbf_1202
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C45, %esi
	call .Lhrdbf_entry_hrdbf_local_dset
	movq	%rbp, %rdi
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C46, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
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
.Lhrdbf_1127:
	movl	$.Lhrdbf_C8, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movzwl	hrdbf_open_tmp+32(%rip), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C9, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzwl	hrdbf_open_tmp+34(%rip), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C10, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movq	%r12, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$1, %eax
.Lhrdbf_1123:
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
.Lhrdbf_1201:
	addq	$16, %rsi
	cmpq	%r10, %rsi
	jne	.Lhrdbf_1138
.Lhrdbf_1137:
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
	je	.Lhrdbf_1203
	cmpb	$67, %cl
	je	.Lhrdbf_1204
	cmpb	$78, %cl
	je	.Lhrdbf_1205
	cmpb	$76, %cl
	je	.Lhrdbf_1206
	cmpb	$68, %cl
	jne	.Lhrdbf_1148
	cmpw	$8, 22(%rdx)
	je	.Lhrdbf_1144
	movl	$.Lhrdbf_C25, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C26, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1196:
	movl	$.Lhrdbf_C5, %esi
	call .Lhrdbf_entry_hrdbf_local_dset
	addq	$104, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_1197:
	movl	$.Lhrdbf_C6, %esi
	call .Lhrdbf_entry_hrdbf_local_dset
	movzbl	(%rbx), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dhex
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C7, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	addq	$104, %rsp
	movl	$2, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_1204:
	testb	%sil, %sil
	jne	.Lhrdbf_1207
.Lhrdbf_1144:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbf_1208
	addq	$32, %r12
	addq	$32, %r9
	cmpq	%r12, (%rsp)
	ja	.Lhrdbf_1151
	movl	$.Lhrdbf_C30, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1205:
	cmpb	$17, %sil
	ja	.Lhrdbf_1170
	cmpb	%sil, %al
	ja	.Lhrdbf_1144
.Lhrdbf_1170:
	movl	$.Lhrdbf_C19, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C20, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movq	%r15, %rax
	movq	%rbp, %rdi
	salq	$4, %rax
	movzbl	hrdbf_open_tmp+54(%rax), %esi
	leaq	hrdbf_open_tmp+32(%rax), %r11
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C21, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	23(%r11), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C22, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$4, %eax
	jmp	.Lhrdbf_1123
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1206:
	cmpw	$1, 22(%rdx)
	je	.Lhrdbf_1144
	movl	$.Lhrdbf_C23, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C24, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1199:
	movl	$.Lhrdbf_C11, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	movq	%rbp, %rdi
	leaq	1(%rax), %rsi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C12, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1200:
	movl	$.Lhrdbf_C13, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$4, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1198:
	movzwl	hrdbf_open_tmp+36(%rip), %r11d
	movl	%ebx, %ecx
	movq	%r12, %rax
	movzwl	30(%rsp), %r13d
	movq	32(%rsp), %rbx
	movq	40(%rsp), %r12
	testw	%r11w, %r11w
	je	.Lhrdbf_1209
	addq	$1, %rax
	cmpl	%ecx, 8(%rsp)
	je	.Lhrdbf_1153
	jmp	.Lhrdbf_1210
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1154:
	addq	$1, %rax
	cmpb	$0, -1(%rbx,%rax)
	jne	.Lhrdbf_1211
.Lhrdbf_1153:
	cmpq	%rax, (%rsp)
	ja	.Lhrdbf_1154
	movl	%ecx, %r10d
	movq	%r12, %rax
	xorl	%edx, %edx
	subq	(%rsp), %rax
	divq	%r10
	movl	24(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbf_1212
	movq	%r8, %rax
	imulq	%r10, %rax
	addq	(%rsp), %rax
	cmpq	%rax, %r12
	je	.Lhrdbf_1156
	movq	%r12, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbf_1157
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbf_1156
.Lhrdbf_1157:
	movl	$.Lhrdbf_C38, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1136:
	movl	$.Lhrdbf_C11, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movzwl	hrdbf_open_tmp+36(%rip), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C14, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1203:
	movl	$.Lhrdbf_C15, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C16, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1211:
	movl	$.Lhrdbf_C34, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1208:
	movl	$.Lhrdbf_C29, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$4, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1207:
	movl	$.Lhrdbf_C17, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C18, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1210:
	movl	$.Lhrdbf_C32, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	%ecx, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C33, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzwl	hrdbf_open_tmp+34(%rip), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1209:
	movl	$.Lhrdbf_C31, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1148:
	movl	$.Lhrdbf_C15, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movq	%rbp, %rdi
	leaq	hrdbf_open_tmp+42(%r8), %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	$.Lhrdbf_C27, %esi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	(%r10), %eax
	leaq	64(%rsp), %rsi
	movq	%rbp, %rdi
	movb	$0, 65(%rsp)
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	movb	%al, 64(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$.Lhrdbf_C28, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1156:
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
	je	.Lhrdbf_1166
	movw	%r14w, 30(%rsp)
	movl	%r13d, %r14d
	movl	%r11d, %r13d
	movq	%rbx, %r11
	movq	%r12, 32(%rsp)
	movq	%r10, %r12
	movq	%rbp, %r10
	movq	%r8, %rbp
.Lhrdbf_1165:
	movq	8(%rsp), %rax
	addq	$1, %r15
	movzbl	(%rax), %eax
	movb	%al, (%rsp)
	cmpb	$32, %al
	je	.Lhrdbf_1160
	cmpb	$42, %al
	jne	.Lhrdbf_1213
.Lhrdbf_1160:
	movq	%r15, hrdbf_open_tmp+24(%rip)
	movl	$1, %ebx
	jmp	.Lhrdbf_1164
.Lhrdbf_1161:
	addl	$1, %ebx
	cmpl	%ebx, 16(%rsp)
	jb	.Lhrdbf_1214
.Lhrdbf_1164:
	leaq	64(%rsp), %rdx
	movl	%ebx, %esi
	movl	$hrdbf_open_tmp, %edi
	movq	%r11, 56(%rsp)
	movq	%r10, 48(%rsp)
	movb	%r9b, 40(%rsp)
	call .Lhrdbf_entry_hrdbf_get
	movzbl	40(%rsp), %r9d
	movq	48(%rsp), %r10
	testl	%eax, %eax
	movq	56(%rsp), %r11
	je	.Lhrdbf_1161
	movq	%r10, %rdi
	movl	$.Lhrdbf_C39, %esi
	movl	%eax, 24(%rsp)
	movq	%r10, %rbp
	movl	%ebx, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_local_dset
	movq	%r10, %rdi
	movq	%r15, %rsi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C42, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	8(%rsp), %ecx
	movq	%rbp, %rdi
	leal	1(%rcx), %esi
	leal	-1(%rcx), %r10d
	salq	$4, %rsi
	addq	$hrdbf_open_tmp+10, %rsi
	call .Lhrdbf_entry_hrdbf_local_dname
	movl	24(%rsp), %eax
	movl	$.Lhrdbf_C4, %edx
	movl	$.Lhrdbf_C3, %esi
	cmpl	$4, %eax
	cmovne	%rdx, %rsi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	%r10d, %edx
	movl	24(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, hrdbf_open_tmp+53(%rdx)
	je	.Lhrdbf_1215
.Lhrdbf_1163:
	cmpb	$42, (%rsp)
	jne	.Lhrdbf_1123
	movl	$.Lhrdbf_C44, %esi
	movq	%rbp, %rdi
	movl	%eax, (%rsp)
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	(%rsp), %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1214:
	addq	%r12, 8(%rsp)
	cmpq	%r15, %rbp
	jne	.Lhrdbf_1165
	movq	%r11, %rbx
	movq	32(%rsp), %r12
	movl	%r13d, %r11d
	movl	%r14d, %r13d
	movzwl	30(%rsp), %r14d
	movq	%r10, %rbp
.Lhrdbf_1166:
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
.Lhrdbf_1159:
	cmpl	%ecx, %esi
	jbe	.Lhrdbf_1216
	leaq	-11(%rax), %rdx
.Lhrdbf_1167:
	movzbl	hrdbf_open_tmp(%rdx), %edi
	movb	%dil, 0(%rbp,%rdx)
	addq	$1, %rdx
	cmpq	%rax, %rdx
	jne	.Lhrdbf_1167
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
	jmp	.Lhrdbf_1159
.Lhrdbf_1212:
	movl	$.Lhrdbf_C35, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dset
	movl	hrdbf_open_tmp+16(%rip), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C36, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	movq	%r12, %rax
	movq	%rbp, %rdi
	movzwl	hrdbf_open_tmp+34(%rip), %ecx
	subq	%rdx, %rax
	xorl	%edx, %edx
	divq	%rcx
	movq	%rax, %rsi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C37, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1216:
	movb	$1, 40(%rbp)
	xorl	%eax, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1213:
	movq	%r10, %rdi
	movl	$.Lhrdbf_C39, %esi
	movq	%r10, %rbp
	call .Lhrdbf_entry_hrdbf_local_dset
	movq	%r15, %rsi
	movq	%r10, %rdi
	call .Lhrdbf_entry_hrdbf_local_ddec
	movl	$.Lhrdbf_C40, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movzbl	(%rsp), %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dhex
	movl	$.Lhrdbf_C41, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	$5, %eax
	jmp	.Lhrdbf_1123
.Lhrdbf_1215:
	movl	$.Lhrdbf_C43, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_dcat
	movl	24(%rsp), %eax
	jmp	.Lhrdbf_1163
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
	ja	.Lhrdbf_1219
	je	.Lhrdbf_1239
	cmpl	$5, %edx
	je	.Lhrdbf_1222
	shrq	$8, %rdi
	jne	.Lhrdbf_1240
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_1219
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_1219
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1219
	movabs	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_1219
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
	ja	.Lhrdbf_1235
	testq	%rsi, %rsi
	je	.Lhrdbf_1235
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_1241
.Lhrdbf_1224:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1239:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_1219
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_1242
.Lhrdbf_1219:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1222:
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
.Lhrdbf_1242:
	testb	$-1, %dh
	jne	.Lhrdbf_1219
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
.Lhrdbf_1240:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1235:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1241:
	testb	$3, %cl
	jne	.Lhrdbf_1224
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_1225
	addl	$1, %eax
	jmp	.Lhrdbf_1224
.Lhrdbf_1225:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_1224
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
	ja	.Lhrdbf_1243
	movzbl	hrdbf_local_CSWTCH.411(%rdx), %eax
.Lhrdbf_1243:
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
	jne	.Lhrdbf_1246
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_1256
	testl	%edx, %edx
	je	.Lhrdbf_1249
	cmpl	$9, %edx
	je	.Lhrdbf_1249
	movl	$1, %eax
.Lhrdbf_1246:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1256:
	testl	$65280, %r9d
	jne	.Lhrdbf_1257
.Lhrdbf_1249:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1257:
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
	movq	%rdi, %r9
	movq	%rsi, %r10
	movq	%rdx, %r11
	pushq	%r12
	pushq	%rbp
	movq	%rcx, %rbp
	pushq	%rbx
	movq	%r8, %rbx
	subq	$40, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1258
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1258
	movzbl	%r9b, %r13d
	movzbl	%r11b, %r12d
	cmpb	$11, %r9b
	jne	.Lhrdbf_1260
	cmpl	$11, %r12d
	jne	.Lhrdbf_1260
.Lhrdbf_1271:
	xorl	%edx, %edx
	cmpq	%rbp, %r10
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_1258:
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1260:
	cmpl	$1, %r13d
	je	.Lhrdbf_1274
	cmpl	$1, %r12d
	je	.Lhrdbf_1274
	cmpl	$3, %r13d
	jne	.Lhrdbf_1263
	cmpl	$3, %r12d
	jne	.Lhrdbf_1263
	testq	%r10, %r10
	sete	%dl
	testq	%rbp, %rbp
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_1258
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1274:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_1258
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1263:
	movq	%r9, %rdi
	movq	%r10, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1267
	cmpl	$12, %r13d
	je	.Lhrdbf_1297
	testl	%r13d, %r13d
	je	.Lhrdbf_1266
	cmpl	$9, %r13d
	jne	.Lhrdbf_1267
.Lhrdbf_1266:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1267
	cmpl	$12, %r12d
	je	.Lhrdbf_1298
	testl	%r12d, %r12d
	je	.Lhrdbf_1271
	cmpl	$9, %r12d
	je	.Lhrdbf_1271
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1267:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r10, %rsi
	call .Lhrdbf_entry_hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbf_1299
.Lhrdbf_1273:
	movl	$1, %eax
	jmp	.Lhrdbf_1258
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1297:
	testl	$65280, %r9d
	je	.Lhrdbf_1266
	jmp	.Lhrdbf_1267
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1299:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbf_1273
	xorl	%edx, %edx
	movsd	16(%rsp), %xmm0
	ucomisd	24(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_1258
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1298:
	testl	$65280, %r11d
	je	.Lhrdbf_1271
	jmp	.Lhrdbf_1267
	.size	hrv_equal, .-hrv_equal
	.p2align 4
	.globl	hrv_compare
	.type	hrv_compare, @function
hrv_compare:
.Lhrdbf_entry_hrv_compare:
	endbr64
	pushq	%r12
	movq	%rdi, %r9
	movq	%rsi, %r12
	movq	%rdx, %r10
	pushq	%rbp
	movq	%r8, %r11
	movq	%rcx, %rbp
	subq	$40, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1300
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	je	.Lhrdbf_1321
.Lhrdbf_1300:
	addq	$40, %rsp
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1321:
	movq	%r9, %rdi
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1302
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_1322
	testl	%eax, %eax
	je	.Lhrdbf_1304
	cmpl	$9, %eax
	je	.Lhrdbf_1304
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1302:
	leaq	8(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r9, %rdi
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbf_1323
.Lhrdbf_1310:
	addq	$40, %rsp
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1323:
	leaq	12(%rsp), %rcx
	leaq	24(%rsp), %rdx
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbf_1310
	movsd	16(%rsp), %xmm1
	movsd	24(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.Lhrdbf_1311
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.Lhrdbf_1311:
	movq	%rdx, (%r11)
	jmp	.Lhrdbf_1300
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1322:
	testl	$65280, %r9d
	jne	.Lhrdbf_1302
.Lhrdbf_1304:
	movq	%r10, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1302
	movzbl	%r10b, %edx
	cmpb	$12, %r10b
	je	.Lhrdbf_1324
	testl	%edx, %edx
	je	.Lhrdbf_1307
	cmpl	$9, %edx
	jne	.Lhrdbf_1302
.Lhrdbf_1307:
	xorl	%edx, %edx
	cmpq	%rbp, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%r11)
	jmp	.Lhrdbf_1300
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1324:
	testl	$65280, %r10d
	je	.Lhrdbf_1307
	jmp	.Lhrdbf_1302
	.size	hrv_compare, .-hrv_compare
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
	jne	.Lhrdbf_1325
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_1329
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_1327
	cmpl	$1, %ecx
	je	.Lhrdbf_1330
.Lhrdbf_1329:
	movl	$1, %eax
.Lhrdbf_1325:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1327:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1330:
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
	jne	.Lhrdbf_1331
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_1378
	cmpl	$12, %eax
	jne	.Lhrdbf_1357
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
.Lhrdbf_1339:
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
	ja	.Lhrdbf_1339
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_1379
	movl	$1, %esi
.Lhrdbf_1340:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_1341:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_1342
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_1380
	subl	%eax, %r14d
	je	.Lhrdbf_1350
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1349:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1349
.Lhrdbf_1350:
	testq	%r11, %r11
	jns	.Lhrdbf_1348
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_1348:
	testl	%esi, %esi
	je	.Lhrdbf_1351
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_1353
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1361:
	movl	%edx, %eax
.Lhrdbf_1353:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_1352
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_1352:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_1361
	addl	%esi, %r14d
.Lhrdbf_1351:
	testl	%r10d, %r10d
	je	.Lhrdbf_1331
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1355:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_1354
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_1354:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_1355
.Lhrdbf_1331:
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
.Lhrdbf_1378:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_1342
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_1335
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1337:
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
	jne	.Lhrdbf_1337
	jmp	.Lhrdbf_1331
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1357:
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
.Lhrdbf_1379:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_1340
	movl	%esi, %eax
	jmp	.Lhrdbf_1341
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1342:
	movl	$3, %r8d
	jmp	.Lhrdbf_1331
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1335:
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
	jmp	.Lhrdbf_1331
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1380:
	testl	%r14d, %r14d
	je	.Lhrdbf_1331
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1345:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_1345
	jmp	.Lhrdbf_1331
	.size	hrv_render, .-hrv_render
	.p2align 4
	.globl	hrv_arith
	.type	hrv_arith, @function
hrv_arith:
.Lhrdbf_entry_hrv_arith:
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
	call .Lhrdbf_entry_hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	movq	%r12, %rdi
	movq	%r13, %rsi
	call .Lhrdbf_entry_hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	leal	-43(%rbx), %eax
	movq	%r9, %r14
	andl	$-3, %eax
	movl	%eax, %r15d
	je	.Lhrdbf_1421
	cmpl	$42, %ebx
	je	.Lhrdbf_1421
	cmpl	$47, %ebx
	je	.Lhrdbf_1396
	cmpl	$37, %ebx
	je	.Lhrdbf_1423
	movl	$1, %r10d
	cmpl	$94, %ebx
	je	.Lhrdbf_1423
.Lhrdbf_1381:
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
.Lhrdbf_1421:
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_1396
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbf_1444
	testl	%eax, %eax
	je	.Lhrdbf_1387
	cmpl	$9, %eax
	je	.Lhrdbf_1387
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1396:
	leaq	16(%rsp), %rcx
	leaq	32(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	leaq	24(%rsp), %rcx
	leaq	40(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call .Lhrdbf_entry_hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	movsd	40(%rsp), %xmm1
	cmpl	$43, %ebx
	je	.Lhrdbf_1445
	testl	%r15d, %r15d
	je	.Lhrdbf_1446
	cmpl	$42, %ebx
	je	.Lhrdbf_1447
	ucomisd	.Lhrdbf_C47(%rip), %xmm1
	jp	.Lhrdbf_1422
	je	.Lhrdbf_1416
.Lhrdbf_1422:
	movsd	32(%rsp), %xmm0
	movl	$517, %eax
	divsd	%xmm1, %xmm0
.Lhrdbf_1399:
	movq	%rax, (%r14)
	movsd	%xmm0, 8(%r14)
	jmp	.Lhrdbf_1381
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1444:
	testl	$65280, %r11d
	jne	.Lhrdbf_1396
.Lhrdbf_1387:
	movq	%r12, %rdi
	movq	%r13, %rsi
	call .Lhrdbf_entry_hrv_validate
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1396
	movzbl	%r12b, %eax
	cmpb	$12, %r12b
	je	.Lhrdbf_1448
	testl	%eax, %eax
	je	.Lhrdbf_1390
	cmpl	$9, %eax
	jne	.Lhrdbf_1396
.Lhrdbf_1390:
	movq	$0, (%r14)
	cmpl	$43, %ebx
	je	.Lhrdbf_1449
	testl	%r15d, %r15d
	je	.Lhrdbf_1450
	imulq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.Lhrdbf_1381
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1423:
	movq	%rsp, %rcx
	leaq	8(%rsp), %rdx
	movq	%r11, %rdi
	movq	%rbp, %rsi
	call .Lhrdbf_entry_hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	leaq	4(%rsp), %rcx
	leaq	16(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call .Lhrdbf_entry_hrv_to_double
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1381
	movsd	16(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.Lhrdbf_1405
	ucomisd	.Lhrdbf_C47(%rip), %xmm0
	jp	.Lhrdbf_1406
	jne	.Lhrdbf_1406
	movq	$0, (%r14)
	movq	$0, 8(%r14)
	jmp	.Lhrdbf_1381
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1448:
	testl	$65280, %r12d
	je	.Lhrdbf_1390
	jmp	.Lhrdbf_1396
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1447:
	movl	$255, %edx
	movl	24(%rsp), %eax
	addl	16(%rsp), %eax
	cmpl	%edx, %eax
	movsd	32(%rsp), %xmm0
	cmova	%rdx, %rax
	mulsd	%xmm1, %xmm0
	salq	$8, %rax
	orq	$5, %rax
	jmp	.Lhrdbf_1399
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1416:
	movl	$5, %r10d
	jmp	.Lhrdbf_1381
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1445:
	addsd	32(%rsp), %xmm1
	movapd	%xmm1, %xmm0
.Lhrdbf_1442:
	movl	24(%rsp), %eax
	movl	16(%rsp), %edx
	cmpl	%edx, %eax
	cmovb	%rdx, %rax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.Lhrdbf_1399
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1446:
	movsd	32(%rsp), %xmm0
	subsd	%xmm1, %xmm0
	jmp	.Lhrdbf_1442
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1449:
	addq	%rbp, %r13
	movq	%r13, 8(%r14)
	jmp	.Lhrdbf_1381
.Lhrdbf_1405:
	movsd	8(%rsp), %xmm1
	movq	%xmm0, %rcx
	movabs	$9223372036854775807, %rax
	movq	%xmm1, %rsi
	movq	%xmm1, %rdx
	andq	%rax, %rsi
	andq	%rcx, %rax
	testq	%rdx, %rdx
	js	.Lhrdbf_1451
	testq	%rsi, %rsi
	jne	.Lhrdbf_1415
.Lhrdbf_1410:
	movabs	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_1408
	testq	%rcx, %rcx
	movl	$0, %edx
	movabs	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1408:
	movq	$517, (%r14)
	movq	%rdx, 8(%r14)
	jmp	.Lhrdbf_1381
.Lhrdbf_1450:
	subq	%r13, %rbp
	xorl	%r10d, %r10d
	movq	%rbp, 8(%r14)
	jmp	.Lhrdbf_1381
.Lhrdbf_1406:
	movsd	8(%rsp), %xmm1
	movsd	%xmm0, 32(%rsp)
	movsd	%xmm1, 24(%rsp)
	fldl 32(%rsp)
	fldl 24(%rsp)
	1: fprem
	fnstsw %ax
	test $4,%ah
	jnz 1b
	fstpl 40(%rsp)
	fstp %st(0)
	movq	40(%rsp), %rdx
	jmp	.Lhrdbf_1408
.Lhrdbf_1451:
	testq	%rsi, %rsi
	je	.Lhrdbf_1410
	movabs	$4841369599423283199, %rdx
	movq	%rax, %xmm2
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1411
	cvttsd2siq	%xmm2, %rdx
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rdx, %xmm1
	ucomisd	%xmm2, %xmm1
	jp	.Lhrdbf_1418
	je	.Lhrdbf_1411
.Lhrdbf_1418:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.Lhrdbf_1408
.Lhrdbf_1415:
	movsd	%xmm1, 24(%rsp)
	movsd	%xmm0, 32(%rsp)
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
	movq	40(%rsp), %rdx
	jmp	.Lhrdbf_1408
.Lhrdbf_1411:
	movq	%rsi, 24(%rsp)
	movsd	%xmm0, 32(%rsp)
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
	movabs	$4841369599423283199, %rdx
	movsd	40(%rsp), %xmm1
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1443
	cvttsd2siq	%xmm2, %rax
	testb	$1, %al
	je	.Lhrdbf_1443
	pxor	%xmm0, %xmm0
	subsd	%xmm1, %xmm0
	movq	%xmm0, %rdx
	jmp	.Lhrdbf_1408
.Lhrdbf_1443:
	movq	%xmm1, %rdx
	jmp	.Lhrdbf_1408
	.size	hrv_arith, .-hrv_arith
	.section	.rodata
.Lhrdbf_C49:
	.string	"DBF unknown value error"
	.text
	.p2align 4
	.globl	hrv_error_name
	.type	hrv_error_name, @function
hrv_error_name:
.Lhrdbf_entry_hrv_error_name:
	endbr64
	movl	$.Lhrdbf_C49, %eax
	cmpl	$5, %edi
	ja	.Lhrdbf_1452
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.438(,%rdi,8), %rax
.Lhrdbf_1452:
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
	ja	.Lhrdbf_1458
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
	je	.Lhrdbf_1458
	movabs	$4503599627370495, %rcx
	andq	%rcx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbf_1553
	btsq	$52, %rax
	subl	$1075, %edx
	movl	$2, %edi
	movl	%eax, %ecx
	movslq	%edx, %r9
	shrq	$32, %rax
.Lhrdbf_1462:
	movl	%ecx, 224(%rsp)
	leaq	224(%rsp), %r14
	movl	%eax, 228(%rsp)
	movl	%edi, 512(%rsp)
	testl	%ebx, %ebx
	je	.Lhrdbf_1469
	xorl	%r10d, %r10d
	xorl	%r8d, %r8d
	leaq	224(%rsp), %r14
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1468:
	leal	-1(%rdi), %eax
	movq	%r14, %rdx
	leaq	228(%rsp,%rax,4), %rsi
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1470:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_1470
	testq	%rax, %rax
	je	.Lhrdbf_1471
	movl	%edi, %edx
	movl	$1, %r10d
	addl	$1, %edi
	movl	%eax, 224(%rsp,%rdx,4)
.Lhrdbf_1471:
	addl	$1, %r8d
	cmpl	%r8d, %ebx
	jne	.Lhrdbf_1468
	testb	%r10b, %r10b
	je	.Lhrdbf_1469
	movl	%edi, 512(%rsp)
.Lhrdbf_1469:
	movl	%ebx, %esi
	addq	%r9, %rsi
	js	.Lhrdbf_1474
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shl
	movl	512(%rsp), %r10d
.Lhrdbf_1475:
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_1481
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1482:
	cmpq	$48, %r12
	je	.Lhrdbf_1554
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_divmod_1e9
	movl	512(%rsp), %r10d
	movl	%eax, 32(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbf_1481:
	movl	%r12d, %r13d
	cmpl	$1, %r10d
	jne	.Lhrdbf_1482
	movl	224(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_1482
	testl	%r12d, %r12d
	jne	.Lhrdbf_1555
	movl	$0, 32(%rsp)
	movl	$48, %edx
	movb	$48, 22(%rsp)
.Lhrdbf_1487:
	leal	-1(%r10), %eax
	leaq	528(%rsp), %r14
	movq	%rax, %r11
	leaq	529(%rsp,%rax), %rcx
	leal	-1(%r10,%r14), %esi
	movq	%r14, %rax
	jmp	.Lhrdbf_1490
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1556:
	movl	%esi, %edx
	subl	%eax, %edx
	movzbl	22(%rsp,%rdx), %edx
.Lhrdbf_1490:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_1556
	testl	%r13d, %r13d
	je	.Lhrdbf_1491
	leaq	32(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1493:
	movl	%r11d, %edi
	movl	(%r12), %edx
	addl	$9, %r11d
	movl	%r11d, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1492:
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
	jne	.Lhrdbf_1492
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbf_1557
	movq	%rax, %r12
	jmp	.Lhrdbf_1493
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1458:
	xorl	%eax, %eax
.Lhrdbf_1455:
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
.Lhrdbf_1553:
	testq	%rax, %rax
	jne	.Lhrdbf_1558
	cmpq	$0, 8(%rsp)
	jne	.Lhrdbf_1559
	xorl	%edx, %edx
.Lhrdbf_1463:
	testl	%ebx, %ebx
	je	.Lhrdbf_1464
	leal	2(%rdx,%rbx), %esi
	cmpl	4(%rsp), %esi
	ja	.Lhrdbf_1458
	movl	%edx, %eax
	movb	$48, 0(%rbp,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, 0(%rbp,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1466:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 0(%rbp,%rcx)
	cmpl	%edx, %esi
	jne	.Lhrdbf_1466
	addl	%ebx, %eax
	jmp	.Lhrdbf_1455
.Lhrdbf_1559:
	movl	4(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbf_1458
	movb	$45, 0(%rbp)
	movl	$1, %edx
	jmp	.Lhrdbf_1463
.Lhrdbf_1474:
	negl	%esi
	movq	%r14, %rdi
	call .Lhrdbf_entry_hrdbf_local_bn_shr_round
	movl	512(%rsp), %r10d
	cmpl	$3, %eax
	je	.Lhrdbf_1560
	cmpl	$2, %eax
	jne	.Lhrdbf_1475
	movl	224(%rsp), %ecx
	movl	%ecx, %edx
	andl	$1, %edx
	je	.Lhrdbf_1475
	testl	%r10d, %r10d
	je	.Lhrdbf_1508
.Lhrdbf_1478:
	xorl	%edx, %edx
	movl	$1, %eax
	jmp	.Lhrdbf_1480
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1561:
	movl	(%r14,%rdx,4), %ecx
.Lhrdbf_1480:
	addq	%rcx, %rax
	movl	%eax, (%r14,%rdx,4)
	addq	$1, %rdx
	shrq	$32, %rax
	cmpl	%edx, %r10d
	ja	.Lhrdbf_1561
	testq	%rax, %rax
	je	.Lhrdbf_1475
	movl	%r10d, %eax
	addl	$1, %r10d
.Lhrdbf_1477:
	movl	%r10d, 512(%rsp)
	movl	$1, 224(%rsp,%rax,4)
	jmp	.Lhrdbf_1475
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1557:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %r10d
.Lhrdbf_1491:
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
	ja	.Lhrdbf_1458
	xorl	%edx, %edx
	testq	%rdi, %rdi
	je	.Lhrdbf_1496
	movb	$45, 0(%rbp)
	movl	$1, %edx
.Lhrdbf_1496:
	cmpl	%r10d, %ebx
	jnb	.Lhrdbf_1497
	testl	%eax, %eax
	je	.Lhrdbf_1513
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1499:
	movzbl	(%r14), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbf_1499
.Lhrdbf_1498:
	testl	%ebx, %ebx
	je	.Lhrdbf_1455
.Lhrdbf_1500:
	cmpl	%r10d, %ebx
	movl	%r10d, %edi
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %edi
	movb	$46, 0(%rbp,%rcx)
	subl	%edi, %ebx
	je	.Lhrdbf_1501
	leal	1(%rbx,%rax), %esi
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1502:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, 0(%rbp,%rcx)
	cmpl	%esi, %eax
	jne	.Lhrdbf_1502
	addl	%ebx, %edx
.Lhrdbf_1501:
	subl	%edi, %r10d
	leal	(%rdi,%rdx), %eax
	subl	%edx, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1503:
	leal	(%r10,%rdx), %esi
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	528(%rsp,%rsi), %esi
	movb	%sil, 0(%rbp,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbf_1503
	jmp	.Lhrdbf_1455
.Lhrdbf_1554:
	movl	220(%rsp), %ecx
	movl	$47, %r13d
.Lhrdbf_1485:
	movl	$1, %esi
	movl	$3435973837, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1488:
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
	ja	.Lhrdbf_1488
	jmp	.Lhrdbf_1487
.Lhrdbf_1558:
	movl	%eax, %ecx
	shrq	$32, %rax
	movl	$0, %edx
	movq	$-1074, %r9
	cmpq	$1, %rax
	sbbl	%edi, %edi
	addl	$2, %edi
	testq	%rax, %rax
	cmove	%edx, %eax
	jmp	.Lhrdbf_1462
.Lhrdbf_1464:
	leal	1(%rdx), %eax
	cmpl	4(%rsp), %eax
	ja	.Lhrdbf_1458
	movb	$48, 0(%rbp,%rdx)
	jmp	.Lhrdbf_1455
.Lhrdbf_1497:
	movb	$48, 0(%rbp,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbf_1500
.Lhrdbf_1560:
	testl	%r10d, %r10d
	je	.Lhrdbf_1507
	movl	224(%rsp), %ecx
	jmp	.Lhrdbf_1478
.Lhrdbf_1513:
	movl	%edx, %eax
	jmp	.Lhrdbf_1498
.Lhrdbf_1508:
	xorl	%eax, %eax
	movl	%edx, %r10d
	jmp	.Lhrdbf_1477
.Lhrdbf_1507:
	xorl	%eax, %eax
	movl	$1, %r10d
	jmp	.Lhrdbf_1477
.Lhrdbf_1555:
	leal	-1(%r12), %eax
	movl	32(%rsp,%rax,4), %ecx
	movq	%rax, %r13
	jmp	.Lhrdbf_1485
	.size	hrdbf_fmt_fixed, .-hrdbf_fmt_fixed
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.type	hrdbf_fmt_harbour, @function
hrdbf_fmt_harbour:
.Lhrdbf_entry_hrdbf_fmt_harbour:
	endbr64
	cmpl	$32, %edx
	ja	.Lhrdbf_1563
	jmp .Lhrdbf_entry_hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1563:
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
	jne	.Lhrdbf_1564
	movzwl	14(%rsi), %eax
	addq	%rax, %rdi
	movzbl	12(%rsi), %eax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	testq	%rcx, %rcx
	je	.Lhrdbf_1566
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1567:
	movzbl	(%rdx,%rax), %r8d
	movb	%r8b, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_1567
	movzbl	12(%rsi), %eax
.Lhrdbf_1566:
	cmpq	%rcx, %rax
	jbe	.Lhrdbf_1569
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1568:
	movb	$32, (%rdi,%rcx)
	movzbl	12(%rsi), %eax
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_1568
.Lhrdbf_1569:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1564:
	ret
	.size	hrdbf_write_char, .-hrdbf_write_char
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.type	hrdbf_write_number_scaled, @function
hrdbf_write_number_scaled:
.Lhrdbf_entry_hrdbf_write_number_scaled:
	endbr64
	cmpb	$78, 11(%rsi)
	jne	.Lhrdbf_1578
	jmp .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1578:
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
	jne	.Lhrdbf_1580
	jmp .Lhrdbf_entry_hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1580:
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
	jne	.Lhrdbf_1581
	movzwl	14(%rsi), %eax
	addq	%rdi, %rax
	testl	%edx, %edx
	je	.Lhrdbf_1596
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
	ja	.Lhrdbf_1581
	cmpl	$9999, %ecx
	jbe	.Lhrdbf_1581
	testl	%edi, %edi
	je	.Lhrdbf_1581
	leal	-2(%rdx), %ecx
	movl	$31, %r10d
	cmpl	$9, %ecx
	jbe	.Lhrdbf_1597
.Lhrdbf_1585:
	movl	$3518437209, %esi
	imulq	%r9, %rsi
	shrq	$45, %rsi
	cmpl	$2, %edx
	je	.Lhrdbf_1598
.Lhrdbf_1586:
	movl	$5, %r8d
	cmpl	%edi, %r10d
	jb	.Lhrdbf_1581
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
.Lhrdbf_1581:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1596:
	leaq	8(%rax), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1584:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1584
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_1581
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1597:
	movl	hrdbf_local_CSWTCH.447(,%rcx,4), %r10d
	jmp	.Lhrdbf_1585
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1598:
	testb	$3, %sil
	jne	.Lhrdbf_1586
	imull	$-1030792151, %esi, %ecx
	movl	%ecx, %r8d
	rorl	$2, %r8d
	cmpl	$42949672, %r8d
	ja	.Lhrdbf_1587
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbf_1586
.Lhrdbf_1587:
	addl	$1, %r10d
	jmp	.Lhrdbf_1586
	.size	hrdbf_write_date, .-hrdbf_write_date
	.p2align 4
	.globl	hrdbf_write_logical
	.type	hrdbf_write_logical, @function
hrdbf_write_logical:
.Lhrdbf_entry_hrdbf_write_logical:
	endbr64
	cmpb	$76, 11(%rsi)
	movl	$3, %eax
	jne	.Lhrdbf_1599
	cmpb	$1, %dl
	movzwl	14(%rsi), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rdi,%rdx)
	xorl	%eax, %eax
.Lhrdbf_1599:
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
	jbe	.Lhrdbf_1611
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbf_1610
.Lhrdbf_1611:
	movzbl	12(%rsi), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_1609
	leaq	(%rdi,%rdx), %rax
	subl	$1, %ecx
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1608:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1608
.Lhrdbf_1609:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1610:
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
	cmpb	$0, 32976(%rdi)
	movq	$0, (%rdi)
	movq	%rdi, %r8
	movq	$0, 8(%rdi)
	movl	$0, 16(%rdi)
	movq	$0, 24(%rdi)
	movl	$16842752, 36(%rdi)
	movb	$0, 40(%rdi)
	movl	$0, 32960(%rdi)
	je	.Lhrdbf_1622
	xorl	%edx, %edx
	movq	32968(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
	syscall
	movb	$0, 32976(%r8)
	movq	$0, 32968(%r8)
	testq	%rax, %rax
	js	.Lhrdbf_1628
.Lhrdbf_1622:
	xorl	%r9d, %r9d
.Lhrdbf_1621:
	movq	32944(%r8), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1619
	movq	32952(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1624
	movq	$0, 32944(%r8)
	movq	$0, 32952(%r8)
.Lhrdbf_1619:
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1628:
	movl	$7, %r9d
	jmp	.Lhrdbf_1621
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1624:
	movl	$7, %r9d
	movl	%r9d, %eax
	ret
	.size	hrdbf_file_close, .-hrdbf_file_close
	.section	.rodata
	.align 8
.Lhrdbf_C50:
	.string	"OS open failed (missing file, permission or sharing conflict)"
	.section	.rodata
.Lhrdbf_C51:
	.string	"OS seek failed"
.Lhrdbf_C52:
	.string	"file size "
.Lhrdbf_C53:
	.string	" exceeds the 1 GiB limit"
	.section	.rodata
	.align 8
.Lhrdbf_C54:
	.string	"out of memory snapshotting the file"
	.section	.rodata
.Lhrdbf_C55:
	.string	"OS read failed"
	.section	.rodata
	.align 8
.Lhrdbf_C56:
	.string	"file changed size while being read"
	.text
	.p2align 4
	.type	hrdbf_file_open.part.0, @function
hrdbf_file_open.part.0:
.Lhrdbf_entry_hrdbf_file_open.part.0:
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
.Lhrdbf_1630:
	movq	%r8, %rax
	syscall
	movq	%rax, %r12
	cmpq	$-4, %rax
	je	.Lhrdbf_1630
	testq	%rax, %rax
	js	.Lhrdbf_1668
	movl	$8, %r8d
	xorl	%ebx, %ebx
	movl	$2, %edx
	movq	%r12, %rdi
	movq	%r8, %rax
	movq	%rbx, %rsi
	syscall
	movl	$.Lhrdbf_C51, %esi
	movq	%rax, %r13
	movq	%rax, %rdx
	testq	%rax, %rax
	js	.Lhrdbf_1666
	cmpq	$32, %rax
	jle	.Lhrdbf_1669
	cmpq	$1073741824, %rax
	jg	.Lhrdbf_1670
	movq	%r8, %rax
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1671
	movq	%r13, 32952(%rbp)
	xorl	%r9d, %r9d
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movl	$34, %r10d
	movl	$9, %eax
	movl	$3, %edx
	movq	$-1, %r8
	syscall
	cmpq	$-4095, %rax
	jb	.Lhrdbf_1639
	movq	$0, 32944(%rbp)
.Lhrdbf_1640:
	movq	$0, 32952(%rbp)
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C54, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rdx, %rsi
	syscall
	movl	$8, %r10d
	testq	%rax, %rax
	js	.Lhrdbf_1667
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1634:
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r10d
.Lhrdbf_1629:
	addq	$24, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1674:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C55, %esi
.Lhrdbf_1666:
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
.Lhrdbf_1665:
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	movl	$7, %r10d
	jmp	.Lhrdbf_1634
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1639:
	movq	%rax, 32944(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_1640
	movq	32952(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%ebx, %ebx
	testq	%rdx, %rdx
	jne	.Lhrdbf_1641
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1642:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1645:
	movq	%r8, %rax
	movq	%r12, %rdi
	syscall
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_1645
	testq	%rax, %rax
	jne	.Lhrdbf_1672
	movq	32952(%rbp), %rdx
	movq	32944(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movl	%eax, %r10d
	testl	%eax, %eax
	jne	.Lhrdbf_1647
	movl	32960(%rbp), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_1673
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1629
	jmp	.Lhrdbf_1667
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1675:
	movq	32944(%rbp), %rsi
.Lhrdbf_1641:
	addq	%r8, %rsi
	subq	%r8, %rdx
	movq	%rbx, %rax
	movq	%r12, %rdi
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_1643
	testq	%rax, %rax
	jle	.Lhrdbf_1674
	addq	%rax, %r8
.Lhrdbf_1643:
	movq	32952(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_1675
	jmp	.Lhrdbf_1642
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1670:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C52, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movq	%r13, %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fdec
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C53, %esi
	call .Lhrdbf_entry_hrdbf_local_fcat
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	movl	$4, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_1634
	jmp	.Lhrdbf_1667
.Lhrdbf_1672:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C56, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%r8, %rsi
	movq	%r8, %rdx
	syscall
.Lhrdbf_1667:
	movl	$7, %r10d
	jmp	.Lhrdbf_1634
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1669:
	movq	%rbp, %rdi
	movl	$.Lhrdbf_C5, %esi
	call .Lhrdbf_entry_hrdbf_local_fset
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	movl	$1, %r10d
	testq	%rax, %rax
	jns	.Lhrdbf_1634
	jmp	.Lhrdbf_1667
.Lhrdbf_1668:
	movq	%rax, %rdx
	movl	$.Lhrdbf_C50, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_ferr
	movl	$7, %r10d
	jmp	.Lhrdbf_1629
.Lhrdbf_1671:
	movl	$.Lhrdbf_C51, %esi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_local_fset
	jmp	.Lhrdbf_1665
.Lhrdbf_1647:
	movl	$3, %eax
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	%rbx, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1634
	jmp	.Lhrdbf_1667
.Lhrdbf_1673:
	movq	%r12, 32968(%rbp)
	movb	$1, 32976(%rbp)
	jmp	.Lhrdbf_1629
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
	syscall
	.size	hrdbf_app_exit, .-hrdbf_app_exit
	.p2align 4
	.type	hrdbf_app_fail, @function
hrdbf_app_fail:
.Lhrdbf_entry_hrdbf_app_fail:
	xorl	%edx, %edx
	cmpb	$0, (%rdi)
	movq	%rdi, %rsi
	je	.Lhrdbf_1678
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1679:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_1679
.Lhrdbf_1678:
	movl	$1, %eax
	movl	$2, %edi
	syscall
	call .Lhrdbf_entry_hrdbf_app_exit
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.section	.rodata
	.align 8
.Lhrdbf_C57:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbf_C58:
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
	jne	.Lhrdbf_1696
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_1697
	cmpb	$78, %al
	je	.Lhrdbf_1698
	cmpb	$68, %al
	je	.Lhrdbf_1699
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1697:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_1700
.Lhrdbf_1685:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_1701
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1699:
	movl	24(%rsp), %edx
	addq	$288, %rsp
	movl	$11, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1698:
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
.Lhrdbf_1700:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_1688
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1687:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_1687
.Lhrdbf_1688:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_1685
.Lhrdbf_1696:
	movl	$.Lhrdbf_C57, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1701:
	movl	$.Lhrdbf_C58, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_ord.part.0, .-hrdbf_app_get_ord.part.0
	.section	.rodata
.Lhrdbf_C59:
	.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.section	.rodata
	.align 8
.Lhrdbf_C60:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbf_C61:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbf_C62:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,110,111,32,114,101,99,111,114,100,32,112,111,115,105,116,105,111,110,101,100,10,0
	.text
	.p2align 4
	.type	hrdbf_app_require_writable, @function
hrdbf_app_require_writable:
.Lhrdbf_entry_hrdbf_app_require_writable:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1707
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1708
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_1709
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbf_1710
	ret
.Lhrdbf_1707:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1710:
	movl	$.Lhrdbf_C62, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1709:
	movl	$.Lhrdbf_C61, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1708:
	movl	$.Lhrdbf_C60, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_require_writable, .-hrdbf_app_require_writable
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
.Lhrdbf_entry_hrdbf_file_open:
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
	jne	.Lhrdbf_1712
	movq	32944(%rdi), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1714
	movq	32952(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1711
.Lhrdbf_1720:
	movq	$0, 32944(%r8)
	movq	$0, 32952(%r8)
.Lhrdbf_1714:
	movl	%r9d, %edx
	movq	%r10, %rsi
	movq	%r8, %rdi
	jmp .Lhrdbf_entry_hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1712:
	xorl	%edx, %edx
	movq	32968(%rdi), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
	syscall
	movb	$0, 32976(%r8)
	movq	32944(%r8), %rdi
	movq	$0, 32968(%r8)
	testq	%rax, %rax
	js	.Lhrdbf_1724
	testq	%rdi, %rdi
	je	.Lhrdbf_1714
	movq	32952(%r8), %rsi
	movl	$11, %eax
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1720
.Lhrdbf_1711:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1724:
	testq	%rdi, %rdi
	je	.Lhrdbf_1711
	movq	32952(%r8), %rsi
	movl	$11, %eax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1711
	movq	$0, 32944(%r8)
	movl	$7, %eax
	movq	$0, 32952(%r8)
	ret
	.size	hrdbf_file_open, .-hrdbf_file_open
	.p2align 4
	.globl	hrdbf_file_write_record
	.type	hrdbf_file_write_record, @function
hrdbf_file_write_record:
.Lhrdbf_entry_hrdbf_file_write_record:
	endbr64
	movl	32960(%rdi), %edx
	movq	%rdi, %r8
	movl	$6, %eax
	testl	%edx, %edx
	je	.Lhrdbf_1725
	cmpb	$0, 32976(%rdi)
	je	.Lhrdbf_1725
	cmpb	$0, 40(%rdi)
	je	.Lhrdbf_1725
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_1725
	movl	16(%rdi), %edx
	cmpq	%rsi, %rdx
	jb	.Lhrdbf_1725
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
	je	.Lhrdbf_1729
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1727:
	movq	32968(%r8), %rdi
	movq	%r9, %rax
	syscall
	cmpq	$-4, %rax
	je	.Lhrdbf_1727
	testq	%rax, %rax
	jle	.Lhrdbf_1735
	cmpq	%rdx, %rax
	ja	.Lhrdbf_1735
	addq	%rax, %rsi
	addq	%rax, %r10
	subq	%rax, %rdx
	jne	.Lhrdbf_1727
.Lhrdbf_1729:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1735:
	movl	$7, %eax
.Lhrdbf_1725:
	ret
	.size	hrdbf_file_write_record, .-hrdbf_file_write_record
	.p2align 4
	.globl	hrdbf_file_append
	.type	hrdbf_file_append, @function
hrdbf_file_append:
.Lhrdbf_entry_hrdbf_file_append:
	endbr64
	movl	32960(%rdi), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1744
	cmpb	$0, 32976(%rdi)
	je	.Lhrdbf_1744
	cmpb	$0, 40(%rdi)
	je	.Lhrdbf_1744
	jmp .Lhrdbf_entry_hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1744:
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
	je	.Lhrdbf_1751
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1756:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl $1, %edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_1769
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1755
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1753:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1769
.Lhrdbf_1755:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.Lhrdbf_1753
	jnb	.Lhrdbf_1769
	leal	1(%rdi), %r10d
.Lhrdbf_1752:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_1756
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_1760
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.Lhrdbf_1759:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.Lhrdbf_1761
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1762
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1794:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1761
.Lhrdbf_1762:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.Lhrdbf_1794
.Lhrdbf_1760:
	testl	%ebp, %ebp
	je	.Lhrdbf_1750
	testl	%r12d, %r12d
	jne	.Lhrdbf_1795
	movl	%r10d, %r11d
.Lhrdbf_1750:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1769:
	movl	%edi, %r11d
	jmp	.Lhrdbf_1752
.Lhrdbf_1761:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.Lhrdbf_1750
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_1763
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1768:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl $1, %edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_1764
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_1767
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1765:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_1764
.Lhrdbf_1767:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.Lhrdbf_1765
	jb	.Lhrdbf_1764
	movl	%edi, %r11d
.Lhrdbf_1766:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_1768
.Lhrdbf_1763:
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
.Lhrdbf_1764:
	leal	1(%rdi), %r10d
	jmp	.Lhrdbf_1766
.Lhrdbf_1795:
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
.Lhrdbf_1751:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_1750
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.Lhrdbf_1759
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata
.Lhrdbf_C63:
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
	je	.Lhrdbf_1797
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	movl	$7, %r8d
	testq	%rax, %rax
	js	.Lhrdbf_1797
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_1797:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1798
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1809
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1798:
	cmpb	$0, hrdbf_app_state+32976(%rip)
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+32960(%rip)
	je	.Lhrdbf_1803
	xorl	%edx, %edx
	movq	hrdbf_app_state+32968(%rip), %rdi
	movl	$3, %eax
	movq	%rdx, %rsi
	syscall
	movb	$0, hrdbf_app_state+32976(%rip)
	movq	$0, hrdbf_app_state+32968(%rip)
	testq	%rax, %rax
	js	.Lhrdbf_1816
.Lhrdbf_1803:
	movq	hrdbf_app_state+32944(%rip), %rdi
	xorl	%r9d, %r9d
	testq	%rdi, %rdi
	je	.Lhrdbf_1801
.Lhrdbf_1800:
	movq	hrdbf_app_state+32952(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1804
	movq	$0, hrdbf_app_state+32944(%rip)
	orl	%r9d, %r8d
	movq	$0, hrdbf_app_state+32952(%rip)
.Lhrdbf_1801:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	testl	%r8d, %r8d
	jne	.Lhrdbf_1806
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1816:
	movq	hrdbf_app_state+32944(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1804
	movl	$7, %r9d
	jmp	.Lhrdbf_1800
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1809:
	movl	$7, %r8d
	jmp	.Lhrdbf_1798
.Lhrdbf_1804:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
.Lhrdbf_1806:
	movl	$.Lhrdbf_C63, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata
.Lhrdbf_C64:
	.string	"table format not supported"
	.section	.rodata
	.align 8
.Lhrdbf_C65:
	.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbf_C66:
	.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbf_C67:
	.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.section	.rodata
.Lhrdbf_C68:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.section	.rodata
	.align 8
.Lhrdbf_C69:
	.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,109,111,100,101,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.section	.rodata
.Lhrdbf_C70:
	.string	"hbc: DBF open rejected: "
.Lhrdbf_C71:
	.byte 10,0
	.text
	.p2align 4
	.globl	hrdbf_app_open
	.type	hrdbf_app_open, @function
hrdbf_app_open:
.Lhrdbf_entry_hrdbf_app_open:
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
	je	.Lhrdbf_1818
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_1892
.Lhrdbf_1818:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_1893
	xorl	%r9d, %r9d
	jmp	.Lhrdbf_1819
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1863:
	movq	%rbx, %r9
.Lhrdbf_1819:
	movzbl	(%r10,%r9), %eax
	testb	%al, %al
	je	.Lhrdbf_1894
	leaq	1(%r9), %rbx
	movb	%al, (%rsp,%r9)
	movq	%rsp, %r13
	cmpq	%rbx, %rsi
	jne	.Lhrdbf_1863
	movq	hrdbf_app_order+32(%rip), %r14
	movb	$0, (%rsp,%rbx)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r14, %r14
	je	.Lhrdbf_1895
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r14, %rdi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1896
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1827
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1828
.Lhrdbf_1829:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1827:
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%r12, %r12
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	cmpq	$2, %rbp
	ja	.Lhrdbf_1897
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1832:
	movzbl	(%r10,%rdx), %esi
	movq	%rdx, %rcx
	addq	$1, %rdx
	cmpb	$47, %sil
	cmove	%rdx, %rax
	cmpq	%rcx, %r9
	jne	.Lhrdbf_1832
	cmpq	%rbx, %rax
	jb	.Lhrdbf_1835
	jmp	.Lhrdbf_1898
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1864:
	movq	%rdx, %rax
.Lhrdbf_1835:
	cmpb	$46, (%r10,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rbx
	cmpq	%r9, %rax
	jne	.Lhrdbf_1864
	movq	%rbx, hrdbf_app_baselen(%rip)
	testq	%rbx, %rbx
	je	.Lhrdbf_1836
.Lhrdbf_1861:
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1838:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %ecx
	cmpb	$26, %sil
	cmovb	%ecx, %eax
	addq	$1, %rdx
	movb	%al, hrdbf_app_basename-1(%rdx)
	cmpq	%rbx, %rdx
	jb	.Lhrdbf_1838
.Lhrdbf_1836:
	movl	$hrdbf_app_state, %edi
	movb	$0, hrdbf_app_state+32977(%rip)
	call .Lhrdbf_entry_hrdbf_file_close
	testl	%eax, %eax
	jne	.Lhrdbf_1839
	movl	%ebp, %edx
	movq	%r13, %rsi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbf_1839
	testq	%r12, %r12
	je	.Lhrdbf_1817
	leaq	4(%rbx), %rax
	cmpq	$4095, %rax
	jbe	.Lhrdbf_1899
.Lhrdbf_1817:
	addq	$4096, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1896:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1828
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1828
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1828:
	movl	$.Lhrdbf_C68, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1895:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1827
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r14, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1829
	jmp	.Lhrdbf_1828
.Lhrdbf_1899:
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
.Lhrdbf_1849:
	movq	%r9, %rax
	movq	%r13, %rsi
	syscall
	movq	%rax, %r8
	cmpq	$-4, %rax
	je	.Lhrdbf_1849
	cmpq	$-2, %rax
	je	.Lhrdbf_1817
	cmpq	$-20, %rax
	je	.Lhrdbf_1817
	testq	%rax, %rax
	js	.Lhrdbf_1850
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%r8, %rdi
	movq	%rdx, %rsi
	syscall
.Lhrdbf_1850:
	cmpq	$1, %rbp
	je	.Lhrdbf_1900
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1852
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.Lhrdbf_1817
.Lhrdbf_1898:
	movq	%rbx, hrdbf_app_baselen(%rip)
	jmp	.Lhrdbf_1861
.Lhrdbf_1852:
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_1853
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r9, %rdi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1901
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1858
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1855
.Lhrdbf_1860:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1858:
	movl	$1, %esi
	movq	%r13, %rdi
	call .Lhrdbf_entry_hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.Lhrdbf_1855
.Lhrdbf_1856:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.Lhrdbf_1817
.Lhrdbf_1900:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.Lhrdbf_1817
.Lhrdbf_1853:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1858
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1860
.Lhrdbf_1855:
	movl	$3, %eax
	jmp	.Lhrdbf_1856
.Lhrdbf_1894:
	movl	$.Lhrdbf_C67, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1901:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1855
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1855
	movq	$0, hrdbf_app_order+40(%rip)
	movl	$3, %eax
	movq	$0, hrdbf_app_order+56(%rip)
	jmp	.Lhrdbf_1856
.Lhrdbf_1893:
	movl	$.Lhrdbf_C66, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1892:
	movl	$.Lhrdbf_C65, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1839:
	cmpb	$0, hrdbf_app_state+32977(%rip)
	movl	$hrdbf_app_state+32977, %r8d
	movl	$hrdbf_app_state+32778, %edx
	cmove	%rdx, %r8
	cmpb	$0, (%r8)
	jne	.Lhrdbf_1842
	subl	$2, %eax
	movl	$.Lhrdbf_C64, %r8d
	cmpl	$6, %eax
	ja	.Lhrdbf_1842
	movq	hrdbf_local_CSWTCH.478(,%rax,8), %r8
.Lhrdbf_1842:
	xorl	%edx, %edx
.Lhrdbf_1843:
	addq	$1, %rdx
	cmpb	$0, .Lhrdbf_C70(%rdx)
	jne	.Lhrdbf_1843
	movl	$1, %eax
	movl	$2, %edi
	movl	$.Lhrdbf_C70, %esi
	syscall
	xorl	%edx, %edx
	cmpb	$0, (%r8)
	je	.Lhrdbf_1844
.Lhrdbf_1845:
	addq	$1, %rdx
	cmpb	$0, (%r8,%rdx)
	jne	.Lhrdbf_1845
.Lhrdbf_1844:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r8, %rsi
	movq	%r9, %rax
	syscall
	movl	$.Lhrdbf_C71, %esi
	movq	%r9, %rax
	movq	%r9, %rdx
	syscall
	call .Lhrdbf_entry_hrdbf_app_exit
.Lhrdbf_1897:
	movl	$.Lhrdbf_C69, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1909
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1904
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbf_1905
.Lhrdbf_1904:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1905:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbf_1907
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.Lhrdbf_1908:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1907:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.Lhrdbf_1908
.Lhrdbf_1909:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
.Lhrdbf_entry_hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1919
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1912
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1912
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rdx
	testl	%esi, %esi
	jne	.Lhrdbf_1920
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.Lhrdbf_1916:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
.Lhrdbf_1917:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%edx, %edx
	sete	%dl
.Lhrdbf_1914:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%dl, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1920:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_1916
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
	jmp	.Lhrdbf_1917
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1912:
	movl	hrdbf_app_state+16(%rip), %edx
	movl	$1, %eax
	testl	%edx, %edx
	cmovne	%rdx, %rax
	sete	%dl
	movl	%edx, %ecx
	jmp	.Lhrdbf_1914
.Lhrdbf_1919:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	movq	%rdi, %rsi
	je	.Lhrdbf_1936
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_1923
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_1923
	testq	%rdi, %rdi
	je	.Lhrdbf_1921
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbf_1926
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.Lhrdbf_1932
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.Lhrdbf_1927:
	movq	%rsi, hrdbf_app_pos(%rip)
.Lhrdbf_1928:
	cmpq	%rax, %rsi
	jnb	.Lhrdbf_1930
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.Lhrdbf_1931:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbf_1921:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1923:
	movl	$hrdbf_app_state, %edi
	jmp .Lhrdbf_entry_hrdbf_skip
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1932:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.Lhrdbf_1927
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1930:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbf_1931
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1926:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.Lhrdbf_1929
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	jmp	.Lhrdbf_1928
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1929:
	addq	%rdx, %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbf_1928
.Lhrdbf_1936:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata
	.align 8
.Lhrdbf_C72:
	.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbf_C73:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbf_C74:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbf_C75:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbf_C76:
	.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,109,97,105,110,116,101,110,97,110,99,101,41,10,0
	.align 8
.Lhrdbf_C77:
	.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,112,114,101,115,101,110,116,32,98,117,116,32,110,111,116,32,97,100,109,105,116,116,101,100,32,40,111,110,101,32,116,97,103,44,32,115,117,98,115,101,116,44,32,115,105,122,101,32,111,114,32,102,111,114,109,97,116,41,10,0
	.align 8
.Lhrdbf_C78:
	.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbf_C79:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbf_C80:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
.Lhrdbf_entry_hrdbf_app_order_add:
	endbr64
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$8, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_1999
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.Lhrdbf_2000
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1939:
	movzbl	(%rdi,%rax), %ecx
	testb	%cl, %cl
	je	.Lhrdbf_2001
	movb	%cl, (%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %cl
	cmove	%rax, %rdx
	cmpq	%rsi, %rax
	jne	.Lhrdbf_1939
	movq	%rsi, %rax
	xorl	%ecx, %ecx
	cmpq	%rsi, %rdx
	jnb	.Lhrdbf_1942
	movl	$1, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1944:
	cmpb	$46, (%rdi,%rdx)
	cmove	%rdx, %rax
	cmove	%r8d, %ecx
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_1944
.Lhrdbf_1942:
	movl	hrdbf_app_cdx(%rip), %r9d
	testl	%r9d, %r9d
	jne	.Lhrdbf_2002
.Lhrdbf_1945:
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_2003
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_2004
	testl	%ecx, %ecx
	je	.Lhrdbf_2005
.Lhrdbf_1955:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, (%rsp,%rsi)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_1957
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r10, %rdi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_2006
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_1962
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1966
.Lhrdbf_1964:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1962:
	movl	%r9d, %esi
	movq	%rsp, %rdi
	call .Lhrdbf_entry_hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbf_2007
.Lhrdbf_1965:
	movl	$1, hrdbf_app_order_active(%rip)
	call .Lhrdbf_entry_hrdbf_app_top
	addq	$4104, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2002:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.Lhrdbf_1945
	testq	%rax, %rax
	je	.Lhrdbf_1946
	movl	$1, %r10d
	xorl	%r8d, %r8d
	xorl	%ebp, %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1949:
	movzbl	(%rdi,%r8), %edx
	leal	-97(%rdx), %ebx
	leal	-32(%rdx), %r11d
	cmpb	$26, %bl
	cmovb	%r11d, %edx
	cmpb	%dl, hrdbf_app_basename(%r8)
	cmovne	%ebp, %r10d
	addq	$1, %r8
	cmpq	%rax, %r8
	jne	.Lhrdbf_1949
	testl	%r10d, %r10d
	je	.Lhrdbf_1945
.Lhrdbf_1946:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.Lhrdbf_1965
	cmpl	$2, %eax
	je	.Lhrdbf_2008
	cmpl	$3, %eax
	je	.Lhrdbf_2009
	cmpl	$4, %eax
	jne	.Lhrdbf_1945
	movl	$.Lhrdbf_C78, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2005:
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
	jmp	.Lhrdbf_1955
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2006:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1966
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_1966
	movq	$0, hrdbf_app_order+40(%rip)
	movl	$.Lhrdbf_C73, %edi
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_1960:
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_1957:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_1962
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_1964
.Lhrdbf_1966:
	movl	$.Lhrdbf_C73, %edi
	jmp	.Lhrdbf_1960
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2001:
	movl	$.Lhrdbf_C75, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2000:
	movl	$.Lhrdbf_C74, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2007:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbf_1966
	cmpl	$3, %eax
	jne	.Lhrdbf_1966
	movl	$.Lhrdbf_C72, %edi
	jmp	.Lhrdbf_1960
.Lhrdbf_2003:
	movl	$.Lhrdbf_C79, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2009:
	movl	$.Lhrdbf_C77, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2008:
	movl	$.Lhrdbf_C76, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_1999:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2004:
	movl	$.Lhrdbf_C80, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
.Lhrdbf_entry_hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2024
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_2025
	movl	$11, %r8d
	movq	hrdbf_app_order+48(%rip), %rsi
	xorl	%edx, %edx
	movq	%r9, %rdi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_2015
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_2019
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_2018
.Lhrdbf_2020:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_2019:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2015:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_2018
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	js	.Lhrdbf_2018
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_2018:
	movl	$.Lhrdbf_C68, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2025:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_2019
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
	syscall
	testq	%rax, %rax
	jns	.Lhrdbf_2020
	jmp	.Lhrdbf_2018
.Lhrdbf_2024:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
.Lhrdbf_entry_hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2028
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbf_2028:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata
	.align 8
.Lhrdbf_C81:
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
	je	.Lhrdbf_2036
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_2031
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2031
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
	jb	.Lhrdbf_2037
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.Lhrdbf_2034:
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
.Lhrdbf_2037:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.Lhrdbf_2034
.Lhrdbf_2031:
	movl	$.Lhrdbf_C81, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2036:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.section	.rodata
	.align 8
.Lhrdbf_C82:
	.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,101,120,112,101,99,116,115,32,97,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,118,97,108,117,101,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_seek_dyn
	.type	hrdbf_app_seek_dyn, @function
hrdbf_app_seek_dyn:
.Lhrdbf_entry_hrdbf_app_seek_dyn:
	endbr64
	pushq	%r12
	subq	$304, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2076
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_2040
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2040
	movq	%rdi, %rax
	movq	%rdx, %r12
	movq	%rsi, %rdi
	movzbl	%al, %edx
	leal	-2(%rdx), %esi
	andl	$-3, %esi
	je	.Lhrdbf_2077
	testl	%edx, %edx
	je	.Lhrdbf_2055
	cmpl	$9, %edx
	je	.Lhrdbf_2055
	cmpl	$5, %edx
	je	.Lhrdbf_2078
	cmpl	$12, %edx
	je	.Lhrdbf_2079
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
.Lhrdbf_2077:
	testq	%rdi, %rdi
	je	.Lhrdbf_2080
	movq	-8(%rdi), %rsi
	addq	$304, %rsp
	movq	%r12, %rdx
	popq	%r12
	jmp .Lhrdbf_entry_hrdbf_app_seek
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2079:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rdi, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.Lhrdbf_2053
	movsd	.Lhrdbf_C0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2054:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.Lhrdbf_2054
.Lhrdbf_2053:
	comisd	.Lhrdbf_C83(%rip), %xmm0
	movabs	$9223372036854775807, %rdi
	ja	.Lhrdbf_2055
.Lhrdbf_2075:
	movsd	.Lhrdbf_C84(%rip), %xmm1
	addq	$1, %rdi
	comisd	%xmm0, %xmm1
	jbe	.Lhrdbf_2081
.Lhrdbf_2055:
	movzwl	hrdbf_app_order+28(%rip), %esi
	leaq	16(%rsp), %rdx
	movq	%rcx, 8(%rsp)
	call .Lhrdbf_entry_hrdbf_app_pad_ll
	movq	8(%rsp), %rcx
	movq	%r12, %rdx
	leaq	16(%rsp), %rdi
	movq	%rax, %rsi
	call .Lhrdbf_entry_hrdbf_app_seek
	addq	$304, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2078:
	testq	%rax, %rax
	js	.Lhrdbf_2082
.Lhrdbf_2048:
	movq	%rdi, %xmm0
	comisd	.Lhrdbf_C83(%rip), %xmm0
	movabs	$9223372036854775807, %rdi
	ja	.Lhrdbf_2055
	jmp	.Lhrdbf_2075
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2081:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.Lhrdbf_2083
	addsd	.Lhrdbf_C85(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.Lhrdbf_2055
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2082:
	movq	(%rdi), %rdi
	jmp	.Lhrdbf_2048
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2083:
	subsd	.Lhrdbf_C85(%rip), %xmm0
	cvttsd2siq	%xmm0, %rdi
	jmp	.Lhrdbf_2055
.Lhrdbf_2040:
	movl	$.Lhrdbf_C81, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2076:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2080:
	movl	$.Lhrdbf_C82, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek_dyn, .-hrdbf_app_seek_dyn
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2086
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_2086:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2089
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_2089:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_fcount
	.type	hrdbf_app_fcount, @function
hrdbf_app_fcount:
.Lhrdbf_entry_hrdbf_app_fcount:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2092
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.Lhrdbf_2092:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_fcount, .-hrdbf_app_fcount
	.p2align 4
	.globl	hrdbf_app_goto
	.type	hrdbf_app_goto, @function
hrdbf_app_goto:
.Lhrdbf_entry_hrdbf_app_goto:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2104
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %edx
	testq	%rdi, %rdi
	jle	.Lhrdbf_2095
	xorl	%eax, %eax
	cmpq	%rdx, %rdi
	ja	.Lhrdbf_2095
.Lhrdbf_2096:
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rdi, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	je	.Lhrdbf_2093
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbf_2105
.Lhrdbf_2093:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2095:
	leaq	1(%rdx), %rdi
	movl	$1, %eax
	jmp	.Lhrdbf_2096
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2105:
	movl	hrdbf_app_order+24(%rip), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbf_2102
	movq	hrdbf_app_order+16(%rip), %rsi
	xorl	%eax, %eax
	jmp	.Lhrdbf_2100
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2099:
	addq	$1, %rax
	cmpq	%rcx, %rax
	je	.Lhrdbf_2098
.Lhrdbf_2100:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.Lhrdbf_2099
.Lhrdbf_2098:
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.Lhrdbf_2102:
	xorl	%eax, %eax
	jmp	.Lhrdbf_2098
.Lhrdbf_2104:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_goto, .-hrdbf_app_goto
	.p2align 4
	.globl	hrdbf_app_ordselect
	.type	hrdbf_app_ordselect, @function
hrdbf_app_ordselect:
.Lhrdbf_entry_hrdbf_app_ordselect:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2121
	testq	%rdi, %rdi
	jle	.Lhrdbf_2108
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_2122
	cmpq	$1, %rdi
	jne	.Lhrdbf_2108
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %rdi
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %rsi
	testl	%ecx, %ecx
	jne	.Lhrdbf_2114
	jmp	.Lhrdbf_2123
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2113:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbf_2116
.Lhrdbf_2114:
	movl	(%rsi,%rax,8), %edx
	cmpq	%rdx, %rdi
	jne	.Lhrdbf_2113
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2122:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.Lhrdbf_2124
	cmpl	$3, %eax
	je	.Lhrdbf_2125
	cmpl	$4, %eax
	je	.Lhrdbf_2126
.Lhrdbf_2108:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.Lhrdbf_2123:
	xorl	%ecx, %ecx
.Lhrdbf_2116:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.Lhrdbf_2121:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2124:
	movl	$.Lhrdbf_C76, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2126:
	movl	$.Lhrdbf_C78, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2125:
	movl	$.Lhrdbf_C77, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_ordselect, .-hrdbf_app_ordselect
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2129
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_2129:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2132
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_2132:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2137
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_2133
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_2133:
	movq	%r8, %rax
	ret
.Lhrdbf_2137:
	movl	$.Lhrdbf_C59, %edi
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
	je	.Lhrdbf_2144
	testq	%rdi, %rdi
	jle	.Lhrdbf_2142
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdi
	jle	.Lhrdbf_2145
.Lhrdbf_2142:
	xorl	%edx, %edx
	movl	$1, %eax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2145:
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	addq	$8, %rsp
	ret
.Lhrdbf_2144:
	movl	$.Lhrdbf_C59, %edi
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
	je	.Lhrdbf_2147
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rdi, %r10
	movq	%rsi, %r9
	movq	%rbx, %rbp
	testl	%ebx, %ebx
	je	.Lhrdbf_2149
	movq	%rdx, %r12
	movl	$hrdbf_app_state+42, %esi
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2160:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2150:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_2151
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_2150
.Lhrdbf_2151:
	cmpq	%rax, %r9
	je	.Lhrdbf_2172
.Lhrdbf_2153:
	addl	$1, %r11d
	addq	$16, %rsi
	cmpl	%r11d, %ebx
	jne	.Lhrdbf_2160
.Lhrdbf_2149:
	movl	$1, %ebx
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbx, %rax
	syscall
	movq	%rbx, %rax
	movq	%r10, %rsi
	movq	%r9, %rdx
	syscall
	movl	$.Lhrdbf_C71, %esi
	movq	%rbx, %rax
	movq	%rbx, %rdx
	syscall
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
	syscall
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2172:
	testq	%r9, %r9
	je	.Lhrdbf_2154
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_2158
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2173:
	addq	$1, %rcx
	cmpq	%rcx, %r9
	je	.Lhrdbf_2154
.Lhrdbf_2158:
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
	je	.Lhrdbf_2173
	cmpq	%rcx, %r9
	jne	.Lhrdbf_2153
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2154:
	leal	1(%r11), %edi
	cmpq	%rbp, %rdi
	jle	.Lhrdbf_2174
	popq	%rbx
	xorl	%edx, %edx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_2174:
	movq	%r12, %rsi
	call .Lhrdbf_entry_hrdbf_app_get_ord.part.0
	popq	%rbx
	popq	%rbp
	popq	%r12
	ret
.Lhrdbf_2147:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get_name, .-hrdbf_app_get_name
	.section	.rodata
	.align 8
.Lhrdbf_C86:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbf_C87:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbf_C88:
	.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbf_C89:
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
	jle	.Lhrdbf_2176
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%r10, %rax
	jl	.Lhrdbf_2176
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
	addq	hrdbf_app_state+32944(%rip), %rax
	cmpb	$76, %dl
	je	.Lhrdbf_2178
	ja	.Lhrdbf_2179
	cmpb	$67, %dl
	je	.Lhrdbf_2180
	cmpb	$68, %dl
	jne	.Lhrdbf_2182
	cmpl	$11, %ecx
	je	.Lhrdbf_2237
	cmpl	$1, %ecx
	jne	.Lhrdbf_2182
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_2191
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_2202
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2238:
	addq	$1, %rdx
.Lhrdbf_2202:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_2238
.Lhrdbf_2187:
	movq	hrdbf_app_state+24(%rip), %rsi
.Lhrdbf_2191:
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbf_2239
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2179:
	cmpb	$78, %dl
	jne	.Lhrdbf_2182
	cmpl	$12, %ecx
	je	.Lhrdbf_2240
	testl	%ecx, %ecx
	je	.Lhrdbf_2210
	cmpl	$9, %ecx
	je	.Lhrdbf_2210
	cmpl	$5, %ecx
	je	.Lhrdbf_2241
	cmpl	$1, %ecx
	jne	.Lhrdbf_2182
	salq	$4, %rdi
	movzbl	hrdbf_app_state+54(%rdi), %ecx
	movzwl	hrdbf_app_state+56(%rdi), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_2191
	addq	%rax, %rdx
	subl	$1, %ecx
	leaq	1(%rdx), %rax
	addq	%rax, %rcx
	jmp	.Lhrdbf_2200
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2242:
	addq	$1, %rax
.Lhrdbf_2200:
	movb	$32, (%rdx)
	movq	%rax, %rdx
	cmpq	%rax, %rcx
	jne	.Lhrdbf_2242
	jmp	.Lhrdbf_2187
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2180:
	leal	-2(%rcx), %edx
	andl	$-3, %edx
	je	.Lhrdbf_2243
	cmpl	$1, %ecx
	jne	.Lhrdbf_2182
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_2191
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_2192
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2244:
	addq	$1, %rdx
.Lhrdbf_2192:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_2244
	jmp	.Lhrdbf_2187
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2178:
	cmpl	$3, %ecx
	je	.Lhrdbf_2245
	cmpl	$1, %ecx
	jne	.Lhrdbf_2182
	movzbl	22(%r10), %ecx
	movzwl	24(%r10), %edx
	testl	%ecx, %ecx
	je	.Lhrdbf_2191
	addq	%rdx, %rax
	subl	$1, %ecx
	leaq	1(%rax), %rdx
	addq	%rdx, %rcx
	jmp	.Lhrdbf_2205
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2246:
	addq	$1, %rdx
.Lhrdbf_2205:
	movb	$32, (%rax)
	movq	%rdx, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbf_2246
	jmp	.Lhrdbf_2187
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2245:
	cmpq	$1, %r12
	movzwl	24(%r10), %ecx
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rax,%rcx)
	movq	hrdbf_app_state+24(%rip), %rsi
	jmp	.Lhrdbf_2191
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2243:
	movzwl	24(%r10), %ecx
	movzbl	22(%r10), %edx
	addq	%rax, %rcx
	movq	-8(%r12), %rax
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rax, %rax
	je	.Lhrdbf_2185
	movq	%rcx, %rsi
	leaq	(%r12,%rax), %r8
	subq	%r12, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2186:
	movzbl	(%r12), %edx
	movb	%dl, (%rsi,%r12)
	addq	$1, %r12
	cmpq	%r8, %r12
	jne	.Lhrdbf_2186
	movq	%rdi, %rdx
	salq	$4, %rdx
	movzbl	hrdbf_app_state+54(%rdx), %edx
.Lhrdbf_2185:
	cmpq	%rdx, %rax
	jnb	.Lhrdbf_2187
	salq	$4, %rdi
	leaq	hrdbf_app_state+32(%rdi), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2188:
	movb	$32, (%rcx,%rax)
	movzbl	22(%rsi), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbf_2188
	jmp	.Lhrdbf_2187
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2237:
	movl	%r12d, %edx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_date
.Lhrdbf_2194:
	cmpl	$3, %eax
	je	.Lhrdbf_2182
	testl	%eax, %eax
	je	.Lhrdbf_2187
	movl	$.Lhrdbf_C88, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2240:
	movzbl	%bh, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbf_2194
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2210:
	xorl	%ecx, %ecx
	movq	%r12, %rdx
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbf_2194
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2241:
	testq	%rbx, %rbx
	jns	.Lhrdbf_2198
	movq	(%r12), %r12
.Lhrdbf_2198:
	movq	%r12, %xmm0
	movq	%r8, %rsi
	movq	%rax, %rdi
	call .Lhrdbf_entry_hrdbf_write_number_double.part.0
	jmp	.Lhrdbf_2194
.Lhrdbf_2182:
	movl	$.Lhrdbf_C87, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2176:
	movl	$.Lhrdbf_C86, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2239:
	movl	$.Lhrdbf_C89, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_fieldput, .-hrdbf_app_fieldput
	.section	.rodata
	.align 8
.Lhrdbf_C90:
	.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,47,114,101,99,97,108,108,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbf_C91:
	.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,47,114,101,99,97,108,108,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbf_C92:
	.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_delete
	.type	hrdbf_app_delete, @function
hrdbf_app_delete:
.Lhrdbf_entry_hrdbf_app_delete:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2255
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2256
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_2257
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbf_2258
.Lhrdbf_2247:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2258:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	movl	$hrdbf_app_state, %edi
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$42, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rsi
	call .Lhrdbf_entry_hrdbf_file_write_record
	testl	%eax, %eax
	je	.Lhrdbf_2247
	movl	$.Lhrdbf_C92, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2257:
	movl	$.Lhrdbf_C91, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2256:
	movl	$.Lhrdbf_C90, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2255:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_delete, .-hrdbf_app_delete
	.section	.rodata
	.align 8
.Lhrdbf_C93:
	.byte 104,98,99,58,32,68,66,70,32,114,101,99,97,108,108,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_recall
	.type	hrdbf_app_recall, @function
hrdbf_app_recall:
.Lhrdbf_entry_hrdbf_app_recall:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_2267
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2268
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_2269
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbf_2270
.Lhrdbf_2259:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2270:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	movl	$hrdbf_app_state, %edi
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$32, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rsi
	call .Lhrdbf_entry_hrdbf_file_write_record
	testl	%eax, %eax
	je	.Lhrdbf_2259
	movl	$.Lhrdbf_C93, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2269:
	movl	$.Lhrdbf_C91, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2268:
	movl	$.Lhrdbf_C90, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2267:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recall, .-hrdbf_app_recall
	.p2align 4
	.globl	hrdbf_app_commit
	.type	hrdbf_app_commit, @function
hrdbf_app_commit:
.Lhrdbf_entry_hrdbf_app_commit:
	endbr64
	ret
	.size	hrdbf_app_commit, .-hrdbf_app_commit
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
	je	.Lhrdbf_2273
	movl	$hrdbf_app_state+42, %esi
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2283:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2274:
	cmpb	$0, (%rsi,%rax)
	je	.Lhrdbf_2275
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbf_2274
.Lhrdbf_2275:
	cmpq	%rax, %r10
	je	.Lhrdbf_2296
.Lhrdbf_2277:
	addl	$1, %r9d
	addq	$16, %rsi
	cmpl	%r9d, %r11d
	jne	.Lhrdbf_2283
.Lhrdbf_2273:
	movl	$1, %ebp
	movl	$2, %edi
	movl	$hrdbf_app_pre_field, %esi
	movl	$43, %edx
	movq	%rbp, %rax
	syscall
	movq	%rbp, %rax
	movq	%rbx, %rsi
	movq	%r10, %rdx
	syscall
	movl	$.Lhrdbf_C71, %esi
	movq	%rbp, %rax
	movq	%rbp, %rdx
	syscall
	call .Lhrdbf_entry_hrntx_file_close.constprop.0
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%rbp, %rdi
	movq	%rdx, %rsi
	syscall
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2296:
	testq	%r10, %r10
	je	.Lhrdbf_2278
	xorl	%ecx, %ecx
	jmp	.Lhrdbf_2282
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2297:
	addq	$1, %rcx
	cmpq	%rcx, %r10
	je	.Lhrdbf_2278
.Lhrdbf_2282:
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
	je	.Lhrdbf_2297
	cmpq	%rcx, %r10
	jne	.Lhrdbf_2277
.Lhrdbf_2278:
	popq	%rbx
	movq	%r12, %rdx
	leal	1(%r9), %edi
	movq	%rbp, %rsi
	popq	%rbp
	popq	%r12
	jmp .Lhrdbf_entry_hrdbf_app_fieldput
	.size	hrdbf_app_set_name, .-hrdbf_app_set_name
	.section	.rodata
.Lhrdbf_C94:
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
	je	.Lhrdbf_2306
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbf_2307
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_2308
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbf_2309
	cmpb	$0, hrdbf_app_state+32976(%rip)
	je	.Lhrdbf_2304
	leaq	12(%rsp), %rsi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbf_2304
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	12(%rsp), %eax
	addq	$24, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2304:
	movl	$.Lhrdbf_C94, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2306:
	movl	$.Lhrdbf_C59, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2309:
	movl	$.Lhrdbf_C62, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2308:
	movl	$.Lhrdbf_C61, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2307:
	movl	$.Lhrdbf_C60, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_append, .-hrdbf_app_append
	.section	.rodata
	.align 8
.Lhrdbf_C95:
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
	jne	.Lhrdbf_2313
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_2313:
	movl	$.Lhrdbf_C95, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata
	.align 8
.Lhrdbf_C96:
	.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbf_C97:
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
	jne	.Lhrdbf_2315
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_2331
	testl	%eax, %eax
	je	.Lhrdbf_2323
	cmpl	$9, %eax
	jne	.Lhrdbf_2319
.Lhrdbf_2323:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2331:
	testl	$65280, %r9d
	je	.Lhrdbf_2323
.Lhrdbf_2318:
	movl	$.Lhrdbf_C96, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2315:
	cmpl	$2, %eax
	je	.Lhrdbf_2318
.Lhrdbf_2319:
	movl	$.Lhrdbf_C97, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata
	.align 8
.Lhrdbf_C98:
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
	testl	%eax, %eax
	jne	.Lhrdbf_2335
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_2335:
	movl	$.Lhrdbf_C98, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata
	.align 8
.Lhrdbf_C99:
	.byte 104,98,99,58,32,68,66,70,32,105,110,118,97,108,105,100,32,68,97,116,101,32,99,111,109,112,97,114,105,115,111,110,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_compare
	.type	hrdbf_app_compare, @function
hrdbf_app_compare:
.Lhrdbf_entry_hrdbf_app_compare:
	endbr64
	subq	$40, %rsp
	movq	%rsi, %r9
	cmpb	$11, %dil
	jne	.Lhrdbf_2337
	cmpb	$11, %dl
	je	.Lhrdbf_2344
.Lhrdbf_2337:
	leaq	24(%rsp), %r8
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_compare
	testl	%eax, %eax
	jne	.Lhrdbf_2345
	movq	24(%rsp), %rax
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2344:
	movq	%rcx, 8(%rsp)
	movq	%rdx, (%rsp)
	call .Lhrdbf_entry_hrv_validate
	movq	(%rsp), %rdx
	movq	8(%rsp), %rcx
	testl	%eax, %eax
	jne	.Lhrdbf_2339
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	%rcx, (%rsp)
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2339
	movq	(%rsp), %rcx
	xorl	%eax, %eax
	movq	$-1, %rdx
	cmpq	%rcx, %r9
	seta	%al
	cmovb	%rdx, %rax
	addq	$40, %rsp
	ret
.Lhrdbf_2345:
	movl	$.Lhrdbf_C98, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2339:
	movl	$.Lhrdbf_C99, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata
	.align 8
.Lhrdbf_C100:
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
	jne	.Lhrdbf_2347
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_2357
	movabs	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_2349
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2369:
	btq	%rax, %rcx
	jc	.Lhrdbf_2361
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_2357
.Lhrdbf_2349:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_2369
.Lhrdbf_2361:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2347:
	cmpl	$8, %r10d
	je	.Lhrdbf_2370
	cmpl	$5, %r10d
	je	.Lhrdbf_2371
	cmpl	$7, %r10d
	je	.Lhrdbf_2361
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_2354
	cmpl	$12, %r10d
	ja	.Lhrdbf_2354
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_2355
	cmpl	$1, %r10d
	je	.Lhrdbf_2362
.Lhrdbf_2354:
	movl	$.Lhrdbf_C100, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2357:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2370:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_2366
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_2366:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_2371:
	testq	%rdi, %rdi
	js	.Lhrdbf_2372
.Lhrdbf_2353:
	movq	%r9, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C47(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_2372:
	movq	(%rsi), %r9
	jmp	.Lhrdbf_2353
.Lhrdbf_2355:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_2346:
	addq	$8, %rsp
	ret
.Lhrdbf_2362:
	movl	$1, %eax
	jmp	.Lhrdbf_2346
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata
	.align 8
.Lhrdbf_C101:
	.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10,0
	.align 8
.Lhrdbf_C102:
	.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,111,110,32,97,32,78,73,76,32,111,114,32,110,111,110,45,110,117,109,101,114,105,99,32,111,112,101,114,97,110,100,10,0
	.section	.rodata
.Lhrdbf_C103:
	.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,114,101,106,101,99,116,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_arith
	.type	hrdbf_app_arith, @function
hrdbf_app_arith:
.Lhrdbf_entry_hrdbf_app_arith:
	endbr64
	subq	$24, %rsp
	movq	%rsp, %r9
	call .Lhrdbf_entry_hrv_arith
	cmpl	$5, %eax
	je	.Lhrdbf_2378
	cmpl	$1, %eax
	je	.Lhrdbf_2379
	testl	%eax, %eax
	jne	.Lhrdbf_2380
	movq	(%rsp), %rax
	movq	8(%rsp), %rdx
	addq	$24, %rsp
	ret
.Lhrdbf_2378:
	movl	$.Lhrdbf_C101, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2380:
	movl	$.Lhrdbf_C103, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_2379:
	movl	$.Lhrdbf_C102, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_arith, .-hrdbf_app_arith
	.section	.rodata
	.align 8
.Lhrdbf_C104:
	.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C104, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata
	.align 8
.Lhrdbf_C105:
	.string	"unsupported table version or header flags"
	.section	.rodata
.Lhrdbf_C106:
	.string	"unsupported field type"
	.section	.rodata
	.align 8
.Lhrdbf_C107:
	.string	"size or field-count limit exceeded"
	.section	.rodata
.Lhrdbf_C108:
	.string	"record content invalid"
.Lhrdbf_C109:
	.string	"I/O error"
.Lhrdbf_C110:
	.string	"out of memory"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.478, @object
	.size	hrdbf_local_CSWTCH.478, 56
hrdbf_local_CSWTCH.478:
.Lhrdbf_entry_hrdbf_local_CSWTCH.478:
	.quad	.Lhrdbf_C105
	.quad	.Lhrdbf_C106
	.quad	.Lhrdbf_C107
	.quad	.Lhrdbf_C108
	.quad	.Lhrdbf_C64
	.quad	.Lhrdbf_C109
	.quad	.Lhrdbf_C110
	.align 32
	.type	hrdbf_local_CSWTCH.447, @object
	.size	hrdbf_local_CSWTCH.447, 40
hrdbf_local_CSWTCH.447:
.Lhrdbf_entry_hrdbf_local_CSWTCH.447:
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
.Lhrdbf_C111:
	.string	"ok"
	.section	.rodata
	.align 8
.Lhrdbf_C112:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C113:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C114:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C115:
	.string	"DBF value tag or metadata invalid"
	.align 8
.Lhrdbf_C116:
	.string	"DBF arithmetic division by zero"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.438, @object
	.size	hrdbf_local_CSWTCH.438, 48
hrdbf_local_CSWTCH.438:
.Lhrdbf_entry_hrdbf_local_CSWTCH.438:
	.quad	.Lhrdbf_C111
	.quad	.Lhrdbf_C112
	.quad	.Lhrdbf_C113
	.quad	.Lhrdbf_C114
	.quad	.Lhrdbf_C115
	.quad	.Lhrdbf_C116
	.align 8
	.type	hrdbf_local_CSWTCH.411, @object
	.size	hrdbf_local_CSWTCH.411, 13
hrdbf_local_CSWTCH.411:
.Lhrdbf_entry_hrdbf_local_CSWTCH.411:
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
.balign 4
hrdbf_app_shared:
.Lhrdbf_entry_hrdbf_app_shared:
.zero 4
.text

.bss
.balign 4
hrdbf_app_struct:
.Lhrdbf_entry_hrdbf_app_struct:
.zero 4
.text

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
hrdbf_app_order_active:
.Lhrdbf_entry_hrdbf_app_order_active:
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
.zero 33144
.text

.bss
.balign 32
hrdbf_open_tmp:
.Lhrdbf_entry_hrdbf_open_tmp:
.zero 32944
.text
	.section	.rodata
	.align 8
.Lhrdbf_C0:
	.long	0
	.long	1076101120
	.align 8
.Lhrdbf_C47:
	.long	0
	.long	0
	.align 8
.Lhrdbf_C83:
	.long	-798530048
	.long	1138748221
	.align 8
.Lhrdbf_C84:
	.long	-798530048
	.long	-1008735427
	.align 8
.Lhrdbf_C85:
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
