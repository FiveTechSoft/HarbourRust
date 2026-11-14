	.file	"hrdbf_embedded_linux.c"
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
	je	.Lhrdbf_50
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_50:
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
	je	.Lhrdbf_53
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_53
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_55
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
.Lhrdbf_57:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_67
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_53:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_55:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_58
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_53
	.p2align 4,,10
	.p2align 3
.Lhrdbf_67:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_53
	.p2align 4,,10
	.p2align 3
.Lhrdbf_58:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_57
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
	je	.Lhrdbf_147
	testl	%esi, %esi
	je	.Lhrdbf_148
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_148
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
	ja	.Lhrdbf_148
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_151
	cmpb	$78, %r8b
	je	.Lhrdbf_152
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_153
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_94
	cmpb	$89, %dl
	je	.Lhrdbf_94
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_148
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_147
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_147
	.p2align 4,,10
	.p2align 3
.Lhrdbf_148:
	xorl	%r8d, %r8d
.Lhrdbf_147:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_94:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_151:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_147
	.p2align 4,,10
	.p2align 3
.Lhrdbf_152:
	testl	%edi, %edi
	je	.Lhrdbf_148
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_73
	.p2align 4,,10
	.p2align 3
.Lhrdbf_74:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_148
.Lhrdbf_73:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_74
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_76
	.p2align 4,,10
	.p2align 3
.Lhrdbf_100:
	movl	%edx, %edi
.Lhrdbf_76:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_75
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_100
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_120
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_98:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_78:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_105
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_97:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_82
	.p2align 4,,10
	.p2align 3
.Lhrdbf_154:
	testl	%ebx, %ebx
	jne	.Lhrdbf_121
	movl	$1, %ebx
.Lhrdbf_79:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_81
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_82:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_154
.Lhrdbf_121:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_105
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_111
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_79
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_79
	.p2align 4,,10
	.p2align 3
.Lhrdbf_153:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_91:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_113
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_91
	jmp	.Lhrdbf_148
.Lhrdbf_113:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_90:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_114
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_90
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
	jbe	.Lhrdbf_147
	cmpl	$11, %edx
	ja	.Lhrdbf_147
	testl	%edi, %edi
	je	.Lhrdbf_147
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_155
.Lhrdbf_92:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_147
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_147
.Lhrdbf_81:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_68
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_68
	leal	1(%r13), %eax
	jbe	.Lhrdbf_83
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_84
	jmp	.Lhrdbf_111
	.p2align 4,,10
	.p2align 3
.Lhrdbf_85:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_111
.Lhrdbf_84:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_85
	testl	%r12d, %r12d
	jne	.Lhrdbf_96
.Lhrdbf_87:
	movq	%r11, %rax
.Lhrdbf_88:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_68:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_111:
	movl	$4, %r8d
	jmp	.Lhrdbf_68
.Lhrdbf_75:
	je	.Lhrdbf_70
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_78
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_98
	.p2align 4,,10
	.p2align 3
.Lhrdbf_70:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_68
.Lhrdbf_105:
	movl	$5, %r8d
	jmp	.Lhrdbf_68
.Lhrdbf_120:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_97
.Lhrdbf_114:
	movl	$5, %r8d
	jmp	.Lhrdbf_147
.Lhrdbf_155:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_92
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_93
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_92
.Lhrdbf_93:
	addl	$1, %r10d
	jmp	.Lhrdbf_92
.Lhrdbf_83:
	testl	%r12d, %r12d
	je	.Lhrdbf_87
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_88
.Lhrdbf_96:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_88
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_156
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_158
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_158:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_156:
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
	jbe	.Lhrdbf_197
	cmpb	$3, (%rsi)
	movl	$2, %eax
	jne	.Lhrdbf_161
	cmpb	$0, 14(%rsi)
	jne	.Lhrdbf_161
	cmpb	$0, 15(%rsi)
	jne	.Lhrdbf_161
	cmpb	$0, 28(%rsi)
	jne	.Lhrdbf_161
	cmpb	$0, 29(%rsi)
	jne	.Lhrdbf_161
	movzwl	8(%rsi), %eax
	movzwl	10(%rsi), %r13d
	movl	4(%rsi), %r15d
	movw	%ax, 112(%rsp)
	movw	%r13w, 114(%rsp)
	movl	%r15d, 96(%rsp)
	cmpw	$32, %ax
	jbe	.Lhrdbf_197
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
	je	.Lhrdbf_213
	.p2align 4,,10
	.p2align 3
.Lhrdbf_197:
	movl	$1, %eax
.Lhrdbf_161:
	addq	$2184, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_213:
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
.Lhrdbf_177:
	movzbl	(%r11), %ecx
	movl	%r14d, %edi
	cmpb	$13, %cl
	je	.Lhrdbf_214
	cmpq	8(%rsp), %r14
	je	.Lhrdbf_197
	cmpq	$4128, %r8
	je	.Lhrdbf_198
	movl	%r14d, %eax
	movl	%r14d, %ebx
	xorl	%edx, %edx
	jmp	.Lhrdbf_168
	.p2align 4,,10
	.p2align 3
.Lhrdbf_215:
	movzbl	(%r11,%rdx), %ecx
.Lhrdbf_168:
	movb	%cl, 42(%r10,%rdx)
	addq	$1, %rdx
	cmpq	$11, %rdx
	jne	.Lhrdbf_215
	movzbl	42(%r10), %r12d
	testb	%r12b, %r12b
	je	.Lhrdbf_197
	leal	1(%rax), %edx
	cmpl	$1, %edx
	jbe	.Lhrdbf_169
	leal	-1(%rax), %ebp
	leaq	149(%rsp), %rax
	xorl	%edi, %edi
	salq	$4, %rbp
	leaq	133(%rsp), %rcx
	addq	%rax, %rbp
	.p2align 4,,10
	.p2align 3
.Lhrdbf_170:
	leaq	-11(%rcx), %rax
	movl	%r12d, %edx
	jmp	.Lhrdbf_172
	.p2align 4,,10
	.p2align 3
.Lhrdbf_217:
	leaq	(%rdi,%rax), %rdx
	movzbl	(%rdx,%r9), %edx
.Lhrdbf_172:
	cmpb	%dl, (%rax)
	jne	.Lhrdbf_216
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_217
	movl	$1, %eax
	jmp	.Lhrdbf_161
	.p2align 4,,10
	.p2align 3
.Lhrdbf_216:
	addq	$16, %rcx
	subq	$16, %rdi
	cmpq	%rbp, %rcx
	jne	.Lhrdbf_170
.Lhrdbf_169:
	movzbl	11(%r11), %edx
	movzbl	16(%r11), %eax
	movw	%si, 56(%r10)
	movzbl	17(%r11), %ecx
	movb	%dl, 53(%r10)
	movb	%al, 54(%r10)
	movb	%cl, 55(%r10)
	testb	%al, %al
	je	.Lhrdbf_197
	cmpb	$67, %dl
	je	.Lhrdbf_218
	cmpb	$78, %dl
	je	.Lhrdbf_219
	cmpb	$76, %dl
	je	.Lhrdbf_220
	cmpb	$68, %dl
	jne	.Lhrdbf_196
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	jne	.Lhrdbf_197
.Lhrdbf_174:
	addl	%eax, %esi
	cmpl	$65535, %esi
	ja	.Lhrdbf_198
	addq	$32, %r8
	addq	$1, %r14
	addq	$32, %r11
	addq	$16, %r10
	addq	$16, %r9
	movl	$1, %eax
	cmpq	%r8, (%rsp)
	ja	.Lhrdbf_177
	jmp	.Lhrdbf_197
.Lhrdbf_218:
	testb	%cl, %cl
	je	.Lhrdbf_174
.Lhrdbf_196:
	movl	$3, %eax
	jmp	.Lhrdbf_161
	.p2align 4,,10
	.p2align 3
.Lhrdbf_219:
	cmpb	%cl, %al
	jbe	.Lhrdbf_198
	cmpb	$17, %cl
	jbe	.Lhrdbf_174
.Lhrdbf_198:
	movl	$4, %eax
	jmp	.Lhrdbf_161
.Lhrdbf_220:
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.Lhrdbf_174
	jmp	.Lhrdbf_197
	.p2align 4,,10
	.p2align 3
.Lhrdbf_214:
	movl	%esi, %edx
	movq	%r8, %rcx
	movq	24(%rsp), %rbx
	movq	32(%rsp), %rsi
	movq	40(%rsp), %r8
	testb	%al, %al
	je	.Lhrdbf_197
	movw	%r14w, 116(%rsp)
	cmpl	%edx, 20(%rsp)
	jne	.Lhrdbf_197
	testw	%r14w, %r14w
	je	.Lhrdbf_197
	movq	%rcx, %rax
	addq	$1, %rax
	jmp	.Lhrdbf_165
.Lhrdbf_178:
	addq	$1, %rax
	cmpb	$0, -1(%rsi,%rax)
	jne	.Lhrdbf_197
.Lhrdbf_165:
	cmpq	%rax, (%rsp)
	ja	.Lhrdbf_178
	movq	(%rsp), %rcx
	movq	%r8, %rax
	xorl	%edx, %edx
	movl	%r15d, %ebp
	subq	%rcx, %rax
	divq	%r13
	cmpq	%rax, %rbp
	ja	.Lhrdbf_197
	movq	%rbp, %rax
	imulq	%r13, %rax
	addq	%rcx, %rax
	cmpq	%rax, %r8
	je	.Lhrdbf_179
	movq	%r8, %rdx
	subq	%rax, %rdx
	subq	$1, %rdx
	jne	.Lhrdbf_197
	cmpb	$26, (%rsi,%rax)
	jne	.Lhrdbf_197
.Lhrdbf_179:
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
.Lhrdbf_180:
	cmpq	%r14, %rbp
	jbe	.Lhrdbf_221
	movzbl	(%r12), %eax
	cmpb	$32, %al
	je	.Lhrdbf_200
	cmpb	$42, %al
	jne	.Lhrdbf_199
.Lhrdbf_200:
	addq	$1, %r14
	movl	$1, %r15d
	movq	%r14, 104(%rsp)
	jmp	.Lhrdbf_182
.Lhrdbf_223:
	addl	$1, %r15d
	cmpl	%r15d, (%rsp)
	jb	.Lhrdbf_222
.Lhrdbf_182:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	je	.Lhrdbf_223
	jmp	.Lhrdbf_161
.Lhrdbf_221:
	movl	$262, %ecx
	movq	%rbx, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.Lhrdbf_161
.Lhrdbf_199:
	movl	$5, %eax
	jmp	.Lhrdbf_161
.Lhrdbf_222:
	addq	%r13, %r12
	jmp	.Lhrdbf_180
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
	ja	.Lhrdbf_226
	je	.Lhrdbf_245
	xorl	%eax, %eax
	cmpl	$5, %edx
	je	.Lhrdbf_226
	shrq	$8, %rdi
	movl	$4, %eax
	jne	.Lhrdbf_226
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_226
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_226
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_226
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_226
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
	ja	.Lhrdbf_241
	testq	%rsi, %rsi
	je	.Lhrdbf_241
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_246
.Lhrdbf_229:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_245:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_226
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_247
.Lhrdbf_226:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_247:
	testb	$-1, %dh
	jne	.Lhrdbf_226
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
.Lhrdbf_241:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_246:
	testb	$3, %cl
	jne	.Lhrdbf_229
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_230
	addl	$1, %eax
	jmp	.Lhrdbf_229
.Lhrdbf_230:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_229
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
	ja	.Lhrdbf_248
	movzbl	hrdbf_local_CSWTCH.115(%rdx), %eax
.Lhrdbf_248:
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
	jne	.Lhrdbf_251
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_261
	testl	%edx, %edx
	je	.Lhrdbf_254
	cmpl	$9, %edx
	je	.Lhrdbf_254
	movl	$1, %eax
.Lhrdbf_251:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_261:
	testl	$65280, %r9d
	jne	.Lhrdbf_262
.Lhrdbf_254:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_262:
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
	jne	.Lhrdbf_263
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_263
	movzbl	%bpl, %r13d
	movzbl	%r10b, %r12d
	cmpb	$11, %bpl
	jne	.Lhrdbf_265
	cmpl	$11, %r12d
	jne	.Lhrdbf_265
.Lhrdbf_278:
	xorl	%edx, %edx
	cmpq	%r11, %r9
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_263:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_265:
	cmpl	$1, %r13d
	je	.Lhrdbf_281
	cmpl	$1, %r12d
	je	.Lhrdbf_281
	cmpl	$3, %r13d
	jne	.Lhrdbf_268
	cmpl	$3, %r12d
	jne	.Lhrdbf_268
	testq	%r9, %r9
	sete	%dl
	testq	%r11, %r11
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_263
	.p2align 4,,10
	.p2align 3
.Lhrdbf_281:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_263
	.p2align 4,,10
	.p2align 3
.Lhrdbf_268:
	movq	%rbp, %rdi
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_263
	cmpl	$12, %r13d
	je	.Lhrdbf_304
	testl	%r13d, %r13d
	je	.Lhrdbf_271
	movl	$1, %eax
	cmpl	$9, %r13d
	jne	.Lhrdbf_263
.Lhrdbf_271:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_263
	cmpl	$12, %r12d
	je	.Lhrdbf_305
	testl	%r12d, %r12d
	je	.Lhrdbf_278
	cmpl	$9, %r12d
	je	.Lhrdbf_278
	movl	$1, %eax
	jmp	.Lhrdbf_263
	.p2align 4,,10
	.p2align 3
.Lhrdbf_304:
	testl	$65280, %ebp
	je	.Lhrdbf_271
.Lhrdbf_277:
	movl	$2, %eax
	jmp	.Lhrdbf_263
	.p2align 4,,10
	.p2align 3
.Lhrdbf_305:
	testl	$65280, %r10d
	je	.Lhrdbf_278
	jmp	.Lhrdbf_277
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
	jne	.Lhrdbf_306
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_310
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_308
	cmpl	$1, %ecx
	je	.Lhrdbf_311
.Lhrdbf_310:
	movl	$1, %eax
.Lhrdbf_306:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_308:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_311:
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
	jne	.Lhrdbf_312
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_359
	cmpl	$12, %eax
	jne	.Lhrdbf_338
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
.Lhrdbf_320:
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
	ja	.Lhrdbf_320
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_360
	movl	$1, %esi
.Lhrdbf_321:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_322:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_323
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_361
	subl	%eax, %r14d
	je	.Lhrdbf_331
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_330:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_330
.Lhrdbf_331:
	testq	%r11, %r11
	jns	.Lhrdbf_329
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_329:
	testl	%esi, %esi
	je	.Lhrdbf_332
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_334
	.p2align 4,,10
	.p2align 3
.Lhrdbf_342:
	movl	%edx, %eax
.Lhrdbf_334:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_333
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_333:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_342
	addl	%esi, %r14d
.Lhrdbf_332:
	testl	%r10d, %r10d
	je	.Lhrdbf_312
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_336:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_335
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_335:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_336
.Lhrdbf_312:
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
.Lhrdbf_359:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_323
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_316
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_318:
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
	jne	.Lhrdbf_318
	jmp	.Lhrdbf_312
	.p2align 4,,10
	.p2align 3
.Lhrdbf_338:
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
.Lhrdbf_360:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_321
	movl	%esi, %eax
	jmp	.Lhrdbf_322
	.p2align 4,,10
	.p2align 3
.Lhrdbf_323:
	movl	$3, %r8d
	jmp	.Lhrdbf_312
	.p2align 4,,10
	.p2align 3
.Lhrdbf_316:
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
	jmp	.Lhrdbf_312
	.p2align 4,,10
	.p2align 3
.Lhrdbf_361:
	testl	%r14d, %r14d
	je	.Lhrdbf_312
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_326:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_326
	jmp	.Lhrdbf_312
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
	ja	.Lhrdbf_362
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.134(,%rdi,8), %rax
.Lhrdbf_362:
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
	je	.Lhrdbf_368
	movq	2104(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_369
.Lhrdbf_368:
	movq	$0, 2096(%r8)
	xorl	%eax, %eax
	movq	$0, 2104(%r8)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_369:
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
	je	.Lhrdbf_371
	.p2align 4,,10
	.p2align 3
.Lhrdbf_372:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_372
.Lhrdbf_371:
	movl	$1, %eax
	movl	$2, %edi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	hrdbf_app_order+32(%rip), %rdi
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_374
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_374
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_374:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_377
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_377
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_377:
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
	.size	hrdbf_app_fail, .-hrdbf_app_fail
	.p2align 4
	.globl	hrdbf_file_open
	.type	hrdbf_file_open, @function
hrdbf_file_open:
.Lhrdbf_entry_hrdbf_file_open:
	endbr64
	pushq	%r13
	movq	%rsi, %r8
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
	je	.Lhrdbf_385
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_405
.Lhrdbf_385:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$0, 2096(%rbp)
	movq	$0, 2104(%rbp)
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_383:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_383
	testq	%rax, %rax
	js	.Lhrdbf_405
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
	js	.Lhrdbf_425
	cmpq	$32, %rax
	jle	.Lhrdbf_426
	cmpq	$67108864, %rax
	jg	.Lhrdbf_427
	movq	%r8, %rax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_428
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
	jb	.Lhrdbf_394
	movq	$0, 2096(%rbp)
.Lhrdbf_395:
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
	jns	.Lhrdbf_389
	.p2align 4,,10
	.p2align 3
.Lhrdbf_424:
	movl	$7, %r8d
	jmp	.Lhrdbf_389
	.p2align 4,,10
	.p2align 3
.Lhrdbf_405:
	movl	$7, %r8d
.Lhrdbf_381:
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_425:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
.Lhrdbf_389:
	movq	2096(%rbp), %rdi
	movq	$0, 0(%rbp)
	movq	$0, 8(%rbp)
	movl	$0, 16(%rbp)
	movq	$0, 24(%rbp)
	movl	$16842752, 36(%rbp)
	movb	$0, 40(%rbp)
	testq	%rdi, %rdi
	je	.Lhrdbf_404
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_405
.Lhrdbf_404:
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
.Lhrdbf_427:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_389
	jmp	.Lhrdbf_424
	.p2align 4,,10
	.p2align 3
.Lhrdbf_426:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_389
	jmp	.Lhrdbf_424
	.p2align 4,,10
	.p2align 3
.Lhrdbf_394:
	movq	%rax, 2096(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_395
	movq	2104(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_396
	jmp	.Lhrdbf_397
	.p2align 4,,10
	.p2align 3
.Lhrdbf_429:
	movq	2096(%rbp), %rsi
.Lhrdbf_396:
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
	je	.Lhrdbf_398
	testq	%rax, %rax
	jle	.Lhrdbf_408
	addq	%rax, %r8
.Lhrdbf_398:
	movq	2104(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_429
.Lhrdbf_397:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_400:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_400
	testq	%rax, %rax
	je	.Lhrdbf_401
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.Lhrdbf_389
.Lhrdbf_401:
	movq	2104(%rbp), %rdx
	movq	2096(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movl	%eax, %r8d
.Lhrdbf_399:
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
	js	.Lhrdbf_424
	testl	%r8d, %r8d
	je	.Lhrdbf_381
	jmp	.Lhrdbf_389
	.p2align 4,,10
	.p2align 3
.Lhrdbf_428:
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_424
.Lhrdbf_408:
	movl	$7, %r8d
	jmp	.Lhrdbf_399
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
	ja	.Lhrdbf_431
	movq	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrdbf_431
	testl	$1023, %edx
	jne	.Lhrdbf_431
	testq	%rbp, %rbp
	je	.Lhrdbf_431
	cmpb	$0, 40(%rbp)
	je	.Lhrdbf_431
	cmpw	$6, (%rsi)
	movl	$2, %r10d
	jne	.Lhrdbf_431
	cmpw	$0, 16(%rsi)
	jne	.Lhrdbf_431
	movq	%rdi, %rbx
	movq	$-260, %rcx
	jmp	.Lhrdbf_434
	.p2align 4,,10
	.p2align 3
.Lhrdbf_433:
	addq	$1, %rcx
	cmpq	$486, %rcx
	je	.Lhrdbf_495
.Lhrdbf_434:
	cmpq	$11, %rcx
	jbe	.Lhrdbf_433
	cmpb	$0, 538(%rax,%rcx)
	je	.Lhrdbf_433
.Lhrdbf_467:
	movl	$2, %r10d
.Lhrdbf_431:
	addq	$72, %rsp
	movl	%r10d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_495:
	movzwl	14(%rax), %r15d
	movl	$1, %r10d
	leal	-1(%r15), %ecx
	cmpw	$254, %cx
	ja	.Lhrdbf_431
	leal	8(%r15), %edi
	movw	%di, 2(%rsp)
	cmpw	%di, 12(%rax)
	jne	.Lhrdbf_431
	movzwl	18(%rax), %esi
	leal	-1(%rsi), %ecx
	movw	%si, 4(%rsp)
	cmpw	$509, %cx
	ja	.Lhrdbf_431
	movl	%esi, %ecx
	shrw	%cx
	cmpw	20(%rax), %cx
	jne	.Lhrdbf_431
	leal	1(%rsi), %ecx
	movzwl	%di, %edi
	xorl	%r12d, %r12d
	movzwl	%cx, %esi
	addq	%rcx, %rcx
	imulq	%rdi, %rsi
	andl	$131070, %ecx
	leaq	2(%rsi,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.Lhrdbf_435
	jmp	.Lhrdbf_431
	.p2align 4,,10
	.p2align 3
.Lhrdbf_436:
	addq	$1, %r12
	cmpq	$256, %r12
	je	.Lhrdbf_467
.Lhrdbf_435:
	cmpb	$0, 22(%rax,%r12)
	jne	.Lhrdbf_436
	testq	%r12, %r12
	je	.Lhrdbf_467
	movzwl	36(%rbp), %esi
	movw	%si, 6(%rsp)
	testq	%rsi, %rsi
	je	.Lhrdbf_467
	movq	%rdx, 8(%rsp)
	movq	%rbp, %r13
	xorl	%r14d, %r14d
	movq	%rsi, %rdx
.Lhrdbf_437:
	xorl	%esi, %esi
	jmp	.Lhrdbf_446
	.p2align 4,,10
	.p2align 3
.Lhrdbf_496:
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
	jne	.Lhrdbf_439
	addq	$1, %rsi
	cmpq	%r12, %rsi
	jnb	.Lhrdbf_438
	cmpq	$10, %rsi
	ja	.Lhrdbf_438
.Lhrdbf_446:
	movzbl	42(%r13,%rsi), %ecx
	testb	%cl, %cl
	jne	.Lhrdbf_496
.Lhrdbf_439:
	cmpq	%r12, %rsi
	je	.Lhrdbf_451
.Lhrdbf_443:
	addq	$1, %r14
	addq	$16, %r13
	cmpq	%rdx, %r14
	jne	.Lhrdbf_437
	jmp	.Lhrdbf_467
.Lhrdbf_438:
	cmpq	%r12, %rsi
	jne	.Lhrdbf_443
	cmpq	$11, %rsi
	je	.Lhrdbf_444
.Lhrdbf_451:
	movq	%r14, %rcx
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$0, 42(%rsi,%rcx)
	jne	.Lhrdbf_443
.Lhrdbf_444:
	movq	8(%rsp), %rdx
	movl	%r14d, %esi
	cmpw	%r14w, 6(%rsp)
	je	.Lhrdbf_467
	movq	%r14, %rcx
	movl	$2, %r10d
	salq	$4, %rcx
	addq	%rbp, %rcx
	cmpb	$67, 53(%rcx)
	jne	.Lhrdbf_431
	movzbl	54(%rcx), %ecx
	cmpw	%r15w, %cx
	jne	.Lhrdbf_431
	movl	16(%rbp), %ecx
	cmpq	%r9, %rcx
	ja	.Lhrdbf_473
	testq	%r8, %r8
	jne	.Lhrdbf_474
	testl	%ecx, %ecx
	jne	.Lhrdbf_473
.Lhrdbf_474:
	movq	%rdx, %rdi
	addq	$7, %rcx
	shrq	$10, %rdi
	shrq	$3, %rcx
	addq	$7, %rdi
	shrq	$3, %rdi
	cmpq	$0, 128(%rsp)
	je	.Lhrdbf_473
	addq	%rdi, %rcx
	cmpq	136(%rsp), %rcx
	ja	.Lhrdbf_473
	movq	128(%rsp), %r9
	addq	%r9, %rcx
.Lhrdbf_448:
	movb	$0, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rcx
	jne	.Lhrdbf_448
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
	jne	.Lhrdbf_449
	movl	52(%rsp), %eax
	cmpl	16(%rbp), %eax
	je	.Lhrdbf_450
	movl	$4, %r10d
.Lhrdbf_449:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.Lhrdbf_431
.Lhrdbf_450:
	movl	%eax, 24(%rbx)
	jmp	.Lhrdbf_431
.Lhrdbf_473:
	movl	$3, %r10d
	jmp	.Lhrdbf_431
	.size	hrntx_open, .-hrntx_open
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
	je	.Lhrdbf_498
	movq	(%rdi), %r9
	movq	16(%rdi), %r8
	xorl	%r10d, %r10d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_503:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_516
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_502
	.p2align 4,,10
	.p2align 3
.Lhrdbf_500:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_516
.Lhrdbf_502:
	movzbl	(%rsi,%rax), %r14d
	cmpb	%r14b, (%rcx,%rax)
	je	.Lhrdbf_500
	jnb	.Lhrdbf_516
	leal	1(%rdi), %r10d
.Lhrdbf_499:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_503
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_507
	movl	%r10d, %eax
	leaq	(%r8,%rax,8), %rax
.Lhrdbf_506:
	movl	4(%rax), %ecx
	testq	%rdx, %rdx
	je	.Lhrdbf_508
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_509
	.p2align 4,,10
	.p2align 3
.Lhrdbf_541:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_508
.Lhrdbf_509:
	movzbl	(%rsi,%rax), %edi
	cmpb	%dil, (%rcx,%rax)
	je	.Lhrdbf_541
.Lhrdbf_507:
	testl	%ebp, %ebp
	je	.Lhrdbf_497
	testl	%r12d, %r12d
	jne	.Lhrdbf_542
	movl	%r10d, %r11d
.Lhrdbf_497:
	popq	%rbx
	movl	%r11d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_516:
	movl	%edi, %r11d
	jmp	.Lhrdbf_499
.Lhrdbf_508:
	movl	$1, 0(%r13)
	movl	%r10d, %r11d
	testl	%r12d, %r12d
	je	.Lhrdbf_497
	movl	24(%rbx), %r11d
	cmpl	%r10d, %r11d
	jbe	.Lhrdbf_510
	.p2align 4,,10
	.p2align 3
.Lhrdbf_515:
	movl	%r11d, %edi
	subl	%r10d, %edi
	shrl	%edi
	leal	(%rdi,%r10), %eax
	movl	4(%r8,%rax,8), %ecx
	movq	%rax, %rdi
	testq	%rdx, %rdx
	je	.Lhrdbf_511
	xorl	%eax, %eax
	addq	%r9, %rcx
	jmp	.Lhrdbf_514
	.p2align 4,,10
	.p2align 3
.Lhrdbf_512:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.Lhrdbf_511
.Lhrdbf_514:
	movzbl	(%rsi,%rax), %ebx
	cmpb	%bl, (%rcx,%rax)
	je	.Lhrdbf_512
	jb	.Lhrdbf_511
	movl	%edi, %r11d
.Lhrdbf_513:
	cmpl	%r11d, %r10d
	jb	.Lhrdbf_515
.Lhrdbf_510:
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
.Lhrdbf_511:
	leal	1(%rdi), %r10d
	jmp	.Lhrdbf_513
.Lhrdbf_542:
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
.Lhrdbf_498:
	movl	24(%rdi), %r11d
	testl	%r11d, %r11d
	je	.Lhrdbf_497
	movq	16(%rdi), %r8
	movq	(%rdi), %r9
	xorl	%r10d, %r10d
	movq	%r8, %rax
	jmp	.Lhrdbf_506
	.size	hrntx_seek, .-hrntx_seek
	.section	.rodata.str1.1
.Lhrdbf_C1:
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
	je	.Lhrdbf_544
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
	js	.Lhrdbf_544
	movq	$0, hrdbf_app_order+32(%rip)
	xorl	%r8d, %r8d
	movq	$0, hrdbf_app_order+48(%rip)
.Lhrdbf_544:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_545
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_553
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_545:
	movq	hrdbf_app_state+2096(%rip), %rdi
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_550
	movq	hrdbf_app_state+2104(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_559
.Lhrdbf_550:
	movq	$0, hrdbf_app_state+2096(%rip)
	movq	$0, hrdbf_app_state+2104(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%r8d, %r8d
	jne	.Lhrdbf_547
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_553:
	movl	$7, %r8d
	jmp	.Lhrdbf_545
.Lhrdbf_559:
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.Lhrdbf_547:
	movl	$.Lhrdbf_C1, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_close, .-hrdbf_app_close
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.Lhrdbf_C2:
	.string	"hbc: DBF only one workarea is supported\n"
	.align 8
.Lhrdbf_C3:
	.string	"hbc: DBF filename length outside supported range\n"
	.align 8
.Lhrdbf_C4:
	.string	"hbc: DBF filename contains NUL\n"
	.section	.rodata.str1.1
.Lhrdbf_C5:
	.string	"hbc: NTX close failed\n"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C6:
	.string	"hbc: DBF read-only open rejected (format, data, size or I/O)\n"
	.text
	.p2align 4
	.globl	hrdbf_app_open
	.type	hrdbf_app_open, @function
hrdbf_app_open:
.Lhrdbf_entry_hrdbf_app_open:
	endbr64
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$8, %rsp
	testq	%rdx, %rdx
	je	.Lhrdbf_561
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_583
.Lhrdbf_561:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_584
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_562:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.Lhrdbf_585
	movb	%dl, (%rsp,%rax)
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbf_562
	movq	hrdbf_app_order+32(%rip), %r9
	movb	$0, (%rsp,%rsi)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_586
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
	js	.Lhrdbf_567
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_571
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_570
.Lhrdbf_572:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_571:
	movq	%rsp, %rsi
	movl	$hrdbf_app_state, %edi
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	call .Lhrdbf_entry_hrdbf_file_open
	testl	%eax, %eax
	jne	.Lhrdbf_587
	addq	$4104, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_567:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_570
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_570
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_570:
	movl	$.Lhrdbf_C5, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_586:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_571
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_572
	jmp	.Lhrdbf_570
.Lhrdbf_585:
	movl	$.Lhrdbf_C4, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_583:
	movl	$.Lhrdbf_C2, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_587:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_584:
	movl	$.Lhrdbf_C3, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.section	.rodata.str1.1
.Lhrdbf_C7:
	.string	"hbc: DBF no workarea is open\n"
	.text
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_594
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_595
	movl	hrdbf_app_order+24(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	jne	.Lhrdbf_596
	movl	hrdbf_app_state+16(%rip), %ecx
	addq	$1, %rcx
.Lhrdbf_593:
	testq	%rdx, %rdx
	movq	%rcx, hrdbf_app_state+24(%rip)
	sete	hrdbf_app_state+39(%rip)
	testl	%eax, %eax
	sete	hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_596:
	movq	hrdbf_app_order+16(%rip), %rcx
	movl	(%rcx), %ecx
	jmp	.Lhrdbf_593
	.p2align 4,,10
	.p2align 3
.Lhrdbf_595:
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbf_594:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_bottom
	.type	hrdbf_app_bottom, @function
hrdbf_app_bottom:
.Lhrdbf_entry_hrdbf_app_bottom:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_605
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_606
	movl	hrdbf_app_order+24(%rip), %esi
	movq	%rsi, %rax
	testl	%esi, %esi
	jne	.Lhrdbf_607
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%ecx, %ecx
.Lhrdbf_602:
	movl	hrdbf_app_state+16(%rip), %edx
	addq	$1, %rdx
.Lhrdbf_603:
	cmpq	%rsi, %rcx
	setnb	%cl
	testl	%eax, %eax
	sete	%al
.Lhrdbf_600:
	movq	%rdx, hrdbf_app_state+24(%rip)
	movb	%cl, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_607:
	leal	-1(%rsi), %ecx
	movq	%rcx, hrdbf_app_pos(%rip)
	cmpq	%rsi, %rcx
	jnb	.Lhrdbf_602
	movq	hrdbf_app_order+16(%rip), %rdx
	movl	(%rdx,%rcx,8), %edx
	jmp	.Lhrdbf_603
	.p2align 4,,10
	.p2align 3
.Lhrdbf_606:
	movl	hrdbf_app_state+16(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmovne	%rax, %rdx
	sete	%al
	movl	%eax, %ecx
	jmp	.Lhrdbf_600
.Lhrdbf_605:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bottom, .-hrdbf_app_bottom
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_622
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.Lhrdbf_623
	testq	%rdi, %rdi
	je	.Lhrdbf_608
	movb	$0, hrdbf_app_state+38(%rip)
	movl	hrdbf_app_order+24(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rdx
	jle	.Lhrdbf_612
	movq	%rax, %rcx
	subq	%rdx, %rcx
	cmpq	%rdi, %rcx
	jb	.Lhrdbf_618
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	setnb	%dl
.Lhrdbf_613:
	movq	%rsi, hrdbf_app_pos(%rip)
.Lhrdbf_614:
	cmpq	%rax, %rsi
	jnb	.Lhrdbf_616
.Lhrdbf_624:
	movq	hrdbf_app_order+16(%rip), %rax
	movl	(%rax,%rsi,8), %eax
.Lhrdbf_617:
	movq	%rax, hrdbf_app_state+24(%rip)
	movb	%dl, hrdbf_app_state+39(%rip)
.Lhrdbf_608:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_612:
	movq	%rdi, %rcx
	negq	%rcx
	cmpq	%rdx, %rcx
	jbe	.Lhrdbf_615
	testq	%rax, %rax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%dl
	xorl	%esi, %esi
	cmpq	%rax, %rsi
	jb	.Lhrdbf_624
.Lhrdbf_616:
	movl	hrdbf_app_state+16(%rip), %eax
	addq	$1, %rax
	jmp	.Lhrdbf_617
	.p2align 4,,10
	.p2align 3
.Lhrdbf_618:
	movq	%rax, %rsi
	movl	$1, %edx
	jmp	.Lhrdbf_613
	.p2align 4,,10
	.p2align 3
.Lhrdbf_615:
	leaq	(%rdi,%rdx), %rsi
	cmpq	%rax, %rsi
	movq	%rsi, hrdbf_app_pos(%rip)
	setnb	%dl
	jmp	.Lhrdbf_614
	.p2align 4,,10
	.p2align 3
.Lhrdbf_623:
	movq	%rdi, %rsi
	movl	$hrdbf_app_state, %edi
	jmp .Lhrdbf_entry_hrdbf_skip
.Lhrdbf_622:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C8:
	.string	"hbc: NTX only one index is supported\n"
	.align 8
.Lhrdbf_C9:
	.string	"hbc: NTX filename length outside supported range\n"
	.align 8
.Lhrdbf_C10:
	.string	"hbc: NTX filename contains NUL\n"
	.align 8
.Lhrdbf_C11:
	.string	"hbc: NTX read-only open rejected (subset, format, DBF mismatch, size or I/O)\n"
	.text
	.p2align 4
	.globl	hrdbf_app_order_add
	.type	hrdbf_app_order_add, @function
hrdbf_app_order_add:
.Lhrdbf_entry_hrdbf_app_order_add:
	endbr64
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_698
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.Lhrdbf_699
	leaq	-1(%rsi), %rax
	cmpq	$4090, %rax
	ja	.Lhrdbf_700
	xorl	%edx, %edx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_628:
	movzbl	(%rdi,%rax), %ecx
	testb	%cl, %cl
	je	.Lhrdbf_701
	movb	%cl, 16(%rsp,%rax)
	addq	$1, %rax
	cmpb	$47, %cl
	leaq	16(%rsp), %r8
	cmove	%rax, %rdx
	cmpq	%rsi, %rax
	jne	.Lhrdbf_628
	cmpq	%rsi, %rdx
	jnb	.Lhrdbf_631
	addq	%rdi, %rdx
	xorl	%eax, %eax
	addq	%rsi, %rdi
	movl	$1, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_633:
	cmpb	$46, (%rdx)
	cmove	%ecx, %eax
	addq	$1, %rdx
	cmpq	%rdi, %rdx
	jne	.Lhrdbf_633
	testl	%eax, %eax
	je	.Lhrdbf_631
.Lhrdbf_634:
	movq	hrdbf_app_order+32(%rip), %r10
	movb	$0, 16(%rsp,%rsi)
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r10, %r10
	je	.Lhrdbf_702
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
	js	.Lhrdbf_703
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_638
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_640
.Lhrdbf_641:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_638:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_642:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_642
	testq	%rax, %rax
	js	.Lhrdbf_640
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
	js	.Lhrdbf_644
	leaq	-2048(%rax), %rax
	cmpq	$67106816, %rax
	ja	.Lhrdbf_644
	movq	%r12, %rbp
	andl	$1023, %ebp
	jne	.Lhrdbf_644
	movq	%r8, %rax
	movq	%rbp, %rsi
	movq	%rbp, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_646
	movq	%r12, hrdbf_app_order+48(%rip)
	xorl	%r9d, %r9d
	movq	%rbp, %rdi
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
	jb	.Lhrdbf_647
	movq	$0, hrdbf_app_order+32(%rip)
.Lhrdbf_648:
	movq	$0, hrdbf_app_order+48(%rip)
	jmp	.Lhrdbf_697
	.p2align 4,,10
	.p2align 3
.Lhrdbf_703:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_640
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_640
.Lhrdbf_665:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_640:
	movl	$.Lhrdbf_C11, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_644:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rsi, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
.Lhrdbf_651:
	movq	hrdbf_app_order+32(%rip), %rdi
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_662
	movq	hrdbf_app_order+48(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_662
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_640
.Lhrdbf_664:
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_665
	jmp	.Lhrdbf_640
	.p2align 4,,10
	.p2align 3
.Lhrdbf_662:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	jne	.Lhrdbf_664
	jmp	.Lhrdbf_640
	.p2align 4,,10
	.p2align 3
.Lhrdbf_631:
	leaq	3(%rsi), %rax
	movb	$46, 16(%rsp,%rsi)
	movb	$110, 17(%rsp,%rsi)
	movb	$116, 18(%rsp,%rsi)
	addq	$4, %rsi
	movb	$120, 16(%rsp,%rax)
	jmp	.Lhrdbf_634
	.p2align 4,,10
	.p2align 3
.Lhrdbf_702:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_638
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r10, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_641
	jmp	.Lhrdbf_640
.Lhrdbf_647:
	movq	%rax, hrdbf_app_order+32(%rip)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_648
	movq	hrdbf_app_order+48(%rip), %rdx
	xorl	%r8d, %r8d
	testq	%rdx, %rdx
	jne	.Lhrdbf_649
	jmp	.Lhrdbf_650
	.p2align 4,,10
	.p2align 3
.Lhrdbf_704:
	movq	hrdbf_app_order+32(%rip), %rsi
.Lhrdbf_649:
	addq	%rbp, %rsi
	subq	%rbp, %rdx
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_652
	testq	%rax, %rax
	jle	.Lhrdbf_653
	addq	%rax, %rbp
.Lhrdbf_652:
	movq	hrdbf_app_order+48(%rip), %rdx
	cmpq	%rbp, %rdx
	ja	.Lhrdbf_704
.Lhrdbf_650:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_654:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbp
	cmpq	$-4, %rax
	je	.Lhrdbf_654
	testq	%rax, %rax
	jne	.Lhrdbf_653
	movl	hrdbf_app_state+16(%rip), %eax
	movq	hrdbf_app_order+48(%rip), %rdx
	leaq	0(,%rax,8), %r13
	cmpq	$8388608, %rax
	ja	.Lhrdbf_646
	shrq	$10, %rdx
	addq	$7, %rax
	xorl	%r9d, %r9d
	movq	%rbp, %rdi
	movq	%rdx, %r12
	shrq	$3, %rax
	movl	$3, %r14d
	movl	$34, %r10d
	addq	$7, %r12
	movq	$-1, %r8
	movq	%r14, %rdx
	shrq	$3, %r12
	addq	%rax, %r12
	movl	$9, %eax
	leaq	0(%r13,%r12), %rsi
	movq	%rsi, hrdbf_app_order+56(%rip)
#APP
# 12 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4095, %rax
	jb	.Lhrdbf_657
	movq	$0, hrdbf_app_order+40(%rip)
.Lhrdbf_658:
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_697:
	xorl	%edx, %edx
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rdx, %rsi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_651
.Lhrdbf_653:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%r8, %rsi
	movq	%r8, %rdx
.Lhrdbf_696:
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_651
.Lhrdbf_646:
	movl	$3, %eax
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	movq	%rbp, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_651
.Lhrdbf_657:
	movq	%rax, hrdbf_app_order+40(%rip)
	testq	%rax, %rax
	je	.Lhrdbf_658
	addq	%rax, %r13
	pushq	%r12
	movq	hrdbf_app_order+48(%rip), %rdx
	movq	%rax, %r8
	pushq	%r13
	movl	$hrdbf_app_state, %ecx
	movl	$hrdbf_app_order, %edi
	movq	hrdbf_app_order+32(%rip), %rsi
	movl	hrdbf_app_state+16(%rip), %r9d
	call .Lhrdbf_entry_hrntx_open
	popq	%rdx
	movq	%rbx, %rdi
	popq	%rcx
	testl	%eax, %eax
	movq	%rbp, %rsi
	movq	%r14, %rax
	movq	%rbp, %rdx
	jne	.Lhrdbf_696
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_651
	call .Lhrdbf_entry_hrdbf_app_top
	addq	$4112, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
.Lhrdbf_701:
	movl	$.Lhrdbf_C10, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_698:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_700:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_699:
	movl	$.Lhrdbf_C8, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_add, .-hrdbf_app_order_add
	.p2align 4
	.globl	hrdbf_app_order_clear
	.type	hrdbf_app_order_clear, @function
hrdbf_app_order_clear:
.Lhrdbf_entry_hrdbf_app_order_clear:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_719
	movq	hrdbf_app_order+32(%rip), %r9
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, hrdbf_app_order+8(%rip)
	movq	$0, hrdbf_app_order+16(%rip)
	movq	$0, hrdbf_app_order+24(%rip)
	testq	%r9, %r9
	je	.Lhrdbf_720
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
	js	.Lhrdbf_710
	movq	hrdbf_app_order+40(%rip), %rdi
	movq	$0, hrdbf_app_order+32(%rip)
	movq	$0, hrdbf_app_order+48(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_714
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_713
.Lhrdbf_715:
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_714:
	movq	$0, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_710:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_713
	movq	hrdbf_app_order+56(%rip), %rsi
	movq	%r8, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_713
	movq	$0, hrdbf_app_order+40(%rip)
	movq	$0, hrdbf_app_order+56(%rip)
.Lhrdbf_713:
	movl	$.Lhrdbf_C5, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_720:
	movq	hrdbf_app_order+40(%rip), %rdi
	testq	%rdi, %rdi
	je	.Lhrdbf_714
	movq	hrdbf_app_order+56(%rip), %rsi
	movl	$11, %eax
	movq	%r9, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	jns	.Lhrdbf_715
	jmp	.Lhrdbf_713
.Lhrdbf_719:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_order_clear, .-hrdbf_app_order_clear
	.p2align 4
	.globl	hrdbf_app_found
	.type	hrdbf_app_found, @function
hrdbf_app_found:
.Lhrdbf_entry_hrdbf_app_found:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_723
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.Lhrdbf_723:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_found, .-hrdbf_app_found
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C12:
	.string	"hbc: NTX seek requires an open index\n"
	.text
	.p2align 4
	.globl	hrdbf_app_seek
	.type	hrdbf_app_seek, @function
hrdbf_app_seek:
.Lhrdbf_entry_hrdbf_app_seek:
	endbr64
	subq	$16, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_730
	cmpq	$0, hrdbf_app_order(%rip)
	je	.Lhrdbf_731
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
	jb	.Lhrdbf_732
	movl	hrdbf_app_state+16(%rip), %edi
	addq	$1, %rdi
.Lhrdbf_728:
	cmpq	%rsi, %rax
	movq	%rdi, hrdbf_app_state+24(%rip)
	movslq	%edx, %rax
	setnb	hrdbf_app_state+39(%rip)
	testl	%ecx, %ecx
	sete	hrdbf_app_state+38(%rip)
	addq	$16, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_732:
	movq	hrdbf_app_order+16(%rip), %rdi
	movl	(%rdi,%rax,8), %edi
	jmp	.Lhrdbf_728
.Lhrdbf_731:
	movl	$.Lhrdbf_C12, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_730:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_seek, .-hrdbf_app_seek
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_735
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_735:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_738
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_738:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_741
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_741:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_744
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_744:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_749
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_745
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_745:
	movq	%r8, %rax
	ret
.Lhrdbf_749:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_deleted, .-hrdbf_app_deleted
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C13:
	.string	"hbc: DBF field decoding failed\n"
	.align 8
.Lhrdbf_C14:
	.string	"hbc: DBF field string allocation failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_get
	.type	hrdbf_app_get, @function
hrdbf_app_get:
.Lhrdbf_entry_hrdbf_app_get:
	endbr64
	pushq	%rbx
	subq	$288, %rsp
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_767
	testq	%rdi, %rdi
	jle	.Lhrdbf_762
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rdi, %rax
	jge	.Lhrdbf_768
.Lhrdbf_762:
	movl	$1, %eax
	xorl	%edx, %edx
.Lhrdbf_752:
	addq	$288, %rsp
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_768:
	movq	%rsi, %rbx
	movq	%rsp, %rdx
	movl	%edi, %esi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	jne	.Lhrdbf_769
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_770
	cmpb	$78, %al
	je	.Lhrdbf_771
	cmpb	$68, %al
	je	.Lhrdbf_772
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_770:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_773
.Lhrdbf_755:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_774
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_771:
	movzbl	2(%rsp), %eax
	movzbl	1(%rsp), %edx
	salq	$8, %rax
	salq	$16, %rdx
	orq	%rdx, %rax
	movq	16(%rsp), %rdx
	orq	$12, %rax
	jmp	.Lhrdbf_752
	.p2align 4,,10
	.p2align 3
.Lhrdbf_772:
	movl	24(%rsp), %edx
	movl	$11, %eax
	jmp	.Lhrdbf_752
	.p2align 4,,10
	.p2align 3
.Lhrdbf_773:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_758
	.p2align 4,,10
	.p2align 3
.Lhrdbf_757:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_757
.Lhrdbf_758:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_755
.Lhrdbf_767:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_769:
	movl	$.Lhrdbf_C13, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_774:
	movl	$.Lhrdbf_C14, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get, .-hrdbf_app_get
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C15:
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
	jne	.Lhrdbf_778
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_778:
	movl	$.Lhrdbf_C15, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C16:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.Lhrdbf_C17:
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
	jne	.Lhrdbf_780
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_796
	testl	%eax, %eax
	je	.Lhrdbf_788
	cmpl	$9, %eax
	jne	.Lhrdbf_784
.Lhrdbf_788:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_796:
	testl	$65280, %r9d
	je	.Lhrdbf_788
.Lhrdbf_783:
	movl	$.Lhrdbf_C16, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_780:
	cmpl	$2, %eax
	je	.Lhrdbf_783
.Lhrdbf_784:
	movl	$.Lhrdbf_C17, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C18:
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
	je	.Lhrdbf_801
	testl	%eax, %eax
	jne	.Lhrdbf_802
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_801:
	movl	$.Lhrdbf_C16, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_802:
	movl	$.Lhrdbf_C18, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C19:
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
	jne	.Lhrdbf_804
	cmpb	$11, %dl
	je	.Lhrdbf_846
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_810
.Lhrdbf_814:
	movl	$.Lhrdbf_C17, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_810:
	cmpl	$2, %eax
	jne	.Lhrdbf_814
.Lhrdbf_813:
	movl	$.Lhrdbf_C16, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_804:
	movzbl	%dil, %ebx
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_810
	cmpl	$12, %ebx
	jne	.Lhrdbf_811
	testl	$65280, %r9d
	jne	.Lhrdbf_813
.Lhrdbf_812:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_810
	movzbl	%r10b, %eax
	cmpb	$12, %r10b
	je	.Lhrdbf_847
	testl	%eax, %eax
	je	.Lhrdbf_820
	cmpl	$9, %eax
	jne	.Lhrdbf_814
.Lhrdbf_820:
	cmpq	%r11, %rbp
	jl	.Lhrdbf_822
	setg	%al
	movzbl	%al, %eax
.Lhrdbf_803:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_811:
	testl	%ebx, %ebx
	je	.Lhrdbf_812
	cmpl	$9, %ebx
	je	.Lhrdbf_812
	jmp	.Lhrdbf_814
	.p2align 4,,10
	.p2align 3
.Lhrdbf_822:
	addq	$8, %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_846:
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_807
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_807
	cmpq	%r11, %rbp
	jb	.Lhrdbf_822
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbf_803
	.p2align 4,,10
	.p2align 3
.Lhrdbf_847:
	testl	$65280, %r10d
	je	.Lhrdbf_820
	jmp	.Lhrdbf_813
.Lhrdbf_807:
	movl	$.Lhrdbf_C19, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C21:
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
	jne	.Lhrdbf_849
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_858
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_851
	.p2align 4,,10
	.p2align 3
.Lhrdbf_870:
	btq	%rax, %rcx
	jc	.Lhrdbf_862
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_858
.Lhrdbf_851:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_870
.Lhrdbf_862:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_849:
	cmpl	$8, %r10d
	je	.Lhrdbf_871
	cmpl	$5, %r10d
	je	.Lhrdbf_872
	cmpl	$7, %r10d
	je	.Lhrdbf_862
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_855
	cmpl	$12, %r10d
	ja	.Lhrdbf_855
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_856
	cmpl	$1, %r10d
	je	.Lhrdbf_863
.Lhrdbf_855:
	movl	$.Lhrdbf_C21, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_858:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_871:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_867
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_867:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_872:
	movq	%rsi, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C20(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_856:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_848:
	addq	$8, %rsp
	ret
.Lhrdbf_863:
	movl	$1, %eax
	jmp	.Lhrdbf_848
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C22:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C22, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.1
.Lhrdbf_C23:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C24:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C25:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C26:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C27:
	.string	"DBF value tag or metadata invalid"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.134, @object
	.size	hrdbf_local_CSWTCH.134, 40
hrdbf_local_CSWTCH.134:
.Lhrdbf_entry_hrdbf_local_CSWTCH.134:
	.quad	.Lhrdbf_C23
	.quad	.Lhrdbf_C24
	.quad	.Lhrdbf_C25
	.quad	.Lhrdbf_C26
	.quad	.Lhrdbf_C27
	.align 8
	.type	hrdbf_local_CSWTCH.115, @object
	.size	hrdbf_local_CSWTCH.115, 13
hrdbf_local_CSWTCH.115:
.Lhrdbf_entry_hrdbf_local_CSWTCH.115:
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
.Lhrdbf_C20:
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
