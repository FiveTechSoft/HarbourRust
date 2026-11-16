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
hrdbfw_device_eq:
	testq	%rdx, %rdx
	je	.Lhrdbfw_28
	pushq	%rbx
	movq	%rdx, %r11
	movq	%rcx, %rbx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_15
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_20:
	movzwl	(%rbx,%rcx,2), %eax
	leal	-97(%rax), %r10d
	leal	-32(%rax), %r9d
	cmpl	$26, %r10d
	cmovb	%r9d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_22
	addq	$1, %rcx
	cmpq	%rcx, %r11
	je	.Lhrdbfw_19
.Lhrdbfw_15:
	movzbl	(%r8,%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_20
.Lhrdbfw_22:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_19:
	addq	%r11, %r8
	xorl	%eax, %eax
	popq	%rbx
	cmpb	$0, (%r8)
	sete	%al
	ret
.Lhrdbfw_28:
	xorl	%eax, %eax
	cmpb	$0, (%r8)
	sete	%al
	ret
	.p2align 4
hrdbfw_local_fset:
	leaq	hrdbfw_local_fsink(%rip), %r9
	movq	%r9, %rax
	leaq	159(%r9), %r8
	jmp	.Lhrdbfw_30
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_32:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_31
.Lhrdbfw_30:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_32
.Lhrdbfw_31:
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
	jb	.Lhrdbfw_34
	jmp	.Lhrdbfw_35
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_36:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_35
.Lhrdbfw_34:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_36
.Lhrdbfw_35:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	ret
	.p2align 4
hrdbfw_local_nxvisit:
	cmpl	$63, %r8d
	ja	.Lhrdbfw_81
	movl	%edx, %r9d
	testl	%edx, %edx
	je	.Lhrdbfw_81
	testl	$1023, %edx
	jne	.Lhrdbfw_81
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
	ja	.Lhrdbfw_42
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
	jne	.Lhrdbfw_42
	movq	(%r10), %r14
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movzwl	32(%rbx), %eax
	addq	%r14, %rdi
	movzwl	(%rdi), %r13d
	cmpw	%ax, %r13w
	ja	.Lhrdbfw_42
	testw	%r13w, %r13w
	jne	.Lhrdbfw_66
	testl	%r8d, %r8d
	je	.Lhrdbfw_66
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_42:
	movl	$1, %eax
.Lhrdbfw_38:
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
.Lhrdbfw_81:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_66:
	leal	4(%rax,%rax), %eax
	xorl	%r12d, %r12d
	leaq	4(%rdi), %r15
	movl	%eax, 40(%rsp)
.Lhrdbfw_47:
	movzwl	%r12w, %eax
	movzwl	2(%rdi,%rax,2), %r11d
	movq	%r11, %rax
	cmpl	40(%rsp), %r11d
	jl	.Lhrdbfw_42
	movzwl	34(%rbx), %edx
	addq	%rdx, %rax
	movq	%rdx, %r10
	cmpq	$1024, %rax
	ja	.Lhrdbfw_42
	testw	%r12w, %r12w
	je	.Lhrdbfw_44
	leal	-1(%r12), %edx
	leaq	2(%rdi), %rax
	movzwl	%dx, %edx
	leal	(%r11,%r10), %ebp
	leaq	(%r15,%rdx,2), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_46:
	movzwl	(%rax), %edx
	leal	(%rdx,%r10), %ecx
	cmpl	%ecx, %r11d
	jge	.Lhrdbfw_45
	cmpl	%ebp, %edx
	jl	.Lhrdbfw_42
.Lhrdbfw_45:
	addq	$2, %rax
	cmpq	%rsi, %rax
	jne	.Lhrdbfw_46
.Lhrdbfw_44:
	addl	$1, %r12d
	cmpw	%r12w, %r13w
	jnb	.Lhrdbfw_47
	movzwl	2(%rdi), %eax
	movl	(%rdi,%rax), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_48
	movl	40(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_85
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_42
.Lhrdbfw_48:
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
.Lhrdbfw_62:
	movzwl	2(%rsi), %r13d
	movl	(%rdi,%r13), %edx
	movq	%r13, %r12
	testl	%edx, %edx
	setne	%al
	cmpb	55(%rsp), %al
	jne	.Lhrdbfw_42
	testl	%ebp, %ebp
	jne	.Lhrdbfw_50
.Lhrdbfw_53:
	cmpq	%rsi, 40(%rsp)
	je	.Lhrdbfw_51
	movl	4(%rdi,%r13), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_55
	movq	8(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_55
	cmpl	36(%rbx), %eax
	jbe	.Lhrdbfw_55
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
	jne	.Lhrdbfw_55
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
	je	.Lhrdbfw_56
	xorl	%ecx, %ecx
	leaq	(%r14,%r11), %r9
	addq	%r13, %r8
	jmp	.Lhrdbfw_57
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_87:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_86
.Lhrdbfw_57:
	movzbl	(%r8,%rcx), %r13d
	cmpb	%r13b, (%r9,%rcx)
	je	.Lhrdbfw_87
.Lhrdbfw_55:
	movl	$4, %eax
	jmp	.Lhrdbfw_38
.Lhrdbfw_50:
	movl	64(%rsp), %r8d
	movq	%rbx, %rcx
	call	hrdbfw_local_nxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_53
	jmp	.Lhrdbfw_38
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_86:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_65
.Lhrdbfw_84:
	movq	16(%r10), %r9
.Lhrdbfw_60:
	movl	%ecx, %r8d
	addl	$1, %ecx
	addq	$2, %rsi
	leaq	(%r9,%r8,8), %r8
	movl	%edx, (%r8)
	movl	%eax, 4(%r8)
	movl	%ecx, 36(%rbx)
	cmpq	%rsi, 56(%rsp)
	jne	.Lhrdbfw_62
.Lhrdbfw_51:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_38
.Lhrdbfw_85:
	movl	%r8d, 40(%rbx)
	jmp	.Lhrdbfw_48
.Lhrdbfw_65:
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	addq	%r14, %r12
	leaq	(%r9,%r8,8), %r8
	movl	4(%r8), %r10d
	movl	(%r8), %r13d
	addq	%r10, %r12
	leaq	(%r14,%r10), %r8
	movq	%r12, 72(%rsp)
	jmp	.Lhrdbfw_61
.Lhrdbfw_59:
	addq	$1, %r8
	cmpq	72(%rsp), %r8
	je	.Lhrdbfw_63
.Lhrdbfw_61:
	movq	%r8, %r12
	subq	%r10, %r12
	movzbl	(%r12,%r11), %r12d
	cmpb	%r12b, (%r8)
	je	.Lhrdbfw_59
	jb	.Lhrdbfw_60
	jmp	.Lhrdbfw_42
.Lhrdbfw_56:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_84
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	movl	(%r9,%r8,8), %r13d
.Lhrdbfw_63:
	cmpl	%r13d, %edx
	ja	.Lhrdbfw_60
	jmp	.Lhrdbfw_42
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
	ja	.Lhrdbfw_109
	testq	%rdx, %rdx
	je	.Lhrdbfw_109
	testl	$1023, %r8d
	jne	.Lhrdbfw_110
	testq	%r9, %r9
	je	.Lhrdbfw_110
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_152
	cmpw	$6, (%rdx)
	movl	$2, %eax
	jne	.Lhrdbfw_152
	cmpw	$0, 16(%rdx)
	jne	.Lhrdbfw_152
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
	jmp	.Lhrdbfw_91
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_90:
	addq	$1, %rax
	cmpq	$486, %rax
	je	.Lhrdbfw_155
.Lhrdbfw_91:
	cmpq	$11, %rax
	jbe	.Lhrdbfw_90
	cmpb	$0, 538(%rdx,%rax)
	je	.Lhrdbfw_90
.Lhrdbfw_124:
	movl	$2, %eax
.Lhrdbfw_88:
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
.Lhrdbfw_109:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_152:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_110:
	ret
.Lhrdbfw_155:
	movzwl	14(%rdx), %r13d
	movl	$1, %eax
	leal	-1(%r13), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbfw_88
	leal	8(%r13), %r14d
	cmpw	%r14w, 12(%rdx)
	jne	.Lhrdbfw_88
	movzwl	18(%rdx), %r15d
	leal	-1(%r15), %ecx
	cmpw	$509, %cx
	ja	.Lhrdbfw_88
	movl	%r15d, %ecx
	shrw $1, %cx
	cmpw	20(%rdx), %cx
	jne	.Lhrdbfw_88
	leal	1(%r15), %ecx
	movzwl	%r14w, %r11d
	xorl	%edi, %edi
	movzwl	%cx, %r10d
	addq	%rcx, %rcx
	imulq	%r11, %r10
	andl	$131070, %ecx
	leaq	2(%r10,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbfw_92
	jmp	.Lhrdbfw_88
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_93:
	addq	$1, %rdi
	cmpq	$256, %rdi
	je	.Lhrdbfw_124
.Lhrdbfw_92:
	cmpb	$0, 22(%rdx,%rdi)
	jne	.Lhrdbfw_93
	testq	%rdi, %rdi
	je	.Lhrdbfw_124
	movzwl	36(%r9), %eax
	movw	%ax, 46(%rsp)
	testq	%rax, %rax
	je	.Lhrdbfw_124
	movq	%r8, 192(%rsp)
	movq	%r9, %rbp
	xorl	%r12d, %r12d
	movq	%rax, %r8
.Lhrdbfw_94:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_103
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_156:
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
	jne	.Lhrdbfw_96
	addq	$1, %rcx
	cmpq	%rdi, %rcx
	jnb	.Lhrdbfw_95
	cmpq	$10, %rcx
	ja	.Lhrdbfw_95
.Lhrdbfw_103:
	movzbl	42(%rbp,%rcx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_156
.Lhrdbfw_96:
	cmpq	%rdi, %rcx
	je	.Lhrdbfw_108
.Lhrdbfw_100:
	addq	$1, %r12
	addq	$16, %rbp
	cmpq	%r8, %r12
	jne	.Lhrdbfw_94
	jmp	.Lhrdbfw_124
.Lhrdbfw_95:
	cmpq	%rdi, %rcx
	jne	.Lhrdbfw_100
	cmpq	$11, %rcx
	je	.Lhrdbfw_101
.Lhrdbfw_108:
	movq	%r12, %rax
	salq	$4, %rax
	addq	%r9, %rax
	cmpb	$0, 42(%rcx,%rax)
	jne	.Lhrdbfw_100
.Lhrdbfw_101:
	movq	192(%rsp), %r8
	movl	%r12d, %r10d
	cmpw	%r12w, 46(%rsp)
	je	.Lhrdbfw_124
	movq	%r12, %rcx
	movl	$2, %eax
	salq	$4, %rcx
	addq	%r9, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbfw_88
	movzbl	54(%rcx), %ecx
	cmpw	%r13w, %cx
	jne	.Lhrdbfw_88
	movl	16(%r9), %eax
	cmpq	216(%rsp), %rax
	ja	.Lhrdbfw_130
	cmpq	$0, 208(%rsp)
	jne	.Lhrdbfw_131
	testl	%eax, %eax
	jne	.Lhrdbfw_130
.Lhrdbfw_131:
	movq	%r8, %rcx
	addq	$7, %rax
	shrq	$10, %rcx
	shrq	$3, %rax
	addq	$7, %rcx
	shrq	$3, %rcx
	cmpq	$0, 224(%rsp)
	je	.Lhrdbfw_130
	addq	%rcx, %rax
	cmpq	232(%rsp), %rax
	ja	.Lhrdbfw_130
	movq	224(%rsp), %r11
	addq	%r11, %rax
.Lhrdbfw_105:
	movb	$0, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_105
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
	jne	.Lhrdbfw_106
	movq	200(%rsp), %r9
	movl	84(%rsp), %edx
	cmpl	16(%r9), %edx
	je	.Lhrdbfw_107
	movl	$4, %eax
.Lhrdbfw_106:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_88
.Lhrdbfw_107:
	movl	%edx, 24(%rbx)
	jmp	.Lhrdbfw_88
.Lhrdbfw_130:
	movl	$3, %eax
	jmp	.Lhrdbfw_88
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
	jne	.Lhrdbfw_163
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.Lhrdbfw_165
.Lhrdbfw_163:
	movl	$1, %eax
.Lhrdbfw_157:
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
.Lhrdbfw_165:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.Lhrdbfw_157
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.Lhrdbfw_157
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.Lhrdbfw_157
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.Lhrdbfw_163
	cmpl	%r10d, %r13d
	jb	.Lhrdbfw_163
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbfw_157
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
	je	.Lhrdbfw_167
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_168:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.Lhrdbfw_168
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.Lhrdbfw_169
	testl	%edx, %edx
	je	.Lhrdbfw_169
.Lhrdbfw_171:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_169:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.Lhrdbfw_171
.Lhrdbfw_177:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbfw_171
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_171
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.Lhrdbfw_172
	xorl	%eax, %eax
	jmp	.Lhrdbfw_173
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_190:
	movq	(%rsi), %rcx
.Lhrdbfw_173:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbfw_190
.Lhrdbfw_172:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.Lhrdbfw_176
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_175:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_175
.Lhrdbfw_176:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_167:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_177
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
	je	.Lhrdbfw_194
	cmpl	$1023, %edx
	ja	.Lhrdbfw_245
.Lhrdbfw_194:
	movl	$1, %r12d
.Lhrdbfw_191:
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
.Lhrdbfw_245:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.Lhrdbfw_194
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_194
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
	jne	.Lhrdbfw_194
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.Lhrdbfw_195
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.Lhrdbfw_194
.Lhrdbfw_195:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_246
	cmpl	%r10d, %ecx
	jne	.Lhrdbfw_194
	cmpl	%edx, 312(%rax)
	jne	.Lhrdbfw_194
.Lhrdbfw_217:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.Lhrdbfw_199
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_194
	testl	$511, %ecx
	jne	.Lhrdbfw_194
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.Lhrdbfw_194
.Lhrdbfw_199:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.Lhrdbfw_200
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_247
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_194
.Lhrdbfw_202:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	hrdbfw_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_191
	testl	%r13d, %r13d
	je	.Lhrdbfw_212
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.Lhrdbfw_203:
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
	jne	.Lhrdbfw_222
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_205
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.Lhrdbfw_205
	cmpl	48(%rbx), %edx
	jbe	.Lhrdbfw_205
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.Lhrdbfw_205
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
	je	.Lhrdbfw_206
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.Lhrdbfw_207
.Lhrdbfw_249:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbfw_248
	movq	%rdx, %rax
.Lhrdbfw_207:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.Lhrdbfw_249
.Lhrdbfw_205:
	movl	$4, %r12d
	jmp	.Lhrdbfw_191
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_246:
	cmpl	$-1, %r10d
	jne	.Lhrdbfw_194
	jmp	.Lhrdbfw_217
.Lhrdbfw_200:
	testl	%r13d, %r13d
	je	.Lhrdbfw_194
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.Lhrdbfw_194
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.Lhrdbfw_215:
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
	jne	.Lhrdbfw_191
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.Lhrdbfw_194
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
	jne	.Lhrdbfw_194
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_213
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.Lhrdbfw_214
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_250:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_213
.Lhrdbfw_214:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.Lhrdbfw_250
	jmp	.Lhrdbfw_194
.Lhrdbfw_247:
	movl	%r8d, 52(%rbx)
	jmp	.Lhrdbfw_202
.Lhrdbfw_213:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.Lhrdbfw_191
	movzwl	%r8w, %eax
	jmp	.Lhrdbfw_215
.Lhrdbfw_248:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_220
.Lhrdbfw_244:
	movq	16(%r14), %rcx
.Lhrdbfw_210:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.Lhrdbfw_203
	movzwl	94(%rsp), %edi
.Lhrdbfw_212:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbfw_191
.Lhrdbfw_220:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.Lhrdbfw_211
.Lhrdbfw_209:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.Lhrdbfw_218
	movq	%r11, %r8
.Lhrdbfw_211:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.Lhrdbfw_209
	jb	.Lhrdbfw_210
	jmp	.Lhrdbfw_194
.Lhrdbfw_206:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_244
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.Lhrdbfw_218:
	cmpl	%edi, %r9d
	ja	.Lhrdbfw_210
	jmp	.Lhrdbfw_194
.Lhrdbfw_222:
	movl	%eax, %r12d
	jmp	.Lhrdbfw_191
	.p2align 4
hrdbfw_local_cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.Lhrdbfw_251
	cmpb	$1, 15(%rcx)
	jne	.Lhrdbfw_251
	cmpw	$1024, 16(%rcx)
	jne	.Lhrdbfw_251
	cmpw	$512, 18(%rcx)
	jne	.Lhrdbfw_251
	cmpw	$0, 502(%rcx)
	jne	.Lhrdbfw_251
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.Lhrdbfw_254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_274:
	cmpl	$23, %eax
	ja	.Lhrdbfw_261
.Lhrdbfw_253:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbfw_273
.Lhrdbfw_254:
	cmpb	$0, (%rcx,%rax)
	je	.Lhrdbfw_253
	testb	%dl, %dl
	je	.Lhrdbfw_274
.Lhrdbfw_261:
	movl	$2, %eax
.Lhrdbfw_251:
	ret
.Lhrdbfw_273:
	testl	%r8d, %r8d
	je	.Lhrdbfw_255
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_251
	cmpb	$67, 21(%rcx)
	jne	.Lhrdbfw_251
	cmpb	$72, 22(%rcx)
	jne	.Lhrdbfw_251
	cmpb	$66, 23(%rcx)
	jne	.Lhrdbfw_251
.Lhrdbfw_255:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_251
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.Lhrdbfw_251
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
	je	.Lhrdbfw_276
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_277:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_277
.Lhrdbfw_276:
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
	ja	.Lhrdbfw_281
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_361
	cmpb	$78, %r9b
	je	.Lhrdbfw_362
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_363
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_308
	cmpb	$89, %al
	je	.Lhrdbfw_308
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_281
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_281
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_281:
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
.Lhrdbfw_308:
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
.Lhrdbfw_362:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_285
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_286
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_287:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_285
.Lhrdbfw_286:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_287
	jmp	.Lhrdbfw_289
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_313:
	movl	%r9d, %ecx
.Lhrdbfw_289:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_288
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_313
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_291
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_311:
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
	jmp	.Lhrdbfw_295
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_365:
	testl	%esi, %esi
	jne	.Lhrdbfw_332
	movl	$1, %esi
.Lhrdbfw_293:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_364
.Lhrdbfw_295:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_365
.Lhrdbfw_332:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_325
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_322
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_293
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_293
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_361:
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
.Lhrdbfw_363:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_304:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_324
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_304
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_325:
	movl	$5, %r11d
	jmp	.Lhrdbfw_281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_324:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_303:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_325
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_303
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
	jbe	.Lhrdbfw_281
	cmpl	$11, %edx
	ja	.Lhrdbfw_281
	testl	%r10d, %r10d
	je	.Lhrdbfw_281
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_366
.Lhrdbfw_306:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_281
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_291:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_292:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_325
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_311
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_322:
	movl	$4, %r11d
	jmp	.Lhrdbfw_281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_364:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_281
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_281
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_296
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_297
	jmp	.Lhrdbfw_322
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_298:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_322
.Lhrdbfw_297:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_298
	testl	%r12d, %r12d
	jne	.Lhrdbfw_310
.Lhrdbfw_301:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_281
.Lhrdbfw_288:
	je	.Lhrdbfw_285
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_291
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_292
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_285:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_281
.Lhrdbfw_366:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_306
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_307
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_306
.Lhrdbfw_307:
	addl	$1, %edx
	jmp	.Lhrdbfw_306
.Lhrdbfw_296:
	testl	%r12d, %r12d
	je	.Lhrdbfw_301
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_301
.Lhrdbfw_310:
	negq	%rbx
	jmp	.Lhrdbfw_301
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
	je	.Lhrdbfw_370
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_382
.Lhrdbfw_370:
	xorl	%r12d, %r12d
.Lhrdbfw_369:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_371
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_383
	movl	$7, %r12d
.Lhrdbfw_371:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_367
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_374
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_367:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_383:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_371
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_382:
	movl	$7, %r12d
	jmp	.Lhrdbfw_369
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_374:
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
	jne	.Lhrdbfw_384
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_384:
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
	ja	.Lhrdbfw_390
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_390
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_390
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_390
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_390
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_386
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_386
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_386
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_386
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_390
	testl	$511, %r12d
	jne	.Lhrdbfw_390
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_390
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_386
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_386
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_390
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_390
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_386
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
	jne	.Lhrdbfw_386
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_390
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_390
	testl	$511, %eax
	jne	.Lhrdbfw_390
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_390
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_390
	cmpl	%r12d, %eax
	je	.Lhrdbfw_390
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_390
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_391
.Lhrdbfw_464:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_428
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_463
.Lhrdbfw_391:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_464
.Lhrdbfw_428:
	movl	$2, %eax
	jmp	.Lhrdbfw_386
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_390:
	movl	$1, %eax
.Lhrdbfw_386:
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
.Lhrdbfw_463:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_386
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_428
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_428
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_428
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_392:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_428
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_392
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_393:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_428
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_402:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_396
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_397
	subl	$32, %ecx
.Lhrdbfw_397:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_398
	subl	$32, %r13d
.Lhrdbfw_398:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_396
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_394
	cmpq	$11, %rdx
	jne	.Lhrdbfw_402
	cmpq	$11, %rax
	jne	.Lhrdbfw_396
.Lhrdbfw_400:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_428
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_428
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_427
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_428
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_432
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_434
	testl	%eax, %eax
	jne	.Lhrdbfw_432
.Lhrdbfw_434:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_432
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_432
	xorl	%edx, %edx
.Lhrdbfw_404:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_404
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_405
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_405:
	testb	$2, %al
	jne	.Lhrdbfw_406
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_406:
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
.Lhrdbfw_407:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_407
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_465
.Lhrdbfw_408:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_386
.Lhrdbfw_394:
	cmpq	$11, %rax
	je	.Lhrdbfw_400
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_400
.Lhrdbfw_396:
	addq	$1, %r9
	jmp	.Lhrdbfw_393
.Lhrdbfw_432:
	movl	$3, %eax
	jmp	.Lhrdbfw_386
.Lhrdbfw_427:
	movl	$5, %eax
	jmp	.Lhrdbfw_386
.Lhrdbfw_465:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_408
	xorl	%edx, %edx
	jmp	.Lhrdbfw_410
.Lhrdbfw_466:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_435
.Lhrdbfw_410:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_409
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_409:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_466
.Lhrdbfw_435:
	testl	%eax, %eax
	jne	.Lhrdbfw_408
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_386
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
.Lhrdbfw_468:
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
	jbe	.Lhrdbfw_476
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_468
.Lhrdbfw_476:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_474:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_470
	jmp	.Lhrdbfw_471
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_472:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_471
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_470:
	testb	%cl, %cl
	jne	.Lhrdbfw_472
.Lhrdbfw_471:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_467
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_474
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_467:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
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
	jmp	.Lhrdbfw_484
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_486:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_485
.Lhrdbfw_484:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_486
.Lhrdbfw_485:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_487
	movl	$32, %ecx
	leaq	.Lhrdbfw_C0(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_489:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_493
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_489
.Lhrdbfw_493:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_487:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_490
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_490:
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
.Lhrdbfw_495:
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
	jbe	.Lhrdbfw_505
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_495
.Lhrdbfw_505:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_503:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_497
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_499:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_498
.Lhrdbfw_497:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_499
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_500
	jmp	.Lhrdbfw_498
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_501:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_498
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_500:
	testb	%cl, %cl
	jne	.Lhrdbfw_501
.Lhrdbfw_498:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_494
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_503
.Lhrdbfw_494:
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
.Lhrdbfw_513:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_512
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.Lhrdbfw_515
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_517:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_516
.Lhrdbfw_515:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_517
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_518
	jmp	.Lhrdbfw_516
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_519:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_516
.Lhrdbfw_518:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_519
.Lhrdbfw_516:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_513
.Lhrdbfw_512:
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
	jmp	.Lhrdbfw_527
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_529:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_528
.Lhrdbfw_527:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_529
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_530
	jmp	.Lhrdbfw_528
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_532:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_528
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_530:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_532
.Lhrdbfw_528:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_534
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_536:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_535
.Lhrdbfw_534:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_536
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_537
	jmp	.Lhrdbfw_535
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_538:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_535
.Lhrdbfw_537:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_538
.Lhrdbfw_535:
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
	je	.Lhrdbfw_550
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.Lhrdbfw_653
	cmpb	$47, %dl
	jne	.Lhrdbfw_646
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_550
	movl	$47, %eax
.Lhrdbfw_551:
	movabs	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.Lhrdbfw_552
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_655:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.Lhrdbfw_550
.Lhrdbfw_556:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_654
	js	.Lhrdbfw_550
	cmpq	$258, %rbx
	ja	.Lhrdbfw_550
.Lhrdbfw_552:
	cmpb	$63, %al
	ja	.Lhrdbfw_655
	btq	%rax, %r9
	jc	.Lhrdbfw_550
	cmpb	$60, %al
	je	.Lhrdbfw_550
	cmpb	$58, %al
	jne	.Lhrdbfw_555
	cmpq	$1, %rbx
	jne	.Lhrdbfw_550
	cmpb	$25, %dl
	ja	.Lhrdbfw_550
	movl	$58, %eax
	jmp	.Lhrdbfw_556
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_660:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_561
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_550:
	leaq	.Lhrdbfw_C2(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_546:
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
.Lhrdbfw_653:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.Lhrdbfw_551
	jmp	.Lhrdbfw_550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_555:
	cmpb	$47, %al
	jne	.Lhrdbfw_556
	movl	$92, %eax
	jmp	.Lhrdbfw_556
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_646:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.Lhrdbfw_551
	jmp	.Lhrdbfw_550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_654:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.Lhrdbfw_576
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_559:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.Lhrdbfw_656
	movq	%rax, %rbx
.Lhrdbfw_576:
	cmpq	%r15, %r12
	je	.Lhrdbfw_558
	cmpw	$92, (%rdi,%r15,2)
	jne	.Lhrdbfw_559
.Lhrdbfw_558:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.Lhrdbfw_605
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.Lhrdbfw_560
	cmpw	$46, %ax
	je	.Lhrdbfw_560
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.Lhrdbfw_561:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_563
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_564:
	movzwl	0(%r13,%rax,2), %edx
.Lhrdbfw_563:
	cmpw	$46, %dx
	je	.Lhrdbfw_657
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_564
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.Lhrdbfw_566
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_570:
	subq	$1, %rsi
	je	.Lhrdbfw_566
.Lhrdbfw_569:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.Lhrdbfw_570
.Lhrdbfw_566:
	leaq	.Lhrdbfw_C3(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_550
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.Lhrdbfw_559
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_559
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_573
.Lhrdbfw_658:
	leaq	.Lhrdbfw_C10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_603
	movzwl	0(%r13,%rcx,2), %eax
.Lhrdbfw_573:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_603
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_658
	jmp	.Lhrdbfw_550
.Lhrdbfw_603:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_575
.Lhrdbfw_659:
	movzwl	0(%r13,%rdx,2), %r14d
.Lhrdbfw_575:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_605
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_550
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_659
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_605:
	movq	%rbx, %rcx
	jmp	.Lhrdbfw_559
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_560:
	cmpq	$1, %rsi
	je	.Lhrdbfw_660
	cmpq	$2, %rsi
	jne	.Lhrdbfw_550
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.Lhrdbfw_550
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_561
	jmp	.Lhrdbfw_550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_657:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_569
	jmp	.Lhrdbfw_566
.Lhrdbfw_656:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.Lhrdbfw_550
	cmpq	$1, %rbx
	je	.Lhrdbfw_577
	cmpw	$58, 98(%rsp)
	je	.Lhrdbfw_661
.Lhrdbfw_577:
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
	je	.Lhrdbfw_662
	movq	728(%rsp), %rax
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_663
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_664
	cmpq	$67108864, %r10
	jg	.Lhrdbfw_665
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_583
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_666
.Lhrdbfw_583:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.Lhrdbfw_584
	movq	(%rdi), %r8
	leaq ReadFile(%rip), %rbx
	xorl	%r15d, %r15d
	movq	%rax, %rdx
	leaq GetLastError(%rip), %r13
	leaq	76(%rsp), %rsi
	testq	%r8, %r8
	jne	.Lhrdbfw_585
	jmp	.Lhrdbfw_586
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_590:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_652
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%r15, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_667
	addq	%rax, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_586
	movq	0(%rbp), %rdx
.Lhrdbfw_585:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rsi, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_590
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_590
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_652:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_664:
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_665:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C16(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_586:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rsi, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_668
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_594
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_594
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_546
.Lhrdbfw_594:
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_667:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_652
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_663:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_662:
	call GetLastError
	leaq	.Lhrdbfw_C12(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_666:
	leaq	.Lhrdbfw_C17(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_546
.Lhrdbfw_584:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_546
.Lhrdbfw_668:
	call GetLastError
	jmp	.Lhrdbfw_652
.Lhrdbfw_661:
	cmpq	$2, %rbx
	je	.Lhrdbfw_550
	cmpw	$92, 100(%rsp)
	jne	.Lhrdbfw_550
	jmp	.Lhrdbfw_577
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
	je	.Lhrdbfw_670
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_670:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_673
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_673
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_675
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
.Lhrdbfw_677:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_687
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_673:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_675:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_678
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_687:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_678:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_677
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
	je	.Lhrdbfw_690
	testl	%edx, %edx
	je	.Lhrdbfw_692
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_692
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_692:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_690:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_693
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_695
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_695:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_693:
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
	jbe	.Lhrdbfw_783
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_784
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
	jbe	.Lhrdbfw_702
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.Lhrdbfw_703
.Lhrdbfw_702:
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
.Lhrdbfw_698:
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
.Lhrdbfw_703:
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
.Lhrdbfw_729:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.Lhrdbfw_785
	cmpq	%r15, 64(%rsp)
	je	.Lhrdbfw_786
	cmpq	$129, %r15
	je	.Lhrdbfw_787
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_713
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_788:
	movzbl	(%r8,%rax), %r10d
.Lhrdbfw_713:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_788
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_714
	cmpl	$1, %r15d
	jbe	.Lhrdbfw_715
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_716:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_719
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_790:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_719:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.Lhrdbfw_789
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_790
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
	jmp	.Lhrdbfw_698
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_789:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.Lhrdbfw_716
.Lhrdbfw_715:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.Lhrdbfw_791
	cmpb	$67, %dl
	je	.Lhrdbfw_792
	cmpb	$78, %dl
	je	.Lhrdbfw_793
	cmpb	$76, %dl
	je	.Lhrdbfw_794
	cmpb	$68, %dl
	jne	.Lhrdbfw_726
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.Lhrdbfw_722
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
	jmp	.Lhrdbfw_698
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_783:
	leaq	.Lhrdbfw_C14(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_784:
	leaq	.Lhrdbfw_C23(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C24(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_792:
	testb	%r9b, %r9b
	jne	.Lhrdbfw_795
.Lhrdbfw_722:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_796
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.Lhrdbfw_729
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_793:
	cmpb	$17, %r9b
	ja	.Lhrdbfw_750
	cmpb	%r9b, %al
	ja	.Lhrdbfw_722
.Lhrdbfw_750:
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
	jmp	.Lhrdbfw_698
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_794:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.Lhrdbfw_722
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
	jmp	.Lhrdbfw_698
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_786:
	testb	%dl, %dl
	je	.Lhrdbfw_709
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_709:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_787:
	testb	%dl, %dl
	je	.Lhrdbfw_711
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_711:
	leaq	.Lhrdbfw_C30(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_785:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.Lhrdbfw_705
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_705:
	cmpw	$0, 148(%rsp)
	je	.Lhrdbfw_797
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.Lhrdbfw_731
	jmp	.Lhrdbfw_798
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_732:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.Lhrdbfw_799
.Lhrdbfw_731:
	cmpq	%r9, 32(%rsp)
	ja	.Lhrdbfw_732
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_800
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_734
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_735
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_734
.Lhrdbfw_735:
	leaq	.Lhrdbfw_C55(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_714:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_791:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_799:
	leaq	.Lhrdbfw_C51(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_796:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C46(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_795:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_798:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_797:
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_726:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_734:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.Lhrdbfw_747
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.Lhrdbfw_739:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_737
	cmpb	$42, %dil
	jne	.Lhrdbfw_801
.Lhrdbfw_737:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.Lhrdbfw_738
	jmp	.Lhrdbfw_745
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_741:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_802
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_745
.Lhrdbfw_738:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.Lhrdbfw_741
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
.Lhrdbfw_742:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.Lhrdbfw_803
.Lhrdbfw_744:
	cmpb	$42, %dil
	jne	.Lhrdbfw_698
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_698
.Lhrdbfw_745:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_739
	cmpb	$0, 152(%rsp)
	je	.Lhrdbfw_746
.Lhrdbfw_736:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.Lhrdbfw_746:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.Lhrdbfw_698
.Lhrdbfw_803:
	leaq	.Lhrdbfw_C60(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_744
.Lhrdbfw_800:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_801:
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
	jmp	.Lhrdbfw_698
.Lhrdbfw_747:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_736
.Lhrdbfw_802:
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
	jmp	.Lhrdbfw_742
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
	ja	.Lhrdbfw_806
	je	.Lhrdbfw_837
	cmpl	$5, %edx
	je	.Lhrdbfw_810
	shrq	$8, %rax
	jne	.Lhrdbfw_806
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_806
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_806
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_806
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_806
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
	ja	.Lhrdbfw_824
	testq	%rcx, %rcx
	je	.Lhrdbfw_824
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_838
.Lhrdbfw_812:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_806:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_837:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_806
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_806
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_824
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_824
	cmpl	%edx, %eax
	jb	.Lhrdbfw_806
.Lhrdbfw_824:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_810:
	testq	%rax, %rax
	jns	.Lhrdbfw_819
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_806
.Lhrdbfw_819:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_838:
	testb	$3, %r9b
	jne	.Lhrdbfw_812
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_813
	addl	$1, %eax
	jmp	.Lhrdbfw_812
.Lhrdbfw_813:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_812
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_839
	leaq	hrdbfw_local_CSWTCH.199(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_839:
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
	jne	.Lhrdbfw_844
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_855
	testl	%edx, %edx
	je	.Lhrdbfw_847
	cmpl	$9, %edx
	je	.Lhrdbfw_847
	movl	$1, %eax
.Lhrdbfw_844:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_855:
	testl	$65280, %r11d
	jne	.Lhrdbfw_856
.Lhrdbfw_847:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_856:
	movl	$2, %eax
	jmp	.Lhrdbfw_844
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
	jne	.Lhrdbfw_857
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_857
	movzbl	%bl, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %bl
	jne	.Lhrdbfw_859
	cmpl	$11, %r14d
	jne	.Lhrdbfw_859
.Lhrdbfw_872:
	xorl	%edx, %edx
	cmpq	%r12, %rsi
	sete	%dl
	movl	%edx, 0(%r13)
.Lhrdbfw_857:
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
.Lhrdbfw_859:
	cmpl	$1, %r15d
	je	.Lhrdbfw_875
	cmpl	$1, %r14d
	je	.Lhrdbfw_875
	cmpl	$3, %r15d
	jne	.Lhrdbfw_862
	cmpl	$3, %r14d
	jne	.Lhrdbfw_862
	testq	%rsi, %rsi
	sete	%dl
	testq	%r12, %r12
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_857
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_875:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_857
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_862:
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_857
	cmpl	$12, %r15d
	je	.Lhrdbfw_898
	testl	%r15d, %r15d
	je	.Lhrdbfw_865
	movl	$1, %eax
	cmpl	$9, %r15d
	jne	.Lhrdbfw_857
.Lhrdbfw_865:
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_857
	cmpl	$12, %r14d
	je	.Lhrdbfw_899
	testl	%r14d, %r14d
	je	.Lhrdbfw_872
	cmpl	$9, %r14d
	je	.Lhrdbfw_872
	movl	$1, %eax
	jmp	.Lhrdbfw_857
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_898:
	andb	$-1, %bh
	je	.Lhrdbfw_865
.Lhrdbfw_871:
	movl	$2, %eax
	jmp	.Lhrdbfw_857
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_899:
	testl	$65280, %edi
	je	.Lhrdbfw_872
	jmp	.Lhrdbfw_871
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
	jne	.Lhrdbfw_900
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_905
	leaq	.Lhrdbfw_903(%rip), %rcx
	movslq	(%rcx,%rdx,4), %rdx
	addq	%rcx, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_903:
	.long	.Lhrdbfw_902-.Lhrdbfw_903
	.long	.Lhrdbfw_904-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_902-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_902-.Lhrdbfw_903
	.long	.Lhrdbfw_905-.Lhrdbfw_903
	.long	.Lhrdbfw_902-.Lhrdbfw_903
	.long	.Lhrdbfw_902-.Lhrdbfw_903
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_905:
	movl	$1, %eax
.Lhrdbfw_900:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_902:
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
.Lhrdbfw_904:
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
	jne	.Lhrdbfw_907
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_954
	cmpl	$12, %eax
	jne	.Lhrdbfw_933
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
.Lhrdbfw_915:
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
	ja	.Lhrdbfw_915
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_955
	movl	$1, %r9d
.Lhrdbfw_916:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_917:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_918
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_956
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_926
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_925:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_925
.Lhrdbfw_926:
	testq	%r13, %r13
	jns	.Lhrdbfw_924
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_924:
	testl	%r9d, %r9d
	je	.Lhrdbfw_927
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_929
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_937:
	movl	%edx, %eax
.Lhrdbfw_929:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_928
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_928:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_937
	addl	%r9d, %r10d
.Lhrdbfw_927:
	testl	%ebx, %ebx
	je	.Lhrdbfw_907
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_931:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_930
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_930:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_931
.Lhrdbfw_907:
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
.Lhrdbfw_954:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_918
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_913
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
	jmp	.Lhrdbfw_907
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_933:
	movl	$1, %r12d
	jmp	.Lhrdbfw_907
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_957:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_932
.Lhrdbfw_912:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_907
.Lhrdbfw_913:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_957
.Lhrdbfw_932:
	movl	$47, %eax
	jmp	.Lhrdbfw_912
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_955:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_916
	movl	%r9d, %eax
	jmp	.Lhrdbfw_917
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_918:
	movl	$3, %r12d
	jmp	.Lhrdbfw_907
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_956:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_907
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_921:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_921
	jmp	.Lhrdbfw_907
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
	ja	.Lhrdbfw_959
	leaq	.Lhrdbfw_961(%rip), %rdx
	movl	%ecx, %ecx
	movslq	(%rdx,%rcx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_961:
	.long	.Lhrdbfw_966-.Lhrdbfw_961
	.long	.Lhrdbfw_964-.Lhrdbfw_961
	.long	.Lhrdbfw_963-.Lhrdbfw_961
	.long	.Lhrdbfw_962-.Lhrdbfw_961
	.long	.Lhrdbfw_960-.Lhrdbfw_961
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_964:
	leaq	.Lhrdbfw_C69(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_966:
	leaq	.Lhrdbfw_C65(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_960:
	leaq	.Lhrdbfw_C68(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_963:
	leaq	.Lhrdbfw_C66(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_962:
	leaq	.Lhrdbfw_C67(%rip), %rax
	ret
.Lhrdbfw_959:
	leaq	.Lhrdbfw_C64(%rip), %rax
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
	movq	2272(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_970
	movq	$0, 2272(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_977
.Lhrdbfw_970:
	xorl	%r12d, %r12d
.Lhrdbfw_969:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_967
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_972
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.Lhrdbfw_967:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_977:
	movl	$7, %r12d
	jmp	.Lhrdbfw_969
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_972:
	movl	$7, %r12d
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
hrdbf_file_open.part.0:
	pushq	%r13
	pushq	%r12
	movq	%rcx, %r12
	movq	%rdx, %rcx
	leaq	2272(%r12), %r9
	leaq	2256(%r12), %rdx
	subq	$72, %rsp
	movb	$0, hrdbfw_local_fsink(%rip)
	movl	%r8d, 48(%rsp)
	leaq	2264(%r12), %r8
	movb	$0, 2280(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.Lhrdbfw_979
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	2280(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_980
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_982:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_981
.Lhrdbfw_980:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_982
.Lhrdbfw_981:
	movb	$0, (%rdx)
.Lhrdbfw_984:
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
.Lhrdbfw_979:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_984
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
	je	.Lhrdbfw_995
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1005
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_995
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1009
	cmpb	$78, %al
	je	.Lhrdbfw_1010
	cmpb	$68, %al
	je	.Lhrdbfw_1004
	movzbl	60(%rsp), %eax
.Lhrdbfw_994:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1009:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1011
.Lhrdbfw_997:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1012
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_995:
	leaq	.Lhrdbfw_C70(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1005:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_994
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1010:
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
.Lhrdbfw_1004:
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
.Lhrdbfw_1011:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1000
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_999:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_999
.Lhrdbfw_1000:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_997
.Lhrdbfw_1012:
	leaq	.Lhrdbfw_C71(%rip), %rcx
	call	hrdbf_app_fail
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
	movb	$0, 2280(%rcx)
	movb	$0, hrdbfw_local_fsink(%rip)
	movq	$0, 8(%rcx)
	movq	$0, (%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	2272(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1033
	movq	$0, 2272(%r12)
	call CloseHandle
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1017
	testq	%rcx, %rcx
	je	.Lhrdbfw_1013
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1013
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
.Lhrdbfw_1017:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1016
.Lhrdbfw_1015:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1031
.Lhrdbfw_1013:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1033:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1015
.Lhrdbfw_1016:
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
.Lhrdbfw_1031:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.Lhrdbfw_1016
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
	je	.Lhrdbfw_1036
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1041:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1054
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1040
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1038:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1054
.Lhrdbfw_1040:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1038
	jnb	.Lhrdbfw_1054
	leal	1(%r10), %r11d
.Lhrdbfw_1037:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1041
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1045
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1044:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1046
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1047
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1079:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1046
.Lhrdbfw_1047:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1079
.Lhrdbfw_1045:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1035
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1080
	movl	%r11d, %r9d
.Lhrdbfw_1035:
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
.Lhrdbfw_1054:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1037
.Lhrdbfw_1046:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1035
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1048
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1053:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1049
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1052
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1050:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1049
.Lhrdbfw_1052:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1050
	jb	.Lhrdbfw_1049
	movl	%r9d, %r10d
.Lhrdbfw_1051:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1053
.Lhrdbfw_1048:
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
.Lhrdbfw_1049:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1051
.Lhrdbfw_1080:
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
.Lhrdbfw_1036:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1035
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1044
	.section .rdata,"dr"
.Lhrdbfw_C72:

.byte 104,98,99,58,32,68,66,70,47,78,84,88,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_close
hrdbfw_app_close:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	movq	hrdbf_app_state+2272(%rip), %rcx
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	%eax, %ebx
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_1086
	movq	$0, hrdbf_app_state+2272(%rip)
	call CloseHandle
	testl	%eax, %eax
	jne	.Lhrdbfw_1086
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1087
	movl	$7, %esi
	jmp	.Lhrdbfw_1083
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1086:
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1096
.Lhrdbfw_1084:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1089
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1096:
	xorl	%esi, %esi
.Lhrdbfw_1083:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1087
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%esi, %ebx
	movq	$0, hrdbf_app_state+2264(%rip)
	jmp	.Lhrdbfw_1084
.Lhrdbfw_1087:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbfw_1089:
	leaq	.Lhrdbfw_C72(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C73:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,0
	.align 8
.Lhrdbfw_C74:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,116,97,98,108,101,32,118,101,114,115,105,111,110,32,111,114,32,104,101,97,100,101,114,32,102,108,97,103,115,0
.Lhrdbfw_C75:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,102,105,101,108,100,32,116,121,112,101,0
.Lhrdbfw_C76:

.byte 114,101,99,111,114,100,32,99,111,110,116,101,110,116,32,105,110,118,97,108,105,100,0
.Lhrdbfw_C77:

.byte 73,47,79,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C78:

.byte 115,105,122,101,32,111,114,32,102,105,101,108,100,45,99,111,117,110,116,32,108,105,109,105,116,32,101,120,99,101,101,100,101,100,0
.Lhrdbfw_C79:

.byte 116,97,98,108,101,32,102,111,114,109,97,116,32,110,111,116,32,115,117,112,112,111,114,116,101,100,0
	.align 8
.Lhrdbfw_C80:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C81:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C82:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C83:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
.Lhrdbfw_C84:

.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,114,101,106,101,99,116,101,100,58,32,0
.Lhrdbfw_C85:

.byte 10,0
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
	je	.Lhrdbfw_1098
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_1144
.Lhrdbfw_1098:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_1145
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1099
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1117:
	movq	%rsi, %rbx
.Lhrdbfw_1099:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1146
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_1117
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1147
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movq	$0, hrdbf_app_pos(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1104
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1102:
	cmpq	%rcx, %rbx
	je	.Lhrdbfw_1148
.Lhrdbfw_1104:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.Lhrdbfw_1127
	cmpb	$92, %dl
	jne	.Lhrdbfw_1102
.Lhrdbfw_1127:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.Lhrdbfw_1104
.Lhrdbfw_1148:
	cmpq	%rsi, %r8
	jnb	.Lhrdbfw_1105
	movq	%r8, %rax
	jmp	.Lhrdbfw_1107
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1118:
	movq	%rdx, %rax
.Lhrdbfw_1107:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_1118
.Lhrdbfw_1105:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.Lhrdbfw_1112
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1108:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrdbfw_1108
.Lhrdbfw_1112:
	xorl	%ebx, %ebx
	leaq	hrdbf_app_state(%rip), %rcx
	cmpq	$0, 384(%rsp)
	movb	$0, hrdbf_app_state+2280(%rip)
	setne	%bl
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_1149
.Lhrdbfw_1109:
	leaq	hrdbf_app_state+2280(%rip), %r12
	cmpb	$0, hrdbf_app_state+2280(%rip)
	leaq	-190(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_1115
	leaq	.Lhrdbfw_C77(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_1115
	leaq	.Lhrdbfw_C73(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_1115
	leaq	.Lhrdbfw_C78(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_1115
	leaq	.Lhrdbfw_C74(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_1115
	leaq	.Lhrdbfw_C75(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_1115
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C76(%rip), %r12
	leaq	.Lhrdbfw_C79(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_1115:
	leaq	.Lhrdbfw_C84(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C85(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1149:
	movl	%ebx, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1109
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.Lhrdbfw_1146:
	leaq	.Lhrdbfw_C82(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1145:
	leaq	.Lhrdbfw_C81(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1144:
	leaq	.Lhrdbfw_C80(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1147:
	leaq	.Lhrdbfw_C83(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C86:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1159
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1160
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1161
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1155:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1161:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbfw_1155
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1160:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1159:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1172
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1173
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_1174
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_1167:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1168:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1174:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_1167
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_1168
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1173:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1172:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1192
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1193
	testq	%rcx, %rcx
	je	.Lhrdbfw_1175
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbfw_1179
	movq	%rax, %r8
	subq	%rdx, %r8
	cmpq	%rcx, %r8
	jb	.Lhrdbfw_1185
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	setnb	%dl
.Lhrdbfw_1180:
	movq	%rcx, hrdbf_app_pos(%rip)
.Lhrdbfw_1181:
	cmpq	%rax, %rcx
	jnb	.Lhrdbfw_1183
.Lhrdbfw_1194:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
.Lhrdbfw_1184:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbfw_1175:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1179:
	movq	%rcx, %r8
	negq	%r8
	cmpq	%rdx, %r8
	jbe	.Lhrdbfw_1182
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_1194
.Lhrdbfw_1183:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_1184
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1185:
	movq	%rax, %rcx
	movl	$1, %edx
	jmp	.Lhrdbfw_1180
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1182:
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	movq	%rcx, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbfw_1181
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1193:
	movq	%rcx, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
.Lhrdbfw_1192:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C87:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C88:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C89:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C90:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C91:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C92:

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
	je	.Lhrdbfw_1269
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1270
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_1271
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.Lhrdbfw_1198
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1200:
	cmpq	%rcx, %r9
	je	.Lhrdbfw_1272
.Lhrdbfw_1236:
	movq	%rcx, %rdx
.Lhrdbfw_1198:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1273
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.Lhrdbfw_1240
	cmpb	$92, %al
	jne	.Lhrdbfw_1200
.Lhrdbfw_1240:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.Lhrdbfw_1236
.Lhrdbfw_1272:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.Lhrdbfw_1202
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.Lhrdbfw_1204
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1237:
	movq	%r11, %rax
.Lhrdbfw_1204:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1237
	testl	%ebx, %ebx
	je	.Lhrdbfw_1208
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.Lhrdbfw_1234
.Lhrdbfw_1209:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1232
.Lhrdbfw_1233:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1214
	testl	%ebx, %ebx
	je	.Lhrdbfw_1216
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
	jne	.Lhrdbfw_1228
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.Lhrdbfw_1227:
	cmpq	$67108864, %rbp
	ja	.Lhrdbfw_1268
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
	je	.Lhrdbfw_1268
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
	je	.Lhrdbfw_1221
	cmpl	$5, %eax
	je	.Lhrdbfw_1222
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1268:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1214
.Lhrdbfw_1223:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	jmp	.Lhrdbfw_1224
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1208:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1207
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1214
.Lhrdbfw_1216:
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
	jne	.Lhrdbfw_1228
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.Lhrdbfw_1227
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1207:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.Lhrdbfw_1231:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.Lhrdbfw_1233
.Lhrdbfw_1202:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1207
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.Lhrdbfw_1274
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1232:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.Lhrdbfw_1231
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1228:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.Lhrdbfw_1214:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_1223
	cmpl	$3, %eax
	je	.Lhrdbfw_1225
	jmp	.Lhrdbfw_1223
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1221:
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
.Lhrdbfw_1274:
	xorl	%r10d, %r10d
.Lhrdbfw_1234:
	testq	%rdi, %rdi
	je	.Lhrdbfw_1210
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1213:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.Lhrdbfw_1213
	testl	%r11d, %r11d
	je	.Lhrdbfw_1209
.Lhrdbfw_1210:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1222:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1214
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1223
.Lhrdbfw_1225:
	leaq	.Lhrdbfw_C87(%rip), %rcx
.Lhrdbfw_1224:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1273:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1270:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1269:
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1271:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1301
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_1302
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	movq	hrdbf_app_order+32(%rip), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1281
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1303
.Lhrdbfw_1278:
	xorl	%edx, %edx
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1282
	movq	hrdbf_app_order+40(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1283
.Lhrdbfw_1279:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_1283
.Lhrdbfw_1304:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_1284:
	testl	%esi, %esi
	jne	.Lhrdbfw_1283
.Lhrdbfw_1280:
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1281:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1278
.Lhrdbfw_1299:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1280
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1304
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1283:
	leaq	.Lhrdbfw_C83(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1302:
	movq	hrdbf_app_order+32(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1278
	jmp	.Lhrdbfw_1299
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1282:
	movq	hrdbf_app_order+40(%rip), %rcx
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1279
	jmp	.Lhrdbfw_1284
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1303:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1279
	jmp	.Lhrdbfw_1283
.Lhrdbfw_1301:
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1310
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_1310:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C93:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1317
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_1318
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
	jb	.Lhrdbfw_1319
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_1315:
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
.Lhrdbfw_1319:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1318:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1317:
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1325
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_1325:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1331
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_1331:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1337
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_1337:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1343
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_1343:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1351
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1344
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_1344:
	movq	%r8, %rax
	ret
.Lhrdbfw_1351:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1358
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_1354
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_1355
.Lhrdbfw_1354:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1355:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_1358:
	leaq	.Lhrdbfw_C86(%rip), %rcx
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
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1360
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%r8, %rbx
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_1362
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1374:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1363:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_1364
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1363
.Lhrdbfw_1364:
	cmpq	%rbx, %rax
	je	.Lhrdbfw_1384
.Lhrdbfw_1366:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%r8d, %esi
	jne	.Lhrdbfw_1374
.Lhrdbfw_1362:
	leaq GetStdHandle(%rip), %rbp
	leaq	60(%rsp), %rdi
	movl	$-12, %ecx
	call	*%rbp
	leaq WriteFile(%rip), %rsi
	movq	%rdi, %r9
	movl	$43, %r8d
	leaq	hrdbf_app_pre_field(%rip), %rdx
	movq	%rax, %rcx
	movq	$0, 32(%rsp)
	call	*%rsi
	movl	$-12, %ecx
	call	*%rbp
	movq	%rdi, %r9
	movl	%ebx, %r8d
	movq	%r12, %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*%rsi
	movl	$-12, %ecx
	call	*%rbp
	movq	%rdi, %r9
	movl	$1, %r8d
	leaq	.Lhrdbfw_C85(%rip), %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*%rsi
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_close
	movl	$1, %ecx
	call ExitProcess
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1384:
	testq	%rbx, %rbx
	je	.Lhrdbfw_1367
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_1371
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1385:
	addq	$1, %rcx
	cmpq	%rcx, %rbx
	je	.Lhrdbfw_1367
.Lhrdbfw_1371:
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
	je	.Lhrdbfw_1385
	cmpq	%rcx, %rbx
	jne	.Lhrdbfw_1366
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1367:
	leal	1(%r8), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_1372
	movq	$1, 0(%r13)
	movq	%r13, %rax
	movq	$0, 8(%r13)
	addq	$72, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_1372:
	movq	%rbp, %r8
	movq	%r13, %rcx
	call	hrdbfw_app_get_ord.part.0
	addq	$72, %rsp
	movq	%r13, %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_1360:
	leaq	.Lhrdbfw_C86(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C94:

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
	jne	.Lhrdbfw_1389
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_1389:
	leaq	.Lhrdbfw_C94(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C95:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C96:

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
	jne	.Lhrdbfw_1391
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1407
	testl	%eax, %eax
	je	.Lhrdbfw_1399
	cmpl	$9, %eax
	jne	.Lhrdbfw_1395
.Lhrdbfw_1399:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1407:
	testl	$65280, %r11d
	je	.Lhrdbfw_1399
.Lhrdbfw_1394:
	leaq	.Lhrdbfw_C95(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1391:
	cmpl	$2, %eax
	je	.Lhrdbfw_1394
.Lhrdbfw_1395:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C97:

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
	je	.Lhrdbfw_1412
	testl	%eax, %eax
	jne	.Lhrdbfw_1413
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_1412:
	leaq	.Lhrdbfw_C95(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1413:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C98:

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
	jne	.Lhrdbfw_1415
	movq	%rcx, 32(%rsp)
	movq	%rdx, 40(%rsp)
	cmpb	$11, %r8b
	je	.Lhrdbfw_1457
	leaq	32(%rsp), %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1421
.Lhrdbfw_1425:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1421:
	cmpl	$2, %eax
	jne	.Lhrdbfw_1425
.Lhrdbfw_1424:
	leaq	.Lhrdbfw_C95(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1415:
	leaq	32(%rsp), %r12
	movq	%rcx, 32(%rsp)
	movzbl	%cl, %r13d
	movq	%r12, %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1421
	cmpl	$12, %r13d
	jne	.Lhrdbfw_1422
	testl	$65280, %r11d
	jne	.Lhrdbfw_1424
.Lhrdbfw_1423:
	movq	%r12, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1421
	movzbl	%bl, %eax
	cmpb	$12, %bl
	je	.Lhrdbfw_1458
	testl	%eax, %eax
	je	.Lhrdbfw_1431
	cmpl	$9, %eax
	jne	.Lhrdbfw_1425
.Lhrdbfw_1431:
	cmpq	%rdi, %rsi
	jl	.Lhrdbfw_1433
	setg	%al
	movzbl	%al, %eax
.Lhrdbfw_1414:
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
.Lhrdbfw_1422:
	testl	%r13d, %r13d
	je	.Lhrdbfw_1423
	cmpl	$9, %r13d
	je	.Lhrdbfw_1423
	jmp	.Lhrdbfw_1425
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1433:
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
.Lhrdbfw_1457:
	leaq	32(%rsp), %r11
	movq	%r11, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1418
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1418
	cmpq	%rdi, %rsi
	jb	.Lhrdbfw_1433
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbfw_1414
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1458:
	andb	$-1, %bh
	je	.Lhrdbfw_1431
	jmp	.Lhrdbfw_1424
.Lhrdbfw_1418:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C100:

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
	jne	.Lhrdbfw_1460
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_1472
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_1462
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1480:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_1476
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_1472
.Lhrdbfw_1462:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_1480
.Lhrdbfw_1476:
	xorl	%eax, %eax
.Lhrdbfw_1459:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1460:
	cmpl	$8, %ebx
	je	.Lhrdbfw_1481
	cmpl	$5, %ebx
	je	.Lhrdbfw_1482
	cmpl	$7, %ebx
	je	.Lhrdbfw_1476
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1467
	cmpl	$12, %ebx
	ja	.Lhrdbfw_1467
	leaq	.Lhrdbfw_1469(%rip), %rdx
	movslq	(%rdx,%rbx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1469:
	.long	.Lhrdbfw_1468-.Lhrdbfw_1469
	.long	.Lhrdbfw_1472-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1468-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1468-.Lhrdbfw_1469
	.long	.Lhrdbfw_1467-.Lhrdbfw_1469
	.long	.Lhrdbfw_1468-.Lhrdbfw_1469
	.long	.Lhrdbfw_1468-.Lhrdbfw_1469
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1472:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1481:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1459
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_1459
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1467:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1482:
	testq	%rcx, %rcx
	js	.Lhrdbfw_1483
.Lhrdbfw_1466:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C99(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_1459
.Lhrdbfw_1468:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_1459
.Lhrdbfw_1483:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_1466
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C101:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.199:
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
.zero 2440
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
.Lhrdbfw_C99:
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
