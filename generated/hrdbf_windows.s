	.text
	.p2align 4
hrdbfw_local_dset:
	leaq	32778(%rcx), %rax
	leaq	32937(%rcx), %r8
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
	leaq	32778(%rcx), %rax
	addq	$32937, %rcx
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
hrv_to_double:
	pushq	%rbp
	movq	(%rcx), %rax
	movq	%rdx, %r10
	movq	8(%rcx), %rcx
	movl	%eax, %edx
	movq	%rsp, %rbp
	andq	$-16, %rsp
	andl	$255, %edx
	je	.Lhrdbfw_24
	cmpl	$9, %edx
	je	.Lhrdbfw_24
	cmpl	$12, %edx
	je	.Lhrdbfw_30
	movl	$1, %r9d
	cmpl	$5, %edx
	je	.Lhrdbfw_31
	leave
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_24:
	pxor	%xmm0, %xmm0
	xorl	%r9d, %r9d
	cvtsi2sdq	%rcx, %xmm0
	movl	%r9d, %eax
	movsd	%xmm0, (%r10)
	movl	$0, (%r8)
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_31:
	movq	%rcx, %r11
	testq	%rax, %rax
	js	.Lhrdbfw_32
	shrq	$8, %rax
	movl	$2, %edx
	testl	%eax, %eax
	cmove	%edx, %eax
.Lhrdbfw_22:
	xorl	%r9d, %r9d
	movq	%r11, (%r10)
	movl	%eax, (%r8)
	movl	%r9d, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_30:
	pxor	%xmm0, %xmm0
	movzbl	%ah, %edx
	cvtsi2sdq	%rcx, %xmm0
	testb	$-1, %ah
	je	.Lhrdbfw_19
	movsd	.Lhrdbfw_C0(%rip), %xmm1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_20:
	divsd	%xmm1, %xmm0
	addl	$1, %eax
	cmpl	%edx, %eax
	jne	.Lhrdbfw_20
.Lhrdbfw_19:
	xorl	%r9d, %r9d
	movsd	%xmm0, (%r10)
	movl	%r9d, %eax
	movl	%edx, (%r8)
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_32:
	movq	(%rcx), %r11
	movzwl	8(%rcx), %eax
	jmp	.Lhrdbfw_22
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
	ja	.Lhrdbfw_33
	movl	%edx, %ebp
	movq	%rcx, %r8
	movl	%edx, %r11d
	andl	$31, %ebp
	je	.Lhrdbfw_36
	testl	%r12d, %r12d
	je	.Lhrdbfw_37
	movl	$32, %esi
	leal	-1(%r12), %edx
	movq	%rcx, %rax
	xorl	%r10d, %r10d
	subl	%ebp, %esi
	leaq	4(%rcx,%rdx,4), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_38:
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
	jne	.Lhrdbfw_38
	testl	%r10d, %r10d
	je	.Lhrdbfw_42
	leal	1(%r12), %eax
	movl	%r12d, %r12d
	movl	%eax, 288(%r8)
	movl	%r10d, (%r8,%r12,4)
.Lhrdbfw_42:
	cmpl	$31, %r11d
	jbe	.Lhrdbfw_33
	movl	288(%r8), %r10d
	leal	-1(%r10), %edx
	addl	%ebx, %r10d
	jmp	.Lhrdbfw_47
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_36:
	cmpl	$31, %edx
	jbe	.Lhrdbfw_33
	leal	-1(%r12), %edx
	testl	%r12d, %r12d
	je	.Lhrdbfw_40
.Lhrdbfw_47:
	movl	%edx, %eax
	addl	%ebx, %edx
	leaq	(%r8,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_43:
	movl	(%rax), %r9d
	movl	%edx, %ecx
	subl	$1, %edx
	movl	%r9d, (%r8,%rcx,4)
	movq	%rax, %rcx
	subq	$4, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_43
.Lhrdbfw_40:
	testl	%ebx, %ebx
	je	.Lhrdbfw_46
	leal	-1(%rbx), %edx
	movq	%r8, %rax
	leaq	4(%r8,%rdx,4), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_45:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_45
.Lhrdbfw_46:
	movl	%r10d, 288(%r8)
.Lhrdbfw_33:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_37:
	cmpl	$31, %edx
	jbe	.Lhrdbfw_33
	movl	%ebx, %r10d
	jmp	.Lhrdbfw_40
	.p2align 4
hrdbfw_local_bn_divmod_1e9:
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %edi
	testl	%edi, %edi
	je	.Lhrdbfw_66
	leal	-1(%rdi), %r9d
	movq	%rcx, %r11
	xorl	%r8d, %r8d
	movabs	$19342813113834067, %rsi
	movl	%r9d, %eax
	leaq	(%rcx,%rax,4), %r10
	movq	%r10, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_63:
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
	jne	.Lhrdbfw_63
	movl	%r8d, %eax
	cmpl	$1, %edi
	jne	.Lhrdbfw_64
	jmp	.Lhrdbfw_61
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_65:
	movl	%r9d, 288(%r11)
	subq	$4, %r10
	subl	$1, %r9d
	je	.Lhrdbfw_61
.Lhrdbfw_64:
	movl	(%r10), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_65
.Lhrdbfw_61:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_66:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4
hrdbfw_device_eq:
	testq	%rdx, %rdx
	je	.Lhrdbfw_87
	pushq	%rbx
	movq	%rdx, %r11
	movq	%rcx, %rbx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_74
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_79:
	movzwl	(%rbx,%rcx,2), %eax
	leal	-97(%rax), %r10d
	leal	-32(%rax), %r9d
	cmpl	$26, %r10d
	cmovb	%r9d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_81
	addq	$1, %rcx
	cmpq	%rcx, %r11
	je	.Lhrdbfw_78
.Lhrdbfw_74:
	movzbl	(%r8,%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_79
.Lhrdbfw_81:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_78:
	addq	%r11, %r8
	xorl	%eax, %eax
	popq	%rbx
	cmpb	$0, (%r8)
	sete	%al
	ret
.Lhrdbfw_87:
	xorl	%eax, %eax
	cmpb	$0, (%r8)
	sete	%al
	ret
	.p2align 4
hrdbfw_local_fset:
	leaq	hrdbfw_local_fsink(%rip), %r9
	movq	%r9, %rax
	leaq	159(%r9), %r8
	jmp	.Lhrdbfw_89
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_91:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_90
.Lhrdbfw_89:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_91
.Lhrdbfw_90:
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
	jb	.Lhrdbfw_93
	jmp	.Lhrdbfw_94
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_95:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_94
.Lhrdbfw_93:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_95
.Lhrdbfw_94:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	ret
	.p2align 4
hrdbfw_local_nxvisit:
	cmpl	$63, %r8d
	ja	.Lhrdbfw_140
	movl	%edx, %r9d
	testl	%edx, %edx
	je	.Lhrdbfw_140
	testl	$1023, %edx
	jne	.Lhrdbfw_140
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
	ja	.Lhrdbfw_101
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
	jne	.Lhrdbfw_101
	movq	(%r10), %r14
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movzwl	32(%rbx), %eax
	addq	%r14, %rdi
	movzwl	(%rdi), %r13d
	cmpw	%ax, %r13w
	ja	.Lhrdbfw_101
	testw	%r13w, %r13w
	jne	.Lhrdbfw_125
	testl	%r8d, %r8d
	je	.Lhrdbfw_125
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_101:
	movl	$1, %eax
.Lhrdbfw_97:
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
.Lhrdbfw_140:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_125:
	leal	4(%rax,%rax), %eax
	xorl	%r12d, %r12d
	leaq	4(%rdi), %r15
	movl	%eax, 40(%rsp)
.Lhrdbfw_106:
	movzwl	%r12w, %eax
	movzwl	2(%rdi,%rax,2), %r11d
	movq	%r11, %rax
	cmpl	40(%rsp), %r11d
	jl	.Lhrdbfw_101
	movzwl	34(%rbx), %edx
	addq	%rdx, %rax
	movq	%rdx, %r10
	cmpq	$1024, %rax
	ja	.Lhrdbfw_101
	testw	%r12w, %r12w
	je	.Lhrdbfw_103
	leal	-1(%r12), %edx
	leaq	2(%rdi), %rax
	movzwl	%dx, %edx
	leal	(%r11,%r10), %ebp
	leaq	(%r15,%rdx,2), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_105:
	movzwl	(%rax), %edx
	leal	(%rdx,%r10), %ecx
	cmpl	%ecx, %r11d
	jge	.Lhrdbfw_104
	cmpl	%ebp, %edx
	jl	.Lhrdbfw_101
.Lhrdbfw_104:
	addq	$2, %rax
	cmpq	%rsi, %rax
	jne	.Lhrdbfw_105
.Lhrdbfw_103:
	addl	$1, %r12d
	cmpw	%r12w, %r13w
	jnb	.Lhrdbfw_106
	movzwl	2(%rdi), %eax
	movl	(%rdi,%rax), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_107
	movl	40(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_144
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_101
.Lhrdbfw_107:
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
.Lhrdbfw_121:
	movzwl	2(%rsi), %r13d
	movl	(%rdi,%r13), %edx
	movq	%r13, %r12
	testl	%edx, %edx
	setne	%al
	cmpb	55(%rsp), %al
	jne	.Lhrdbfw_101
	testl	%ebp, %ebp
	jne	.Lhrdbfw_109
.Lhrdbfw_112:
	cmpq	%rsi, 40(%rsp)
	je	.Lhrdbfw_110
	movl	4(%rdi,%r13), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_114
	movq	8(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_114
	cmpl	36(%rbx), %eax
	jbe	.Lhrdbfw_114
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
	jne	.Lhrdbfw_114
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
	je	.Lhrdbfw_115
	xorl	%ecx, %ecx
	leaq	(%r14,%r11), %r9
	addq	%r13, %r8
	jmp	.Lhrdbfw_116
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_146:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_145
.Lhrdbfw_116:
	movzbl	(%r8,%rcx), %r13d
	cmpb	%r13b, (%r9,%rcx)
	je	.Lhrdbfw_146
.Lhrdbfw_114:
	movl	$4, %eax
	jmp	.Lhrdbfw_97
.Lhrdbfw_109:
	movl	64(%rsp), %r8d
	movq	%rbx, %rcx
	call	hrdbfw_local_nxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_112
	jmp	.Lhrdbfw_97
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_145:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_124
.Lhrdbfw_143:
	movq	16(%r10), %r9
.Lhrdbfw_119:
	movl	%ecx, %r8d
	addl	$1, %ecx
	addq	$2, %rsi
	leaq	(%r9,%r8,8), %r8
	movl	%edx, (%r8)
	movl	%eax, 4(%r8)
	movl	%ecx, 36(%rbx)
	cmpq	%rsi, 56(%rsp)
	jne	.Lhrdbfw_121
.Lhrdbfw_110:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_97
.Lhrdbfw_144:
	movl	%r8d, 40(%rbx)
	jmp	.Lhrdbfw_107
.Lhrdbfw_124:
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	addq	%r14, %r12
	leaq	(%r9,%r8,8), %r8
	movl	4(%r8), %r10d
	movl	(%r8), %r13d
	addq	%r10, %r12
	leaq	(%r14,%r10), %r8
	movq	%r12, 72(%rsp)
	jmp	.Lhrdbfw_120
.Lhrdbfw_118:
	addq	$1, %r8
	cmpq	72(%rsp), %r8
	je	.Lhrdbfw_122
.Lhrdbfw_120:
	movq	%r8, %r12
	subq	%r10, %r12
	movzbl	(%r12,%r11), %r12d
	cmpb	%r12b, (%r8)
	je	.Lhrdbfw_118
	jb	.Lhrdbfw_119
	jmp	.Lhrdbfw_101
.Lhrdbfw_115:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_143
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	movl	(%r9,%r8,8), %r13d
.Lhrdbfw_122:
	cmpl	%r13d, %edx
	ja	.Lhrdbfw_119
	jmp	.Lhrdbfw_101
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
	ja	.Lhrdbfw_168
	testq	%rdx, %rdx
	je	.Lhrdbfw_168
	testl	$1023, %r8d
	jne	.Lhrdbfw_169
	testq	%r9, %r9
	je	.Lhrdbfw_169
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_211
	cmpw	$6, (%rdx)
	movl	$2, %eax
	jne	.Lhrdbfw_211
	cmpw	$0, 16(%rdx)
	jne	.Lhrdbfw_211
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
	jmp	.Lhrdbfw_150
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_149:
	addq	$1, %rax
	cmpq	$486, %rax
	je	.Lhrdbfw_214
.Lhrdbfw_150:
	cmpq	$11, %rax
	jbe	.Lhrdbfw_149
	cmpb	$0, 538(%rdx,%rax)
	je	.Lhrdbfw_149
.Lhrdbfw_183:
	movl	$2, %eax
.Lhrdbfw_147:
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
.Lhrdbfw_168:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_211:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_169:
	ret
.Lhrdbfw_214:
	movzwl	14(%rdx), %r13d
	movl	$1, %eax
	leal	-1(%r13), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbfw_147
	leal	8(%r13), %r14d
	cmpw	%r14w, 12(%rdx)
	jne	.Lhrdbfw_147
	movzwl	18(%rdx), %r15d
	leal	-1(%r15), %ecx
	cmpw	$509, %cx
	ja	.Lhrdbfw_147
	movl	%r15d, %ecx
	shrw $1, %cx
	cmpw	20(%rdx), %cx
	jne	.Lhrdbfw_147
	leal	1(%r15), %ecx
	movzwl	%r14w, %r11d
	xorl	%edi, %edi
	movzwl	%cx, %r10d
	addq	%rcx, %rcx
	imulq	%r11, %r10
	andl	$131070, %ecx
	leaq	2(%r10,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbfw_151
	jmp	.Lhrdbfw_147
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_152:
	addq	$1, %rdi
	cmpq	$256, %rdi
	je	.Lhrdbfw_183
.Lhrdbfw_151:
	cmpb	$0, 22(%rdx,%rdi)
	jne	.Lhrdbfw_152
	testq	%rdi, %rdi
	je	.Lhrdbfw_183
	movzwl	36(%r9), %eax
	movw	%ax, 46(%rsp)
	testq	%rax, %rax
	je	.Lhrdbfw_183
	movq	%r8, 192(%rsp)
	movq	%r9, %rbp
	xorl	%r12d, %r12d
	movq	%rax, %r8
.Lhrdbfw_153:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_162
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_215:
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
	jne	.Lhrdbfw_155
	addq	$1, %rcx
	cmpq	%rdi, %rcx
	jnb	.Lhrdbfw_154
	cmpq	$10, %rcx
	ja	.Lhrdbfw_154
.Lhrdbfw_162:
	movzbl	42(%rbp,%rcx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_215
.Lhrdbfw_155:
	cmpq	%rdi, %rcx
	je	.Lhrdbfw_167
.Lhrdbfw_159:
	addq	$1, %r12
	addq	$16, %rbp
	cmpq	%r8, %r12
	jne	.Lhrdbfw_153
	jmp	.Lhrdbfw_183
.Lhrdbfw_154:
	cmpq	%rdi, %rcx
	jne	.Lhrdbfw_159
	cmpq	$11, %rcx
	je	.Lhrdbfw_160
.Lhrdbfw_167:
	movq	%r12, %rax
	salq	$4, %rax
	addq	%r9, %rax
	cmpb	$0, 42(%rcx,%rax)
	jne	.Lhrdbfw_159
.Lhrdbfw_160:
	movq	192(%rsp), %r8
	movl	%r12d, %r10d
	cmpw	%r12w, 46(%rsp)
	je	.Lhrdbfw_183
	movq	%r12, %rcx
	movl	$2, %eax
	salq	$4, %rcx
	addq	%r9, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbfw_147
	movzbl	54(%rcx), %ecx
	cmpw	%r13w, %cx
	jne	.Lhrdbfw_147
	movl	16(%r9), %eax
	cmpq	216(%rsp), %rax
	ja	.Lhrdbfw_189
	cmpq	$0, 208(%rsp)
	jne	.Lhrdbfw_190
	testl	%eax, %eax
	jne	.Lhrdbfw_189
.Lhrdbfw_190:
	movq	%r8, %rcx
	addq	$7, %rax
	shrq	$10, %rcx
	shrq	$3, %rax
	addq	$7, %rcx
	shrq	$3, %rcx
	cmpq	$0, 224(%rsp)
	je	.Lhrdbfw_189
	addq	%rcx, %rax
	cmpq	232(%rsp), %rax
	ja	.Lhrdbfw_189
	movq	224(%rsp), %r11
	addq	%r11, %rax
.Lhrdbfw_164:
	movb	$0, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_164
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
	jne	.Lhrdbfw_165
	movq	200(%rsp), %r9
	movl	84(%rsp), %edx
	cmpl	16(%r9), %edx
	je	.Lhrdbfw_166
	movl	$4, %eax
.Lhrdbfw_165:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_147
.Lhrdbfw_166:
	movl	%edx, 24(%rbx)
	jmp	.Lhrdbfw_147
.Lhrdbfw_189:
	movl	$3, %eax
	jmp	.Lhrdbfw_147
	.p2align 4
hrdbfw_local_nxputslot:
	movq	%rdx, %r11
	pushq	%rbx
	movl	48(%rsp), %edx
	movq	%rcx, %r10
	imulq	%r11, %r9
	movl	72(%rsp), %eax
	movq	64(%rsp), %rcx
	movzbl	%dh, %ebx
	addq	%r9, %r8
	movw	%r8w, 2(%r10,%r11,2)
	leaq	(%r10,%r8), %r9
	movl	%edx, %r11d
	shrl	$24, %edx
	movb	%dl, 3(%r9)
	movl	56(%rsp), %edx
	shrl	$16, %r11d
	movb	$0, (%r9)
	movb	%bl, 1(%r9)
	movb	%r11b, 2(%r9)
	movl	%edx, 4(%r10,%r8)
	movzwl	%ax, %r8d
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_218:
	xorl	%edx, %edx
	testq	%rcx, %rcx
	je	.Lhrdbfw_217
	movzbl	(%rcx,%rax), %edx
.Lhrdbfw_217:
	movb	%dl, 8(%r9,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_218
	popq	%rbx
	ret
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
	jne	.Lhrdbfw_229
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.Lhrdbfw_231
.Lhrdbfw_229:
	movl	$1, %eax
.Lhrdbfw_223:
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
.Lhrdbfw_231:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.Lhrdbfw_223
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.Lhrdbfw_223
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.Lhrdbfw_223
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.Lhrdbfw_229
	cmpl	%r10d, %r13d
	jb	.Lhrdbfw_229
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbfw_223
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
	je	.Lhrdbfw_233
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_234:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.Lhrdbfw_234
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.Lhrdbfw_235
	testl	%edx, %edx
	je	.Lhrdbfw_235
.Lhrdbfw_237:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_235:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.Lhrdbfw_237
.Lhrdbfw_243:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbfw_237
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_237
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.Lhrdbfw_238
	xorl	%eax, %eax
	jmp	.Lhrdbfw_239
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_256:
	movq	(%rsi), %rcx
.Lhrdbfw_239:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbfw_256
.Lhrdbfw_238:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.Lhrdbfw_242
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_241:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_241
.Lhrdbfw_242:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_233:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_243
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
	je	.Lhrdbfw_260
	cmpl	$1023, %edx
	ja	.Lhrdbfw_311
.Lhrdbfw_260:
	movl	$1, %r12d
.Lhrdbfw_257:
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
.Lhrdbfw_311:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.Lhrdbfw_260
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_260
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
	jne	.Lhrdbfw_260
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.Lhrdbfw_261
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.Lhrdbfw_260
.Lhrdbfw_261:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_312
	cmpl	%r10d, %ecx
	jne	.Lhrdbfw_260
	cmpl	%edx, 312(%rax)
	jne	.Lhrdbfw_260
.Lhrdbfw_283:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.Lhrdbfw_265
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_260
	testl	$511, %ecx
	jne	.Lhrdbfw_260
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.Lhrdbfw_260
.Lhrdbfw_265:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.Lhrdbfw_266
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_313
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_260
.Lhrdbfw_268:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	hrdbfw_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_257
	testl	%r13d, %r13d
	je	.Lhrdbfw_278
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.Lhrdbfw_269:
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
	jne	.Lhrdbfw_288
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_271
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.Lhrdbfw_271
	cmpl	48(%rbx), %edx
	jbe	.Lhrdbfw_271
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.Lhrdbfw_271
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
	je	.Lhrdbfw_272
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.Lhrdbfw_273
.Lhrdbfw_315:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbfw_314
	movq	%rdx, %rax
.Lhrdbfw_273:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.Lhrdbfw_315
.Lhrdbfw_271:
	movl	$4, %r12d
	jmp	.Lhrdbfw_257
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_312:
	cmpl	$-1, %r10d
	jne	.Lhrdbfw_260
	jmp	.Lhrdbfw_283
.Lhrdbfw_266:
	testl	%r13d, %r13d
	je	.Lhrdbfw_260
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.Lhrdbfw_260
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.Lhrdbfw_281:
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
	jne	.Lhrdbfw_257
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.Lhrdbfw_260
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
	jne	.Lhrdbfw_260
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_279
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.Lhrdbfw_280
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_316:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_279
.Lhrdbfw_280:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.Lhrdbfw_316
	jmp	.Lhrdbfw_260
.Lhrdbfw_313:
	movl	%r8d, 52(%rbx)
	jmp	.Lhrdbfw_268
.Lhrdbfw_279:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.Lhrdbfw_257
	movzwl	%r8w, %eax
	jmp	.Lhrdbfw_281
.Lhrdbfw_314:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_286
.Lhrdbfw_310:
	movq	16(%r14), %rcx
.Lhrdbfw_276:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.Lhrdbfw_269
	movzwl	94(%rsp), %edi
.Lhrdbfw_278:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbfw_257
.Lhrdbfw_286:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.Lhrdbfw_277
.Lhrdbfw_275:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.Lhrdbfw_284
	movq	%r11, %r8
.Lhrdbfw_277:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.Lhrdbfw_275
	jb	.Lhrdbfw_276
	jmp	.Lhrdbfw_260
.Lhrdbfw_272:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_310
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.Lhrdbfw_284:
	cmpl	%edi, %r9d
	ja	.Lhrdbfw_276
	jmp	.Lhrdbfw_260
.Lhrdbfw_288:
	movl	%eax, %r12d
	jmp	.Lhrdbfw_257
	.p2align 4
hrdbfw_local_cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.Lhrdbfw_317
	cmpb	$1, 15(%rcx)
	jne	.Lhrdbfw_317
	cmpw	$1024, 16(%rcx)
	jne	.Lhrdbfw_317
	cmpw	$512, 18(%rcx)
	jne	.Lhrdbfw_317
	cmpw	$0, 502(%rcx)
	jne	.Lhrdbfw_317
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.Lhrdbfw_320
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_340:
	cmpl	$23, %eax
	ja	.Lhrdbfw_327
.Lhrdbfw_319:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbfw_339
.Lhrdbfw_320:
	cmpb	$0, (%rcx,%rax)
	je	.Lhrdbfw_319
	testb	%dl, %dl
	je	.Lhrdbfw_340
.Lhrdbfw_327:
	movl	$2, %eax
.Lhrdbfw_317:
	ret
.Lhrdbfw_339:
	testl	%r8d, %r8d
	je	.Lhrdbfw_321
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_317
	cmpb	$67, 21(%rcx)
	jne	.Lhrdbfw_317
	cmpb	$72, 22(%rcx)
	jne	.Lhrdbfw_317
	cmpb	$66, 23(%rcx)
	jne	.Lhrdbfw_317
.Lhrdbfw_321:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_317
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.Lhrdbfw_317
	xorl	%eax, %eax
	cmpw	$0, 508(%rcx)
	setne	%al
	addl	%eax, %eax
	ret
	.p2align 4
hrdbf_app_pad_ll:
	pushq	%rbp
	movl	%edx, %r11d
	movq	%rcx, %r9
	pushq	%rdi
	movq	%rcx, %rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	testq	%rcx, %rcx
	js	.Lhrdbfw_360
	jne	.Lhrdbfw_343
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r11
	je	.Lhrdbfw_345
.Lhrdbfw_344:
	leaq	(%r8,%r9), %rdx
	leaq	(%rdx,%r11), %r10
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_349:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%r10, %rdx
	jne	.Lhrdbfw_349
	addq	%r9, %r11
.Lhrdbfw_345:
	movq	%rsp, %r10
	addq	%r11, %r8
	leaq	(%r10,%rcx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_350:
	movzbl	-1(%rdx), %r9d
	subq	$1, %rdx
	addq	$1, %r8
	movb	%r9b, -1(%r8)
	cmpq	%r10, %rdx
	jne	.Lhrdbfw_350
	addq	$40, %rsp
	leaq	(%rcx,%r11), %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_360:
	negq	%r9
.Lhrdbfw_343:
	xorl	%ecx, %ecx
	leaq	-1(%rsp), %rbp
	movabs	$-3689348814741910323, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_346:
	movq	%r9, %rax
	movq	%rcx, %rbx
	addq	$1, %rcx
	mulq	%rsi
	movq	%r9, %rax
	shrq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r10
	addq	%r10, %r10
	subq	%r10, %rax
	addl	$48, %eax
	movb	%al, 0(%rbp,%rcx)
	movq	%r9, %rax
	movq	%rdx, %r9
	cmpq	$9, %rax
	ja	.Lhrdbfw_346
	testq	%rdi, %rdi
	jns	.Lhrdbfw_352
	movb	$45, (%r8)
	addq	$2, %rbx
	movl	$1, %r9d
.Lhrdbfw_347:
	subq	%rbx, %r11
	jne	.Lhrdbfw_344
	movq	%r9, %r11
	jmp	.Lhrdbfw_345
.Lhrdbfw_352:
	movq	%rcx, %rbx
	xorl	%r9d, %r9d
	jmp	.Lhrdbfw_347
	.p2align 4
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.Lhrdbfw_362
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_363:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_363
.Lhrdbfw_362:
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
	movq	32968(%rcx), %rcx
	call SetFilePointerEx
	testl	%eax, %eax
	je	.Lhrdbfw_370
	leaq WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.Lhrdbfw_371
	jmp	.Lhrdbfw_372
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_383:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_370
	cmpq	%rax, %rbx
	jb	.Lhrdbfw_370
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.Lhrdbfw_372
.Lhrdbfw_371:
	movq	32968(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.Lhrdbfw_383
.Lhrdbfw_370:
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
.Lhrdbfw_372:
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
	ja	.Lhrdbfw_384
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_464
	cmpb	$78, %r9b
	je	.Lhrdbfw_465
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_466
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_411
	cmpb	$89, %al
	je	.Lhrdbfw_411
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_384
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_384
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_384:
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
.Lhrdbfw_411:
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
.Lhrdbfw_465:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_388
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_389
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_390:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_388
.Lhrdbfw_389:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_390
	jmp	.Lhrdbfw_392
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_416:
	movl	%r9d, %ecx
.Lhrdbfw_392:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_391
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_416
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_394
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_414:
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
	jmp	.Lhrdbfw_398
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_468:
	testl	%esi, %esi
	jne	.Lhrdbfw_435
	movl	$1, %esi
.Lhrdbfw_396:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_467
.Lhrdbfw_398:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_468
.Lhrdbfw_435:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_428
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_425
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_396
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_396
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_464:
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
.Lhrdbfw_466:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_407:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_427
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_407
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_384
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_428:
	movl	$5, %r11d
	jmp	.Lhrdbfw_384
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_427:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_406:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_428
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_406
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
	jbe	.Lhrdbfw_384
	cmpl	$11, %edx
	ja	.Lhrdbfw_384
	testl	%r10d, %r10d
	je	.Lhrdbfw_384
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_469
.Lhrdbfw_409:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_384
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_384
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_394:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_395:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_428
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_414
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_425:
	movl	$4, %r11d
	jmp	.Lhrdbfw_384
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_467:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_384
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_384
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_399
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_400
	jmp	.Lhrdbfw_425
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_401:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_425
.Lhrdbfw_400:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_401
	testl	%r12d, %r12d
	jne	.Lhrdbfw_413
.Lhrdbfw_404:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_384
.Lhrdbfw_391:
	je	.Lhrdbfw_388
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_394
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_395
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_388:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_384
.Lhrdbfw_469:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_409
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_410
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_409
.Lhrdbfw_410:
	addl	$1, %edx
	jmp	.Lhrdbfw_409
.Lhrdbfw_399:
	testl	%r12d, %r12d
	je	.Lhrdbfw_404
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_404
.Lhrdbfw_413:
	negq	%rbx
	jmp	.Lhrdbfw_404
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
	je	.Lhrdbfw_473
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_485
.Lhrdbfw_473:
	xorl	%r12d, %r12d
.Lhrdbfw_472:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_474
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_486
	movl	$7, %r12d
.Lhrdbfw_474:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_470
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_477
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_470:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_486:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_474
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_485:
	movl	$7, %r12d
	jmp	.Lhrdbfw_472
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_477:
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
	jne	.Lhrdbfw_487
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_487:
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
	ja	.Lhrdbfw_493
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_493
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_493
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_493
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_493
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_489
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_489
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_489
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_489
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_493
	testl	$511, %r12d
	jne	.Lhrdbfw_493
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_493
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_489
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_489
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_493
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_493
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_489
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
	jne	.Lhrdbfw_489
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_493
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_493
	testl	$511, %eax
	jne	.Lhrdbfw_493
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_493
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_493
	cmpl	%r12d, %eax
	je	.Lhrdbfw_493
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_493
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_494
.Lhrdbfw_567:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_531
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_566
.Lhrdbfw_494:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_567
.Lhrdbfw_531:
	movl	$2, %eax
	jmp	.Lhrdbfw_489
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_493:
	movl	$1, %eax
.Lhrdbfw_489:
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
.Lhrdbfw_566:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_489
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_531
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_531
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_531
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_495:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_531
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_495
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_496:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_531
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_505:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_499
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_500
	subl	$32, %ecx
.Lhrdbfw_500:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_501
	subl	$32, %r13d
.Lhrdbfw_501:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_499
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_497
	cmpq	$11, %rdx
	jne	.Lhrdbfw_505
	cmpq	$11, %rax
	jne	.Lhrdbfw_499
.Lhrdbfw_503:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_531
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_531
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_530
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_531
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_535
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_537
	testl	%eax, %eax
	jne	.Lhrdbfw_535
.Lhrdbfw_537:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_535
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_535
	xorl	%edx, %edx
.Lhrdbfw_507:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_507
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_508
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_508:
	testb	$2, %al
	jne	.Lhrdbfw_509
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_509:
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
.Lhrdbfw_510:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_510
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_568
.Lhrdbfw_511:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_489
.Lhrdbfw_497:
	cmpq	$11, %rax
	je	.Lhrdbfw_503
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_503
.Lhrdbfw_499:
	addq	$1, %r9
	jmp	.Lhrdbfw_496
.Lhrdbfw_535:
	movl	$3, %eax
	jmp	.Lhrdbfw_489
.Lhrdbfw_530:
	movl	$5, %eax
	jmp	.Lhrdbfw_489
.Lhrdbfw_568:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_511
	xorl	%edx, %edx
	jmp	.Lhrdbfw_513
.Lhrdbfw_569:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_538
.Lhrdbfw_513:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_512
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_512:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_569
.Lhrdbfw_538:
	testl	%eax, %eax
	jne	.Lhrdbfw_511
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_489
	.p2align 4
hrdbfw_local_put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.Lhrdbfw_570
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.Lhrdbfw_591
	subl	%r10d, %edx
	je	.Lhrdbfw_576
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_577:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.Lhrdbfw_577
.Lhrdbfw_576:
	testl	%r10d, %r10d
	je	.Lhrdbfw_575
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_578:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.Lhrdbfw_578
.Lhrdbfw_575:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_570:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_591:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.Lhrdbfw_575
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_574:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.Lhrdbfw_575
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_574
	jmp	.Lhrdbfw_575
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
	ja	.Lhrdbfw_592
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.Lhrdbfw_618
	cmpb	%r8b, %r13b
	jnb	.Lhrdbfw_618
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.Lhrdbfw_594
	negq	%rcx
	movl	$1, %r11d
.Lhrdbfw_594:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_595
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.Lhrdbfw_596
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_597:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.Lhrdbfw_597
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq $1, %r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.Lhrdbfw_598
.Lhrdbfw_596:
	addq	$1, %rcx
.Lhrdbfw_598:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_603:
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
	ja	.Lhrdbfw_603
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
	ja	.Lhrdbfw_646
	testl	%r11d, %r11d
	je	.Lhrdbfw_609
	movb	$45, 96(%rsp)
.Lhrdbfw_609:
	cmpl	%r10d, %ebp
	jb	.Lhrdbfw_647
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.Lhrdbfw_611:
	testb	%r13b, %r13b
	je	.Lhrdbfw_613
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.Lhrdbfw_614
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_615:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.Lhrdbfw_615
	addl	%ebp, %eax
.Lhrdbfw_614:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_616:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.Lhrdbfw_616
.Lhrdbfw_613:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_592:
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
.Lhrdbfw_618:
	movl	$4, %eax
	jmp	.Lhrdbfw_592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_595:
	jnb	.Lhrdbfw_598
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.Lhrdbfw_598
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_599
	xorl	%eax, %eax
	jmp	.Lhrdbfw_600
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_602:
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_599
.Lhrdbfw_600:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.Lhrdbfw_602
	jmp	.Lhrdbfw_598
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_647:
	testl	%r14d, %r14d
	je	.Lhrdbfw_622
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.Lhrdbfw_612
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_648:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.Lhrdbfw_612:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.Lhrdbfw_648
	jmp	.Lhrdbfw_611
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_646:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_607:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbfw_607
	xorl	%eax, %eax
	jmp	.Lhrdbfw_592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_599:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_601:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_601
	xorl	%eax, %eax
	jmp	.Lhrdbfw_592
.Lhrdbfw_622:
	movl	%r11d, %edx
	jmp	.Lhrdbfw_611
	.p2align 4
hrdbfw_local_bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_698
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.Lhrdbfw_701
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.Lhrdbfw_657
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.Lhrdbfw_659
.Lhrdbfw_658:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_662
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_661:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.Lhrdbfw_702
	movl	%eax, %ecx
.Lhrdbfw_662:
	cmpl	%ecx, %r10d
	jbe	.Lhrdbfw_661
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbfw_661
.Lhrdbfw_660:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.Lhrdbfw_659
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.Lhrdbfw_667
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_666:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.Lhrdbfw_666
.Lhrdbfw_667:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.Lhrdbfw_659
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_668:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_668
.Lhrdbfw_659:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.Lhrdbfw_649
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_669
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_670:
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
	jne	.Lhrdbfw_670
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.Lhrdbfw_649
	movl	%edi, 288(%r9)
	jmp	.Lhrdbfw_649
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_701:
	testl	%r10d, %r10d
	je	.Lhrdbfw_652
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_654:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_654
	testl	%eax, %eax
	je	.Lhrdbfw_652
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_655:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_655
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.Lhrdbfw_652
	jne	.Lhrdbfw_677
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.Lhrdbfw_652
.Lhrdbfw_677:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_652:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.Lhrdbfw_649:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_698:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_657:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.Lhrdbfw_658
	jmp	.Lhrdbfw_660
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_702:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_660
.Lhrdbfw_669:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.Lhrdbfw_649
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
.Lhrdbfw_704:
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
	jbe	.Lhrdbfw_712
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_704
.Lhrdbfw_712:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_710:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_706
	jmp	.Lhrdbfw_707
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_708:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_707
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_706:
	testb	%cl, %cl
	jne	.Lhrdbfw_708
.Lhrdbfw_707:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_703
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_710
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_703:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
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
	cmpq	$1073741824, %rbp
	ja	.Lhrdbfw_719
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call VirtualAlloc
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_727
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 32952(%rbx)
	je	.Lhrdbfw_724
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_721:
	movq	32944(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	32952(%rbx), %rax
	jb	.Lhrdbfw_721
.Lhrdbfw_724:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.Lhrdbfw_723
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_722:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbfw_722
	addq	%r14, %rdx
.Lhrdbfw_723:
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
	je	.Lhrdbfw_739
.Lhrdbfw_725:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call VirtualFree
.Lhrdbfw_719:
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
.Lhrdbfw_739:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_725
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_725
	xorl	%edx, %edx
	movq	32944(%rbx), %rcx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_730
	movl	16(%rbx), %eax
	xorl	%edx, %edx
	movq	%r13, (%rbx)
	movq	%r13, 32944(%rbx)
	leal	1(%rax), %esi
	movq	%rbp, 32952(%rbx)
	movq	%rbp, 8(%rbx)
	movl	%esi, 16(%rbx)
	movq	%rsi, 24(%rbx)
	movw	%dx, 38(%rbx)
	movl	%esi, (%rdi)
	jmp	.Lhrdbfw_719
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_727:
	movl	$8, %r15d
	jmp	.Lhrdbfw_719
.Lhrdbfw_730:
	movl	$7, %r15d
	jmp	.Lhrdbfw_725
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
	je	.Lhrdbfw_748
	movabs	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.Lhrdbfw_986
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.Lhrdbfw_746:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_751:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_752:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_752
	testq	%rax, %rax
	je	.Lhrdbfw_753
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.Lhrdbfw_753:
	subl	$1, %r9d
	jne	.Lhrdbfw_751
	testb	%r11b, %r11b
	je	.Lhrdbfw_755
	movl	%r10d, 352(%rsp)
.Lhrdbfw_755:
	testl	%r12d, %r12d
	js	.Lhrdbfw_756
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_983:
	movl	352(%rsp), %eax
.Lhrdbfw_759:
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_757
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_762:
	cmpq	$80, %rbx
	je	.Lhrdbfw_987
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.Lhrdbfw_757:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.Lhrdbfw_762
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_762
	testl	%ebx, %ebx
	jne	.Lhrdbfw_988
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_747
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.Lhrdbfw_989
.Lhrdbfw_748:
	xorl	%eax, %eax
.Lhrdbfw_740:
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
.Lhrdbfw_986:
	testq	%rax, %rax
	jne	.Lhrdbfw_990
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.Lhrdbfw_747
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.Lhrdbfw_748
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_750:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_750
	jmp	.Lhrdbfw_740
.Lhrdbfw_747:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.Lhrdbfw_748
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.Lhrdbfw_740
.Lhrdbfw_990:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.Lhrdbfw_746
.Lhrdbfw_756:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	hrdbfw_local_bn_shr_round
	cmpl	$1, %eax
	jbe	.Lhrdbfw_983
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_855
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.Lhrdbfw_761:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.Lhrdbfw_761
	testq	%rdx, %rdx
	je	.Lhrdbfw_759
	leal	1(%rax), %edx
.Lhrdbfw_760:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.Lhrdbfw_759
.Lhrdbfw_987:
	movl	$79, %r10d
.Lhrdbfw_765:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.Lhrdbfw_769:
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
	ja	.Lhrdbfw_769
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.Lhrdbfw_771
.Lhrdbfw_991:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_771:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.Lhrdbfw_991
	testl	%r10d, %r10d
	je	.Lhrdbfw_772
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.Lhrdbfw_774:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_773:
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
	jne	.Lhrdbfw_773
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.Lhrdbfw_992
	movq	%rax, %rbp
	jmp	.Lhrdbfw_774
.Lhrdbfw_992:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.Lhrdbfw_772:
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
.Lhrdbfw_776:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_777:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_777
	testq	%rax, %rax
	je	.Lhrdbfw_778
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.Lhrdbfw_778:
	subl	$1, %r9d
	jne	.Lhrdbfw_776
	testb	%dil, %dil
	je	.Lhrdbfw_780
	movl	%r10d, 656(%rsp)
.Lhrdbfw_780:
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
	je	.Lhrdbfw_781
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
.Lhrdbfw_782:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_783:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_783
	testq	%rax, %rax
	je	.Lhrdbfw_784
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_784:
	subl	$1, %ebx
	jne	.Lhrdbfw_782
	testb	%bpl, %bpl
	je	.Lhrdbfw_786
	movl	%edi, 960(%rsp)
.Lhrdbfw_786:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_787:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.Lhrdbfw_794
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.Lhrdbfw_821:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_795:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.Lhrdbfw_795
	cmpb	$53, (%rdi)
	ja	.Lhrdbfw_796
	je	.Lhrdbfw_993
.Lhrdbfw_797:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.Lhrdbfw_994
.Lhrdbfw_799:
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
	je	.Lhrdbfw_803
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_802:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_804:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_804
	testq	%rax, %rax
	je	.Lhrdbfw_805
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.Lhrdbfw_805:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.Lhrdbfw_802
	testb	%r15b, %r15b
	je	.Lhrdbfw_803
	movl	%r9d, 1264(%rsp)
.Lhrdbfw_803:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.Lhrdbfw_808
	jnb	.Lhrdbfw_809
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_810
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_817
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_820:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.Lhrdbfw_995
.Lhrdbfw_817:
	cmpl	$-1, %eax
	jne	.Lhrdbfw_820
.Lhrdbfw_816:
	testb	$1, 40(%rsp)
	je	.Lhrdbfw_975
.Lhrdbfw_810:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.Lhrdbfw_976
	cmpl	%r12d, %ebp
	jb	.Lhrdbfw_821
.Lhrdbfw_976:
	movq	2400(%rsp), %rsi
.Lhrdbfw_794:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.Lhrdbfw_823:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.Lhrdbfw_824:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.Lhrdbfw_824
	cmpl	%r12d, %ebp
	jnb	.Lhrdbfw_825
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.Lhrdbfw_826
	jne	.Lhrdbfw_825
	testb	$1, %r8b
	jne	.Lhrdbfw_826
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.Lhrdbfw_825
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.Lhrdbfw_827
.Lhrdbfw_996:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.Lhrdbfw_825
.Lhrdbfw_827:
	cmpb	$48, (%rcx)
	je	.Lhrdbfw_996
.Lhrdbfw_826:
	addq	$1, %r8
.Lhrdbfw_825:
	movabs	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.Lhrdbfw_828:
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
	ja	.Lhrdbfw_828
	cmpl	%ebp, %ecx
	jbe	.Lhrdbfw_829
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.Lhrdbfw_833
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.Lhrdbfw_829:
	xorl	%edx, %edx
	jmp	.Lhrdbfw_831
.Lhrdbfw_997:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_831:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbfw_997
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_832
.Lhrdbfw_998:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbfw_832
	movl	%eax, %ecx
.Lhrdbfw_833:
	cmpl	$1, %ecx
	ja	.Lhrdbfw_998
.Lhrdbfw_832:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.Lhrdbfw_999
	cmpl	%ecx, %r8d
	jge	.Lhrdbfw_838
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.Lhrdbfw_844
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.Lhrdbfw_841
.Lhrdbfw_840:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.Lhrdbfw_1000
	movq	%rcx, %rdx
.Lhrdbfw_841:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.Lhrdbfw_840
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.Lhrdbfw_844
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1002:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.Lhrdbfw_1001
	movl	%edx, %r8d
.Lhrdbfw_844:
	cmpl	$1, %r8d
	jne	.Lhrdbfw_1002
.Lhrdbfw_843:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.Lhrdbfw_836
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_808:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.Lhrdbfw_813
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_815:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.Lhrdbfw_1003
.Lhrdbfw_813:
	cmpl	$-1, %edx
	jne	.Lhrdbfw_815
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.Lhrdbfw_817
	jmp	.Lhrdbfw_816
.Lhrdbfw_993:
	testb	$1, %r8b
	jne	.Lhrdbfw_796
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbfw_797
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.Lhrdbfw_798
.Lhrdbfw_1004:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_797
.Lhrdbfw_798:
	cmpb	$48, (%rax)
	je	.Lhrdbfw_1004
.Lhrdbfw_796:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.Lhrdbfw_799
.Lhrdbfw_994:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_800:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.Lhrdbfw_800
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_799
	movabs	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.Lhrdbfw_799
.Lhrdbfw_995:
	jnb	.Lhrdbfw_819
	cmpl	$1, %ecx
	je	.Lhrdbfw_975
.Lhrdbfw_819:
	testl	%ecx, %ecx
	jne	.Lhrdbfw_810
	jmp	.Lhrdbfw_816
.Lhrdbfw_1003:
	jnb	.Lhrdbfw_814
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.Lhrdbfw_817
	jmp	.Lhrdbfw_810
.Lhrdbfw_809:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_984
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_817
.Lhrdbfw_984:
	jnb	.Lhrdbfw_810
.Lhrdbfw_975:
	movq	2400(%rsp), %rsi
	jmp	.Lhrdbfw_823
.Lhrdbfw_814:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_984
	movl	$1, %ecx
	jmp	.Lhrdbfw_817
.Lhrdbfw_781:
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
.Lhrdbfw_789:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_790:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_790
	testq	%rax, %rax
	je	.Lhrdbfw_791
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_791:
	subl	$1, %ebx
	jne	.Lhrdbfw_789
	testb	%r11b, %r11b
	je	.Lhrdbfw_793
	movl	%edi, 960(%rsp)
.Lhrdbfw_793:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
	jmp	.Lhrdbfw_787
.Lhrdbfw_838:
	cmpl	$1, %ecx
	je	.Lhrdbfw_843
.Lhrdbfw_836:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.Lhrdbfw_845:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.Lhrdbfw_748
	testl	%r10d, %r10d
	je	.Lhrdbfw_869
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.Lhrdbfw_847:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbfw_848
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.Lhrdbfw_850:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_849
	movzbl	0(%r13,%rdx), %r11d
.Lhrdbfw_849:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_850
	addl	%r10d, %eax
.Lhrdbfw_851:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbfw_740
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.Lhrdbfw_853
.Lhrdbfw_1006:
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_871
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.Lhrdbfw_852:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.Lhrdbfw_1005
.Lhrdbfw_853:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.Lhrdbfw_1006
.Lhrdbfw_871:
	movl	$48, %r10d
	jmp	.Lhrdbfw_852
.Lhrdbfw_869:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.Lhrdbfw_847
.Lhrdbfw_999:
	jne	.Lhrdbfw_835
	cmpb	$52, 1600(%rsp)
	jbe	.Lhrdbfw_835
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.Lhrdbfw_836
.Lhrdbfw_835:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.Lhrdbfw_845
.Lhrdbfw_848:
	movb	$48, (%rdx)
	jmp	.Lhrdbfw_851
.Lhrdbfw_1005:
	addl	%r9d, %eax
	jmp	.Lhrdbfw_740
.Lhrdbfw_988:
	subl	$1, %r10d
	jmp	.Lhrdbfw_765
.Lhrdbfw_989:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_768:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_768
	jmp	.Lhrdbfw_740
.Lhrdbfw_1001:
	movl	%r8d, %ecx
	jmp	.Lhrdbfw_836
.Lhrdbfw_855:
	movl	$1, %edx
	jmp	.Lhrdbfw_760
.Lhrdbfw_1000:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.Lhrdbfw_844
	.p2align 4
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.Lhrdbfw_1014
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.Lhrdbfw_1007
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1007
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_1007:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1014:
	ret
	.section .rdata,"dr"
.Lhrdbfw_C1:

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
	jmp	.Lhrdbfw_1018
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1020:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1019
.Lhrdbfw_1018:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_1020
.Lhrdbfw_1019:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1021
	movl	$32, %ecx
	leaq	.Lhrdbfw_C1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1023:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1027
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1023
.Lhrdbfw_1027:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_1021:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1024
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_1024:
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
.Lhrdbfw_1029:
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
	jbe	.Lhrdbfw_1039
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_1029
.Lhrdbfw_1039:
	leaq	32778(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$32937, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1037:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_1031
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1033:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1032
.Lhrdbfw_1031:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1033
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_1034
	jmp	.Lhrdbfw_1032
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1035:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1032
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_1034:
	testb	%cl, %cl
	jne	.Lhrdbfw_1035
.Lhrdbfw_1032:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_1028
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_1037
.Lhrdbfw_1028:
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
	leaq	32937(%rcx), %r8
	subq	$16, %rsp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1047:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_1046
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	32778(%r10), %rax
	jmp	.Lhrdbfw_1049
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1051:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1050
.Lhrdbfw_1049:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1051
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1052
	jmp	.Lhrdbfw_1050
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1053:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1050
.Lhrdbfw_1052:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1053
.Lhrdbfw_1050:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_1047
.Lhrdbfw_1046:
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
.Lhrdbfw_C2:

.byte 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,0
	.text
	.p2align 4
hrdbfw_local_dhex:
	pushq	%rbx
	movl	%edx, %eax
	leaq	.Lhrdbfw_C2(%rip), %rbx
	movl	%edx, %r11d
	shrl	$4, %eax
	subq	$16, %rsp
	movzbl	(%rbx,%rax), %r8d
	leaq	32778(%rcx), %rax
	addq	$32937, %rcx
	movb	$0, 15(%rsp)
	movq	%rax, %rdx
	movb	%r8b, 14(%rsp)
	jmp	.Lhrdbfw_1061
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1063:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1062
.Lhrdbfw_1061:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_1063
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_1064
	jmp	.Lhrdbfw_1062
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1066:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1062
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_1064:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1066
.Lhrdbfw_1062:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_1068
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1070:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1069
.Lhrdbfw_1068:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1070
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_1071
	jmp	.Lhrdbfw_1069
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1072:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1069
.Lhrdbfw_1071:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1072
.Lhrdbfw_1069:
	movb	$0, (%rax)
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
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
	.text
	.p2align 4
hrdbfw_path.part.0:
	pushq	%r15
	movq	%rdx, %r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	movzbl	(%rcx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1150
	js	.Lhrdbfw_1084
	movabs	$-4611681598906040321, %r8
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1083
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1152:
	movl	%eax, %edx
	andl	$-65, %edx
	cmpb	$60, %dl
	je	.Lhrdbfw_1084
.Lhrdbfw_1088:
	movw	%ax, (%r15,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1151
	testb	%al, %al
	js	.Lhrdbfw_1084
	cmpq	$258, %rbx
	ja	.Lhrdbfw_1084
.Lhrdbfw_1083:
	cmpb	$63, %al
	ja	.Lhrdbfw_1152
	btq	%rax, %r8
	jc	.Lhrdbfw_1084
	cmpb	$60, %al
	je	.Lhrdbfw_1084
	cmpb	$58, %al
	jne	.Lhrdbfw_1087
	cmpq	$1, %rbx
	jne	.Lhrdbfw_1084
	movzbl	(%rcx), %eax
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	ja	.Lhrdbfw_1084
	movl	$58, %eax
	jmp	.Lhrdbfw_1088
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1087:
	cmpb	$47, %al
	jne	.Lhrdbfw_1088
	movl	$92, %eax
	jmp	.Lhrdbfw_1088
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1158:
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1094
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1084:
	xorl	%eax, %eax
.Lhrdbfw_1080:
	addq	$40, %rsp
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
.Lhrdbfw_1151:
	xorl	%eax, %eax
	xorl	%r14d, %r14d
	leaq	.Lhrdbfw_C3(%rip), %rdi
	movw	%ax, (%r15,%rbx,2)
	leaq	.Lhrdbfw_C4(%rip), %rbp
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1109
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1154:
	addq	$1, %r14
.Lhrdbfw_1091:
	cmpq	%r14, %rbx
	jb	.Lhrdbfw_1153
.Lhrdbfw_1109:
	cmpq	%r14, %rbx
	je	.Lhrdbfw_1090
	cmpw	$92, (%r15,%r14,2)
	jne	.Lhrdbfw_1154
.Lhrdbfw_1090:
	movq	%r14, %rsi
	subq	%rax, %rsi
	je	.Lhrdbfw_1092
	movzwl	-2(%r15,%r14,2), %edx
	cmpw	$32, %dx
	je	.Lhrdbfw_1093
	cmpw	$46, %dx
	je	.Lhrdbfw_1093
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
.Lhrdbfw_1094:
	movl	%r13d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1096
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1097:
	movzwl	(%r12,%rax,2), %edx
.Lhrdbfw_1096:
	cmpw	$46, %dx
	je	.Lhrdbfw_1155
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_1097
	cmpw	$32, -2(%r12,%rsi,2)
	jne	.Lhrdbfw_1099
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1103:
	subq	$1, %rsi
	je	.Lhrdbfw_1099
.Lhrdbfw_1102:
	cmpw	$32, -2(%r12,%rsi,2)
	je	.Lhrdbfw_1103
.Lhrdbfw_1099:
	movq	%rdi, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	movq	%rbp, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1084
	cmpq	$4, %rsi
	jne	.Lhrdbfw_1092
	movzwl	6(%r12), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_1092
	movzwl	%r13w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_1106
.Lhrdbfw_1156:
	leaq	.Lhrdbfw_C10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_1114
	movzwl	(%r12,%rcx,2), %eax
.Lhrdbfw_1106:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1114
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_1156
	jmp	.Lhrdbfw_1084
.Lhrdbfw_1114:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_1108
.Lhrdbfw_1157:
	movzwl	(%r12,%rdx,2), %r13d
.Lhrdbfw_1108:
	movzwl	%r13w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_1092
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_1084
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_1157
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1092:
	leaq	1(%r14), %rax
	movq	%rax, %r14
	jmp	.Lhrdbfw_1091
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1093:
	cmpq	$1, %rsi
	je	.Lhrdbfw_1158
	cmpq	$2, %rsi
	jne	.Lhrdbfw_1084
	addq	%rax, %rax
	leaq	(%r15,%rax), %r12
	cmpw	$46, (%r12)
	jne	.Lhrdbfw_1084
	movzwl	2(%r15,%rax), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1094
	jmp	.Lhrdbfw_1084
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1155:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_1102
	jmp	.Lhrdbfw_1099
.Lhrdbfw_1153:
	cmpw	$92, (%r15)
	je	.Lhrdbfw_1084
	movl	$1, %eax
	cmpq	$1, %rbx
	je	.Lhrdbfw_1080
	cmpw	$58, 2(%r15)
	jne	.Lhrdbfw_1080
	cmpq	$2, %rbx
	je	.Lhrdbfw_1084
	cmpw	$92, 4(%r15)
	jne	.Lhrdbfw_1084
	jmp	.Lhrdbfw_1080
.Lhrdbfw_1150:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movw	%dx, (%r15)
	jmp	.Lhrdbfw_1080
	.p2align 4
hrntx_file_flush.part.0.constprop.0:
	movzbl	hrdbf_app_ntxpath(%rip), %eax
	testb	%al, %al
	je	.Lhrdbfw_1200
	cmpb	$92, %al
	je	.Lhrdbfw_1204
	cmpb	$47, %al
	jne	.Lhrdbfw_1164
	cmpb	$47, hrdbf_app_ntxpath+1(%rip)
	je	.Lhrdbfw_1200
.Lhrdbfw_1164:
	pushq	%r12
	leaq	hrdbf_app_ntxpath(%rip), %rcx
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$608, %rsp
	leaq	80(%rsp), %r12
	movq	%r12, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_1202
	movq	hrdbf_app_order+64(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1167
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
.Lhrdbfw_1167:
	movq	%r12, %rcx
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	movl	$1073741824, %edx
	movq	$0, 48(%rsp)
	movl	$128, 40(%rsp)
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_1202
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	movq	%rax, %rcx
	call SetFilePointerEx
	testl	%eax, %eax
	je	.Lhrdbfw_1171
	leaq SetEndOfFile(%rip), %rdi
	movq	%r12, %rcx
	call	*%rdi
	testl	%eax, %eax
	je	.Lhrdbfw_1171
	movq	hrdbf_app_order+48(%rip), %r8
	leaq WriteFile(%rip), %rsi
	xorl	%ebx, %ebx
	leaq	76(%rsp), %rbp
	testq	%r8, %r8
	jne	.Lhrdbfw_1169
	jmp	.Lhrdbfw_1170
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1205:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1171
	movq	hrdbf_app_order+48(%rip), %r8
	addq	%rax, %rbx
	cmpq	%rbx, %r8
	jbe	.Lhrdbfw_1170
.Lhrdbfw_1169:
	movq	hrdbf_app_order+32(%rip), %rdx
	subl	%ebx, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	addq	%rbx, %rdx
	call	*%rsi
	testl	%eax, %eax
	jne	.Lhrdbfw_1205
.Lhrdbfw_1171:
	movq	%r12, %rcx
.Lhrdbfw_1203:
	call CloseHandle
.Lhrdbfw_1202:
	movl	$7, %eax
.Lhrdbfw_1159:
	addq	$608, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1204:
	cmpb	$92, hrdbf_app_ntxpath+1(%rip)
	jne	.Lhrdbfw_1164
.Lhrdbfw_1200:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1170:
	movq	%r12, %rcx
	call	*%rdi
	movq	%r12, %rcx
	testl	%eax, %eax
	je	.Lhrdbfw_1203
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1202
	movl	$0, hrdbf_app_order+72(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1159
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C12:

.byte 112,97,116,104,32,105,115,32,110,111,116,32,97,32,115,117,112,112,111,114,116,101,100,32,112,108,97,105,110,32,102,105,108,101,32,112,97,116,104,32,40,114,101,115,101,114,118,101,100,32,100,101,118,105,99,101,32,110,97,109,101,32,111,114,32,99,104,97,114,97,99,116,101,114,115,41,0
	.align 8
.Lhrdbfw_C13:

.byte 79,83,32,111,112,101,110,32,102,97,105,108,101,100,32,40,50,61,109,105,115,115,105,110,103,44,32,53,61,97,99,99,101,115,115,32,100,101,110,105,101,100,44,32,51,50,61,97,110,111,116,104,101,114,32,112,114,111,103,114,97,109,32,104,97,115,32,105,116,32,111,112,101,110,41,0
.Lhrdbfw_C14:

.byte 71,101,116,70,105,108,101,83,105,122,101,69,120,32,102,97,105,108,101,100,0
	.align 8
.Lhrdbfw_C15:

.byte 102,105,108,101,32,104,97,115,32,102,101,119,101,114,32,116,104,97,110,32,116,104,101,32,51,51,32,104,101,97,100,101,114,32,98,121,116,101,115,0
.Lhrdbfw_C16:

.byte 102,105,108,101,32,115,105,122,101,32,0
.Lhrdbfw_C17:

.byte 32,101,120,99,101,101,100,115,32,116,104,101,32,49,32,71,105,66,32,108,105,109,105,116,0
	.align 8
.Lhrdbfw_C18:

.byte 102,105,108,101,32,115,105,122,101,32,105,115,32,110,111,116,32,97,32,119,104,111,108,101,32,110,117,109,98,101,114,32,111,102,32,112,97,103,101,115,0
	.align 8
.Lhrdbfw_C19:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,32,115,110,97,112,115,104,111,116,116,105,110,103,32,116,104,101,32,102,105,108,101,0
.Lhrdbfw_C20:

.byte 79,83,32,114,101,97,100,32,102,97,105,108,101,100,0
	.align 8
.Lhrdbfw_C21:

.byte 102,105,108,101,32,99,104,97,110,103,101,100,32,115,105,122,101,32,119,104,105,108,101,32,98,101,105,110,103,32,114,101,97,100,0
	.text
	.p2align 4
hrdbfw_snapshot:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$632, %rsp
	movzbl	(%rcx), %eax
	movl	752(%rsp), %ebp
	testb	%al, %al
	je	.Lhrdbfw_1210
	movq	%rdx, %rsi
	movq	%r8, %rbx
	movq	%r9, %rdi
	cmpb	$92, %al
	je	.Lhrdbfw_1254
	cmpb	$47, %al
	jne	.Lhrdbfw_1211
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_1210
.Lhrdbfw_1211:
	leaq	96(%rsp), %r12
	movq	%r12, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_1210
	cmpl	$2, %ebp
	je	.Lhrdbfw_1231
	xorl	%r8d, %r8d
	movl	$-1073741824, %edx
	cmpl	$1, %ebp
	movl	$-2147483648, %eax
	cmovne	%eax, %edx
.Lhrdbfw_1214:
	movq	%r12, %rcx
	movl	$128, 40(%rsp)
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_1255
	movq	%rax, (%rdi)
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%rax, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1256
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_1257
	cmpq	$1073741824, %r10
	jg	.Lhrdbfw_1258
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1219
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1259
.Lhrdbfw_1219:
	movq	%r10, %rdx
	movq	%r10, (%rbx)
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, (%rsi)
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1220
	movq	(%rbx), %r8
	leaq ReadFile(%rip), %rdi
	xorl	%r15d, %r15d
	leaq	76(%rsp), %rbp
	leaq GetLastError(%rip), %r13
	testq	%r8, %r8
	jne	.Lhrdbfw_1221
	jmp	.Lhrdbfw_1222
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1226:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1253
	movq	(%rbx), %r8
	movl	%eax, %edx
	movq	%r8, %rax
	subq	%r15, %rax
	cmpq	%rax, %rdx
	ja	.Lhrdbfw_1260
	addq	%rdx, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_1222
	movq	(%rsi), %rdx
.Lhrdbfw_1221:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rdi
	testl	%eax, %eax
	jne	.Lhrdbfw_1226
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_1226
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1253:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1254:
	cmpb	$92, 1(%rcx)
	jne	.Lhrdbfw_1211
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1210:
	leaq	.Lhrdbfw_C12(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_1206:
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
.Lhrdbfw_1231:
	movl	$3, %r8d
	movl	$-2147483648, %edx
	jmp	.Lhrdbfw_1214
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1257:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1222:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rbp, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rdi
	testl	%eax, %eax
	je	.Lhrdbfw_1261
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_1230
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1230
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_1206
.Lhrdbfw_1230:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1258:
	leaq	.Lhrdbfw_C16(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C17(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1260:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1253
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1256:
	call GetLastError
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1255:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1206
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1259:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1206
.Lhrdbfw_1220:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1206
.Lhrdbfw_1261:
	call GetLastError
	jmp	.Lhrdbfw_1253
	.p2align 4
hrntx_file_open.part.0.constprop.0:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	%edx, %ebx
	subq	$72, %rsp
	testl	%edx, %edx
	je	.Lhrdbfw_1284
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1265
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rdi
.Lhrdbfw_1268:
	movl	$4, %r12d
	cmpq	$67108864, %rdi
	ja	.Lhrdbfw_1265
	xorl	%edx, %edx
	leaq	7(%rcx), %rsi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	divq	%r8
	shrq	$3, %rsi
	movl	$12288, %r8d
	leaq	(%rsi,%rdi), %rdx
	leaq	7(%rax), %r12
	shrq	$3, %r12
	addq	%r12, %rdx
	movq	%rdx, hrdbf_app_order+56(%rip)
	call VirtualAlloc
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbfw_1272
	testl	%ebx, %ebx
	leaq	hrntx_open(%rip), %rdx
	leaq	hrcdx_open(%rip), %r10
	movq	%rax, 32(%rsp)
	cmove	%rdx, %r10
	addq	%r12, %rsi
	addq	%rax, %rdi
	movq	hrdbf_app_order+48(%rip), %r8
	movq	%rsi, 56(%rsp)
	movl	hrdbf_app_state+16(%rip), %esi
	leaq	hrdbf_app_state(%rip), %r9
	leaq	hrdbf_app_order(%rip), %rcx
	movq	%rdi, 48(%rsp)
	movq	hrdbf_app_order+32(%rip), %rdx
	movq	%rsi, 40(%rsp)
	call	*%r10
	movl	%eax, %r12d
	testl	%eax, %eax
	je	.Lhrdbfw_1262
	cmpl	$5, %eax
	sete	%r12b
	movzbl	%r12b, %r12d
	leal	1(%r12,%r12), %r12d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1265:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmovne	%eax, %r12d
.Lhrdbfw_1262:
	addq	$72, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1284:
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1265
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rdi
	jmp	.Lhrdbfw_1268
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1272:
	movl	$8, %r12d
	jmp	.Lhrdbfw_1265
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
	je	.Lhrdbfw_1286
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_1286:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1289
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1289
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_1291
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
.Lhrdbfw_1293:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_1303
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1289:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1291:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1294
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1303:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1294:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_1293
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
	je	.Lhrdbfw_1306
	testl	%edx, %edx
	je	.Lhrdbfw_1308
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1308
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1308:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1306:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1309
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1311
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_1311:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1309:
	ret
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C22:

.byte 39,32,99,111,110,116,101,110,116,32,105,115,32,110,111,116,32,118,97,108,105,100,32,102,111,114,32,105,116,115,32,116,121,112,101,0
	.align 8
.Lhrdbfw_C23:

.byte 39,32,110,117,109,101,114,105,99,32,99,111,110,116,101,110,116,32,111,118,101,114,102,108,111,119,115,32,105,110,116,54,52,0
.Lhrdbfw_C24:

.byte 118,101,114,115,105,111,110,32,98,121,116,101,32,48,120,0
	.align 8
.Lhrdbfw_C25:

.byte 32,105,115,32,110,111,116,32,48,120,48,51,32,40,100,66,65,83,69,32,73,73,73,32,116,97,98,108,101,32,119,105,116,104,111,117,116,32,109,101,109,111,59,32,48,120,56,51,47,48,120,70,53,32,99,97,114,114,121,32,97,32,109,101,109,111,32,102,105,108,101,41,0
.Lhrdbfw_C26:

.byte 105,109,112,108,97,117,115,105,98,108,101,32,104,101,97,100,101,114,32,108,101,110,103,116,104,32,0
.Lhrdbfw_C27:

.byte 32,111,114,32,114,101,99,111,114,100,32,108,101,110,103,116,104,32,0
.Lhrdbfw_C28:

.byte 32,102,111,114,32,102,105,108,101,32,115,105,122,101,32,0
.Lhrdbfw_C29:

.byte 102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,32,0
	.align 8
.Lhrdbfw_C30:

.byte 32,116,114,117,110,99,97,116,101,100,32,98,101,102,111,114,101,32,101,110,100,32,111,102,32,104,101,97,100,101,114,0
	.align 8
.Lhrdbfw_C31:

.byte 109,111,114,101,32,116,104,97,110,32,50,48,52,54,32,102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,0
.Lhrdbfw_C32:

.byte 32,104,97,115,32,97,110,32,101,109,112,116,121,32,110,97,109,101,0
.Lhrdbfw_C33:

.byte 102,105,101,108,100,32,39,0
.Lhrdbfw_C34:

.byte 39,32,104,97,115,32,122,101,114,111,32,119,105,100,116,104,0
.Lhrdbfw_C35:

.byte 67,32,102,105,101,108,100,32,39,0
.Lhrdbfw_C36:

.byte 39,32,100,101,99,108,97,114,101,115,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C37:

.byte 78,32,102,105,101,108,100,32,39,0
.Lhrdbfw_C38:

.byte 39,32,119,105,100,116,104,32,0
.Lhrdbfw_C39:

.byte 32,47,32,100,101,99,105,109,97,108,115,32,0
.Lhrdbfw_C40:

.byte 32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,0
.Lhrdbfw_C41:

.byte 76,32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C42:

.byte 39,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,49,32,119,105,116,104,32,110,111,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C43:

.byte 68,32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C44:

.byte 39,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,56,32,119,105,116,104,32,110,111,32,100,101,99,105,109,97,108,115,0
.Lhrdbfw_C45:

.byte 39,32,104,97,115,32,117,110,115,117,112,112,111,114,116,101,100,32,116,121,112,101,32,39,0
.Lhrdbfw_C46:

.byte 39,32,40,111,110,108,121,32,67,47,78,47,68,47,76,44,32,110,111,32,109,101,109,111,41,0
	.align 8
.Lhrdbfw_C47:

.byte 102,105,101,108,100,32,119,105,100,116,104,115,32,101,120,99,101,101,100,32,116,104,101,32,54,53,53,51,53,32,114,101,99,111,114,100,32,108,105,109,105,116,0
	.align 8
.Lhrdbfw_C48:

.byte 102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,32,110,111,116,32,116,101,114,109,105,110,97,116,101,100,32,98,121,32,48,120,48,68,0
.Lhrdbfw_C49:

.byte 116,97,98,108,101,32,100,101,99,108,97,114,101,115,32,110,111,32,102,105,101,108,100,115,0
	.align 8
.Lhrdbfw_C50:

.byte 102,105,101,108,100,32,119,105,100,116,104,115,32,112,108,117,115,32,100,101,108,101,116,101,32,102,108,97,103,32,115,117,109,32,116,111,32,0
.Lhrdbfw_C51:

.byte 32,98,117,116,32,104,101,97,100,101,114,32,114,101,99,111,114,100,32,108,101,110,103,116,104,32,105,115,32,0
	.align 8
.Lhrdbfw_C52:

.byte 110,111,110,122,101,114,111,32,98,121,116,101,32,98,101,116,119,101,101,110,32,102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,32,97,110,100,32,104,101,97,100,101,114,32,101,110,100,0
.Lhrdbfw_C53:

.byte 104,101,97,100,101,114,32,114,101,99,111,114,100,32,99,111,117,110,116,32,0
.Lhrdbfw_C54:

.byte 32,101,120,99,101,101,100,115,32,116,104,101,32,0
.Lhrdbfw_C55:

.byte 32,114,101,99,111,114,100,115,32,112,104,121,115,105,99,97,108,108,121,32,112,114,101,115,101,110,116,0
	.align 8
.Lhrdbfw_C56:

.byte 117,110,101,120,112,101,99,116,101,100,32,116,114,97,105,108,105,110,103,32,98,121,116,101,115,32,97,102,116,101,114,32,116,104,101,32,108,97,115,116,32,114,101,99,111,114,100,32,40,110,111,32,48,120,49,65,32,116,101,114,109,105,110,97,116,111,114,41,0
.Lhrdbfw_C57:

.byte 114,101,99,111,114,100,32,0
.Lhrdbfw_C58:

.byte 32,104,97,115,32,100,101,108,101,116,101,32,102,108,97,103,32,48,120,0
.Lhrdbfw_C59:

.byte 32,40,101,120,112,101,99,116,101,100,32,115,112,97,99,101,32,111,114,32,39,42,39,41,0
.Lhrdbfw_C60:

.byte 32,102,105,101,108,100,32,39,0
	.align 8
.Lhrdbfw_C61:

.byte 32,40,108,111,103,105,99,97,108,32,98,121,116,101,32,109,117,115,116,32,98,101,32,84,47,70,47,89,47,78,47,63,47,115,112,97,99,101,41,0
.Lhrdbfw_C62:

.byte 32,105,110,115,105,100,101,32,97,32,100,101,108,101,116,101,100,32,114,101,99,111,114,100,0
.Lhrdbfw_C63:

.byte 100,117,112,108,105,99,97,116,101,32,102,105,101,108,100,32,110,97,109,101,32,39,0
.Lhrdbfw_C64:

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
	subq	$104, %rsp
	movb	$0, 32778(%rcx)
	movb	$0, hrdbf_open_tmp+32778(%rip)
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	$0, hrdbf_open_tmp(%rip)
	movq	$0, hrdbf_open_tmp+8(%rip)
	movl	$0, hrdbf_open_tmp+16(%rip)
	movq	$0, hrdbf_open_tmp+24(%rip)
	movl	$16842752, hrdbf_open_tmp+36(%rip)
	movb	$0, hrdbf_open_tmp+40(%rip)
	cmpq	$32, %r8
	jbe	.Lhrdbfw_1392
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_1393
	movzwl	8(%rdx), %eax
	movq	%r8, %r13
	movw	%ax, hrdbf_open_tmp+32(%rip)
	movzwl	10(%rdx), %edi
	movw	%di, hrdbf_open_tmp+34(%rip)
	movl	4(%rdx), %ebp
	movl	%edi, 56(%rsp)
	movl	%ebp, hrdbf_open_tmp+16(%rip)
	cmpw	$32, %ax
	jbe	.Lhrdbfw_1318
	movq	%rax, 40(%rsp)
	testl	%edi, %edi
	je	.Lhrdbfw_1318
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1318
	movq	40(%rsp), %rax
	movl	%ebp, 60(%rsp)
	movl	$1, %ecx
	leaq	32(%rbx), %rsi
	movq	%r8, 192(%rsp)
	leaq	hrdbf_open_tmp(%rip), %rdi
	subq	$32, %rax
	movq	%rbx, 184(%rsp)
	movl	%ecx, %ebx
	andq	$-32, %rax
	addq	$32, %rax
	movq	%rax, 48(%rsp)
	movl	$32, %eax
	movq	%rax, %r13
.Lhrdbfw_1342:
	cmpb	$13, (%rsi)
	je	.Lhrdbfw_1394
	cmpq	48(%rsp), %r13
	je	.Lhrdbfw_1395
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	cmpw	$2046, %ax
	je	.Lhrdbfw_1396
	leal	1(%rax), %ecx
	movq	%rax, %r10
	movq	%rax, 32(%rsp)
	movzwl	%ax, %r15d
	movw	%cx, hrdbf_open_tmp+36(%rip)
	salq	$4, %r10
	xorl	%eax, %eax
	leaq	(%rdi,%r10), %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1326:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, 42(%r8,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1326
	movq	%r15, %rax
	salq	$4, %rax
	movzbl	42(%rax,%rdi), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_1327
	movzwl	%cx, %eax
	cmpw	$1, %cx
	jbe	.Lhrdbfw_1328
	movq	32(%rsp), %r9
	leal	-1(%rax), %r11d
	leaq	43(%rdi,%r10), %r14
	xorl	%r8d, %r8d
	leaq	hrdbf_open_tmp+53(%rip), %rax
	salq	$4, %r11
	negq	%r9
	addq	%rax, %r10
	salq	$4, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1329:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_1332
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1398:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_1332:
	leaq	(%rax,%r9), %rcx
	cmpb	%dl, -1(%rcx,%r8)
	jne	.Lhrdbfw_1397
	cmpq	%rax, %r10
	jne	.Lhrdbfw_1398
	leaq	.Lhrdbfw_C63(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C64(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1318:
	leaq	.Lhrdbfw_C26(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C27(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	hrdbf_open_tmp+34(%rip), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C28(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
.Lhrdbfw_1314:
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
.Lhrdbfw_1397:
	addq	$16, %r8
	cmpq	%r8, %r11
	jne	.Lhrdbfw_1329
.Lhrdbfw_1328:
	leaq	2(%r15), %rax
	movzbl	11(%rsi), %ecx
	salq	$4, %rax
	addq	%rdi, %rax
	movb	%cl, 21(%rax)
	movzbl	16(%rsi), %edx
	leaq	21(%rax), %r14
	movb	%dl, 22(%rax)
	movzbl	17(%rsi), %r8d
	movw	%bx, 24(%rax)
	movb	%r8b, 23(%rax)
	testb	%dl, %dl
	je	.Lhrdbfw_1399
	cmpb	$67, %cl
	je	.Lhrdbfw_1400
	cmpb	$78, %cl
	je	.Lhrdbfw_1401
	cmpb	$76, %cl
	je	.Lhrdbfw_1402
	cmpb	$68, %cl
	jne	.Lhrdbfw_1339
	cmpw	$8, 22(%rax)
	je	.Lhrdbfw_1335
	leaq	.Lhrdbfw_C43(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C44(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1392:
	leaq	.Lhrdbfw_C15(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1393:
	leaq	.Lhrdbfw_C24(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C25(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1400:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1403
.Lhrdbfw_1335:
	addl	%edx, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_1404
	addq	$32, %r13
	addq	$32, %rsi
	cmpq	%r13, 40(%rsp)
	ja	.Lhrdbfw_1342
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1401:
	cmpb	$17, %r8b
	ja	.Lhrdbfw_1366
	cmpb	%r8b, %dl
	ja	.Lhrdbfw_1335
.Lhrdbfw_1366:
	leaq	.Lhrdbfw_C37(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C38(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	%r15, %rax
	movq	%r12, %rcx
	addq	$2, %rax
	salq	$4, %rax
	addq	%rax, %rdi
	movzbl	22(%rdi), %edx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C39(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	23(%rdi), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C40(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$4, %eax
	jmp	.Lhrdbfw_1314
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1402:
	cmpw	$1, 22(%rax)
	je	.Lhrdbfw_1335
	leaq	.Lhrdbfw_C41(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C42(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1395:
	leaq	.Lhrdbfw_C29(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	movq	%r12, %rcx
	leaq	1(%rax), %rdx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C30(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1396:
	leaq	.Lhrdbfw_C31(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1394:
	cmpw	$0, hrdbf_open_tmp+36(%rip)
	movl	%ebx, %esi
	movq	%r13, %rax
	movl	60(%rsp), %ebp
	movq	184(%rsp), %rbx
	movq	192(%rsp), %r13
	je	.Lhrdbfw_1405
	addq	$1, %rax
	cmpl	%esi, 56(%rsp)
	je	.Lhrdbfw_1344
	jmp	.Lhrdbfw_1406
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1345:
	addq	$1, %rax
	cmpb	$0, -1(%rbx,%rax)
	jne	.Lhrdbfw_1407
.Lhrdbfw_1344:
	cmpq	%rax, 40(%rsp)
	ja	.Lhrdbfw_1345
	movl	%esi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	40(%rsp), %rax
	divq	%rcx
	movl	%ebp, %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1408
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	40(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_1347
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_1348
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_1347
.Lhrdbfw_1348:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1327:
	leaq	.Lhrdbfw_C29(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	hrdbf_open_tmp+36(%rip), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C32(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1399:
	leaq	.Lhrdbfw_C33(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C34(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1407:
	leaq	.Lhrdbfw_C52(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1404:
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1403:
	leaq	.Lhrdbfw_C35(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C36(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1406:
	leaq	.Lhrdbfw_C50(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	%esi, %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C51(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	hrdbf_open_tmp+34(%rip), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1405:
	leaq	.Lhrdbfw_C49(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1339:
	leaq	.Lhrdbfw_C33(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	hrdbfw_local_dname
	leaq	.Lhrdbfw_C45(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	(%r14), %eax
	movq	%r12, %rcx
	movb	$0, 65(%rsp)
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	leaq	64(%rsp), %rdx
	movb	%al, 64(%rsp)
	call	hrdbfw_local_dcat
	leaq	.Lhrdbfw_C46(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1347:
	testl	%ebp, %ebp
	movq	%rbx, hrdbf_open_tmp(%rip)
	sete	%al
	movq	%r13, hrdbf_open_tmp+8(%rip)
	movb	$1, hrdbf_open_tmp+40(%rip)
	movq	$1, hrdbf_open_tmp+24(%rip)
	movb	%al, hrdbf_open_tmp+39(%rip)
	movb	%al, hrdbf_open_tmp+38(%rip)
	testq	%r8, %r8
	je	.Lhrdbfw_1363
	xorl	%r13d, %r13d
	leaq	hrdbf_open_tmp(%rip), %rbp
	leaq	64(%rsp), %r8
.Lhrdbfw_1352:
	movzwl	hrdbf_open_tmp+34(%rip), %eax
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_1350
	cmpb	$42, %dil
	jne	.Lhrdbfw_1409
.Lhrdbfw_1350:
	cmpw	$0, hrdbf_open_tmp+36(%rip)
	movq	%r13, hrdbf_open_tmp+24(%rip)
	movl	$1, %esi
	movq	%rbp, %r14
	jne	.Lhrdbfw_1351
	jmp	.Lhrdbfw_1358
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1354:
	movl	%esi, %edx
	movq	%rbp, %rcx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1410
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_1358
.Lhrdbfw_1351:
	movl	$85, %eax
	cmpb	$0, hrdbf_open_tmp+40(%rip)
	movb	$0, 92(%rsp)
	movw	%ax, 64(%rsp)
	movb	$0, 66(%rsp)
	movq	$0, 72(%rsp)
	movq	$0, 80(%rsp)
	movl	$0, 88(%rsp)
	jne	.Lhrdbfw_1354
	leaq	.Lhrdbfw_C57(%rip), %rdx
	movq	%r12, %rcx
	leal	-1(%rsi), %ebx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C60(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	leal	1(%rsi), %eax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	10(%rbp,%rax), %rdx
	call	hrdbfw_local_dname
	movl	$6, %eax
	leaq	.Lhrdbfw_C22(%rip), %rdx
.Lhrdbfw_1355:
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	32(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 53(%rdx,%rbp)
	je	.Lhrdbfw_1411
.Lhrdbfw_1357:
	cmpb	$42, %dil
	jne	.Lhrdbfw_1314
	leaq	.Lhrdbfw_C62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_dcat
	movl	32(%rsp), %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1358:
	movl	hrdbf_open_tmp+16(%rip), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_1352
	cmpb	$0, hrdbf_open_tmp+40(%rip)
	je	.Lhrdbfw_1359
.Lhrdbfw_1349:
	movq	$1, hrdbf_open_tmp+24(%rip)
	testl	%eax, %eax
	sete	%dl
	movb	%dl, hrdbf_open_tmp+39(%rip)
	movb	%dl, hrdbf_open_tmp+38(%rip)
.Lhrdbfw_1359:
	movl	%eax, 16(%r12)
	movq	hrdbf_open_tmp+24(%rip), %rax
	xorl	%r8d, %r8d
	movq	hrdbf_open_tmp(%rip), %rdx
	movq	%rax, 24(%r12)
	movzwl	hrdbf_open_tmp+32(%rip), %eax
	movq	%rdx, (%r12)
	movq	hrdbf_open_tmp+8(%rip), %rdx
	movw	%ax, 32(%r12)
	movzwl	hrdbf_open_tmp+34(%rip), %eax
	movq	%rdx, 8(%r12)
	leaq	hrdbf_open_tmp(%rip), %rdx
	movw	%ax, 34(%r12)
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	movw	%ax, 36(%r12)
	movzbl	hrdbf_open_tmp+38(%rip), %eax
	movzwl	hrdbf_open_tmp+36(%rip), %r9d
	movb	%al, 38(%r12)
	movzbl	hrdbf_open_tmp+39(%rip), %eax
	movb	%al, 39(%r12)
	movl	$53, %eax
.Lhrdbfw_1360:
	cmpl	%r8d, %r9d
	jbe	.Lhrdbfw_1412
	leaq	-11(%rax), %rcx
.Lhrdbfw_1361:
	movzbl	(%r14,%rcx), %r10d
	movb	%r10b, (%r12,%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1361
	movzbl	53(%rdx), %ecx
	addl	$1, %r8d
	addq	$16, %rdx
	movb	%cl, (%r12,%rax)
	movzbl	38(%rdx), %ecx
	movb	%cl, 1(%r12,%rax)
	movzbl	39(%rdx), %ecx
	movb	%cl, 2(%r12,%rax)
	movzwl	40(%rdx), %ecx
	movw	%cx, 3(%r12,%rax)
	addq	$16, %rax
	jmp	.Lhrdbfw_1360
.Lhrdbfw_1411:
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	32(%rsp), %eax
	jmp	.Lhrdbfw_1357
.Lhrdbfw_1412:
	movb	$0, 32778(%r12)
	xorl	%eax, %eax
	movb	$1, 40(%r12)
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1408:
	leaq	.Lhrdbfw_C53(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	hrdbf_open_tmp+16(%rip), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C54(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	movzwl	hrdbf_open_tmp+34(%rip), %ecx
	movq	%r13, %rax
	subq	%rdx, %rax
	xorl	%edx, %edx
	divq	%rcx
	movq	%r12, %rcx
	movq	%rax, %rdx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C55(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1409:
	leaq	.Lhrdbfw_C57(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C58(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	%dil, %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C59(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$5, %eax
	jmp	.Lhrdbfw_1314
.Lhrdbfw_1363:
	xorl	%eax, %eax
	leaq	hrdbf_open_tmp(%rip), %r14
	jmp	.Lhrdbfw_1349
.Lhrdbfw_1410:
	leaq	.Lhrdbfw_C57(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	leal	-1(%rsi), %ebx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C60(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	leal	1(%rsi), %edx
	movq	%r12, %rcx
	salq	$4, %rdx
	leaq	10(%rbp,%rdx), %rdx
	call	hrdbfw_local_dname
	movl	32(%rsp), %eax
	leaq	.Lhrdbfw_C22(%rip), %rdx
	leaq	.Lhrdbfw_C23(%rip), %rcx
	cmpl	$4, %eax
	cmove	%rcx, %rdx
	jmp	.Lhrdbfw_1355
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
	ja	.Lhrdbfw_1415
	je	.Lhrdbfw_1446
	cmpl	$5, %edx
	je	.Lhrdbfw_1419
	shrq	$8, %rax
	jne	.Lhrdbfw_1415
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_1415
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_1415
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1415
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_1415
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
	ja	.Lhrdbfw_1433
	testq	%rcx, %rcx
	je	.Lhrdbfw_1433
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_1447
.Lhrdbfw_1421:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_1415:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1446:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_1415
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_1415
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_1433
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_1433
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1415
.Lhrdbfw_1433:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1419:
	testq	%rax, %rax
	jns	.Lhrdbfw_1428
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1415
.Lhrdbfw_1428:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1447:
	testb	$3, %r9b
	jne	.Lhrdbfw_1421
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_1422
	addl	$1, %eax
	jmp	.Lhrdbfw_1421
.Lhrdbfw_1422:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_1421
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_1448
	leaq	hrdbfw_local_CSWTCH.413(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_1448:
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
	jne	.Lhrdbfw_1453
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_1464
	testl	%edx, %edx
	je	.Lhrdbfw_1456
	cmpl	$9, %edx
	je	.Lhrdbfw_1456
	movl	$1, %eax
.Lhrdbfw_1453:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1464:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1465
.Lhrdbfw_1456:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1465:
	movl	$2, %eax
	jmp	.Lhrdbfw_1453
	.p2align 4
	.globl	hrv_equal
hrv_equal:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movq	%r8, %rbx
	andq	$-16, %rsp
	subq	$80, %rsp
	movq	(%rcx), %r11
	movq	8(%rcx), %rsi
	leaq	32(%rsp), %r12
	movq	(%rdx), %rdi
	movq	8(%rdx), %r13
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1466
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1466
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.Lhrdbfw_1468
	cmpl	$11, %r14d
	jne	.Lhrdbfw_1468
.Lhrdbfw_1479:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbfw_1466:
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
.Lhrdbfw_1468:
	cmpl	$1, %r15d
	je	.Lhrdbfw_1482
	cmpl	$1, %r14d
	je	.Lhrdbfw_1482
	cmpl	$3, %r15d
	jne	.Lhrdbfw_1471
	cmpl	$3, %r14d
	jne	.Lhrdbfw_1471
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1466
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1482:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1466
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1471:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1475
	cmpl	$12, %r15d
	je	.Lhrdbfw_1505
	testl	%r15d, %r15d
	je	.Lhrdbfw_1474
	cmpl	$9, %r15d
	jne	.Lhrdbfw_1475
.Lhrdbfw_1474:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1475
	cmpl	$12, %r14d
	je	.Lhrdbfw_1506
	testl	%r14d, %r14d
	je	.Lhrdbfw_1479
	cmpl	$9, %r14d
	je	.Lhrdbfw_1479
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1475:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1507
.Lhrdbfw_1481:
	movl	$1, %eax
	jmp	.Lhrdbfw_1466
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1505:
	testl	$65280, %r11d
	je	.Lhrdbfw_1474
	jmp	.Lhrdbfw_1475
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1507:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1481
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1466
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1506:
	testl	$65280, %edi
	je	.Lhrdbfw_1479
	jmp	.Lhrdbfw_1475
	.p2align 4
	.globl	hrv_compare
hrv_compare:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movq	%r8, %rbx
	andq	$-16, %rsp
	subq	$80, %rsp
	movq	(%rcx), %r11
	movq	8(%rcx), %r12
	leaq	32(%rsp), %r13
	movq	(%rdx), %rsi
	movq	8(%rdx), %rdi
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1508
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.Lhrdbfw_1529
.Lhrdbfw_1508:
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
.Lhrdbfw_1529:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1510
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1530
	testl	%eax, %eax
	je	.Lhrdbfw_1512
	cmpl	$9, %eax
	je	.Lhrdbfw_1512
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1510:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1531
.Lhrdbfw_1518:
	leaq	-40(%rbp), %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	popq	%r13
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1531:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1518
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.Lhrdbfw_1519
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.Lhrdbfw_1519:
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1508
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1530:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1510
.Lhrdbfw_1512:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1510
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.Lhrdbfw_1532
	testl	%edx, %edx
	je	.Lhrdbfw_1515
	cmpl	$9, %edx
	jne	.Lhrdbfw_1510
.Lhrdbfw_1515:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1508
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1532:
	testl	$65280, %esi
	je	.Lhrdbfw_1515
	jmp	.Lhrdbfw_1510
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
	jne	.Lhrdbfw_1533
	movzbl	%r11b, %ecx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_1537
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbfw_1535
	andl	$2, %edx
	jne	.Lhrdbfw_1539
.Lhrdbfw_1537:
	movl	$1, %eax
.Lhrdbfw_1533:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1535:
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
.Lhrdbfw_1539:
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
	jne	.Lhrdbfw_1540
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_1587
	cmpl	$12, %eax
	jne	.Lhrdbfw_1566
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
.Lhrdbfw_1548:
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
	ja	.Lhrdbfw_1548
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_1588
	movl	$1, %r9d
.Lhrdbfw_1549:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_1550:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_1551
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_1589
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_1559
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1558:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_1558
.Lhrdbfw_1559:
	testq	%r13, %r13
	jns	.Lhrdbfw_1557
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_1557:
	testl	%r9d, %r9d
	je	.Lhrdbfw_1560
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_1562
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1570:
	movl	%edx, %eax
.Lhrdbfw_1562:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1561
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1561:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_1570
	addl	%r9d, %r10d
.Lhrdbfw_1560:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1540
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1564:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1563
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1563:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_1564
.Lhrdbfw_1540:
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
.Lhrdbfw_1587:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_1551
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_1546
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
	jmp	.Lhrdbfw_1540
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1566:
	movl	$1, %r12d
	jmp	.Lhrdbfw_1540
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1590:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_1565
.Lhrdbfw_1545:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_1540
.Lhrdbfw_1546:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1590
.Lhrdbfw_1565:
	movl	$47, %eax
	jmp	.Lhrdbfw_1545
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1588:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1549
	movl	%r9d, %eax
	jmp	.Lhrdbfw_1550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1551:
	movl	$3, %r12d
	jmp	.Lhrdbfw_1540
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1589:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1540
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1554:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_1554
	jmp	.Lhrdbfw_1540
	.p2align 4
	.globl	hrv_arith
hrv_arith:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	movq	%r9, %rsi
	pushq	%rbx
	movl	%ecx, %ebx
	andq	$-16, %rsp
	subq	$96, %rsp
	movq	(%rdx), %r11
	movq	8(%rdx), %r14
	leaq	32(%rsp), %r15
	movq	(%r8), %rdi
	movq	8(%r8), %r12
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.Lhrdbfw_1631
	cmpl	$42, %ebx
	je	.Lhrdbfw_1631
	cmpl	$47, %ebx
	je	.Lhrdbfw_1606
	cmpl	$37, %ebx
	je	.Lhrdbfw_1633
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.Lhrdbfw_1633
.Lhrdbfw_1591:
	leaq	-56(%rbp), %rsp
	movl	%r8d, %eax
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
.Lhrdbfw_1631:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1606
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1653
	testl	%eax, %eax
	je	.Lhrdbfw_1597
	cmpl	$9, %eax
	je	.Lhrdbfw_1597
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1606:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.Lhrdbfw_1654
	testl	%r13d, %r13d
	je	.Lhrdbfw_1655
	cmpl	$42, %ebx
	je	.Lhrdbfw_1656
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1632
	jne	.Lhrdbfw_1632
	movl	$5, %r8d
	jmp	.Lhrdbfw_1591
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1653:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1606
.Lhrdbfw_1597:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1606
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.Lhrdbfw_1657
	testl	%eax, %eax
	je	.Lhrdbfw_1600
	cmpl	$9, %eax
	jne	.Lhrdbfw_1606
.Lhrdbfw_1600:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.Lhrdbfw_1658
	testl	%r13d, %r13d
	je	.Lhrdbfw_1659
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1591
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1633:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1591
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.Lhrdbfw_1615
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1616
	jne	.Lhrdbfw_1616
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.Lhrdbfw_1591
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1657:
	testl	$65280, %edi
	je	.Lhrdbfw_1600
	jmp	.Lhrdbfw_1606
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1656:
	mulsd	80(%rsp), %xmm0
	movl	72(%rsp), %eax
	movl	$255, %ecx
	addl	64(%rsp), %eax
	cmpl	$255, %eax
	cmova	%rcx, %rax
	salq	$8, %rax
	movq	%xmm0, %rdx
	orq	$5, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1609:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1591
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1632:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1609
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1654:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.Lhrdbfw_1652:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.Lhrdbfw_1609
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1655:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1652
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1658:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1591
.Lhrdbfw_1615:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabs	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.Lhrdbfw_1660
	testq	%r10, %r10
	jne	.Lhrdbfw_1625
.Lhrdbfw_1620:
	movabs	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1618
	testq	%r9, %r9
	movl	$0, %edx
	movabs	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1618:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1591
.Lhrdbfw_1659:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.Lhrdbfw_1591
.Lhrdbfw_1616:
	movsd	56(%rsp), %xmm1
	movsd	%xmm0, 80(%rsp)
	movsd	%xmm1, 72(%rsp)
	fldl 80(%rsp)
	fldl 72(%rsp)
	1: fprem
	fnstsw %ax
	test $4,%ah
	jnz 1b
	fstpl 88(%rsp)
	fstp %st(0)
	movq	88(%rsp), %rdx
	jmp	.Lhrdbfw_1618
.Lhrdbfw_1660:
	testq	%r10, %r10
	je	.Lhrdbfw_1620
	movabs	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1621
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.Lhrdbfw_1628
	jne	.Lhrdbfw_1628
.Lhrdbfw_1621:
	movq	%r10, 72(%rsp)
	movsd	%xmm0, 80(%rsp)
	fldl 80(%rsp)
	fldl 72(%rsp)
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
	fstpl 88(%rsp)
	movabs	$4841369599423283199, %rcx
	movq	88(%rsp), %rdx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_1618
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.Lhrdbfw_1618
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.Lhrdbfw_1618
.Lhrdbfw_1625:
	movq	%rcx, 72(%rsp)
	movsd	%xmm0, 80(%rsp)
	fldl 80(%rsp)
	fldl 72(%rsp)
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
	fstpl 88(%rsp)
	movq	88(%rsp), %rdx
	jmp	.Lhrdbfw_1618
.Lhrdbfw_1628:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.Lhrdbfw_1618
	.section .rdata,"dr"
.Lhrdbfw_C67:

.byte 68,66,70,32,117,110,107,110,111,119,110,32,118,97,108,117,101,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C68:

.byte 68,66,70,32,118,97,108,117,101,32,111,117,116,112,117,116,32,98,117,102,102,101,114,32,116,111,111,32,115,104,111,114,116,0
	.align 8
.Lhrdbfw_C69:

.byte 68,66,70,32,118,97,108,117,101,32,116,121,112,101,32,111,117,116,115,105,100,101,32,97,100,109,105,116,116,101,100,32,111,112,101,114,97,116,105,111,110,0
.Lhrdbfw_C70:

.byte 111,107,0
	.align 8
.Lhrdbfw_C71:

.byte 68,66,70,32,118,97,108,117,101,32,116,97,103,32,111,114,32,109,101,116,97,100,97,116,97,32,105,110,118,97,108,105,100,0
	.align 8
.Lhrdbfw_C72:

.byte 68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,0
	.align 8
.Lhrdbfw_C73:

.byte 68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,0
	.text
	.p2align 4
	.globl	hrv_error_name
hrv_error_name:
	leaq	.Lhrdbfw_C68(%rip), %rax
	cmpl	$3, %ecx
	je	.Lhrdbfw_1661
	ja	.Lhrdbfw_1663
	leaq	.Lhrdbfw_C69(%rip), %rax
	cmpl	$1, %ecx
	je	.Lhrdbfw_1661
	leaq	.Lhrdbfw_C72(%rip), %rax
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1674
.Lhrdbfw_1661:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1674:
	testl	%ecx, %ecx
	leaq	.Lhrdbfw_C70(%rip), %rdx
	leaq	.Lhrdbfw_C67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1663:
	leaq	.Lhrdbfw_C71(%rip), %rax
	cmpl	$4, %ecx
	je	.Lhrdbfw_1661
	cmpl	$5, %ecx
	leaq	.Lhrdbfw_C73(%rip), %rdx
	leaq	.Lhrdbfw_C67(%rip), %rax
	cmove	%rdx, %rax
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
	ja	.Lhrdbfw_1678
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.Lhrdbfw_1678
	movabs	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.Lhrdbfw_1773
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.Lhrdbfw_1682:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.Lhrdbfw_1689
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1688:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1690:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_1690
	testq	%rax, %rax
	je	.Lhrdbfw_1691
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.Lhrdbfw_1691:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.Lhrdbfw_1688
	testb	%r12b, %r12b
	je	.Lhrdbfw_1689
	movl	%r9d, 544(%rsp)
.Lhrdbfw_1689:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.Lhrdbfw_1694
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shl
	movl	544(%rsp), %edi
.Lhrdbfw_1695:
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_1701
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1702:
	cmpq	$48, %r12
	je	.Lhrdbfw_1774
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbfw_1701:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.Lhrdbfw_1702
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1702
	testl	%r12d, %r12d
	jne	.Lhrdbfw_1775
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.Lhrdbfw_1707:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.Lhrdbfw_1710
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1776:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.Lhrdbfw_1710:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1776
	testl	%r13d, %r13d
	je	.Lhrdbfw_1711
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1713:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1712:
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
	jne	.Lhrdbfw_1712
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbfw_1777
	movq	%rax, %r12
	jmp	.Lhrdbfw_1713
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1678:
	xorl	%eax, %eax
.Lhrdbfw_1675:
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
.Lhrdbfw_1773:
	testq	%rax, %rax
	jne	.Lhrdbfw_1778
	cmpq	$0, 40(%rsp)
	jne	.Lhrdbfw_1779
	xorl	%edx, %edx
.Lhrdbfw_1683:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1684
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.Lhrdbfw_1678
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1686:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.Lhrdbfw_1686
	addl	%ebx, %eax
	jmp	.Lhrdbfw_1675
.Lhrdbfw_1779:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1678
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.Lhrdbfw_1683
.Lhrdbfw_1694:
	negl	%edx
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.Lhrdbfw_1780
	cmpl	$2, %eax
	jne	.Lhrdbfw_1695
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.Lhrdbfw_1695
	testl	%edi, %edi
	je	.Lhrdbfw_1728
.Lhrdbfw_1698:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.Lhrdbfw_1700
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1781:
	movl	(%rcx), %edx
.Lhrdbfw_1700:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.Lhrdbfw_1781
	testq	%rax, %rax
	je	.Lhrdbfw_1695
	movl	%edi, %eax
	addl	$1, %edi
.Lhrdbfw_1697:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.Lhrdbfw_1695
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1777:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.Lhrdbfw_1711:
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
	ja	.Lhrdbfw_1678
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.Lhrdbfw_1716
	movb	$45, (%rsi)
	movl	$1, %edx
.Lhrdbfw_1716:
	cmpl	%edi, %ebx
	jnb	.Lhrdbfw_1717
	testl	%eax, %eax
	je	.Lhrdbfw_1733
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1719:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1719
.Lhrdbfw_1718:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1675
.Lhrdbfw_1720:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.Lhrdbfw_1721
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1722:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_1722
	addl	%ebx, %edx
.Lhrdbfw_1721:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1723:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1723
	jmp	.Lhrdbfw_1675
.Lhrdbfw_1774:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.Lhrdbfw_1705:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1708:
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
	ja	.Lhrdbfw_1708
	jmp	.Lhrdbfw_1707
.Lhrdbfw_1778:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.Lhrdbfw_1682
.Lhrdbfw_1684:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.Lhrdbfw_1678
	movb	$48, (%rsi,%rdx)
	jmp	.Lhrdbfw_1675
.Lhrdbfw_1717:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbfw_1720
.Lhrdbfw_1780:
	testl	%edi, %edi
	je	.Lhrdbfw_1727
	movl	256(%rsp), %edx
	jmp	.Lhrdbfw_1698
.Lhrdbfw_1733:
	movl	%edx, %eax
	jmp	.Lhrdbfw_1718
.Lhrdbfw_1728:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.Lhrdbfw_1697
.Lhrdbfw_1727:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.Lhrdbfw_1697
.Lhrdbfw_1775:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.Lhrdbfw_1705
	.p2align 4
	.globl	hrdbf_fmt_harbour
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1783
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1783:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1784
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.Lhrdbfw_1786
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1787:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrdbfw_1787
	movzbl	12(%rdx), %eax
.Lhrdbfw_1786:
	cmpq	%rax, %r9
	jnb	.Lhrdbfw_1789
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1788:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1788
.Lhrdbfw_1789:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1784:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1798
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1798:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1800
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1800:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.Lhrdbfw_1821
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.Lhrdbfw_1824
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
	ja	.Lhrdbfw_1821
	cmpl	$9999, %r8d
	jbe	.Lhrdbfw_1821
	testl	%r11d, %r11d
	je	.Lhrdbfw_1821
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.Lhrdbfw_1805
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.Lhrdbfw_1807
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.Lhrdbfw_1807:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.Lhrdbfw_1801
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
.Lhrdbfw_1801:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1824:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1804:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1804
	xorl	%r10d, %r10d
.Lhrdbfw_1821:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1805:
	movl	$28, %edx
	testb	$3, %bl
	jne	.Lhrdbfw_1807
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.Lhrdbfw_1807
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.Lhrdbfw_1807
	.p2align 4
	.globl	hrdbf_write_logical
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1825
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1825:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.Lhrdbfw_1837
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbfw_1836
.Lhrdbfw_1837:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1835
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1834:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1834
.Lhrdbfw_1835:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1836:
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
	movl	$0, 32960(%rcx)
	movq	32968(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1848
	movq	$0, 32968(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1855
.Lhrdbfw_1848:
	xorl	%r12d, %r12d
.Lhrdbfw_1847:
	movq	32944(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1845
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1850
	movq	$0, 32944(%rbx)
	movq	$0, 32952(%rbx)
.Lhrdbfw_1845:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1855:
	movl	$7, %r12d
	jmp	.Lhrdbfw_1847
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1850:
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
	leaq	32968(%r12), %r9
	leaq	32944(%r12), %rdx
	subq	$72, %rsp
	cmpl	$1, %r8d
	movb	$0, hrdbfw_local_fsink(%rip)
	sete	%al
	movl	%r8d, 48(%rsp)
	leaq	32952(%r12), %r8
	movb	$0, 32976(%r12)
	movl	%eax, 32960(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.Lhrdbfw_1857
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	32976(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_1858
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1860:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_1859
.Lhrdbfw_1858:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1860
.Lhrdbfw_1859:
	movb	$0, (%rdx)
.Lhrdbfw_1862:
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
.Lhrdbfw_1857:
	movq	32944(%r12), %rdx
	movq	32952(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_1862
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
.Lhrdbfw_C74:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C75:

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
	je	.Lhrdbfw_1873
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1883
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1873
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1887
	cmpb	$78, %al
	je	.Lhrdbfw_1888
	cmpb	$68, %al
	je	.Lhrdbfw_1882
	movzbl	60(%rsp), %eax
.Lhrdbfw_1872:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1887:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1889
.Lhrdbfw_1875:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1890
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1873:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1883:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1872
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1888:
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
.Lhrdbfw_1882:
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
.Lhrdbfw_1889:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1878
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1877:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1877
.Lhrdbfw_1878:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1875
.Lhrdbfw_1890:
	leaq	.Lhrdbfw_C75(%rip), %rcx
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
	movb	$0, 32976(%rcx)
	movb	$0, hrdbfw_local_fsink(%rip)
	movq	$0, 8(%rcx)
	movq	$0, (%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movl	$0, 32960(%rcx)
	movq	32968(%rcx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1913
	movq	$0, 32968(%r12)
	call CloseHandle
	movq	32944(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1897
	testq	%rcx, %rcx
	je	.Lhrdbfw_1893
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1893
	movq	$0, 32944(%r12)
	movl	$7, %eax
	movq	$0, 32952(%r12)
	addq	$32, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1897:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1896
.Lhrdbfw_1895:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1911
.Lhrdbfw_1893:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1913:
	movq	32944(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1895
.Lhrdbfw_1896:
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
.Lhrdbfw_1911:
	movq	$0, 32944(%r12)
	movq	$0, 32952(%r12)
	jmp	.Lhrdbfw_1896
	.p2align 4
	.globl	hrdbf_file_write_record
hrdbf_file_write_record:
	movl	32960(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1918
	cmpq	$0, 32968(%rcx)
	je	.Lhrdbfw_1918
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1918
	testq	%rdx, %rdx
	je	.Lhrdbfw_1919
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.Lhrdbfw_1921
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1918:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1919:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1921:
	movzwl	34(%rcx), %r9d
	subq	$1, %rdx
	movzwl	32(%rcx), %eax
	movq	32944(%rcx), %r8
	imulq	%r9, %rdx
	addq	%rax, %rdx
	addq	%rdx, %r8
	jmp	hrdbfw_local_write_at
	.p2align 4
	.globl	hrdbf_file_append
hrdbf_file_append:
	movl	32960(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1922
	cmpq	$0, 32968(%rcx)
	je	.Lhrdbfw_1922
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1922
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1922:
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
	je	.Lhrdbfw_1929
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1934:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1947
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1933
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1931:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1947
.Lhrdbfw_1933:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1931
	jnb	.Lhrdbfw_1947
	leal	1(%r10), %r11d
.Lhrdbfw_1930:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1934
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1938
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1937:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1939
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1940
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1972:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1939
.Lhrdbfw_1940:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1972
.Lhrdbfw_1938:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1928
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1973
	movl	%r11d, %r9d
.Lhrdbfw_1928:
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
.Lhrdbfw_1947:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1930
.Lhrdbfw_1939:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1928
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1941
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1946:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1942
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1945
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1943:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1942
.Lhrdbfw_1945:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1943
	jb	.Lhrdbfw_1942
	movl	%r9d, %r10d
.Lhrdbfw_1944:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1946
.Lhrdbfw_1941:
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
.Lhrdbfw_1942:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1944
.Lhrdbfw_1973:
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
.Lhrdbfw_1929:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1928
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1937
	.p2align 4
	.globl	hrntx_build
hrntx_build:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$144, %rsp
	movq	48(%rbp), %rsi
	testq	%rcx, %rcx
	je	.Lhrdbfw_1978
	movq	%rdx, %r11
	testq	%rdx, %rdx
	je	.Lhrdbfw_1978
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_1978
	movzwl	28(%r8), %edi
	movw	%di, 80(%rsp)
	testw	%di, %di
	je	.Lhrdbfw_1978
	testq	%rsi, %rsi
	je	.Lhrdbfw_1978
	movq	%rcx, %rbx
	movl	16(%r9), %ecx
	movq	%rcx, %rax
	movq	%rcx, 112(%rsp)
	salq	$4, %rax
	cmpq	56(%rbp), %rax
	ja	.Lhrdbfw_1978
	movzwl	18(%rdx), %edx
	movw	%dx, 86(%rsp)
	testw	%dx, %dx
	je	.Lhrdbfw_1978
	movzwl	%dx, %r15d
	movzwl	%di, %r10d
	leaq	8(%r10), %rdi
	movq	%r15, %rax
	leaq	4(%r15,%r15), %r12
	movq	%r15, 104(%rsp)
	imulq	%rdi, %rax
	addq	%r12, %rax
	cmpq	$1024, %rax
	ja	.Lhrdbfw_1978
	movq	%r15, %rdx
	movzwl	30(%r8), %eax
	addq	$1, %rdx
	movq	%rdx, 96(%rsp)
	cmpq	%r15, %rcx
	ja	.Lhrdbfw_1979
	testq	%rcx, %rcx
	je	.Lhrdbfw_2024
.Lhrdbfw_1980:
	salq	$4, %rax
	movzwl	32(%r9), %edx
	movzwl	34(%r9), %r13d
	movzwl	56(%rax,%r9), %eax
	addq	%rdx, %rax
	addq	(%r9), %rax
	movq	112(%rsp), %r9
	movq	%rsi, %rdx
	movq	%rax, %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1982:
	leal	1(%rax), %r8d
	addq	$1, %rax
	movq	%rcx, 8(%rdx)
	addq	$16, %rdx
	movl	%r8d, -16(%rdx)
	addq	%r13, %rcx
	cmpq	%rax, %r9
	ja	.Lhrdbfw_1982
	cmpq	$1, 112(%rsp)
	jbe	.Lhrdbfw_2001
	movq	%r12, 120(%rsp)
	movq	112(%rsp), %r14
	leaq	16(%rsi), %r15
	movl	$1, %r13d
	movq	%rdi, 128(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1989:
	movl	(%r15), %r12d
	movq	8(%r15), %rcx
	movq	%r15, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1984:
	movl	-16(%r8), %r9d
	movq	-8(%r8), %rdx
	movq	%r8, %rdi
	xorl	%eax, %eax
	movl	%r9d, 136(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1988:
	movzbl	(%rdx,%rax), %r9d
	cmpb	%r9b, (%rcx,%rax)
	jne	.Lhrdbfw_2025
	addq	$1, %rax
	cmpq	%rax, %r10
	ja	.Lhrdbfw_1988
	movl	136(%rsp), %r9d
	cmpl	%r12d, %r9d
	jbe	.Lhrdbfw_1985
.Lhrdbfw_1987:
	movdqu	-16(%r8), %xmm0
	subq	$16, %r8
	movups	%xmm0, 16(%r8)
	cmpq	%rsi, %r8
	jne	.Lhrdbfw_1984
	movq	%rsi, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1985:
	addq	$1, %r13
	movl	%r12d, (%rdi)
	addq	$16, %r15
	movq	%rcx, 8(%rdi)
	cmpq	%r13, %r14
	jne	.Lhrdbfw_1989
	movq	128(%rsp), %rdi
	movq	120(%rsp), %r12
.Lhrdbfw_2001:
	movq	112(%rsp), %rax
	movq	104(%rsp), %rcx
	xorl	%edx, %edx
	leaq	1(%rax,%rcx), %rax
	divq	96(%rsp)
	movq	%rax, 128(%rsp)
	cmpq	%rcx, %rax
	jbe	.Lhrdbfw_1981
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1978:
	xorl	%eax, %eax
.Lhrdbfw_1974:
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
.Lhrdbfw_1979:
	movq	104(%rsp), %rcx
	movq	%rcx, %rdx
	imulq	%rcx, %rdx
	cmpq	112(%rsp), %rdx
	jnb	.Lhrdbfw_1980
	jmp	.Lhrdbfw_1978
.Lhrdbfw_2024:
	movq	$1, 128(%rsp)
.Lhrdbfw_1981:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1990:
	movzbl	(%r11,%rax), %edx
	movb	%dl, (%rbx,%rax)
	addq	$1, %rax
	cmpq	$1024, %rax
	jne	.Lhrdbfw_1990
	movq	128(%rsp), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_1991
	subq	$1, %rax
	movq	%rsi, 48(%rbp)
	leaq	1024(%rbx), %r15
	movq	%rax, 72(%rsp)
	movq	112(%rsp), %rax
	movq	%r15, %rcx
	movq	%r12, %r15
	movq	$0, 120(%rsp)
	movq	%rcx, %r12
	movq	%rax, 88(%rsp)
	movzwl	86(%rsp), %eax
	movq	$0, 136(%rsp)
	shrw	$8, %ax
	movq	%rbx, 16(%rbp)
	movw	%ax, 84(%rsp)
	movzwl	80(%rsp), %eax
	movl	%eax, 80(%rsp)
	movl	%eax, %ebx
.Lhrdbfw_1994:
	movq	72(%rsp), %rsi
	cmpq	%rsi, 136(%rsp)
	je	.Lhrdbfw_2026
	movzbl	86(%rsp), %eax
	movq	104(%rsp), %r13
	movb	%al, (%r12)
	movzbl	84(%rsp), %eax
	movb	%al, 1(%r12)
.Lhrdbfw_1993:
	movq	120(%rsp), %rax
	xorl	%r14d, %r14d
	salq	$4, %rax
	addq	48(%rbp), %rax
	movq	%rax, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1996:
	movl	%ebx, 56(%rsp)
	movq	8(%rsi), %rax
	movq	%r14, %rdx
	movq	%rdi, %r9
	movq	%r15, %r8
	movq	%r12, %rcx
	addq	$1, %r14
	addq	$16, %rsi
	movq	%rax, 48(%rsp)
	movl	-16(%rsi), %eax
	movl	$0, 32(%rsp)
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_nxputslot
	cmpq	%r13, %r14
	jne	.Lhrdbfw_1996
.Lhrdbfw_1997:
	movl	%ebx, 56(%rsp)
	movq	%r13, %rdx
	movq	%r12, %rcx
	movq	%rdi, %r9
	movq	$0, 48(%rsp)
	movq	%r15, %r8
	addq	$1024, %r12
	movl	$0, 40(%rsp)
	movl	$0, 32(%rsp)
	call	hrdbfw_local_nxputslot
	movq	96(%rsp), %rdx
	addq	%rdx, 120(%rsp)
	addq	$1, 136(%rsp)
	movq	136(%rsp), %rax
	subq	%rdx, 88(%rsp)
	cmpq	128(%rsp), %rax
	jne	.Lhrdbfw_1994
	movq	128(%rsp), %rax
	movq	16(%rbp), %rbx
	movq	%r15, %r12
	movq	48(%rbp), %rsi
	cmpq	$1, %rax
	je	.Lhrdbfw_1991
	leaq	1(%rax), %r13
	subl	$1, %eax
	movq	104(%rsp), %r14
	movl	$1, %r15d
	salq	$10, %r13
	leaq	(%rbx,%r13), %rcx
	movw	%ax, (%rcx)
	movq	%rcx, %rbx
	jmp	.Lhrdbfw_1998
.Lhrdbfw_2004:
	movq	%rax, %r15
.Lhrdbfw_1998:
	leaq	-1(%r15), %rdx
	cmpq	%r14, 112(%rsp)
	jbe	.Lhrdbfw_1978
	movl	80(%rsp), %ecx
	movq	%r14, %rax
	movq	%rdi, %r9
	salq	$4, %rax
	movl	%ecx, 56(%rsp)
	movq	8(%rsi,%rax), %r8
	movq	%rbx, %rcx
	movq	%r8, 48(%rsp)
	movl	(%rsi,%rax), %eax
	movq	%r12, %r8
	movl	%eax, 40(%rsp)
	movl	%r15d, %eax
	sall	$10, %eax
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_nxputslot
	leaq	1(%r15), %rax
	addq	96(%rsp), %r14
	cmpq	128(%rsp), %rax
	jne	.Lhrdbfw_2004
	movl	80(%rsp), %eax
	movq	%rbx, %rcx
	movq	%rdi, %r9
	movq	%r12, %r8
	movq	$0, 48(%rsp)
	movq	%r15, %rdx
	movq	16(%rbp), %rbx
	movl	%eax, 56(%rsp)
	movl	128(%rsp), %eax
	movl	$0, 40(%rsp)
	sall	$10, %eax
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_nxputslot
	movl	%r13d, %eax
	movb	$0, 4(%rbx)
	shrl	$8, %eax
	movb	%al, 5(%rbx)
	movl	%r13d, %eax
	shrl	$24, %r13d
	movb	%r13b, 7(%rbx)
	shrl	$16, %eax
	movb	%al, 6(%rbx)
	movl	$2, %eax
.Lhrdbfw_1999:
	addq	128(%rsp), %rax
	salq	$10, %rax
	jmp	.Lhrdbfw_1974
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2025:
	jb	.Lhrdbfw_1987
	jmp	.Lhrdbfw_1985
.Lhrdbfw_2026:
	movq	88(%rsp), %rsi
	cmpq	%rsi, 104(%rsp)
	jb	.Lhrdbfw_1978
	movl	%esi, %eax
	movb	%sil, (%r12)
	shrw	$8, %ax
	movb	%al, 1(%r12)
	testq	%rsi, %rsi
	jne	.Lhrdbfw_2003
	xorl	%r13d, %r13d
	jmp	.Lhrdbfw_1997
.Lhrdbfw_2003:
	movq	88(%rsp), %r13
	jmp	.Lhrdbfw_1993
.Lhrdbfw_1991:
	movl	$1024, 4(%rbx)
	movl	$1, %eax
	jmp	.Lhrdbfw_1999
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C77:

.byte 104,98,99,58,32,68,66,70,32,78,84,88,32,105,110,100,101,120,32,114,101,98,117,105,108,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
hrdbf_app_rebuild_index:
	movq	hrdbf_app_order(%rip), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2067
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2072
.Lhrdbfw_2067:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2072:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$96, %rsp
	movl	hrdbf_app_state+16(%rip), %ecx
	movzwl	18(%rax), %eax
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2029
	testw	%ax, %ax
	je	.Lhrdbfw_2033
	movl	$1, %ebx
	movl	$2048, %edx
.Lhrdbfw_2031:
	movl	%ecx, %r15d
	leaq VirtualAlloc(%rip), %r13
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movq	%r15, %rdi
	leaq	7(%r15), %rsi
	movl	$12288, %r8d
	call	*%r13
	salq	$4, %rdi
	shrq	$3, %rsi
	movq	%rax, %r12
	testq	%rax, %rax
	je	.Lhrdbfw_2033
	leaq	(%rdi,%rsi), %r14
	movl	$4, %r9d
	movl	$12288, %r8d
	xorl	%ecx, %ecx
	addq	%rbx, %r14
	movq	%r14, %rdx
	call	*%r13
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_2073
	movq	%rdi, 40(%rsp)
	movq	hrdbf_app_order(%rip), %rdx
	movq	%r12, %rcx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rax, 32(%rsp)
	leaq	hrdbf_app_order(%rip), %r8
	call	hrntx_build
	movq	%rax, %rdi
	testq	%rax, %rax
	je	.Lhrdbfw_2070
	leaq	0(%r13,%r15,8), %rax
	addq	%rsi, %rbx
	movq	%r13, 32(%rsp)
	movq	%rdi, %r8
	movq	%rax, 48(%rsp)
	movl	hrdbf_app_state+16(%rip), %eax
	leaq	64(%rsp), %rcx
	movq	%r12, %rdx
	movq	%rbx, 56(%rsp)
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rax, 40(%rsp)
	movq	$0, 64(%rsp)
	movq	$0, 72(%rsp)
	movq	$0, 80(%rsp)
	movq	$0, 88(%rsp)
	call	hrntx_open
	testl	%eax, %eax
	jne	.Lhrdbfw_2070
	movq	hrdbf_app_order+64(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2038
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
.Lhrdbfw_2038:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2039
	movl	$32768, %r8d
	xorl	%edx, %edx
	call VirtualFree
.Lhrdbfw_2039:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2040
	movl	$32768, %r8d
	xorl	%edx, %edx
	call VirtualFree
.Lhrdbfw_2040:
	movdqu	80(%rsp), %xmm1
	movdqu	64(%rsp), %xmm0
	xorl	%eax, %eax
	movq	%r12, hrdbf_app_order+32(%rip)
	movq	%rdi, hrdbf_app_order+48(%rip)
	movq	hrdbf_app_state+24(%rip), %r9
	movups	%xmm1, hrdbf_app_order+16(%rip)
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_order+16(%rip), %r8
	movq	%r13, hrdbf_app_order+40(%rip)
	movq	%r14, hrdbf_app_order+56(%rip)
	movl	$1, hrdbf_app_order+72(%rip)
	movq	%rcx, hrdbf_app_pos(%rip)
	movups	%xmm0, hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2045
	jmp	.Lhrdbfw_2071
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2043:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2071
.Lhrdbfw_2045:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.Lhrdbfw_2043
	cmpq	%rax, %rcx
	movq	%rax, hrdbf_app_pos(%rip)
	setbe	%al
	jbe	.Lhrdbfw_2042
.Lhrdbfw_2044:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
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
.Lhrdbfw_2029:
	movzwl	%ax, %r8d
	xorl	%edx, %edx
	leal	-1(%rcx,%rax), %eax
	divq	%r8
	cmpq	%rax, %r8
	jb	.Lhrdbfw_2033
	cmpq	$1, %rax
	jbe	.Lhrdbfw_2034
	leaq	2(%rax), %rdx
	leaq	9(%rax), %rbx
	salq	$10, %rdx
	shrq	$3, %rbx
	jmp	.Lhrdbfw_2031
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2071:
	movl	$1, %eax
.Lhrdbfw_2042:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
	jmp	.Lhrdbfw_2044
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2070:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r12, %rcx
	leaq VirtualFree(%rip), %rbx
	call	*%rbx
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*%rbx
.Lhrdbfw_2033:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2073:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r12, %rcx
	call VirtualFree
	jmp	.Lhrdbfw_2033
.Lhrdbfw_2034:
	leaq	1(%rax), %rdx
	movl	$1, %ebx
	salq	$10, %rdx
	jmp	.Lhrdbfw_2031
	.section .rdata,"dr"
.Lhrdbfw_C78:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,108,117,115,104,32,102,97,105,108,101,100,10,0
.Lhrdbfw_C79:

.byte 104,98,99,58,32,68,66,70,47,78,84,88,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_close
hrdbfw_app_close:
	pushq	%rbx
	subq	$32, %rsp
	movl	hrdbf_app_order+72(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2075
	cmpq	$0, hrdbf_app_order+32(%rip)
	je	.Lhrdbfw_2075
	cmpq	$0, hrdbf_app_order+48(%rip)
	jne	.Lhrdbfw_2081
.Lhrdbfw_2075:
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	movl	%eax, %ebx
	call	hrdbf_file_close
	movb	$0, hrdbf_app_ntxpath(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	orl	%eax, %ebx
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	jne	.Lhrdbfw_2082
	addq	$32, %rsp
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2081:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2075
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2082:
	leaq	.Lhrdbfw_C79(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C80:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,0
	.align 8
.Lhrdbfw_C81:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,116,97,98,108,101,32,118,101,114,115,105,111,110,32,111,114,32,104,101,97,100,101,114,32,102,108,97,103,115,0
.Lhrdbfw_C82:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,102,105,101,108,100,32,116,121,112,101,0
.Lhrdbfw_C83:

.byte 114,101,99,111,114,100,32,99,111,110,116,101,110,116,32,105,110,118,97,108,105,100,0
.Lhrdbfw_C84:

.byte 73,47,79,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C85:

.byte 115,105,122,101,32,111,114,32,102,105,101,108,100,45,99,111,117,110,116,32,108,105,109,105,116,32,101,120,99,101,101,100,101,100,0
.Lhrdbfw_C86:

.byte 116,97,98,108,101,32,102,111,114,109,97,116,32,110,111,116,32,115,117,112,112,111,114,116,101,100,0
	.align 8
.Lhrdbfw_C87:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C88:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C89:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C90:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C91:

.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,109,111,100,101,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
.Lhrdbfw_C92:

.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,114,101,106,101,99,116,101,100,58,32,0
	.text
	.p2align 4
	.globl	hrdbfw_app_open
hrdbfw_app_open:
	pushq	%r13
	movq	%r9, %r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	movq	%rcx, %rdi
	pushq	%rsi
	pushq	%rbx
	subq	$872, %rsp
	movq	960(%rsp), %rbp
	testq	%r8, %r8
	je	.Lhrdbfw_2084
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_2154
.Lhrdbfw_2084:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_2155
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_2085
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2120:
	movq	%rsi, %rbx
.Lhrdbfw_2085:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2156
	leaq	1(%rbx), %rsi
	movb	%al, 64(%rsp,%rbx)
	leaq	64(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_2120
	movb	$0, 64(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2157
	xorl	%eax, %eax
	testq	%r13, %r13
	movl	$0, hrdbf_app_found_flag(%rip)
	setne	%al
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	cmpq	$2, %rbp
	ja	.Lhrdbfw_2158
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2091
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2089:
	cmpq	%r8, %rbx
	je	.Lhrdbfw_2159
.Lhrdbfw_2091:
	movzbl	(%rdi,%rdx), %ecx
	movq	%rdx, %r8
	addq	$1, %rdx
	cmpb	$47, %cl
	je	.Lhrdbfw_2131
	cmpb	$92, %cl
	jne	.Lhrdbfw_2089
.Lhrdbfw_2131:
	movq	%rdx, %rax
	cmpq	%r8, %rbx
	jne	.Lhrdbfw_2091
.Lhrdbfw_2159:
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_2094
	jmp	.Lhrdbfw_2160
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2121:
	movq	%rdx, %rax
.Lhrdbfw_2094:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_2121
	movq	%rsi, hrdbf_app_baselen(%rip)
	testq	%rsi, %rsi
	je	.Lhrdbfw_2095
.Lhrdbfw_2118:
	xorl	%edx, %edx
	leaq	hrdbf_app_basename(%rip), %r9
	jmp	.Lhrdbfw_2097
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2161:
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jbe	.Lhrdbfw_2095
.Lhrdbfw_2097:
	movzbl	(%rdi,%rdx), %eax
	cmpb	$92, %al
	jne	.Lhrdbfw_2161
	movl	$47, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	ja	.Lhrdbfw_2097
.Lhrdbfw_2095:
	leaq	hrdbf_app_state(%rip), %rcx
	movb	$0, hrdbf_app_state+32976(%rip)
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_2162
.Lhrdbfw_2098:
	leaq	hrdbf_app_state+32976(%rip), %r12
	cmpb	$0, hrdbf_app_state+32976(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_2101
	leaq	.Lhrdbfw_C84(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_2101
	leaq	.Lhrdbfw_C80(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_2101
	leaq	.Lhrdbfw_C85(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_2101
	leaq	.Lhrdbfw_C81(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_2101
	leaq	.Lhrdbfw_C82(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_2101
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C83(%rip), %r12
	leaq	.Lhrdbfw_C86(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_2101:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2162:
	movl	%ebp, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2098
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2083
	leaq	4(%rsi), %rax
	cmpq	$259, %rax
	jbe	.Lhrdbfw_2163
.Lhrdbfw_2083:
	addq	$872, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_2163:
	movb	$46, 64(%rsp,%rsi)
	movzbl	64(%rsp), %eax
	movb	$99, 65(%rsp,%rsi)
	movb	$100, 66(%rsp,%rsi)
	movb	$120, 67(%rsp,%rsi)
	movb	$0, 68(%rsp,%rsi)
	testb	%al, %al
	je	.Lhrdbfw_2106
	cmpb	$92, %al
	je	.Lhrdbfw_2164
	cmpb	$47, %al
	je	.Lhrdbfw_2110
.Lhrdbfw_2109:
	leaq	336(%rsp), %r13
	movq	%r12, %rcx
	movq	%r13, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_2106
	movq	%r13, %rcx
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$1, %r8d
	movl	$128, 40(%rsp)
	movl	$-2147483648, %edx
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %rcx
	cmpq	$-1, %rax
	je	.Lhrdbfw_2165
	call CloseHandle
.Lhrdbfw_2106:
	cmpq	$1, %rbp
	je	.Lhrdbfw_2166
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2115
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2083
.Lhrdbfw_2160:
	movq	%rsi, hrdbf_app_baselen(%rip)
	jmp	.Lhrdbfw_2118
.Lhrdbfw_2165:
	call GetLastError
	subl	$2, %eax
	cmpl	$1, %eax
	jbe	.Lhrdbfw_2083
	jmp	.Lhrdbfw_2106
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2110:
	cmpb	$47, 65(%rsp)
	jne	.Lhrdbfw_2109
	jmp	.Lhrdbfw_2106
.Lhrdbfw_2115:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2116
	movl	$1, %edx
	movq	%r12, %rcx
	call	hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_2116
.Lhrdbfw_2117:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2083
.Lhrdbfw_2164:
	cmpb	$92, 65(%rsp)
	jne	.Lhrdbfw_2109
	jmp	.Lhrdbfw_2106
.Lhrdbfw_2166:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2083
.Lhrdbfw_2116:
	movl	$3, %eax
	jmp	.Lhrdbfw_2117
.Lhrdbfw_2156:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2158:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2157:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2155:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2154:
	leaq	.Lhrdbfw_C87(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C93:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2177
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2169
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2170
.Lhrdbfw_2169:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2170:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2172
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.Lhrdbfw_2173:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2172:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.Lhrdbfw_2173
.Lhrdbfw_2177:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2189
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2180
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2180
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_2190
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_2184:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_2185:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2190:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_2184
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_2185
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2180:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_2189:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2209
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2193
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2193
	testq	%rcx, %rcx
	je	.Lhrdbfw_2191
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.Lhrdbfw_2196
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.Lhrdbfw_2202
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.Lhrdbfw_2197:
	movq	%rdx, hrdbf_app_pos(%rip)
.Lhrdbfw_2198:
	cmpq	%rax, %rdx
	jnb	.Lhrdbfw_2200
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.Lhrdbfw_2201:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
.Lhrdbfw_2191:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2193:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2202:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.Lhrdbfw_2197
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2200:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_2201
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2196:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.Lhrdbfw_2199
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.Lhrdbfw_2198
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2199:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.Lhrdbfw_2198
.Lhrdbfw_2209:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C94:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C95:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C96:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C97:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C98:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,109,97,105,110,116,101,110,97,110,99,101,41,10,0
	.align 8
.Lhrdbfw_C99:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,112,114,101,115,101,110,116,32,98,117,116,32,110,111,116,32,97,100,109,105,116,116,101,100,32,40,111,110,101,32,116,97,103,44,32,115,117,98,115,101,116,44,32,115,105,122,101,32,111,114,32,102,111,114,109,97,116,41,10,0
	.align 8
.Lhrdbfw_C100:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbfw_C101:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbfw_C102:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
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
	subq	$304, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2268
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_2269
	movq	%rcx, %r8
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2212
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2214:
	cmpq	%rbx, %r9
	je	.Lhrdbfw_2270
.Lhrdbfw_2240:
	movq	%rbx, %rdx
.Lhrdbfw_2212:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2271
	movb	%al, 32(%rsp,%rdx)
	leaq	32(%rsp), %rsi
	leaq	1(%rdx), %rbx
	cmpb	$47, %al
	je	.Lhrdbfw_2246
	cmpb	$92, %al
	jne	.Lhrdbfw_2214
.Lhrdbfw_2246:
	movq	%rbx, %rcx
	cmpq	%rbx, %r9
	jne	.Lhrdbfw_2240
.Lhrdbfw_2270:
	movq	%rbx, %rax
	xorl	%r9d, %r9d
	cmpq	%rbx, %rcx
	jnb	.Lhrdbfw_2216
	movl	$1, %r11d
	jmp	.Lhrdbfw_2218
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2242:
	movq	%r10, %rcx
.Lhrdbfw_2218:
	cmpb	$46, (%r8,%rcx)
	leaq	1(%rcx), %r10
	cmove	%rcx, %rax
	cmove	%r11d, %r9d
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_2242
.Lhrdbfw_2216:
	movl	hrdbf_app_cdx(%rip), %r12d
	testl	%r12d, %r12d
	jne	.Lhrdbfw_2272
.Lhrdbfw_2219:
	movl	hrdbf_app_shared(%rip), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2273
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2274
	testl	%r9d, %r9d
	je	.Lhrdbfw_2275
	movb	$0, 32(%rsp,%rbx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2230
.Lhrdbfw_2278:
	movl	%r12d, %edx
	movq	%rsi, %rcx
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2230
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2234
	xorl	%eax, %eax
	leaq	hrdbf_app_ntxpath(%rip), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2235:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, (%rcx,%rax)
	movq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_2235
	jmp	.Lhrdbfw_2236
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2272:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.Lhrdbfw_2219
	testq	%rax, %rax
	je	.Lhrdbfw_2220
	movl	$1, %r11d
	xorl	%r10d, %r10d
	leaq	hrdbf_app_basename(%rip), %r14
	xorl	%r13d, %r13d
	jmp	.Lhrdbfw_2223
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2277:
	leal	-97(%rcx), %ebp
	leal	-32(%rcx), %edi
	cmpb	$26, %bpl
	cmovb	%edi, %ecx
.Lhrdbfw_2221:
	cmpb	%cl, (%r14,%r10)
	cmovne	%r13d, %r11d
	addq	$1, %r10
	cmpq	%rax, %r10
	je	.Lhrdbfw_2276
.Lhrdbfw_2223:
	movzbl	(%r8,%r10), %ecx
	cmpb	$92, %cl
	jne	.Lhrdbfw_2277
	movl	$47, %ecx
	jmp	.Lhrdbfw_2221
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2234:
	movb	$0, hrdbf_app_ntxpath(%rip)
.Lhrdbfw_2236:
	movl	$1, hrdbf_app_order_active(%rip)
	call	hrdbfw_app_top
	addq	$304, %rsp
	movl	$1, %eax
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
.Lhrdbfw_2275:
	cmpl	$1, %r12d
	movb	$46, 32(%rsp,%rbx)
	leaq	5(%rdx), %rbx
	sbbl	%ecx, %ecx
	movb	$120, 36(%rsp,%rdx)
	andl	$11, %ecx
	addl	$99, %ecx
	cmpl	$1, %r12d
	sbbl	%eax, %eax
	movb	%cl, 34(%rsp,%rdx)
	andl	$16, %eax
	addl	$100, %eax
	movb	%al, 35(%rsp,%rdx)
	movb	$0, 32(%rsp,%rbx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2278
.Lhrdbfw_2230:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_2247
	leaq	.Lhrdbfw_C94(%rip), %rcx
	cmpl	$3, %eax
	je	.Lhrdbfw_2232
.Lhrdbfw_2247:
	leaq	.Lhrdbfw_C95(%rip), %rcx
.Lhrdbfw_2232:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2276:
	testl	%r11d, %r11d
	je	.Lhrdbfw_2219
.Lhrdbfw_2220:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.Lhrdbfw_2236
	cmpl	$2, %eax
	je	.Lhrdbfw_2279
	cmpl	$3, %eax
	je	.Lhrdbfw_2280
	cmpl	$4, %eax
	jne	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2271:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2280:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2279:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2269:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2268:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2274:
	leaq	.Lhrdbfw_C102(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2273:
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2289
	movl	hrdbf_app_order+72(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2283
	cmpq	$0, hrdbf_app_order+32(%rip)
	je	.Lhrdbfw_2283
	cmpq	$0, hrdbf_app_order+48(%rip)
	jne	.Lhrdbfw_2290
.Lhrdbfw_2283:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2291
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2290:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2283
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2289:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2291:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2297
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_2297:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C103:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2305
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2300
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2300
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
	jb	.Lhrdbfw_2306
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_2303:
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
.Lhrdbfw_2306:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_2303
.Lhrdbfw_2300:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2305:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C104:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,101,120,112,101,99,116,115,32,97,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,118,97,108,117,101,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek_dyn
hrdbfw_app_seek_dyn:
	pushq	%r12
	pushq	%rbx
	subq	$344, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2345
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2309
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2309
	movq	%rcx, %rax
	movq	%rdx, %rcx
	movq	%r8, %rbx
	movzbl	%al, %edx
	leal	-2(%rdx), %r8d
	andl	$-3, %r8d
	je	.Lhrdbfw_2346
	testl	%edx, %edx
	je	.Lhrdbfw_2324
	cmpl	$9, %edx
	je	.Lhrdbfw_2324
	cmpl	$5, %edx
	je	.Lhrdbfw_2347
	cmpl	$12, %edx
	je	.Lhrdbfw_2348
	movl	hrdbf_app_order+24(%rip), %eax
	movb	$1, hrdbf_app_state+39(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%rax, %rdx
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	orl	hrdbf_app_cdx(%rip), %edx
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+38(%rip)
	addq	$344, %rsp
	xorl	%eax, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2346:
	testq	%rcx, %rcx
	je	.Lhrdbfw_2349
	movq	-8(%rcx), %rdx
	addq	$344, %rsp
	movq	%rbx, %r8
	popq	%rbx
	popq	%r12
	jmp	hrdbfw_app_seek
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2348:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rcx, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.Lhrdbfw_2322
	movsd	.Lhrdbfw_C0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2323:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.Lhrdbfw_2323
.Lhrdbfw_2322:
	comisd	.Lhrdbfw_C105(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2324
.Lhrdbfw_2344:
	movsd	.Lhrdbfw_C106(%rip), %xmm1
	addq	$1, %rcx
	comisd	%xmm0, %xmm1
	jbe	.Lhrdbfw_2350
.Lhrdbfw_2324:
	leaq	48(%rsp), %r12
	movzwl	hrdbf_app_order+28(%rip), %edx
	movq	%r9, 40(%rsp)
	movq	%r12, %r8
	call	hrdbf_app_pad_ll
	movq	40(%rsp), %r9
	movq	%rbx, %r8
	movq	%r12, %rcx
	movq	%rax, %rdx
	call	hrdbfw_app_seek
	addq	$344, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2347:
	testq	%rax, %rax
	js	.Lhrdbfw_2351
.Lhrdbfw_2317:
	movq	%rcx, %xmm0
	comisd	.Lhrdbfw_C105(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2324
	jmp	.Lhrdbfw_2344
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2350:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.Lhrdbfw_2352
	addsd	.Lhrdbfw_C107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2324
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2351:
	movq	(%rcx), %rcx
	jmp	.Lhrdbfw_2317
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2352:
	subsd	.Lhrdbfw_C107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2324
.Lhrdbfw_2309:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2345:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2349:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2358
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_2358:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2364
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_2364:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
hrdbfw_app_fcount:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2370
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.Lhrdbfw_2370:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
hrdbfw_app_goto:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2385
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %eax
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2373
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_2374
.Lhrdbfw_2373:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, hrdbf_app_state+24(%rip)
	movw	%cx, hrdbf_app_state+38(%rip)
.Lhrdbfw_2375:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2371
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2386
.Lhrdbfw_2371:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2374:
	xorl	%edx, %edx
	movq	%rcx, hrdbf_app_state+24(%rip)
	movw	%dx, hrdbf_app_state+38(%rip)
	jmp	.Lhrdbfw_2375
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2386:
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r8
	testl	%ecx, %ecx
	je	.Lhrdbfw_2380
	movq	hrdbf_app_order+16(%rip), %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2379
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2378:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2377
.Lhrdbfw_2379:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_2378
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2380:
	xorl	%ecx, %ecx
.Lhrdbfw_2377:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2385:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
hrdbfw_app_ordselect:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2403
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2389
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2404
	cmpq	$1, %rcx
	jne	.Lhrdbfw_2389
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r9
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %r8
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2395
	jmp	.Lhrdbfw_2405
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2394:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2397
.Lhrdbfw_2395:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.Lhrdbfw_2394
	movq	%rax, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2404:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.Lhrdbfw_2406
	cmpl	$3, %eax
	je	.Lhrdbfw_2407
	cmpl	$4, %eax
	je	.Lhrdbfw_2408
.Lhrdbfw_2389:
	movl	$0, hrdbf_app_order_active(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2405:
	xorl	%ecx, %ecx
.Lhrdbfw_2397:
	movq	%rcx, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2403:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2406:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2408:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2407:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2414
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_2414:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2420
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_2420:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2428
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2421
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_2421:
	movq	%r8, %rax
	ret
.Lhrdbfw_2428:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2435
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_2431
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_2432
.Lhrdbfw_2431:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2432:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_2435:
	leaq	.Lhrdbfw_C93(%rip), %rcx
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
	je	.Lhrdbfw_2437
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_2439
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2451:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2440:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2441
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2440
.Lhrdbfw_2441:
	cmpq	%r8, %rax
	je	.Lhrdbfw_2461
.Lhrdbfw_2443:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.Lhrdbfw_2451
.Lhrdbfw_2439:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2461:
	testq	%r8, %r8
	je	.Lhrdbfw_2444
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2448
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2462:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.Lhrdbfw_2444
.Lhrdbfw_2448:
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
	je	.Lhrdbfw_2462
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_2443
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2444:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_2449
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
.Lhrdbfw_2449:
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
.Lhrdbfw_2437:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C108:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C109:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,67,68,88,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,78,84,88,32,111,110,108,121,41,10,0
	.align 8
.Lhrdbfw_C110:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbfw_C111:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbfw_C112:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbfw_C113:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_fieldput
hrdbfw_app_fieldput:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2529
	movl	hrdbf_app_state+32960(%rip), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_2530
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rbx
	movq	%rdx, %r9
	je	.Lhrdbfw_2466
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2531
.Lhrdbfw_2466:
	testq	%rbx, %rbx
	jle	.Lhrdbfw_2467
	movzwl	hrdbf_app_state+36(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r11
	cmpq	%rbx, %rax
	jl	.Lhrdbfw_2467
	movq	hrdbf_app_state+24(%rip), %r10
	leaq	1(%rbx), %rax
	leaq	-1(%rbx), %rsi
	movzbl	%r9b, %edi
	movzwl	hrdbf_app_state+34(%rip), %edx
	salq	$4, %rax
	leaq	-1(%r10), %rcx
	leaq	10(%r11,%rax), %r12
	addq	%r11, %rax
	imulq	%rdx, %rcx
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	%rdx, %rcx
	movzbl	21(%rax), %edx
	addq	hrdbf_app_state+32944(%rip), %rcx
	cmpb	$76, %dl
	je	.Lhrdbfw_2469
	ja	.Lhrdbfw_2470
	cmpb	$67, %dl
	je	.Lhrdbfw_2471
	cmpb	$68, %dl
	jne	.Lhrdbfw_2473
	cmpl	$11, %edi
	je	.Lhrdbfw_2532
	cmpl	$1, %edi
	jne	.Lhrdbfw_2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.Lhrdbfw_2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2533:
	addq	$1, %rax
.Lhrdbfw_2493:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2533
.Lhrdbfw_2478:
	movq	hrdbf_app_state+24(%rip), %r10
.Lhrdbfw_2482:
	movq	%r10, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbfw_2534
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2463
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2463
	movzwl	hrdbf_app_order+30(%rip), %eax
	addq	$1, %rax
	cmpq	%rbx, %rax
	je	.Lhrdbfw_2535
.Lhrdbfw_2463:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2470:
	cmpb	$78, %dl
	jne	.Lhrdbfw_2473
	cmpl	$12, %edi
	je	.Lhrdbfw_2536
	testl	%edi, %edi
	je	.Lhrdbfw_2502
	cmpl	$9, %edi
	je	.Lhrdbfw_2502
	cmpl	$5, %edi
	je	.Lhrdbfw_2537
	cmpl	$1, %edi
	jne	.Lhrdbfw_2473
	addq	$2, %rsi
	salq	$4, %rsi
	addq	%rsi, %r11
	movzbl	22(%r11), %edx
	movzwl	24(%r11), %eax
	testl	%edx, %edx
	je	.Lhrdbfw_2482
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2491
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2538:
	addq	$1, %rax
.Lhrdbfw_2491:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2538
	jmp	.Lhrdbfw_2478
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2471:
	leal	-2(%rdi), %edx
	andl	$-3, %edx
	je	.Lhrdbfw_2539
	cmpl	$1, %edi
	jne	.Lhrdbfw_2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.Lhrdbfw_2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2483
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2540:
	addq	$1, %rax
.Lhrdbfw_2483:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2540
	jmp	.Lhrdbfw_2478
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2469:
	cmpl	$3, %edi
	je	.Lhrdbfw_2541
	cmpl	$1, %edi
	jne	.Lhrdbfw_2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.Lhrdbfw_2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2496
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2542:
	addq	$1, %rax
.Lhrdbfw_2496:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2542
	jmp	.Lhrdbfw_2478
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2541:
	cmpq	$1, %r8
	movzwl	24(%rax), %eax
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rcx,%rax)
	movq	hrdbf_app_state+24(%rip), %r10
	jmp	.Lhrdbfw_2482
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2536:
	movl	%r9d, %eax
	movq	%r12, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.Lhrdbfw_2485:
	cmpl	$3, %eax
	je	.Lhrdbfw_2473
	testl	%eax, %eax
	je	.Lhrdbfw_2478
	leaq	.Lhrdbfw_C112(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2539:
	movzwl	24(%rax), %edx
	addq	%rdx, %rcx
	movzbl	22(%rax), %edx
	cmpq	%rdx, -8(%r8)
	movq	%rdx, %rax
	cmovbe	-8(%r8), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2476
	movq	%rcx, %r9
	leaq	(%r8,%rax), %r10
	subq	%r8, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2477:
	movzbl	(%r8), %edx
	movb	%dl, (%r9,%r8)
	addq	$1, %r8
	cmpq	%r10, %r8
	jne	.Lhrdbfw_2477
	movq	%rsi, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r11), %edx
.Lhrdbfw_2476:
	cmpq	%rax, %rdx
	jbe	.Lhrdbfw_2478
	leaq	2(%rsi), %rdx
	salq	$4, %rdx
	addq	%rdx, %r11
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2479:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r11), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbfw_2479
	jmp	.Lhrdbfw_2478
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2532:
	movq	%r12, %rdx
	call	hrdbf_write_date
	jmp	.Lhrdbfw_2485
.Lhrdbfw_2473:
	leaq	.Lhrdbfw_C111(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2502:
	xorl	%r9d, %r9d
	movq	%r12, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbfw_2485
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2535:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	jmp	hrdbf_app_rebuild_index
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2537:
	testq	%r9, %r9
	jns	.Lhrdbfw_2489
	movq	(%r8), %r8
.Lhrdbfw_2489:
	movq	%r8, %xmm2
	movq	%r12, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.Lhrdbfw_2485
.Lhrdbfw_2467:
	leaq	.Lhrdbfw_C110(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2529:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2530:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2531:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2534:
	leaq	.Lhrdbfw_C113(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C114:

.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,47,114,101,99,97,108,108,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C115:

.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,47,114,101,99,97,108,108,32,119,105,116,104,32,97,110,32,111,112,101,110,32,67,68,88,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,78,84,88,32,111,110,108,121,41,10,0
	.align 8
.Lhrdbfw_C116:

.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_delete
hrdbfw_app_delete:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2551
	movl	hrdbf_app_state+32960(%rip), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_2552
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2546
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2553
.Lhrdbfw_2546:
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbfw_2554
.Lhrdbfw_2543:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2554:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$42, (%rax,%rdx)
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2549
	cmpq	$0, hrdbf_app_state+32968(%rip)
	je	.Lhrdbfw_2549
	cmpb	$0, hrdbf_app_state+40(%rip)
	movq	hrdbf_app_state+24(%rip), %rax
	je	.Lhrdbfw_2549
	testq	%rax, %rax
	je	.Lhrdbfw_2549
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2549
	leaq	-1(%rax), %rdx
	movzwl	hrdbf_app_state+34(%rip), %r9d
	movq	hrdbf_app_state+32944(%rip), %r8
	leaq	hrdbf_app_state(%rip), %rcx
	movq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	imulq	%r9, %rax
	addq	%rax, %rdx
	addq	%rdx, %r8
	call	hrdbfw_local_write_at
	testl	%eax, %eax
	je	.Lhrdbfw_2543
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2549:
	leaq	.Lhrdbfw_C116(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2551:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2552:
	leaq	.Lhrdbfw_C114(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2553:
	leaq	.Lhrdbfw_C115(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C117:

.byte 104,98,99,58,32,68,66,70,32,114,101,99,97,108,108,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_recall
hrdbfw_app_recall:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2563
	movl	hrdbf_app_state+32960(%rip), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_2564
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2558
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2565
.Lhrdbfw_2558:
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbfw_2566
.Lhrdbfw_2555:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2566:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$32, (%rax,%rdx)
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2561
	cmpq	$0, hrdbf_app_state+32968(%rip)
	je	.Lhrdbfw_2561
	cmpb	$0, hrdbf_app_state+40(%rip)
	movq	hrdbf_app_state+24(%rip), %rax
	je	.Lhrdbfw_2561
	testq	%rax, %rax
	je	.Lhrdbfw_2561
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2561
	leaq	-1(%rax), %rdx
	movzwl	hrdbf_app_state+34(%rip), %r9d
	movq	hrdbf_app_state+32944(%rip), %r8
	leaq	hrdbf_app_state(%rip), %rcx
	movq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	imulq	%r9, %rax
	addq	%rax, %rdx
	addq	%rdx, %r8
	call	hrdbfw_local_write_at
	testl	%eax, %eax
	je	.Lhrdbfw_2555
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2561:
	leaq	.Lhrdbfw_C117(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2563:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2564:
	leaq	.Lhrdbfw_C114(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2565:
	leaq	.Lhrdbfw_C115(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_commit
hrdbfw_app_commit:
	ret
	.p2align 4
	.globl	hrdbfw_app_set_name
hrdbfw_app_set_name:
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2594
	movl	hrdbf_app_state+32960(%rip), %r10d
	testl	%r10d, %r10d
	je	.Lhrdbfw_2595
	movq	%rcx, %r13
	movq	%rdx, %r12
	movq	%r8, %r14
	movq	%r9, %rsi
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2574
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2596
.Lhrdbfw_2574:
	movzwl	hrdbf_app_state+36(%rip), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_2573
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2584:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2575:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2576
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2575
.Lhrdbfw_2576:
	cmpq	%rax, %r12
	je	.Lhrdbfw_2597
.Lhrdbfw_2578:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.Lhrdbfw_2584
.Lhrdbfw_2573:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2597:
	testq	%r12, %r12
	je	.Lhrdbfw_2579
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2583
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2598:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_2579
.Lhrdbfw_2583:
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
	je	.Lhrdbfw_2598
	cmpq	%rcx, %r12
	jne	.Lhrdbfw_2578
.Lhrdbfw_2579:
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
.Lhrdbfw_2596:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2595:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2594:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C118:

.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_append
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2606
	movl	hrdbf_app_state+32960(%rip), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2607
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2602
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2608
.Lhrdbfw_2602:
	cmpq	$0, hrdbf_app_state+32968(%rip)
	je	.Lhrdbfw_2604
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2604
	movl	$0, hrdbf_app_found_flag(%rip)
	call	hrdbf_app_rebuild_index
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2604:
	leaq	.Lhrdbfw_C118(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2606:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2607:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2608:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C119:

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
	jne	.Lhrdbfw_2612
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_2612:
	leaq	.Lhrdbfw_C119(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C120:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C121:

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
	jne	.Lhrdbfw_2614
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_2630
	testl	%eax, %eax
	je	.Lhrdbfw_2622
	cmpl	$9, %eax
	jne	.Lhrdbfw_2618
.Lhrdbfw_2622:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2630:
	testl	$65280, %r11d
	je	.Lhrdbfw_2622
.Lhrdbfw_2617:
	leaq	.Lhrdbfw_C120(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2614:
	cmpl	$2, %eax
	je	.Lhrdbfw_2617
.Lhrdbfw_2618:
	leaq	.Lhrdbfw_C121(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C122:

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
	testl	%eax, %eax
	jne	.Lhrdbfw_2634
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_2634:
	leaq	.Lhrdbfw_C122(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C123:

.byte 104,98,99,58,32,68,66,70,32,105,110,118,97,108,105,100,32,68,97,116,101,32,99,111,109,112,97,114,105,115,111,110,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_compare
hrdbfw_app_compare:
	pushq	%rbp
	movq	%r8, %r11
	movq	%rsp, %rbp
	pushq	%r12
	pushq	%rsi
	movq	%rdx, %rsi
	pushq	%rbx
	movq	%r9, %rbx
	andq	$-16, %rsp
	subq	$80, %rsp
	movq	%rcx, 48(%rsp)
	movq	%rdx, 56(%rsp)
	cmpb	$11, %cl
	jne	.Lhrdbfw_2636
	cmpb	$11, %r8b
	je	.Lhrdbfw_2643
.Lhrdbfw_2636:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.Lhrdbfw_2644
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2643:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2638
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2638
	xorl	%eax, %eax
	cmpq	%rbx, %rsi
	movq	$-1, %rdx
	seta	%al
	cmovb	%rdx, %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
.Lhrdbfw_2644:
	leaq	.Lhrdbfw_C122(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2638:
	leaq	.Lhrdbfw_C123(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C124:

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
	jne	.Lhrdbfw_2646
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2657
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_2648
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2665:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_2661
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_2657
.Lhrdbfw_2648:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_2665
.Lhrdbfw_2661:
	xorl	%eax, %eax
.Lhrdbfw_2645:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2646:
	cmpl	$8, %ebx
	je	.Lhrdbfw_2666
	cmpl	$5, %ebx
	je	.Lhrdbfw_2667
	cmpl	$7, %ebx
	je	.Lhrdbfw_2661
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2653
	cmpl	$12, %ebx
	ja	.Lhrdbfw_2653
	movl	$1, %eax
	movl	%ebx, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbfw_2654
	testb	$2, %al
	jne	.Lhrdbfw_2657
.Lhrdbfw_2653:
	leaq	.Lhrdbfw_C124(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2657:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2666:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2645
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_2645
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2667:
	testq	%rcx, %rcx
	js	.Lhrdbfw_2668
.Lhrdbfw_2652:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_2645
.Lhrdbfw_2668:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_2652
.Lhrdbfw_2654:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_2645
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C125:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10,0
	.align 8
.Lhrdbfw_C126:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,111,110,32,97,32,78,73,76,32,111,114,32,110,111,110,45,110,117,109,101,114,105,99,32,111,112,101,114,97,110,100,10,0
.Lhrdbfw_C127:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,114,101,106,101,99,116,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_arith
hrdbfw_app_arith:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r12
	movq	%rcx, %r12
	movq	%rdx, %rcx
	andq	$-16, %rsp
	subq	$80, %rsp
	movq	48(%rbp), %rax
	movq	%r8, 48(%rsp)
	leaq	48(%rsp), %rdx
	leaq	32(%rsp), %r8
	movq	%rax, 32(%rsp)
	movq	56(%rbp), %rax
	movq	%r9, 56(%rsp)
	leaq	64(%rsp), %r9
	movq	%rax, 40(%rsp)
	call	hrv_arith
	cmpl	$5, %eax
	je	.Lhrdbfw_2674
	cmpl	$1, %eax
	je	.Lhrdbfw_2675
	testl	%eax, %eax
	jne	.Lhrdbfw_2676
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.Lhrdbfw_2674:
	leaq	.Lhrdbfw_C125(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2676:
	leaq	.Lhrdbfw_C127(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2675:
	leaq	.Lhrdbfw_C126(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C128:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C128(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.413:
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
.balign 4
hrdbf_app_shared:
.zero 4
.text

.bss
.balign 4
hrdbf_app_struct:
.zero 4
.text

.bss
.balign 32
hrdbf_app_ntxpath:
.zero 260
.text

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
hrdbf_app_order_active:
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
.zero 80
.text

.bss
.balign 32
hrdbf_app_state:
.zero 33136
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

.bss
.balign 32
hrdbf_open_tmp:
.zero 32944
.text
	.align 8
.Lhrdbfw_C0:
	.long	0
	.long	1076101120
	.align 8
.Lhrdbfw_C65:
	.long	0
	.long	0
	.align 8
.Lhrdbfw_C105:
	.long	-798530048
	.long	1138748221
	.align 8
.Lhrdbfw_C106:
	.long	-798530048
	.long	-1008735427
	.align 8
.Lhrdbfw_C107:
	.long	0
	.long	1071644672

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

hrdbf_app_seek_dyn:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rcx, %r9
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrdbfw_app_seek_dyn
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

hrdbf_app_fcount:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_fcount
    leave
    ret

hrdbf_app_goto:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdi, %rcx
    call hrdbfw_app_goto
    leave
    ret

hrdbf_app_ordselect:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdi, %rcx
    call hrdbfw_app_ordselect
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

hrdbf_app_delete:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_delete
    leave
    ret

hrdbf_app_recall:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_recall
    leave
    ret

hrdbf_app_commit:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    call hrdbfw_app_commit
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
hrdbf_app_arith:
    push %rbp
    mov %rsp, %rbp
    sub $64, %rsp
    mov %rcx, 32(%rsp)
    mov %r8, 40(%rsp)
    mov %rdx, %r9
    mov %rsi, %r8
    mov %rdi, %rdx
    lea 48(%rsp), %rcx
    call hrdbfw_app_arith
    mov 48(%rsp), %rax
    mov 56(%rsp), %rdx
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
