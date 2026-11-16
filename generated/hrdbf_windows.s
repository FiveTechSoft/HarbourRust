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
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.Lhrdbfw_335
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_336:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.Lhrdbfw_336
.Lhrdbfw_335:
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
	je	.Lhrdbfw_343
	leaq WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.Lhrdbfw_344
	jmp	.Lhrdbfw_345
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_356:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_343
	cmpq	%rax, %rbx
	jb	.Lhrdbfw_343
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.Lhrdbfw_345
.Lhrdbfw_344:
	movq	2280(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.Lhrdbfw_356
.Lhrdbfw_343:
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
.Lhrdbfw_345:
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
	ja	.Lhrdbfw_357
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.Lhrdbfw_437
	cmpb	$78, %r9b
	je	.Lhrdbfw_438
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.Lhrdbfw_439
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.Lhrdbfw_384
	cmpb	$89, %al
	je	.Lhrdbfw_384
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.Lhrdbfw_357
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.Lhrdbfw_357
	movabs	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.Lhrdbfw_357:
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
.Lhrdbfw_384:
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
.Lhrdbfw_438:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.Lhrdbfw_361
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.Lhrdbfw_362
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_363:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.Lhrdbfw_361
.Lhrdbfw_362:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.Lhrdbfw_363
	jmp	.Lhrdbfw_365
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_389:
	movl	%r9d, %ecx
.Lhrdbfw_365:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_364
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.Lhrdbfw_389
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.Lhrdbfw_367
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.Lhrdbfw_387:
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
	jmp	.Lhrdbfw_371
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_441:
	testl	%esi, %esi
	jne	.Lhrdbfw_408
	movl	$1, %esi
.Lhrdbfw_369:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.Lhrdbfw_440
.Lhrdbfw_371:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.Lhrdbfw_441
.Lhrdbfw_408:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbfw_401
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.Lhrdbfw_398
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.Lhrdbfw_369
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.Lhrdbfw_369
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_437:
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
.Lhrdbfw_439:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_380:
	cmpb	$32, (%rax)
	jne	.Lhrdbfw_400
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_380
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_357
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_401:
	movl	$5, %r11d
	jmp	.Lhrdbfw_357
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_400:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_379:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.Lhrdbfw_401
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_379
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
	jbe	.Lhrdbfw_357
	cmpl	$11, %edx
	ja	.Lhrdbfw_357
	testl	%r10d, %r10d
	je	.Lhrdbfw_357
	leaq	hrdbfw_local_days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.Lhrdbfw_442
.Lhrdbfw_382:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.Lhrdbfw_357
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_357
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_367:
	movabs	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.Lhrdbfw_368:
	cmpl	%eax, %ecx
	jbe	.Lhrdbfw_401
	leal	-1(%rcx), %r9d
	jmp	.Lhrdbfw_387
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_398:
	movl	$4, %r11d
	jmp	.Lhrdbfw_357
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_440:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.Lhrdbfw_357
	cmpl	%ebp, %r10d
	jb	.Lhrdbfw_357
	leal	1(%rbp), %eax
	jbe	.Lhrdbfw_372
	movabs	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.Lhrdbfw_373
	jmp	.Lhrdbfw_398
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_374:
	cmpq	%rcx, %rbx
	ja	.Lhrdbfw_398
.Lhrdbfw_373:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.Lhrdbfw_374
	testl	%r12d, %r12d
	jne	.Lhrdbfw_386
.Lhrdbfw_377:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_357
.Lhrdbfw_364:
	je	.Lhrdbfw_361
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.Lhrdbfw_367
	movabs	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_368
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_361:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.Lhrdbfw_357
.Lhrdbfw_442:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.Lhrdbfw_382
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.Lhrdbfw_383
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.Lhrdbfw_382
.Lhrdbfw_383:
	addl	$1, %edx
	jmp	.Lhrdbfw_382
.Lhrdbfw_372:
	testl	%r12d, %r12d
	je	.Lhrdbfw_377
	movabs	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.Lhrdbfw_377
.Lhrdbfw_386:
	negq	%rbx
	jmp	.Lhrdbfw_377
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
	je	.Lhrdbfw_446
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_458
.Lhrdbfw_446:
	xorl	%r12d, %r12d
.Lhrdbfw_445:
	movq	hrdbf_app_order+32(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_447
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_459
	movl	$7, %r12d
.Lhrdbfw_447:
	movq	hrdbf_app_order+40(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_443
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_450
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_443:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_459:
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbfw_447
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_458:
	movl	$7, %r12d
	jmp	.Lhrdbfw_445
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_450:
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
	jne	.Lhrdbfw_460
	orl	%ecx, %eax
	movb	%al, (%rdx)
.Lhrdbfw_460:
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
	ja	.Lhrdbfw_466
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbfw_466
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.Lhrdbfw_466
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.Lhrdbfw_466
	cmpb	$0, 40(%r9)
	je	.Lhrdbfw_466
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_462
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.Lhrdbfw_462
	cmpw	$1, 510(%rdi)
	jne	.Lhrdbfw_462
	cmpb	$0, 512(%rdi)
	jne	.Lhrdbfw_462
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.Lhrdbfw_466
	testl	$511, %r12d
	jne	.Lhrdbfw_466
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_466
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.Lhrdbfw_462
	cmpw	$1, 2(%rdi,%rdx)
	jne	.Lhrdbfw_462
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.Lhrdbfw_466
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.Lhrdbfw_466
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	hrdbfw_local_cxleaf_header
	testl	%eax, %eax
	jne	.Lhrdbfw_462
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
	jne	.Lhrdbfw_462
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_466
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.Lhrdbfw_466
	testl	$511, %eax
	jne	.Lhrdbfw_466
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.Lhrdbfw_466
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbfw_466
	cmpl	%r12d, %eax
	je	.Lhrdbfw_466
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.Lhrdbfw_466
	movabs	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_467
.Lhrdbfw_540:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.Lhrdbfw_504
	addq	$1, %rax
	cmpq	$10, %rax
	je	.Lhrdbfw_539
.Lhrdbfw_467:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.Lhrdbfw_540
.Lhrdbfw_504:
	movl	$2, %eax
	jmp	.Lhrdbfw_462
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_466:
	movl	$1, %eax
.Lhrdbfw_462:
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
.Lhrdbfw_539:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	hrdbfw_local_cxheader
	testl	%eax, %eax
	jne	.Lhrdbfw_462
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.Lhrdbfw_504
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.Lhrdbfw_504
	cmpb	$0, (%rdi,%rcx)
	jne	.Lhrdbfw_504
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.Lhrdbfw_468:
	cmpb	$0, (%r14,%rcx)
	je	.Lhrdbfw_504
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.Lhrdbfw_468
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.Lhrdbfw_469:
	cmpq	%r9, %r8
	jbe	.Lhrdbfw_504
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.Lhrdbfw_478:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.Lhrdbfw_472
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.Lhrdbfw_473
	subl	$32, %ecx
.Lhrdbfw_473:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.Lhrdbfw_474
	subl	$32, %r13d
.Lhrdbfw_474:
	cmpb	%cl, %r13b
	jne	.Lhrdbfw_472
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.Lhrdbfw_470
	cmpq	$11, %rdx
	jne	.Lhrdbfw_478
	cmpq	$11, %rax
	jne	.Lhrdbfw_472
.Lhrdbfw_476:
	cmpl	%r9d, 72(%rsp)
	je	.Lhrdbfw_504
	cmpb	$67, 53(%r10)
	jne	.Lhrdbfw_504
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.Lhrdbfw_503
	cmpw	12(%rdi,%r11), %ax
	jne	.Lhrdbfw_504
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.Lhrdbfw_508
	cmpq	$0, 1072(%rsp)
	jne	.Lhrdbfw_510
	testl	%eax, %eax
	jne	.Lhrdbfw_508
.Lhrdbfw_510:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.Lhrdbfw_508
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.Lhrdbfw_508
	xorl	%edx, %edx
.Lhrdbfw_480:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_480
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.Lhrdbfw_481
	orl	$1, %eax
	movb	%al, (%rcx)
.Lhrdbfw_481:
	testb	$2, %al
	jne	.Lhrdbfw_482
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.Lhrdbfw_482:
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
.Lhrdbfw_483:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_483
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	hrdbfw_local_cxvisit
	testl	%eax, %eax
	je	.Lhrdbfw_541
.Lhrdbfw_484:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbfw_462
.Lhrdbfw_470:
	cmpq	$11, %rax
	je	.Lhrdbfw_476
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.Lhrdbfw_476
.Lhrdbfw_472:
	addq	$1, %r9
	jmp	.Lhrdbfw_469
.Lhrdbfw_508:
	movl	$3, %eax
	jmp	.Lhrdbfw_462
.Lhrdbfw_503:
	movl	$5, %eax
	jmp	.Lhrdbfw_462
.Lhrdbfw_541:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.Lhrdbfw_484
	xorl	%edx, %edx
	jmp	.Lhrdbfw_486
.Lhrdbfw_542:
	cmpq	$63, %rdx
	ja	.Lhrdbfw_511
.Lhrdbfw_486:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_485
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.Lhrdbfw_485:
	addq	$1, %rdx
	testb	$1, %al
	je	.Lhrdbfw_542
.Lhrdbfw_511:
	testl	%eax, %eax
	jne	.Lhrdbfw_484
	movl	%ecx, 24(%rbx)
	jmp	.Lhrdbfw_462
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
	ja	.Lhrdbfw_543
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call VirtualAlloc
	movq	%rax, %r13
	testq	%rax, %rax
	je	.Lhrdbfw_551
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.Lhrdbfw_548
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_545:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.Lhrdbfw_545
.Lhrdbfw_548:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.Lhrdbfw_547
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_546:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.Lhrdbfw_546
	addq	%r14, %rdx
.Lhrdbfw_547:
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
	je	.Lhrdbfw_563
.Lhrdbfw_549:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call VirtualFree
.Lhrdbfw_543:
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
.Lhrdbfw_563:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_549
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	hrdbfw_local_write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.Lhrdbfw_549
	xorl	%edx, %edx
	movq	2256(%rbx), %rcx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_554
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
	jmp	.Lhrdbfw_543
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_551:
	movl	$8, %r15d
	jmp	.Lhrdbfw_543
.Lhrdbfw_554:
	movl	$7, %r15d
	jmp	.Lhrdbfw_549
	.p2align 4
hrdbfw_local_put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.Lhrdbfw_564
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.Lhrdbfw_585
	subl	%r10d, %edx
	je	.Lhrdbfw_570
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_571:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.Lhrdbfw_571
.Lhrdbfw_570:
	testl	%r10d, %r10d
	je	.Lhrdbfw_569
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_572:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.Lhrdbfw_572
.Lhrdbfw_569:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_564:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_585:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.Lhrdbfw_569
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_568:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.Lhrdbfw_569
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_568
	jmp	.Lhrdbfw_569
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
	ja	.Lhrdbfw_586
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.Lhrdbfw_612
	cmpb	%r8b, %r13b
	jnb	.Lhrdbfw_612
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.Lhrdbfw_588
	negq	%rcx
	movl	$1, %r11d
.Lhrdbfw_588:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_589
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.Lhrdbfw_590
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_591:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.Lhrdbfw_591
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq $1, %r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.Lhrdbfw_592
.Lhrdbfw_590:
	addq	$1, %rcx
.Lhrdbfw_592:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabs	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_597:
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
	ja	.Lhrdbfw_597
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
	ja	.Lhrdbfw_640
	testl	%r11d, %r11d
	je	.Lhrdbfw_603
	movb	$45, 96(%rsp)
.Lhrdbfw_603:
	cmpl	%r10d, %ebp
	jb	.Lhrdbfw_641
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.Lhrdbfw_605:
	testb	%r13b, %r13b
	je	.Lhrdbfw_607
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.Lhrdbfw_608
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_609:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.Lhrdbfw_609
	addl	%ebp, %eax
.Lhrdbfw_608:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_610:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.Lhrdbfw_610
.Lhrdbfw_607:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_586:
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
.Lhrdbfw_612:
	movl	$4, %eax
	jmp	.Lhrdbfw_586
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_589:
	jnb	.Lhrdbfw_592
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.Lhrdbfw_592
	movabs	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_593
	xorl	%eax, %eax
	jmp	.Lhrdbfw_594
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_596:
	cmpq	%rdx, %rcx
	ja	.Lhrdbfw_593
.Lhrdbfw_594:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.Lhrdbfw_596
	jmp	.Lhrdbfw_592
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_641:
	testl	%r14d, %r14d
	je	.Lhrdbfw_616
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.Lhrdbfw_606
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_642:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.Lhrdbfw_606:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.Lhrdbfw_642
	jmp	.Lhrdbfw_605
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_640:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_601:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.Lhrdbfw_601
	xorl	%eax, %eax
	jmp	.Lhrdbfw_586
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_593:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_595:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.Lhrdbfw_595
	xorl	%eax, %eax
	jmp	.Lhrdbfw_586
.Lhrdbfw_616:
	movl	%r11d, %edx
	jmp	.Lhrdbfw_605
	.p2align 4
hrdbfw_local_bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_692
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.Lhrdbfw_695
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.Lhrdbfw_651
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.Lhrdbfw_653
.Lhrdbfw_652:
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_656
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_655:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.Lhrdbfw_696
	movl	%eax, %ecx
.Lhrdbfw_656:
	cmpl	%ecx, %r10d
	jbe	.Lhrdbfw_655
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.Lhrdbfw_655
.Lhrdbfw_654:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.Lhrdbfw_653
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.Lhrdbfw_661
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_660:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.Lhrdbfw_660
.Lhrdbfw_661:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.Lhrdbfw_653
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_662:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_662
.Lhrdbfw_653:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.Lhrdbfw_643
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_663
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_664:
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
	jne	.Lhrdbfw_664
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.Lhrdbfw_643
	movl	%edi, 288(%r9)
	jmp	.Lhrdbfw_643
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_695:
	testl	%r10d, %r10d
	je	.Lhrdbfw_646
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_648:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_648
	testl	%eax, %eax
	je	.Lhrdbfw_646
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_649:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.Lhrdbfw_649
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.Lhrdbfw_646
	jne	.Lhrdbfw_671
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.Lhrdbfw_646
.Lhrdbfw_671:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_646:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.Lhrdbfw_643:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_692:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_651:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.Lhrdbfw_652
	jmp	.Lhrdbfw_654
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_696:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_654
.Lhrdbfw_663:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.Lhrdbfw_643
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
.Lhrdbfw_698:
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
	jbe	.Lhrdbfw_706
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_698
.Lhrdbfw_706:
	leaq	hrdbfw_local_fsink(%rip), %rbx
	movl	hrdbfw_local_fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_704:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.Lhrdbfw_700
	jmp	.Lhrdbfw_701
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_702:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.Lhrdbfw_701
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.Lhrdbfw_700:
	testb	%cl, %cl
	jne	.Lhrdbfw_702
.Lhrdbfw_701:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, hrdbfw_local_fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.Lhrdbfw_697
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_704
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_697:
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
	je	.Lhrdbfw_721
	movabs	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.Lhrdbfw_959
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.Lhrdbfw_719:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_724:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_725:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_725
	testq	%rax, %rax
	je	.Lhrdbfw_726
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.Lhrdbfw_726:
	subl	$1, %r9d
	jne	.Lhrdbfw_724
	testb	%r11b, %r11b
	je	.Lhrdbfw_728
	movl	%r10d, 352(%rsp)
.Lhrdbfw_728:
	testl	%r12d, %r12d
	js	.Lhrdbfw_729
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_956:
	movl	352(%rsp), %eax
.Lhrdbfw_732:
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_730
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_735:
	cmpq	$80, %rbx
	je	.Lhrdbfw_960
	movq	%rdi, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.Lhrdbfw_730:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.Lhrdbfw_735
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.Lhrdbfw_735
	testl	%ebx, %ebx
	jne	.Lhrdbfw_961
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.Lhrdbfw_720
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.Lhrdbfw_962
.Lhrdbfw_721:
	xorl	%eax, %eax
.Lhrdbfw_713:
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
.Lhrdbfw_959:
	testq	%rax, %rax
	jne	.Lhrdbfw_963
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.Lhrdbfw_720
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.Lhrdbfw_721
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_723:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.Lhrdbfw_723
	jmp	.Lhrdbfw_713
.Lhrdbfw_720:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.Lhrdbfw_721
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.Lhrdbfw_713
.Lhrdbfw_963:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.Lhrdbfw_719
.Lhrdbfw_729:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	hrdbfw_local_bn_shr_round
	cmpl	$1, %eax
	jbe	.Lhrdbfw_956
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_828
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.Lhrdbfw_734:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.Lhrdbfw_734
	testq	%rdx, %rdx
	je	.Lhrdbfw_732
	leal	1(%rax), %edx
.Lhrdbfw_733:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.Lhrdbfw_732
.Lhrdbfw_960:
	movl	$79, %r10d
.Lhrdbfw_738:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.Lhrdbfw_742:
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
	ja	.Lhrdbfw_742
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.Lhrdbfw_744
.Lhrdbfw_964:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_744:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.Lhrdbfw_964
	testl	%r10d, %r10d
	je	.Lhrdbfw_745
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.Lhrdbfw_747:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_746:
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
	jne	.Lhrdbfw_746
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.Lhrdbfw_965
	movq	%rax, %rbp
	jmp	.Lhrdbfw_747
.Lhrdbfw_965:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.Lhrdbfw_745:
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
.Lhrdbfw_749:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_750:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_750
	testq	%rax, %rax
	je	.Lhrdbfw_751
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.Lhrdbfw_751:
	subl	$1, %r9d
	jne	.Lhrdbfw_749
	testb	%dil, %dil
	je	.Lhrdbfw_753
	movl	%r10d, 656(%rsp)
.Lhrdbfw_753:
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
	je	.Lhrdbfw_754
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
.Lhrdbfw_755:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_756:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_756
	testq	%rax, %rax
	je	.Lhrdbfw_757
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_757:
	subl	$1, %ebx
	jne	.Lhrdbfw_755
	testb	%bpl, %bpl
	je	.Lhrdbfw_759
	movl	%edi, 960(%rsp)
.Lhrdbfw_759:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
.Lhrdbfw_760:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.Lhrdbfw_767
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.Lhrdbfw_794:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_768:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.Lhrdbfw_768
	cmpb	$53, (%rdi)
	ja	.Lhrdbfw_769
	je	.Lhrdbfw_966
.Lhrdbfw_770:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.Lhrdbfw_967
.Lhrdbfw_772:
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
	je	.Lhrdbfw_776
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_775:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_777:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_777
	testq	%rax, %rax
	je	.Lhrdbfw_778
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.Lhrdbfw_778:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.Lhrdbfw_775
	testb	%r15b, %r15b
	je	.Lhrdbfw_776
	movl	%r9d, 1264(%rsp)
.Lhrdbfw_776:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	hrdbfw_local_bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.Lhrdbfw_781
	jnb	.Lhrdbfw_782
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_783
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_790
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_793:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.Lhrdbfw_968
.Lhrdbfw_790:
	cmpl	$-1, %eax
	jne	.Lhrdbfw_793
.Lhrdbfw_789:
	testb	$1, 40(%rsp)
	je	.Lhrdbfw_948
.Lhrdbfw_783:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.Lhrdbfw_949
	cmpl	%r12d, %ebp
	jb	.Lhrdbfw_794
.Lhrdbfw_949:
	movq	2400(%rsp), %rsi
.Lhrdbfw_767:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.Lhrdbfw_796:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.Lhrdbfw_797:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.Lhrdbfw_797
	cmpl	%r12d, %ebp
	jnb	.Lhrdbfw_798
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.Lhrdbfw_799
	jne	.Lhrdbfw_798
	testb	$1, %r8b
	jne	.Lhrdbfw_799
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.Lhrdbfw_798
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.Lhrdbfw_800
.Lhrdbfw_969:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.Lhrdbfw_798
.Lhrdbfw_800:
	cmpb	$48, (%rcx)
	je	.Lhrdbfw_969
.Lhrdbfw_799:
	addq	$1, %r8
.Lhrdbfw_798:
	movabs	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.Lhrdbfw_801:
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
	ja	.Lhrdbfw_801
	cmpl	%ebp, %ecx
	jbe	.Lhrdbfw_802
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.Lhrdbfw_806
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.Lhrdbfw_802:
	xorl	%edx, %edx
	jmp	.Lhrdbfw_804
.Lhrdbfw_970:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.Lhrdbfw_804:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.Lhrdbfw_970
	cmpl	$1, %ecx
	jbe	.Lhrdbfw_805
.Lhrdbfw_971:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.Lhrdbfw_805
	movl	%eax, %ecx
.Lhrdbfw_806:
	cmpl	$1, %ecx
	ja	.Lhrdbfw_971
.Lhrdbfw_805:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.Lhrdbfw_972
	cmpl	%ecx, %r8d
	jge	.Lhrdbfw_811
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.Lhrdbfw_817
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.Lhrdbfw_814
.Lhrdbfw_813:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.Lhrdbfw_973
	movq	%rcx, %rdx
.Lhrdbfw_814:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.Lhrdbfw_813
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.Lhrdbfw_817
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_975:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.Lhrdbfw_974
	movl	%edx, %r8d
.Lhrdbfw_817:
	cmpl	$1, %r8d
	jne	.Lhrdbfw_975
.Lhrdbfw_816:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.Lhrdbfw_809
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_781:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.Lhrdbfw_786
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_788:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.Lhrdbfw_976
.Lhrdbfw_786:
	cmpl	$-1, %edx
	jne	.Lhrdbfw_788
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.Lhrdbfw_790
	jmp	.Lhrdbfw_789
.Lhrdbfw_966:
	testb	$1, %r8b
	jne	.Lhrdbfw_769
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.Lhrdbfw_770
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.Lhrdbfw_771
.Lhrdbfw_977:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_770
.Lhrdbfw_771:
	cmpb	$48, (%rax)
	je	.Lhrdbfw_977
.Lhrdbfw_769:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.Lhrdbfw_772
.Lhrdbfw_967:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_773:
	movabs	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.Lhrdbfw_773
	cmpl	%ebp, %r9d
	jbe	.Lhrdbfw_772
	movabs	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.Lhrdbfw_772
.Lhrdbfw_968:
	jnb	.Lhrdbfw_792
	cmpl	$1, %ecx
	je	.Lhrdbfw_948
.Lhrdbfw_792:
	testl	%ecx, %ecx
	jne	.Lhrdbfw_783
	jmp	.Lhrdbfw_789
.Lhrdbfw_976:
	jnb	.Lhrdbfw_787
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.Lhrdbfw_790
	jmp	.Lhrdbfw_783
.Lhrdbfw_782:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_957
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.Lhrdbfw_790
.Lhrdbfw_957:
	jnb	.Lhrdbfw_783
.Lhrdbfw_948:
	movq	2400(%rsp), %rsi
	jmp	.Lhrdbfw_796
.Lhrdbfw_787:
	cmpl	656(%rsp), %r8d
	jne	.Lhrdbfw_957
	movl	$1, %ecx
	jmp	.Lhrdbfw_790
.Lhrdbfw_754:
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
	cmpq	%r8, %rcx
	jne	.Lhrdbfw_763
	testq	%rax, %rax
	je	.Lhrdbfw_764
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.Lhrdbfw_764:
	subl	$1, %ebx
	jne	.Lhrdbfw_762
	testb	%r11b, %r11b
	je	.Lhrdbfw_766
	movl	%edi, 960(%rsp)
.Lhrdbfw_766:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	hrdbfw_local_bn_shl
	jmp	.Lhrdbfw_760
.Lhrdbfw_811:
	cmpl	$1, %ecx
	je	.Lhrdbfw_816
.Lhrdbfw_809:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.Lhrdbfw_818:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.Lhrdbfw_721
	testl	%r10d, %r10d
	je	.Lhrdbfw_842
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.Lhrdbfw_820:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.Lhrdbfw_821
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.Lhrdbfw_823:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_822
	movzbl	0(%r13,%rdx), %r11d
.Lhrdbfw_822:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.Lhrdbfw_823
	addl	%r10d, %eax
.Lhrdbfw_824:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.Lhrdbfw_713
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.Lhrdbfw_826
.Lhrdbfw_979:
	cmpl	%ecx, %edx
	jnb	.Lhrdbfw_844
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.Lhrdbfw_825:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.Lhrdbfw_978
.Lhrdbfw_826:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.Lhrdbfw_979
.Lhrdbfw_844:
	movl	$48, %r10d
	jmp	.Lhrdbfw_825
.Lhrdbfw_842:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.Lhrdbfw_820
.Lhrdbfw_972:
	jne	.Lhrdbfw_808
	cmpb	$52, 1600(%rsp)
	jbe	.Lhrdbfw_808
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.Lhrdbfw_809
.Lhrdbfw_808:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.Lhrdbfw_818
.Lhrdbfw_821:
	movb	$48, (%rdx)
	jmp	.Lhrdbfw_824
.Lhrdbfw_978:
	addl	%r9d, %eax
	jmp	.Lhrdbfw_713
.Lhrdbfw_961:
	subl	$1, %r10d
	jmp	.Lhrdbfw_738
.Lhrdbfw_962:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.Lhrdbfw_741:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.Lhrdbfw_741
	jmp	.Lhrdbfw_713
.Lhrdbfw_974:
	movl	%r8d, %ecx
	jmp	.Lhrdbfw_809
.Lhrdbfw_828:
	movl	$1, %edx
	jmp	.Lhrdbfw_733
.Lhrdbfw_973:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.Lhrdbfw_817
	.p2align 4
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.Lhrdbfw_987
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.Lhrdbfw_980
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_980
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	hrdbfw_local_put_number.isra.0
.Lhrdbfw_980:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_987:
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
	jmp	.Lhrdbfw_991
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_993:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_992
.Lhrdbfw_991:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.Lhrdbfw_993
.Lhrdbfw_992:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_994
	movl	$32, %ecx
	leaq	.Lhrdbfw_C1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_996:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_1000
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_996
.Lhrdbfw_1000:
	movl	%eax, %edx
	subl	%esi, %edx
.Lhrdbfw_994:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, hrdbfw_local_fsink_len(%rip)
	call	hrdbfw_local_fdec
	movl	hrdbfw_local_fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.Lhrdbfw_997
	movb	$41, (%rax)
	addq	$1, %rax
.Lhrdbfw_997:
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
.Lhrdbfw_1002:
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
	jbe	.Lhrdbfw_1012
	cmpl	$19, %r10d
	jbe	.Lhrdbfw_1002
.Lhrdbfw_1012:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1010:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.Lhrdbfw_1004
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1006:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1005
.Lhrdbfw_1004:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1006
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.Lhrdbfw_1007
	jmp	.Lhrdbfw_1005
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1008:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.Lhrdbfw_1005
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.Lhrdbfw_1007:
	testb	%cl, %cl
	jne	.Lhrdbfw_1008
.Lhrdbfw_1005:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.Lhrdbfw_1001
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.Lhrdbfw_1010
.Lhrdbfw_1001:
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
.Lhrdbfw_1020:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.Lhrdbfw_1019
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.Lhrdbfw_1022
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1024:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1023
.Lhrdbfw_1022:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1024
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1025
	jmp	.Lhrdbfw_1023
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1026:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.Lhrdbfw_1023
.Lhrdbfw_1025:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1026
.Lhrdbfw_1023:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.Lhrdbfw_1020
.Lhrdbfw_1019:
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
	jmp	.Lhrdbfw_1034
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1036:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1035
.Lhrdbfw_1034:
	cmpb	$0, (%rdx)
	jne	.Lhrdbfw_1036
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.Lhrdbfw_1037
	jmp	.Lhrdbfw_1035
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1039:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.Lhrdbfw_1035
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.Lhrdbfw_1037:
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1039
.Lhrdbfw_1035:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.Lhrdbfw_1041
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1043:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1042
.Lhrdbfw_1041:
	cmpb	$0, (%rax)
	jne	.Lhrdbfw_1043
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.Lhrdbfw_1044
	jmp	.Lhrdbfw_1042
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1045:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.Lhrdbfw_1042
.Lhrdbfw_1044:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.Lhrdbfw_1045
.Lhrdbfw_1042:
	movb	$0, (%rax)
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C3:

.byte 112,97,116,104,32,105,115,32,110,111,116,32,97,32,115,117,112,112,111,114,116,101,100,32,112,108,97,105,110,32,102,105,108,101,32,112,97,116,104,32,40,114,101,115,101,114,118,101,100,32,100,101,118,105,99,101,32,110,97,109,101,32,111,114,32,99,104,97,114,97,99,116,101,114,115,41,0
.Lhrdbfw_C4:

.byte 67,79,78,0
.Lhrdbfw_C5:

.byte 80,82,78,0
.Lhrdbfw_C6:

.byte 65,85,88,0
.Lhrdbfw_C7:

.byte 78,85,76,0
.Lhrdbfw_C8:

.byte 67,79,78,73,78,36,0
.Lhrdbfw_C9:

.byte 67,79,78,79,85,84,36,0
.Lhrdbfw_C10:

.byte 67,76,79,67,75,36,0
.Lhrdbfw_C11:

.byte 67,79,77,0
.Lhrdbfw_C12:

.byte 76,80,84,0
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
	movq	%rdx, %rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$632, %rsp
	movzbl	(%rcx), %edx
	movq	%r9, 728(%rsp)
	testb	%dl, %dl
	je	.Lhrdbfw_1057
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.Lhrdbfw_1160
	cmpb	$47, %dl
	jne	.Lhrdbfw_1153
	cmpb	$47, 1(%rcx)
	je	.Lhrdbfw_1057
	movl	$47, %eax
.Lhrdbfw_1058:
	movabs	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.Lhrdbfw_1059
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1162:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.Lhrdbfw_1057
.Lhrdbfw_1063:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1161
	js	.Lhrdbfw_1057
	cmpq	$258, %rbx
	ja	.Lhrdbfw_1057
.Lhrdbfw_1059:
	cmpb	$63, %al
	ja	.Lhrdbfw_1162
	btq	%rax, %r9
	jc	.Lhrdbfw_1057
	cmpb	$60, %al
	je	.Lhrdbfw_1057
	cmpb	$58, %al
	jne	.Lhrdbfw_1062
	cmpq	$1, %rbx
	jne	.Lhrdbfw_1057
	cmpb	$25, %dl
	ja	.Lhrdbfw_1057
	movl	$58, %eax
	jmp	.Lhrdbfw_1063
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1167:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_1068
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1057:
	leaq	.Lhrdbfw_C3(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
.Lhrdbfw_1053:
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
.Lhrdbfw_1160:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.Lhrdbfw_1058
	jmp	.Lhrdbfw_1057
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1062:
	cmpb	$47, %al
	jne	.Lhrdbfw_1063
	movl	$92, %eax
	jmp	.Lhrdbfw_1063
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1153:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.Lhrdbfw_1058
	jmp	.Lhrdbfw_1057
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1161:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.Lhrdbfw_1083
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1066:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.Lhrdbfw_1163
	movq	%rax, %rbx
.Lhrdbfw_1083:
	cmpq	%r15, %r12
	je	.Lhrdbfw_1065
	cmpw	$92, (%rdi,%r15,2)
	jne	.Lhrdbfw_1066
.Lhrdbfw_1065:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.Lhrdbfw_1112
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.Lhrdbfw_1067
	cmpw	$46, %ax
	je	.Lhrdbfw_1067
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.Lhrdbfw_1068:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1070
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1071:
	movzwl	0(%r13,%rax,2), %edx
.Lhrdbfw_1070:
	cmpw	$46, %dx
	je	.Lhrdbfw_1164
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbfw_1071
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.Lhrdbfw_1073
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1077:
	subq	$1, %rsi
	je	.Lhrdbfw_1073
.Lhrdbfw_1076:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.Lhrdbfw_1077
.Lhrdbfw_1073:
	leaq	.Lhrdbfw_C4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C10(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.Lhrdbfw_1057
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.Lhrdbfw_1066
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.Lhrdbfw_1066
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.Lhrdbfw_1080
.Lhrdbfw_1165:
	leaq	.Lhrdbfw_C11(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.Lhrdbfw_1110
	movzwl	0(%r13,%rcx,2), %eax
.Lhrdbfw_1080:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1110
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.Lhrdbfw_1165
	jmp	.Lhrdbfw_1057
.Lhrdbfw_1110:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.Lhrdbfw_1082
.Lhrdbfw_1166:
	movzwl	0(%r13,%rdx,2), %r14d
.Lhrdbfw_1082:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.Lhrdbfw_1112
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.Lhrdbfw_1057
	leaq	.Lhrdbfw_C12(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.Lhrdbfw_1166
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1112:
	movq	%rbx, %rcx
	jmp	.Lhrdbfw_1066
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1067:
	cmpq	$1, %rsi
	je	.Lhrdbfw_1167
	cmpq	$2, %rsi
	jne	.Lhrdbfw_1057
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.Lhrdbfw_1057
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.Lhrdbfw_1068
	jmp	.Lhrdbfw_1057
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1164:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.Lhrdbfw_1076
	jmp	.Lhrdbfw_1073
.Lhrdbfw_1163:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.Lhrdbfw_1057
	cmpq	$1, %rbx
	je	.Lhrdbfw_1084
	cmpw	$58, 98(%rsp)
	je	.Lhrdbfw_1168
.Lhrdbfw_1084:
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
	je	.Lhrdbfw_1169
	movq	728(%rsp), %rax
	leaq GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1170
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.Lhrdbfw_1171
	cmpq	$67108864, %r10
	jg	.Lhrdbfw_1172
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1090
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1173
.Lhrdbfw_1090:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call VirtualAlloc
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.Lhrdbfw_1091
	movq	(%rdi), %r8
	leaq ReadFile(%rip), %rbx
	xorl	%r15d, %r15d
	movq	%rax, %rdx
	leaq GetLastError(%rip), %r13
	leaq	76(%rsp), %rsi
	testq	%r8, %r8
	jne	.Lhrdbfw_1092
	jmp	.Lhrdbfw_1093
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1097:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1159
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%r15, %rdx
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_1174
	addq	%rax, %r15
	cmpq	%r15, %r8
	jbe	.Lhrdbfw_1093
	movq	0(%rbp), %rdx
.Lhrdbfw_1092:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rsi, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_1097
	call	*%r13
	testl	%eax, %eax
	je	.Lhrdbfw_1097
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1159:
	movl	%eax, %edx
	leaq	.Lhrdbfw_C20(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1171:
	leaq	.Lhrdbfw_C15(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1172:
	leaq	.Lhrdbfw_C16(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	movq	80(%rsp), %rcx
	call	hrdbfw_local_fdec
	leaq	.Lhrdbfw_C17(%rip), %rcx
	call	hrdbfw_local_fcat
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1093:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rsi, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_1175
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.Lhrdbfw_1101
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.Lhrdbfw_1101
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.Lhrdbfw_1053
.Lhrdbfw_1101:
	leaq	.Lhrdbfw_C21(%rip), %rcx
	movl	$7, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1174:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1159
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1170:
	call GetLastError
	leaq	.Lhrdbfw_C14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1169:
	call GetLastError
	leaq	.Lhrdbfw_C13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	hrdbfw_local_werr
	jmp	.Lhrdbfw_1053
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1173:
	leaq	.Lhrdbfw_C18(%rip), %rcx
	movl	$1, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1053
.Lhrdbfw_1091:
	leaq	.Lhrdbfw_C19(%rip), %rcx
	movl	$8, %r13d
	call	hrdbfw_local_fset
	jmp	.Lhrdbfw_1053
.Lhrdbfw_1175:
	call GetLastError
	jmp	.Lhrdbfw_1159
.Lhrdbfw_1168:
	cmpq	$2, %rbx
	je	.Lhrdbfw_1057
	cmpw	$92, 100(%rsp)
	jne	.Lhrdbfw_1057
	jmp	.Lhrdbfw_1084
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
	je	.Lhrdbfw_1177
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.Lhrdbfw_1177:
	ret
	.p2align 4
	.globl	hrdbf_skip
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1180
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_1180
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.Lhrdbfw_1182
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
.Lhrdbfw_1184:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.Lhrdbfw_1194
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1180:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1182:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.Lhrdbfw_1185
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1194:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1185:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.Lhrdbfw_1184
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
	je	.Lhrdbfw_1197
	testl	%edx, %edx
	je	.Lhrdbfw_1199
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1199
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1199:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1197:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.Lhrdbfw_1200
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1202
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.Lhrdbfw_1202:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1200:
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
	jbe	.Lhrdbfw_1290
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.Lhrdbfw_1291
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
	jbe	.Lhrdbfw_1209
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.Lhrdbfw_1210
.Lhrdbfw_1209:
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
.Lhrdbfw_1205:
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
.Lhrdbfw_1210:
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
.Lhrdbfw_1236:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.Lhrdbfw_1292
	cmpq	%r15, 64(%rsp)
	je	.Lhrdbfw_1293
	cmpq	$129, %r15
	je	.Lhrdbfw_1294
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1220
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1295:
	movzbl	(%r8,%rax), %r10d
.Lhrdbfw_1220:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_1295
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.Lhrdbfw_1221
	cmpl	$1, %r15d
	jbe	.Lhrdbfw_1222
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1223:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.Lhrdbfw_1226
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1297:
	movzbl	(%rax), %edx
	addq	$1, %rax
.Lhrdbfw_1226:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.Lhrdbfw_1296
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1297
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
	jmp	.Lhrdbfw_1205
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1296:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.Lhrdbfw_1223
.Lhrdbfw_1222:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.Lhrdbfw_1298
	cmpb	$67, %dl
	je	.Lhrdbfw_1299
	cmpb	$78, %dl
	je	.Lhrdbfw_1300
	cmpb	$76, %dl
	je	.Lhrdbfw_1301
	cmpb	$68, %dl
	jne	.Lhrdbfw_1233
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.Lhrdbfw_1229
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
	jmp	.Lhrdbfw_1205
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1290:
	leaq	.Lhrdbfw_C15(%rip), %rdx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1291:
	leaq	.Lhrdbfw_C24(%rip), %rdx
	call	hrdbfw_local_dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	hrdbfw_local_dhex
	leaq	.Lhrdbfw_C25(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	$2, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1299:
	testb	%r9b, %r9b
	jne	.Lhrdbfw_1302
.Lhrdbfw_1229:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.Lhrdbfw_1303
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.Lhrdbfw_1236
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C48(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1300:
	cmpb	$17, %r9b
	ja	.Lhrdbfw_1257
	cmpb	%r9b, %al
	ja	.Lhrdbfw_1229
.Lhrdbfw_1257:
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
	jmp	.Lhrdbfw_1205
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1301:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.Lhrdbfw_1229
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
	jmp	.Lhrdbfw_1205
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1293:
	testb	%dl, %dl
	je	.Lhrdbfw_1216
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1216:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1294:
	testb	%dl, %dl
	je	.Lhrdbfw_1218
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1218:
	leaq	.Lhrdbfw_C31(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1292:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.Lhrdbfw_1212
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.Lhrdbfw_1212:
	cmpw	$0, 148(%rsp)
	je	.Lhrdbfw_1304
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.Lhrdbfw_1238
	jmp	.Lhrdbfw_1305
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1239:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.Lhrdbfw_1306
.Lhrdbfw_1238:
	cmpq	%r9, 32(%rsp)
	ja	.Lhrdbfw_1239
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.Lhrdbfw_1307
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.Lhrdbfw_1241
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.Lhrdbfw_1242
	cmpb	$26, (%rbx,%rax)
	je	.Lhrdbfw_1241
.Lhrdbfw_1242:
	leaq	.Lhrdbfw_C56(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1221:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1298:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1306:
	leaq	.Lhrdbfw_C52(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1303:
	movzwl	46(%rsp), %eax
	leaq	.Lhrdbfw_C47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	hrdbfw_local_dset
	movl	$4, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1302:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1305:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1304:
	leaq	.Lhrdbfw_C49(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dset
	movl	$1, %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1233:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1241:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.Lhrdbfw_1254
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.Lhrdbfw_1246:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.Lhrdbfw_1244
	cmpb	$42, %dil
	jne	.Lhrdbfw_1308
.Lhrdbfw_1244:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.Lhrdbfw_1245
	jmp	.Lhrdbfw_1252
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1248:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1309
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.Lhrdbfw_1252
.Lhrdbfw_1245:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.Lhrdbfw_1248
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
.Lhrdbfw_1249:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.Lhrdbfw_1310
.Lhrdbfw_1251:
	cmpb	$42, %dil
	jne	.Lhrdbfw_1205
	leaq	.Lhrdbfw_C62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1252:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.Lhrdbfw_1246
	cmpb	$0, 152(%rsp)
	je	.Lhrdbfw_1253
.Lhrdbfw_1243:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.Lhrdbfw_1253:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1310:
	leaq	.Lhrdbfw_C61(%rip), %rdx
	movq	%r12, %rcx
	call	hrdbfw_local_dcat
	movl	40(%rsp), %eax
	jmp	.Lhrdbfw_1251
.Lhrdbfw_1307:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1308:
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
	jmp	.Lhrdbfw_1205
.Lhrdbfw_1254:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1243
.Lhrdbfw_1309:
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
	jmp	.Lhrdbfw_1249
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
	ja	.Lhrdbfw_1313
	je	.Lhrdbfw_1344
	cmpl	$5, %edx
	je	.Lhrdbfw_1317
	shrq	$8, %rax
	jne	.Lhrdbfw_1313
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.Lhrdbfw_1313
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.Lhrdbfw_1313
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1313
	movq	%rcx, %rax
	movl	$4, %r8d
	movabs	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.Lhrdbfw_1313
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
	ja	.Lhrdbfw_1331
	testq	%rcx, %rcx
	je	.Lhrdbfw_1331
	leaq	hrdbfw_local_days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbfw_1345
.Lhrdbfw_1319:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.Lhrdbfw_1313:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1344:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.Lhrdbfw_1313
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.Lhrdbfw_1313
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.Lhrdbfw_1331
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.Lhrdbfw_1331
	cmpl	%edx, %eax
	jb	.Lhrdbfw_1313
.Lhrdbfw_1331:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1317:
	testq	%rax, %rax
	jns	.Lhrdbfw_1326
	movabs	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1313
.Lhrdbfw_1326:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1345:
	testb	$3, %r9b
	jne	.Lhrdbfw_1319
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbfw_1320
	addl	$1, %eax
	jmp	.Lhrdbfw_1319
.Lhrdbfw_1320:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.Lhrdbfw_1319
	.p2align 4
	.globl	hrv_valtype
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.Lhrdbfw_1346
	leaq	hrdbfw_local_CSWTCH.335(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.Lhrdbfw_1346:
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
	jne	.Lhrdbfw_1351
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.Lhrdbfw_1362
	testl	%edx, %edx
	je	.Lhrdbfw_1354
	cmpl	$9, %edx
	je	.Lhrdbfw_1354
	movl	$1, %eax
.Lhrdbfw_1351:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1362:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1363
.Lhrdbfw_1354:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1363:
	movl	$2, %eax
	jmp	.Lhrdbfw_1351
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
	jne	.Lhrdbfw_1364
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1364
	movzbl	%bl, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %bl
	jne	.Lhrdbfw_1366
	cmpl	$11, %r14d
	jne	.Lhrdbfw_1366
.Lhrdbfw_1379:
	xorl	%edx, %edx
	cmpq	%r12, %rsi
	sete	%dl
	movl	%edx, 0(%r13)
.Lhrdbfw_1364:
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
.Lhrdbfw_1366:
	cmpl	$1, %r15d
	je	.Lhrdbfw_1382
	cmpl	$1, %r14d
	je	.Lhrdbfw_1382
	cmpl	$3, %r15d
	jne	.Lhrdbfw_1369
	cmpl	$3, %r14d
	jne	.Lhrdbfw_1369
	testq	%rsi, %rsi
	sete	%dl
	testq	%r12, %r12
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_1364
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1382:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, 0(%r13)
	jmp	.Lhrdbfw_1364
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1369:
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1364
	cmpl	$12, %r15d
	je	.Lhrdbfw_1405
	testl	%r15d, %r15d
	je	.Lhrdbfw_1372
	movl	$1, %eax
	cmpl	$9, %r15d
	jne	.Lhrdbfw_1364
.Lhrdbfw_1372:
	movq	%r11, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1364
	cmpl	$12, %r14d
	je	.Lhrdbfw_1406
	testl	%r14d, %r14d
	je	.Lhrdbfw_1379
	cmpl	$9, %r14d
	je	.Lhrdbfw_1379
	movl	$1, %eax
	jmp	.Lhrdbfw_1364
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1405:
	andb	$-1, %bh
	je	.Lhrdbfw_1372
.Lhrdbfw_1378:
	movl	$2, %eax
	jmp	.Lhrdbfw_1364
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1406:
	testl	$65280, %edi
	je	.Lhrdbfw_1379
	jmp	.Lhrdbfw_1378
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
	jne	.Lhrdbfw_1407
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	ja	.Lhrdbfw_1412
	leaq	.Lhrdbfw_1410(%rip), %rcx
	movslq	(%rcx,%rdx,4), %rdx
	addq	%rcx, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1410:
	.long	.Lhrdbfw_1409-.Lhrdbfw_1410
	.long	.Lhrdbfw_1411-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1409-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1409-.Lhrdbfw_1410
	.long	.Lhrdbfw_1412-.Lhrdbfw_1410
	.long	.Lhrdbfw_1409-.Lhrdbfw_1410
	.long	.Lhrdbfw_1409-.Lhrdbfw_1410
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1412:
	movl	$1, %eax
.Lhrdbfw_1407:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1409:
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
.Lhrdbfw_1411:
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
	jne	.Lhrdbfw_1414
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.Lhrdbfw_1461
	cmpl	$12, %eax
	jne	.Lhrdbfw_1440
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
.Lhrdbfw_1422:
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
	ja	.Lhrdbfw_1422
	cmpl	%ebx, %r8d
	ja	.Lhrdbfw_1462
	movl	$1, %r9d
.Lhrdbfw_1423:
	leal	1(%r9,%rbx), %eax
.Lhrdbfw_1424:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.Lhrdbfw_1425
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.Lhrdbfw_1463
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.Lhrdbfw_1433
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1432:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_1432
.Lhrdbfw_1433:
	testq	%r13, %r13
	jns	.Lhrdbfw_1431
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.Lhrdbfw_1431:
	testl	%r9d, %r9d
	je	.Lhrdbfw_1434
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.Lhrdbfw_1436
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1444:
	movl	%edx, %eax
.Lhrdbfw_1436:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1435
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1435:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.Lhrdbfw_1444
	addl	%r9d, %r10d
.Lhrdbfw_1434:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1414
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1438:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.Lhrdbfw_1437
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.Lhrdbfw_1437:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbfw_1438
.Lhrdbfw_1414:
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
.Lhrdbfw_1461:
	cmpq	$7, %rsi
	jbe	.Lhrdbfw_1425
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.Lhrdbfw_1420
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
	jmp	.Lhrdbfw_1414
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1440:
	movl	$1, %r12d
	jmp	.Lhrdbfw_1414
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1464:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.Lhrdbfw_1439
.Lhrdbfw_1419:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.Lhrdbfw_1414
.Lhrdbfw_1420:
	cmpl	$2, %ecx
	jne	.Lhrdbfw_1464
.Lhrdbfw_1439:
	movl	$47, %eax
	jmp	.Lhrdbfw_1419
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1462:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1423
	movl	%r9d, %eax
	jmp	.Lhrdbfw_1424
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1425:
	movl	$3, %r12d
	jmp	.Lhrdbfw_1414
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1463:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.Lhrdbfw_1414
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1428:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.Lhrdbfw_1428
	jmp	.Lhrdbfw_1414
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
	subq	$80, %rsp
	movq	(%rdx), %r11
	movq	8(%rdx), %r14
	leaq	32(%rsp), %r15
	movq	(%r8), %rdi
	movq	8(%r8), %r12
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1465
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1465
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.Lhrdbfw_1487
	cmpl	$42, %ebx
	je	.Lhrdbfw_1487
	movl	$1, %eax
	cmpl	$47, %ebx
	je	.Lhrdbfw_1480
.Lhrdbfw_1465:
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
.Lhrdbfw_1487:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1480
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_1501
	testl	%eax, %eax
	je	.Lhrdbfw_1471
	cmpl	$9, %eax
	je	.Lhrdbfw_1471
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1480:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1465
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.Lhrdbfw_1465
	movsd	72(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.Lhrdbfw_1502
	testl	%r13d, %r13d
	je	.Lhrdbfw_1503
	cmpl	$42, %ebx
	je	.Lhrdbfw_1504
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	jp	.Lhrdbfw_1488
	jne	.Lhrdbfw_1488
	movl	$5, %eax
	jmp	.Lhrdbfw_1465
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1501:
	testl	$65280, %r11d
	jne	.Lhrdbfw_1480
.Lhrdbfw_1471:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_1480
	movzbl	%dil, %edx
	cmpb	$12, %dil
	je	.Lhrdbfw_1505
	testl	%edx, %edx
	je	.Lhrdbfw_1474
	cmpl	$9, %edx
	jne	.Lhrdbfw_1480
.Lhrdbfw_1474:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.Lhrdbfw_1506
	testl	%r13d, %r13d
	je	.Lhrdbfw_1507
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1465
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1505:
	testl	$65280, %edi
	je	.Lhrdbfw_1474
	jmp	.Lhrdbfw_1480
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1504:
	mulsd	64(%rsp), %xmm0
	movl	60(%rsp), %edx
	movl	$255, %r8d
	addl	56(%rsp), %edx
	cmpl	$255, %edx
	cmova	%r8, %rdx
	salq	$8, %rdx
	movq	%xmm0, %rcx
	orq	$5, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1482:
	movq	%rdx, (%rsi)
	movq	%rcx, 8(%rsi)
	jmp	.Lhrdbfw_1465
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1488:
	movsd	64(%rsp), %xmm1
	movl	$517, %edx
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rcx
	jmp	.Lhrdbfw_1482
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1502:
	addsd	64(%rsp), %xmm0
	movq	%xmm0, %rcx
.Lhrdbfw_1500:
	movl	56(%rsp), %edx
	cmpl	%edx, 60(%rsp)
	cmovnb	60(%rsp), %edx
	movl	%edx, %edx
	salq	$8, %rdx
	orq	$5, %rdx
	jmp	.Lhrdbfw_1482
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1503:
	movsd	64(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rcx
	jmp	.Lhrdbfw_1500
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1506:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.Lhrdbfw_1465
.Lhrdbfw_1507:
	subq	%r12, %r14
	xorl	%eax, %eax
	movq	%r14, 8(%rsi)
	jmp	.Lhrdbfw_1465
	.section .rdata,"dr"
.Lhrdbfw_C66:

.byte 68,66,70,32,117,110,107,110,111,119,110,32,118,97,108,117,101,32,101,114,114,111,114,0
.Lhrdbfw_C67:

.byte 111,107,0
	.align 8
.Lhrdbfw_C68:

.byte 68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,0
	.align 8
.Lhrdbfw_C69:

.byte 68,66,70,32,118,97,108,117,101,32,111,117,116,112,117,116,32,98,117,102,102,101,114,32,116,111,111,32,115,104,111,114,116,0
	.align 8
.Lhrdbfw_C70:

.byte 68,66,70,32,118,97,108,117,101,32,116,97,103,32,111,114,32,109,101,116,97,100,97,116,97,32,105,110,118,97,108,105,100,0
	.align 8
.Lhrdbfw_C71:

.byte 68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,0
	.align 8
.Lhrdbfw_C72:

.byte 68,66,70,32,118,97,108,117,101,32,116,121,112,101,32,111,117,116,115,105,100,101,32,97,100,109,105,116,116,101,100,32,111,112,101,114,97,116,105,111,110,0
	.text
	.p2align 4
	.globl	hrv_error_name
hrv_error_name:
	cmpl	$5, %ecx
	ja	.Lhrdbfw_1509
	leaq	.Lhrdbfw_1511(%rip), %rdx
	movl	%ecx, %ecx
	movslq	(%rdx,%rcx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_1511:
	.long	.Lhrdbfw_1517-.Lhrdbfw_1511
	.long	.Lhrdbfw_1515-.Lhrdbfw_1511
	.long	.Lhrdbfw_1514-.Lhrdbfw_1511
	.long	.Lhrdbfw_1513-.Lhrdbfw_1511
	.long	.Lhrdbfw_1512-.Lhrdbfw_1511
	.long	.Lhrdbfw_1510-.Lhrdbfw_1511
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1515:
	leaq	.Lhrdbfw_C72(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1517:
	leaq	.Lhrdbfw_C67(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1510:
	leaq	.Lhrdbfw_C71(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1514:
	leaq	.Lhrdbfw_C68(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1513:
	leaq	.Lhrdbfw_C69(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1512:
	leaq	.Lhrdbfw_C70(%rip), %rax
	ret
.Lhrdbfw_1509:
	leaq	.Lhrdbfw_C66(%rip), %rax
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
	ja	.Lhrdbfw_1521
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.Lhrdbfw_1521
	movabs	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.Lhrdbfw_1616
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.Lhrdbfw_1525:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.Lhrdbfw_1532
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1531:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1533:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.Lhrdbfw_1533
	testq	%rax, %rax
	je	.Lhrdbfw_1534
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.Lhrdbfw_1534:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.Lhrdbfw_1531
	testb	%r12b, %r12b
	je	.Lhrdbfw_1532
	movl	%r9d, 544(%rsp)
.Lhrdbfw_1532:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.Lhrdbfw_1537
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shl
	movl	544(%rsp), %edi
.Lhrdbfw_1538:
	xorl	%r12d, %r12d
	jmp	.Lhrdbfw_1544
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1545:
	cmpq	$48, %r12
	je	.Lhrdbfw_1617
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.Lhrdbfw_1544:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.Lhrdbfw_1545
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1545
	testl	%r12d, %r12d
	jne	.Lhrdbfw_1618
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.Lhrdbfw_1550:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.Lhrdbfw_1553
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1619:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.Lhrdbfw_1553:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbfw_1619
	testl	%r13d, %r13d
	je	.Lhrdbfw_1554
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1556:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1555:
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
	jne	.Lhrdbfw_1555
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.Lhrdbfw_1620
	movq	%rax, %r12
	jmp	.Lhrdbfw_1556
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1521:
	xorl	%eax, %eax
.Lhrdbfw_1518:
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
.Lhrdbfw_1616:
	testq	%rax, %rax
	jne	.Lhrdbfw_1621
	cmpq	$0, 40(%rsp)
	jne	.Lhrdbfw_1622
	xorl	%edx, %edx
.Lhrdbfw_1526:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1527
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.Lhrdbfw_1521
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1529:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.Lhrdbfw_1529
	addl	%ebx, %eax
	jmp	.Lhrdbfw_1518
.Lhrdbfw_1622:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.Lhrdbfw_1521
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.Lhrdbfw_1526
.Lhrdbfw_1537:
	negl	%edx
	movq	%rbp, %rcx
	call	hrdbfw_local_bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.Lhrdbfw_1623
	cmpl	$2, %eax
	jne	.Lhrdbfw_1538
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.Lhrdbfw_1538
	testl	%edi, %edi
	je	.Lhrdbfw_1571
.Lhrdbfw_1541:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.Lhrdbfw_1543
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1624:
	movl	(%rcx), %edx
.Lhrdbfw_1543:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.Lhrdbfw_1624
	testq	%rax, %rax
	je	.Lhrdbfw_1538
	movl	%edi, %eax
	addl	$1, %edi
.Lhrdbfw_1540:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.Lhrdbfw_1538
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1620:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.Lhrdbfw_1554:
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
	ja	.Lhrdbfw_1521
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.Lhrdbfw_1559
	movb	$45, (%rsi)
	movl	$1, %edx
.Lhrdbfw_1559:
	cmpl	%edi, %ebx
	jnb	.Lhrdbfw_1560
	testl	%eax, %eax
	je	.Lhrdbfw_1576
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1562:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1562
.Lhrdbfw_1561:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1518
.Lhrdbfw_1563:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.Lhrdbfw_1564
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1565:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.Lhrdbfw_1565
	addl	%ebx, %edx
.Lhrdbfw_1564:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1566:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.Lhrdbfw_1566
	jmp	.Lhrdbfw_1518
.Lhrdbfw_1617:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.Lhrdbfw_1548:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1551:
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
	ja	.Lhrdbfw_1551
	jmp	.Lhrdbfw_1550
.Lhrdbfw_1621:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.Lhrdbfw_1525
.Lhrdbfw_1527:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.Lhrdbfw_1521
	movb	$48, (%rsi,%rdx)
	jmp	.Lhrdbfw_1518
.Lhrdbfw_1560:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.Lhrdbfw_1563
.Lhrdbfw_1623:
	testl	%edi, %edi
	je	.Lhrdbfw_1570
	movl	256(%rsp), %edx
	jmp	.Lhrdbfw_1541
.Lhrdbfw_1576:
	movl	%edx, %eax
	jmp	.Lhrdbfw_1561
.Lhrdbfw_1571:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.Lhrdbfw_1540
.Lhrdbfw_1570:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.Lhrdbfw_1540
.Lhrdbfw_1618:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.Lhrdbfw_1548
	.p2align 4
	.globl	hrdbf_fmt_harbour
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.Lhrdbfw_1626
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1626:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1627
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.Lhrdbfw_1629
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1630:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrdbfw_1630
	movzbl	12(%rdx), %eax
.Lhrdbfw_1629:
	cmpq	%rax, %r9
	jnb	.Lhrdbfw_1632
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1631:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.Lhrdbfw_1631
.Lhrdbfw_1632:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1627:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1641
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1641:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.Lhrdbfw_1643
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1643:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.Lhrdbfw_1664
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.Lhrdbfw_1667
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
	ja	.Lhrdbfw_1664
	cmpl	$9999, %r8d
	jbe	.Lhrdbfw_1664
	testl	%r11d, %r11d
	je	.Lhrdbfw_1664
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.Lhrdbfw_1648
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.Lhrdbfw_1650
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.Lhrdbfw_1650:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.Lhrdbfw_1644
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
.Lhrdbfw_1644:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1667:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1647:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.Lhrdbfw_1647
	xorl	%r10d, %r10d
.Lhrdbfw_1664:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1648:
	movl	$28, %edx
	testb	$3, %bl
	jne	.Lhrdbfw_1650
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.Lhrdbfw_1650
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.Lhrdbfw_1650
	.p2align 4
	.globl	hrdbf_write_logical
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.Lhrdbfw_1668
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.Lhrdbfw_1668:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.Lhrdbfw_1680
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.Lhrdbfw_1679
.Lhrdbfw_1680:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1678
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1677:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1677
.Lhrdbfw_1678:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1679:
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
	je	.Lhrdbfw_1691
	movq	$0, 2280(%rbx)
	call CloseHandle
	testl	%eax, %eax
	je	.Lhrdbfw_1698
.Lhrdbfw_1691:
	xorl	%r12d, %r12d
.Lhrdbfw_1690:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1688
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1693
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.Lhrdbfw_1688:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1698:
	movl	$7, %r12d
	jmp	.Lhrdbfw_1690
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1693:
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
	je	.Lhrdbfw_1700
	movl	%eax, %r13d
	leaq	hrdbfw_local_fsink(%rip), %rax
	leaq	2288(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.Lhrdbfw_1701
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1703:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.Lhrdbfw_1702
.Lhrdbfw_1701:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.Lhrdbfw_1703
.Lhrdbfw_1702:
	movb	$0, (%rdx)
.Lhrdbfw_1705:
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
.Lhrdbfw_1700:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.Lhrdbfw_1705
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
.Lhrdbfw_C73:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,100,101,99,111,100,105,110,103,32,102,97,105,108,101,100,10,0
	.align 8
.Lhrdbfw_C74:

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
	je	.Lhrdbfw_1716
	movzwl	hrdbf_app_state+36(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.Lhrdbfw_1726
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1716
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbfw_1730
	cmpb	$78, %al
	je	.Lhrdbfw_1731
	cmpb	$68, %al
	je	.Lhrdbfw_1725
	movzbl	60(%rsp), %eax
.Lhrdbfw_1715:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1730:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.Lhrdbfw_1732
.Lhrdbfw_1718:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.Lhrdbfw_1733
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1716:
	leaq	.Lhrdbfw_C73(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1726:
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1715
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1731:
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
.Lhrdbfw_1725:
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
.Lhrdbfw_1732:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.Lhrdbfw_1721
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1720:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1720
.Lhrdbfw_1721:
	movq	%rcx, 40(%rsp)
	jmp	.Lhrdbfw_1718
.Lhrdbfw_1733:
	leaq	.Lhrdbfw_C74(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C75:

.byte 104,98,99,58,32,68,66,70,32,110,111,32,119,111,114,107,97,114,101,97,32,105,115,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C76:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,114,101,113,117,105,114,101,115,32,97,32,114,101,97,100,111,110,108,121,61,46,70,46,32,111,112,101,110,10,0
	.align 8
.Lhrdbfw_C77:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,97,110,32,111,112,101,110,32,105,110,100,101,120,32,105,115,32,111,117,116,115,105,100,101,32,116,104,105,115,32,105,110,99,114,101,109,101,110,116,10,0
	.align 8
.Lhrdbfw_C78:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,119,105,116,104,32,110,111,32,114,101,99,111,114,100,32,112,111,115,105,116,105,111,110,101,100,10,0
	.text
	.p2align 4
hrdbf_app_require_writable:
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1740
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1741
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_1742
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_1743
	addq	$40, %rsp
	ret
.Lhrdbfw_1740:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1743:
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1742:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1741:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C79:

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
	leaq	.Lhrdbfw_C79(%rip), %rdx
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
	je	.Lhrdbfw_1766
	movq	$0, 2280(%r12)
	call CloseHandle
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_1750
	testq	%rcx, %rcx
	je	.Lhrdbfw_1746
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1746
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
.Lhrdbfw_1750:
	testq	%rcx, %rcx
	je	.Lhrdbfw_1749
.Lhrdbfw_1748:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	jne	.Lhrdbfw_1764
.Lhrdbfw_1746:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1766:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1748
.Lhrdbfw_1749:
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
.Lhrdbfw_1764:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.Lhrdbfw_1749
	.p2align 4
	.globl	hrdbf_file_write_record
hrdbf_file_write_record:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1771
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1771
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1771
	testq	%rdx, %rdx
	je	.Lhrdbfw_1772
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.Lhrdbfw_1774
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1771:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1772:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1774:
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
	je	.Lhrdbfw_1775
	cmpq	$0, 2280(%rcx)
	je	.Lhrdbfw_1775
	cmpb	$0, 40(%rcx)
	je	.Lhrdbfw_1775
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1775:
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
	je	.Lhrdbfw_1782
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1787:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl $1, %r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.Lhrdbfw_1800
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1786
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1784:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1800
.Lhrdbfw_1786:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.Lhrdbfw_1784
	jnb	.Lhrdbfw_1800
	leal	1(%r10), %r11d
.Lhrdbfw_1783:
	cmpl	%r9d, %r11d
	jb	.Lhrdbfw_1787
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.Lhrdbfw_1791
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.Lhrdbfw_1790:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.Lhrdbfw_1792
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1793
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1825:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1792
.Lhrdbfw_1793:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.Lhrdbfw_1825
.Lhrdbfw_1791:
	testl	%ebp, %ebp
	je	.Lhrdbfw_1781
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.Lhrdbfw_1826
	movl	%r11d, %r9d
.Lhrdbfw_1781:
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
.Lhrdbfw_1800:
	movl	%r10d, %r9d
	jmp	.Lhrdbfw_1783
.Lhrdbfw_1792:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.Lhrdbfw_1781
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.Lhrdbfw_1794
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1799:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl $1, %r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.Lhrdbfw_1795
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.Lhrdbfw_1798
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1796:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbfw_1795
.Lhrdbfw_1798:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.Lhrdbfw_1796
	jb	.Lhrdbfw_1795
	movl	%r9d, %r10d
.Lhrdbfw_1797:
	cmpl	%r10d, %r11d
	jb	.Lhrdbfw_1799
.Lhrdbfw_1794:
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
.Lhrdbfw_1795:
	leal	1(%r9), %r11d
	jmp	.Lhrdbfw_1797
.Lhrdbfw_1826:
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
.Lhrdbfw_1782:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.Lhrdbfw_1781
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.Lhrdbfw_1790
	.section .rdata,"dr"
.Lhrdbfw_C80:

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
	je	.Lhrdbfw_1832
	movq	$0, hrdbf_app_state+2280(%rip)
	call CloseHandle
	testl	%eax, %eax
	jne	.Lhrdbfw_1832
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	je	.Lhrdbfw_1833
	movl	$7, %esi
	jmp	.Lhrdbfw_1829
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1832:
	movq	hrdbf_app_state+2256(%rip), %rcx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_1842
.Lhrdbfw_1830:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.Lhrdbfw_1835
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1842:
	xorl	%esi, %esi
.Lhrdbfw_1829:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call VirtualFree
	testl	%eax, %eax
	je	.Lhrdbfw_1833
	movq	$0, hrdbf_app_state+2256(%rip)
	orl	%esi, %ebx
	movq	$0, hrdbf_app_state+2264(%rip)
	jmp	.Lhrdbfw_1830
.Lhrdbfw_1833:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbfw_1835:
	leaq	.Lhrdbfw_C80(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.Lhrdbfw_C81:

.byte 111,117,116,32,111,102,32,109,101,109,111,114,121,0
	.align 8
.Lhrdbfw_C82:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,116,97,98,108,101,32,118,101,114,115,105,111,110,32,111,114,32,104,101,97,100,101,114,32,102,108,97,103,115,0
.Lhrdbfw_C83:

.byte 117,110,115,117,112,112,111,114,116,101,100,32,102,105,101,108,100,32,116,121,112,101,0
.Lhrdbfw_C84:

.byte 114,101,99,111,114,100,32,99,111,110,116,101,110,116,32,105,110,118,97,108,105,100,0
.Lhrdbfw_C85:

.byte 73,47,79,32,101,114,114,111,114,0
	.align 8
.Lhrdbfw_C86:

.byte 115,105,122,101,32,111,114,32,102,105,101,108,100,45,99,111,117,110,116,32,108,105,109,105,116,32,101,120,99,101,101,100,101,100,0
.Lhrdbfw_C87:

.byte 116,97,98,108,101,32,102,111,114,109,97,116,32,110,111,116,32,115,117,112,112,111,114,116,101,100,0
	.align 8
.Lhrdbfw_C88:

.byte 104,98,99,58,32,68,66,70,32,111,110,108,121,32,111,110,101,32,119,111,114,107,97,114,101,97,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C89:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C90:

.byte 104,98,99,58,32,68,66,70,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
.Lhrdbfw_C91:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,99,108,111,115,101,32,102,97,105,108,101,100,10,0
.Lhrdbfw_C92:

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
	je	.Lhrdbfw_1844
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbfw_1890
.Lhrdbfw_1844:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.Lhrdbfw_1891
	xorl	%ebx, %ebx
	jmp	.Lhrdbfw_1845
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1863:
	movq	%rsi, %rbx
.Lhrdbfw_1845:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.Lhrdbfw_1892
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.Lhrdbfw_1863
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1893
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movq	$0, hrdbf_app_pos(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	jmp	.Lhrdbfw_1850
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1848:
	cmpq	%rcx, %rbx
	je	.Lhrdbfw_1894
.Lhrdbfw_1850:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.Lhrdbfw_1873
	cmpb	$92, %dl
	jne	.Lhrdbfw_1848
.Lhrdbfw_1873:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.Lhrdbfw_1850
.Lhrdbfw_1894:
	cmpq	%rsi, %r8
	jnb	.Lhrdbfw_1851
	movq	%r8, %rax
	jmp	.Lhrdbfw_1853
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1864:
	movq	%rdx, %rax
.Lhrdbfw_1853:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.Lhrdbfw_1864
.Lhrdbfw_1851:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.Lhrdbfw_1858
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1854:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrdbfw_1854
.Lhrdbfw_1858:
	xorl	%ebx, %ebx
	leaq	hrdbf_app_state(%rip), %rcx
	cmpq	$0, 384(%rsp)
	movb	$0, hrdbf_app_state+2288(%rip)
	setne	%bl
	movb	$0, hrdbfw_local_fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.Lhrdbfw_1895
.Lhrdbfw_1855:
	leaq	hrdbf_app_state+2288(%rip), %r12
	cmpb	$0, hrdbf_app_state+2288(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.Lhrdbfw_1861
	leaq	.Lhrdbfw_C85(%rip), %r12
	cmpl	$7, %eax
	je	.Lhrdbfw_1861
	leaq	.Lhrdbfw_C81(%rip), %r12
	cmpl	$8, %eax
	je	.Lhrdbfw_1861
	leaq	.Lhrdbfw_C86(%rip), %r12
	cmpl	$4, %eax
	je	.Lhrdbfw_1861
	leaq	.Lhrdbfw_C82(%rip), %r12
	cmpl	$2, %eax
	je	.Lhrdbfw_1861
	leaq	.Lhrdbfw_C83(%rip), %r12
	cmpl	$3, %eax
	je	.Lhrdbfw_1861
	cmpl	$5, %eax
	leaq	.Lhrdbfw_C84(%rip), %r12
	leaq	.Lhrdbfw_C87(%rip), %rax
	cmovne	%rax, %r12
.Lhrdbfw_1861:
	leaq	.Lhrdbfw_C92(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.Lhrdbfw_C79(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1895:
	movl	%ebx, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1855
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.Lhrdbfw_1892:
	leaq	.Lhrdbfw_C90(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1891:
	leaq	.Lhrdbfw_C89(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1890:
	leaq	.Lhrdbfw_C88(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_1893:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_top
hrdbfw_app_top:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1905
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1906
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbfw_1907
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1901:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1907:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbfw_1901
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1906:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1905:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
hrdbfw_app_bottom:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1918
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1919
	movl	hrdbf_app_order+24(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.Lhrdbfw_1920
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.Lhrdbfw_1913:
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbfw_1914:
	cmpq	%r8, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	setnb	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1920:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.Lhrdbfw_1913
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.Lhrdbfw_1914
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1919:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbfw_1918:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
hrdbfw_app_skip:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_1938
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbfw_1939
	testq	%rcx, %rcx
	je	.Lhrdbfw_1921
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbfw_1925
	movq	%rax, %r8
	subq	%rdx, %r8
	cmpq	%rcx, %r8
	jb	.Lhrdbfw_1931
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	setnb	%dl
.Lhrdbfw_1926:
	movq	%rcx, hrdbf_app_pos(%rip)
.Lhrdbfw_1927:
	cmpq	%rax, %rcx
	jnb	.Lhrdbfw_1929
.Lhrdbfw_1940:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rcx,8), %eax
.Lhrdbfw_1930:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbfw_1921:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1925:
	movq	%rcx, %r8
	negq	%r8
	cmpq	%rdx, %r8
	jbe	.Lhrdbfw_1928
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%ecx, %ecx
	cmpq	%rax, %rcx
	jb	.Lhrdbfw_1940
.Lhrdbfw_1929:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbfw_1930
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1931:
	movq	%rax, %rcx
	movl	$1, %edx
	jmp	.Lhrdbfw_1926
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1928:
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	movq	%rcx, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbfw_1927
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1939:
	movq	%rcx, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
.Lhrdbfw_1938:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C93:

.byte 104,98,99,58,32,67,68,88,32,100,105,114,101,99,116,32,99,104,97,114,97,99,116,101,114,32,107,101,121,32,102,105,101,108,100,32,119,105,100,116,104,32,109,117,115,116,32,98,101,32,60,61,50,52,48,10,0
	.align 8
.Lhrdbfw_C94:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,114,101,97,100,45,111,110,108,121,32,111,112,101,110,32,114,101,106,101,99,116,101,100,32,40,115,117,98,115,101,116,44,32,102,111,114,109,97,116,44,32,68,66,70,32,109,105,115,109,97,116,99,104,44,32,115,105,122,101,32,111,114,32,73,47,79,41,10,0
	.align 8
.Lhrdbfw_C95:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,111,110,108,121,32,111,110,101,32,105,110,100,101,120,32,105,115,32,115,117,112,112,111,114,116,101,100,10,0
	.align 8
.Lhrdbfw_C96:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,108,101,110,103,116,104,32,111,117,116,115,105,100,101,32,115,117,112,112,111,114,116,101,100,32,114,97,110,103,101,10,0
	.align 8
.Lhrdbfw_C97:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,102,105,108,101,110,97,109,101,32,99,111,110,116,97,105,110,115,32,78,85,76,10,0
	.align 8
.Lhrdbfw_C98:

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
	je	.Lhrdbfw_2015
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2016
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.Lhrdbfw_2017
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.Lhrdbfw_1944
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1946:
	cmpq	%rcx, %r9
	je	.Lhrdbfw_2018
.Lhrdbfw_1982:
	movq	%rcx, %rdx
.Lhrdbfw_1944:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.Lhrdbfw_2019
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.Lhrdbfw_1986
	cmpb	$92, %al
	jne	.Lhrdbfw_1946
.Lhrdbfw_1986:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.Lhrdbfw_1982
.Lhrdbfw_2018:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.Lhrdbfw_1948
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.Lhrdbfw_1950
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1983:
	movq	%r11, %rax
.Lhrdbfw_1950:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_1983
	testl	%ebx, %ebx
	je	.Lhrdbfw_1954
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.Lhrdbfw_1980
.Lhrdbfw_1955:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1978
.Lhrdbfw_1979:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1960
	testl	%ebx, %ebx
	je	.Lhrdbfw_1962
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
	jne	.Lhrdbfw_1974
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.Lhrdbfw_1973:
	cmpq	$67108864, %rbp
	ja	.Lhrdbfw_2014
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
	je	.Lhrdbfw_2014
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
	je	.Lhrdbfw_1967
	cmpl	$5, %eax
	je	.Lhrdbfw_1968
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2014:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1960
.Lhrdbfw_1969:
	leaq	.Lhrdbfw_C94(%rip), %rcx
	jmp	.Lhrdbfw_1970
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1954:
	testl	%r10d, %r10d
	je	.Lhrdbfw_1953
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1960
.Lhrdbfw_1962:
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
	jne	.Lhrdbfw_1974
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	hrdbf_app_order+48(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.Lhrdbfw_1973
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1953:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.Lhrdbfw_1977:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.Lhrdbfw_1979
.Lhrdbfw_1948:
	testl	%ebx, %ebx
	je	.Lhrdbfw_1953
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.Lhrdbfw_2020
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1978:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.Lhrdbfw_1977
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1974:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.Lhrdbfw_1960:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.Lhrdbfw_1969
	cmpl	$3, %eax
	je	.Lhrdbfw_1971
	jmp	.Lhrdbfw_1969
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1967:
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
.Lhrdbfw_2020:
	xorl	%r10d, %r10d
.Lhrdbfw_1980:
	testq	%rdi, %rdi
	je	.Lhrdbfw_1956
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1959:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.Lhrdbfw_1959
	testl	%r11d, %r11d
	je	.Lhrdbfw_1955
.Lhrdbfw_1956:
	leaq	.Lhrdbfw_C98(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_1968:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.Lhrdbfw_1960
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_1969
.Lhrdbfw_1971:
	leaq	.Lhrdbfw_C93(%rip), %rcx
.Lhrdbfw_1970:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2019:
	leaq	.Lhrdbfw_C97(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2016:
	leaq	.Lhrdbfw_C95(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2015:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2017:
	leaq	.Lhrdbfw_C96(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2047
	movq	hrdbf_app_order+64(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rcx, %rcx
	je	.Lhrdbfw_2048
	movq	$0, hrdbf_app_order+64(%rip)
	call CloseHandle
	movq	hrdbf_app_order+32(%rip), %rcx
	testl	%eax, %eax
	jne	.Lhrdbfw_2027
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_2049
.Lhrdbfw_2024:
	xorl	%edx, %edx
	leaq VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_2028
	movq	hrdbf_app_order+40(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.Lhrdbfw_2029
.Lhrdbfw_2025:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.Lhrdbfw_2029
.Lhrdbfw_2050:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbfw_2030:
	testl	%esi, %esi
	jne	.Lhrdbfw_2029
.Lhrdbfw_2026:
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2027:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2024
.Lhrdbfw_2045:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.Lhrdbfw_2026
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.Lhrdbfw_2050
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2029:
	leaq	.Lhrdbfw_C91(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2048:
	movq	hrdbf_app_order+32(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2024
	jmp	.Lhrdbfw_2045
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2028:
	movq	hrdbf_app_order+40(%rip), %rcx
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2025
	jmp	.Lhrdbfw_2030
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2049:
	movq	hrdbf_app_order+40(%rip), %rcx
	leaq VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.Lhrdbfw_2025
	jmp	.Lhrdbfw_2029
.Lhrdbfw_2047:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
hrdbfw_app_found:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2056
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbfw_2056:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C99:

.byte 104,98,99,58,32,68,66,70,32,105,110,100,101,120,32,115,101,101,107,32,114,101,113,117,105,114,101,115,32,97,110,32,111,112,101,110,32,105,110,100,101,120,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2063
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbfw_2064
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
	jb	.Lhrdbfw_2065
	movl	hrdbf_app_state+16(%rip), %r9d
	addq	$1, %r9
.Lhrdbfw_2061:
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
.Lhrdbfw_2065:
	movq	hrdbf_app_order+16(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.Lhrdbfw_2061
.Lhrdbfw_2064:
	leaq	.Lhrdbfw_C99(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2063:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
hrdbfw_app_recno:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2071
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbfw_2071:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
hrdbfw_app_lastrec:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2077
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbfw_2077:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
hrdbfw_app_bof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2083
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbfw_2083:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
hrdbfw_app_eof:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2089
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbfw_2089:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
hrdbfw_app_deleted:
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2097
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbfw_2090
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbfw_2090:
	movq	%r8, %rax
	ret
.Lhrdbfw_2097:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2104
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.Lhrdbfw_2100
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rax, %rdx
	jle	.Lhrdbfw_2101
.Lhrdbfw_2100:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2101:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.Lhrdbfw_2104:
	leaq	.Lhrdbfw_C75(%rip), %rcx
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
	je	.Lhrdbfw_2106
	movzwl	hrdbf_app_state+36(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.Lhrdbfw_2108
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2120:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2109:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2110
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2109
.Lhrdbfw_2110:
	cmpq	%r8, %rax
	je	.Lhrdbfw_2130
.Lhrdbfw_2112:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.Lhrdbfw_2120
.Lhrdbfw_2108:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2130:
	testq	%r8, %r8
	je	.Lhrdbfw_2113
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2117
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2131:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.Lhrdbfw_2113
.Lhrdbfw_2117:
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
	je	.Lhrdbfw_2131
	cmpq	%rcx, %r8
	jne	.Lhrdbfw_2112
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2113:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.Lhrdbfw_2118
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
.Lhrdbfw_2118:
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
.Lhrdbfw_2106:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C100:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,111,114,100,105,110,97,108,32,111,117,116,115,105,100,101,32,116,104,101,32,111,112,101,110,32,97,114,101,97,10,0
	.align 8
.Lhrdbfw_C101:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,116,121,112,101,32,109,105,115,109,97,116,99,104,10,0
	.align 8
.Lhrdbfw_C102:

.byte 104,98,99,58,32,68,66,70,32,102,105,101,108,100,32,119,114,105,116,101,32,101,110,99,111,100,105,110,103,32,114,101,106,101,99,116,101,100,10,0
	.align 8
.Lhrdbfw_C103:

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
	jle	.Lhrdbfw_2133
	movzwl	hrdbf_app_state+36(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r9
	cmpq	%rbx, %rax
	jl	.Lhrdbfw_2133
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
	je	.Lhrdbfw_2135
	ja	.Lhrdbfw_2136
	cmpb	$67, %al
	je	.Lhrdbfw_2137
	cmpb	$68, %al
	jne	.Lhrdbfw_2139
	cmpl	$11, %r8d
	je	.Lhrdbfw_2194
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2139
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2148
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2159
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2195:
	addq	$1, %rax
.Lhrdbfw_2159:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2195
.Lhrdbfw_2144:
	movq	hrdbf_app_state+24(%rip), %rdx
.Lhrdbfw_2148:
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.Lhrdbfw_2196
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2136:
	cmpb	$78, %al
	jne	.Lhrdbfw_2139
	cmpl	$12, %r8d
	je	.Lhrdbfw_2197
	testl	%r8d, %r8d
	je	.Lhrdbfw_2167
	cmpl	$9, %r8d
	je	.Lhrdbfw_2167
	cmpl	$5, %r8d
	je	.Lhrdbfw_2198
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2139
	addq	$2, %r10
	salq	$4, %r10
	addq	%r10, %r9
	movzbl	22(%r9), %r8d
	movzwl	24(%r9), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2148
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2157
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2199:
	addq	$1, %rax
.Lhrdbfw_2157:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2199
	jmp	.Lhrdbfw_2144
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2137:
	leal	-2(%r8), %eax
	andl	$-3, %eax
	je	.Lhrdbfw_2200
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2139
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2148
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2149
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2201:
	addq	$1, %rax
.Lhrdbfw_2149:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.Lhrdbfw_2201
	jmp	.Lhrdbfw_2144
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2135:
	cmpl	$3, %r8d
	je	.Lhrdbfw_2202
	cmpl	$1, %r8d
	jne	.Lhrdbfw_2139
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.Lhrdbfw_2148
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.Lhrdbfw_2162
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2203:
	addq	$1, %rax
.Lhrdbfw_2162:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.Lhrdbfw_2203
	jmp	.Lhrdbfw_2144
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2197:
	movl	%edi, %eax
	movq	%rsi, %r8
	movq	%r11, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.Lhrdbfw_2151:
	cmpl	$3, %eax
	je	.Lhrdbfw_2139
	testl	%eax, %eax
	je	.Lhrdbfw_2144
	leaq	.Lhrdbfw_C102(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2202:
	cmpq	$1, %rsi
	movzwl	24(%rbx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	hrdbf_app_state+24(%rip), %rdx
	jmp	.Lhrdbfw_2148
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2200:
	movzwl	24(%rbx), %eax
	movzbl	22(%rbx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%rsi)
	movq	%rdx, %rax
	cmovbe	-8(%rsi), %rax
	testq	%rax, %rax
	je	.Lhrdbfw_2142
	movq	%rcx, %r8
	leaq	(%rsi,%rax), %r11
	subq	%rsi, %r8
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2143:
	movzbl	(%rsi), %edx
	movb	%dl, (%r8,%rsi)
	addq	$1, %rsi
	cmpq	%r11, %rsi
	jne	.Lhrdbfw_2143
	movq	%r10, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r9), %edx
.Lhrdbfw_2142:
	cmpq	%rax, %rdx
	jbe	.Lhrdbfw_2144
	leaq	2(%r10), %rdx
	salq	$4, %rdx
	addq	%rdx, %r9
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2145:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r9), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrdbfw_2145
	jmp	.Lhrdbfw_2144
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2194:
	movl	%esi, %r8d
	movq	%r11, %rdx
	call	hrdbf_write_date
	jmp	.Lhrdbfw_2151
.Lhrdbfw_2139:
	leaq	.Lhrdbfw_C101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2167:
	xorl	%r9d, %r9d
	movq	%rsi, %r8
	movq	%r11, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.Lhrdbfw_2151
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2198:
	testq	%rdi, %rdi
	jns	.Lhrdbfw_2155
	movq	(%rsi), %rsi
.Lhrdbfw_2155:
	movq	%rsi, %xmm2
	movq	%r11, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.Lhrdbfw_2151
.Lhrdbfw_2133:
	leaq	.Lhrdbfw_C100(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2196:
	leaq	.Lhrdbfw_C103(%rip), %rcx
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
	je	.Lhrdbfw_2205
	leaq	hrdbf_app_state+42(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2215:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2206:
	cmpb	$0, (%r10,%rax)
	je	.Lhrdbfw_2207
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.Lhrdbfw_2206
.Lhrdbfw_2207:
	cmpq	%r12, %rax
	je	.Lhrdbfw_2228
.Lhrdbfw_2209:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.Lhrdbfw_2215
.Lhrdbfw_2205:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2228:
	testq	%r12, %r12
	je	.Lhrdbfw_2210
	xorl	%ecx, %ecx
	jmp	.Lhrdbfw_2214
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2229:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.Lhrdbfw_2210
.Lhrdbfw_2214:
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
	je	.Lhrdbfw_2229
	cmpq	%rcx, %r12
	jne	.Lhrdbfw_2209
.Lhrdbfw_2210:
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
.Lhrdbfw_C104:

.byte 104,98,99,58,32,68,66,70,32,97,112,112,101,110,100,32,102,97,105,108,101,100,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_append
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbfw_2238
	movl	hrdbf_app_state+2272(%rip), %eax
	testl	%eax, %eax
	je	.Lhrdbfw_2239
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbfw_2240
	movl	hrdbf_app_state+16(%rip), %eax
	cmpq	%rax, hrdbf_app_state+24(%rip)
	ja	.Lhrdbfw_2241
	cmpq	$0, hrdbf_app_state+2280(%rip)
	je	.Lhrdbfw_2236
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.Lhrdbfw_2236
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2236:
	leaq	.Lhrdbfw_C104(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2238:
	leaq	.Lhrdbfw_C75(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2241:
	leaq	.Lhrdbfw_C78(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2240:
	leaq	.Lhrdbfw_C77(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2239:
	leaq	.Lhrdbfw_C76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C105:

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
	jne	.Lhrdbfw_2245
	movq	56(%rsp), %rax
	leave
	ret
.Lhrdbfw_2245:
	leaq	.Lhrdbfw_C105(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C106:

.byte 104,98,99,58,32,68,66,70,32,100,101,99,105,109,97,108,32,110,117,109,101,114,105,99,32,99,97,110,110,111,116,32,101,110,116,101,114,32,73,54,52,32,111,112,101,114,97,116,105,111,110,10,0
	.align 8
.Lhrdbfw_C107:

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
	jne	.Lhrdbfw_2247
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.Lhrdbfw_2263
	testl	%eax, %eax
	je	.Lhrdbfw_2255
	cmpl	$9, %eax
	jne	.Lhrdbfw_2251
.Lhrdbfw_2255:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2263:
	testl	$65280, %r11d
	je	.Lhrdbfw_2255
.Lhrdbfw_2250:
	leaq	.Lhrdbfw_C106(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2247:
	cmpl	$2, %eax
	je	.Lhrdbfw_2250
.Lhrdbfw_2251:
	leaq	.Lhrdbfw_C107(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C108:

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
	je	.Lhrdbfw_2268
	testl	%eax, %eax
	jne	.Lhrdbfw_2269
	movslq	76(%rsp), %rax
	leave
	ret
.Lhrdbfw_2268:
	leaq	.Lhrdbfw_C106(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2269:
	leaq	.Lhrdbfw_C108(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C109:

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
	jne	.Lhrdbfw_2271
	movq	%rcx, 32(%rsp)
	movq	%rdx, 40(%rsp)
	cmpb	$11, %r8b
	je	.Lhrdbfw_2313
	leaq	32(%rsp), %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2277
.Lhrdbfw_2281:
	leaq	.Lhrdbfw_C107(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2277:
	cmpl	$2, %eax
	jne	.Lhrdbfw_2281
.Lhrdbfw_2280:
	leaq	.Lhrdbfw_C106(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2271:
	leaq	32(%rsp), %r12
	movq	%rcx, 32(%rsp)
	movzbl	%cl, %r13d
	movq	%r12, %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2277
	cmpl	$12, %r13d
	jne	.Lhrdbfw_2278
	testl	$65280, %r11d
	jne	.Lhrdbfw_2280
.Lhrdbfw_2279:
	movq	%r12, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2277
	movzbl	%bl, %eax
	cmpb	$12, %bl
	je	.Lhrdbfw_2314
	testl	%eax, %eax
	je	.Lhrdbfw_2287
	cmpl	$9, %eax
	jne	.Lhrdbfw_2281
.Lhrdbfw_2287:
	cmpq	%rdi, %rsi
	jl	.Lhrdbfw_2289
	setg	%al
	movzbl	%al, %eax
.Lhrdbfw_2270:
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
.Lhrdbfw_2278:
	testl	%r13d, %r13d
	je	.Lhrdbfw_2279
	cmpl	$9, %r13d
	je	.Lhrdbfw_2279
	jmp	.Lhrdbfw_2281
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2289:
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
.Lhrdbfw_2313:
	leaq	32(%rsp), %r11
	movq	%r11, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2274
	movq	%r11, %rcx
	movq	%rbx, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2274
	cmpq	%rdi, %rsi
	jb	.Lhrdbfw_2289
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbfw_2270
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2314:
	andb	$-1, %bh
	je	.Lhrdbfw_2287
	jmp	.Lhrdbfw_2280
.Lhrdbfw_2274:
	leaq	.Lhrdbfw_C109(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C110:

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
	jne	.Lhrdbfw_2316
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbfw_2328
	movabs	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.Lhrdbfw_2318
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2336:
	btq	%rax, %rcx
	jnc	.Lhrdbfw_2332
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.Lhrdbfw_2328
.Lhrdbfw_2318:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.Lhrdbfw_2336
.Lhrdbfw_2332:
	xorl	%eax, %eax
.Lhrdbfw_2315:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2316:
	cmpl	$8, %ebx
	je	.Lhrdbfw_2337
	cmpl	$5, %ebx
	je	.Lhrdbfw_2338
	cmpl	$7, %ebx
	je	.Lhrdbfw_2332
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbfw_2323
	cmpl	$12, %ebx
	ja	.Lhrdbfw_2323
	leaq	.Lhrdbfw_2325(%rip), %rdx
	movslq	(%rdx,%rbx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.Lhrdbfw_2325:
	.long	.Lhrdbfw_2324-.Lhrdbfw_2325
	.long	.Lhrdbfw_2328-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2324-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2324-.Lhrdbfw_2325
	.long	.Lhrdbfw_2323-.Lhrdbfw_2325
	.long	.Lhrdbfw_2324-.Lhrdbfw_2325
	.long	.Lhrdbfw_2324-.Lhrdbfw_2325
	.text
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2328:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2337:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.Lhrdbfw_2315
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.Lhrdbfw_2315
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2323:
	leaq	.Lhrdbfw_C110(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbfw_2338:
	testq	%rcx, %rcx
	js	.Lhrdbfw_2339
.Lhrdbfw_2322:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.Lhrdbfw_C65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.Lhrdbfw_2315
.Lhrdbfw_2324:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.Lhrdbfw_2315
.Lhrdbfw_2339:
	movq	(%rdx), %r11
	jmp	.Lhrdbfw_2322
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C111:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,100,105,118,105,115,105,111,110,32,98,121,32,122,101,114,111,10,0
	.align 8
.Lhrdbfw_C112:

.byte 104,98,99,58,32,68,66,70,32,97,114,105,116,104,109,101,116,105,99,32,111,110,32,97,32,78,73,76,32,111,114,32,110,111,110,45,110,117,109,101,114,105,99,32,111,112,101,114,97,110,100,10,0
.Lhrdbfw_C113:

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
	je	.Lhrdbfw_2345
	cmpl	$1, %eax
	je	.Lhrdbfw_2346
	testl	%eax, %eax
	jne	.Lhrdbfw_2347
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.Lhrdbfw_2345:
	leaq	.Lhrdbfw_C111(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2347:
	leaq	.Lhrdbfw_C113(%rip), %rcx
	call	hrdbf_app_fail
.Lhrdbfw_2346:
	leaq	.Lhrdbfw_C112(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.Lhrdbfw_C114:

.byte 104,98,99,58,32,68,66,70,45,97,99,116,105,118,101,32,100,121,110,97,109,105,99,32,115,99,97,108,97,114,32,99,111,110,115,117,109,101,114,32,105,115,32,111,117,116,115,105,100,101,32,116,104,101,32,97,100,109,105,116,116,101,100,32,115,117,98,115,101,116,10,0
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.Lhrdbfw_C114(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
hrdbfw_local_CSWTCH.335:
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
.Lhrdbfw_C0:
	.long	0
	.long	1076101120
	.align 8
.Lhrdbfw_C65:
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
