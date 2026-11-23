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
	jne	.Lhrdbfw_222
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.Lhrdbfw_224
.Lhrdbfw_222:
	movl	$1, %eax
.Lhrdbfw_216:
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
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.Lhrdbfw_216
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.Lhrdbfw_216
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.Lhrdbfw_216
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.Lhrdbfw_222
	cmpl	%r10d, %r13d
	jb	.Lhrdbfw_222
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrdbfw_216
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
	je	.Lhrdbfw_226
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_227:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.Lhrdbfw_227
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.Lhrdbfw_228
	testl	%edx, %edx
	je	.Lhrdbfw_228
.Lhrdbfw_230:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_228:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.Lhrdbfw_230
.Lhrdbfw_236:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.Lhrdbfw_230
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_230
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.Lhrdbfw_231
	xorl	%eax, %eax
	jmp	.Lhrdbfw_232
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_249:
	movq	(%rsi), %rcx
.Lhrdbfw_232:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.Lhrdbfw_249
.Lhrdbfw_231:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.Lhrdbfw_235
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_234:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_234
.Lhrdbfw_235:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_226:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_236
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
	je	.Lhrdbfw_253
	cmpl	$1023, %edx
	ja	.Lhrdbfw_304
.Lhrdbfw_253:
	movl	$1, %r12d
.Lhrdbfw_250:
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
.Lhrdbfw_304:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.Lhrdbfw_253
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_253
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
	jne	.Lhrdbfw_253
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.Lhrdbfw_254
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.Lhrdbfw_253
.Lhrdbfw_254:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_305
	cmpl	%r10d, %ecx
	jne	.Lhrdbfw_253
	cmpl	%edx, 312(%rax)
	jne	.Lhrdbfw_253
.Lhrdbfw_276:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.Lhrdbfw_258
	cmpl	$1023, %ecx
	jbe	.Lhrdbfw_253
	testl	$511, %ecx
	jne	.Lhrdbfw_253
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.Lhrdbfw_253
.Lhrdbfw_258:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.Lhrdbfw_259
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.Lhrdbfw_306
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_253
.Lhrdbfw_261:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	hrdbfw_local_cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_250
	testl	%r13d, %r13d
	je	.Lhrdbfw_271
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.Lhrdbfw_262:
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
	jne	.Lhrdbfw_281
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_264
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.Lhrdbfw_264
	cmpl	48(%rbx), %edx
	jbe	.Lhrdbfw_264
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.Lhrdbfw_264
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
	je	.Lhrdbfw_265
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.Lhrdbfw_266
.Lhrdbfw_308:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.Lhrdbfw_307
	movq	%rdx, %rax
.Lhrdbfw_266:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.Lhrdbfw_308
.Lhrdbfw_264:
	movl	$4, %r12d
	jmp	.Lhrdbfw_250
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_305:
	cmpl	$-1, %r10d
	jne	.Lhrdbfw_253
	jmp	.Lhrdbfw_276
.Lhrdbfw_259:
	testl	%r13d, %r13d
	je	.Lhrdbfw_253
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.Lhrdbfw_253
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.Lhrdbfw_274:
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
	jne	.Lhrdbfw_250
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.Lhrdbfw_253
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
	jne	.Lhrdbfw_253
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_272
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.Lhrdbfw_273
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_309:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_272
.Lhrdbfw_273:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.Lhrdbfw_309
	jmp	.Lhrdbfw_253
.Lhrdbfw_306:
	movl	%r8d, 52(%rbx)
	jmp	.Lhrdbfw_261
.Lhrdbfw_272:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.Lhrdbfw_250
	movzwl	%r8w, %eax
	jmp	.Lhrdbfw_274
.Lhrdbfw_307:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_279
.Lhrdbfw_303:
	movq	16(%r14), %rcx
.Lhrdbfw_269:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.Lhrdbfw_262
	movzwl	94(%rsp), %edi
.Lhrdbfw_271:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.Lhrdbfw_250
.Lhrdbfw_279:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.Lhrdbfw_270
.Lhrdbfw_268:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.Lhrdbfw_277
	movq	%r11, %r8
.Lhrdbfw_270:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.Lhrdbfw_268
	jb	.Lhrdbfw_269
	jmp	.Lhrdbfw_253
.Lhrdbfw_265:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_303
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.Lhrdbfw_277:
	cmpl	%edi, %r9d
	ja	.Lhrdbfw_269
	jmp	.Lhrdbfw_253
.Lhrdbfw_281:
	movl	%eax, %r12d
	jmp	.Lhrdbfw_250
	.p2align 4
hrdbfw_local_cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.Lhrdbfw_310
	cmpb	$1, 15(%rcx)
	jne	.Lhrdbfw_310
	cmpw	$1024, 16(%rcx)
	jne	.Lhrdbfw_310
	cmpw	$512, 18(%rcx)
	jne	.Lhrdbfw_310
	cmpw	$0, 502(%rcx)
	jne	.Lhrdbfw_310
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.Lhrdbfw_313
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_333:
	cmpl	$23, %eax
	ja	.Lhrdbfw_320
.Lhrdbfw_312:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.Lhrdbfw_332
.Lhrdbfw_313:
	cmpb	$0, (%rcx,%rax)
	je	.Lhrdbfw_312
	testb	%dl, %dl
	je	.Lhrdbfw_333
.Lhrdbfw_320:
	movl	$2, %eax
.Lhrdbfw_310:
	ret
.Lhrdbfw_332:
	testl	%r8d, %r8d
	je	.Lhrdbfw_314
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_310
	cmpb	$67, 21(%rcx)
	jne	.Lhrdbfw_310
	cmpb	$72, 22(%rcx)
	jne	.Lhrdbfw_310
	cmpb	$66, 23(%rcx)
	jne	.Lhrdbfw_310
.Lhrdbfw_314:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.Lhrdbfw_310
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.Lhrdbfw_310
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
	js	.Lhrdbfw_353
	jne	.Lhrdbfw_336
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r11
	je	.Lhrdbfw_338
.Lhrdbfw_337:
	leaq	(%r8,%r9), %rdx
	leaq	(%rdx,%r11), %r10
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_342:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%r10, %rdx
	jne	.Lhrdbfw_342
	addq	%r9, %r11
.Lhrdbfw_338:
	movq	%rsp, %r10
	addq	%r11, %r8
	leaq	(%r10,%rcx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_343:
	movzbl	-1(%rdx), %r9d
	subq	$1, %rdx
	addq	$1, %r8
	movb	%r9b, -1(%r8)
	cmpq	%r10, %rdx
	jne	.Lhrdbfw_343
	addq	$40, %rsp
	leaq	(%rcx,%r11), %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_353:
	negq	%r9
.Lhrdbfw_336:
	xorl	%ecx, %ecx
	leaq	-1(%rsp), %rbp
	movabs	$-3689348814741910323, %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_339:
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
	ja	.Lhrdbfw_339
	testq	%rdi, %rdi
	jns	.Lhrdbfw_345
	movb	$45, (%r8)
	addq	$2, %rbx
	movl	$1, %r9d
.Lhrdbfw_340:
	subq	%rbx, %r11
	jne	.Lhrdbfw_337
	movq	%r9, %r11
	jmp	.Lhrdbfw_338
.Lhrdbfw_345:
	movq	%rcx, %rbx
	xorl	%r9d, %r9d
	jmp	.Lhrdbfw_340
	.p2align 4
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.Lhrdbfw_355
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_356:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_356
.Lhrdbfw_355:
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
	je	.Lhrdbfw_363
	leaq WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.Lhrdbfw_364
	jmp	.Lhrdbfw_365
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_376:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_363
	cmpq	%rax, %rbx
	jb	.Lhrdbfw_363
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.Lhrdbfw_365
.Lhrdbfw_364:
	movq	2280(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.Lhrdbfw_376
.Lhrdbfw_363:
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
.Lhrdbfw_365:
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
	ja	.Lhrdbfw_377
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_457
	cmpb	$78, %r9b
	je	.Lhrdbfw_458
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_459
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_404
	cmpb	$89, %al
	je	.Lhrdbfw_404
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_377
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_377
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_377:
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
.Lhrdbfw_404:
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
.Lhrdbfw_458:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_381
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_382
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_383:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_381
.Lhrdbfw_382:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_383
	jmp	.Lhrdbfw_385
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_409:
	movl	%r9d, %ecx
.Lhrdbfw_385:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_384
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_409
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_387
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_407:
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
	jmp	.Lhrdbfw_391
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_461:
	testl	%esi, %esi
	jne	.Lhrdbfw_428
	movl	$1, %esi
.Lhrdbfw_389:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_460
.Lhrdbfw_391:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_461
.Lhrdbfw_428:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_421
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_418
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_389
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_389
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_457:
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
.Lhrdbfw_459:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_400:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_420
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_400
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_377
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_421:
	movl	$5, %r11d
	jmp	.Lhrdbfw_377
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_420:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_399:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_421
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_399
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
	jbe	.Lhrdbfw_377
	cmpl	$11, %edx
	ja	.Lhrdbfw_377
	testl	%r10d, %r10d
	je	.Lhrdbfw_377
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_462
.Lhrdbfw_402:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_377
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_377
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_387:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_388:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_421
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_407
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_418:
	movl	$4, %r11d
	jmp	.Lhrdbfw_377
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_460:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_377
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_377
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_392
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_393
	jmp	.Lhrdbfw_418
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_394:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_418
.Lhrdbfw_393:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_394
	testl	%r12d, %r12d
	jne	.Lhrdbfw_406
.Lhrdbfw_397:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_377
.Lhrdbfw_384:
	je	.Lhrdbfw_381
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_387
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_388
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_381:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_377
.Lhrdbfw_462:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_402
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_403
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_402
.Lhrdbfw_403:
	addl	$1, %edx
	jmp	.Lhrdbfw_402
.Lhrdbfw_392:
	testl	%r12d, %r12d
	je	.Lhrdbfw_397
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_397
.Lhrdbfw_406:
	negq	%rbx
	jmp	.Lhrdbfw_397
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
	je	.Lhrdbfw_466
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_478
.Lhrdbfw_466:
	xorl	%r12d, %r12d
.Lhrdbfw_465:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_467
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_479
	movl	$7, %r12d
.Lhrdbfw_467:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_463
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_470
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_463:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_479:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_467
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_478:
	movl	$7, %r12d
	jmp	.Lhrdbfw_465
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_470:
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
	jne	.Lhrdbfw_480
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_480:
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
	ja	.Lhrdbfw_486
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_486
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_486
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_486
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_486
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_482
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_482
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_482
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_482
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_486
	testl	$511, %r12d
	jne	.Lhrdbfw_486
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_486
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_482
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_482
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_486
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_486
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_482
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
	jne	.Lhrdbfw_482
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_486
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_486
	testl	$511, %eax
	jne	.Lhrdbfw_486
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_486
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_486
	cmpl	%r12d, %eax
	je	.Lhrdbfw_486
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_486
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_487
.Lhrdbfw_560:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_524
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_559
.Lhrdbfw_487:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_560
.Lhrdbfw_524:
	movl	$2, %eax
	jmp	.Lhrdbfw_482
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_486:
	movl	$1, %eax
.Lhrdbfw_482:
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
.Lhrdbfw_559:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_482
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_524
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_524
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_524
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_488:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_524
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_488
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_489:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_524
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_498:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_492
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_493
	subl	$32, %ecx
.Lhrdbfw_493:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_494
	subl	$32, %r13d
.Lhrdbfw_494:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_492
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_490
	cmpq	$11, %rdx
	jne	.Lhrdbfw_498
	cmpq	$11, %rax
	jne	.Lhrdbfw_492
.Lhrdbfw_496:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_524
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_524
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_523
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_524
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_528
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_530
	testl	%eax, %eax
	jne	.Lhrdbfw_528
.Lhrdbfw_530:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_528
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_528
	xorl	%edx, %edx
.Lhrdbfw_500:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_500
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_501
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_501:
	testb	$2, %al
	jne	.Lhrdbfw_502
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_502:
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
.Lhrdbfw_503:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_503
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_561
.Lhrdbfw_504:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_482
.Lhrdbfw_490:
	cmpq	$11, %rax
	je	.Lhrdbfw_496
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_496
.Lhrdbfw_492:
	addq	$1, %r9
	jmp	.Lhrdbfw_489
.Lhrdbfw_528:
	movl	$3, %eax
	jmp	.Lhrdbfw_482
.Lhrdbfw_523:
	movl	$5, %eax
	jmp	.Lhrdbfw_482
.Lhrdbfw_561:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_504
	xorl	%edx, %edx
	jmp	.Lhrdbfw_506
.Lhrdbfw_562:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_531
.Lhrdbfw_506:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_505
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_505:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_562
.Lhrdbfw_531:
	testl	%eax, %eax
	jne	.Lhrdbfw_504
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_482
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
	ja	.Lhrdbfw_563
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call VirtualAlloc
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_571
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.Lhrdbfw_568
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_565:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.Lhrdbfw_565
.Lhrdbfw_568:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.Lhrdbfw_567
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_566:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbfw_566
	addq	%r14, %rdx
.Lhrdbfw_567:
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
	je	.Lhrdbfw_583
.Lhrdbfw_569:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call VirtualFree
.Lhrdbfw_563:
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
.Lhrdbfw_583:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_569
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_569
	xorl	%edx, %edx
	movq	2256(%rbx), %rcx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_574
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
	jmp	.Lhrdbfw_563
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_571:
	movl	$8, %r15d
	jmp	.Lhrdbfw_563
.Lhrdbfw_574:
	movl	$7, %r15d
	jmp	.Lhrdbfw_569
	.p2align 4
hrdbfw_local_put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.Lhrdbfw_584
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.Lhrdbfw_605
	subl	%r10d, %edx
	je	.Lhrdbfw_590
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_591:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.Lhrdbfw_591
.Lhrdbfw_590:
	testl	%r10d, %r10d
	je	.Lhrdbfw_589
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_592:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.Lhrdbfw_592
.Lhrdbfw_589:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_584:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_605:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.Lhrdbfw_589
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_588:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.Lhrdbfw_589
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_588
	jmp	.Lhrdbfw_589
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
	ja	.Lhrdbfw_606
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.Lhrdbfw_632
	cmpb	%r8b, %r13b
	jnb	.Lhrdbfw_632
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.Lhrdbfw_608
	negq	%rcx
	movl	$1, %r11d
.Lhrdbfw_608:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_609
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.Lhrdbfw_610
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_611:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.Lhrdbfw_611
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq $1, %r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.Lhrdbfw_612
.Lhrdbfw_610:
	addq	$1, %rcx
.Lhrdbfw_612:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_617:
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
	ja	.Lhrdbfw_617
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
	ja	.Lhrdbfw_660
	testl	%r11d, %r11d
	je	.Lhrdbfw_623
	movb	$45, 96(%rsp)
.Lhrdbfw_623:
	cmpl	%r10d, %ebp
	jb	.Lhrdbfw_661
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.Lhrdbfw_625:
	testb	%r13b, %r13b
	je	.Lhrdbfw_627
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.Lhrdbfw_628
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_629:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.Lhrdbfw_629
	addl	%ebp, %eax
.Lhrdbfw_628:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_630:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.Lhrdbfw_630
.Lhrdbfw_627:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_606:
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
.Lhrdbfw_632:
	movl	$4, %eax
	jmp	.Lhrdbfw_606
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_609:
	jnb	.Lhrdbfw_612
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.Lhrdbfw_612
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_613
	xorl	%eax, %eax
	jmp	.Lhrdbfw_614
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_616:
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_613
.Lhrdbfw_614:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.Lhrdbfw_616
	jmp	.Lhrdbfw_612
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_661:
	testl	%r14d, %r14d
	je	.Lhrdbfw_636
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.Lhrdbfw_626
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_662:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.Lhrdbfw_626:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.Lhrdbfw_662
	jmp	.Lhrdbfw_625
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_660:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_621:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbfw_621
	xorl	%eax, %eax
	jmp	.Lhrdbfw_606
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_613:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_615:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_615
	xorl	%eax, %eax
	jmp	.Lhrdbfw_606
.Lhrdbfw_636:
	movl	%r11d, %edx
	jmp	.Lhrdbfw_625
	.p2align 4
hrdbfw_local_bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_712
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.Lhrdbfw_715
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.Lhrdbfw_671
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.Lhrdbfw_673
.Lhrdbfw_672:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_676
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_675:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.Lhrdbfw_716
	movl	%eax, %ecx
.Lhrdbfw_676:
	cmpl	%ecx, %r10d
	jbe	.Lhrdbfw_675
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbfw_675
.Lhrdbfw_674:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.Lhrdbfw_673
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.Lhrdbfw_681
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_680:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.Lhrdbfw_680
.Lhrdbfw_681:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.Lhrdbfw_673
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_682:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_682
.Lhrdbfw_673:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.Lhrdbfw_663
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_683
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_684:
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
	jne	.Lhrdbfw_684
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.Lhrdbfw_663
	movl	%edi, 288(%r9)
	jmp	.Lhrdbfw_663
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_715:
	testl	%r10d, %r10d
	je	.Lhrdbfw_666
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_668:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_668
	testl	%eax, %eax
	je	.Lhrdbfw_666
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_669:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_669
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.Lhrdbfw_666
	jne	.Lhrdbfw_691
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.Lhrdbfw_666
.Lhrdbfw_691:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_666:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.Lhrdbfw_663:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_712:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_671:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.Lhrdbfw_672
	jmp	.Lhrdbfw_674
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_716:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_674
.Lhrdbfw_683:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.Lhrdbfw_663
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
.Lhrdbfw_718:
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
	jbe	.Lhrdbfw_726
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_718
.Lhrdbfw_726:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_724:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_720
	jmp	.Lhrdbfw_721
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_722:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_721
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_720:
	testb	%cl, %cl
	jne	.Lhrdbfw_722
.Lhrdbfw_721:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_717
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_724
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_717:
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
	je	.Lhrdbfw_741
	movabs	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.Lhrdbfw_979
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.Lhrdbfw_739:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_744:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_745:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_745
	testq	%rax, %rax
	je	.Lhrdbfw_746
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.Lhrdbfw_746:
	subl	$1, %r9d
	jne	.Lhrdbfw_744
	testb	%r11b, %r11b
	je	.Lhrdbfw_748
	movl	%r10d, 352(%rsp)
.Lhrdbfw_748:
	testl	%r12d, %r12d
	js	.Lhrdbfw_749
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_976:
	movl	352(%rsp), %eax
.Lhrdbfw_752:
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_750
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_755:
	cmpq	$80, %rbx
	je	.Lhrdbfw_980
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.Lhrdbfw_750:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.Lhrdbfw_755
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_755
	testl	%ebx, %ebx
	jne	.Lhrdbfw_981
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_740
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.Lhrdbfw_982
.Lhrdbfw_741:
	xorl	%eax, %eax
.Lhrdbfw_733:
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
.Lhrdbfw_979:
	testq	%rax, %rax
	jne	.Lhrdbfw_983
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.Lhrdbfw_740
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.Lhrdbfw_741
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_743:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_743
	jmp	.Lhrdbfw_733
.Lhrdbfw_740:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.Lhrdbfw_741
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.Lhrdbfw_733
.Lhrdbfw_983:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.Lhrdbfw_739
.Lhrdbfw_749:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	hrdbfw_local_bn_shr_round
	cmpl	$1, %eax
	jbe	.Lhrdbfw_976
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_848
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.Lhrdbfw_754:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.Lhrdbfw_754
	testq	%rdx, %rdx
	je	.Lhrdbfw_752
	leal	1(%rax), %edx
.Lhrdbfw_753:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.Lhrdbfw_752
.Lhrdbfw_980:
	movl	$79, %r10d
.Lhrdbfw_758:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.Lhrdbfw_762:
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
	ja	.Lhrdbfw_762
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.Lhrdbfw_764
.Lhrdbfw_984:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_764:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.Lhrdbfw_984
	testl	%r10d, %r10d
	je	.Lhrdbfw_765
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.Lhrdbfw_767:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_766:
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
	jne	.Lhrdbfw_766
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.Lhrdbfw_985
	movq	%rax, %rbp
	jmp	.Lhrdbfw_767
.Lhrdbfw_985:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.Lhrdbfw_765:
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
.Lhrdbfw_769:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
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
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_770
	testq	%rax, %rax
	je	.Lhrdbfw_771
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.Lhrdbfw_771:
	subl	$1, %r9d
	jne	.Lhrdbfw_769
	testb	%dil, %dil
	je	.Lhrdbfw_773
	movl	%r10d, 656(%rsp)
.Lhrdbfw_773:
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
	je	.Lhrdbfw_774
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
.Lhrdbfw_775:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_776:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_776
	testq	%rax, %rax
	je	.Lhrdbfw_777
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_777:
	subl	$1, %ebx
	jne	.Lhrdbfw_775
	testb	%bpl, %bpl
	je	.Lhrdbfw_779
	movl	%edi, 960(%rsp)
.Lhrdbfw_779:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_780:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.Lhrdbfw_787
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.Lhrdbfw_814:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_788:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.Lhrdbfw_788
	cmpb	$53, (%rdi)
	ja	.Lhrdbfw_789
	je	.Lhrdbfw_986
.Lhrdbfw_790:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.Lhrdbfw_987
.Lhrdbfw_792:
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
	je	.Lhrdbfw_796
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_795:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_797:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_797
	testq	%rax, %rax
	je	.Lhrdbfw_798
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.Lhrdbfw_798:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.Lhrdbfw_795
	testb	%r15b, %r15b
	je	.Lhrdbfw_796
	movl	%r9d, 1264(%rsp)
.Lhrdbfw_796:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.Lhrdbfw_801
	jnb	.Lhrdbfw_802
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_803
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_810
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_813:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.Lhrdbfw_988
.Lhrdbfw_810:
	cmpl	$-1, %eax
	jne	.Lhrdbfw_813
.Lhrdbfw_809:
	testb	$1, 40(%rsp)
	je	.Lhrdbfw_968
.Lhrdbfw_803:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.Lhrdbfw_969
	cmpl	%r12d, %ebp
	jb	.Lhrdbfw_814
.Lhrdbfw_969:
	movq	2400(%rsp), %rsi
.Lhrdbfw_787:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.Lhrdbfw_816:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.Lhrdbfw_817:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.Lhrdbfw_817
	cmpl	%r12d, %ebp
	jnb	.Lhrdbfw_818
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.Lhrdbfw_819
	jne	.Lhrdbfw_818
	testb	$1, %r8b
	jne	.Lhrdbfw_819
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.Lhrdbfw_818
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.Lhrdbfw_820
.Lhrdbfw_989:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.Lhrdbfw_818
.Lhrdbfw_820:
	cmpb	$48, (%rcx)
	je	.Lhrdbfw_989
.Lhrdbfw_819:
	addq	$1, %r8
.Lhrdbfw_818:
	movabs	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.Lhrdbfw_821:
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
	ja	.Lhrdbfw_821
	cmpl	%ebp, %ecx
	jbe	.Lhrdbfw_822
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.Lhrdbfw_826
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.Lhrdbfw_822:
	xorl	%edx, %edx
	jmp	.Lhrdbfw_824
.Lhrdbfw_990:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_824:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbfw_990
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_825
.Lhrdbfw_991:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbfw_825
	movl	%eax, %ecx
.Lhrdbfw_826:
	cmpl	$1, %ecx
	ja	.Lhrdbfw_991
.Lhrdbfw_825:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.Lhrdbfw_992
	cmpl	%ecx, %r8d
	jge	.Lhrdbfw_831
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.Lhrdbfw_837
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.Lhrdbfw_834
.Lhrdbfw_833:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.Lhrdbfw_993
	movq	%rcx, %rdx
.Lhrdbfw_834:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.Lhrdbfw_833
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.Lhrdbfw_837
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_995:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.Lhrdbfw_994
	movl	%edx, %r8d
.Lhrdbfw_837:
	cmpl	$1, %r8d
	jne	.Lhrdbfw_995
.Lhrdbfw_836:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.Lhrdbfw_829
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_801:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.Lhrdbfw_806
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_808:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.Lhrdbfw_996
.Lhrdbfw_806:
	cmpl	$-1, %edx
	jne	.Lhrdbfw_808
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.Lhrdbfw_810
	jmp	.Lhrdbfw_809
.Lhrdbfw_986:
	testb	$1, %r8b
	jne	.Lhrdbfw_789
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbfw_790
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.Lhrdbfw_791
.Lhrdbfw_997:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_790
.Lhrdbfw_791:
	cmpb	$48, (%rax)
	je	.Lhrdbfw_997
.Lhrdbfw_789:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.Lhrdbfw_792
.Lhrdbfw_987:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_793:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.Lhrdbfw_793
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_792
	movabs	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.Lhrdbfw_792
.Lhrdbfw_988:
	jnb	.Lhrdbfw_812
	cmpl	$1, %ecx
	je	.Lhrdbfw_968
.Lhrdbfw_812:
	testl	%ecx, %ecx
	jne	.Lhrdbfw_803
	jmp	.Lhrdbfw_809
.Lhrdbfw_996:
	jnb	.Lhrdbfw_807
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.Lhrdbfw_810
	jmp	.Lhrdbfw_803
.Lhrdbfw_802:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_977
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_810
.Lhrdbfw_977:
	jnb	.Lhrdbfw_803
.Lhrdbfw_968:
	movq	2400(%rsp), %rsi
	jmp	.Lhrdbfw_816
.Lhrdbfw_807:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_977
	movl	$1, %ecx
	jmp	.Lhrdbfw_810
.Lhrdbfw_774:
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
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_783
	testq	%rax, %rax
	je	.Lhrdbfw_784
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_784:
	subl	$1, %ebx
	jne	.Lhrdbfw_782
	testb	%r11b, %r11b
	je	.Lhrdbfw_786
	movl	%edi, 960(%rsp)
.Lhrdbfw_786:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
	jmp	.Lhrdbfw_780
.Lhrdbfw_831:
	cmpl	$1, %ecx
	je	.Lhrdbfw_836
.Lhrdbfw_829:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.Lhrdbfw_838:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.Lhrdbfw_741
	testl	%r10d, %r10d
	je	.Lhrdbfw_862
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.Lhrdbfw_840:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbfw_841
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.Lhrdbfw_843:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_842
	movzbl	0(%r13,%rdx), %r11d
.Lhrdbfw_842:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_843
	addl	%r10d, %eax
.Lhrdbfw_844:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbfw_733
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.Lhrdbfw_846
.Lhrdbfw_999:
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_864
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.Lhrdbfw_845:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.Lhrdbfw_998
.Lhrdbfw_846:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.Lhrdbfw_999
.Lhrdbfw_864:
	movl	$48, %r10d
	jmp	.Lhrdbfw_845
.Lhrdbfw_862:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.Lhrdbfw_840
.Lhrdbfw_992:
	jne	.Lhrdbfw_828
	cmpb	$52, 1600(%rsp)
	jbe	.Lhrdbfw_828
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.Lhrdbfw_829
.Lhrdbfw_828:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.Lhrdbfw_838
.Lhrdbfw_841:
	movb	$48, (%rdx)
	jmp	.Lhrdbfw_844
.Lhrdbfw_998:
	addl	%r9d, %eax
	jmp	.Lhrdbfw_733
.Lhrdbfw_981:
	subl	$1, %r10d
	jmp	.Lhrdbfw_758
.Lhrdbfw_982:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_761:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_761
	jmp	.Lhrdbfw_733
.Lhrdbfw_994:
	movl	%r8d, %ecx
	jmp	.Lhrdbfw_829
.Lhrdbfw_848:
	movl	$1, %edx
	jmp	.Lhrdbfw_753
.Lhrdbfw_993:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.Lhrdbfw_837
	.p2align 4
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.Lhrdbfw_1007
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.Lhrdbfw_1000
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1000
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_1000:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1007:
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
	jmp	.Lhrdbfw_1011
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1013:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1012
.Lhrdbfw_1011:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_1013
.Lhrdbfw_1012:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1014
	movl	$32, %ecx
	leaq	.Lhrdbfw_C1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1016:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1020
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1016
.Lhrdbfw_1020:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_1014:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1017
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_1017:
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
.Lhrdbfw_1022:
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
	jbe	.Lhrdbfw_1032
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_1022
.Lhrdbfw_1032:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1030:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_1024
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1026:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1025
.Lhrdbfw_1024:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1026
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_1027
	jmp	.Lhrdbfw_1025
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1028:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1025
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_1027:
	testb	%cl, %cl
	jne	.Lhrdbfw_1028
.Lhrdbfw_1025:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_1021
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_1030
.Lhrdbfw_1021:
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
.Lhrdbfw_1040:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_1039
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.Lhrdbfw_1042
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1044:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1043
.Lhrdbfw_1042:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1044
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1045
	jmp	.Lhrdbfw_1043
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1046:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1043
.Lhrdbfw_1045:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1046
.Lhrdbfw_1043:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_1040
.Lhrdbfw_1039:
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
	leaq	2090(%rcx), %rax
	addq	$2249, %rcx
	movb	$0, 15(%rsp)
	movq	%rax, %rdx
	movb	%r8b, 14(%rsp)
	jmp	.Lhrdbfw_1054
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1056:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1055
.Lhrdbfw_1054:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_1056
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_1057
	jmp	.Lhrdbfw_1055
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1059:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1055
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_1057:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1059
.Lhrdbfw_1055:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_1061
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1063:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1062
.Lhrdbfw_1061:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1063
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_1064
	jmp	.Lhrdbfw_1062
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1065:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1062
.Lhrdbfw_1064:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1065
.Lhrdbfw_1062:
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
	je	.Lhrdbfw_1143
	js	.Lhrdbfw_1077
	movabs	$-4611681598906040321, %r8
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1076
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1145:
	movl	%eax, %edx
	andl	$-65, %edx
	cmpb	$60, %dl
	je	.Lhrdbfw_1077
.Lhrdbfw_1081:
	movw	%ax, (%r15,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1144
	testb	%al, %al
	js	.Lhrdbfw_1077
	cmpq	$258, %rbx
	ja	.Lhrdbfw_1077
.Lhrdbfw_1076:
	cmpb	$63, %al
	ja	.Lhrdbfw_1145
	btq	%rax, %r8
	jc	.Lhrdbfw_1077
	cmpb	$60, %al
	je	.Lhrdbfw_1077
	cmpb	$58, %al
	jne	.Lhrdbfw_1080
	cmpq	$1, %rbx
	jne	.Lhrdbfw_1077
	movzbl	(%rcx), %eax
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	ja	.Lhrdbfw_1077
	movl	$58, %eax
	jmp	.Lhrdbfw_1081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1080:
	cmpb	$47, %al
	jne	.Lhrdbfw_1081
	movl	$92, %eax
	jmp	.Lhrdbfw_1081
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1151:
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1087
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1077:
	xorl	%eax, %eax
.Lhrdbfw_1073:
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
.Lhrdbfw_1144:
	xorl	%eax, %eax
	xorl	%r14d, %r14d
	leaq	.Lhrdbfw_C3(%rip), %rdi
	movw	%ax, (%r15,%rbx,2)
	leaq	.Lhrdbfw_C4(%rip), %rbp
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1102
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1147:
	addq	$1, %r14
.Lhrdbfw_1084:
	cmpq	%r14, %rbx
	jb	.Lhrdbfw_1146
.Lhrdbfw_1102:
	cmpq	%r14, %rbx
	je	.Lhrdbfw_1083
	cmpw	$92, (%r15,%r14,2)
	jne	.Lhrdbfw_1147
.Lhrdbfw_1083:
	movq	%r14, %rsi
	subq	%rax, %rsi
	je	.Lhrdbfw_1085
	movzwl	-2(%r15,%r14,2), %edx
	cmpw	$32, %dx
	je	.Lhrdbfw_1086
	cmpw	$46, %dx
	je	.Lhrdbfw_1086
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
.Lhrdbfw_1087:
	movl	%r13d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1089
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1090:
	movzwl	(%r12,%rax,2), %edx
.Lhrdbfw_1089:
	cmpw	$46, %dx
	je	.Lhrdbfw_1148
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_1090
	cmpw	$32, -2(%r12,%rsi,2)
	jne	.Lhrdbfw_1092
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1096:
	subq	$1, %rsi
	je	.Lhrdbfw_1092
.Lhrdbfw_1095:
	cmpw	$32, -2(%r12,%rsi,2)
	je	.Lhrdbfw_1096
.Lhrdbfw_1092:
	movq	%rdi, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	movq	%rbp, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1077
	cmpq	$4, %rsi
	jne	.Lhrdbfw_1085
	movzwl	6(%r12), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_1085
	movzwl	%r13w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_1099
.Lhrdbfw_1149:
	leaq	.Lhrdbfw_C10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_1107
	movzwl	(%r12,%rcx,2), %eax
.Lhrdbfw_1099:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1107
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_1149
	jmp	.Lhrdbfw_1077
.Lhrdbfw_1107:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_1101
.Lhrdbfw_1150:
	movzwl	(%r12,%rdx,2), %r13d
.Lhrdbfw_1101:
	movzwl	%r13w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_1085
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_1077
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_1150
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1085:
	leaq	1(%r14), %rax
	movq	%rax, %r14
	jmp	.Lhrdbfw_1084
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1086:
	cmpq	$1, %rsi
	je	.Lhrdbfw_1151
	cmpq	$2, %rsi
	jne	.Lhrdbfw_1077
	addq	%rax, %rax
	leaq	(%r15,%rax), %r12
	cmpw	$46, (%r12)
	jne	.Lhrdbfw_1077
	movzwl	2(%r15,%rax), %r13d
	cmpw	$46, %r13w
	je	.Lhrdbfw_1087
	jmp	.Lhrdbfw_1077
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1148:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_1095
	jmp	.Lhrdbfw_1092
.Lhrdbfw_1146:
	cmpw	$92, (%r15)
	je	.Lhrdbfw_1077
	movl	$1, %eax
	cmpq	$1, %rbx
	je	.Lhrdbfw_1073
	cmpw	$58, 2(%r15)
	jne	.Lhrdbfw_1073
	cmpq	$2, %rbx
	je	.Lhrdbfw_1077
	cmpw	$92, 4(%r15)
	jne	.Lhrdbfw_1077
	jmp	.Lhrdbfw_1073
.Lhrdbfw_1143:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movw	%dx, (%r15)
	jmp	.Lhrdbfw_1073
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

.byte 32,101,120,99,101,101,100,115,32,116,104,101,32,54,52,32,77,105,66,32,108,105,109,105,116,0
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
	je	.Lhrdbfw_1156
	movq	%rdx, %rsi
	movq	%r8, %rbx
	movq	%r9, %rdi
	cmpb	$92, %al
	je	.Lhrdbfw_1200
	cmpb	$47, %al
	jne	.Lhrdbfw_1157
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_1156
.Lhrdbfw_1157:
	leaq	96(%rsp), %r12
	movq	%r12, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_1156
	cmpl	$2, %ebp
	je	.Lhrdbfw_1177
	xorl	%r8d, %r8d
	movl	$-1073741824, %edx
	cmpl	$1, %ebp
	movl	$-2147483648, %eax
	cmovne	%eax, %edx
.Lhrdbfw_1160:
	movq	%r12, %rcx
	movl	$128, 40(%rsp)
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$3, 32(%rsp)
	call CreateFileW
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.Lhrdbfw_1201
	movq	%rax, (%rdi)
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%rax, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1202
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_1203
	cmpq	$67108864, %r10
	jg	.Lhrdbfw_1204
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1165
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1205
.Lhrdbfw_1165:
	movq	%r10, %rdx
	movq	%r10, (%rbx)
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, (%rsi)
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1166
	movq	(%rbx), %r8
	leaq ReadFile(%rip), %rdi
	xorl	%r15d, %r15d
	leaq	76(%rsp), %rbp
	leaq GetLastError(%rip), %r13
	testq	%r8, %r8
	jne	.Lhrdbfw_1167
	jmp	.Lhrdbfw_1168
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1172:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1199
	movq	(%rbx), %r8
	movl	%eax, %edx
	movq	%r8, %rax
	subq	%r15, %rax
	cmpq	%rax, %rdx
	ja	.Lhrdbfw_1206
	addq	%rdx, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_1168
	movq	(%rsi), %rdx
.Lhrdbfw_1167:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rdi
	testl	%eax, %eax
	jne	.Lhrdbfw_1172
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_1172
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1199:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1200:
	cmpb	$92, 1(%rcx)
	jne	.Lhrdbfw_1157
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1156:
	leaq	.Lhrdbfw_C12(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_1152:
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
.Lhrdbfw_1177:
	movl	$3, %r8d
	movl	$-2147483648, %edx
	jmp	.Lhrdbfw_1160
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1203:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1168:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rbp, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rdi
	testl	%eax, %eax
	je	.Lhrdbfw_1207
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_1176
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1176
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_1152
.Lhrdbfw_1176:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1204:
	leaq	.Lhrdbfw_C16(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C17(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1206:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1199
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1202:
	call GetLastError
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1201:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1152
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1205:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1152
.Lhrdbfw_1166:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1152
.Lhrdbfw_1207:
	call GetLastError
	jmp	.Lhrdbfw_1199
	.p2align 4
hrntx_file_open.part.0.constprop.0:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	%edx, %ebx
	subq	$72, %rsp
	testl	%edx, %edx
	je	.Lhrdbfw_1230
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1211
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rdi
.Lhrdbfw_1214:
	movl	$4, %r12d
	cmpq	$67108864, %rdi
	ja	.Lhrdbfw_1211
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
	je	.Lhrdbfw_1218
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
	je	.Lhrdbfw_1208
	cmpl	$5, %eax
	sete	%r12b
	movzbl	%r12b, %r12d
	leal	1(%r12,%r12), %r12d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1211:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmovne	%eax, %r12d
.Lhrdbfw_1208:
	addq	$72, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1230:
	leaq	hrdbf_app_order+64(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.Lhrdbfw_1211
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rdi
	jmp	.Lhrdbfw_1214
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1218:
	movl	$8, %r12d
	jmp	.Lhrdbfw_1211
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
	je	.Lhrdbfw_1232
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_1232:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1235
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1235
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_1237
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
.Lhrdbfw_1239:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_1249
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1235:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1237:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1240
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1249:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1240:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_1239
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
	je	.Lhrdbfw_1252
	testl	%edx, %edx
	je	.Lhrdbfw_1254
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1254
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1254:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1252:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1255
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1257
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_1257:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1255:
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

.byte 109,111,114,101,32,116,104,97,110,32,49,50,56,32,102,105,101,108,100,32,100,101,115,99,114,105,112,116,111,114,115,0
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
	jbe	.Lhrdbfw_1345
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_1346
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
	jbe	.Lhrdbfw_1264
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.Lhrdbfw_1265
.Lhrdbfw_1264:
	leaq	.Lhrdbfw_C26(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	144(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C27(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C28(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
.Lhrdbfw_1260:
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
.Lhrdbfw_1265:
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
.Lhrdbfw_1291:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.Lhrdbfw_1347
	cmpq	%r15, 64(%rsp)
	je	.Lhrdbfw_1348
	cmpq	$129, %r15
	je	.Lhrdbfw_1349
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1275
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1350:
	movzbl	(%r8,%rax), %r10d
.Lhrdbfw_1275:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1350
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_1276
	cmpl	$1, %r15d
	jbe	.Lhrdbfw_1277
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1278:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_1281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1352:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_1281:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.Lhrdbfw_1351
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1352
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C63(%rip), %rdx
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
	leaq	.Lhrdbfw_C64(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1351:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.Lhrdbfw_1278
.Lhrdbfw_1277:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.Lhrdbfw_1353
	cmpb	$67, %dl
	je	.Lhrdbfw_1354
	cmpb	$78, %dl
	je	.Lhrdbfw_1355
	cmpb	$76, %dl
	je	.Lhrdbfw_1356
	cmpb	$68, %dl
	jne	.Lhrdbfw_1288
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.Lhrdbfw_1284
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C43(%rip), %rdx
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
	leaq	.Lhrdbfw_C44(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1345:
	leaq	.Lhrdbfw_C15(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1346:
	leaq	.Lhrdbfw_C24(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C25(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1354:
	testb	%r9b, %r9b
	jne	.Lhrdbfw_1357
.Lhrdbfw_1284:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_1358
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.Lhrdbfw_1291
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1355:
	cmpb	$17, %r9b
	ja	.Lhrdbfw_1312
	cmpb	%r9b, %al
	ja	.Lhrdbfw_1284
.Lhrdbfw_1312:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C37(%rip), %rdx
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
	leaq	.Lhrdbfw_C38(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	134(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C39(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzbl	135(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C40(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$4, %eax
	jmp	.Lhrdbfw_1260
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1356:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.Lhrdbfw_1284
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C41(%rip), %rdx
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
	leaq	.Lhrdbfw_C42(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1348:
	testb	%dl, %dl
	je	.Lhrdbfw_1271
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1271:
	leaq	.Lhrdbfw_C29(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movzwl	148(%rsp), %eax
	movq	%r12, %rcx
	leaq	1(%rax), %rdx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C30(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1349:
	testb	%dl, %dl
	je	.Lhrdbfw_1273
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1273:
	leaq	.Lhrdbfw_C31(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1347:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.Lhrdbfw_1267
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1267:
	cmpw	$0, 148(%rsp)
	je	.Lhrdbfw_1359
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.Lhrdbfw_1293
	jmp	.Lhrdbfw_1360
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1294:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.Lhrdbfw_1361
.Lhrdbfw_1293:
	cmpq	%r9, 32(%rsp)
	ja	.Lhrdbfw_1294
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1362
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_1296
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_1297
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_1296
.Lhrdbfw_1297:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1276:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C29(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movzwl	148(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C32(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1353:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C33(%rip), %rdx
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
	leaq	.Lhrdbfw_C34(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1361:
	leaq	.Lhrdbfw_C52(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1358:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1357:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C35(%rip), %rdx
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
	leaq	.Lhrdbfw_C36(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1360:
	leaq	.Lhrdbfw_C50(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	%edi, %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C51(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1359:
	leaq	.Lhrdbfw_C49(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1288:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C33(%rip), %rdx
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
	leaq	.Lhrdbfw_C45(%rip), %rdx
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
	leaq	.Lhrdbfw_C46(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$3, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1296:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.Lhrdbfw_1309
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.Lhrdbfw_1301:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_1299
	cmpb	$42, %dil
	jne	.Lhrdbfw_1363
.Lhrdbfw_1299:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.Lhrdbfw_1300
	jmp	.Lhrdbfw_1307
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1303:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1364
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_1307
.Lhrdbfw_1300:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.Lhrdbfw_1303
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
	movq	56(%rsp), %rsi
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	10(%rsi,%rax), %rdx
	call	hrdbfw_local_dname
	movl	$6, %eax
	leaq	.Lhrdbfw_C22(%rip), %rdx
.Lhrdbfw_1304:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.Lhrdbfw_1365
.Lhrdbfw_1306:
	cmpb	$42, %dil
	jne	.Lhrdbfw_1260
	leaq	.Lhrdbfw_C62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1307:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_1301
	cmpb	$0, 152(%rsp)
	je	.Lhrdbfw_1308
.Lhrdbfw_1298:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.Lhrdbfw_1308:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1365:
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1306
.Lhrdbfw_1362:
	leaq	.Lhrdbfw_C53(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	128(%rsp), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C54(%rip), %rdx
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
	leaq	.Lhrdbfw_C55(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$1, %eax
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1363:
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
	jmp	.Lhrdbfw_1260
.Lhrdbfw_1309:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1298
.Lhrdbfw_1364:
	leaq	.Lhrdbfw_C57(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	leal	-1(%rsi), %ebx
	call	hrdbfw_local_dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_ddec
	leaq	.Lhrdbfw_C60(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movq	56(%rsp), %rax
	leal	1(%rsi), %edx
	movq	%r12, %rcx
	salq	$4, %rdx
	leaq	10(%rax,%rdx), %rdx
	call	hrdbfw_local_dname
	movl	40(%rsp), %eax
	leaq	.Lhrdbfw_C22(%rip), %rdx
	leaq	.Lhrdbfw_C23(%rip), %rcx
	cmpl	$4, %eax
	cmove	%rcx, %rdx
	jmp	.Lhrdbfw_1304
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
	ja	.Lhrdbfw_1368
	je	.Lhrdbfw_1399
	cmpl	$5, %edx
	je	.Lhrdbfw_1372
	shrq	$8, %rax
	jne	.Lhrdbfw_1368
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_1368
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_1368
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1368
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_1368
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
	ja	.Lhrdbfw_1386
	testq	%rcx, %rcx
	je	.Lhrdbfw_1386
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_1400
.Lhrdbfw_1374:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_1368:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1399:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_1368
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_1368
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_1386
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_1386
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1368
.Lhrdbfw_1386:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1372:
	testq	%rax, %rax
	jns	.Lhrdbfw_1381
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1368
.Lhrdbfw_1381:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1400:
	testb	$3, %r9b
	jne	.Lhrdbfw_1374
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_1375
	addl	$1, %eax
	jmp	.Lhrdbfw_1374
.Lhrdbfw_1375:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_1374
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_1401
	leaq	hrdbfw_local_CSWTCH.394(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_1401:
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
	jne	.Lhrdbfw_1406
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_1417
	testl	%edx, %edx
	je	.Lhrdbfw_1409
	cmpl	$9, %edx
	je	.Lhrdbfw_1409
	movl	$1, %eax
.Lhrdbfw_1406:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1417:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1418
.Lhrdbfw_1409:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1418:
	movl	$2, %eax
	jmp	.Lhrdbfw_1406
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
	jne	.Lhrdbfw_1419
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1419
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.Lhrdbfw_1421
	cmpl	$11, %r14d
	jne	.Lhrdbfw_1421
.Lhrdbfw_1432:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbfw_1419:
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
.Lhrdbfw_1421:
	cmpl	$1, %r15d
	je	.Lhrdbfw_1435
	cmpl	$1, %r14d
	je	.Lhrdbfw_1435
	cmpl	$3, %r15d
	jne	.Lhrdbfw_1424
	cmpl	$3, %r14d
	jne	.Lhrdbfw_1424
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1419
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1435:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1419
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1424:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1428
	cmpl	$12, %r15d
	je	.Lhrdbfw_1458
	testl	%r15d, %r15d
	je	.Lhrdbfw_1427
	cmpl	$9, %r15d
	jne	.Lhrdbfw_1428
.Lhrdbfw_1427:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1428
	cmpl	$12, %r14d
	je	.Lhrdbfw_1459
	testl	%r14d, %r14d
	je	.Lhrdbfw_1432
	cmpl	$9, %r14d
	je	.Lhrdbfw_1432
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1428:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1460
.Lhrdbfw_1434:
	movl	$1, %eax
	jmp	.Lhrdbfw_1419
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1458:
	testl	$65280, %r11d
	je	.Lhrdbfw_1427
	jmp	.Lhrdbfw_1428
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1460:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1434
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbfw_1419
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1459:
	testl	$65280, %edi
	je	.Lhrdbfw_1432
	jmp	.Lhrdbfw_1428
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
	jne	.Lhrdbfw_1461
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.Lhrdbfw_1482
.Lhrdbfw_1461:
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
.Lhrdbfw_1482:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1463
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1483
	testl	%eax, %eax
	je	.Lhrdbfw_1465
	cmpl	$9, %eax
	je	.Lhrdbfw_1465
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1463:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.Lhrdbfw_1484
.Lhrdbfw_1471:
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
.Lhrdbfw_1484:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1471
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.Lhrdbfw_1472
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.Lhrdbfw_1472:
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1461
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1483:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1463
.Lhrdbfw_1465:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1463
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.Lhrdbfw_1485
	testl	%edx, %edx
	je	.Lhrdbfw_1468
	cmpl	$9, %edx
	jne	.Lhrdbfw_1463
.Lhrdbfw_1468:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.Lhrdbfw_1461
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1485:
	testl	$65280, %esi
	je	.Lhrdbfw_1468
	jmp	.Lhrdbfw_1463
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
	jne	.Lhrdbfw_1486
	movzbl	%r11b, %ecx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_1490
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbfw_1488
	andl	$2, %edx
	jne	.Lhrdbfw_1492
.Lhrdbfw_1490:
	movl	$1, %eax
.Lhrdbfw_1486:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1488:
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
.Lhrdbfw_1492:
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
	jne	.Lhrdbfw_1493
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_1540
	cmpl	$12, %eax
	jne	.Lhrdbfw_1519
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
.Lhrdbfw_1501:
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
	ja	.Lhrdbfw_1501
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_1541
	movl	$1, %r9d
.Lhrdbfw_1502:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_1503:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_1504
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_1542
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_1512
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1511:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_1511
.Lhrdbfw_1512:
	testq	%r13, %r13
	jns	.Lhrdbfw_1510
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_1510:
	testl	%r9d, %r9d
	je	.Lhrdbfw_1513
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_1515
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1523:
	movl	%edx, %eax
.Lhrdbfw_1515:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1514
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1514:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_1523
	addl	%r9d, %r10d
.Lhrdbfw_1513:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1493
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1517:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1516
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1516:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_1517
.Lhrdbfw_1493:
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
.Lhrdbfw_1540:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_1504
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_1499
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
	jmp	.Lhrdbfw_1493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1519:
	movl	$1, %r12d
	jmp	.Lhrdbfw_1493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1543:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_1518
.Lhrdbfw_1498:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_1493
.Lhrdbfw_1499:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1543
.Lhrdbfw_1518:
	movl	$47, %eax
	jmp	.Lhrdbfw_1498
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1541:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1502
	movl	%r9d, %eax
	jmp	.Lhrdbfw_1503
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1504:
	movl	$3, %r12d
	jmp	.Lhrdbfw_1493
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1542:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1493
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1507:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_1507
	jmp	.Lhrdbfw_1493
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
	jne	.Lhrdbfw_1544
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1544
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.Lhrdbfw_1584
	cmpl	$42, %ebx
	je	.Lhrdbfw_1584
	cmpl	$47, %ebx
	je	.Lhrdbfw_1559
	cmpl	$37, %ebx
	je	.Lhrdbfw_1586
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.Lhrdbfw_1586
.Lhrdbfw_1544:
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
.Lhrdbfw_1584:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1559
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1606
	testl	%eax, %eax
	je	.Lhrdbfw_1550
	cmpl	$9, %eax
	je	.Lhrdbfw_1550
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1559:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1544
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1544
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.Lhrdbfw_1607
	testl	%r13d, %r13d
	je	.Lhrdbfw_1608
	cmpl	$42, %ebx
	je	.Lhrdbfw_1609
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1585
	jne	.Lhrdbfw_1585
	movl	$5, %r8d
	jmp	.Lhrdbfw_1544
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1606:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1559
.Lhrdbfw_1550:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1559
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.Lhrdbfw_1610
	testl	%eax, %eax
	je	.Lhrdbfw_1553
	cmpl	$9, %eax
	jne	.Lhrdbfw_1559
.Lhrdbfw_1553:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.Lhrdbfw_1611
	testl	%r13d, %r13d
	je	.Lhrdbfw_1612
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1544
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1586:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1544
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.Lhrdbfw_1544
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.Lhrdbfw_1568
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1569
	jne	.Lhrdbfw_1569
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.Lhrdbfw_1544
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1610:
	testl	$65280, %edi
	je	.Lhrdbfw_1553
	jmp	.Lhrdbfw_1559
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1609:
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
.Lhrdbfw_1562:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1544
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1585:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1562
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1607:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.Lhrdbfw_1605:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.Lhrdbfw_1562
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1608:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.Lhrdbfw_1605
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1611:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1544
.Lhrdbfw_1568:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabs	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.Lhrdbfw_1613
	testq	%r10, %r10
	jne	.Lhrdbfw_1578
.Lhrdbfw_1573:
	movabs	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.Lhrdbfw_1571
	testq	%r9, %r9
	movl	$0, %edx
	movabs	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1571:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.Lhrdbfw_1544
.Lhrdbfw_1612:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.Lhrdbfw_1544
.Lhrdbfw_1569:
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
	jmp	.Lhrdbfw_1571
.Lhrdbfw_1613:
	testq	%r10, %r10
	je	.Lhrdbfw_1573
	movabs	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1574
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.Lhrdbfw_1581
	jne	.Lhrdbfw_1581
.Lhrdbfw_1574:
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
	ja	.Lhrdbfw_1571
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.Lhrdbfw_1571
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.Lhrdbfw_1571
.Lhrdbfw_1578:
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
	jmp	.Lhrdbfw_1571
.Lhrdbfw_1581:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.Lhrdbfw_1571
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
	je	.Lhrdbfw_1614
	ja	.Lhrdbfw_1616
	leaq	.Lhrdbfw_C69(%rip), %rax
	cmpl	$1, %ecx
	je	.Lhrdbfw_1614
	leaq	.Lhrdbfw_C72(%rip), %rax
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1627
.Lhrdbfw_1614:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1627:
	testl	%ecx, %ecx
	leaq	.Lhrdbfw_C70(%rip), %rdx
	leaq	.Lhrdbfw_C67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1616:
	leaq	.Lhrdbfw_C71(%rip), %rax
	cmpl	$4, %ecx
	je	.Lhrdbfw_1614
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
	ja	.Lhrdbfw_1631
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.Lhrdbfw_1631
	movabs	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.Lhrdbfw_1726
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.Lhrdbfw_1635:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.Lhrdbfw_1642
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1641:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1643:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_1643
	testq	%rax, %rax
	je	.Lhrdbfw_1644
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.Lhrdbfw_1644:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.Lhrdbfw_1641
	testb	%r12b, %r12b
	je	.Lhrdbfw_1642
	movl	%r9d, 544(%rsp)
.Lhrdbfw_1642:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.Lhrdbfw_1647
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shl
	movl	544(%rsp), %edi
.Lhrdbfw_1648:
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_1654
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1655:
	cmpq	$48, %r12
	je	.Lhrdbfw_1727
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbfw_1654:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.Lhrdbfw_1655
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1655
	testl	%r12d, %r12d
	jne	.Lhrdbfw_1728
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.Lhrdbfw_1660:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.Lhrdbfw_1663
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1729:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.Lhrdbfw_1663:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1729
	testl	%r13d, %r13d
	je	.Lhrdbfw_1664
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1666:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1665:
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
	jne	.Lhrdbfw_1665
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbfw_1730
	movq	%rax, %r12
	jmp	.Lhrdbfw_1666
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1631:
	xorl	%eax, %eax
.Lhrdbfw_1628:
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
.Lhrdbfw_1726:
	testq	%rax, %rax
	jne	.Lhrdbfw_1731
	cmpq	$0, 40(%rsp)
	jne	.Lhrdbfw_1732
	xorl	%edx, %edx
.Lhrdbfw_1636:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1637
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.Lhrdbfw_1631
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1639:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.Lhrdbfw_1639
	addl	%ebx, %eax
	jmp	.Lhrdbfw_1628
.Lhrdbfw_1732:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1631
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.Lhrdbfw_1636
.Lhrdbfw_1647:
	negl	%edx
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.Lhrdbfw_1733
	cmpl	$2, %eax
	jne	.Lhrdbfw_1648
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.Lhrdbfw_1648
	testl	%edi, %edi
	je	.Lhrdbfw_1681
.Lhrdbfw_1651:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.Lhrdbfw_1653
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1734:
	movl	(%rcx), %edx
.Lhrdbfw_1653:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.Lhrdbfw_1734
	testq	%rax, %rax
	je	.Lhrdbfw_1648
	movl	%edi, %eax
	addl	$1, %edi
.Lhrdbfw_1650:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.Lhrdbfw_1648
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1730:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.Lhrdbfw_1664:
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
	ja	.Lhrdbfw_1631
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.Lhrdbfw_1669
	movb	$45, (%rsi)
	movl	$1, %edx
.Lhrdbfw_1669:
	cmpl	%edi, %ebx
	jnb	.Lhrdbfw_1670
	testl	%eax, %eax
	je	.Lhrdbfw_1686
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1672:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1672
.Lhrdbfw_1671:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1628
.Lhrdbfw_1673:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.Lhrdbfw_1674
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1675:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_1675
	addl	%ebx, %edx
.Lhrdbfw_1674:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1676:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1676
	jmp	.Lhrdbfw_1628
.Lhrdbfw_1727:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.Lhrdbfw_1658:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1661:
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
	ja	.Lhrdbfw_1661
	jmp	.Lhrdbfw_1660
.Lhrdbfw_1731:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.Lhrdbfw_1635
.Lhrdbfw_1637:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.Lhrdbfw_1631
	movb	$48, (%rsi,%rdx)
	jmp	.Lhrdbfw_1628
.Lhrdbfw_1670:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbfw_1673
.Lhrdbfw_1733:
	testl	%edi, %edi
	je	.Lhrdbfw_1680
	movl	256(%rsp), %edx
	jmp	.Lhrdbfw_1651
.Lhrdbfw_1686:
	movl	%edx, %eax
	jmp	.Lhrdbfw_1671
.Lhrdbfw_1681:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.Lhrdbfw_1650
.Lhrdbfw_1680:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.Lhrdbfw_1650
.Lhrdbfw_1728:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.Lhrdbfw_1658
	.p2align 4
	.globl	hrdbf_fmt_harbour
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1736
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1736:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1737
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.Lhrdbfw_1739
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1740:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrdbfw_1740
	movzbl	12(%rdx), %eax
.Lhrdbfw_1739:
	cmpq	%rax, %r9
	jnb	.Lhrdbfw_1742
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1741:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1741
.Lhrdbfw_1742:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1737:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1751
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1751:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1753
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1753:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.Lhrdbfw_1774
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.Lhrdbfw_1777
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
	ja	.Lhrdbfw_1774
	cmpl	$9999, %r8d
	jbe	.Lhrdbfw_1774
	testl	%r11d, %r11d
	je	.Lhrdbfw_1774
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.Lhrdbfw_1758
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.Lhrdbfw_1760
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.Lhrdbfw_1760:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.Lhrdbfw_1754
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
.Lhrdbfw_1754:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1777:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1757:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1757
	xorl	%r10d, %r10d
.Lhrdbfw_1774:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1758:
	movl	$28, %edx
	testb	$3, %bl
	jne	.Lhrdbfw_1760
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.Lhrdbfw_1760
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.Lhrdbfw_1760
	.p2align 4
	.globl	hrdbf_write_logical
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1778
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1778:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.Lhrdbfw_1790
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbfw_1789
.Lhrdbfw_1790:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1788
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1787:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1787
.Lhrdbfw_1788:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1789:
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
	je	.Lhrdbfw_1801
	movq	$0, 2280(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1808
.Lhrdbfw_1801:
	xorl	%r12d, %r12d
.Lhrdbfw_1800:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1798
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1803
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.Lhrdbfw_1798:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1808:
	movl	$7, %r12d
	jmp	.Lhrdbfw_1800
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1803:
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
	cmpl	$1, %r8d
	movb	$0, hrdbfw_local_fsink(%rip)
	sete	%al
	movl	%r8d, 48(%rsp)
	leaq	2264(%r12), %r8
	movb	$0, 2288(%r12)
	movl	%eax, 2272(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.Lhrdbfw_1810
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	2288(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_1811
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1813:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_1812
.Lhrdbfw_1811:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1813
.Lhrdbfw_1812:
	movb	$0, (%rdx)
.Lhrdbfw_1815:
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
.Lhrdbfw_1810:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_1815
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
	je	.Lhrdbfw_1826
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1836
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1826
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1840
	cmpb	$78, %al
	je	.Lhrdbfw_1841
	cmpb	$68, %al
	je	.Lhrdbfw_1835
	movzbl	60(%rsp), %eax
.Lhrdbfw_1825:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1840:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1842
.Lhrdbfw_1828:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1843
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1826:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1836:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1825
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1841:
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
.Lhrdbfw_1835:
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
.Lhrdbfw_1842:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1831
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1830:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1830
.Lhrdbfw_1831:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1828
.Lhrdbfw_1843:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C76:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C77:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C78:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbfw_C79:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,110,111,32,114,101,99,111,114,100,32,112,111,115,105,116,105,111,110,101,100,10,0
	.text
	.p2align 4
hrdbf_app_require_writable:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1850
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1851
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1852
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_1853
	addq	$40, %rsp
	ret
.Lhrdbfw_1850:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1853:
	leaq	.Lhrdbfw_C79(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1852:
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1851:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C80:

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
	leaq	.Lhrdbfw_C80(%rip), %rdx
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
	je	.Lhrdbfw_1876
	movq	$0, 2280(%r12)
	call CloseHandle
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1860
	testq	%rcx, %rcx
	je	.Lhrdbfw_1856
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1856
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
.Lhrdbfw_1860:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1859
.Lhrdbfw_1858:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1874
.Lhrdbfw_1856:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1876:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1858
.Lhrdbfw_1859:
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
.Lhrdbfw_1874:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.Lhrdbfw_1859
	.p2align 4
	.globl	hrdbf_file_write_record
hrdbf_file_write_record:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1881
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1881
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1881
	testq	%rdx, %rdx
	je	.Lhrdbfw_1882
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.Lhrdbfw_1884
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1881:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1882:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1884:
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
	je	.Lhrdbfw_1885
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1885
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1885
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1885:
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
	je	.Lhrdbfw_1892
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1897:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1910
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1896
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1894:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1910
.Lhrdbfw_1896:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1894
	jnb	.Lhrdbfw_1910
	leal	1(%r10), %r11d
.Lhrdbfw_1893:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1897
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1901
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1900:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1902
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1903
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1935:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1902
.Lhrdbfw_1903:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1935
.Lhrdbfw_1901:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1891
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1936
	movl	%r11d, %r9d
.Lhrdbfw_1891:
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
.Lhrdbfw_1910:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1893
.Lhrdbfw_1902:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1891
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1904
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1909:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1905
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1908
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1906:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1905
.Lhrdbfw_1908:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1906
	jb	.Lhrdbfw_1905
	movl	%r9d, %r10d
.Lhrdbfw_1907:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1909
.Lhrdbfw_1904:
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
.Lhrdbfw_1905:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1907
.Lhrdbfw_1936:
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
.Lhrdbfw_1892:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1891
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1900
	.section .rdata,"dr"
.Lhrdbfw_C81:

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
	je	.Lhrdbfw_1942
	movq	$0, hrdbf_app_state+2280(%rip)
	call CloseHandle
	testl	%eax, %eax
	jne	.Lhrdbfw_1942
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1943
	movl	$7, %esi
	jmp	.Lhrdbfw_1939
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1942:
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1952
.Lhrdbfw_1940:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1945
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1952:
	xorl	%esi, %esi
.Lhrdbfw_1939:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1943
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%esi, %ebx
	movq	$0, hrdbf_app_state+2264(%rip)
	jmp	.Lhrdbfw_1940
.Lhrdbfw_1943:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	$0, hrdbf_app_shared(%rip)
.Lhrdbfw_1945:
	leaq	.Lhrdbfw_C81(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C82:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,0
	.align 8
.Lhrdbfw_C83:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,116,97,98,108,101,32,118,101,114,115,105,111,110,32,111,114,32,104,101,97,100,101,114,32,102,108,97,103,115,0
.Lhrdbfw_C84:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,102,105,101,108,100,32,116,121,112,101,0
.Lhrdbfw_C85:

.byte 114,101,99,111,114,100,32,99,111,110,116,101,110,116,32,105,110,118,97,108,105,100,0
.Lhrdbfw_C86:

.byte 73,47,79,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C87:

.byte 115,105,122,101,32,111,114,32,102,105,101,108,100,45,99,111,117,110,116,32,108,105,109,105,116,32,101,120,99,101,101,100,101,100,0
.Lhrdbfw_C88:

.byte 116,97,98,108,101,32,102,111,114,109,97,116,32,110,111,116,32,115,117,112,112,111,114,116,101,100,0
	.align 8
.Lhrdbfw_C89:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C90:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C91:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C92:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C93:

.byte 104,98,99,58,32,68,66,70,32,111,112,101,110,32,109,111,100,101,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
.Lhrdbfw_C94:

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
	je	.Lhrdbfw_1954
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_2024
.Lhrdbfw_1954:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_2025
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1955
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1990:
	movq	%rsi, %rbx
.Lhrdbfw_1955:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2026
	leaq	1(%rbx), %rsi
	movb	%al, 64(%rsp,%rbx)
	leaq	64(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_1990
	movb	$0, 64(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2027
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%r13, %r13
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	movq	$0, hrdbf_app_pos(%rip)
	movl	$0, hrdbf_app_struct(%rip)
	movl	%eax, hrdbf_app_cdx(%rip)
	cmpq	$2, %rbp
	ja	.Lhrdbfw_2028
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1961
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1959:
	cmpq	%r8, %rbx
	je	.Lhrdbfw_2029
.Lhrdbfw_1961:
	movzbl	(%rdi,%rdx), %ecx
	movq	%rdx, %r8
	addq	$1, %rdx
	cmpb	$47, %cl
	je	.Lhrdbfw_2001
	cmpb	$92, %cl
	jne	.Lhrdbfw_1959
.Lhrdbfw_2001:
	movq	%rdx, %rax
	cmpq	%r8, %rbx
	jne	.Lhrdbfw_1961
.Lhrdbfw_2029:
	cmpq	%rsi, %rax
	jb	.Lhrdbfw_1964
	jmp	.Lhrdbfw_2030
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1991:
	movq	%rdx, %rax
.Lhrdbfw_1964:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_1991
	movq	%rsi, hrdbf_app_baselen(%rip)
	testq	%rsi, %rsi
	je	.Lhrdbfw_1965
.Lhrdbfw_1988:
	xorl	%edx, %edx
	leaq	hrdbf_app_basename(%rip), %r9
	jmp	.Lhrdbfw_1967
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2031:
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jbe	.Lhrdbfw_1965
.Lhrdbfw_1967:
	movzbl	(%rdi,%rdx), %eax
	cmpb	$92, %al
	jne	.Lhrdbfw_2031
	movl	$47, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	ja	.Lhrdbfw_1967
.Lhrdbfw_1965:
	leaq	hrdbf_app_state(%rip), %rcx
	movb	$0, hrdbf_app_state+2288(%rip)
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_2032
.Lhrdbfw_1968:
	leaq	hrdbf_app_state+2288(%rip), %r12
	cmpb	$0, hrdbf_app_state+2288(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_1971
	leaq	.Lhrdbfw_C86(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_1971
	leaq	.Lhrdbfw_C82(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_1971
	leaq	.Lhrdbfw_C87(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_1971
	leaq	.Lhrdbfw_C83(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_1971
	leaq	.Lhrdbfw_C84(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_1971
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C85(%rip), %r12
	leaq	.Lhrdbfw_C88(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_1971:
	leaq	.Lhrdbfw_C94(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C80(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2032:
	movl	%ebp, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1968
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1953
	leaq	4(%rsi), %rax
	cmpq	$259, %rax
	jbe	.Lhrdbfw_2033
.Lhrdbfw_1953:
	addq	$872, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.Lhrdbfw_2033:
	movb	$46, 64(%rsp,%rsi)
	movzbl	64(%rsp), %eax
	movb	$99, 65(%rsp,%rsi)
	movb	$100, 66(%rsp,%rsi)
	movb	$120, 67(%rsp,%rsi)
	movb	$0, 68(%rsp,%rsi)
	testb	%al, %al
	je	.Lhrdbfw_1976
	cmpb	$92, %al
	je	.Lhrdbfw_2034
	cmpb	$47, %al
	je	.Lhrdbfw_1980
.Lhrdbfw_1979:
	leaq	336(%rsp), %r13
	movq	%r12, %rcx
	movq	%r13, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.Lhrdbfw_1976
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
	je	.Lhrdbfw_2035
	call CloseHandle
.Lhrdbfw_1976:
	cmpq	$1, %rbp
	je	.Lhrdbfw_2036
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1985
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_1953
.Lhrdbfw_2030:
	movq	%rsi, hrdbf_app_baselen(%rip)
	jmp	.Lhrdbfw_1988
.Lhrdbfw_2035:
	call GetLastError
	subl	$2, %eax
	cmpl	$1, %eax
	jbe	.Lhrdbfw_1953
	jmp	.Lhrdbfw_1976
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1980:
	cmpb	$47, 65(%rsp)
	jne	.Lhrdbfw_1979
	jmp	.Lhrdbfw_1976
.Lhrdbfw_1985:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1986
	movl	$1, %edx
	movq	%r12, %rcx
	call	hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_1986
.Lhrdbfw_1987:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_1953
.Lhrdbfw_2034:
	cmpb	$92, 65(%rsp)
	jne	.Lhrdbfw_1979
	jmp	.Lhrdbfw_1976
.Lhrdbfw_2036:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.Lhrdbfw_1953
.Lhrdbfw_1986:
	movl	$3, %eax
	jmp	.Lhrdbfw_1987
.Lhrdbfw_2026:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2028:
	leaq	.Lhrdbfw_C93(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2027:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2025:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2024:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2047
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2039
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.Lhrdbfw_2040
.Lhrdbfw_2039:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2040:
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2042
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
.Lhrdbfw_2043:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2042:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
	jmp	.Lhrdbfw_2043
.Lhrdbfw_2047:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2059
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2050
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2050
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_2060
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_2054:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_2055:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2060:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_2054
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_2055
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2050:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_2059:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2079
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_2063
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2063
	testq	%rcx, %rcx
	je	.Lhrdbfw_2061
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.Lhrdbfw_2066
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.Lhrdbfw_2072
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.Lhrdbfw_2067:
	movq	%rdx, hrdbf_app_pos(%rip)
.Lhrdbfw_2068:
	cmpq	%rax, %rdx
	jnb	.Lhrdbfw_2070
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.Lhrdbfw_2071:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
.Lhrdbfw_2061:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2063:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2072:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.Lhrdbfw_2067
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2070:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_2071
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2066:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.Lhrdbfw_2069
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.Lhrdbfw_2068
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2069:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.Lhrdbfw_2068
.Lhrdbfw_2079:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C95:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C96:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C97:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C98:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C99:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,109,97,105,110,116,101,110,97,110,99,101,41,10,0
	.align 8
.Lhrdbfw_C100:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,112,114,101,115,101,110,116,32,98,117,116,32,110,111,116,32,97,100,109,105,116,116,101,100,32,40,111,110,101,32,116,97,103,44,32,115,117,98,115,101,116,44,32,115,105,122,101,32,111,114,32,102,111,114,109,97,116,41,10,0
	.align 8
.Lhrdbfw_C101:

.byte 104,98,99,58,32,115,116,114,117,99,116,117,114,97,108,32,67,68,88,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbfw_C102:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,32,97,32,115,104,97,114,101,100,61,46,84,46,32,111,112,101,110,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,32,40,105,110,100,101,120,32,108,111,99,107,32,112,114,111,116,111,99,111,108,41,10,0
	.align 8
.Lhrdbfw_C103:

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
	je	.Lhrdbfw_2137
	leaq	-1(%rdx), %rax
	movq	%rdx, %r10
	cmpq	$254, %rax
	ja	.Lhrdbfw_2138
	movq	%rcx, %r9
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	jmp	.Lhrdbfw_2082
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2084:
	cmpq	%rcx, %r10
	je	.Lhrdbfw_2139
.Lhrdbfw_2107:
	movq	%rcx, %rdx
.Lhrdbfw_2082:
	movzbl	(%r9,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2140
	movb	%al, 32(%rsp,%rdx)
	leaq	32(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.Lhrdbfw_2113
	cmpb	$92, %al
	jne	.Lhrdbfw_2084
.Lhrdbfw_2113:
	movq	%rcx, %r8
	cmpq	%rcx, %r10
	jne	.Lhrdbfw_2107
.Lhrdbfw_2139:
	movq	%rcx, %rax
	xorl	%r10d, %r10d
	cmpq	%rcx, %r8
	jnb	.Lhrdbfw_2086
	movl	$1, %ebx
	jmp	.Lhrdbfw_2088
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2109:
	movq	%r11, %r8
.Lhrdbfw_2088:
	cmpb	$46, (%r9,%r8)
	leaq	1(%r8), %r11
	cmove	%r8, %rax
	cmove	%ebx, %r10d
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_2109
.Lhrdbfw_2086:
	movl	hrdbf_app_cdx(%rip), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_2141
.Lhrdbfw_2089:
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2142
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2143
	testl	%r10d, %r10d
	je	.Lhrdbfw_2144
	movb	$0, 32(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2100
.Lhrdbfw_2149:
	movl	%r13d, %edx
	movq	%r12, %rcx
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2100
.Lhrdbfw_2101:
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
.Lhrdbfw_2141:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.Lhrdbfw_2089
	testq	%rax, %rax
	je	.Lhrdbfw_2090
	movl	$1, %ebx
	xorl	%r11d, %r11d
	leaq	hrdbf_app_basename(%rip), %r14
	xorl	%ebp, %ebp
	jmp	.Lhrdbfw_2093
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2146:
	leal	-97(%r8), %edi
	leal	-32(%r8), %esi
	cmpb	$26, %dil
	cmovb	%esi, %r8d
	cmpb	%r8b, (%r14,%r11)
	cmovne	%ebp, %ebx
	addq	$1, %r11
	cmpq	%rax, %r11
	je	.Lhrdbfw_2145
.Lhrdbfw_2093:
	movzbl	(%r9,%r11), %r8d
	cmpb	$92, %r8b
	jne	.Lhrdbfw_2146
	movl	$47, %r8d
	cmpb	%r8b, (%r14,%r11)
	cmovne	%ebp, %ebx
	addq	$1, %r11
	cmpq	%rax, %r11
	jne	.Lhrdbfw_2093
.Lhrdbfw_2145:
	testl	%ebx, %ebx
	je	.Lhrdbfw_2089
.Lhrdbfw_2090:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.Lhrdbfw_2101
	cmpl	$2, %eax
	je	.Lhrdbfw_2147
	cmpl	$3, %eax
	je	.Lhrdbfw_2148
	cmpl	$4, %eax
	jne	.Lhrdbfw_2089
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2144:
	cmpl	$1, %r13d
	movb	$46, 32(%rsp,%rcx)
	sbbl	%ecx, %ecx
	movb	$120, 36(%rsp,%rdx)
	andl	$11, %ecx
	addl	$99, %ecx
	cmpl	$1, %r13d
	sbbl	%eax, %eax
	movb	%cl, 34(%rsp,%rdx)
	leaq	5(%rdx), %rcx
	andl	$16, %eax
	addl	$100, %eax
	movb	%al, 35(%rsp,%rdx)
	movb	$0, 32(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	je	.Lhrdbfw_2149
.Lhrdbfw_2100:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_2114
	leaq	.Lhrdbfw_C95(%rip), %rcx
	cmpl	$3, %eax
	je	.Lhrdbfw_2102
.Lhrdbfw_2114:
	leaq	.Lhrdbfw_C96(%rip), %rcx
.Lhrdbfw_2102:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2140:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2148:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2147:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2138:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2137:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2143:
	leaq	.Lhrdbfw_C103(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2142:
	leaq	.Lhrdbfw_C102(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2176
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_2177
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	movq	hrdbf_app_order+32(%rip), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_2156
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_2178
.Lhrdbfw_2153:
	xorl	%edx, %edx
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_2157
	movq	hrdbf_app_order+40(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_2158
.Lhrdbfw_2154:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_2158
.Lhrdbfw_2179:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_2159:
	testl	%esi, %esi
	jne	.Lhrdbfw_2158
.Lhrdbfw_2155:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2156:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2153
.Lhrdbfw_2174:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2155
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_2179
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2158:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2177:
	movq	hrdbf_app_order+32(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2153
	jmp	.Lhrdbfw_2174
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2157:
	movq	hrdbf_app_order+40(%rip), %rcx
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2154
	jmp	.Lhrdbfw_2159
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2178:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2154
	jmp	.Lhrdbfw_2158
.Lhrdbfw_2176:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2185
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_2185:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C104:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2193
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2188
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2188
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
	jb	.Lhrdbfw_2194
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_2191:
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
.Lhrdbfw_2194:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_2191
.Lhrdbfw_2188:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2193:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C105:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,101,120,112,101,99,116,115,32,97,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,118,97,108,117,101,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek_dyn
hrdbfw_app_seek_dyn:
	pushq	%r12
	pushq	%rbx
	subq	$344, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2233
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2197
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2197
	movq	%rcx, %rax
	movq	%rdx, %rcx
	movq	%r8, %rbx
	movzbl	%al, %edx
	leal	-2(%rdx), %r8d
	andl	$-3, %r8d
	je	.Lhrdbfw_2234
	testl	%edx, %edx
	je	.Lhrdbfw_2212
	cmpl	$9, %edx
	je	.Lhrdbfw_2212
	cmpl	$5, %edx
	je	.Lhrdbfw_2235
	cmpl	$12, %edx
	je	.Lhrdbfw_2236
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
.Lhrdbfw_2234:
	testq	%rcx, %rcx
	je	.Lhrdbfw_2237
	movq	-8(%rcx), %rdx
	addq	$344, %rsp
	movq	%rbx, %r8
	popq	%rbx
	popq	%r12
	jmp	hrdbfw_app_seek
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2236:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rcx, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.Lhrdbfw_2210
	movsd	.Lhrdbfw_C0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2211:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.Lhrdbfw_2211
.Lhrdbfw_2210:
	comisd	.Lhrdbfw_C106(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2212
.Lhrdbfw_2232:
	movsd	.Lhrdbfw_C107(%rip), %xmm1
	addq	$1, %rcx
	comisd	%xmm0, %xmm1
	jbe	.Lhrdbfw_2238
.Lhrdbfw_2212:
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
.Lhrdbfw_2235:
	testq	%rax, %rax
	js	.Lhrdbfw_2239
.Lhrdbfw_2205:
	movq	%rcx, %xmm0
	comisd	.Lhrdbfw_C106(%rip), %xmm0
	movabs	$9223372036854775807, %rcx
	ja	.Lhrdbfw_2212
	jmp	.Lhrdbfw_2232
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2238:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.Lhrdbfw_2240
	addsd	.Lhrdbfw_C108(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2212
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2239:
	movq	(%rcx), %rcx
	jmp	.Lhrdbfw_2205
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2240:
	subsd	.Lhrdbfw_C108(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.Lhrdbfw_2212
.Lhrdbfw_2197:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2233:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2237:
	leaq	.Lhrdbfw_C105(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2246
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_2246:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2252
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_2252:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
hrdbfw_app_fcount:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2258
	movzwl	hrdbf_app_state+36(%rip), %eax
	ret
.Lhrdbfw_2258:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
hrdbfw_app_goto:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2273
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	hrdbf_app_state+16(%rip), %eax
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2261
	cmpq	%rax, %rcx
	jbe	.Lhrdbfw_2262
.Lhrdbfw_2261:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, hrdbf_app_state+24(%rip)
	movw	%cx, hrdbf_app_state+38(%rip)
.Lhrdbfw_2263:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2259
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_2274
.Lhrdbfw_2259:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2262:
	xorl	%edx, %edx
	movq	%rcx, hrdbf_app_state+24(%rip)
	movw	%dx, hrdbf_app_state+38(%rip)
	jmp	.Lhrdbfw_2263
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2274:
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r8
	testl	%ecx, %ecx
	je	.Lhrdbfw_2268
	movq	hrdbf_app_order+16(%rip), %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_2267
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2266:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2265
.Lhrdbfw_2267:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_2266
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2268:
	xorl	%ecx, %ecx
.Lhrdbfw_2265:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.Lhrdbfw_2273:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
hrdbfw_app_ordselect:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2291
	testq	%rcx, %rcx
	jle	.Lhrdbfw_2277
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2292
	cmpq	$1, %rcx
	jne	.Lhrdbfw_2277
	movl	hrdbf_app_order+24(%rip), %ecx
	movq	hrdbf_app_state+24(%rip), %r9
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	hrdbf_app_order+16(%rip), %r8
	testl	%ecx, %ecx
	jne	.Lhrdbfw_2283
	jmp	.Lhrdbfw_2293
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2282:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.Lhrdbfw_2285
.Lhrdbfw_2283:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.Lhrdbfw_2282
	movq	%rax, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2292:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.Lhrdbfw_2294
	cmpl	$3, %eax
	je	.Lhrdbfw_2295
	cmpl	$4, %eax
	je	.Lhrdbfw_2296
.Lhrdbfw_2277:
	movl	$0, hrdbf_app_order_active(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2293:
	xorl	%ecx, %ecx
.Lhrdbfw_2285:
	movq	%rcx, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
.Lhrdbfw_2291:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2294:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2296:
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2295:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2302
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_2302:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2308
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_2308:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2316
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2309
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_2309:
	movq	%r8, %rax
	ret
.Lhrdbfw_2316:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2323
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_2319
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_2320
.Lhrdbfw_2319:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2320:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_2323:
	leaq	.Lhrdbfw_C76(%rip), %rcx
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
	je	.Lhrdbfw_2325
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_2327
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2339:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2328:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2329
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2328
.Lhrdbfw_2329:
	cmpq	%r8, %rax
	je	.Lhrdbfw_2349
.Lhrdbfw_2331:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.Lhrdbfw_2339
.Lhrdbfw_2327:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2349:
	testq	%r8, %r8
	je	.Lhrdbfw_2332
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2336
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2350:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.Lhrdbfw_2332
.Lhrdbfw_2336:
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
	je	.Lhrdbfw_2350
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_2331
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2332:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_2337
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
.Lhrdbfw_2337:
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
.Lhrdbfw_2325:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
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
	pushq	%rdi
	movq	%rdx, %rdi
	pushq	%rsi
	movq	%r8, %rsi
	pushq	%rbx
	movq	%rcx, %rbx
	subq	$32, %rsp
	call	hrdbf_app_require_writable
	testq	%rbx, %rbx
	jle	.Lhrdbfw_2352
	movzwl	hrdbf_app_state+36(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r9
	cmpq	%rbx, %rax
	jl	.Lhrdbfw_2352
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
	je	.Lhrdbfw_2354
	ja	.Lhrdbfw_2355
	cmpb	$67, %al
	je	.Lhrdbfw_2356
	cmpb	$68, %al
	jne	.Lhrdbfw_2358
	cmpl	$11, %r8d
	je	.Lhrdbfw_2413
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2358
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2367
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2378
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2414:
	addq	$1, %rax
.Lhrdbfw_2378:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2414
.Lhrdbfw_2363:
	movq	hrdbf_app_state+24(%rip), %rdx
.Lhrdbfw_2367:
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbfw_2415
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2355:
	cmpb	$78, %al
	jne	.Lhrdbfw_2358
	cmpl	$12, %r8d
	je	.Lhrdbfw_2416
	testl	%r8d, %r8d
	je	.Lhrdbfw_2386
	cmpl	$9, %r8d
	je	.Lhrdbfw_2386
	cmpl	$5, %r8d
	je	.Lhrdbfw_2417
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2358
	addq	$2, %r10
	salq	$4, %r10
	addq	%r10, %r9
	movzbl	22(%r9), %r8d
	movzwl	24(%r9), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2367
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2376
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2418:
	addq	$1, %rax
.Lhrdbfw_2376:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2418
	jmp	.Lhrdbfw_2363
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2356:
	leal	-2(%r8), %eax
	andl	$-3, %eax
	je	.Lhrdbfw_2419
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2358
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2367
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2368
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2420:
	addq	$1, %rax
.Lhrdbfw_2368:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2420
	jmp	.Lhrdbfw_2363
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2354:
	cmpl	$3, %r8d
	je	.Lhrdbfw_2421
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2358
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2367
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2381
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2422:
	addq	$1, %rax
.Lhrdbfw_2381:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2422
	jmp	.Lhrdbfw_2363
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2416:
	movl	%edi, %eax
	movq	%rsi, %r8
	movq	%r11, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.Lhrdbfw_2370:
	cmpl	$3, %eax
	je	.Lhrdbfw_2358
	testl	%eax, %eax
	je	.Lhrdbfw_2363
	leaq	.Lhrdbfw_C111(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2421:
	cmpq	$1, %rsi
	movzwl	24(%rbx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	hrdbf_app_state+24(%rip), %rdx
	jmp	.Lhrdbfw_2367
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2419:
	movzwl	24(%rbx), %eax
	movzbl	22(%rbx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%rsi)
	movq	%rdx, %rax
	cmovbe	-8(%rsi), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2361
	movq	%rcx, %r8
	leaq	(%rsi,%rax), %r11
	subq	%rsi, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2362:
	movzbl	(%rsi), %edx
	movb	%dl, (%r8,%rsi)
	addq	$1, %rsi
	cmpq	%r11, %rsi
	jne	.Lhrdbfw_2362
	movq	%r10, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r9), %edx
.Lhrdbfw_2361:
	cmpq	%rax, %rdx
	jbe	.Lhrdbfw_2363
	leaq	2(%r10), %rdx
	salq	$4, %rdx
	addq	%rdx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2364:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r9), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbfw_2364
	jmp	.Lhrdbfw_2363
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2413:
	movl	%esi, %r8d
	movq	%r11, %rdx
	call	hrdbf_write_date
	jmp	.Lhrdbfw_2370
.Lhrdbfw_2358:
	leaq	.Lhrdbfw_C110(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2386:
	xorl	%r9d, %r9d
	movq	%rsi, %r8
	movq	%r11, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbfw_2370
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2417:
	testq	%rdi, %rdi
	jns	.Lhrdbfw_2374
	movq	(%rsi), %rsi
.Lhrdbfw_2374:
	movq	%rsi, %xmm2
	movq	%r11, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.Lhrdbfw_2370
.Lhrdbfw_2352:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2415:
	leaq	.Lhrdbfw_C112(%rip), %rcx
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
	je	.Lhrdbfw_2424
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2434:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2425:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2426
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2425
.Lhrdbfw_2426:
	cmpq	%r12, %rax
	je	.Lhrdbfw_2447
.Lhrdbfw_2428:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.Lhrdbfw_2434
.Lhrdbfw_2424:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2447:
	testq	%r12, %r12
	je	.Lhrdbfw_2429
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2433
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2448:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_2429
.Lhrdbfw_2433:
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
	je	.Lhrdbfw_2448
	cmpq	%rcx, %r12
	jne	.Lhrdbfw_2428
.Lhrdbfw_2429:
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
.Lhrdbfw_C113:

.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_append
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2457
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2458
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2459
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_2460
	cmpq	$0, hrdbf_app_state+2280(%rip)
	je	.Lhrdbfw_2455
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2455
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2455:
	leaq	.Lhrdbfw_C113(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2457:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2460:
	leaq	.Lhrdbfw_C79(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2459:
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2458:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C114:

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
	jne	.Lhrdbfw_2464
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_2464:
	leaq	.Lhrdbfw_C114(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C115:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C116:

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
	jne	.Lhrdbfw_2466
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_2482
	testl	%eax, %eax
	je	.Lhrdbfw_2474
	cmpl	$9, %eax
	jne	.Lhrdbfw_2470
.Lhrdbfw_2474:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2482:
	testl	$65280, %r11d
	je	.Lhrdbfw_2474
.Lhrdbfw_2469:
	leaq	.Lhrdbfw_C115(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2466:
	cmpl	$2, %eax
	je	.Lhrdbfw_2469
.Lhrdbfw_2470:
	leaq	.Lhrdbfw_C116(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C117:

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
	jne	.Lhrdbfw_2486
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_2486:
	leaq	.Lhrdbfw_C117(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C118:

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
	jne	.Lhrdbfw_2488
	cmpb	$11, %r8b
	je	.Lhrdbfw_2495
.Lhrdbfw_2488:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.Lhrdbfw_2496
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2495:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2490
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2490
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
.Lhrdbfw_2496:
	leaq	.Lhrdbfw_C117(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2490:
	leaq	.Lhrdbfw_C118(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C119:

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
	jne	.Lhrdbfw_2498
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2509
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_2500
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2517:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_2513
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_2509
.Lhrdbfw_2500:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_2517
.Lhrdbfw_2513:
	xorl	%eax, %eax
.Lhrdbfw_2497:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2498:
	cmpl	$8, %ebx
	je	.Lhrdbfw_2518
	cmpl	$5, %ebx
	je	.Lhrdbfw_2519
	cmpl	$7, %ebx
	je	.Lhrdbfw_2513
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2505
	cmpl	$12, %ebx
	ja	.Lhrdbfw_2505
	movl	$1, %eax
	movl	%ebx, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbfw_2506
	testb	$2, %al
	jne	.Lhrdbfw_2509
.Lhrdbfw_2505:
	leaq	.Lhrdbfw_C119(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2509:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2518:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2497
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_2497
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2519:
	testq	%rcx, %rcx
	js	.Lhrdbfw_2520
.Lhrdbfw_2504:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_2497
.Lhrdbfw_2520:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_2504
.Lhrdbfw_2506:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_2497
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C120:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10,0
	.align 8
.Lhrdbfw_C121:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,111,110,32,97,32,78,73,76,32,111,114,32,110,111,110,45,110,117,109,101,114,105,99,32,111,112,101,114,97,110,100,10,0
.Lhrdbfw_C122:

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
	je	.Lhrdbfw_2526
	cmpl	$1, %eax
	je	.Lhrdbfw_2527
	testl	%eax, %eax
	jne	.Lhrdbfw_2528
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.Lhrdbfw_2526:
	leaq	.Lhrdbfw_C120(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2528:
	leaq	.Lhrdbfw_C122(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2527:
	leaq	.Lhrdbfw_C121(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C123:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C123(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.394:
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
.Lhrdbfw_C0:
	.long	0
	.long	1076101120
	.align 8
.Lhrdbfw_C65:
	.long	0
	.long	0
	.align 8
.Lhrdbfw_C106:
	.long	-798530048
	.long	1138748221
	.align 8
.Lhrdbfw_C107:
	.long	-798530048
	.long	-1008735427
	.align 8
.Lhrdbfw_C108:
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
