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
hrdbfw_release.isra.0:
	movl	$32768, %r8d
	xorl	%edx, %edx
	jmp VirtualFree
	.p2align 4
hrdbfw_local_put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.Lhrdbfw_571
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.Lhrdbfw_592
	subl	%r10d, %edx
	je	.Lhrdbfw_577
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_578:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.Lhrdbfw_578
.Lhrdbfw_577:
	testl	%r10d, %r10d
	je	.Lhrdbfw_576
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_579:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.Lhrdbfw_579
.Lhrdbfw_576:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_571:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_592:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.Lhrdbfw_576
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_575:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.Lhrdbfw_576
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_575
	jmp	.Lhrdbfw_576
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
	ja	.Lhrdbfw_593
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.Lhrdbfw_619
	cmpb	%r8b, %r13b
	jnb	.Lhrdbfw_619
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.Lhrdbfw_595
	negq	%rcx
	movl	$1, %r11d
.Lhrdbfw_595:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_596
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.Lhrdbfw_597
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_598:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.Lhrdbfw_598
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq $1, %r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.Lhrdbfw_599
.Lhrdbfw_597:
	addq	$1, %rcx
.Lhrdbfw_599:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_604:
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
	ja	.Lhrdbfw_604
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
	ja	.Lhrdbfw_647
	testl	%r11d, %r11d
	je	.Lhrdbfw_610
	movb	$45, 96(%rsp)
.Lhrdbfw_610:
	cmpl	%r10d, %ebp
	jb	.Lhrdbfw_648
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.Lhrdbfw_612:
	testb	%r13b, %r13b
	je	.Lhrdbfw_614
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.Lhrdbfw_615
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_616:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.Lhrdbfw_616
	addl	%ebp, %eax
.Lhrdbfw_615:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_617:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.Lhrdbfw_617
.Lhrdbfw_614:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_593:
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
.Lhrdbfw_619:
	movl	$4, %eax
	jmp	.Lhrdbfw_593
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_596:
	jnb	.Lhrdbfw_599
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.Lhrdbfw_599
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_600
	xorl	%eax, %eax
	jmp	.Lhrdbfw_601
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_603:
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_600
.Lhrdbfw_601:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.Lhrdbfw_603
	jmp	.Lhrdbfw_599
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_648:
	testl	%r14d, %r14d
	je	.Lhrdbfw_623
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.Lhrdbfw_613
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_649:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.Lhrdbfw_613:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.Lhrdbfw_649
	jmp	.Lhrdbfw_612
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_647:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_608:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbfw_608
	xorl	%eax, %eax
	jmp	.Lhrdbfw_593
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_600:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_602:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_602
	xorl	%eax, %eax
	jmp	.Lhrdbfw_593
.Lhrdbfw_623:
	movl	%r11d, %edx
	jmp	.Lhrdbfw_612
	.p2align 4
hrdbfw_local_bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_699
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.Lhrdbfw_702
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.Lhrdbfw_658
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.Lhrdbfw_660
.Lhrdbfw_659:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_663
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_662:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.Lhrdbfw_703
	movl	%eax, %ecx
.Lhrdbfw_663:
	cmpl	%ecx, %r10d
	jbe	.Lhrdbfw_662
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbfw_662
.Lhrdbfw_661:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.Lhrdbfw_660
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.Lhrdbfw_668
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_667:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.Lhrdbfw_667
.Lhrdbfw_668:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.Lhrdbfw_660
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_669:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_669
.Lhrdbfw_660:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.Lhrdbfw_650
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_670
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_671:
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
	jne	.Lhrdbfw_671
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.Lhrdbfw_650
	movl	%edi, 288(%r9)
	jmp	.Lhrdbfw_650
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_702:
	testl	%r10d, %r10d
	je	.Lhrdbfw_653
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_655:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_655
	testl	%eax, %eax
	je	.Lhrdbfw_653
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_656:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_656
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.Lhrdbfw_653
	jne	.Lhrdbfw_678
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.Lhrdbfw_653
.Lhrdbfw_678:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_653:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.Lhrdbfw_650:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_699:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_658:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.Lhrdbfw_659
	jmp	.Lhrdbfw_661
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_703:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_661
.Lhrdbfw_670:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.Lhrdbfw_650
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
.Lhrdbfw_705:
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
	jbe	.Lhrdbfw_713
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_705
.Lhrdbfw_713:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_711:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_707
	jmp	.Lhrdbfw_708
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_709:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_708
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_707:
	testb	%cl, %cl
	jne	.Lhrdbfw_709
.Lhrdbfw_708:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_704
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_711
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_704:
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
	je	.Lhrdbfw_728
	movabs	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.Lhrdbfw_966
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.Lhrdbfw_726:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_731:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_732:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_732
	testq	%rax, %rax
	je	.Lhrdbfw_733
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.Lhrdbfw_733:
	subl	$1, %r9d
	jne	.Lhrdbfw_731
	testb	%r11b, %r11b
	je	.Lhrdbfw_735
	movl	%r10d, 352(%rsp)
.Lhrdbfw_735:
	testl	%r12d, %r12d
	js	.Lhrdbfw_736
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_963:
	movl	352(%rsp), %eax
.Lhrdbfw_739:
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_737
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_742:
	cmpq	$80, %rbx
	je	.Lhrdbfw_967
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.Lhrdbfw_737:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.Lhrdbfw_742
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_742
	testl	%ebx, %ebx
	jne	.Lhrdbfw_968
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_727
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.Lhrdbfw_969
.Lhrdbfw_728:
	xorl	%eax, %eax
.Lhrdbfw_720:
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
.Lhrdbfw_966:
	testq	%rax, %rax
	jne	.Lhrdbfw_970
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.Lhrdbfw_727
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.Lhrdbfw_728
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_730:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_730
	jmp	.Lhrdbfw_720
.Lhrdbfw_727:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.Lhrdbfw_728
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.Lhrdbfw_720
.Lhrdbfw_970:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.Lhrdbfw_726
.Lhrdbfw_736:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	hrdbfw_local_bn_shr_round
	cmpl	$1, %eax
	jbe	.Lhrdbfw_963
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_835
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.Lhrdbfw_741:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.Lhrdbfw_741
	testq	%rdx, %rdx
	je	.Lhrdbfw_739
	leal	1(%rax), %edx
.Lhrdbfw_740:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.Lhrdbfw_739
.Lhrdbfw_967:
	movl	$79, %r10d
.Lhrdbfw_745:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.Lhrdbfw_749:
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
	ja	.Lhrdbfw_749
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.Lhrdbfw_751
.Lhrdbfw_971:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_751:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.Lhrdbfw_971
	testl	%r10d, %r10d
	je	.Lhrdbfw_752
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.Lhrdbfw_754:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_753:
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
	jne	.Lhrdbfw_753
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.Lhrdbfw_972
	movq	%rax, %rbp
	jmp	.Lhrdbfw_754
.Lhrdbfw_972:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.Lhrdbfw_752:
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
.Lhrdbfw_756:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_757:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_757
	testq	%rax, %rax
	je	.Lhrdbfw_758
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.Lhrdbfw_758:
	subl	$1, %r9d
	jne	.Lhrdbfw_756
	testb	%dil, %dil
	je	.Lhrdbfw_760
	movl	%r10d, 656(%rsp)
.Lhrdbfw_760:
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
	je	.Lhrdbfw_761
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
.Lhrdbfw_762:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_763:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_763
	testq	%rax, %rax
	je	.Lhrdbfw_764
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_764:
	subl	$1, %ebx
	jne	.Lhrdbfw_762
	testb	%bpl, %bpl
	je	.Lhrdbfw_766
	movl	%edi, 960(%rsp)
.Lhrdbfw_766:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_767:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.Lhrdbfw_774
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.Lhrdbfw_801:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_775:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.Lhrdbfw_775
	cmpb	$53, (%rdi)
	ja	.Lhrdbfw_776
	je	.Lhrdbfw_973
.Lhrdbfw_777:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.Lhrdbfw_974
.Lhrdbfw_779:
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
	je	.Lhrdbfw_783
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_782:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_784:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_784
	testq	%rax, %rax
	je	.Lhrdbfw_785
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.Lhrdbfw_785:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.Lhrdbfw_782
	testb	%r15b, %r15b
	je	.Lhrdbfw_783
	movl	%r9d, 1264(%rsp)
.Lhrdbfw_783:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.Lhrdbfw_788
	jnb	.Lhrdbfw_789
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_790
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_797
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_800:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.Lhrdbfw_975
.Lhrdbfw_797:
	cmpl	$-1, %eax
	jne	.Lhrdbfw_800
.Lhrdbfw_796:
	testb	$1, 40(%rsp)
	je	.Lhrdbfw_955
.Lhrdbfw_790:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.Lhrdbfw_956
	cmpl	%r12d, %ebp
	jb	.Lhrdbfw_801
.Lhrdbfw_956:
	movq	2400(%rsp), %rsi
.Lhrdbfw_774:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.Lhrdbfw_803:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.Lhrdbfw_804:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.Lhrdbfw_804
	cmpl	%r12d, %ebp
	jnb	.Lhrdbfw_805
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.Lhrdbfw_806
	jne	.Lhrdbfw_805
	testb	$1, %r8b
	jne	.Lhrdbfw_806
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.Lhrdbfw_805
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.Lhrdbfw_807
.Lhrdbfw_976:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.Lhrdbfw_805
.Lhrdbfw_807:
	cmpb	$48, (%rcx)
	je	.Lhrdbfw_976
.Lhrdbfw_806:
	addq	$1, %r8
.Lhrdbfw_805:
	movabs	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.Lhrdbfw_808:
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
	ja	.Lhrdbfw_808
	cmpl	%ebp, %ecx
	jbe	.Lhrdbfw_809
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.Lhrdbfw_813
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.Lhrdbfw_809:
	xorl	%edx, %edx
	jmp	.Lhrdbfw_811
.Lhrdbfw_977:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_811:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbfw_977
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_812
.Lhrdbfw_978:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbfw_812
	movl	%eax, %ecx
.Lhrdbfw_813:
	cmpl	$1, %ecx
	ja	.Lhrdbfw_978
.Lhrdbfw_812:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.Lhrdbfw_979
	cmpl	%ecx, %r8d
	jge	.Lhrdbfw_818
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.Lhrdbfw_824
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.Lhrdbfw_821
.Lhrdbfw_820:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.Lhrdbfw_980
	movq	%rcx, %rdx
.Lhrdbfw_821:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.Lhrdbfw_820
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.Lhrdbfw_824
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_982:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.Lhrdbfw_981
	movl	%edx, %r8d
.Lhrdbfw_824:
	cmpl	$1, %r8d
	jne	.Lhrdbfw_982
.Lhrdbfw_823:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.Lhrdbfw_816
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_788:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.Lhrdbfw_793
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_795:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.Lhrdbfw_983
.Lhrdbfw_793:
	cmpl	$-1, %edx
	jne	.Lhrdbfw_795
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.Lhrdbfw_797
	jmp	.Lhrdbfw_796
.Lhrdbfw_973:
	testb	$1, %r8b
	jne	.Lhrdbfw_776
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbfw_777
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.Lhrdbfw_778
.Lhrdbfw_984:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_777
.Lhrdbfw_778:
	cmpb	$48, (%rax)
	je	.Lhrdbfw_984
.Lhrdbfw_776:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.Lhrdbfw_779
.Lhrdbfw_974:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_780:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.Lhrdbfw_780
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_779
	movabs	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.Lhrdbfw_779
.Lhrdbfw_975:
	jnb	.Lhrdbfw_799
	cmpl	$1, %ecx
	je	.Lhrdbfw_955
.Lhrdbfw_799:
	testl	%ecx, %ecx
	jne	.Lhrdbfw_790
	jmp	.Lhrdbfw_796
.Lhrdbfw_983:
	jnb	.Lhrdbfw_794
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.Lhrdbfw_797
	jmp	.Lhrdbfw_790
.Lhrdbfw_789:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_964
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_797
.Lhrdbfw_964:
	jnb	.Lhrdbfw_790
.Lhrdbfw_955:
	movq	2400(%rsp), %rsi
	jmp	.Lhrdbfw_803
.Lhrdbfw_794:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_964
	movl	$1, %ecx
	jmp	.Lhrdbfw_797
.Lhrdbfw_761:
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
.Lhrdbfw_769:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_770:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_770
	testq	%rax, %rax
	je	.Lhrdbfw_771
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_771:
	subl	$1, %ebx
	jne	.Lhrdbfw_769
	testb	%r11b, %r11b
	je	.Lhrdbfw_773
	movl	%edi, 960(%rsp)
.Lhrdbfw_773:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
	jmp	.Lhrdbfw_767
.Lhrdbfw_818:
	cmpl	$1, %ecx
	je	.Lhrdbfw_823
.Lhrdbfw_816:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.Lhrdbfw_825:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.Lhrdbfw_728
	testl	%r10d, %r10d
	je	.Lhrdbfw_849
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.Lhrdbfw_827:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbfw_828
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.Lhrdbfw_830:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_829
	movzbl	0(%r13,%rdx), %r11d
.Lhrdbfw_829:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_830
	addl	%r10d, %eax
.Lhrdbfw_831:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbfw_720
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.Lhrdbfw_833
.Lhrdbfw_986:
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_851
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.Lhrdbfw_832:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.Lhrdbfw_985
.Lhrdbfw_833:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.Lhrdbfw_986
.Lhrdbfw_851:
	movl	$48, %r10d
	jmp	.Lhrdbfw_832
.Lhrdbfw_849:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.Lhrdbfw_827
.Lhrdbfw_979:
	jne	.Lhrdbfw_815
	cmpb	$52, 1600(%rsp)
	jbe	.Lhrdbfw_815
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.Lhrdbfw_816
.Lhrdbfw_815:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.Lhrdbfw_825
.Lhrdbfw_828:
	movb	$48, (%rdx)
	jmp	.Lhrdbfw_831
.Lhrdbfw_985:
	addl	%r9d, %eax
	jmp	.Lhrdbfw_720
.Lhrdbfw_968:
	subl	$1, %r10d
	jmp	.Lhrdbfw_745
.Lhrdbfw_969:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_748:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_748
	jmp	.Lhrdbfw_720
.Lhrdbfw_981:
	movl	%r8d, %ecx
	jmp	.Lhrdbfw_816
.Lhrdbfw_835:
	movl	$1, %edx
	jmp	.Lhrdbfw_740
.Lhrdbfw_980:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.Lhrdbfw_824
	.p2align 4
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.Lhrdbfw_994
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.Lhrdbfw_987
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_987
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_987:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_994:
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
	jmp	.Lhrdbfw_998
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1000:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_999
.Lhrdbfw_998:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_1000
.Lhrdbfw_999:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1001
	movl	$32, %ecx
	leaq	.Lhrdbfw_C1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1003:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1007
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1003
.Lhrdbfw_1007:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_1001:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1004
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_1004:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	addq	$40, %rsp
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
	ja	.Lhrdbfw_1008
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call VirtualAlloc
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_1016
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 32952(%rbx)
	je	.Lhrdbfw_1013
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1010:
	movq	32944(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	32952(%rbx), %rax
	jb	.Lhrdbfw_1010
.Lhrdbfw_1013:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.Lhrdbfw_1012
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1011:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbfw_1011
	addq	%r14, %rdx
.Lhrdbfw_1012:
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
	je	.Lhrdbfw_1028
.Lhrdbfw_1014:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call VirtualFree
.Lhrdbfw_1008:
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
.Lhrdbfw_1028:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_1014
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_1014
	xorl	%edx, %edx
	movq	32944(%rbx), %rcx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1019
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
	jmp	.Lhrdbfw_1008
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1016:
	movl	$8, %r15d
	jmp	.Lhrdbfw_1008
.Lhrdbfw_1019:
	movl	$7, %r15d
	jmp	.Lhrdbfw_1014
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
.Lhrdbfw_1030:
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
	jbe	.Lhrdbfw_1040
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_1030
.Lhrdbfw_1040:
	leaq	32778(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$32937, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1038:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_1032
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1034:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1033
.Lhrdbfw_1032:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1034
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_1035
	jmp	.Lhrdbfw_1033
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1036:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1033
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_1035:
	testb	%cl, %cl
	jne	.Lhrdbfw_1036
.Lhrdbfw_1033:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_1029
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_1038
.Lhrdbfw_1029:
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
.Lhrdbfw_1048:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_1047
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	32778(%r10), %rax
	jmp	.Lhrdbfw_1050
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1052:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1051
.Lhrdbfw_1050:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1052
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1053
	jmp	.Lhrdbfw_1051
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1054:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1051
.Lhrdbfw_1053:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1054
.Lhrdbfw_1051:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_1048
.Lhrdbfw_1047:
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
	jmp	.Lhrdbfw_1062
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1064:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1063
.Lhrdbfw_1062:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_1064
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_1065
	jmp	.Lhrdbfw_1063
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1067:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1063
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_1065:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1067
.Lhrdbfw_1063:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_1069
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1071:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1070
.Lhrdbfw_1069:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1071
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_1072
	jmp	.Lhrdbfw_1070
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1073:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1070
.Lhrdbfw_1072:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1073
.Lhrdbfw_1070:
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
	je	.Lhrdbfw_1151
	js	.Lhrdbfw_1085
	movabs	$-4611681598906040321, %r8
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1084
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1153:
	movl	%eax, %edx
	andl	$-65, %edx
	cmpb	$60, %dl
	je	.Lhrdbfw_1085
.Lhrdbfw_1089:
	movw	%ax, (%r15,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1152
	testb	%al, %al
	js	.Lhrdbfw_1085
	cmpq	$258, %rbx
	ja	.Lhrdbfw_1085
.Lhrdbfw_1084:
	cmpb	$63, %al
	ja	.Lhrdbfw_1153
	btq	%rax, %r8
	jc	.Lhrdbfw_1085
	cmpb	$60, %al
	je	.Lhrdbfw_1085
	cmpb	$58, %al
	jne	.Lhrdbfw_1088
	cmpq	$1, %rbx
	jne	.Lhrdbfw_1085
	movzbl	(%rcx), %eax
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	ja	.Lhrdbfw_1085
	movl	$58, %eax
	jmp	.Lhrdbfw_1089
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1088:
	cmpb	$47, %al
	jne	.Lhrdbfw_1089
	movl	$92, %eax
	jmp	.Lhrdbfw_1089
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1159:
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1095
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1085:
	xorl	%eax, %eax
.Lhrdbfw_1081:
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
.Lhrdbfw_1152:
	xorl	%eax, %eax
	xorl	%r14d, %r14d
	leaq	.Lhrdbfw_C3(%rip), %rdi
	movw	%ax, (%r15,%rbx,2)
	leaq	.Lhrdbfw_C4(%rip), %rbp
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1110
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1155:
	addq	$1, %r14
.Lhrdbfw_1092:
	cmpq	%r14, %rbx
	jb	.Lhrdbfw_1154
.Lhrdbfw_1110:
	cmpq	%r14, %rbx
	je	.Lhrdbfw_1091
	cmpw	$92, (%r15,%r14,2)
	jne	.Lhrdbfw_1155
.Lhrdbfw_1091:
	movq	%r14, %rsi
	subq	%rax, %rsi
	je	.Lhrdbfw_1093
	movzwl	-2(%r15,%r14,2), %edx
	cmpw	$32, %dx
	je	.Lhrdbfw_1094
	cmpw	$46, %dx
	je	.Lhrdbfw_1094
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
.Lhrdbfw_1095:
	movl	%r13d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1097
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1098:
	movzwl	(%r12,%rax,2), %edx
.Lhrdbfw_1097:
	cmpw	$46, %dx
	je	.Lhrdbfw_1156
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_1098
	cmpw	$32, -2(%r12,%rsi,2)
	jne	.Lhrdbfw_1100
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1104:
	subq	$1, %rsi
	je	.Lhrdbfw_1100
.Lhrdbfw_1103:
	cmpw	$32, -2(%r12,%rsi,2)
	je	.Lhrdbfw_1104
.Lhrdbfw_1100:
	movq	%rdi, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	movq	%rbp, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1085
	cmpq	$4, %rsi
	jne	.Lhrdbfw_1093
	movzwl	6(%r12), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_1093
	movzwl	%r13w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_1107
.Lhrdbfw_1157:
	leaq	.Lhrdbfw_C10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_1115
	movzwl	(%r12,%rcx,2), %eax
.Lhrdbfw_1107:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1115
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_1157
	jmp	.Lhrdbfw_1085
.Lhrdbfw_1115:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_1109
.Lhrdbfw_1158:
	movzwl	(%r12,%rdx,2), %r13d
.Lhrdbfw_1109:
	movzwl	%r13w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_1093
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_1085
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_1158
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1093:
	leaq	1(%r14), %rax
	movq	%rax, %r14
	jmp	.Lhrdbfw_1092
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1094:
	cmpq	$1, %rsi
	je	.Lhrdbfw_1159
	cmpq	$2, %rsi
	jne	.Lhrdbfw_1085
	addq	%rax, %rax
	leaq	(%r15,%rax), %r12
	cmpw	$46, (%r12)
	jne	.Lhrdbfw_1085
	movzwl	2(%r15,%rax), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1095
	jmp	.Lhrdbfw_1085
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1156:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_1103
	jmp	.Lhrdbfw_1100
.Lhrdbfw_1154:
	cmpw	$92, (%r15)
	je	.Lhrdbfw_1085
	movl	$1, %eax
	cmpq	$1, %rbx
	je	.Lhrdbfw_1081
	cmpw	$58, 2(%r15)
	jne	.Lhrdbfw_1081
	cmpq	$2, %rbx
	je	.Lhrdbfw_1085
	cmpw	$92, 4(%r15)
	jne	.Lhrdbfw_1085
	jmp	.Lhrdbfw_1081
.Lhrdbfw_1151:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movw	%dx, (%r15)
	jmp	.Lhrdbfw_1081
	.p2align 4
hrntx_file_flush.part.0.constprop.0:
	movzbl	hrdbf_app_ntxpath(%rip), %eax
	testb	%al, %al
	je	.Lhrdbfw_1201
	cmpb	$92, %al
	je	.Lhrdbfw_1205
	cmpb	$47, %al
	jne	.Lhrdbfw_1165
	cmpb	$47, hrdbf_app_ntxpath+1(%rip)
	je	.Lhrdbfw_1201
.Lhrdbfw_1165:
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
	je	.Lhrdbfw_1203
	movq	hrdbf_app_order+64(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1168
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
.Lhrdbfw_1168:
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
	je	.Lhrdbfw_1203
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	movq	%rax, %rcx
	call SetFilePointerEx
	testl	%eax, %eax
	je	.Lhrdbfw_1172
	leaq SetEndOfFile(%rip), %rdi
	movq	%r12, %rcx
	call	*%rdi
	testl	%eax, %eax
	je	.Lhrdbfw_1172
	movq	hrdbf_app_order+48(%rip), %r8
	leaq WriteFile(%rip), %rsi
	xorl	%ebx, %ebx
	leaq	76(%rsp), %rbp
	testq	%r8, %r8
	jne	.Lhrdbfw_1170
	jmp	.Lhrdbfw_1171
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1206:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1172
	movq	hrdbf_app_order+48(%rip), %r8
	addq	%rax, %rbx
	cmpq	%rbx, %r8
	jbe	.Lhrdbfw_1171
.Lhrdbfw_1170:
	movq	hrdbf_app_order+32(%rip), %rdx
	subl	%ebx, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	addq	%rbx, %rdx
	call	*%rsi
	testl	%eax, %eax
	jne	.Lhrdbfw_1206
.Lhrdbfw_1172:
	movq	%r12, %rcx
.Lhrdbfw_1204:
	call CloseHandle
.Lhrdbfw_1203:
	movl	$7, %eax
.Lhrdbfw_1160:
	addq	$608, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1205:
	cmpb	$92, hrdbf_app_ntxpath+1(%rip)
	jne	.Lhrdbfw_1165
.Lhrdbfw_1201:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1171:
	movq	%r12, %rcx
	call	*%rdi
	movq	%r12, %rcx
	testl	%eax, %eax
	je	.Lhrdbfw_1204
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1203
	movl	$0, hrdbf_app_order+72(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1160
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
	je	.Lhrdbfw_1211
	movq	%rdx, %rsi
	movq	%r8, %rbx
	movq	%r9, %rdi
	cmpb	$92, %al
	je	.Lhrdbfw_1255
	cmpb	$47, %al
	jne	.Lhrdbfw_1212
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_1211
.Lhrdbfw_1212:
	leaq	96(%rsp), %r12
	movq	%r12, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_1211
	cmpl	$2, %ebp
	je	.Lhrdbfw_1232
	xorl	%r8d, %r8d
	movl	$-1073741824, %edx
	cmpl	$1, %ebp
	movl	$-2147483648, %eax
	cmovne	%eax, %edx
.Lhrdbfw_1215:
	movq	%r12, %rcx
	movl	$128, 40(%rsp)
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_1256
	movq	%rax, (%rdi)
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%rax, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1257
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_1258
	cmpq	$1073741824, %r10
	jg	.Lhrdbfw_1259
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1220
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1260
.Lhrdbfw_1220:
	movq	%r10, %rdx
	movq	%r10, (%rbx)
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, (%rsi)
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1221
	movq	(%rbx), %r8
	leaq ReadFile(%rip), %rdi
	xorl	%r15d, %r15d
	leaq	76(%rsp), %rbp
	leaq GetLastError(%rip), %r13
	testq	%r8, %r8
	jne	.Lhrdbfw_1222
	jmp	.Lhrdbfw_1223
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1227:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1254
	movq	(%rbx), %r8
	movl	%eax, %edx
	movq	%r8, %rax
	subq	%r15, %rax
	cmpq	%rax, %rdx
	ja	.Lhrdbfw_1261
	addq	%rdx, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_1223
	movq	(%rsi), %rdx
.Lhrdbfw_1222:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rdi
	testl	%eax, %eax
	jne	.Lhrdbfw_1227
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_1227
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1254:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1255:
	cmpb	$92, 1(%rcx)
	jne	.Lhrdbfw_1212
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1211:
	leaq	.Lhrdbfw_C12(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_1207:
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
.Lhrdbfw_1232:
	movl	$3, %r8d
	movl	$-2147483648, %edx
	jmp	.Lhrdbfw_1215
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1258:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1223:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rbp, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rdi
	testl	%eax, %eax
	je	.Lhrdbfw_1262
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_1231
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1231
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_1207
.Lhrdbfw_1231:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1259:
	leaq	.Lhrdbfw_C16(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C17(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1261:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1254
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1257:
	call GetLastError
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1256:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1207
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1260:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1207
.Lhrdbfw_1221:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1207
.Lhrdbfw_1262:
	call GetLastError
	jmp	.Lhrdbfw_1254
	.p2align 4
hrntx_file_open.part.0.constprop.0:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	%edx, %ebx
	subq	$72, %rsp
	movl	%edx, hrdbf_app_order+76(%rip)
	testl	%edx, %edx
	je	.Lhrdbfw_1285
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1266
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rdi
.Lhrdbfw_1269:
	movl	$4, %r12d
	cmpq	$67108864, %rdi
	ja	.Lhrdbfw_1266
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
	je	.Lhrdbfw_1273
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
	je	.Lhrdbfw_1263
	cmpl	$5, %eax
	sete	%r12b
	movzbl	%r12b, %r12d
	leal	1(%r12,%r12), %r12d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1266:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmovne	%eax, %r12d
.Lhrdbfw_1263:
	addq	$72, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1285:
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1266
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rdi
	jmp	.Lhrdbfw_1269
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1273:
	movl	$8, %r12d
	jmp	.Lhrdbfw_1266
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
	je	.Lhrdbfw_1287
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_1287:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1290
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1290
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_1292
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
.Lhrdbfw_1294:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_1304
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1290:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1292:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1295
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1304:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1295:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_1294
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
	je	.Lhrdbfw_1307
	testl	%edx, %edx
	je	.Lhrdbfw_1309
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1309
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1309:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1307:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1310
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1312
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_1312:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1310:
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
	jbe	.Lhrdbfw_1393
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_1394
	movzwl	8(%rdx), %eax
	movq	%r8, %r13
	movw	%ax, hrdbf_open_tmp+32(%rip)
	movzwl	10(%rdx), %edi
	movw	%di, hrdbf_open_tmp+34(%rip)
	movl	4(%rdx), %ebp
	movl	%edi, 56(%rsp)
	movl	%ebp, hrdbf_open_tmp+16(%rip)
	cmpw	$32, %ax
	jbe	.Lhrdbfw_1319
	movq	%rax, 40(%rsp)
	testl	%edi, %edi
	je	.Lhrdbfw_1319
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1319
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
.Lhrdbfw_1343:
	cmpb	$13, (%rsi)
	je	.Lhrdbfw_1395
	cmpq	48(%rsp), %r13
	je	.Lhrdbfw_1396
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	cmpw	$2046, %ax
	je	.Lhrdbfw_1397
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
.Lhrdbfw_1327:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, 42(%r8,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1327
	movq	%r15, %rax
	salq	$4, %rax
	movzbl	42(%rax,%rdi), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_1328
	movzwl	%cx, %eax
	cmpw	$1, %cx
	jbe	.Lhrdbfw_1329
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
.Lhrdbfw_1330:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_1333
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1399:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_1333:
	leaq	(%rax,%r9), %rcx
	cmpb	%dl, -1(%rcx,%r8)
	jne	.Lhrdbfw_1398
	cmpq	%rax, %r10
	jne	.Lhrdbfw_1399
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
	jmp	.Lhrdbfw_1315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1319:
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
.Lhrdbfw_1315:
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
.Lhrdbfw_1398:
	addq	$16, %r8
	cmpq	%r8, %r11
	jne	.Lhrdbfw_1330
.Lhrdbfw_1329:
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
	je	.Lhrdbfw_1400
	cmpb	$67, %cl
	je	.Lhrdbfw_1401
	cmpb	$78, %cl
	je	.Lhrdbfw_1402
	cmpb	$76, %cl
	je	.Lhrdbfw_1403
	cmpb	$68, %cl
	jne	.Lhrdbfw_1340
	cmpw	$8, 22(%rax)
	je	.Lhrdbfw_1336
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
	jmp	.Lhrdbfw_1315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1393:
	leaq	.Lhrdbfw_C15(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1394:
	leaq	.Lhrdbfw_C24(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C25(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1401:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1404
.Lhrdbfw_1336:
	addl	%edx, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_1405
	addq	$32, %r13
	addq	$32, %rsi
	cmpq	%r13, 40(%rsp)
	ja	.Lhrdbfw_1343
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1402:
	cmpb	$17, %r8b
	ja	.Lhrdbfw_1367
	cmpb	%r8b, %dl
	ja	.Lhrdbfw_1336
.Lhrdbfw_1367:
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
	jmp	.Lhrdbfw_1315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1403:
	cmpw	$1, 22(%rax)
	je	.Lhrdbfw_1336
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
	jmp	.Lhrdbfw_1315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1396:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1397:
	leaq	.Lhrdbfw_C31(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1395:
	cmpw	$0, hrdbf_open_tmp+36(%rip)
	movl	%ebx, %esi
	movq	%r13, %rax
	movl	60(%rsp), %ebp
	movq	184(%rsp), %rbx
	movq	192(%rsp), %r13
	je	.Lhrdbfw_1406
	addq	$1, %rax
	cmpl	%esi, 56(%rsp)
	je	.Lhrdbfw_1345
	jmp	.Lhrdbfw_1407
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1346:
	addq	$1, %rax
	cmpb	$0, -1(%rbx,%rax)
	jne	.Lhrdbfw_1408
.Lhrdbfw_1345:
	cmpq	%rax, 40(%rsp)
	ja	.Lhrdbfw_1346
	movl	%esi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	40(%rsp), %rax
	divq	%rcx
	movl	%ebp, %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1409
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	40(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_1348
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_1349
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_1348
.Lhrdbfw_1349:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1328:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1400:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1408:
	leaq	.Lhrdbfw_C52(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1405:
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1404:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1407:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1406:
	leaq	.Lhrdbfw_C49(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1340:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1348:
	testl	%ebp, %ebp
	movq	%rbx, hrdbf_open_tmp(%rip)
	sete	%al
	movq	%r13, hrdbf_open_tmp+8(%rip)
	movb	$1, hrdbf_open_tmp+40(%rip)
	movq	$1, hrdbf_open_tmp+24(%rip)
	movb	%al, hrdbf_open_tmp+39(%rip)
	movb	%al, hrdbf_open_tmp+38(%rip)
	testq	%r8, %r8
	je	.Lhrdbfw_1364
	xorl	%r13d, %r13d
	leaq	hrdbf_open_tmp(%rip), %rbp
	leaq	64(%rsp), %r8
.Lhrdbfw_1353:
	movzwl	hrdbf_open_tmp+34(%rip), %eax
	movzwl	hrdbf_open_tmp+32(%rip), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_1351
	cmpb	$42, %dil
	jne	.Lhrdbfw_1410
.Lhrdbfw_1351:
	cmpw	$0, hrdbf_open_tmp+36(%rip)
	movq	%r13, hrdbf_open_tmp+24(%rip)
	movl	$1, %esi
	movq	%rbp, %r14
	jne	.Lhrdbfw_1352
	jmp	.Lhrdbfw_1359
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1355:
	movl	%esi, %edx
	movq	%rbp, %rcx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1411
	movzwl	hrdbf_open_tmp+36(%rip), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_1359
.Lhrdbfw_1352:
	movl	$85, %eax
	cmpb	$0, hrdbf_open_tmp+40(%rip)
	movb	$0, 92(%rsp)
	movw	%ax, 64(%rsp)
	movb	$0, 66(%rsp)
	movq	$0, 72(%rsp)
	movq	$0, 80(%rsp)
	movl	$0, 88(%rsp)
	jne	.Lhrdbfw_1355
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
.Lhrdbfw_1356:
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	32(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 53(%rdx,%rbp)
	je	.Lhrdbfw_1412
.Lhrdbfw_1358:
	cmpb	$42, %dil
	jne	.Lhrdbfw_1315
	leaq	.Lhrdbfw_C62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	hrdbfw_local_dcat
	movl	32(%rsp), %eax
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1359:
	movl	hrdbf_open_tmp+16(%rip), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_1353
	cmpb	$0, hrdbf_open_tmp+40(%rip)
	je	.Lhrdbfw_1360
.Lhrdbfw_1350:
	movq	$1, hrdbf_open_tmp+24(%rip)
	testl	%eax, %eax
	sete	%dl
	movb	%dl, hrdbf_open_tmp+39(%rip)
	movb	%dl, hrdbf_open_tmp+38(%rip)
.Lhrdbfw_1360:
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
.Lhrdbfw_1361:
	cmpl	%r8d, %r9d
	jbe	.Lhrdbfw_1413
	leaq	-11(%rax), %rcx
.Lhrdbfw_1362:
	movzbl	(%r14,%rcx), %r10d
	movb	%r10b, (%r12,%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1362
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
	jmp	.Lhrdbfw_1361
.Lhrdbfw_1412:
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	32(%rsp), %eax
	jmp	.Lhrdbfw_1358
.Lhrdbfw_1413:
	movb	$0, 32778(%r12)
	xorl	%eax, %eax
	movb	$1, 40(%r12)
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1409:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1410:
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
	jmp	.Lhrdbfw_1315
.Lhrdbfw_1364:
	xorl	%eax, %eax
	leaq	hrdbf_open_tmp(%rip), %r14
	jmp	.Lhrdbfw_1350
.Lhrdbfw_1411:
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
	jmp	.Lhrdbfw_1356
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
	ja	.Lhrdbfw_1416
	je	.Lhrdbfw_1447
	cmpl	$5, %edx
	je	.Lhrdbfw_1420
	shrq	$8, %rax
	jne	.Lhrdbfw_1416
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_1416
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_1416
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1416
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_1416
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
	ja	.Lhrdbfw_1434
	testq	%rcx, %rcx
	je	.Lhrdbfw_1434
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_1448
.Lhrdbfw_1422:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_1416:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1447:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_1416
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_1416
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_1434
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_1434
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1416
.Lhrdbfw_1434:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1420:
	testq	%rax, %rax
	jns	.Lhrdbfw_1429
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1416
.Lhrdbfw_1429:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1448:
	testb	$3, %r9b
	jne	.Lhrdbfw_1422
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_1423
	addl	$1, %eax
	jmp	.Lhrdbfw_1422
.Lhrdbfw_1423:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_1422
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_1449
	leaq	hrdbfw_local_CSWTCH.425(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_1449:
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
	jne	.Lhrdbfw_1454
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_1465
	testl	%edx, %edx
	je	.Lhrdbfw_1457
	cmpl	$9, %edx
	je	.Lhrdbfw_1457
	movl	$1, %eax
.Lhrdbfw_1454:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1465:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1466
.Lhrdbfw_1457:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1466:
	movl	$2, %eax
	jmp	.Lhrdbfw_1454
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
	jne	.Lhrdbfw_1467
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1467
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.Lhrdbfw_1469
	cmpl	$11, %r14d
	jne	.Lhrdbfw_1469
.Lhrdbfw_1480:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbfw_1467:
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
.Lhrdbfw_1469:
	cmpl	$1, %r15d
	je	.Lhrdbfw_1483
	cmpl	$1, %r14d
	je	.Lhrdbfw_1483
	cmpl	$3, %r15d
	jne	.Lhrdbfw_1472
	cmpl	$3, %r14d
	jne	.Lhrdbfw_1472
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1467
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1483:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1467
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1472:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1476
	cmpl	$12, %r15d
	je	.Lhrdbfw_1506
	testl	%r15d, %r15d
	je	.Lhrdbfw_1475
	cmpl	$9, %r15d
	jne	.Lhrdbfw_1476
.Lhrdbfw_1475:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1476
	cmpl	$12, %r14d
	je	.Lhrdbfw_1507
	testl	%r14d, %r14d
	je	.Lhrdbfw_1480
	cmpl	$9, %r14d
	je	.Lhrdbfw_1480
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1476:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1508
.Lhrdbfw_1482:
	movl	$1, %eax
	jmp	.Lhrdbfw_1467
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1506:
	testl	$65280, %r11d
	je	.Lhrdbfw_1475
	jmp	.Lhrdbfw_1476
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1508:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1482
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1467
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1507:
	testl	$65280, %edi
	je	.Lhrdbfw_1480
	jmp	.Lhrdbfw_1476
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
	jne	.Lhrdbfw_1509
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.Lhrdbfw_1530
.Lhrdbfw_1509:
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
.Lhrdbfw_1530:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1511
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1531
	testl	%eax, %eax
	je	.Lhrdbfw_1513
	cmpl	$9, %eax
	je	.Lhrdbfw_1513
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1511:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1532
.Lhrdbfw_1519:
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
.Lhrdbfw_1532:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1519
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.Lhrdbfw_1520
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.Lhrdbfw_1520:
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1509
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1531:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1511
.Lhrdbfw_1513:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1511
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.Lhrdbfw_1533
	testl	%edx, %edx
	je	.Lhrdbfw_1516
	cmpl	$9, %edx
	jne	.Lhrdbfw_1511
.Lhrdbfw_1516:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1509
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1533:
	testl	$65280, %esi
	je	.Lhrdbfw_1516
	jmp	.Lhrdbfw_1511
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
	jne	.Lhrdbfw_1534
	movzbl	%r11b, %ecx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_1538
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbfw_1536
	andl	$2, %edx
	jne	.Lhrdbfw_1540
.Lhrdbfw_1538:
	movl	$1, %eax
.Lhrdbfw_1534:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1536:
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
.Lhrdbfw_1540:
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
	jne	.Lhrdbfw_1541
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_1588
	cmpl	$12, %eax
	jne	.Lhrdbfw_1567
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
.Lhrdbfw_1549:
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
	ja	.Lhrdbfw_1549
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_1589
	movl	$1, %r9d
.Lhrdbfw_1550:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_1551:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_1552
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_1590
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_1560
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1559:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_1559
.Lhrdbfw_1560:
	testq	%r13, %r13
	jns	.Lhrdbfw_1558
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_1558:
	testl	%r9d, %r9d
	je	.Lhrdbfw_1561
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_1563
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1571:
	movl	%edx, %eax
.Lhrdbfw_1563:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1562
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1562:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_1571
	addl	%r9d, %r10d
.Lhrdbfw_1561:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1541
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1565:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1564
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1564:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_1565
.Lhrdbfw_1541:
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
.Lhrdbfw_1588:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_1552
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_1547
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
	jmp	.Lhrdbfw_1541
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1567:
	movl	$1, %r12d
	jmp	.Lhrdbfw_1541
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1591:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_1566
.Lhrdbfw_1546:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_1541
.Lhrdbfw_1547:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1591
.Lhrdbfw_1566:
	movl	$47, %eax
	jmp	.Lhrdbfw_1546
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1589:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1550
	movl	%r9d, %eax
	jmp	.Lhrdbfw_1551
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1552:
	movl	$3, %r12d
	jmp	.Lhrdbfw_1541
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1590:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1541
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1555:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_1555
	jmp	.Lhrdbfw_1541
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
	jne	.Lhrdbfw_1592
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1592
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.Lhrdbfw_1632
	cmpl	$42, %ebx
	je	.Lhrdbfw_1632
	cmpl	$47, %ebx
	je	.Lhrdbfw_1607
	cmpl	$37, %ebx
	je	.Lhrdbfw_1634
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.Lhrdbfw_1634
.Lhrdbfw_1592:
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
.Lhrdbfw_1632:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1607
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1654
	testl	%eax, %eax
	je	.Lhrdbfw_1598
	cmpl	$9, %eax
	je	.Lhrdbfw_1598
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1607:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1592
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1592
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.Lhrdbfw_1655
	testl	%r13d, %r13d
	je	.Lhrdbfw_1656
	cmpl	$42, %ebx
	je	.Lhrdbfw_1657
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1633
	jne	.Lhrdbfw_1633
	movl	$5, %r8d
	jmp	.Lhrdbfw_1592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1654:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1607
.Lhrdbfw_1598:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1607
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.Lhrdbfw_1658
	testl	%eax, %eax
	je	.Lhrdbfw_1601
	cmpl	$9, %eax
	jne	.Lhrdbfw_1607
.Lhrdbfw_1601:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.Lhrdbfw_1659
	testl	%r13d, %r13d
	je	.Lhrdbfw_1660
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1634:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1592
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1592
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.Lhrdbfw_1616
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1617
	jne	.Lhrdbfw_1617
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.Lhrdbfw_1592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1658:
	testl	$65280, %edi
	je	.Lhrdbfw_1601
	jmp	.Lhrdbfw_1607
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1657:
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
.Lhrdbfw_1610:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1633:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1610
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1655:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.Lhrdbfw_1653:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.Lhrdbfw_1610
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1656:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1653
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1659:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1592
.Lhrdbfw_1616:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabs	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.Lhrdbfw_1661
	testq	%r10, %r10
	jne	.Lhrdbfw_1626
.Lhrdbfw_1621:
	movabs	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1619
	testq	%r9, %r9
	movl	$0, %edx
	movabs	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1619:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1592
.Lhrdbfw_1660:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.Lhrdbfw_1592
.Lhrdbfw_1617:
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
	jmp	.Lhrdbfw_1619
.Lhrdbfw_1661:
	testq	%r10, %r10
	je	.Lhrdbfw_1621
	movabs	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1622
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.Lhrdbfw_1629
	jne	.Lhrdbfw_1629
.Lhrdbfw_1622:
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
	ja	.Lhrdbfw_1619
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.Lhrdbfw_1619
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.Lhrdbfw_1619
.Lhrdbfw_1626:
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
	jmp	.Lhrdbfw_1619
.Lhrdbfw_1629:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.Lhrdbfw_1619
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
	je	.Lhrdbfw_1662
	ja	.Lhrdbfw_1664
	leaq	.Lhrdbfw_C69(%rip), %rax
	cmpl	$1, %ecx
	je	.Lhrdbfw_1662
	leaq	.Lhrdbfw_C72(%rip), %rax
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1675
.Lhrdbfw_1662:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1675:
	testl	%ecx, %ecx
	leaq	.Lhrdbfw_C70(%rip), %rdx
	leaq	.Lhrdbfw_C67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1664:
	leaq	.Lhrdbfw_C71(%rip), %rax
	cmpl	$4, %ecx
	je	.Lhrdbfw_1662
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
	ja	.Lhrdbfw_1679
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.Lhrdbfw_1679
	movabs	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.Lhrdbfw_1774
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.Lhrdbfw_1683:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.Lhrdbfw_1690
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1689:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1691:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_1691
	testq	%rax, %rax
	je	.Lhrdbfw_1692
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.Lhrdbfw_1692:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.Lhrdbfw_1689
	testb	%r12b, %r12b
	je	.Lhrdbfw_1690
	movl	%r9d, 544(%rsp)
.Lhrdbfw_1690:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.Lhrdbfw_1695
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shl
	movl	544(%rsp), %edi
.Lhrdbfw_1696:
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_1702
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1703:
	cmpq	$48, %r12
	je	.Lhrdbfw_1775
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbfw_1702:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.Lhrdbfw_1703
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1703
	testl	%r12d, %r12d
	jne	.Lhrdbfw_1776
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.Lhrdbfw_1708:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.Lhrdbfw_1711
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1777:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.Lhrdbfw_1711:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1777
	testl	%r13d, %r13d
	je	.Lhrdbfw_1712
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1714:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1713:
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
	jne	.Lhrdbfw_1713
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbfw_1778
	movq	%rax, %r12
	jmp	.Lhrdbfw_1714
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1679:
	xorl	%eax, %eax
.Lhrdbfw_1676:
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
.Lhrdbfw_1774:
	testq	%rax, %rax
	jne	.Lhrdbfw_1779
	cmpq	$0, 40(%rsp)
	jne	.Lhrdbfw_1780
	xorl	%edx, %edx
.Lhrdbfw_1684:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1685
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.Lhrdbfw_1679
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1687:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.Lhrdbfw_1687
	addl	%ebx, %eax
	jmp	.Lhrdbfw_1676
.Lhrdbfw_1780:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1679
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.Lhrdbfw_1684
.Lhrdbfw_1695:
	negl	%edx
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.Lhrdbfw_1781
	cmpl	$2, %eax
	jne	.Lhrdbfw_1696
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.Lhrdbfw_1696
	testl	%edi, %edi
	je	.Lhrdbfw_1729
.Lhrdbfw_1699:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.Lhrdbfw_1701
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1782:
	movl	(%rcx), %edx
.Lhrdbfw_1701:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.Lhrdbfw_1782
	testq	%rax, %rax
	je	.Lhrdbfw_1696
	movl	%edi, %eax
	addl	$1, %edi
.Lhrdbfw_1698:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.Lhrdbfw_1696
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1778:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.Lhrdbfw_1712:
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
	ja	.Lhrdbfw_1679
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.Lhrdbfw_1717
	movb	$45, (%rsi)
	movl	$1, %edx
.Lhrdbfw_1717:
	cmpl	%edi, %ebx
	jnb	.Lhrdbfw_1718
	testl	%eax, %eax
	je	.Lhrdbfw_1734
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1720:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1720
.Lhrdbfw_1719:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1676
.Lhrdbfw_1721:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.Lhrdbfw_1722
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1723:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_1723
	addl	%ebx, %edx
.Lhrdbfw_1722:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1724:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1724
	jmp	.Lhrdbfw_1676
.Lhrdbfw_1775:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.Lhrdbfw_1706:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1709:
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
	ja	.Lhrdbfw_1709
	jmp	.Lhrdbfw_1708
.Lhrdbfw_1779:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.Lhrdbfw_1683
.Lhrdbfw_1685:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.Lhrdbfw_1679
	movb	$48, (%rsi,%rdx)
	jmp	.Lhrdbfw_1676
.Lhrdbfw_1718:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbfw_1721
.Lhrdbfw_1781:
	testl	%edi, %edi
	je	.Lhrdbfw_1728
	movl	256(%rsp), %edx
	jmp	.Lhrdbfw_1699
.Lhrdbfw_1734:
	movl	%edx, %eax
	jmp	.Lhrdbfw_1719
.Lhrdbfw_1729:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.Lhrdbfw_1698
.Lhrdbfw_1728:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.Lhrdbfw_1698
.Lhrdbfw_1776:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.Lhrdbfw_1706
	.p2align 4
	.globl	hrdbf_fmt_harbour
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1784
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1784:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1785
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.Lhrdbfw_1787
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1788:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrdbfw_1788
	movzbl	12(%rdx), %eax
.Lhrdbfw_1787:
	cmpq	%rax, %r9
	jnb	.Lhrdbfw_1790
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1789:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1789
.Lhrdbfw_1790:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1785:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1799
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1799:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1801
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1801:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.Lhrdbfw_1822
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.Lhrdbfw_1825
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
	ja	.Lhrdbfw_1822
	cmpl	$9999, %r8d
	jbe	.Lhrdbfw_1822
	testl	%r11d, %r11d
	je	.Lhrdbfw_1822
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.Lhrdbfw_1806
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.Lhrdbfw_1808
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.Lhrdbfw_1808:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.Lhrdbfw_1802
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
.Lhrdbfw_1802:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1825:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1805:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1805
	xorl	%r10d, %r10d
.Lhrdbfw_1822:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1806:
	movl	$28, %edx
	testb	$3, %bl
	jne	.Lhrdbfw_1808
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.Lhrdbfw_1808
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.Lhrdbfw_1808
	.p2align 4
	.globl	hrdbf_write_logical
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1826
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1826:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.Lhrdbfw_1838
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbfw_1837
.Lhrdbfw_1838:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1836
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1835:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1835
.Lhrdbfw_1836:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1837:
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
	je	.Lhrdbfw_1849
	movq	$0, 32968(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1856
.Lhrdbfw_1849:
	xorl	%r12d, %r12d
.Lhrdbfw_1848:
	movq	32944(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1846
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1851
	movq	$0, 32944(%rbx)
	movq	$0, 32952(%rbx)
.Lhrdbfw_1846:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1856:
	movl	$7, %r12d
	jmp	.Lhrdbfw_1848
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1851:
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
	je	.Lhrdbfw_1858
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	32976(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_1859
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1861:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_1860
.Lhrdbfw_1859:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1861
.Lhrdbfw_1860:
	movb	$0, (%rdx)
.Lhrdbfw_1863:
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
.Lhrdbfw_1858:
	movq	32944(%r12), %rdx
	movq	32952(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_1863
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
	je	.Lhrdbfw_1874
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1884
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1874
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1888
	cmpb	$78, %al
	je	.Lhrdbfw_1889
	cmpb	$68, %al
	je	.Lhrdbfw_1883
	movzbl	60(%rsp), %eax
.Lhrdbfw_1873:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1888:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1890
.Lhrdbfw_1876:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1891
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1874:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1884:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1873
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1889:
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
.Lhrdbfw_1883:
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
.Lhrdbfw_1890:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1879
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1878:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1878
.Lhrdbfw_1879:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1876
.Lhrdbfw_1891:
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
	je	.Lhrdbfw_1914
	movq	$0, 32968(%r12)
	call CloseHandle
	movq	32944(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1898
	testq	%rcx, %rcx
	je	.Lhrdbfw_1894
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1894
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
.Lhrdbfw_1898:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1897
.Lhrdbfw_1896:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1912
.Lhrdbfw_1894:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1914:
	movq	32944(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1896
.Lhrdbfw_1897:
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
.Lhrdbfw_1912:
	movq	$0, 32944(%r12)
	movq	$0, 32952(%r12)
	jmp	.Lhrdbfw_1897
	.p2align 4
	.globl	hrdbf_file_write_record
hrdbf_file_write_record:
	movl	32960(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1919
	cmpq	$0, 32968(%rcx)
	je	.Lhrdbfw_1919
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1919
	testq	%rdx, %rdx
	je	.Lhrdbfw_1920
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.Lhrdbfw_1922
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1919:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1920:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1922:
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
	je	.Lhrdbfw_1923
	cmpq	$0, 32968(%rcx)
	je	.Lhrdbfw_1923
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1923
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1923:
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
	je	.Lhrdbfw_1930
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1935:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1948
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1934
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1932:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1948
.Lhrdbfw_1934:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1932
	jnb	.Lhrdbfw_1948
	leal	1(%r10), %r11d
.Lhrdbfw_1931:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1935
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1939
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1938:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1940
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1941
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1973:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1940
.Lhrdbfw_1941:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1973
.Lhrdbfw_1939:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1929
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1974
	movl	%r11d, %r9d
.Lhrdbfw_1929:
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
.Lhrdbfw_1948:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1931
.Lhrdbfw_1940:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1929
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1942
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1947:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1943
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1946
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1944:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1943
.Lhrdbfw_1946:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1944
	jb	.Lhrdbfw_1943
	movl	%r9d, %r10d
.Lhrdbfw_1945:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1947
.Lhrdbfw_1942:
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
.Lhrdbfw_1943:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1945
.Lhrdbfw_1974:
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
.Lhrdbfw_1930:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1929
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1938
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
	je	.Lhrdbfw_1979
	movq	%rdx, %r11
	testq	%rdx, %rdx
	je	.Lhrdbfw_1979
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_1979
	movzwl	28(%r8), %edi
	movw	%di, 80(%rsp)
	testw	%di, %di
	je	.Lhrdbfw_1979
	testq	%rsi, %rsi
	je	.Lhrdbfw_1979
	movq	%rcx, %rbx
	movl	16(%r9), %ecx
	movq	%rcx, %rax
	movq	%rcx, 112(%rsp)
	salq	$4, %rax
	cmpq	56(%rbp), %rax
	ja	.Lhrdbfw_1979
	movzwl	18(%rdx), %edx
	movw	%dx, 86(%rsp)
	testw	%dx, %dx
	je	.Lhrdbfw_1979
	movzwl	%dx, %r15d
	movzwl	%di, %r10d
	leaq	8(%r10), %rdi
	movq	%r15, %rax
	leaq	4(%r15,%r15), %r12
	movq	%r15, 104(%rsp)
	imulq	%rdi, %rax
	addq	%r12, %rax
	cmpq	$1024, %rax
	ja	.Lhrdbfw_1979
	movq	%r15, %rdx
	movzwl	30(%r8), %eax
	addq	$1, %rdx
	movq	%rdx, 96(%rsp)
	cmpq	%r15, %rcx
	ja	.Lhrdbfw_1980
	testq	%rcx, %rcx
	je	.Lhrdbfw_2025
.Lhrdbfw_1981:
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
.Lhrdbfw_1983:
	leal	1(%rax), %r8d
	addq	$1, %rax
	movq	%rcx, 8(%rdx)
	addq	$16, %rdx
	movl	%r8d, -16(%rdx)
	addq	%r13, %rcx
	cmpq	%rax, %r9
	ja	.Lhrdbfw_1983
	cmpq	$1, 112(%rsp)
	jbe	.Lhrdbfw_2002
	movq	%r12, 120(%rsp)
	movq	112(%rsp), %r14
	leaq	16(%rsi), %r15
	movl	$1, %r13d
	movq	%rdi, 128(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1990:
	movl	(%r15), %r12d
	movq	8(%r15), %rcx
	movq	%r15, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1985:
	movl	-16(%r8), %r9d
	movq	-8(%r8), %rdx
	movq	%r8, %rdi
	xorl	%eax, %eax
	movl	%r9d, 136(%rsp)
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1989:
	movzbl	(%rdx,%rax), %r9d
	cmpb	%r9b, (%rcx,%rax)
	jne	.Lhrdbfw_2026
	addq	$1, %rax
	cmpq	%rax, %r10
	ja	.Lhrdbfw_1989
	movl	136(%rsp), %r9d
	cmpl	%r12d, %r9d
	jbe	.Lhrdbfw_1986
.Lhrdbfw_1988:
	movdqu	-16(%r8), %xmm0
	subq	$16, %r8
	movups	%xmm0, 16(%r8)
	cmpq	%rsi, %r8
	jne	.Lhrdbfw_1985
	movq	%rsi, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1986:
	addq	$1, %r13
	movl	%r12d, (%rdi)
	addq	$16, %r15
	movq	%rcx, 8(%rdi)
	cmpq	%r13, %r14
	jne	.Lhrdbfw_1990
	movq	128(%rsp), %rdi
	movq	120(%rsp), %r12
.Lhrdbfw_2002:
	movq	112(%rsp), %rax
	movq	104(%rsp), %rcx
	xorl	%edx, %edx
	leaq	1(%rax,%rcx), %rax
	divq	96(%rsp)
	movq	%rax, 128(%rsp)
	cmpq	%rcx, %rax
	jbe	.Lhrdbfw_1982
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1979:
	xorl	%eax, %eax
.Lhrdbfw_1975:
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
.Lhrdbfw_1980:
	movq	104(%rsp), %rcx
	movq	%rcx, %rdx
	imulq	%rcx, %rdx
	cmpq	112(%rsp), %rdx
	jnb	.Lhrdbfw_1981
	jmp	.Lhrdbfw_1979
.Lhrdbfw_2025:
	movq	$1, 128(%rsp)
.Lhrdbfw_1982:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1991:
	movzbl	(%r11,%rax), %edx
	movb	%dl, (%rbx,%rax)
	addq	$1, %rax
	cmpq	$1024, %rax
	jne	.Lhrdbfw_1991
	movq	128(%rsp), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_1992
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
.Lhrdbfw_1995:
	movq	72(%rsp), %rsi
	cmpq	%rsi, 136(%rsp)
	je	.Lhrdbfw_2027
	movzbl	86(%rsp), %eax
	movq	104(%rsp), %r13
	movb	%al, (%r12)
	movzbl	84(%rsp), %eax
	movb	%al, 1(%r12)
.Lhrdbfw_1994:
	movq	120(%rsp), %rax
	xorl	%r14d, %r14d
	salq	$4, %rax
	addq	48(%rbp), %rax
	movq	%rax, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1997:
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
	jne	.Lhrdbfw_1997
.Lhrdbfw_1998:
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
	jne	.Lhrdbfw_1995
	movq	128(%rsp), %rax
	movq	16(%rbp), %rbx
	movq	%r15, %r12
	movq	48(%rbp), %rsi
	cmpq	$1, %rax
	je	.Lhrdbfw_1992
	leaq	1(%rax), %r13
	subl	$1, %eax
	movq	104(%rsp), %r14
	movl	$1, %r15d
	salq	$10, %r13
	leaq	(%rbx,%r13), %rcx
	movw	%ax, (%rcx)
	movq	%rcx, %rbx
	jmp	.Lhrdbfw_1999
.Lhrdbfw_2005:
	movq	%rax, %r15
.Lhrdbfw_1999:
	leaq	-1(%r15), %rdx
	cmpq	%r14, 112(%rsp)
	jbe	.Lhrdbfw_1979
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
	jne	.Lhrdbfw_2005
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
.Lhrdbfw_2000:
	addq	128(%rsp), %rax
	salq	$10, %rax
	jmp	.Lhrdbfw_1975
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2026:
	jb	.Lhrdbfw_1988
	jmp	.Lhrdbfw_1986
.Lhrdbfw_2027:
	movq	88(%rsp), %rsi
	cmpq	%rsi, 104(%rsp)
	jb	.Lhrdbfw_1979
	movl	%esi, %eax
	movb	%sil, (%r12)
	shrw	$8, %ax
	movb	%al, 1(%r12)
	testq	%rsi, %rsi
	jne	.Lhrdbfw_2004
	xorl	%r13d, %r13d
	jmp	.Lhrdbfw_1998
.Lhrdbfw_2004:
	movq	88(%rsp), %r13
	jmp	.Lhrdbfw_1994
.Lhrdbfw_1992:
	movl	$1024, 4(%rbx)
	movl	$1, %eax
	jmp	.Lhrdbfw_2000
	.p2align 4
	.globl	hrcdx_build
hrcdx_build:
	testq	%rcx, %rcx
	je	.Lhrdbfw_2117
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rdi
	movq	%rdx, %rdi
	pushq	%rsi
	pushq	%rbx
	andq	$-16, %rsp
	subq	$496, %rsp
	testq	%rdx, %rdx
	je	.Lhrdbfw_2033
	cmpb	$0, 40(%r9)
	movq	%r9, %r14
	je	.Lhrdbfw_2033
	movzwl	28(%r8), %r13d
	testw	%r13w, %r13w
	je	.Lhrdbfw_2033
	cmpq	$0, 48(%rbp)
	je	.Lhrdbfw_2033
	movl	16(%r9), %esi
	movq	%rsi, %rax
	movq	%rsi, %r12
	salq	$4, %rax
	cmpq	56(%rbp), %rax
	ja	.Lhrdbfw_2033
	movl	(%rdx), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_2033
	testl	$511, %eax
	jne	.Lhrdbfw_2033
	movq	%rcx, %rbx
	movq	8(%r9), %rcx
	leaq	-512(%rcx), %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2033
	leaq	(%rdi,%rax), %r15
	cmpw	$3, (%r15)
	jne	.Lhrdbfw_2033
	cmpw	$1, 2(%rdi,%rax)
	jne	.Lhrdbfw_2033
	movzwl	30(%r8), %eax
	leaq	208(%rsp), %r10
	movl	$10, %edx
	movq	%r15, %rcx
	movq	%r10, %r8
	movq	%r10, 168(%rsp)
	movw	%ax, 176(%rsp)
	movq	$512, 200(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_2033
	leaq	196(%rsp), %rax
	xorl	%r8d, %r8d
	movl	$10, %r9d
	movq	%r15, %rcx
	movq	%rax, 48(%rsp)
	leaq	200(%rsp), %rax
	movq	168(%rsp), %r10
	movq	%rax, 40(%rsp)
	leaq	240(%rsp), %rax
	movq	%rax, 32(%rsp)
	movq	%r10, %rdx
	call	hrdbfw_local_cxkey
	testl	%eax, %eax
	jne	.Lhrdbfw_2033
	movl	196(%rsp), %eax
	movl	%eax, 152(%rsp)
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_2033
	testl	$511, %eax
	jne	.Lhrdbfw_2033
	movl	%eax, %ecx
	movq	8(%r14), %rax
	movq	%rcx, 144(%rsp)
	subq	$512, %rax
	cmpq	%rax, %rcx
	ja	.Lhrdbfw_2033
	movl	$1, %eax
	testq	%rsi, %rsi
	movl	$1, %r8d
	cmove	%eax, %r12d
	movl	%eax, %ecx
	jmp	.Lhrdbfw_2036
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2038:
	addl	$1, %ecx
	cmpl	$32, %ecx
	je	.Lhrdbfw_2037
.Lhrdbfw_2036:
	movl	%r8d, %edx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %r12d
	ja	.Lhrdbfw_2038
.Lhrdbfw_2037:
	movzwl	%r13w, %r8d
	movl	$16, %edx
	movl	%ecx, %eax
	cmpl	$16, %ecx
	movl	%r8d, 88(%rsp)
	cmovb	%edx, %eax
	movl	$3, %r9d
	movl	$1, %edx
.Lhrdbfw_2074:
	movl	$1, %r11d
	jmp	.Lhrdbfw_2039
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2041:
	addl	$1, %r11d
	cmpl	$32, %r11d
	je	.Lhrdbfw_2040
.Lhrdbfw_2039:
	movl	%r11d, %ecx
	movl	%edx, %r15d
	sall	%cl, %r15d
	movl	%r15d, %ecx
	subl	$1, %ecx
	cmpl	%ecx, %r8d
	ja	.Lhrdbfw_2041
	leal	0(,%r9,4), %ecx
	subl	%r11d, %ecx
	addl	%ecx, %ecx
	cmpl	$32, %ecx
	ja	.Lhrdbfw_2040
	cmpl	%ecx, %eax
	ja	.Lhrdbfw_2040
	movl	%edx, %r10d
	sall	%cl, %r10d
	subl	$1, %r10d
	cmpl	16(%r14), %r10d
	jnb	.Lhrdbfw_2120
.Lhrdbfw_2040:
	cmpl	$6, %r9d
	je	.Lhrdbfw_2033
	addl	$1, %r9d
	jmp	.Lhrdbfw_2074
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2033:
	xorl	%eax, %eax
.Lhrdbfw_2028:
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
.Lhrdbfw_2117:
	xorl	%eax, %eax
	ret
.Lhrdbfw_2120:
	movzwl	%r13w, %r10d
	movl	%r9d, %eax
	movl	%ecx, 140(%rsp)
	leaq	8(%r10), %r15
	leaq	(%r10,%rax), %rcx
	movq	%rax, 112(%rsp)
	movl	%r9d, 136(%rsp)
	movq	%r15, 104(%rsp)
	cmpq	$488, %rcx
	ja	.Lhrdbfw_2033
	cmpq	$500, %r15
	ja	.Lhrdbfw_2033
	movl	$488, %eax
	xorl	%edx, %edx
	divq	%rcx
	movq	%rax, 168(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbfw_2076
	movq	%rax, %rcx
	xorl	%edx, %edx
	leaq	-1(%rsi,%rax), %rax
	divq	%rcx
	xorl	%edx, %edx
	movq	%rax, %r12
	movl	$500, %eax
	divq	%r15
	cmpq	%r12, %rax
	jb	.Lhrdbfw_2033
.Lhrdbfw_2042:
	movzwl	176(%rsp), %eax
	movq	48(%rbp), %r8
	xorl	%ecx, %ecx
	addq	$2, %rax
	salq	$4, %rax
	leaq	(%r14,%rax), %r9
	jmp	.Lhrdbfw_2043
.Lhrdbfw_2044:
	leal	1(%rcx), %eax
	movzwl	24(%r9), %edx
	addq	$16, %r8
	movl	%eax, -16(%r8)
	movzwl	32(%r14), %eax
	addq	%rdx, %rax
	movzwl	34(%r14), %edx
	imulq	%rcx, %rdx
	addq	$1, %rcx
	addq	%rdx, %rax
	addq	(%r14), %rax
	movq	%rax, -8(%r8)
.Lhrdbfw_2043:
	cmpq	%rsi, %rcx
	jb	.Lhrdbfw_2044
	movl	$16, %r15d
	movl	$1, %r14d
.Lhrdbfw_2045:
	cmpq	%rsi, %r14
	jnb	.Lhrdbfw_2121
	movq	48(%rbp), %rax
	movq	%r15, %r8
	movl	(%rax,%r15), %r9d
	movq	8(%rax,%r15), %rdx
.Lhrdbfw_2046:
	movq	48(%rbp), %rax
	movq	%r8, 176(%rsp)
	movl	-16(%rax,%r8), %eax
	movl	%eax, 160(%rsp)
	movq	48(%rbp), %rax
	movq	-8(%rax,%r8), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2050:
	movzbl	(%rcx,%rax), %r8d
	cmpb	%r8b, (%rdx,%rax)
	jne	.Lhrdbfw_2122
	addq	$1, %rax
	cmpq	%rax, %r10
	ja	.Lhrdbfw_2050
	xorl	%eax, %eax
	movq	176(%rsp), %r8
	cmpl	160(%rsp), %r9d
	setb	%al
.Lhrdbfw_2052:
	testl	%eax, %eax
	je	.Lhrdbfw_2047
	movq	48(%rbp), %rax
	movdqu	-16(%rax,%r8), %xmm0
	movups	%xmm0, 176(%rsp)
	movups	%xmm0, (%rax,%r8)
	subq	$16, %r8
	jne	.Lhrdbfw_2046
.Lhrdbfw_2047:
	addq	48(%rbp), %r8
	addq	$1, %r14
	addq	$16, %r15
	movl	%r9d, (%r8)
	movq	%rdx, 8(%r8)
	jmp	.Lhrdbfw_2045
.Lhrdbfw_2076:
	movl	$1, %r12d
	jmp	.Lhrdbfw_2042
.Lhrdbfw_2122:
	sbbl	%eax, %eax
	movq	176(%rsp), %r8
	shrl	$31, %eax
	jmp	.Lhrdbfw_2052
.Lhrdbfw_2121:
	movq	144(%rsp), %rcx
	xorl	%eax, %eax
	addq	$1024, %rcx
	movq	%rcx, 160(%rsp)
.Lhrdbfw_2054:
	movzbl	(%rdi,%rax), %edx
	movb	%dl, (%rbx,%rax)
	addq	$1, %rax
	cmpq	%rax, 160(%rsp)
	ja	.Lhrdbfw_2054
	movl	$1, %eax
	movq	%rsi, 120(%rsp)
	xorl	%r14d, %r14d
	xorl	%r15d, %r15d
	movzbl	140(%rsp), %ecx
	addl	136(%rsp), %r13d
	movq	%rbx, 16(%rbp)
	movw	%r13w, 86(%rsp)
	salq	%cl, %rax
	movl	%r11d, 176(%rsp)
	subl	$1, %eax
	movzbl	%ah, %ecx
	movl	%eax, %edx
	movb	%al, 102(%rsp)
	shrl	$24, %eax
	movl	%ecx, 96(%rsp)
	movl	%r11d, %ecx
	shrl	$16, %edx
	movq	112(%rsp), %r11
	movl	%eax, 92(%rsp)
	movl	$1, %eax
	sall	%cl, %eax
	movb	%dl, 101(%rsp)
	movq	%r14, %rdx
	subl	$1, %eax
	movb	%al, 103(%rsp)
	movl	152(%rsp), %eax
	addl	$1536, %eax
	movl	%eax, 156(%rsp)
	movq	160(%rsp), %rax
	leaq	(%rbx,%rax), %r8
	leaq	-1(%r12), %rax
	movq	%rax, 128(%rsp)
	movl	$512, %eax
	subq	%r10, %rax
	movq	%rax, 72(%rsp)
.Lhrdbfw_2055:
	cmpq	%r15, %r12
	je	.Lhrdbfw_2123
	cmpq	%r15, 128(%rsp)
	je	.Lhrdbfw_2078
	movq	168(%rsp), %rax
	leaq	(%rax,%rdx), %rsi
	movq	%rsi, %r14
.Lhrdbfw_2056:
	movq	%r14, %rcx
	movl	176(%rsp), %ebx
	movq	%r8, %rax
	leaq	512(%r8), %rdi
	subq	%rdx, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2057:
	movb	$0, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdi
	jne	.Lhrdbfw_2057
	movl	%ecx, %eax
	movl	%ebx, 176(%rsp)
	shrw	$8, %ax
	testq	%r15, %r15
	jne	.Lhrdbfw_2083
	cmpq	$1, %r12
	jne	.Lhrdbfw_2083
	movb	$3, (%r8)
	movb	$0, 1(%r8)
	movb	%cl, 2(%r8)
	movb	$-1, 4(%r8)
	movb	$-1, 5(%r8)
	movb	$-1, 6(%r8)
	movb	$-1, 7(%r8)
	movb	%al, 3(%r8)
	orl	$-1, %eax
.Lhrdbfw_2061:
	movl	%eax, %r9d
	movzbl	%ah, %ebx
	movb	%al, 8(%r8)
	shrl	$24, %eax
	shrl	$16, %r9d
	movb	%al, 11(%r8)
	movl	$488, %eax
	movb	%r9b, 10(%r8)
	movzwl	86(%rsp), %r9d
	movb	%bl, 9(%r8)
	imull	%ecx, %r9d
	subl	%r9d, %eax
	movb	%al, 12(%r8)
	shrw	$8, %ax
	movb	%al, 13(%r8)
	movzbl	102(%rsp), %eax
	movb	%al, 14(%r8)
	movzbl	96(%rsp), %eax
	movb	%al, 15(%r8)
	movzbl	101(%rsp), %eax
	movb	%al, 16(%r8)
	movzbl	92(%rsp), %eax
	movb	%al, 17(%r8)
	movzbl	103(%rsp), %eax
	movb	%al, 18(%r8)
	movb	%al, 19(%r8)
	movzbl	140(%rsp), %eax
	movb	%al, 20(%r8)
	movl	176(%rsp), %eax
	movb	%al, 21(%r8)
	movb	%al, 22(%r8)
	movzbl	136(%rsp), %eax
	movb	%al, 23(%r8)
	testq	%rcx, %rcx
	je	.Lhrdbfw_2066
	movq	72(%rsp), %rax
	salq	$4, %rdx
	movl	176(%rsp), %ebx
	addq	48(%rbp), %rdx
	leaq	(%rax,%r8), %r13
	movq	%r14, %rax
	movq	%rdx, %r9
	salq	$4, %rax
	addq	48(%rbp), %rax
	movq	%rax, %r14
.Lhrdbfw_2065:
	movq	%r9, 176(%rsp)
	movl	(%r9), %eax
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2063:
	leal	0(,%rdx,8), %ecx
	movq	%rax, %r9
	shrq	%cl, %r9
	movb	%r9b, 24(%r8,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %r11
	jne	.Lhrdbfw_2063
	movq	176(%rsp), %r9
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2064:
	movq	8(%r9), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	addq	$1, %rax
	cmpq	%rax, %r10
	jne	.Lhrdbfw_2064
	addq	$16, %r9
	subq	%r10, %r13
	addq	%rdx, %r8
	cmpq	%r9, %r14
	jne	.Lhrdbfw_2065
	movl	%ebx, 176(%rsp)
.Lhrdbfw_2066:
	addq	$1, %r15
	movq	%rsi, %rdx
	movq	%rdi, %r8
	addl	$512, 156(%rsp)
	jmp	.Lhrdbfw_2055
.Lhrdbfw_2083:
	movb	$2, (%r8)
	movb	$0, 1(%r8)
	movb	%cl, 2(%r8)
	movb	%al, 3(%r8)
	testq	%r15, %r15
	je	.Lhrdbfw_2079
	movl	156(%rsp), %eax
	subl	$1024, %eax
.Lhrdbfw_2060:
	movl	%eax, %r9d
	movzbl	%ah, %ebx
	movb	%al, 4(%r8)
	shrl	$24, %eax
	shrl	$16, %r9d
	movb	%al, 7(%r8)
	cmpq	%r15, 128(%rsp)
	movl	$-1, %eax
	movb	%bl, 5(%r8)
	cmovne	156(%rsp), %eax
	movb	%r9b, 6(%r8)
	jmp	.Lhrdbfw_2061
.Lhrdbfw_2078:
	movq	168(%rsp), %rax
	movq	120(%rsp), %r14
	leaq	(%rax,%rdx), %rsi
	jmp	.Lhrdbfw_2056
.Lhrdbfw_2123:
	movq	160(%rsp), %rcx
	movq	120(%rsp), %rsi
	movq	16(%rbp), %rbx
	movq	%rcx, %r13
	cmpq	$1, %r12
	jbe	.Lhrdbfw_2068
	movq	%r12, %rax
	salq	$9, %rax
	movq	%rax, %r13
	addq	%rcx, %r13
	leaq	(%rbx,%r13), %rdx
	leaq	512(%rdx), %rcx
	movq	%rdx, %rax
.Lhrdbfw_2069:
	movb	$0, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_2069
	movl	152(%rsp), %eax
	movb	%r12b, 2(%rdx)
	addq	%rdx, %r10
	xorl	%edi, %edi
	movw	$1, (%rdx)
	xorl	%r14d, %r14d
	leaq	-1(%r12), %r11
	movq	%rdx, %r9
	movq	$-256, 3(%rdx)
	movq	168(%rsp), %r15
	addl	$1024, %eax
	movb	$-1, 11(%rdx)
.Lhrdbfw_2072:
	cmpq	%rdi, %r11
	movq	%r15, %rcx
	movq	48(%rbp), %rdx
	movl	%eax, 176(%rsp)
	cmove	%rsi, %rcx
	salq	$4, %rcx
	leaq	-16(%rdx,%rcx), %r8
	movq	%r9, %rdx
	xorl	%ecx, %ecx
	addq	%r14, %r9
.Lhrdbfw_2071:
	movq	8(%r8), %rax
	movzbl	(%rax,%rcx), %eax
	movb	%al, 12(%r9,%rcx)
	addq	$1, %rcx
	cmpl	%ecx, 88(%rsp)
	ja	.Lhrdbfw_2071
	movl	(%r8), %ecx
	movl	176(%rsp), %eax
	movq	%rdx, %r9
	addq	$1, %rdi
	addq	168(%rsp), %r15
	movl	%ecx, %r8d
	movb	%cl, 15(%r10)
	movzbl	%ch, %edx
	shrl	$24, %r8d
	movb	%al, 19(%r10)
	movb	%r8b, 12(%r10)
	movl	%ecx, %r8d
	movl	%eax, %ecx
	shrl	$24, %ecx
	shrl	$16, %r8d
	movb	%dl, 14(%r10)
	movb	%cl, 16(%r10)
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%r8b, 13(%r10)
	movb	%cl, 17(%r10)
	movzbl	%ah, %ecx
	addl	$512, %eax
	movb	%cl, 18(%r10)
	movq	104(%rsp), %rcx
	addq	%rcx, %r10
	addq	%rcx, %r14
	cmpq	%rdi, %r12
	jne	.Lhrdbfw_2072
.Lhrdbfw_2068:
	movq	144(%rsp), %rax
	movl	%r13d, (%rbx,%rax)
	xorl	%eax, %eax
	cmpq	$1, %r12
	seta	%al
	addq	%r12, %rax
	salq	$9, %rax
	addq	160(%rsp), %rax
	jmp	.Lhrdbfw_2028
.Lhrdbfw_2079:
	orl	$-1, %eax
	jmp	.Lhrdbfw_2060
	.p2align 4
hrntx_file_rebuild.constprop.0:
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
	subq	$384, %rsp
	movq	hrdbf_app_order(%rip), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2145
	movl	hrdbf_app_state+16(%rip), %ecx
	movl	hrdbf_app_order+76(%rip), %r8d
	movq	%rcx, %rbx
	leaq	0(,%rcx,8), %rsi
	salq	$4, %rbx
	testl	%r8d, %r8d
	je	.Lhrdbfw_2126
	movq	hrdbf_app_order+48(%rip), %rax
	movq	hrdbf_app_order+32(%rip), %rdx
	movq	$512, 88(%rsp)
	cmpq	$2047, %rax
	jbe	.Lhrdbfw_2172
	testl	$511, %eax
	jne	.Lhrdbfw_2172
	movl	(%rdx), %ecx
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_2172
	testl	$511, %ecx
	jne	.Lhrdbfw_2172
	subq	$512, %rax
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_2175
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2172:
	movl	$1, %r12d
.Lhrdbfw_2124:
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
.Lhrdbfw_2126:
	movzwl	18(%rdx), %edx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2135
	movl	$4, %r12d
	testw	%dx, %dx
	je	.Lhrdbfw_2124
	movl	$1, %r12d
	movl	$2048, %edx
.Lhrdbfw_2136:
	leaq	7(%rcx), %rdi
	leaq VirtualAlloc(%rip), %r14
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	shrq	$3, %rdi
	call	*%r14
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_2171
	leaq	(%rbx,%rdi), %r15
	movl	$4, %r9d
	movl	$12288, %r8d
	xorl	%ecx, %ecx
	addq	%r12, %r15
	movq	%r15, %rdx
	call	*%r14
	movq	%rax, %r14
	testq	%rax, %rax
	je	.Lhrdbfw_2176
	movq	%rbx, 40(%rsp)
	movq	hrdbf_app_order(%rip), %rdx
	movq	%r13, %rcx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rax, 32(%rsp)
	leaq	hrdbf_app_order(%rip), %r8
	call	hrntx_build
	movq	%rax, %rbx
	testq	%rax, %rax
	je	.Lhrdbfw_2174
	movl	hrdbf_app_state+16(%rip), %eax
	addq	%r12, %rdi
	addq	%r14, %rsi
	movq	%rbx, %r8
	movq	%rdi, 56(%rsp)
	leaq	128(%rsp), %rcx
	movq	%r13, %rdx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rsi, 48(%rsp)
	movq	%rax, 40(%rsp)
	movq	%r14, 32(%rsp)
	movq	$0, 128(%rsp)
	movq	$0, 136(%rsp)
	movq	$0, 144(%rsp)
	movq	$0, 152(%rsp)
	call	hrntx_open
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_2174
	movq	hrdbf_app_order+64(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2142
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
.Lhrdbfw_2142:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2143
	movl	$32768, %r8d
	xorl	%edx, %edx
	call VirtualFree
.Lhrdbfw_2143:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2144
	movl	$32768, %r8d
	xorl	%edx, %edx
	call VirtualFree
.Lhrdbfw_2144:
	movdqu	128(%rsp), %xmm0
	movq	%r13, hrdbf_app_order+32(%rip)
	movdqu	144(%rsp), %xmm1
	movq	%rbx, hrdbf_app_order+48(%rip)
	movq	%r14, hrdbf_app_order+40(%rip)
	movq	%r15, hrdbf_app_order+56(%rip)
	movl	$1, hrdbf_app_order+72(%rip)
	movups	%xmm0, hrdbf_app_order(%rip)
	movups	%xmm1, hrdbf_app_order+16(%rip)
	jmp	.Lhrdbfw_2124
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2135:
	movzwl	%dx, %r8d
	leal	-1(%rcx,%rdx), %eax
	xorl	%edx, %edx
	movl	$4, %r12d
	divq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_2124
	cmpq	$1, %rax
	jbe	.Lhrdbfw_2137
	leaq	2(%rax), %rdx
	leaq	9(%rax), %r12
	salq	$10, %rdx
	shrq	$3, %r12
	jmp	.Lhrdbfw_2136
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2174:
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*%rbx
	movl	$1, %r12d
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r14, %rcx
	call	*%rbx
	jmp	.Lhrdbfw_2124
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2145:
	movl	$6, %r12d
	jmp	.Lhrdbfw_2124
.Lhrdbfw_2177:
	movq	%r14, %rcx
	call	hrdbfw_release.isra.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2171:
	movl	$8, %r12d
	jmp	.Lhrdbfw_2124
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2175:
	leaq	(%rdx,%rcx), %r13
	leaq	96(%rsp), %r14
	movl	$10, %edx
	movq	%r14, %r8
	movq	%r13, %rcx
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_2172
	leaq	84(%rsp), %rax
	xorl	%r8d, %r8d
	movq	%r14, %rdx
	movq	%r13, %rcx
	movq	%rax, 48(%rsp)
	leaq	128(%rsp), %r12
	leaq	88(%rsp), %rax
	movl	$10, %r9d
	movq	%rax, 40(%rsp)
	movq	%r12, 32(%rsp)
	call	hrdbfw_local_cxkey
	testl	%eax, %eax
	jne	.Lhrdbfw_2172
	movl	84(%rsp), %ecx
	movq	%rcx, %rax
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_2172
	testl	$511, %eax
	jne	.Lhrdbfw_2172
	movq	hrdbf_app_order+48(%rip), %rax
	subq	$1024, %rax
	cmpq	%rax, %rcx
	ja	.Lhrdbfw_2172
	movzwl	hrdbf_app_order+28(%rip), %r8d
	movl	$500, %eax
	xorl	%edx, %edx
	leaq VirtualAlloc(%rip), %r13
	movl	$4, %r9d
	addq	$8, %r8
	divq	%r8
	movl	$12288, %r8d
	addq	$2, %rax
	salq	$9, %rax
	leaq	1024(%rcx,%rax), %rdx
	movl	hrdbf_app_state+16(%rip), %eax
	xorl	%ecx, %ecx
	movq	%rdx, %rdi
	addq	$7, %rax
	shrq	$9, %rdi
	shrq	$3, %rax
	addq	$7, %rdi
	movq	%rax, 72(%rsp)
	shrq	$3, %rdi
	call	*%r13
	movq	%rax, %r14
	testq	%rax, %rax
	je	.Lhrdbfw_2171
	movq	72(%rsp), %rax
	movl	$4, %r9d
	movl	$12288, %r8d
	xorl	%ecx, %ecx
	leaq	(%rbx,%rax), %r15
	addq	%rdi, %r15
	movq	%r15, %rdx
	call	*%r13
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_2177
	movq	%rbx, 40(%rsp)
	movq	hrdbf_app_order+32(%rip), %rdx
	movq	%r14, %rcx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rax, 32(%rsp)
	leaq	hrdbf_app_order(%rip), %r8
	call	hrcdx_build
	movq	%rax, %rbx
	testq	%rax, %rax
	je	.Lhrdbfw_2173
	movl	hrdbf_app_state+16(%rip), %eax
	addq	%r13, %rsi
	movq	%r12, %rcx
	movq	%rbx, %r8
	addq	72(%rsp), %rdi
	movq	%rsi, 48(%rsp)
	movq	%r14, %rdx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rdi, 56(%rsp)
	movq	%rax, 40(%rsp)
	movq	%r13, 32(%rsp)
	movq	$0, 128(%rsp)
	movq	$0, 136(%rsp)
	movq	$0, 144(%rsp)
	movq	$0, 152(%rsp)
	call	hrcdx_open
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_2173
	movq	hrdbf_app_order+64(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2132
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
.Lhrdbfw_2132:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2133
	call	hrdbfw_release.isra.0
.Lhrdbfw_2133:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2134
	call	hrdbfw_release.isra.0
.Lhrdbfw_2134:
	movdqu	128(%rsp), %xmm2
	movq	%r14, hrdbf_app_order+32(%rip)
	movdqu	144(%rsp), %xmm3
	movq	%rbx, hrdbf_app_order+48(%rip)
	movq	%r13, hrdbf_app_order+40(%rip)
	movq	%r15, hrdbf_app_order+56(%rip)
	movl	$1, hrdbf_app_order+72(%rip)
	movups	%xmm2, hrdbf_app_order(%rip)
	movups	%xmm3, hrdbf_app_order+16(%rip)
	jmp	.Lhrdbfw_2124
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2176:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	movl	$8, %r12d
	call VirtualFree
	jmp	.Lhrdbfw_2124
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2137:
	leaq	1(%rax), %rdx
	movl	$1, %r12d
	salq	$10, %rdx
	jmp	.Lhrdbfw_2136
.Lhrdbfw_2173:
	movq	%r14, %rcx
	call	hrdbfw_release.isra.0
	movq	%r13, %rcx
	call	hrdbfw_release.isra.0
	jmp	.Lhrdbfw_2172
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C77:

.byte 104,98,99,58,32,68,66,70,32,78,84,88,32,105,110,100,101,120,32,114,101,98,117,105,108,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
hrdbf_app_rebuild_index:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2188
	subq	$40, %rsp
	call	hrntx_file_rebuild.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2191
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r8
	movq	%rcx, hrdbf_app_pos(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_2185
	movq	hrdbf_app_order+16(%rip), %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2184
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2182:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2185
.Lhrdbfw_2184:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_2182
	cmpq	%rax, %rcx
	movq	%rax, hrdbf_app_pos(%rip)
	setbe	%al
	jbe	.Lhrdbfw_2181
.Lhrdbfw_2183:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2185:
	movl	$1, %eax
.Lhrdbfw_2181:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
	jmp	.Lhrdbfw_2183
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2188:
	ret
.Lhrdbfw_2191:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
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
	je	.Lhrdbfw_2193
	cmpq	$0, hrdbf_app_order+32(%rip)
	je	.Lhrdbfw_2193
	cmpq	$0, hrdbf_app_order+48(%rip)
	jne	.Lhrdbfw_2199
.Lhrdbfw_2193:
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
	jne	.Lhrdbfw_2200
	addq	$32, %rsp
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2199:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2193
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2200:
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
	je	.Lhrdbfw_2202
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_2272
.Lhrdbfw_2202:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_2273
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_2203
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2238:
	movq	%rsi, %rbx
.Lhrdbfw_2203:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2274
	leaq	1(%rbx), %rsi
	movb	%al, 64(%rsp,%rbx)
	leaq	64(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_2238
	movb	$0, 64(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2275
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
	ja	.Lhrdbfw_2276
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2209
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2207:
	cmpq	%r8, %rbx
	je	.Lhrdbfw_2277
.Lhrdbfw_2209:
	movzbl	(%rdi,%rdx), %ecx
	movq	%rdx, %r8
	addq	$1, %rdx
	cmpb	$47, %cl
	je	.Lhrdbfw_2249
	cmpb	$92, %cl
	jne	.Lhrdbfw_2207
.Lhrdbfw_2249:
	movq	%rdx, %rax
	cmpq	%r8, %rbx
	jne	.Lhrdbfw_2209
.Lhrdbfw_2277:
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_2212
	jmp	.Lhrdbfw_2278
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2239:
	movq	%rdx, %rax
.Lhrdbfw_2212:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_2239
	movq	%rsi, hrdbf_app_baselen(%rip)
	testq	%rsi, %rsi
	je	.Lhrdbfw_2213
.Lhrdbfw_2236:
	xorl	%edx, %edx
	leaq	hrdbf_app_basename(%rip), %r9
	jmp	.Lhrdbfw_2215
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2279:
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jbe	.Lhrdbfw_2213
.Lhrdbfw_2215:
	movzbl	(%rdi,%rdx), %eax
	cmpb	$92, %al
	jne	.Lhrdbfw_2279
	movl	$47, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	ja	.Lhrdbfw_2215
.Lhrdbfw_2213:
	leaq	hrdbf_app_state(%rip), %rcx
	movb	$0, hrdbf_app_state+32976(%rip)
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_2280
.Lhrdbfw_2216:
	leaq	hrdbf_app_state+32976(%rip), %r12
	cmpb	$0, hrdbf_app_state+32976(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C84(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C80(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C85(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C81(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_2219
	leaq	.Lhrdbfw_C82(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_2219
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C83(%rip), %r12
	leaq	.Lhrdbfw_C86(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_2219:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2280:
	movl	%ebp, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2216
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2201
	leaq	4(%rsi), %rax
	cmpq	$259, %rax
	jbe	.Lhrdbfw_2281
.Lhrdbfw_2201:
	addq	$872, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_2281:
	movb	$46, 64(%rsp,%rsi)
	movzbl	64(%rsp), %eax
	movb	$99, 65(%rsp,%rsi)
	movb	$100, 66(%rsp,%rsi)
	movb	$120, 67(%rsp,%rsi)
	movb	$0, 68(%rsp,%rsi)
	testb	%al, %al
	je	.Lhrdbfw_2224
	cmpb	$92, %al
	je	.Lhrdbfw_2282
	cmpb	$47, %al
	je	.Lhrdbfw_2228
.Lhrdbfw_2227:
	leaq	336(%rsp), %r13
	movq	%r12, %rcx
	movq	%r13, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_2224
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
	je	.Lhrdbfw_2283
	call CloseHandle
.Lhrdbfw_2224:
	cmpq	$1, %rbp
	je	.Lhrdbfw_2284
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2233
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2201
.Lhrdbfw_2278:
	movq	%rsi, hrdbf_app_baselen(%rip)
	jmp	.Lhrdbfw_2236
.Lhrdbfw_2283:
	call GetLastError
	subl	$2, %eax
	cmpl	$1, %eax
	jbe	.Lhrdbfw_2201
	jmp	.Lhrdbfw_2224
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2228:
	cmpb	$47, 65(%rsp)
	jne	.Lhrdbfw_2227
	jmp	.Lhrdbfw_2224
.Lhrdbfw_2233:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2234
	movl	$1, %edx
	movq	%r12, %rcx
	call	hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_2234
.Lhrdbfw_2235:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2201
.Lhrdbfw_2282:
	cmpb	$92, 65(%rsp)
	jne	.Lhrdbfw_2227
	jmp	.Lhrdbfw_2224
.Lhrdbfw_2284:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_2201
.Lhrdbfw_2234:
	movl	$3, %eax
	jmp	.Lhrdbfw_2235
.Lhrdbfw_2274:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2276:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2275:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2273:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2272:
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
	je	.Lhrdbfw_2295
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2287
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2288
.Lhrdbfw_2287:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2288:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2290
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.Lhrdbfw_2291:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2290:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.Lhrdbfw_2291
.Lhrdbfw_2295:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2307
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2298
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2298
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_2308
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_2302:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_2303:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2308:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_2302
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_2303
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2298:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_2307:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2327
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2311
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2311
	testq	%rcx, %rcx
	je	.Lhrdbfw_2309
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.Lhrdbfw_2314
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.Lhrdbfw_2320
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.Lhrdbfw_2315:
	movq	%rdx, hrdbf_app_pos(%rip)
.Lhrdbfw_2316:
	cmpq	%rax, %rdx
	jnb	.Lhrdbfw_2318
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.Lhrdbfw_2319:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
.Lhrdbfw_2309:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2311:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2320:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.Lhrdbfw_2315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2318:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_2319
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2314:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.Lhrdbfw_2317
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.Lhrdbfw_2316
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2317:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.Lhrdbfw_2316
.Lhrdbfw_2327:
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
	je	.Lhrdbfw_2386
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_2387
	movq	%rcx, %r8
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2330
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2332:
	cmpq	%rbx, %r9
	je	.Lhrdbfw_2388
.Lhrdbfw_2358:
	movq	%rbx, %rdx
.Lhrdbfw_2330:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2389
	movb	%al, 32(%rsp,%rdx)
	leaq	32(%rsp), %rsi
	leaq	1(%rdx), %rbx
	cmpb	$47, %al
	je	.Lhrdbfw_2364
	cmpb	$92, %al
	jne	.Lhrdbfw_2332
.Lhrdbfw_2364:
	movq	%rbx, %rcx
	cmpq	%rbx, %r9
	jne	.Lhrdbfw_2358
.Lhrdbfw_2388:
	movq	%rbx, %rax
	xorl	%r9d, %r9d
	cmpq	%rbx, %rcx
	jnb	.Lhrdbfw_2334
	movl	$1, %r11d
	jmp	.Lhrdbfw_2336
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2360:
	movq	%r10, %rcx
.Lhrdbfw_2336:
	cmpb	$46, (%r8,%rcx)
	leaq	1(%rcx), %r10
	cmove	%rcx, %rax
	cmove	%r11d, %r9d
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_2360
.Lhrdbfw_2334:
	movl	hrdbf_app_cdx(%rip), %r12d
	testl	%r12d, %r12d
	jne	.Lhrdbfw_2390
.Lhrdbfw_2337:
	movl	hrdbf_app_shared(%rip), %ecx
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2391
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2392
	testl	%r9d, %r9d
	je	.Lhrdbfw_2393
	movb	$0, 32(%rsp,%rbx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2348
.Lhrdbfw_2396:
	movl	%r12d, %edx
	movq	%rsi, %rcx
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2348
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2352
	xorl	%eax, %eax
	leaq	hrdbf_app_ntxpath(%rip), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2353:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, (%rcx,%rax)
	movq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_2353
	jmp	.Lhrdbfw_2354
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2390:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.Lhrdbfw_2337
	testq	%rax, %rax
	je	.Lhrdbfw_2338
	movl	$1, %r11d
	xorl	%r10d, %r10d
	leaq	hrdbf_app_basename(%rip), %r14
	xorl	%r13d, %r13d
	jmp	.Lhrdbfw_2341
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2395:
	leal	-97(%rcx), %ebp
	leal	-32(%rcx), %edi
	cmpb	$26, %bpl
	cmovb	%edi, %ecx
.Lhrdbfw_2339:
	cmpb	%cl, (%r14,%r10)
	cmovne	%r13d, %r11d
	addq	$1, %r10
	cmpq	%rax, %r10
	je	.Lhrdbfw_2394
.Lhrdbfw_2341:
	movzbl	(%r8,%r10), %ecx
	cmpb	$92, %cl
	jne	.Lhrdbfw_2395
	movl	$47, %ecx
	jmp	.Lhrdbfw_2339
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2352:
	movb	$0, hrdbf_app_ntxpath(%rip)
.Lhrdbfw_2354:
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
.Lhrdbfw_2393:
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
	je	.Lhrdbfw_2396
.Lhrdbfw_2348:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_2365
	leaq	.Lhrdbfw_C94(%rip), %rcx
	cmpl	$3, %eax
	je	.Lhrdbfw_2350
.Lhrdbfw_2365:
	leaq	.Lhrdbfw_C95(%rip), %rcx
.Lhrdbfw_2350:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2394:
	testl	%r11d, %r11d
	je	.Lhrdbfw_2337
.Lhrdbfw_2338:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.Lhrdbfw_2354
	cmpl	$2, %eax
	je	.Lhrdbfw_2397
	cmpl	$3, %eax
	je	.Lhrdbfw_2398
	cmpl	$4, %eax
	jne	.Lhrdbfw_2337
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2389:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2398:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2397:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2387:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2386:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2392:
	leaq	.Lhrdbfw_C102(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2391:
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2407
	movl	hrdbf_app_order+72(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2401
	cmpq	$0, hrdbf_app_order+32(%rip)
	je	.Lhrdbfw_2401
	cmpq	$0, hrdbf_app_order+48(%rip)
	jne	.Lhrdbfw_2408
.Lhrdbfw_2401:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2409
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2408:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2401
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2407:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2409:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2415
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_2415:
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
	je	.Lhrdbfw_2423
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2418
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2418
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
	jb	.Lhrdbfw_2424
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_2421:
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
.Lhrdbfw_2424:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_2421
.Lhrdbfw_2418:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2423:
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
	je	.Lhrdbfw_2463
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2427
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2427
	movq	%rcx, %rax
	movq	%rdx, %rcx
	movq	%r8, %rbx
	movzbl	%al, %edx
	leal	-2(%rdx), %r8d
	andl	$-3, %r8d
	je	.Lhrdbfw_2464
	testl	%edx, %edx
	je	.Lhrdbfw_2442
	cmpl	$9, %edx
	je	.Lhrdbfw_2442
	cmpl	$5, %edx
	je	.Lhrdbfw_2465
	cmpl	$12, %edx
	je	.Lhrdbfw_2466
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
.Lhrdbfw_2464:
	testq	%rcx, %rcx
	je	.Lhrdbfw_2467
	movq	-8(%rcx), %rdx
	addq	$344, %rsp
	movq	%rbx, %r8
	popq	%rbx
	popq	%r12
	jmp	hrdbfw_app_seek
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2466:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rcx, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.Lhrdbfw_2440
	movsd	.Lhrdbfw_C0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2441:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.Lhrdbfw_2441
.Lhrdbfw_2440:
	comisd	.Lhrdbfw_C105(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2442
.Lhrdbfw_2462:
	movsd	.Lhrdbfw_C106(%rip), %xmm1
	addq	$1, %rcx
	comisd	%xmm0, %xmm1
	jbe	.Lhrdbfw_2468
.Lhrdbfw_2442:
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
.Lhrdbfw_2465:
	testq	%rax, %rax
	js	.Lhrdbfw_2469
.Lhrdbfw_2435:
	movq	%rcx, %xmm0
	comisd	.Lhrdbfw_C105(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2442
	jmp	.Lhrdbfw_2462
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2468:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.Lhrdbfw_2470
	addsd	.Lhrdbfw_C107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2442
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2469:
	movq	(%rcx), %rcx
	jmp	.Lhrdbfw_2435
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2470:
	subsd	.Lhrdbfw_C107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2442
.Lhrdbfw_2427:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2463:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2467:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2476
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_2476:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2482
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_2482:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
hrdbfw_app_fcount:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2488
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.Lhrdbfw_2488:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
hrdbfw_app_goto:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2503
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %eax
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2491
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_2492
.Lhrdbfw_2491:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, hrdbf_app_state+24(%rip)
	movw	%cx, hrdbf_app_state+38(%rip)
.Lhrdbfw_2493:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2489
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2504
.Lhrdbfw_2489:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2492:
	xorl	%edx, %edx
	movq	%rcx, hrdbf_app_state+24(%rip)
	movw	%dx, hrdbf_app_state+38(%rip)
	jmp	.Lhrdbfw_2493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2504:
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r8
	testl	%ecx, %ecx
	je	.Lhrdbfw_2498
	movq	hrdbf_app_order+16(%rip), %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2497
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2496:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2495
.Lhrdbfw_2497:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_2496
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2498:
	xorl	%ecx, %ecx
.Lhrdbfw_2495:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2503:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
hrdbfw_app_ordselect:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2521
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2507
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2522
	cmpq	$1, %rcx
	jne	.Lhrdbfw_2507
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r9
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %r8
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2513
	jmp	.Lhrdbfw_2523
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2512:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2515
.Lhrdbfw_2513:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.Lhrdbfw_2512
	movq	%rax, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2522:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.Lhrdbfw_2524
	cmpl	$3, %eax
	je	.Lhrdbfw_2525
	cmpl	$4, %eax
	je	.Lhrdbfw_2526
.Lhrdbfw_2507:
	movl	$0, hrdbf_app_order_active(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2523:
	xorl	%ecx, %ecx
.Lhrdbfw_2515:
	movq	%rcx, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2521:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2524:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2526:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2525:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2532
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_2532:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2538
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_2538:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2546
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2539
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_2539:
	movq	%r8, %rax
	ret
.Lhrdbfw_2546:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2553
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_2549
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_2550
.Lhrdbfw_2549:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2550:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_2553:
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
	je	.Lhrdbfw_2555
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_2557
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2569:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2558:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2559
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2558
.Lhrdbfw_2559:
	cmpq	%r8, %rax
	je	.Lhrdbfw_2579
.Lhrdbfw_2561:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.Lhrdbfw_2569
.Lhrdbfw_2557:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2579:
	testq	%r8, %r8
	je	.Lhrdbfw_2562
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2566
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2580:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.Lhrdbfw_2562
.Lhrdbfw_2566:
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
	je	.Lhrdbfw_2580
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_2561
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2562:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_2567
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
.Lhrdbfw_2567:
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
.Lhrdbfw_2555:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C108:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C109:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbfw_C110:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbfw_C111:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbfw_C112:

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
	je	.Lhrdbfw_2646
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2647
	movq	%rcx, %rbx
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2584
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rcx, %rax
	jl	.Lhrdbfw_2584
	movq	hrdbf_app_state+24(%rip), %r11
	movq	%rdx, %r9
	leaq	1(%rcx), %rax
	leaq	-1(%rcx), %rsi
	movzwl	hrdbf_app_state+34(%rip), %edx
	salq	$4, %rax
	leaq	hrdbf_app_state(%rip), %r10
	movzbl	%r9b, %edi
	leaq	-1(%r11), %rcx
	leaq	10(%r10,%rax), %r12
	imulq	%rdx, %rcx
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	%rdx, %rcx
	leaq	(%r10,%rax), %rdx
	addq	hrdbf_app_state+32944(%rip), %rcx
	movzbl	21(%rdx), %eax
	cmpb	$76, %al
	je	.Lhrdbfw_2586
	ja	.Lhrdbfw_2587
	cmpb	$67, %al
	je	.Lhrdbfw_2588
	cmpb	$68, %al
	jne	.Lhrdbfw_2590
	cmpl	$11, %edi
	je	.Lhrdbfw_2648
	cmpl	$1, %edi
	jne	.Lhrdbfw_2590
	addq	$2, %rsi
	salq	$4, %rsi
	addq	%rsi, %r10
	movzbl	22(%r10), %edx
	movzwl	24(%r10), %eax
	testl	%edx, %edx
	je	.Lhrdbfw_2599
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2610
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2649:
	addq	$1, %rax
.Lhrdbfw_2610:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2649
.Lhrdbfw_2595:
	movq	hrdbf_app_state+24(%rip), %r11
.Lhrdbfw_2599:
	movq	%r11, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbfw_2650
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2581
	movzwl	hrdbf_app_order+30(%rip), %eax
	addq	$1, %rax
	cmpq	%rbx, %rax
	je	.Lhrdbfw_2651
.Lhrdbfw_2581:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2587:
	cmpb	$78, %al
	jne	.Lhrdbfw_2590
	cmpl	$12, %edi
	je	.Lhrdbfw_2652
	testl	%edi, %edi
	je	.Lhrdbfw_2619
	cmpl	$9, %edi
	je	.Lhrdbfw_2619
	cmpl	$5, %edi
	je	.Lhrdbfw_2653
	cmpl	$1, %edi
	jne	.Lhrdbfw_2590
	addq	$2, %rsi
	salq	$4, %rsi
	addq	%rsi, %r10
	movzbl	22(%r10), %edx
	movzwl	24(%r10), %eax
	testl	%edx, %edx
	je	.Lhrdbfw_2599
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2608
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2654:
	addq	$1, %rax
.Lhrdbfw_2608:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2654
	jmp	.Lhrdbfw_2595
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2588:
	leal	-2(%rdi), %eax
	andl	$-3, %eax
	je	.Lhrdbfw_2655
	cmpl	$1, %edi
	jne	.Lhrdbfw_2590
	movzwl	24(%rdx), %eax
	movzbl	22(%rdx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2599
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2600
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2656:
	addq	$1, %rax
.Lhrdbfw_2600:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2656
	jmp	.Lhrdbfw_2595
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2586:
	cmpl	$3, %edi
	je	.Lhrdbfw_2657
	cmpl	$1, %edi
	jne	.Lhrdbfw_2590
	movzwl	24(%rdx), %eax
	movzbl	22(%rdx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_2599
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2613
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2658:
	addq	$1, %rax
.Lhrdbfw_2613:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2658
	jmp	.Lhrdbfw_2595
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2652:
	movl	%r9d, %eax
	movq	%r12, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.Lhrdbfw_2602:
	cmpl	$3, %eax
	je	.Lhrdbfw_2590
	testl	%eax, %eax
	je	.Lhrdbfw_2595
	leaq	.Lhrdbfw_C111(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2657:
	cmpq	$1, %r8
	movzwl	24(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	hrdbf_app_state+24(%rip), %r11
	jmp	.Lhrdbfw_2599
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2655:
	movzwl	24(%rdx), %eax
	movzbl	22(%rdx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%r8)
	movq	%rdx, %rax
	cmovbe	-8(%r8), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2593
	movq	%rcx, %r9
	leaq	(%r8,%rax), %r11
	subq	%r8, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2594:
	movzbl	(%r8), %edx
	movb	%dl, (%r9,%r8)
	addq	$1, %r8
	cmpq	%r11, %r8
	jne	.Lhrdbfw_2594
	movq	%rsi, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r10), %edx
.Lhrdbfw_2593:
	cmpq	%rax, %rdx
	jbe	.Lhrdbfw_2595
	leaq	2(%rsi), %rdx
	salq	$4, %rdx
	addq	%rdx, %r10
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2596:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r10), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbfw_2596
	jmp	.Lhrdbfw_2595
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2648:
	movq	%r12, %rdx
	call	hrdbf_write_date
	jmp	.Lhrdbfw_2602
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2651:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	jmp	hrdbf_app_rebuild_index
.Lhrdbfw_2590:
	leaq	.Lhrdbfw_C110(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2619:
	xorl	%r9d, %r9d
	movq	%r12, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbfw_2602
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2653:
	testq	%r9, %r9
	jns	.Lhrdbfw_2606
	movq	(%r8), %r8
.Lhrdbfw_2606:
	movq	%r8, %xmm2
	movq	%r12, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.Lhrdbfw_2602
.Lhrdbfw_2584:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2646:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2647:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2650:
	leaq	.Lhrdbfw_C112(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C113:

.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,47,114,101,99,97,108,108,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C114:

.byte 104,98,99,58,32,68,66,70,32,100,101,108,101,116,101,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_delete
hrdbfw_app_delete:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2667
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2668
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbfw_2669
.Lhrdbfw_2659:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2669:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	leaq	hrdbf_app_state(%rip), %rcx
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$42, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rdx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	je	.Lhrdbfw_2659
	leaq	.Lhrdbfw_C114(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2668:
	leaq	.Lhrdbfw_C113(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2667:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C115:

.byte 104,98,99,58,32,68,66,70,32,114,101,99,97,108,108,32,99,111,109,109,105,116,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_recall
hrdbfw_app_recall:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2678
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2679
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.Lhrdbfw_2680
.Lhrdbfw_2670:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2680:
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	leaq	hrdbf_app_state(%rip), %rcx
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state+32944(%rip), %rax
	movb	$32, (%rax,%rdx)
	movq	hrdbf_app_state+24(%rip), %rdx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	je	.Lhrdbfw_2670
	leaq	.Lhrdbfw_C115(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2679:
	leaq	.Lhrdbfw_C113(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2678:
	leaq	.Lhrdbfw_C93(%rip), %rcx
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
	je	.Lhrdbfw_2706
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2684
	movzwl	hrdbf_app_state+36(%rip), %ebx
	movq	%rcx, %r13
	movq	%rdx, %r12
	testl	%ebx, %ebx
	je	.Lhrdbfw_2686
	movq	%r8, %r14
	movq	%r9, %rsi
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2696:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2687:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2688
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2687
.Lhrdbfw_2688:
	cmpq	%r12, %rax
	je	.Lhrdbfw_2707
.Lhrdbfw_2690:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.Lhrdbfw_2696
.Lhrdbfw_2686:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2707:
	testq	%r12, %r12
	je	.Lhrdbfw_2691
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2695
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2708:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_2691
.Lhrdbfw_2695:
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
	je	.Lhrdbfw_2708
	cmpq	%rcx, %r12
	jne	.Lhrdbfw_2690
.Lhrdbfw_2691:
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
.Lhrdbfw_2684:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2706:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C116:

.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_append
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2715
	movl	hrdbf_app_state+32960(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2716
	cmpq	$0, hrdbf_app_state+32968(%rip)
	je	.Lhrdbfw_2713
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2713
	movl	$0, hrdbf_app_found_flag(%rip)
	call	hrdbf_app_rebuild_index
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2713:
	leaq	.Lhrdbfw_C116(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2715:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2716:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C117:

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
	jne	.Lhrdbfw_2720
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_2720:
	leaq	.Lhrdbfw_C117(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C118:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C119:

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
	jne	.Lhrdbfw_2722
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_2738
	testl	%eax, %eax
	je	.Lhrdbfw_2730
	cmpl	$9, %eax
	jne	.Lhrdbfw_2726
.Lhrdbfw_2730:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2738:
	testl	$65280, %r11d
	je	.Lhrdbfw_2730
.Lhrdbfw_2725:
	leaq	.Lhrdbfw_C118(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2722:
	cmpl	$2, %eax
	je	.Lhrdbfw_2725
.Lhrdbfw_2726:
	leaq	.Lhrdbfw_C119(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C120:

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
	jne	.Lhrdbfw_2742
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_2742:
	leaq	.Lhrdbfw_C120(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C121:

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
	jne	.Lhrdbfw_2744
	cmpb	$11, %r8b
	je	.Lhrdbfw_2751
.Lhrdbfw_2744:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.Lhrdbfw_2752
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2751:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2746
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2746
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
.Lhrdbfw_2752:
	leaq	.Lhrdbfw_C120(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2746:
	leaq	.Lhrdbfw_C121(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C122:

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
	jne	.Lhrdbfw_2754
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2765
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_2756
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2773:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_2769
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_2765
.Lhrdbfw_2756:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_2773
.Lhrdbfw_2769:
	xorl	%eax, %eax
.Lhrdbfw_2753:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2754:
	cmpl	$8, %ebx
	je	.Lhrdbfw_2774
	cmpl	$5, %ebx
	je	.Lhrdbfw_2775
	cmpl	$7, %ebx
	je	.Lhrdbfw_2769
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2761
	cmpl	$12, %ebx
	ja	.Lhrdbfw_2761
	movl	$1, %eax
	movl	%ebx, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbfw_2762
	testb	$2, %al
	jne	.Lhrdbfw_2765
.Lhrdbfw_2761:
	leaq	.Lhrdbfw_C122(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2765:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2774:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2753
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_2753
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2775:
	testq	%rcx, %rcx
	js	.Lhrdbfw_2776
.Lhrdbfw_2760:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_2753
.Lhrdbfw_2776:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_2760
.Lhrdbfw_2762:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_2753
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C123:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10,0
	.align 8
.Lhrdbfw_C124:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,111,110,32,97,32,78,73,76,32,111,114,32,110,111,110,45,110,117,109,101,114,105,99,32,111,112,101,114,97,110,100,10,0
.Lhrdbfw_C125:

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
	je	.Lhrdbfw_2782
	cmpl	$1, %eax
	je	.Lhrdbfw_2783
	testl	%eax, %eax
	jne	.Lhrdbfw_2784
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.Lhrdbfw_2782:
	leaq	.Lhrdbfw_C123(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2784:
	leaq	.Lhrdbfw_C125(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2783:
	leaq	.Lhrdbfw_C124(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C126:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C126(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.425:
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
