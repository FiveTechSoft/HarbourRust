	.text
	.p2align 4
hrdbfw_local_dset:
	leaq	2090(%rcx), %rax
	leaq	2249(%rcx), %r8
	jmp	.Lhrdbfw_2
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_4:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_3
.Lhrdbfw_2:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_4
.Lhrdbfw_3:
	movb	$0, (%rax)
	ret
	.p2align 4
hrdbfw_local_dcat:
	leaq	2090(%rcx), %rax
	addq	$2249, %rcx
	jmp	.Lhrdbfw_7
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_9:
	addq	$1, %rax
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_8
.Lhrdbfw_7:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_9
	jmp	.Lhrdbfw_13
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_11:
	movb	%r8b, (%rax)
	addq	$1, %rdx
	addq	$1, %rax
.Lhrdbfw_13:
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_8
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_11
.Lhrdbfw_8:
	movb	$0, (%rax)
	ret
	.p2align 4
hrdbfw_local_bn_shl:
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	%edx, %ebx
	movl	288(%rcx), %r12d
	shrl	$5, %ebx
	leal	(%r12,%rbx), %r10d
	cmpl	$71, %r10d
	ja	.Lhrdbfw_14
	movl	%edx, %ebp
	movq	%rcx, %r8
	movl	%edx, %r11d
	andl	$31, %ebp
	je	.Lhrdbfw_17
	testl	%r12d, %r12d
	je	.Lhrdbfw_18
	movl	$32, %esi
	leal	-1(%r12), %edx
	movq	%rcx, %rax
	xorl	%r10d, %r10d
	subl	%ebp, %esi
	leaq	4(%rcx,%rdx,4), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_19:
	movl	(%rax), %r9d
	movl	%ebp, %ecx
	addq	$4, %rax
	movl	%r9d, %edx
	sall	%cl, %edx
	movl	%esi, %ecx
	orl	%r10d, %edx
	movl	%r9d, %r10d
	movl	%edx, -4(%rax)
	shrl	%cl, %r10d
	cmpq	%rdi, %rax
	jne	.Lhrdbfw_19
	testl	%r10d, %r10d
	je	.Lhrdbfw_23
	leal	1(%r12), %eax
	movl	%r12d, %r12d
	movl	%eax, 288(%r8)
	movl	%r10d, (%r8,%r12,4)
.Lhrdbfw_23:
	cmpl	$31, %r11d
	jbe	.Lhrdbfw_14
	movl	288(%r8), %r10d
	leal	-1(%r10), %edx
	addl	%ebx, %r10d
	jmp	.Lhrdbfw_28
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_17:
	cmpl	$31, %edx
	jbe	.Lhrdbfw_14
	leal	-1(%r12), %edx
	testl	%r12d, %r12d
	je	.Lhrdbfw_21
.Lhrdbfw_28:
	movl	%edx, %eax
	addl	%ebx, %edx
	leaq	(%r8,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_24:
	movl	(%rax), %r9d
	movl	%edx, %ecx
	subl	$1, %edx
	movl	%r9d, (%r8,%rcx,4)
	movq	%rax, %rcx
	subq	$4, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_24
.Lhrdbfw_21:
	testl	%ebx, %ebx
	je	.Lhrdbfw_27
	leal	-1(%rbx), %edx
	movq	%r8, %rax
	leaq	4(%r8,%rdx,4), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_26:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_26
.Lhrdbfw_27:
	movl	%r10d, 288(%r8)
.Lhrdbfw_14:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_18:
	cmpl	$31, %edx
	jbe	.Lhrdbfw_14
	movl	%ebx, %r10d
	jmp	.Lhrdbfw_21
	.p2align 4
hrdbfw_local_bn_divmod_1e9:
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %edi
	testl	%edi, %edi
	je	.Lhrdbfw_47
	leal	-1(%rdi), %r9d
	movq	%rcx, %r11
	xorl	%r8d, %r8d
	movabs	$19342813113834067, %rsi
	movl	%r9d, %eax
	leaq	(%rcx,%rax,4), %r10
	movq	%r10, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_44:
	movq	%r8, %rax
	movl	(%rcx), %r8d
	movq	%rcx, %rbx
	subq	$4, %rcx
	salq	$32, %rax
	orq	%rax, %r8
	movq	%r8, %rdx
	shrq	$9, %rdx
	movq	%rdx, %rax
	mulq	%rsi
	shrq	$11, %rdx
	movl	%edx, 4(%rcx)
	imulq	$1000000000, %rdx, %rdx
	subq	%rdx, %r8
	cmpq	%r11, %rbx
	jne	.Lhrdbfw_44
	movl	%r8d, %eax
	cmpl	$1, %edi
	jne	.Lhrdbfw_45
	jmp	.Lhrdbfw_42
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_46:
	movl	%r9d, 288(%r11)
	subq	$4, %r10
	subl	$1, %r9d
	je	.Lhrdbfw_42
.Lhrdbfw_45:
	movl	(%r10), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_46
.Lhrdbfw_42:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_47:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4
hrdbfw_device_eq:
	testq	%rdx, %rdx
	je	.Lhrdbfw_68
	pushq	%rbx
	movq	%rdx, %r11
	movq	%rcx, %rbx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_55
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_60:
	movzwl	(%rbx,%rcx,2), %eax
	leal	-97(%rax), %r10d
	leal	-32(%rax), %r9d
	cmpl	$26, %r10d
	cmovb	%r9d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_62
	addq	$1, %rcx
	cmpq	%rcx, %r11
	je	.Lhrdbfw_59
.Lhrdbfw_55:
	movzbl	(%r8,%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_60
.Lhrdbfw_62:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_59:
	addq	%r11, %r8
	xorl	%eax, %eax
	popq	%rbx
	cmpb	$0, (%r8)
	sete	%al
	ret
.Lhrdbfw_68:
	xorl	%eax, %eax
	cmpb	$0, (%r8)
	sete	%al
	ret
	.p2align 4
hrdbfw_local_fset:
	leaq	hrdbfw_local_fsink(%rip), %r9
	movq	%r9, %rax
	leaq	159(%r9), %r8
	jmp	.Lhrdbfw_70
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_72:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_71
.Lhrdbfw_70:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_72
.Lhrdbfw_71:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	ret
	.p2align 4
hrdbfw_local_fcat:
	movl	hrdbfw_local_fsink_len(%rip), %eax
	leaq	hrdbfw_local_fsink(%rip), %r9
	leaq	159(%r9), %r8
	addq	%r9, %rax
	cmpq	%r8, %rax
	jb	.Lhrdbfw_74
	jmp	.Lhrdbfw_75
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_76:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_75
.Lhrdbfw_74:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_76
.Lhrdbfw_75:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	ret
	.p2align 4
hrdbfw_local_nxvisit:
	cmpl	$63, %r8d
	ja	.Lhrdbfw_121
	movl	%edx, %r9d
	testl	%edx, %edx
	je	.Lhrdbfw_121
	testl	$1023, %edx
	jne	.Lhrdbfw_121
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
	ja	.Lhrdbfw_82
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
	jne	.Lhrdbfw_82
	movq	(%r10), %r14
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movzwl	32(%rbx), %eax
	addq	%r14, %rdi
	movzwl	(%rdi), %r13d
	cmpw	%ax, %r13w
	ja	.Lhrdbfw_82
	testw	%r13w, %r13w
	jne	.Lhrdbfw_106
	testl	%r8d, %r8d
	je	.Lhrdbfw_106
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_82:
	movl	$1, %eax
.Lhrdbfw_78:
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
.Lhrdbfw_121:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_106:
	leal	4(%rax,%rax), %eax
	xorl	%r12d, %r12d
	leaq	4(%rdi), %r15
	movl	%eax, 40(%rsp)
.Lhrdbfw_87:
	movzwl	%r12w, %eax
	movzwl	2(%rdi,%rax,2), %r11d
	movq	%r11, %rax
	cmpl	40(%rsp), %r11d
	jl	.Lhrdbfw_82
	movzwl	34(%rbx), %edx
	addq	%rdx, %rax
	movq	%rdx, %r10
	cmpq	$1024, %rax
	ja	.Lhrdbfw_82
	testw	%r12w, %r12w
	je	.Lhrdbfw_84
	leal	-1(%r12), %edx
	leaq	2(%rdi), %rax
	movzwl	%dx, %edx
	leal	(%r11,%r10), %ebp
	leaq	(%r15,%rdx,2), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_86:
	movzwl	(%rax), %edx
	leal	(%rdx,%r10), %ecx
	cmpl	%ecx, %r11d
	jge	.Lhrdbfw_85
	cmpl	%ebp, %edx
	jl	.Lhrdbfw_82
.Lhrdbfw_85:
	addq	$2, %rax
	cmpq	%rsi, %rax
	jne	.Lhrdbfw_86
.Lhrdbfw_84:
	addl	$1, %r12d
	cmpw	%r12w, %r13w
	jnb	.Lhrdbfw_87
	movzwl	2(%rdi), %eax
	movl	(%rdi,%rax), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_88
	movl	40(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_125
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_82
.Lhrdbfw_88:
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
.Lhrdbfw_102:
	movzwl	2(%rsi), %r13d
	movl	(%rdi,%r13), %edx
	movq	%r13, %r12
	testl	%edx, %edx
	setne	%al
	cmpb	55(%rsp), %al
	jne	.Lhrdbfw_82
	testl	%ebp, %ebp
	jne	.Lhrdbfw_90
.Lhrdbfw_93:
	cmpq	%rsi, 40(%rsp)
	je	.Lhrdbfw_91
	movl	4(%rdi,%r13), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_95
	movq	8(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_95
	cmpl	36(%rbx), %eax
	jbe	.Lhrdbfw_95
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
	jne	.Lhrdbfw_95
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
	je	.Lhrdbfw_96
	xorl	%ecx, %ecx
	leaq	(%r14,%r11), %r9
	addq	%r13, %r8
	jmp	.Lhrdbfw_97
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_127:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_126
.Lhrdbfw_97:
	movzbl	(%r8,%rcx), %r13d
	cmpb	%r13b, (%r9,%rcx)
	je	.Lhrdbfw_127
.Lhrdbfw_95:
	movl	$4, %eax
	jmp	.Lhrdbfw_78
.Lhrdbfw_90:
	movl	64(%rsp), %r8d
	movq	%rbx, %rcx
	call	hrdbfw_local_nxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_93
	jmp	.Lhrdbfw_78
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_126:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_105
.Lhrdbfw_124:
	movq	16(%r10), %r9
.Lhrdbfw_100:
	movl	%ecx, %r8d
	addl	$1, %ecx
	addq	$2, %rsi
	leaq	(%r9,%r8,8), %r8
	movl	%edx, (%r8)
	movl	%eax, 4(%r8)
	movl	%ecx, 36(%rbx)
	cmpq	%rsi, 56(%rsp)
	jne	.Lhrdbfw_102
.Lhrdbfw_91:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_78
.Lhrdbfw_125:
	movl	%r8d, 40(%rbx)
	jmp	.Lhrdbfw_88
.Lhrdbfw_105:
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	addq	%r14, %r12
	leaq	(%r9,%r8,8), %r8
	movl	4(%r8), %r10d
	movl	(%r8), %r13d
	addq	%r10, %r12
	leaq	(%r14,%r10), %r8
	movq	%r12, 72(%rsp)
	jmp	.Lhrdbfw_101
.Lhrdbfw_99:
	addq	$1, %r8
	cmpq	72(%rsp), %r8
	je	.Lhrdbfw_103
.Lhrdbfw_101:
	movq	%r8, %r12
	subq	%r10, %r12
	movzbl	(%r12,%r11), %r12d
	cmpb	%r12b, (%r8)
	je	.Lhrdbfw_99
	jb	.Lhrdbfw_100
	jmp	.Lhrdbfw_82
.Lhrdbfw_96:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_124
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	movl	(%r9,%r8,8), %r13d
.Lhrdbfw_103:
	cmpl	%r13d, %edx
	ja	.Lhrdbfw_100
	jmp	.Lhrdbfw_82
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
	ja	.Lhrdbfw_149
	testq	%rdx, %rdx
	je	.Lhrdbfw_149
	testl	$1023, %r8d
	jne	.Lhrdbfw_150
	testq	%r9, %r9
	je	.Lhrdbfw_150
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_192
	cmpw	$6, (%rdx)
	movl	$2, %eax
	jne	.Lhrdbfw_192
	cmpw	$0, 16(%rdx)
	jne	.Lhrdbfw_192
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
	jmp	.Lhrdbfw_131
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_130:
	addq	$1, %rax
	cmpq	$486, %rax
	je	.Lhrdbfw_195
.Lhrdbfw_131:
	cmpq	$11, %rax
	jbe	.Lhrdbfw_130
	cmpb	$0, 538(%rdx,%rax)
	je	.Lhrdbfw_130
.Lhrdbfw_164:
	movl	$2, %eax
.Lhrdbfw_128:
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
.Lhrdbfw_149:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_192:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_150:
	ret
.Lhrdbfw_195:
	movzwl	14(%rdx), %r13d
	movl	$1, %eax
	leal	-1(%r13), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbfw_128
	leal	8(%r13), %r14d
	cmpw	%r14w, 12(%rdx)
	jne	.Lhrdbfw_128
	movzwl	18(%rdx), %r15d
	leal	-1(%r15), %ecx
	cmpw	$509, %cx
	ja	.Lhrdbfw_128
	movl	%r15d, %ecx
	shrw $1, %cx
	cmpw	20(%rdx), %cx
	jne	.Lhrdbfw_128
	leal	1(%r15), %ecx
	movzwl	%r14w, %r11d
	xorl	%edi, %edi
	movzwl	%cx, %r10d
	addq	%rcx, %rcx
	imulq	%r11, %r10
	andl	$131070, %ecx
	leaq	2(%r10,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbfw_132
	jmp	.Lhrdbfw_128
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_133:
	addq	$1, %rdi
	cmpq	$256, %rdi
	je	.Lhrdbfw_164
.Lhrdbfw_132:
	cmpb	$0, 22(%rdx,%rdi)
	jne	.Lhrdbfw_133
	testq	%rdi, %rdi
	je	.Lhrdbfw_164
	movzwl	36(%r9), %eax
	movw	%ax, 46(%rsp)
	testq	%rax, %rax
	je	.Lhrdbfw_164
	movq	%r8, 192(%rsp)
	movq	%r9, %rbp
	xorl	%r12d, %r12d
	movq	%rax, %r8
.Lhrdbfw_134:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_143
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_196:
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
	jne	.Lhrdbfw_136
	addq	$1, %rcx
	cmpq	%rdi, %rcx
	jnb	.Lhrdbfw_135
	cmpq	$10, %rcx
	ja	.Lhrdbfw_135
.Lhrdbfw_143:
	movzbl	42(%rbp,%rcx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_196
.Lhrdbfw_136:
	cmpq	%rdi, %rcx
	je	.Lhrdbfw_148
.Lhrdbfw_140:
	addq	$1, %r12
	addq	$16, %rbp
	cmpq	%r8, %r12
	jne	.Lhrdbfw_134
	jmp	.Lhrdbfw_164
.Lhrdbfw_135:
	cmpq	%rdi, %rcx
	jne	.Lhrdbfw_140
	cmpq	$11, %rcx
	je	.Lhrdbfw_141
.Lhrdbfw_148:
	movq	%r12, %rax
	salq	$4, %rax
	addq	%r9, %rax
	cmpb	$0, 42(%rcx,%rax)
	jne	.Lhrdbfw_140
.Lhrdbfw_141:
	movq	192(%rsp), %r8
	movl	%r12d, %r10d
	cmpw	%r12w, 46(%rsp)
	je	.Lhrdbfw_164
	movq	%r12, %rcx
	movl	$2, %eax
	salq	$4, %rcx
	addq	%r9, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbfw_128
	movzbl	54(%rcx), %ecx
	cmpw	%r13w, %cx
	jne	.Lhrdbfw_128
	movl	16(%r9), %eax
	cmpq	216(%rsp), %rax
	ja	.Lhrdbfw_170
	cmpq	$0, 208(%rsp)
	jne	.Lhrdbfw_171
	testl	%eax, %eax
	jne	.Lhrdbfw_170
.Lhrdbfw_171:
	movq	%r8, %rcx
	addq	$7, %rax
	shrq	$10, %rcx
	shrq	$3, %rax
	addq	$7, %rcx
	shrq	$3, %rcx
	cmpq	$0, 224(%rsp)
	je	.Lhrdbfw_170
	addq	%rcx, %rax
	cmpq	232(%rsp), %rax
	ja	.Lhrdbfw_170
	movq	224(%rsp), %r11
	addq	%r11, %rax
.Lhrdbfw_145:
	movb	$0, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_145
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
	jne	.Lhrdbfw_146
	movq	200(%rsp), %r9
	movl	84(%rsp), %edx
	cmpl	16(%r9), %edx
	je	.Lhrdbfw_147
	movl	$4, %eax
.Lhrdbfw_146:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_128
.Lhrdbfw_147:
	movl	%edx, 24(%rbx)
	jmp	.Lhrdbfw_128
.Lhrdbfw_170:
	movl	$3, %eax
	jmp	.Lhrdbfw_128
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
	jne	.Lhrdbfw_203
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.Lhrdbfw_205
.Lhrdbfw_203:
	movl	$1, %eax
.Lhrdbfw_197:
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
.Lhrdbfw_205:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.Lhrdbfw_197
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.Lhrdbfw_197
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.Lhrdbfw_197
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.Lhrdbfw_203
	cmpl	%r10d, %r13d
	jb	.Lhrdbfw_203
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbfw_197
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
	je	.Lhrdbfw_207
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_208:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.Lhrdbfw_208
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.Lhrdbfw_209
	testl	%edx, %edx
	je	.Lhrdbfw_209
.Lhrdbfw_211:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_209:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.Lhrdbfw_211
.Lhrdbfw_217:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbfw_211
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_211
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.Lhrdbfw_212
	xorl	%eax, %eax
	jmp	.Lhrdbfw_213
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_230:
	movq	(%rsi), %rcx
.Lhrdbfw_213:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbfw_230
.Lhrdbfw_212:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.Lhrdbfw_216
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_215:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_215
.Lhrdbfw_216:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_207:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_217
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
	je	.Lhrdbfw_234
	cmpl	$1023, %edx
	ja	.Lhrdbfw_285
.Lhrdbfw_234:
	movl	$1, %r12d
.Lhrdbfw_231:
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
.Lhrdbfw_285:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.Lhrdbfw_234
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_234
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
	jne	.Lhrdbfw_234
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.Lhrdbfw_235
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.Lhrdbfw_234
.Lhrdbfw_235:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_286
	cmpl	%r10d, %ecx
	jne	.Lhrdbfw_234
	cmpl	%edx, 312(%rax)
	jne	.Lhrdbfw_234
.Lhrdbfw_257:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.Lhrdbfw_239
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_234
	testl	$511, %ecx
	jne	.Lhrdbfw_234
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.Lhrdbfw_234
.Lhrdbfw_239:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.Lhrdbfw_240
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_287
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_234
.Lhrdbfw_242:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	hrdbfw_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_231
	testl	%r13d, %r13d
	je	.Lhrdbfw_252
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.Lhrdbfw_243:
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
	jne	.Lhrdbfw_262
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_245
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.Lhrdbfw_245
	cmpl	48(%rbx), %edx
	jbe	.Lhrdbfw_245
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.Lhrdbfw_245
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
	je	.Lhrdbfw_246
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.Lhrdbfw_247
.Lhrdbfw_289:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbfw_288
	movq	%rdx, %rax
.Lhrdbfw_247:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.Lhrdbfw_289
.Lhrdbfw_245:
	movl	$4, %r12d
	jmp	.Lhrdbfw_231
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_286:
	cmpl	$-1, %r10d
	jne	.Lhrdbfw_234
	jmp	.Lhrdbfw_257
.Lhrdbfw_240:
	testl	%r13d, %r13d
	je	.Lhrdbfw_234
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.Lhrdbfw_234
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.Lhrdbfw_255:
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
	jne	.Lhrdbfw_231
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.Lhrdbfw_234
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
	jne	.Lhrdbfw_234
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_253
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_290:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_253
.Lhrdbfw_254:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.Lhrdbfw_290
	jmp	.Lhrdbfw_234
.Lhrdbfw_287:
	movl	%r8d, 52(%rbx)
	jmp	.Lhrdbfw_242
.Lhrdbfw_253:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.Lhrdbfw_231
	movzwl	%r8w, %eax
	jmp	.Lhrdbfw_255
.Lhrdbfw_288:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_260
.Lhrdbfw_284:
	movq	16(%r14), %rcx
.Lhrdbfw_250:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.Lhrdbfw_243
	movzwl	94(%rsp), %edi
.Lhrdbfw_252:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbfw_231
.Lhrdbfw_260:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.Lhrdbfw_251
.Lhrdbfw_249:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.Lhrdbfw_258
	movq	%r11, %r8
.Lhrdbfw_251:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.Lhrdbfw_249
	jb	.Lhrdbfw_250
	jmp	.Lhrdbfw_234
.Lhrdbfw_246:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_284
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.Lhrdbfw_258:
	cmpl	%edi, %r9d
	ja	.Lhrdbfw_250
	jmp	.Lhrdbfw_234
.Lhrdbfw_262:
	movl	%eax, %r12d
	jmp	.Lhrdbfw_231
	.p2align 4
hrdbfw_local_cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.Lhrdbfw_291
	cmpb	$1, 15(%rcx)
	jne	.Lhrdbfw_291
	cmpw	$1024, 16(%rcx)
	jne	.Lhrdbfw_291
	cmpw	$512, 18(%rcx)
	jne	.Lhrdbfw_291
	cmpw	$0, 502(%rcx)
	jne	.Lhrdbfw_291
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.Lhrdbfw_294
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_314:
	cmpl	$23, %eax
	ja	.Lhrdbfw_301
.Lhrdbfw_293:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbfw_313
.Lhrdbfw_294:
	cmpb	$0, (%rcx,%rax)
	je	.Lhrdbfw_293
	testb	%dl, %dl
	je	.Lhrdbfw_314
.Lhrdbfw_301:
	movl	$2, %eax
.Lhrdbfw_291:
	ret
.Lhrdbfw_313:
	testl	%r8d, %r8d
	je	.Lhrdbfw_295
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_291
	cmpb	$67, 21(%rcx)
	jne	.Lhrdbfw_291
	cmpb	$72, 22(%rcx)
	jne	.Lhrdbfw_291
	cmpb	$66, 23(%rcx)
	jne	.Lhrdbfw_291
.Lhrdbfw_295:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_291
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.Lhrdbfw_291
	xorl	%eax, %eax
	cmpw	$0, 508(%rcx)
	setne	%al
	addl	%eax, %eax
	ret
	.p2align 4
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.Lhrdbfw_316
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_317:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_317
.Lhrdbfw_316:
	movl	$-12, %ecx
	call GetStdHandle
	leaq	60(%rsp), %r9
	movl	%ebx, %r8d
	movq	%r12, %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call WriteFile
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
hrdbfw_local_write_at:
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	movq	%rcx, %rdi
	pushq	%rsi
	movq	%r8, %rsi
	xorl	%r8d, %r8d
	pushq	%rbx
	movq	%r9, %rbx
	xorl	%r9d, %r9d
	subq	$64, %rsp
	movq	2280(%rcx), %rcx
	call SetFilePointerEx
	testl	%eax, %eax
	je	.Lhrdbfw_324
	leaq WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.Lhrdbfw_325
	jmp	.Lhrdbfw_326
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_337:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_324
	cmpq	%rax, %rbx
	jb	.Lhrdbfw_324
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.Lhrdbfw_326
.Lhrdbfw_325:
	movq	2280(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.Lhrdbfw_337
.Lhrdbfw_324:
	addq	$64, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_326:
	addq	$64, %rsp
	xorl	%eax, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
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
	ja	.Lhrdbfw_338
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_418
	cmpb	$78, %r9b
	je	.Lhrdbfw_419
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_420
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_365
	cmpb	$89, %al
	je	.Lhrdbfw_365
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_338
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_338
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_338:
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
.Lhrdbfw_365:
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
.Lhrdbfw_419:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_342
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_343
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_344:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_342
.Lhrdbfw_343:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_344
	jmp	.Lhrdbfw_346
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_370:
	movl	%r9d, %ecx
.Lhrdbfw_346:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_345
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_370
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_348
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_368:
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
	jmp	.Lhrdbfw_352
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_422:
	testl	%esi, %esi
	jne	.Lhrdbfw_389
	movl	$1, %esi
.Lhrdbfw_350:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_421
.Lhrdbfw_352:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_422
.Lhrdbfw_389:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_382
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_379
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_350
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_350
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_418:
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
.Lhrdbfw_420:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_361:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_381
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_361
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_338
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_382:
	movl	$5, %r11d
	jmp	.Lhrdbfw_338
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_381:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_360:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_382
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_360
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
	jbe	.Lhrdbfw_338
	cmpl	$11, %edx
	ja	.Lhrdbfw_338
	testl	%r10d, %r10d
	je	.Lhrdbfw_338
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_423
.Lhrdbfw_363:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_338
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_338
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_348:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_349:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_382
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_368
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_379:
	movl	$4, %r11d
	jmp	.Lhrdbfw_338
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_421:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_338
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_338
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_353
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_354
	jmp	.Lhrdbfw_379
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_355:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_379
.Lhrdbfw_354:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_355
	testl	%r12d, %r12d
	jne	.Lhrdbfw_367
.Lhrdbfw_358:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_338
.Lhrdbfw_345:
	je	.Lhrdbfw_342
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_348
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_349
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_342:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_338
.Lhrdbfw_423:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_363
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_364
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_363
.Lhrdbfw_364:
	addl	$1, %edx
	jmp	.Lhrdbfw_363
.Lhrdbfw_353:
	testl	%r12d, %r12d
	je	.Lhrdbfw_358
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_358
.Lhrdbfw_367:
	negq	%rbx
	jmp	.Lhrdbfw_358
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
	je	.Lhrdbfw_427
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_439
.Lhrdbfw_427:
	xorl	%r12d, %r12d
.Lhrdbfw_426:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_428
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_440
	movl	$7, %r12d
.Lhrdbfw_428:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_424
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_431
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_424:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_440:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_428
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_439:
	movl	$7, %r12d
	jmp	.Lhrdbfw_426
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_431:
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
	jne	.Lhrdbfw_441
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_441:
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
	ja	.Lhrdbfw_447
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_447
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_447
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_447
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_447
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_443
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_443
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_443
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_443
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_447
	testl	$511, %r12d
	jne	.Lhrdbfw_447
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_447
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_443
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_443
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_447
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_447
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_443
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
	jne	.Lhrdbfw_443
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_447
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_447
	testl	$511, %eax
	jne	.Lhrdbfw_447
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_447
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_447
	cmpl	%r12d, %eax
	je	.Lhrdbfw_447
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_447
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_448
.Lhrdbfw_521:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_485
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_520
.Lhrdbfw_448:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_521
.Lhrdbfw_485:
	movl	$2, %eax
	jmp	.Lhrdbfw_443
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_447:
	movl	$1, %eax
.Lhrdbfw_443:
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
.Lhrdbfw_520:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_443
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_485
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_485
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_485
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_449:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_485
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_449
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_450:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_485
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_459:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_453
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_454
	subl	$32, %ecx
.Lhrdbfw_454:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_455
	subl	$32, %r13d
.Lhrdbfw_455:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_453
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_451
	cmpq	$11, %rdx
	jne	.Lhrdbfw_459
	cmpq	$11, %rax
	jne	.Lhrdbfw_453
.Lhrdbfw_457:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_485
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_485
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_484
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_485
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_489
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_491
	testl	%eax, %eax
	jne	.Lhrdbfw_489
.Lhrdbfw_491:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_489
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_489
	xorl	%edx, %edx
.Lhrdbfw_461:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_461
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_462
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_462:
	testb	$2, %al
	jne	.Lhrdbfw_463
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_463:
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
.Lhrdbfw_464:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_464
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_522
.Lhrdbfw_465:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_443
.Lhrdbfw_451:
	cmpq	$11, %rax
	je	.Lhrdbfw_457
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_457
.Lhrdbfw_453:
	addq	$1, %r9
	jmp	.Lhrdbfw_450
.Lhrdbfw_489:
	movl	$3, %eax
	jmp	.Lhrdbfw_443
.Lhrdbfw_484:
	movl	$5, %eax
	jmp	.Lhrdbfw_443
.Lhrdbfw_522:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_465
	xorl	%edx, %edx
	jmp	.Lhrdbfw_467
.Lhrdbfw_523:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_492
.Lhrdbfw_467:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_466
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_466:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_523
.Lhrdbfw_492:
	testl	%eax, %eax
	jne	.Lhrdbfw_465
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_443
	.p2align 4
hrdbf_file_append.part.0:
	pushq	%r15
	movl	$4, %r15d
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$56, %rsp
	movzwl	34(%rcx), %esi
	movl	16(%rcx), %r12d
	movzwl	32(%rcx), %eax
	imulq	%rsi, %r12
	addq	$1, %rsi
	addq	%rax, %r12
	leaq	(%r12,%rsi), %rbp
	cmpq	$67108864, %rbp
	ja	.Lhrdbfw_524
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call VirtualAlloc
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_532
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.Lhrdbfw_529
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_526:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.Lhrdbfw_526
.Lhrdbfw_529:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.Lhrdbfw_528
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_527:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbfw_527
	addq	%r14, %rdx
.Lhrdbfw_528:
	movb	$26, (%rdx)
	leaq	32(%rsp), %rcx
	call GetSystemTime
	movzbl	32(%rsp), %eax
	movl	$7, %r9d
	movq	%rbx, %rcx
	leaq	1(%r13), %r8
	movl	$1, %edx
	subl	$108, %eax
	movb	%al, 1(%r13)
	movzwl	34(%rsp), %eax
	movb	%al, 2(%r13)
	movzwl	38(%rsp), %eax
	movb	%al, 3(%r13)
	movl	16(%rbx), %eax
	movb	$0, 28(%r13)
	addl	$1, %eax
	movl	%eax, 4(%r13)
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	je	.Lhrdbfw_544
.Lhrdbfw_530:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call VirtualFree
.Lhrdbfw_524:
	addq	$56, %rsp
	movl	%r15d, %eax
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
.Lhrdbfw_544:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_530
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_530
	xorl	%edx, %edx
	movq	2256(%rbx), %rcx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_535
	movl	16(%rbx), %eax
	xorl	%edx, %edx
	movq	%r13, (%rbx)
	movq	%r13, 2256(%rbx)
	leal	1(%rax), %esi
	movq	%rbp, 2264(%rbx)
	movq	%rbp, 8(%rbx)
	movl	%esi, 16(%rbx)
	movq	%rsi, 24(%rbx)
	movw	%dx, 38(%rbx)
	movl	%esi, (%rdi)
	jmp	.Lhrdbfw_524
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_532:
	movl	$8, %r15d
	jmp	.Lhrdbfw_524
.Lhrdbfw_535:
	movl	$7, %r15d
	jmp	.Lhrdbfw_530
	.p2align 4
hrdbfw_local_put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.Lhrdbfw_545
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.Lhrdbfw_566
	subl	%r10d, %edx
	je	.Lhrdbfw_551
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_552:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.Lhrdbfw_552
.Lhrdbfw_551:
	testl	%r10d, %r10d
	je	.Lhrdbfw_550
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_553:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.Lhrdbfw_553
.Lhrdbfw_550:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_545:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_566:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.Lhrdbfw_550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_549:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.Lhrdbfw_550
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_549
	jmp	.Lhrdbfw_550
	.p2align 4
hrdbf_write_number_scaled.part.0:
	pushq	%r14
	movl	$4, %eax
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$160, %rsp
	movzbl	13(%rdx), %r13d
	cmpb	$17, %r13b
	ja	.Lhrdbfw_567
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.Lhrdbfw_593
	cmpb	%r8b, %r13b
	jnb	.Lhrdbfw_593
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.Lhrdbfw_569
	negq	%rcx
	movl	$1, %r11d
.Lhrdbfw_569:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_570
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.Lhrdbfw_571
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_572:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.Lhrdbfw_572
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq $1, %r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.Lhrdbfw_573
.Lhrdbfw_571:
	addq	$1, %rcx
.Lhrdbfw_573:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_578:
	movq	%rcx, %rax
	movl	%r10d, %esi
	addq	$1, %r9
	addl	$1, %r10d
	mulq	%rdi
	movq	%rcx, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r14
	addq	%r14, %r14
	subq	%r14, %rax
	movq	%rcx, %r14
	movq	%rdx, %rcx
	addl	$48, %eax
	movb	%al, -1(%r9)
	cmpq	$9, %r14
	ja	.Lhrdbfw_578
	movl	%r10d, %r14d
	movl	$1, %edx
	movl	$0, %ecx
	movzbl	%r8b, %edi
	subl	%ebp, %r14d
	cmpl	%r10d, %ebp
	movzwl	14(%rbx), %r9d
	cmovnb	%edx, %r14d
	testb	%r13b, %r13b
	leal	1(%rbp), %edx
	cmove	%ecx, %edx
	leal	(%r14,%r11), %ecx
	addl	%ecx, %edx
	cmpl	%edi, %edx
	ja	.Lhrdbfw_621
	testl	%r11d, %r11d
	je	.Lhrdbfw_584
	movb	$45, 96(%rsp)
.Lhrdbfw_584:
	cmpl	%r10d, %ebp
	jb	.Lhrdbfw_622
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.Lhrdbfw_586:
	testb	%r13b, %r13b
	je	.Lhrdbfw_588
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.Lhrdbfw_589
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_590:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.Lhrdbfw_590
	addl	%ebp, %eax
.Lhrdbfw_589:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_591:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.Lhrdbfw_591
.Lhrdbfw_588:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_567:
	addq	$160, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_593:
	movl	$4, %eax
	jmp	.Lhrdbfw_567
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_570:
	jnb	.Lhrdbfw_573
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.Lhrdbfw_573
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_574
	xorl	%eax, %eax
	jmp	.Lhrdbfw_575
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_577:
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_574
.Lhrdbfw_575:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.Lhrdbfw_577
	jmp	.Lhrdbfw_573
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_622:
	testl	%r14d, %r14d
	je	.Lhrdbfw_597
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.Lhrdbfw_587
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_623:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.Lhrdbfw_587:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.Lhrdbfw_623
	jmp	.Lhrdbfw_586
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_621:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_582:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbfw_582
	xorl	%eax, %eax
	jmp	.Lhrdbfw_567
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_574:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_576:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_576
	xorl	%eax, %eax
	jmp	.Lhrdbfw_567
.Lhrdbfw_597:
	movl	%r11d, %edx
	jmp	.Lhrdbfw_586
	.p2align 4
hrdbfw_local_bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_673
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.Lhrdbfw_676
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.Lhrdbfw_632
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.Lhrdbfw_634
.Lhrdbfw_633:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_637
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_636:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.Lhrdbfw_677
	movl	%eax, %ecx
.Lhrdbfw_637:
	cmpl	%ecx, %r10d
	jbe	.Lhrdbfw_636
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbfw_636
.Lhrdbfw_635:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.Lhrdbfw_634
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.Lhrdbfw_642
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_641:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.Lhrdbfw_641
.Lhrdbfw_642:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.Lhrdbfw_634
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_643:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_643
.Lhrdbfw_634:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.Lhrdbfw_624
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_644
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_645:
	movl	(%rdx), %r8d
	movl	4(%rdx), %r10d
	movl	%r11d, %ecx
	addq	$4, %rdx
	shrl	%cl, %r8d
	movl	%ebx, %ecx
	sall	%cl, %r10d
	orl	%r10d, %r8d
	movl	%r8d, -4(%rdx)
	cmpq	%rdx, %rsi
	jne	.Lhrdbfw_645
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.Lhrdbfw_624
	movl	%edi, 288(%r9)
	jmp	.Lhrdbfw_624
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_676:
	testl	%r10d, %r10d
	je	.Lhrdbfw_627
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_629:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_629
	testl	%eax, %eax
	je	.Lhrdbfw_627
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_630:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_630
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.Lhrdbfw_627
	jne	.Lhrdbfw_652
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.Lhrdbfw_627
.Lhrdbfw_652:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_627:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.Lhrdbfw_624:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_673:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_632:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.Lhrdbfw_633
	jmp	.Lhrdbfw_635
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_677:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_635
.Lhrdbfw_644:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.Lhrdbfw_624
	.p2align 4
hrdbfw_local_fdec:
	pushq	%rsi
	movq	%rcx, %r8
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %r9
	pushq	%rbx
	subq	$56, %rsp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_679:
	movq	%r8, %rax
	movq	%r8, %rcx
	mulq	%r9
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movl	%r10d, %eax
	addl	$1, %r10d
	addl	$48, %ecx
	movb	%cl, 16(%rsp,%rax)
	movq	%r8, %rax
	movq	%rdx, %r8
	cmpq	$9, %rax
	jbe	.Lhrdbfw_687
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_679
.Lhrdbfw_687:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_685:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_681
	jmp	.Lhrdbfw_682
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_683:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_682
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_681:
	testb	%cl, %cl
	jne	.Lhrdbfw_683
.Lhrdbfw_682:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_678
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_685
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_678:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
hrdbf_fmt_harbour.part.0:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	movq	%xmm2, %r12
	pushq	%rbp
	shrq	$52, %r12
	pushq	%rdi
	andl	$2047, %r12d
	pushq	%rsi
	pushq	%rbx
	subq	$2328, %rsp
	movl	%edx, 2408(%rsp)
	movl	%r9d, 2424(%rsp)
	movq	%xmm2, 56(%rsp)
	cmpq	$2047, %r12
	je	.Lhrdbfw_702
	movabs	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.Lhrdbfw_940
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.Lhrdbfw_700:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_705:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_706:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_706
	testq	%rax, %rax
	je	.Lhrdbfw_707
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.Lhrdbfw_707:
	subl	$1, %r9d
	jne	.Lhrdbfw_705
	testb	%r11b, %r11b
	je	.Lhrdbfw_709
	movl	%r10d, 352(%rsp)
.Lhrdbfw_709:
	testl	%r12d, %r12d
	js	.Lhrdbfw_710
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_937:
	movl	352(%rsp), %eax
.Lhrdbfw_713:
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_711
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_716:
	cmpq	$80, %rbx
	je	.Lhrdbfw_941
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.Lhrdbfw_711:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.Lhrdbfw_716
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_716
	testl	%ebx, %ebx
	jne	.Lhrdbfw_942
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_701
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.Lhrdbfw_943
.Lhrdbfw_702:
	xorl	%eax, %eax
.Lhrdbfw_694:
	addq	$2328, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbfw_940:
	testq	%rax, %rax
	jne	.Lhrdbfw_944
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.Lhrdbfw_701
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.Lhrdbfw_702
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_704:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_704
	jmp	.Lhrdbfw_694
.Lhrdbfw_701:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.Lhrdbfw_702
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.Lhrdbfw_694
.Lhrdbfw_944:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.Lhrdbfw_700
.Lhrdbfw_710:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	hrdbfw_local_bn_shr_round
	cmpl	$1, %eax
	jbe	.Lhrdbfw_937
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_809
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.Lhrdbfw_715:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.Lhrdbfw_715
	testq	%rdx, %rdx
	je	.Lhrdbfw_713
	leal	1(%rax), %edx
.Lhrdbfw_714:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.Lhrdbfw_713
.Lhrdbfw_941:
	movl	$79, %r10d
.Lhrdbfw_719:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.Lhrdbfw_723:
	movl	%ecx, %r8d
	movl	%ecx, %eax
	movl	%edx, %r12d
	imulq	%r11, %r8
	shrq	$35, %r8
	leal	(%r8,%r8,4), %r9d
	addl	%r9d, %r9d
	subl	%r9d, %eax
	movl	%ecx, %r9d
	movl	%r8d, %ecx
	movq	%rdx, %r8
	addl	$48, %eax
	movb	%al, (%rbx,%rdx)
	addq	$1, %rdx
	cmpl	$9, %r9d
	ja	.Lhrdbfw_723
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.Lhrdbfw_725
.Lhrdbfw_945:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_725:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.Lhrdbfw_945
	testl	%r10d, %r10d
	je	.Lhrdbfw_726
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.Lhrdbfw_728:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_727:
	movl	%edx, %eax
	movl	%ecx, %r8d
	subl	$1, %ecx
	imulq	%rbx, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %r11d
	addl	%r11d, %r11d
	subl	%r11d, %edx
	addl	$48, %edx
	movb	%dl, 1600(%rsp,%r8)
	movl	%eax, %edx
	cmpl	%r9d, %ecx
	jne	.Lhrdbfw_727
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.Lhrdbfw_946
	movq	%rax, %rbp
	jmp	.Lhrdbfw_728
.Lhrdbfw_946:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.Lhrdbfw_726:
	leal	-341(%r12), %eax
	xorl	%r10d, %r10d
	movl	$340, %r9d
	movl	%eax, 52(%rsp)
	movq	40(%rsp), %rax
	leaq	368(%rsp), %r11
	leaq	372(%rsp), %rbx
	leaq	(%rax,%rax), %rbp
	leaq	1(%rbp), %rax
	movq	%rax, 368(%rsp)
	shrq	$32, %rax
	setne	%r10b
	xorl	%edi, %edi
	addl	$1, %r10d
	movl	%r10d, 656(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_730:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_731:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_731
	testq	%rax, %rax
	je	.Lhrdbfw_732
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.Lhrdbfw_732:
	subl	$1, %r9d
	jne	.Lhrdbfw_730
	testb	%dil, %dil
	je	.Lhrdbfw_734
	movl	%r10d, 656(%rsp)
.Lhrdbfw_734:
	leal	339(%r15), %r14d
	movq	%r11, %rcx
	movl	%r14d, %edx
	call	hrdbfw_local_bn_shl
	cmpl	$-1074, %r15d
	movabs	$4503599627370496, %rax
	setne	%r11b
	cmpq	%rax, 40(%rsp)
	sete	%al
	andb	%al, %r11b
	je	.Lhrdbfw_735
	movl	$340, %ebx
	xorl	%ebp, %ebp
	movl	$2, %edi
	movabs	$18014398509481983, %rax
	movq	%rax, 672(%rsp)
	leaq	672(%rsp), %r9
	leaq	676(%rsp), %r10
	movl	$2, 960(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_736:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_737:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_737
	testq	%rax, %rax
	je	.Lhrdbfw_738
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_738:
	subl	$1, %ebx
	jne	.Lhrdbfw_736
	testb	%bpl, %bpl
	je	.Lhrdbfw_740
	movl	%edi, 960(%rsp)
.Lhrdbfw_740:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_741:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.Lhrdbfw_748
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.Lhrdbfw_775:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_749:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.Lhrdbfw_749
	cmpb	$53, (%rdi)
	ja	.Lhrdbfw_750
	je	.Lhrdbfw_947
.Lhrdbfw_751:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.Lhrdbfw_948
.Lhrdbfw_753:
	xorl	%r9d, %r9d
	movq	%r8, 976(%rsp)
	shrq	$32, %r8
	leaq	980(%rsp), %r14
	setne	%r9b
	xorl	%r10d, %r10d
	xorl	%r15d, %r15d
	addl	$1, %r9d
	movl	%r9d, 1264(%rsp)
	testl	%r11d, %r11d
	je	.Lhrdbfw_757
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_756:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_758:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_758
	testq	%rax, %rax
	je	.Lhrdbfw_759
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.Lhrdbfw_759:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.Lhrdbfw_756
	testb	%r15b, %r15b
	je	.Lhrdbfw_757
	movl	%r9d, 1264(%rsp)
.Lhrdbfw_757:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.Lhrdbfw_762
	jnb	.Lhrdbfw_763
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_764
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_771
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_774:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.Lhrdbfw_949
.Lhrdbfw_771:
	cmpl	$-1, %eax
	jne	.Lhrdbfw_774
.Lhrdbfw_770:
	testb	$1, 40(%rsp)
	je	.Lhrdbfw_929
.Lhrdbfw_764:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.Lhrdbfw_930
	cmpl	%r12d, %ebp
	jb	.Lhrdbfw_775
.Lhrdbfw_930:
	movq	2400(%rsp), %rsi
.Lhrdbfw_748:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.Lhrdbfw_777:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.Lhrdbfw_778:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.Lhrdbfw_778
	cmpl	%r12d, %ebp
	jnb	.Lhrdbfw_779
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.Lhrdbfw_780
	jne	.Lhrdbfw_779
	testb	$1, %r8b
	jne	.Lhrdbfw_780
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.Lhrdbfw_779
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.Lhrdbfw_781
.Lhrdbfw_950:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.Lhrdbfw_779
.Lhrdbfw_781:
	cmpb	$48, (%rcx)
	je	.Lhrdbfw_950
.Lhrdbfw_780:
	addq	$1, %r8
.Lhrdbfw_779:
	movabs	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.Lhrdbfw_782:
	movq	%r8, %rax
	movl	%ecx, %r9d
	addq	$1, %rbx
	addl	$1, %ecx
	mulq	%r10
	movq	%r8, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r11
	addq	%r11, %r11
	subq	%r11, %rax
	movq	%r8, %r11
	movq	%rdx, %r8
	addl	$48, %eax
	movb	%al, -1(%rbx)
	cmpq	$9, %r11
	ja	.Lhrdbfw_782
	cmpl	%ebp, %ecx
	jbe	.Lhrdbfw_783
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.Lhrdbfw_787
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.Lhrdbfw_783:
	xorl	%edx, %edx
	jmp	.Lhrdbfw_785
.Lhrdbfw_951:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_785:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbfw_951
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_786
.Lhrdbfw_952:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbfw_786
	movl	%eax, %ecx
.Lhrdbfw_787:
	cmpl	$1, %ecx
	ja	.Lhrdbfw_952
.Lhrdbfw_786:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.Lhrdbfw_953
	cmpl	%ecx, %r8d
	jge	.Lhrdbfw_792
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.Lhrdbfw_798
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.Lhrdbfw_795
.Lhrdbfw_794:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.Lhrdbfw_954
	movq	%rcx, %rdx
.Lhrdbfw_795:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.Lhrdbfw_794
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.Lhrdbfw_798
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_956:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.Lhrdbfw_955
	movl	%edx, %r8d
.Lhrdbfw_798:
	cmpl	$1, %r8d
	jne	.Lhrdbfw_956
.Lhrdbfw_797:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.Lhrdbfw_790
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_762:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.Lhrdbfw_767
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_769:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.Lhrdbfw_957
.Lhrdbfw_767:
	cmpl	$-1, %edx
	jne	.Lhrdbfw_769
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.Lhrdbfw_771
	jmp	.Lhrdbfw_770
.Lhrdbfw_947:
	testb	$1, %r8b
	jne	.Lhrdbfw_750
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbfw_751
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.Lhrdbfw_752
.Lhrdbfw_958:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_751
.Lhrdbfw_752:
	cmpb	$48, (%rax)
	je	.Lhrdbfw_958
.Lhrdbfw_750:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.Lhrdbfw_753
.Lhrdbfw_948:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_754:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.Lhrdbfw_754
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_753
	movabs	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.Lhrdbfw_753
.Lhrdbfw_949:
	jnb	.Lhrdbfw_773
	cmpl	$1, %ecx
	je	.Lhrdbfw_929
.Lhrdbfw_773:
	testl	%ecx, %ecx
	jne	.Lhrdbfw_764
	jmp	.Lhrdbfw_770
.Lhrdbfw_957:
	jnb	.Lhrdbfw_768
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.Lhrdbfw_771
	jmp	.Lhrdbfw_764
.Lhrdbfw_763:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_938
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_771
.Lhrdbfw_938:
	jnb	.Lhrdbfw_764
.Lhrdbfw_929:
	movq	2400(%rsp), %rsi
	jmp	.Lhrdbfw_777
.Lhrdbfw_768:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_938
	movl	$1, %ecx
	jmp	.Lhrdbfw_771
.Lhrdbfw_735:
	subq	$1, %rbp
	xorl	%edi, %edi
	movl	$340, %ebx
	movq	%rbp, 672(%rsp)
	shrq	$32, %rbp
	leaq	672(%rsp), %r9
	leaq	676(%rsp), %r10
	setne	%dil
	addl	$1, %edi
	movl	%edi, 960(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_743:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_744:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_744
	testq	%rax, %rax
	je	.Lhrdbfw_745
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_745:
	subl	$1, %ebx
	jne	.Lhrdbfw_743
	testb	%r11b, %r11b
	je	.Lhrdbfw_747
	movl	%edi, 960(%rsp)
.Lhrdbfw_747:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
	jmp	.Lhrdbfw_741
.Lhrdbfw_792:
	cmpl	$1, %ecx
	je	.Lhrdbfw_797
.Lhrdbfw_790:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.Lhrdbfw_799:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.Lhrdbfw_702
	testl	%r10d, %r10d
	je	.Lhrdbfw_823
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.Lhrdbfw_801:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbfw_802
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.Lhrdbfw_804:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_803
	movzbl	0(%r13,%rdx), %r11d
.Lhrdbfw_803:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_804
	addl	%r10d, %eax
.Lhrdbfw_805:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbfw_694
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.Lhrdbfw_807
.Lhrdbfw_960:
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_825
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.Lhrdbfw_806:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.Lhrdbfw_959
.Lhrdbfw_807:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.Lhrdbfw_960
.Lhrdbfw_825:
	movl	$48, %r10d
	jmp	.Lhrdbfw_806
.Lhrdbfw_823:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.Lhrdbfw_801
.Lhrdbfw_953:
	jne	.Lhrdbfw_789
	cmpb	$52, 1600(%rsp)
	jbe	.Lhrdbfw_789
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.Lhrdbfw_790
.Lhrdbfw_789:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.Lhrdbfw_799
.Lhrdbfw_802:
	movb	$48, (%rdx)
	jmp	.Lhrdbfw_805
.Lhrdbfw_959:
	addl	%r9d, %eax
	jmp	.Lhrdbfw_694
.Lhrdbfw_942:
	subl	$1, %r10d
	jmp	.Lhrdbfw_719
.Lhrdbfw_943:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_722:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_722
	jmp	.Lhrdbfw_694
.Lhrdbfw_955:
	movl	%r8d, %ecx
	jmp	.Lhrdbfw_790
.Lhrdbfw_809:
	movl	$1, %edx
	jmp	.Lhrdbfw_714
.Lhrdbfw_954:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.Lhrdbfw_798
	.p2align 4
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.Lhrdbfw_968
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.Lhrdbfw_961
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_961
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_961:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_968:
	ret
	.section .rdata,"dr"
.Lhrdbfw_C0:

.byte 32,40,119,105,110,51,50,32,101,114,114,111,114,32,0
	.text
	.p2align 4
hrdbfw_local_werr:
	pushq	%rsi
	leaq	hrdbfw_local_fsink(%rip), %rsi
	movl	%edx, %r8d
	pushq	%rbx
	movq	%rsi, %rax
	leaq	159(%rsi), %rbx
	subq	$40, %rsp
	jmp	.Lhrdbfw_972
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_974:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_973
.Lhrdbfw_972:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_974
.Lhrdbfw_973:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_975
	movl	$32, %ecx
	leaq	.Lhrdbfw_C0(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_977:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_981
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_977
.Lhrdbfw_981:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_975:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_978
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_978:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
hrdbfw_local_ddec:
	pushq	%rsi
	movq	%rcx, %r8
	movq	%rdx, %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %r11
	pushq	%rbx
	subq	$56, %rsp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_983:
	movq	%r9, %rax
	movq	%r9, %rcx
	mulq	%r11
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %rax
	addq	%rax, %rax
	subq	%rax, %rcx
	movl	%r10d, %eax
	addl	$1, %r10d
	addl	$48, %ecx
	movb	%cl, 16(%rsp,%rax)
	movq	%r9, %rax
	movq	%rdx, %r9
	cmpq	$9, %rax
	jbe	.Lhrdbfw_993
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_983
.Lhrdbfw_993:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_991:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_985
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_987:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_986
.Lhrdbfw_985:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_987
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_988
	jmp	.Lhrdbfw_986
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_989:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_986
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_988:
	testb	%cl, %cl
	jne	.Lhrdbfw_989
.Lhrdbfw_986:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_982
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_991
.Lhrdbfw_982:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
hrdbfw_local_dname:
	pushq	%rbx
	movq	%rcx, %r10
	movq	%rdx, %r11
	xorl	%r9d, %r9d
	movl	$63, %ebx
	leaq	2249(%rcx), %r8
	subq	$16, %rsp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1001:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_1000
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.Lhrdbfw_1003
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1005:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1004
.Lhrdbfw_1003:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1005
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1006
	jmp	.Lhrdbfw_1004
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1007:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1004
.Lhrdbfw_1006:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1007
.Lhrdbfw_1004:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_1001
.Lhrdbfw_1000:
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
.Lhrdbfw_C1:

.byte 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,0
	.text
	.p2align 4
hrdbfw_local_dhex:
	pushq	%rbx
	movl	%edx, %eax
	leaq	.Lhrdbfw_C1(%rip), %rbx
	movl	%edx, %r11d
	shrl	$4, %eax
	subq	$16, %rsp
	movzbl	(%rbx,%rax), %r8d
	leaq	2090(%rcx), %rax
	addq	$2249, %rcx
	movb	$0, 15(%rsp)
	movq	%rax, %rdx
	movb	%r8b, 14(%rsp)
	jmp	.Lhrdbfw_1015
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1017:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1016
.Lhrdbfw_1015:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_1017
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_1018
	jmp	.Lhrdbfw_1016
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1020:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1016
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_1018:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1020
.Lhrdbfw_1016:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_1022
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1024:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1023
.Lhrdbfw_1022:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1024
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_1025
	jmp	.Lhrdbfw_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1026:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1023
.Lhrdbfw_1025:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1026
.Lhrdbfw_1023:
	movb	$0, (%rax)
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C2:

.byte 112,97,116,104,32,105,115,32,110,111,116,32,97,32,115,117,112,112,111,114,116,101,100,32,112,108,97,105,110,32,102,105,108,101,32,112,97,116,104,32,40,114,101,115,101,114,118,101,100,32,100,101,118,105,99,101,32,110,97,109,101,32,111,114,32,99,104,97,114,97,99,116,101,114,115,41,0
.Lhrdbfw_C3:

.byte 67,79,78,0
.Lhrdbfw_C4:

.byte 80,82,78,0
.Lhrdbfw_C5:

.byte 65,85,88,0
.Lhrdbfw_C6:

.byte 78,85,76,0
.Lhrdbfw_C7:

.byte 67,79,78,73,78,36,0
.Lhrdbfw_C8:

.byte 67,79,78,79,85,84,36,0
.Lhrdbfw_C9:

.byte 67,76,79,67,75,36,0
.Lhrdbfw_C10:

.byte 67,79,77,0
.Lhrdbfw_C11:

.byte 76,80,84,0
	.align 8
.Lhrdbfw_C12:

.byte 79,83,32,111,112,101,110,32,102,97,105,108,101,100,32,40,50,61,109,105,115,115,105,110,103,44,32,53,61,97,99,99,101,115,115,32,100,101,110,105,101,100,44,32,51,50,61,97,110,111,116,104,101,114,32,112,114,111,103,114,97,109,32,104,97,115,32,105,116,32,111,112,101,110,41,0
.Lhrdbfw_C13:

.byte 71,101,116,70,105,108,101,83,105,122,101,69,120,32,102,97,105,108,101,100,0
	.align 8
.Lhrdbfw_C14:

.byte 102,105,108,101,32,104,97,115,32,102,101,119,101,114,32,116,104,97,110,32,116,104,101,32,51,51,32,104,101,97,100,101,114,32,98,121,116,101,115,0
.Lhrdbfw_C15:

.byte 102,105,108,101,32,115,105,122,101,32,0
.Lhrdbfw_C16:

.byte 32,101,120,99,101,101,100,115,32,116,104,101,32,54,52,32,77,105,66,32,108,105,109,105,116,0
	.align 8
.Lhrdbfw_C17:

.byte 102,105,108,101,32,115,105,122,101,32,105,115,32,110,111,116,32,97,32,119,104,111,108,101,32,110,117,109,98,101,114,32,111,102,32,112,97,103,101,115,0
	.align 8
.Lhrdbfw_C18:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,32,115,110,97,112,115,104,111,116,116,105,110,103,32,116,104,101,32,102,105,108,101,0
.Lhrdbfw_C19:

.byte 79,83,32,114,101,97,100,32,102,97,105,108,101,100,0
	.align 8
.Lhrdbfw_C20:

.byte 102,105,108,101,32,99,104,97,110,103,101,100,32,115,105,122,101,32,119,104,105,108,101,32,98,101,105,110,103,32,114,101,97,100,0
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
	je	.Lhrdbfw_1038
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.Lhrdbfw_1141
	cmpb	$47, %dl
	jne	.Lhrdbfw_1134
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_1038
	movl	$47, %eax
.Lhrdbfw_1039:
	movabs	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.Lhrdbfw_1040
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1143:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.Lhrdbfw_1038
.Lhrdbfw_1044:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1142
	js	.Lhrdbfw_1038
	cmpq	$258, %rbx
	ja	.Lhrdbfw_1038
.Lhrdbfw_1040:
	cmpb	$63, %al
	ja	.Lhrdbfw_1143
	btq	%rax, %r9
	jc	.Lhrdbfw_1038
	cmpb	$60, %al
	je	.Lhrdbfw_1038
	cmpb	$58, %al
	jne	.Lhrdbfw_1043
	cmpq	$1, %rbx
	jne	.Lhrdbfw_1038
	cmpb	$25, %dl
	ja	.Lhrdbfw_1038
	movl	$58, %eax
	jmp	.Lhrdbfw_1044
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1148:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_1049
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1038:
	leaq	.Lhrdbfw_C2(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_1034:
	addq	$632, %rsp
	movl	%r13d, %eax
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
.Lhrdbfw_1141:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.Lhrdbfw_1039
	jmp	.Lhrdbfw_1038
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1043:
	cmpb	$47, %al
	jne	.Lhrdbfw_1044
	movl	$92, %eax
	jmp	.Lhrdbfw_1044
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1134:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.Lhrdbfw_1039
	jmp	.Lhrdbfw_1038
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1142:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.Lhrdbfw_1064
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1047:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.Lhrdbfw_1144
	movq	%rax, %rbx
.Lhrdbfw_1064:
	cmpq	%r15, %r12
	je	.Lhrdbfw_1046
	cmpw	$92, (%rdi,%r15,2)
	jne	.Lhrdbfw_1047
.Lhrdbfw_1046:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.Lhrdbfw_1093
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.Lhrdbfw_1048
	cmpw	$46, %ax
	je	.Lhrdbfw_1048
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.Lhrdbfw_1049:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1051
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1052:
	movzwl	0(%r13,%rax,2), %edx
.Lhrdbfw_1051:
	cmpw	$46, %dx
	je	.Lhrdbfw_1145
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_1052
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.Lhrdbfw_1054
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1058:
	subq	$1, %rsi
	je	.Lhrdbfw_1054
.Lhrdbfw_1057:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.Lhrdbfw_1058
.Lhrdbfw_1054:
	leaq	.Lhrdbfw_C3(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1038
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.Lhrdbfw_1047
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_1047
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_1061
.Lhrdbfw_1146:
	leaq	.Lhrdbfw_C10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_1091
	movzwl	0(%r13,%rcx,2), %eax
.Lhrdbfw_1061:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1091
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_1146
	jmp	.Lhrdbfw_1038
.Lhrdbfw_1091:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_1063
.Lhrdbfw_1147:
	movzwl	0(%r13,%rdx,2), %r14d
.Lhrdbfw_1063:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_1093
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_1038
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_1147
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1093:
	movq	%rbx, %rcx
	jmp	.Lhrdbfw_1047
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1048:
	cmpq	$1, %rsi
	je	.Lhrdbfw_1148
	cmpq	$2, %rsi
	jne	.Lhrdbfw_1038
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.Lhrdbfw_1038
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_1049
	jmp	.Lhrdbfw_1038
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1145:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_1057
	jmp	.Lhrdbfw_1054
.Lhrdbfw_1144:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.Lhrdbfw_1038
	cmpq	$1, %rbx
	je	.Lhrdbfw_1065
	cmpw	$58, 98(%rsp)
	je	.Lhrdbfw_1149
.Lhrdbfw_1065:
	cmpl	$1, 752(%rsp)
	movq	%r12, %rcx
	movq	$0, 48(%rsp)
	sbbl	%edx, %edx
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	movl	$128, 40(%rsp)
	andl	$-1073741824, %edx
	movl	$3, 32(%rsp)
	subl	$1073741824, %edx
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_1150
	movq	728(%rsp), %rax
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1151
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_1152
	cmpq	$67108864, %r10
	jg	.Lhrdbfw_1153
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1071
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1154
.Lhrdbfw_1071:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.Lhrdbfw_1072
	movq	(%rdi), %r8
	leaq ReadFile(%rip), %rbx
	xorl	%r15d, %r15d
	movq	%rax, %rdx
	leaq GetLastError(%rip), %r13
	leaq	76(%rsp), %rsi
	testq	%r8, %r8
	jne	.Lhrdbfw_1073
	jmp	.Lhrdbfw_1074
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1078:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1140
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%r15, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1155
	addq	%rax, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_1074
	movq	0(%rbp), %rdx
.Lhrdbfw_1073:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rsi, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1078
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_1078
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1140:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1152:
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1153:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C16(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1074:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rsi, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_1156
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_1082
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1082
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_1034
.Lhrdbfw_1082:
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1155:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1140
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1151:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1150:
	call GetLastError
	leaq	.Lhrdbfw_C12(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1154:
	leaq	.Lhrdbfw_C17(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1034
.Lhrdbfw_1072:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1034
.Lhrdbfw_1156:
	call GetLastError
	jmp	.Lhrdbfw_1140
.Lhrdbfw_1149:
	cmpq	$2, %rbx
	je	.Lhrdbfw_1038
	cmpw	$92, 100(%rsp)
	jne	.Lhrdbfw_1038
	jmp	.Lhrdbfw_1065
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
	je	.Lhrdbfw_1158
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_1158:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1161
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1161
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_1163
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
.Lhrdbfw_1165:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_1175
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1161:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1163:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1166
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1175:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1166:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_1165
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
	je	.Lhrdbfw_1178
	testl	%edx, %edx
	je	.Lhrdbfw_1180
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1180
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1180:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1178:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1181
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1183
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_1183:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1181:
	ret
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C21:

.byte 39,32,99,111,110,116,101,110,116,32,105,115,32,110,111,116,32,118,97,108,105,100,32,102,111,114,32,105,116,115,32,116,121,112,101,0
	.align 8
.Lhrdbfw_C22:

.byte 39,32,110,117,109,101,114,105,99,32,99,111,110,116,101,110,116,32,111,118,101,114,102,108,111,119,115,32,105,110,116,54,52,0
.Lhrdbfw_C23:

.byte 118,101,114,115,105,111,110,32,98,121,116,101,32,48,120,0
	.align 8
.Lhrdbfw_C24:

.byte 32,105,115,32,110,111,116,32,48,120,48,51,32,40,100,66,65,83,69,32,73,73,73,32,116,97,98,108,101,32,119,105,116,104,111,117,116,32,109,101,109,111,59,32,48,120,56,51,47,48,120,70,53,32,99,97,114,114,121,32,97,32,109,101,109,111,32,102,105,108,101,41,0
.Lhrdbfw_C25:

.byte 105,109,112,108,97,117,115,105,98,108,101,32,104,101,97,100,101,114,32,108,101,110,103,116,104,32,0
.Lhrdbfw_C26:

.byte 32,111,114,32,114,101,99,111,114,100,32,108,101,110,103,116,104,32,0
.Lhrdbfw_C27:

.byte 32,102,111,114,32,102,105,108,101,32,115,105,122,101,32,0
.Lhrdbfw_C28:

.byte 102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,32,0
	.align 8
.Lhrdbfw_C29:

.byte 32,116,114,117,110,99,97,116,101,100,32,98,101,102,111,114,101,32,101,110,100,32,111,102,32,104,101,97,100,101,114,0
	.align 8
.Lhrdbfw_C30:

.byte 109,111,114,101,32,116,104,97,110,32,49,50,56,32,102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,0
.Lhrdbfw_C31:

.byte 32,104,97,115,32,97,110,32,101,109,112,116,121,32,110,97,109,101,0
.Lhrdbfw_C32:

.byte 102,105,101,108,100,32,39,0
.Lhrdbfw_C33:

.byte 39,32,104,97,115,32,122,101,114,111,32,119,105,100,116,104,0
.Lhrdbfw_C34:

.byte 67,32,102,105,101,108,100,32,39,0
.Lhrdbfw_C35:

.byte 39,32,100,101,99,108,97,114,101,115,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C36:

.byte 78,32,102,105,101,108,100,32,39,0
.Lhrdbfw_C37:

.byte 39,32,119,105,100,116,104,32,0
.Lhrdbfw_C38:

.byte 32,47,32,100,101,99,105,109,97,108,115,32,0
.Lhrdbfw_C39:

.byte 32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,0
.Lhrdbfw_C40:

.byte 76,32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C41:

.byte 39,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,49,32,119,105,116,104,32,110,111,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C42:

.byte 68,32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C43:

.byte 39,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,56,32,119,105,116,104,32,110,111,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C44:

.byte 39,32,104,97,115,32,117,110,115,117,112,112,111,114,116,101,100,32,116,121,112,101,32,39,0
.Lhrdbfw_C45:

.byte 39,32,40,111,110,108,121,32,67,47,78,47,68,47,76,44,32,110,111,32,109,101,109,111,41,0
	.align 8
.Lhrdbfw_C46:

.byte 102,105,101,108,100,32,119,105,100,116,104,115,32,101,120,99,101,101,100,32,116,104,101,32,54,53,53,51,53,32,114,101,99,111,114,100,32,108,105,109,105,116,0
	.align 8
.Lhrdbfw_C47:

.byte 102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,32,110,111,116,32,116,101,114,109,105,110,97,116,101,100,32,98,121,32,48,120,48,68,0
.Lhrdbfw_C48:

.byte 116,97,98,108,101,32,100,101,99,108,97,114,101,115,32,110,111,32,102,105,101,108,100,115,0
	.align 8
.Lhrdbfw_C49:

.byte 102,105,101,108,100,32,119,105,100,116,104,115,32,112,108,117,115,32,100,101,108,101,116,101,32,102,108,97,103,32,115,117,109,32,116,111,32,0
.Lhrdbfw_C50:

.byte 32,98,117,116,32,104,101,97,100,101,114,32,114,101,99,111,114,100,32,108,101,110,103,116,104,32,105,115,32,0
	.align 8
.Lhrdbfw_C51:

.byte 110,111,110,122,101,114,111,32,98,121,116,101,32,98,101,116,119,101,101,110,32,102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,32,97,110,100,32,104,101,97,100,101,114,32,101,110,100,0
.Lhrdbfw_C52:

.byte 104,101,97,100,101,114,32,114,101,99,111,114,100,32,99,111,117,110,116,32,0
.Lhrdbfw_C53:

.byte 32,101,120,99,101,101,100,115,32,116,104,101,32,0
.Lhrdbfw_C54:

.byte 32,114,101,99,111,114,100,115,32,112,104,121,115,105,99,97,108,108,121,32,112,114,101,115,101,110,116,0
	.align 8
.Lhrdbfw_C55:

.byte 117,110,101,120,112,101,99,116,101,100,32,116,114,97,105,108,105,110,103,32,98,121,116,101,115,32,97,102,116,101,114,32,116,104,101,32,108,97,115,116,32,114,101,99,111,114,100,32,40,110,111,32,48,120,49,65,32,116,101,114,109,105,110,97,116,111,114,41,0
.Lhrdbfw_C56:

.byte 114,101,99,111,114,100,32,0
.Lhrdbfw_C57:

.byte 32,104,97,115,32,100,101,108,101,116,101,32,102,108,97,103,32,48,120,0
.Lhrdbfw_C58:

.byte 32,40,101,120,112,101,99,116,101,100,32,115,112,97,99,101,32,111,114,32,39,42,39,41,0
.Lhrdbfw_C59:

.byte 32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C60:

.byte 32,40,108,111,103,105,99,97,108,32,98,121,116,101,32,109,117,115,116,32,98,101,32,84,47,70,47,89,47,78,47,63,47,115,112,97,99,101,41,0
.Lhrdbfw_C61:

.byte 32,105,110,115,105,100,101,32,97,32,100,101,108,101,116,101,100,32,114,101,99,111,114,100,0
.Lhrdbfw_C62:

.byte 100,117,112,108,105,99,97,116,101,32,102,105,101,108,100,32,110,97,109,101,32,39,0
.Lhrdbfw_C63:

.byte 39,0
	.text
	.p2align 4
	.globl	hrdbf_open
hrdbf_open:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$2376, %rsp
	movb	$0, 2090(%rcx)
	movb	$0, 2202(%rsp)
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	$0, 112(%rsp)
	movq	$0, 120(%rsp)
	movl	$0, 128(%rsp)
	movq	$0, 136(%rsp)
	movl	$16842752, 148(%rsp)
	movb	$0, 152(%rsp)
	cmpq	$32, %r8
	jbe	.Lhrdbfw_1271
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_1272
	movzwl	10(%rdx), %esi
	movl	4(%rdx), %edi
	movq	%r8, %r13
	movzwl	8(%rdx), %eax
	movl	%esi, 52(%rsp)
	movw	%ax, 144(%rsp)
	movw	%si, 146(%rsp)
	movl	%edi, 48(%rsp)
	movl	%edi, 128(%rsp)
	cmpw	$32, %ax
	jbe	.Lhrdbfw_1190
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.Lhrdbfw_1191
.Lhrdbfw_1190:
	leaq	.Lhrdbfw_C25(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	144(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C26(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C27(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
.Lhrdbfw_1186:
	addq	$2376, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbfw_1191:
	movq	32(%rsp), %rdi
	leaq	112(%rsp), %rax
	leaq	32(%rbx), %r8
	movl	$0, 40(%rsp)
	movq	%rax, 56(%rsp)
	movq	%rax, %rsi
	xorl	%r11d, %r11d
	leaq	155(%rsp), %r14
	leaq	-33(%rdi), %rax
	movq	%rbx, 2456(%rsp)
	leaq	165(%rsp), %rcx
	movl	$1, %r15d
	shrq	$5, %rax
	addq	$2, %rax
	movq	%rax, 72(%rsp)
	leaq	-32(%rdi), %rax
	shrq	$5, %rax
	addq	$1, %rax
	movq	%rax, 64(%rsp)
	movl	$1, %eax
	movl	%eax, %ebx
.Lhrdbfw_1217:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.Lhrdbfw_1273
	cmpq	%r15, 64(%rsp)
	je	.Lhrdbfw_1274
	cmpq	$129, %r15
	je	.Lhrdbfw_1275
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1201
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1276:
	movzbl	(%r8,%rax), %r10d
.Lhrdbfw_1201:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1276
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_1202
	cmpl	$1, %r15d
	jbe	.Lhrdbfw_1203
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1204:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1278:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_1207:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.Lhrdbfw_1277
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1278
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C62(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C63(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1277:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.Lhrdbfw_1204
.Lhrdbfw_1203:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.Lhrdbfw_1279
	cmpb	$67, %dl
	je	.Lhrdbfw_1280
	cmpb	$78, %dl
	je	.Lhrdbfw_1281
	cmpb	$76, %dl
	je	.Lhrdbfw_1282
	cmpb	$68, %dl
	jne	.Lhrdbfw_1214
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.Lhrdbfw_1210
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C42(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C43(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1271:
	leaq	.Lhrdbfw_C14(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1272:
	leaq	.Lhrdbfw_C23(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C24(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1280:
	testb	%r9b, %r9b
	jne	.Lhrdbfw_1283
.Lhrdbfw_1210:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_1284
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.Lhrdbfw_1217
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1281:
	cmpb	$17, %r9b
	ja	.Lhrdbfw_1238
	cmpb	%r9b, %al
	ja	.Lhrdbfw_1210
.Lhrdbfw_1238:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C36(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movslq	40(%rsp), %rbx
	movq	56(%rsp), %rdi
	movq	%r12, %rcx
	leal	2(%rbx), %eax
	addq	$2, %rbx
	cltq
	salq	$4, %rbx
	salq	$4, %rax
	leaq	10(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C37(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	134(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C38(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	135(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C39(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$4, %eax
	jmp	.Lhrdbfw_1186
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1282:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.Lhrdbfw_1210
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C40(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C41(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1274:
	testb	%dl, %dl
	je	.Lhrdbfw_1197
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1197:
	leaq	.Lhrdbfw_C28(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	148(%rsp), %eax
	movq	%r12, %rcx
	leaq	1(%rax), %rdx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C29(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1275:
	testb	%dl, %dl
	je	.Lhrdbfw_1199
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1199:
	leaq	.Lhrdbfw_C30(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1273:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.Lhrdbfw_1193
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1193:
	cmpw	$0, 148(%rsp)
	je	.Lhrdbfw_1285
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.Lhrdbfw_1219
	jmp	.Lhrdbfw_1286
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1220:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.Lhrdbfw_1287
.Lhrdbfw_1219:
	cmpq	%r9, 32(%rsp)
	ja	.Lhrdbfw_1220
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1288
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_1222
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_1223
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_1222
.Lhrdbfw_1223:
	leaq	.Lhrdbfw_C55(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1202:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C28(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movzwl	148(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C31(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1279:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C32(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C33(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1287:
	leaq	.Lhrdbfw_C51(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1284:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C46(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1283:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C34(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C35(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1286:
	leaq	.Lhrdbfw_C49(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	%edi, %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C50(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1285:
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1214:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C32(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	40(%rsp), %ebx
	movq	56(%rsp), %rdi
	movq	%r12, %rcx
	leal	2(%rbx), %eax
	cltq
	salq	$4, %rax
	leaq	10(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C44(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movslq	%ebx, %rax
	movq	%r12, %rcx
	movb	$0, 81(%rsp)
	salq	$4, %rax
	movzbl	165(%rsp,%rax), %eax
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	leaq	80(%rsp), %rdx
	movb	%al, 80(%rsp)
	call	hrdbfw_local_dcat
	leaq	.Lhrdbfw_C45(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1222:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.Lhrdbfw_1235
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.Lhrdbfw_1227:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_1225
	cmpb	$42, %dil
	jne	.Lhrdbfw_1289
.Lhrdbfw_1225:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.Lhrdbfw_1226
	jmp	.Lhrdbfw_1233
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1229:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1290
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_1233
.Lhrdbfw_1226:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.Lhrdbfw_1229
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	leal	-1(%rsi), %ebx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C59(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	leal	1(%rsi), %eax
	movq	56(%rsp), %rsi
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	10(%rsi,%rax), %rdx
	call	hrdbfw_local_dname
	movl	$6, %eax
	leaq	.Lhrdbfw_C21(%rip), %rdx
.Lhrdbfw_1230:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.Lhrdbfw_1291
.Lhrdbfw_1232:
	cmpb	$42, %dil
	jne	.Lhrdbfw_1186
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1233:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_1227
	cmpb	$0, 152(%rsp)
	je	.Lhrdbfw_1234
.Lhrdbfw_1224:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.Lhrdbfw_1234:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1291:
	leaq	.Lhrdbfw_C60(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1232
.Lhrdbfw_1288:
	leaq	.Lhrdbfw_C52(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	128(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C53(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	144(%rsp), %edx
	movzwl	146(%rsp), %ecx
	movq	%r13, %rax
	subq	%rdx, %rax
	xorl	%edx, %edx
	divq	%rcx
	movq	%r12, %rcx
	movq	%rax, %rdx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C54(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1289:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C57(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	%dil, %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C58(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$5, %eax
	jmp	.Lhrdbfw_1186
.Lhrdbfw_1235:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1224
.Lhrdbfw_1290:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	leal	-1(%rsi), %ebx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C59(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	56(%rsp), %rax
	leal	1(%rsi), %edx
	movq	%r12, %rcx
	salq	$4, %rdx
	leaq	10(%rax,%rdx), %rdx
	call	hrdbfw_local_dname
	movl	40(%rsp), %eax
	leaq	.Lhrdbfw_C21(%rip), %rdx
	leaq	.Lhrdbfw_C22(%rip), %rcx
	cmpl	$4, %eax
	cmove	%rcx, %rdx
	jmp	.Lhrdbfw_1230
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
	ja	.Lhrdbfw_1294
	je	.Lhrdbfw_1325
	cmpl	$5, %edx
	je	.Lhrdbfw_1298
	shrq	$8, %rax
	jne	.Lhrdbfw_1294
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_1294
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_1294
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1294
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_1294
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
	ja	.Lhrdbfw_1312
	testq	%rcx, %rcx
	je	.Lhrdbfw_1312
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_1326
.Lhrdbfw_1300:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_1294:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1325:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_1294
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_1294
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_1312
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_1312
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1294
.Lhrdbfw_1312:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1298:
	testq	%rax, %rax
	jns	.Lhrdbfw_1307
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1294
.Lhrdbfw_1307:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1326:
	testb	$3, %r9b
	jne	.Lhrdbfw_1300
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_1301
	addl	$1, %eax
	jmp	.Lhrdbfw_1300
.Lhrdbfw_1301:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_1300
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_1327
	leaq	hrdbfw_local_CSWTCH.302(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_1327:
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
	jne	.Lhrdbfw_1332
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_1343
	testl	%edx, %edx
	je	.Lhrdbfw_1335
	cmpl	$9, %edx
	je	.Lhrdbfw_1335
	movl	$1, %eax
.Lhrdbfw_1332:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1343:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1344
.Lhrdbfw_1335:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1344:
	movl	$2, %eax
	jmp	.Lhrdbfw_1332
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
	jne	.Lhrdbfw_1345
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1345
	movzbl	%bl, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %bl
	jne	.Lhrdbfw_1347
	cmpl	$11, %r14d
	jne	.Lhrdbfw_1347
.Lhrdbfw_1360:
	xorl	%edx, %edx
	cmpq	%r12, %rsi
	sete	%dl
	movl	%edx, 0(%r13)
.Lhrdbfw_1345:
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
.Lhrdbfw_1347:
	cmpl	$1, %r15d
	je	.Lhrdbfw_1363
	cmpl	$1, %r14d
	je	.Lhrdbfw_1363
	cmpl	$3, %r15d
	jne	.Lhrdbfw_1350
	cmpl	$3, %r14d
	jne	.Lhrdbfw_1350
	testq	%rsi, %rsi
	sete	%dl
	testq	%r12, %r12
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_1345
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1363:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_1345
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1350:
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1345
	cmpl	$12, %r15d
	je	.Lhrdbfw_1386
	testl	%r15d, %r15d
	je	.Lhrdbfw_1353
	movl	$1, %eax
	cmpl	$9, %r15d
	jne	.Lhrdbfw_1345
.Lhrdbfw_1353:
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1345
	cmpl	$12, %r14d
	je	.Lhrdbfw_1387
	testl	%r14d, %r14d
	je	.Lhrdbfw_1360
	cmpl	$9, %r14d
	je	.Lhrdbfw_1360
	movl	$1, %eax
	jmp	.Lhrdbfw_1345
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1386:
	andb	$-1, %bh
	je	.Lhrdbfw_1353
.Lhrdbfw_1359:
	movl	$2, %eax
	jmp	.Lhrdbfw_1345
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1387:
	testl	$65280, %edi
	je	.Lhrdbfw_1360
	jmp	.Lhrdbfw_1359
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
	jne	.Lhrdbfw_1388
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_1393
	leaq	.Lhrdbfw_1391(%rip), %rcx
	movslq	(%rcx,%rdx,4), %rdx
	addq	%rcx, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1391:
	.long	.Lhrdbfw_1390-.Lhrdbfw_1391
	.long	.Lhrdbfw_1392-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1390-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1390-.Lhrdbfw_1391
	.long	.Lhrdbfw_1393-.Lhrdbfw_1391
	.long	.Lhrdbfw_1390-.Lhrdbfw_1391
	.long	.Lhrdbfw_1390-.Lhrdbfw_1391
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1393:
	movl	$1, %eax
.Lhrdbfw_1388:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1390:
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
.Lhrdbfw_1392:
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
	jne	.Lhrdbfw_1395
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_1442
	cmpl	$12, %eax
	jne	.Lhrdbfw_1421
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
.Lhrdbfw_1403:
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
	ja	.Lhrdbfw_1403
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_1443
	movl	$1, %r9d
.Lhrdbfw_1404:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_1405:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_1406
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_1444
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_1414
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1413:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_1413
.Lhrdbfw_1414:
	testq	%r13, %r13
	jns	.Lhrdbfw_1412
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_1412:
	testl	%r9d, %r9d
	je	.Lhrdbfw_1415
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_1417
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1425:
	movl	%edx, %eax
.Lhrdbfw_1417:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1416
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1416:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_1425
	addl	%r9d, %r10d
.Lhrdbfw_1415:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1395
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1419:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1418
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1418:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_1419
.Lhrdbfw_1395:
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
.Lhrdbfw_1442:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_1406
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_1401
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
	jmp	.Lhrdbfw_1395
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1421:
	movl	$1, %r12d
	jmp	.Lhrdbfw_1395
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1445:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_1420
.Lhrdbfw_1400:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_1395
.Lhrdbfw_1401:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1445
.Lhrdbfw_1420:
	movl	$47, %eax
	jmp	.Lhrdbfw_1400
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1443:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1404
	movl	%r9d, %eax
	jmp	.Lhrdbfw_1405
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1406:
	movl	$3, %r12d
	jmp	.Lhrdbfw_1395
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1444:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1395
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1409:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_1409
	jmp	.Lhrdbfw_1395
	.section .rdata,"dr"
.Lhrdbfw_C64:

.byte 68,66,70,32,117,110,107,110,111,119,110,32,118,97,108,117,101,32,101,114,114,111,114,0
.Lhrdbfw_C65:

.byte 111,107,0
	.align 8
.Lhrdbfw_C66:

.byte 68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,0
	.align 8
.Lhrdbfw_C67:

.byte 68,66,70,32,118,97,108,117,101,32,111,117,116,112,117,116,32,98,117,102,102,101,114,32,116,111,111,32,115,104,111,114,116,0
	.align 8
.Lhrdbfw_C68:

.byte 68,66,70,32,118,97,108,117,101,32,116,97,103,32,111,114,32,109,101,116,97,100,97,116,97,32,105,110,118,97,108,105,100,0
	.align 8
.Lhrdbfw_C69:

.byte 68,66,70,32,118,97,108,117,101,32,116,121,112,101,32,111,117,116,115,105,100,101,32,97,100,109,105,116,116,101,100,32,111,112,101,114,97,116,105,111,110,0
	.text
	.p2align 4
	.globl	hrv_error_name
hrv_error_name:
	cmpl	$4, %ecx
	ja	.Lhrdbfw_1447
	leaq	.Lhrdbfw_1449(%rip), %rdx
	movl	%ecx, %ecx
	movslq	(%rdx,%rcx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1449:
	.long	.Lhrdbfw_1454-.Lhrdbfw_1449
	.long	.Lhrdbfw_1452-.Lhrdbfw_1449
	.long	.Lhrdbfw_1451-.Lhrdbfw_1449
	.long	.Lhrdbfw_1450-.Lhrdbfw_1449
	.long	.Lhrdbfw_1448-.Lhrdbfw_1449
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1452:
	leaq	.Lhrdbfw_C69(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1454:
	leaq	.Lhrdbfw_C65(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1448:
	leaq	.Lhrdbfw_C68(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1451:
	leaq	.Lhrdbfw_C66(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1450:
	leaq	.Lhrdbfw_C67(%rip), %rax
	ret
.Lhrdbfw_1447:
	leaq	.Lhrdbfw_C64(%rip), %rax
	ret
	.p2align 4
	.globl	hrdbf_fmt_fixed
hrdbf_fmt_fixed:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$920, %rsp
	movl	%edx, 1000(%rsp)
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1458
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.Lhrdbfw_1458
	movabs	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.Lhrdbfw_1553
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.Lhrdbfw_1462:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.Lhrdbfw_1469
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1468:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1470:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_1470
	testq	%rax, %rax
	je	.Lhrdbfw_1471
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.Lhrdbfw_1471:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.Lhrdbfw_1468
	testb	%r12b, %r12b
	je	.Lhrdbfw_1469
	movl	%r9d, 544(%rsp)
.Lhrdbfw_1469:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.Lhrdbfw_1474
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shl
	movl	544(%rsp), %edi
.Lhrdbfw_1475:
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_1481
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1482:
	cmpq	$48, %r12
	je	.Lhrdbfw_1554
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbfw_1481:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.Lhrdbfw_1482
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1482
	testl	%r12d, %r12d
	jne	.Lhrdbfw_1555
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.Lhrdbfw_1487:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.Lhrdbfw_1490
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1556:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.Lhrdbfw_1490:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1556
	testl	%r13d, %r13d
	je	.Lhrdbfw_1491
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1493:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1492:
	movl	%edx, %eax
	movl	%ecx, %r8d
	subl	$1, %ecx
	imulq	%r9, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %r11d
	addl	%r11d, %r11d
	subl	%r11d, %edx
	addl	$48, %edx
	movb	%dl, 560(%rsp,%r8)
	movl	%eax, %edx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_1492
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbfw_1557
	movq	%rax, %r12
	jmp	.Lhrdbfw_1493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1458:
	xorl	%eax, %eax
.Lhrdbfw_1455:
	addq	$920, %rsp
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
.Lhrdbfw_1553:
	testq	%rax, %rax
	jne	.Lhrdbfw_1558
	cmpq	$0, 40(%rsp)
	jne	.Lhrdbfw_1559
	xorl	%edx, %edx
.Lhrdbfw_1463:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1464
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.Lhrdbfw_1458
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1466:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.Lhrdbfw_1466
	addl	%ebx, %eax
	jmp	.Lhrdbfw_1455
.Lhrdbfw_1559:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1458
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.Lhrdbfw_1463
.Lhrdbfw_1474:
	negl	%edx
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.Lhrdbfw_1560
	cmpl	$2, %eax
	jne	.Lhrdbfw_1475
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.Lhrdbfw_1475
	testl	%edi, %edi
	je	.Lhrdbfw_1508
.Lhrdbfw_1478:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.Lhrdbfw_1480
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1561:
	movl	(%rcx), %edx
.Lhrdbfw_1480:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.Lhrdbfw_1561
	testq	%rax, %rax
	je	.Lhrdbfw_1475
	movl	%edi, %eax
	addl	$1, %edi
.Lhrdbfw_1477:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.Lhrdbfw_1475
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1557:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.Lhrdbfw_1491:
	movl	%edi, %eax
	movl	$1, %edx
	movq	40(%rsp), %r15
	movl	$0, %ecx
	subl	%ebx, %eax
	cmpl	%edi, %ebx
	cmovnb	%edx, %eax
	testl	%ebx, %ebx
	leal	1(%rbx), %edx
	cmovne	%edx, %ecx
	movl	%r15d, %edx
	addl	%eax, %edx
	addl	%ecx, %edx
	cmpl	1000(%rsp), %edx
	ja	.Lhrdbfw_1458
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.Lhrdbfw_1496
	movb	$45, (%rsi)
	movl	$1, %edx
.Lhrdbfw_1496:
	cmpl	%edi, %ebx
	jnb	.Lhrdbfw_1497
	testl	%eax, %eax
	je	.Lhrdbfw_1513
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1499:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1499
.Lhrdbfw_1498:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1455
.Lhrdbfw_1500:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.Lhrdbfw_1501
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1502:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_1502
	addl	%ebx, %edx
.Lhrdbfw_1501:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1503:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1503
	jmp	.Lhrdbfw_1455
.Lhrdbfw_1554:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.Lhrdbfw_1485:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1488:
	movl	%r8d, %eax
	movl	%r8d, %edx
	movl	%r9d, %edi
	imulq	%r10, %rax
	shrq	$35, %rax
	leal	(%rax,%rax,4), %ecx
	addl	%ecx, %ecx
	subl	%ecx, %edx
	movl	%r8d, %ecx
	movl	%eax, %r8d
	addl	$48, %edx
	movb	%dl, (%r11,%r9)
	addq	$1, %r9
	cmpl	$9, %ecx
	ja	.Lhrdbfw_1488
	jmp	.Lhrdbfw_1487
.Lhrdbfw_1558:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.Lhrdbfw_1462
.Lhrdbfw_1464:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.Lhrdbfw_1458
	movb	$48, (%rsi,%rdx)
	jmp	.Lhrdbfw_1455
.Lhrdbfw_1497:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbfw_1500
.Lhrdbfw_1560:
	testl	%edi, %edi
	je	.Lhrdbfw_1507
	movl	256(%rsp), %edx
	jmp	.Lhrdbfw_1478
.Lhrdbfw_1513:
	movl	%edx, %eax
	jmp	.Lhrdbfw_1498
.Lhrdbfw_1508:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.Lhrdbfw_1477
.Lhrdbfw_1507:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.Lhrdbfw_1477
.Lhrdbfw_1555:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.Lhrdbfw_1485
	.p2align 4
	.globl	hrdbf_fmt_harbour
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1563
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1563:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1564
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.Lhrdbfw_1566
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1567:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrdbfw_1567
	movzbl	12(%rdx), %eax
.Lhrdbfw_1566:
	cmpq	%rax, %r9
	jnb	.Lhrdbfw_1569
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1568:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1568
.Lhrdbfw_1569:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1564:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1578
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1578:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1580
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1580:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.Lhrdbfw_1601
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.Lhrdbfw_1604
	movl	%r8d, %r9d
	movl	%r8d, %r11d
	imulq	$1374389535, %r9, %rdx
	shrq	$37, %rdx
	movl	%edx, %eax
	imulq	$1374389535, %rax, %rax
	shrq	$37, %rax
	imull	$100, %eax, %r10d
	movl	%edx, %eax
	imull	$100, %edx, %edx
	subl	%r10d, %eax
	movl	$5, %r10d
	subl	%edx, %r11d
	leal	-1(%rax), %edx
	cmpl	$11, %edx
	ja	.Lhrdbfw_1601
	cmpl	$9999, %r8d
	jbe	.Lhrdbfw_1601
	testl	%r11d, %r11d
	je	.Lhrdbfw_1601
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.Lhrdbfw_1585
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.Lhrdbfw_1587
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.Lhrdbfw_1587:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.Lhrdbfw_1581
	imulq	$1801439851, %r9, %r9
	movl	$3435973837, %r10d
	shrq	$54, %r9
	movl	%r9d, %edx
	imulq	%r10, %rdx
	shrq	$35, %rdx
	leal	(%rdx,%rdx,4), %edx
	addl	%edx, %edx
	subl	%edx, %r9d
	movl	%ebx, %edx
	imulq	$1374389535, %rdx, %r8
	addl	$48, %r9d
	movb	%r9b, (%rcx)
	imulq	%r10, %rdx
	shrq	$37, %r8
	movl	%r8d, %r9d
	shrq	$35, %rdx
	imulq	%r10, %r9
	shrq	$35, %r9
	leal	(%r9,%r9,4), %r9d
	addl	%r9d, %r9d
	subl	%r9d, %r8d
	addl	$48, %r8d
	movb	%r8b, 1(%rcx)
	movl	%edx, %r8d
	imulq	%r10, %r8
	shrq	$35, %r8
	leal	(%r8,%r8,4), %r9d
	movl	%edx, %r8d
	leal	(%rdx,%rdx,4), %edx
	addl	%edx, %edx
	addl	%r9d, %r9d
	subl	%edx, %ebx
	movl	%eax, %edx
	subl	%r9d, %r8d
	imulq	%r10, %rdx
	addl	$48, %r8d
	addl	$48, %ebx
	movb	%r8b, 2(%rcx)
	movb	%bl, 3(%rcx)
	shrq	$35, %rdx
	leal	48(%rdx), %r8d
	leal	(%rdx,%rdx,4), %edx
	addl	%edx, %edx
	movb	%r8b, 4(%rcx)
	subl	%edx, %eax
	addl	$48, %eax
	movb	%al, 5(%rcx)
	movl	%r11d, %eax
	imulq	%r10, %rax
	shrq	$35, %rax
	leal	48(%rax), %edx
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movb	%dl, 6(%rcx)
	subl	%eax, %r11d
	xorl	%r10d, %r10d
	addl	$48, %r11d
	movb	%r11b, 7(%rcx)
.Lhrdbfw_1581:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1604:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1584:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1584
	xorl	%r10d, %r10d
.Lhrdbfw_1601:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1585:
	movl	$28, %edx
	testb	$3, %bl
	jne	.Lhrdbfw_1587
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.Lhrdbfw_1587
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.Lhrdbfw_1587
	.p2align 4
	.globl	hrdbf_write_logical
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1605
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1605:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.Lhrdbfw_1617
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbfw_1616
.Lhrdbfw_1617:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1615
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1614:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1614
.Lhrdbfw_1615:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1616:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_deleted
hrdbf_write_deleted:
	cmpb	$1, %dl
	sbbl	%eax, %eax
	andl	$-10, %eax
	addl	$42, %eax
	movb	%al, (%rcx)
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
	movl	$0, 2272(%rcx)
	movq	2280(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1628
	movq	$0, 2280(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1635
.Lhrdbfw_1628:
	xorl	%r12d, %r12d
.Lhrdbfw_1627:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1625
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1630
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.Lhrdbfw_1625:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1635:
	movl	$7, %r12d
	jmp	.Lhrdbfw_1627
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1630:
	movl	$7, %r12d
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
hrdbf_file_open.part.0:
	pushq	%r13
	xorl	%eax, %eax
	pushq	%r12
	movq	%rcx, %r12
	movq	%rdx, %rcx
	leaq	2280(%r12), %r9
	leaq	2256(%r12), %rdx
	subq	$72, %rsp
	testl	%r8d, %r8d
	movb	$0, hrdbfw_local_fsink(%rip)
	setne	%al
	movl	%r8d, 48(%rsp)
	leaq	2264(%r12), %r8
	movb	$0, 2288(%r12)
	movl	%eax, 2272(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.Lhrdbfw_1637
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	2288(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_1638
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1640:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_1639
.Lhrdbfw_1638:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1640
.Lhrdbfw_1639:
	movb	$0, (%rdx)
.Lhrdbfw_1642:
	movq	%r12, %rcx
	call	hrdbf_file_close
	testl	%eax, %eax
	cmovne	%eax, %r13d
	addq	$72, %rsp
	popq	%r12
	movl	%r13d, %eax
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1637:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_1642
	addq	$72, %rsp
	movl	%r13d, %eax
	popq	%r12
	popq	%r13
	ret
	.p2align 4
hrdbf_app_exit:
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_close
	movl	$1, %ecx
	call ExitProcess
	.p2align 4
hrdbf_app_fail:
	subq	$40, %rsp
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C70:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C71:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,115,116,114,105,110,103,32,97,108,108,111,99,97,116,105,111,110,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
hrdbfw_app_get_ord.part.0:
	pushq	%r12
	movl	$85, %eax
	pushq	%rbx
	subq	$328, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	movb	$0, 60(%rsp)
	movw	%ax, 32(%rsp)
	movb	$0, 34(%rsp)
	movq	$0, 40(%rsp)
	movq	$0, 48(%rsp)
	movl	$0, 56(%rsp)
	je	.Lhrdbfw_1653
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1663
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1653
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1667
	cmpb	$78, %al
	je	.Lhrdbfw_1668
	cmpb	$68, %al
	je	.Lhrdbfw_1662
	movzbl	60(%rsp), %eax
.Lhrdbfw_1652:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1667:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1669
.Lhrdbfw_1655:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1670
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1653:
	leaq	.Lhrdbfw_C70(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1663:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1652
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1668:
	movzbl	34(%rsp), %eax
	movzbl	33(%rsp), %edx
	salq	$8, %rax
	salq	$16, %rdx
	orq	%rdx, %rax
	orq	$12, %rax
	movq	%rax, (%r12)
	movq	48(%rsp), %rax
	movq	%rax, 8(%r12)
	addq	$328, %rsp
	movq	%r12, %rax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1662:
	movl	56(%rsp), %eax
	movq	$11, (%r12)
	movq	%rax, 8(%r12)
	addq	$328, %rsp
	movq	%r12, %rax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1669:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1658
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1657:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1657
.Lhrdbfw_1658:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1655
.Lhrdbfw_1670:
	leaq	.Lhrdbfw_C71(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C72:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C73:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C74:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbfw_C75:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,110,111,32,114,101,99,111,114,100,32,112,111,115,105,116,105,111,110,101,100,10,0
	.text
	.p2align 4
hrdbf_app_require_writable:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1677
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1678
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1679
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_1680
	addq	$40, %rsp
	ret
.Lhrdbfw_1677:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1680:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1679:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1678:
	leaq	.Lhrdbfw_C73(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C76:

.byte 10,0
	.text
	.p2align 4
hrdbfw_app_field_missing:
	pushq	%r12
	movq	%rcx, %r12
	movl	$-12, %ecx
	pushq	%rbp
	movq	%rdx, %rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$64, %rsp
	leaq GetStdHandle(%rip), %rdi
	call	*%rdi
	leaq	60(%rsp), %rsi
	leaq WriteFile(%rip), %rbx
	movl	$43, %r8d
	movq	%rsi, %r9
	leaq	hrdbf_app_pre_field(%rip), %rdx
	movq	%rax, %rcx
	movq	$0, 32(%rsp)
	call	*%rbx
	movl	$-12, %ecx
	call	*%rdi
	movq	%rsi, %r9
	movl	%ebp, %r8d
	movq	%r12, %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*%rbx
	movl	$-12, %ecx
	call	*%rdi
	movq	%rsi, %r9
	movl	$1, %r8d
	leaq	.Lhrdbfw_C76(%rip), %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*%rbx
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
	pushq	%rbx
	movl	%r8d, %ebx
	subq	$32, %rsp
	movb	$0, 2288(%rcx)
	movb	$0, hrdbfw_local_fsink(%rip)
	movq	$0, 8(%rcx)
	movq	$0, (%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movl	$0, 2272(%rcx)
	movq	2280(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1703
	movq	$0, 2280(%r12)
	call CloseHandle
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1687
	testq	%rcx, %rcx
	je	.Lhrdbfw_1683
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1683
	movq	$0, 2256(%r12)
	movl	$7, %eax
	movq	$0, 2264(%r12)
	addq	$32, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1687:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1686
.Lhrdbfw_1685:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1701
.Lhrdbfw_1683:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1703:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1685
.Lhrdbfw_1686:
	addq	$32, %rsp
	movl	%ebx, %r8d
	movq	%r13, %rdx
	movq	%r12, %rcx
	popq	%rbx
	popq	%r12
	popq	%r13
	jmp	hrdbf_file_open.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1701:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.Lhrdbfw_1686
	.p2align 4
	.globl	hrdbf_file_write_record
hrdbf_file_write_record:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1708
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1708
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1708
	testq	%rdx, %rdx
	je	.Lhrdbfw_1709
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.Lhrdbfw_1711
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1708:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1709:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1711:
	movzwl	34(%rcx), %r9d
	subq	$1, %rdx
	movzwl	32(%rcx), %eax
	movq	2256(%rcx), %r8
	imulq	%r9, %rdx
	addq	%rax, %rdx
	addq	%rdx, %r8
	jmp	hrdbfw_local_write_at
	.p2align 4
	.globl	hrdbf_file_append
hrdbf_file_append:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1712
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1712
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1712
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1712:
	movl	$6, %eax
	ret
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
	je	.Lhrdbfw_1719
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1724:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1737
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1723
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1721:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1737
.Lhrdbfw_1723:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1721
	jnb	.Lhrdbfw_1737
	leal	1(%r10), %r11d
.Lhrdbfw_1720:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1724
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1728
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1727:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1729
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1730
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1762:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1729
.Lhrdbfw_1730:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1762
.Lhrdbfw_1728:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1718
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1763
	movl	%r11d, %r9d
.Lhrdbfw_1718:
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
.Lhrdbfw_1737:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1720
.Lhrdbfw_1729:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1718
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1731
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1736:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1732
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1735
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1733:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1732
.Lhrdbfw_1735:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1733
	jb	.Lhrdbfw_1732
	movl	%r9d, %r10d
.Lhrdbfw_1734:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1736
.Lhrdbfw_1731:
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
.Lhrdbfw_1732:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1734
.Lhrdbfw_1763:
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
.Lhrdbfw_1719:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1718
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1727
	.section .rdata,"dr"
.Lhrdbfw_C77:

.byte 104,98,99,58,32,68,66,70,47,78,84,88,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_close
hrdbfw_app_close:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	movq	hrdbf_app_state+2280(%rip), %rcx
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	%eax, %ebx
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	movl	$0, hrdbf_app_state+2272(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_1769
	movq	$0, hrdbf_app_state+2280(%rip)
	call CloseHandle
	testl	%eax, %eax
	jne	.Lhrdbfw_1769
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1770
	movl	$7, %esi
	jmp	.Lhrdbfw_1766
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1769:
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1779
.Lhrdbfw_1767:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1772
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1779:
	xorl	%esi, %esi
.Lhrdbfw_1766:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1770
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%esi, %ebx
	movq	$0, hrdbf_app_state+2264(%rip)
	jmp	.Lhrdbfw_1767
.Lhrdbfw_1770:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbfw_1772:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C78:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,0
	.align 8
.Lhrdbfw_C79:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,116,97,98,108,101,32,118,101,114,115,105,111,110,32,111,114,32,104,101,97,100,101,114,32,102,108,97,103,115,0
.Lhrdbfw_C80:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,102,105,101,108,100,32,116,121,112,101,0
.Lhrdbfw_C81:

.byte 114,101,99,111,114,100,32,99,111,110,116,101,110,116,32,105,110,118,97,108,105,100,0
.Lhrdbfw_C82:

.byte 73,47,79,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C83:

.byte 115,105,122,101,32,111,114,32,102,105,101,108,100,45,99,111,117,110,116,32,108,105,109,105,116,32,101,120,99,101,101,100,101,100,0
.Lhrdbfw_C84:

.byte 116,97,98,108,101,32,102,111,114,109,97,116,32,110,111,116,32,115,117,112,112,111,114,116,101,100,0
	.align 8
.Lhrdbfw_C85:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C86:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C87:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C88:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
.Lhrdbfw_C89:

.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,114,101,106,101,99,116,101,100,58,32,0
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
	je	.Lhrdbfw_1781
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_1827
.Lhrdbfw_1781:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_1828
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1782
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1800:
	movq	%rsi, %rbx
.Lhrdbfw_1782:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1829
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_1800
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1830
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movq	$0, hrdbf_app_pos(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1787
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1785:
	cmpq	%rcx, %rbx
	je	.Lhrdbfw_1831
.Lhrdbfw_1787:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.Lhrdbfw_1810
	cmpb	$92, %dl
	jne	.Lhrdbfw_1785
.Lhrdbfw_1810:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.Lhrdbfw_1787
.Lhrdbfw_1831:
	cmpq	%rsi, %r8
	jnb	.Lhrdbfw_1788
	movq	%r8, %rax
	jmp	.Lhrdbfw_1790
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1801:
	movq	%rdx, %rax
.Lhrdbfw_1790:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_1801
.Lhrdbfw_1788:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.Lhrdbfw_1795
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1791:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrdbfw_1791
.Lhrdbfw_1795:
	xorl	%ebx, %ebx
	leaq	hrdbf_app_state(%rip), %rcx
	cmpq	$0, 384(%rsp)
	movb	$0, hrdbf_app_state+2288(%rip)
	setne	%bl
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_1832
.Lhrdbfw_1792:
	leaq	hrdbf_app_state+2288(%rip), %r12
	cmpb	$0, hrdbf_app_state+2288(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_1798
	leaq	.Lhrdbfw_C82(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_1798
	leaq	.Lhrdbfw_C78(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_1798
	leaq	.Lhrdbfw_C83(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_1798
	leaq	.Lhrdbfw_C79(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_1798
	leaq	.Lhrdbfw_C80(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_1798
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C81(%rip), %r12
	leaq	.Lhrdbfw_C84(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_1798:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1832:
	movl	%ebx, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1792
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.Lhrdbfw_1829:
	leaq	.Lhrdbfw_C87(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1828:
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1827:
	leaq	.Lhrdbfw_C85(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1830:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1842
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1843
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1844
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1838:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1844:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbfw_1838
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1843:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1842:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1855
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1856
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_1857
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_1850:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1851:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1857:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_1850
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_1851
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1856:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1855:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1875
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1876
	testq	%rcx, %rcx
	je	.Lhrdbfw_1858
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbfw_1862
	movq	%rax, %r8
	subq	%rdx, %r8
	cmpq	%rcx, %r8
	jb	.Lhrdbfw_1868
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	setnb	%dl
.Lhrdbfw_1863:
	movq	%rcx, hrdbf_app_pos(%rip)
.Lhrdbfw_1864:
	cmpq	%rax, %rcx
	jnb	.Lhrdbfw_1866
.Lhrdbfw_1877:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
.Lhrdbfw_1867:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbfw_1858:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1862:
	movq	%rcx, %r8
	negq	%r8
	cmpq	%rdx, %r8
	jbe	.Lhrdbfw_1865
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_1877
.Lhrdbfw_1866:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_1867
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1868:
	movq	%rax, %rcx
	movl	$1, %edx
	jmp	.Lhrdbfw_1863
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1865:
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	movq	%rcx, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbfw_1864
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1876:
	movq	%rcx, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
.Lhrdbfw_1875:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C90:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C91:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C92:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C93:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C94:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C95:

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
	je	.Lhrdbfw_1952
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1953
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_1954
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.Lhrdbfw_1881
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1883:
	cmpq	%rcx, %r9
	je	.Lhrdbfw_1955
.Lhrdbfw_1919:
	movq	%rcx, %rdx
.Lhrdbfw_1881:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1956
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.Lhrdbfw_1923
	cmpb	$92, %al
	jne	.Lhrdbfw_1883
.Lhrdbfw_1923:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.Lhrdbfw_1919
.Lhrdbfw_1955:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.Lhrdbfw_1885
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.Lhrdbfw_1887
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1920:
	movq	%r11, %rax
.Lhrdbfw_1887:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1920
	testl	%ebx, %ebx
	je	.Lhrdbfw_1891
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.Lhrdbfw_1917
.Lhrdbfw_1892:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1915
.Lhrdbfw_1916:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1897
	testl	%ebx, %ebx
	je	.Lhrdbfw_1899
	leaq	hrdbf_app_order+64(%rip), %r9
	movq	%r12, %rcx
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.Lhrdbfw_1911
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.Lhrdbfw_1910:
	cmpq	$67108864, %rbp
	ja	.Lhrdbfw_1951
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
	je	.Lhrdbfw_1951
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
	je	.Lhrdbfw_1904
	cmpl	$5, %eax
	je	.Lhrdbfw_1905
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1951:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1897
.Lhrdbfw_1906:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	jmp	.Lhrdbfw_1907
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1891:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1890
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1897
.Lhrdbfw_1899:
	leaq	hrdbf_app_order+64(%rip), %r9
	movq	%r12, %rcx
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.Lhrdbfw_1911
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.Lhrdbfw_1910
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1890:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.Lhrdbfw_1914:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.Lhrdbfw_1916
.Lhrdbfw_1885:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1890
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.Lhrdbfw_1957
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1915:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.Lhrdbfw_1914
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1911:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.Lhrdbfw_1897:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_1906
	cmpl	$3, %eax
	je	.Lhrdbfw_1908
	jmp	.Lhrdbfw_1906
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1904:
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
.Lhrdbfw_1957:
	xorl	%r10d, %r10d
.Lhrdbfw_1917:
	testq	%rdi, %rdi
	je	.Lhrdbfw_1893
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1896:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.Lhrdbfw_1896
	testl	%r11d, %r11d
	je	.Lhrdbfw_1892
.Lhrdbfw_1893:
	leaq	.Lhrdbfw_C95(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1905:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1897
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1906
.Lhrdbfw_1908:
	leaq	.Lhrdbfw_C90(%rip), %rcx
.Lhrdbfw_1907:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1956:
	leaq	.Lhrdbfw_C94(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1953:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1952:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1954:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1984
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_1985
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	movq	hrdbf_app_order+32(%rip), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1964
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1986
.Lhrdbfw_1961:
	xorl	%edx, %edx
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1965
	movq	hrdbf_app_order+40(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1966
.Lhrdbfw_1962:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_1966
.Lhrdbfw_1987:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_1967:
	testl	%esi, %esi
	jne	.Lhrdbfw_1966
.Lhrdbfw_1963:
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1964:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1961
.Lhrdbfw_1982:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1963
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1987
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1966:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1985:
	movq	hrdbf_app_order+32(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1961
	jmp	.Lhrdbfw_1982
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1965:
	movq	hrdbf_app_order+40(%rip), %rcx
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1962
	jmp	.Lhrdbfw_1967
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1986:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1962
	jmp	.Lhrdbfw_1966
.Lhrdbfw_1984:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1993
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_1993:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C96:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2000
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2001
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
	jb	.Lhrdbfw_2002
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_1998:
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
.Lhrdbfw_2002:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_1998
.Lhrdbfw_2001:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2000:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2008
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_2008:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2014
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_2014:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2020
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_2020:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2026
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_2026:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2034
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2027
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_2027:
	movq	%r8, %rax
	ret
.Lhrdbfw_2034:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2041
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_2037
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_2038
.Lhrdbfw_2037:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2038:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_2041:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get_name
hrdbfw_app_get_name:
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2043
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_2045
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2057:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2046:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2047
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2046
.Lhrdbfw_2047:
	cmpq	%r8, %rax
	je	.Lhrdbfw_2067
.Lhrdbfw_2049:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.Lhrdbfw_2057
.Lhrdbfw_2045:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2067:
	testq	%r8, %r8
	je	.Lhrdbfw_2050
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2054
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2068:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.Lhrdbfw_2050
.Lhrdbfw_2054:
	movzbl	(%r12,%rcx), %eax
	leal	-97(%rax), %r9d
	leal	-32(%rax), %edx
	cmpb	$26, %r9b
	cmovb	%edx, %eax
	movzbl	(%r10,%rcx), %edx
	leal	-97(%rdx), %r9d
	leal	-32(%rdx), %r11d
	cmpb	$26, %r9b
	cmovb	%r11d, %edx
	cmpb	%al, %dl
	je	.Lhrdbfw_2068
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_2049
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2050:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_2055
	movq	$1, 0(%r13)
	movq	%r13, %rax
	movq	$0, 8(%r13)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_2055:
	movq	%rbp, %r8
	movq	%r13, %rcx
	call	hrdbfw_app_get_ord.part.0
	addq	$40, %rsp
	movq	%r13, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_2043:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C97:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbfw_C98:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbfw_C99:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbfw_C100:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_fieldput
hrdbfw_app_fieldput:
	pushq	%rdi
	movq	%rdx, %rdi
	pushq	%rsi
	movq	%r8, %rsi
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$32, %rsp
	call	hrdbf_app_require_writable
	testq	%rbx, %rbx
	jle	.Lhrdbfw_2070
	movzwl	hrdbf_app_state+36(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r9
	cmpq	%rbx, %rax
	jl	.Lhrdbfw_2070
	movq	hrdbf_app_state+24(%rip), %rdx
	movzwl	hrdbf_app_state+34(%rip), %eax
	leaq	-1(%rbx), %r10
	addq	$1, %rbx
	salq	$4, %rbx
	movzbl	%dil, %r8d
	leaq	-1(%rdx), %rcx
	leaq	10(%r9,%rbx), %r11
	addq	%r9, %rbx
	imulq	%rax, %rcx
	movzwl	hrdbf_app_state+32(%rip), %eax
	addq	%rax, %rcx
	movzbl	21(%rbx), %eax
	addq	hrdbf_app_state+2256(%rip), %rcx
	cmpb	$76, %al
	je	.Lhrdbfw_2072
	ja	.Lhrdbfw_2073
	cmpb	$67, %al
	je	.Lhrdbfw_2074
	cmpb	$68, %al
	jne	.Lhrdbfw_2076
	cmpl	$11, %r8d
	je	.Lhrdbfw_2131
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2076
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2085
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2096
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2132:
	addq	$1, %rax
.Lhrdbfw_2096:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2132
.Lhrdbfw_2081:
	movq	hrdbf_app_state+24(%rip), %rdx
.Lhrdbfw_2085:
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbfw_2133
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2073:
	cmpb	$78, %al
	jne	.Lhrdbfw_2076
	cmpl	$12, %r8d
	je	.Lhrdbfw_2134
	testl	%r8d, %r8d
	je	.Lhrdbfw_2104
	cmpl	$9, %r8d
	je	.Lhrdbfw_2104
	cmpl	$5, %r8d
	je	.Lhrdbfw_2135
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2076
	addq	$2, %r10
	salq	$4, %r10
	addq	%r10, %r9
	movzbl	22(%r9), %r8d
	movzwl	24(%r9), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2085
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2094
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2136:
	addq	$1, %rax
.Lhrdbfw_2094:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2136
	jmp	.Lhrdbfw_2081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2074:
	leal	-2(%r8), %eax
	andl	$-3, %eax
	je	.Lhrdbfw_2137
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2076
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2085
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2086
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2138:
	addq	$1, %rax
.Lhrdbfw_2086:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2138
	jmp	.Lhrdbfw_2081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2072:
	cmpl	$3, %r8d
	je	.Lhrdbfw_2139
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2076
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2085
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2099
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2140:
	addq	$1, %rax
.Lhrdbfw_2099:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2140
	jmp	.Lhrdbfw_2081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2134:
	movl	%edi, %eax
	movq	%rsi, %r8
	movq	%r11, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.Lhrdbfw_2088:
	cmpl	$3, %eax
	je	.Lhrdbfw_2076
	testl	%eax, %eax
	je	.Lhrdbfw_2081
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2139:
	cmpq	$1, %rsi
	movzwl	24(%rbx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	hrdbf_app_state+24(%rip), %rdx
	jmp	.Lhrdbfw_2085
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2137:
	movzwl	24(%rbx), %eax
	movzbl	22(%rbx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%rsi)
	movq	%rdx, %rax
	cmovbe	-8(%rsi), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2079
	movq	%rcx, %r8
	leaq	(%rsi,%rax), %r11
	subq	%rsi, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2080:
	movzbl	(%rsi), %edx
	movb	%dl, (%r8,%rsi)
	addq	$1, %rsi
	cmpq	%r11, %rsi
	jne	.Lhrdbfw_2080
	movq	%r10, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r9), %edx
.Lhrdbfw_2079:
	cmpq	%rax, %rdx
	jbe	.Lhrdbfw_2081
	leaq	2(%r10), %rdx
	salq	$4, %rdx
	addq	%rdx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2082:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r9), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbfw_2082
	jmp	.Lhrdbfw_2081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2131:
	movl	%esi, %r8d
	movq	%r11, %rdx
	call	hrdbf_write_date
	jmp	.Lhrdbfw_2088
.Lhrdbfw_2076:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2104:
	xorl	%r9d, %r9d
	movq	%rsi, %r8
	movq	%r11, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbfw_2088
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2135:
	testq	%rdi, %rdi
	jns	.Lhrdbfw_2092
	movq	(%rsi), %rsi
.Lhrdbfw_2092:
	movq	%rsi, %xmm2
	movq	%r11, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.Lhrdbfw_2088
.Lhrdbfw_2070:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2133:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_set_name
hrdbfw_app_set_name:
	pushq	%r14
	movq	%r8, %r14
	pushq	%r13
	movq	%rcx, %r13
	pushq	%r12
	movq	%rdx, %r12
	pushq	%rsi
	movq	%r9, %rsi
	pushq	%rbx
	subq	$32, %rsp
	call	hrdbf_app_require_writable
	movzwl	hrdbf_app_state+36(%rip), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_2142
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2152:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2143:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2144
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2143
.Lhrdbfw_2144:
	cmpq	%r12, %rax
	je	.Lhrdbfw_2165
.Lhrdbfw_2146:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.Lhrdbfw_2152
.Lhrdbfw_2142:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2165:
	testq	%r12, %r12
	je	.Lhrdbfw_2147
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2151
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2166:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_2147
.Lhrdbfw_2151:
	movzbl	0(%r13,%rcx), %eax
	leal	-97(%rax), %r11d
	leal	-32(%rax), %edx
	cmpb	$26, %r11b
	cmovb	%edx, %eax
	movzbl	(%r10,%rcx), %edx
	leal	-97(%rdx), %r9d
	leal	-32(%rdx), %r11d
	cmpb	$26, %r9b
	cmovb	%r11d, %edx
	cmpb	%al, %dl
	je	.Lhrdbfw_2166
	cmpq	%rcx, %r12
	jne	.Lhrdbfw_2146
.Lhrdbfw_2147:
	addq	$32, %rsp
	leal	1(%r8), %ecx
	movq	%r14, %rdx
	movq	%rsi, %r8
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	jmp	hrdbfw_app_fieldput
	.section .rdata,"dr"
.Lhrdbfw_C101:

.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_append
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2175
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2176
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2177
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_2178
	cmpq	$0, hrdbf_app_state+2280(%rip)
	je	.Lhrdbfw_2173
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2173
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2173:
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2175:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2178:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2177:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2176:
	leaq	.Lhrdbfw_C73(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C102:

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
	jne	.Lhrdbfw_2182
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_2182:
	leaq	.Lhrdbfw_C102(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C103:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C104:

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
	jne	.Lhrdbfw_2184
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_2200
	testl	%eax, %eax
	je	.Lhrdbfw_2192
	cmpl	$9, %eax
	jne	.Lhrdbfw_2188
.Lhrdbfw_2192:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2200:
	testl	$65280, %r11d
	je	.Lhrdbfw_2192
.Lhrdbfw_2187:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2184:
	cmpl	$2, %eax
	je	.Lhrdbfw_2187
.Lhrdbfw_2188:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C105:

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
	je	.Lhrdbfw_2205
	testl	%eax, %eax
	jne	.Lhrdbfw_2206
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_2205:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2206:
	leaq	.Lhrdbfw_C105(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C106:

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
	jne	.Lhrdbfw_2208
	movq	%rcx, 32(%rsp)
	movq	%rdx, 40(%rsp)
	cmpb	$11, %r8b
	je	.Lhrdbfw_2250
	leaq	32(%rsp), %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2214
.Lhrdbfw_2218:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2214:
	cmpl	$2, %eax
	jne	.Lhrdbfw_2218
.Lhrdbfw_2217:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2208:
	leaq	32(%rsp), %r12
	movq	%rcx, 32(%rsp)
	movzbl	%cl, %r13d
	movq	%r12, %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2214
	cmpl	$12, %r13d
	jne	.Lhrdbfw_2215
	testl	$65280, %r11d
	jne	.Lhrdbfw_2217
.Lhrdbfw_2216:
	movq	%r12, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2214
	movzbl	%bl, %eax
	cmpb	$12, %bl
	je	.Lhrdbfw_2251
	testl	%eax, %eax
	je	.Lhrdbfw_2224
	cmpl	$9, %eax
	jne	.Lhrdbfw_2218
.Lhrdbfw_2224:
	cmpq	%rdi, %rsi
	jl	.Lhrdbfw_2226
	setg	%al
	movzbl	%al, %eax
.Lhrdbfw_2207:
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
.Lhrdbfw_2215:
	testl	%r13d, %r13d
	je	.Lhrdbfw_2216
	cmpl	$9, %r13d
	je	.Lhrdbfw_2216
	jmp	.Lhrdbfw_2218
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2226:
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
.Lhrdbfw_2250:
	leaq	32(%rsp), %r11
	movq	%r11, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2211
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2211
	cmpq	%rdi, %rsi
	jb	.Lhrdbfw_2226
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbfw_2207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2251:
	andb	$-1, %bh
	je	.Lhrdbfw_2224
	jmp	.Lhrdbfw_2217
.Lhrdbfw_2211:
	leaq	.Lhrdbfw_C106(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C108:

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
	jne	.Lhrdbfw_2253
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2265
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_2255
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2273:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_2269
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_2265
.Lhrdbfw_2255:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_2273
.Lhrdbfw_2269:
	xorl	%eax, %eax
.Lhrdbfw_2252:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2253:
	cmpl	$8, %ebx
	je	.Lhrdbfw_2274
	cmpl	$5, %ebx
	je	.Lhrdbfw_2275
	cmpl	$7, %ebx
	je	.Lhrdbfw_2269
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2260
	cmpl	$12, %ebx
	ja	.Lhrdbfw_2260
	leaq	.Lhrdbfw_2262(%rip), %rdx
	movslq	(%rdx,%rbx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_2262:
	.long	.Lhrdbfw_2261-.Lhrdbfw_2262
	.long	.Lhrdbfw_2265-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2261-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2261-.Lhrdbfw_2262
	.long	.Lhrdbfw_2260-.Lhrdbfw_2262
	.long	.Lhrdbfw_2261-.Lhrdbfw_2262
	.long	.Lhrdbfw_2261-.Lhrdbfw_2262
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2265:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2274:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2252
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_2252
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2260:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2275:
	testq	%rcx, %rcx
	js	.Lhrdbfw_2276
.Lhrdbfw_2259:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C107(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_2252
.Lhrdbfw_2261:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_2252
.Lhrdbfw_2276:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_2259
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C109:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.302:
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
	.align 32
hrdbf_app_pre_field:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,110,111,116,32,102,111,117,110,100,32,105,110,32,116,104,101,32,111,112,101,110,32,97,114,101,97,58,32,0
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
.zero 2448
.text

.bss
.balign 4
hrdbfw_local_fsink_len:
.zero 4
.text

.bss
.balign 32
hrdbfw_local_fsink:
.zero 160
.text
	.align 8
.Lhrdbfw_C107:
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
    sub $48, %rsp
    mov %r8, 32(%rsp)
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

hrdbf_app_fieldput:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_fieldput
    leave
    ret

hrdbf_app_append:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_append
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
hrdbf_app_get_name:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rdx, 48(%rsp)
    mov %rsi, %r8
    mov %rdi, %rdx
    lea 32(%rsp), %rcx
    lea hrdbfw_copy_callback(%rip), %r9
    call hrdbfw_app_get_name
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
