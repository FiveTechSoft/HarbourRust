	.file	"hrdbf_embedded_linux.c"
	.text
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
	je	.Lhrdbf_3
	movl	16(%rdi), %eax
	movq	$1, 24(%rdi)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rdi)
	movb	%al, 38(%rdi)
	xorl	%eax, %eax
.Lhrdbf_3:
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
	je	.Lhrdbf_6
	xorl	%r8d, %r8d
	testq	%rsi, %rsi
	je	.Lhrdbf_6
	movb	$0, 38(%rdi)
	movq	24(%rdi), %rdx
	jle	.Lhrdbf_8
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
.Lhrdbf_10:
	movl	$1, %edx
	testl	%edi, %edi
	jne	.Lhrdbf_20
	movb	%dl, 39(%rax)
	xorl	%r8d, %r8d
.Lhrdbf_6:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_8:
	movq	%rsi, %rcx
	negq	%rcx
	cmpq	%rcx, %rdx
	ja	.Lhrdbf_11
	xorl	%edx, %edx
	movq	$1, 24(%rdi)
	xorl	%r8d, %r8d
	movb	$1, 38(%rdi)
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_6
	.p2align 4,,10
	.p2align 3
.Lhrdbf_20:
	cmpq	%rdi, 24(%rax)
	seta	%dl
	xorl	%r8d, %r8d
	movb	%dl, 39(%rax)
	jmp	.Lhrdbf_6
	.p2align 4,,10
	.p2align 3
.Lhrdbf_11:
	addq	%rsi, %rdx
	movq	%rdx, 24(%rdi)
	movl	16(%rdi), %edi
	jmp	.Lhrdbf_10
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
	je	.Lhrdbf_100
	testl	%esi, %esi
	je	.Lhrdbf_101
	movq	%rdx, %rcx
	movzwl	36(%rdi), %edx
	movq	%rdi, %rax
	cmpl	%esi, %edx
	jb	.Lhrdbf_101
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
	ja	.Lhrdbf_101
	movzwl	34(%rax), %r10d
	subq	$1, %rsi
	movzwl	56(%rdx), %edx
	imulq	%r10, %rsi
	movzwl	32(%rax), %r10d
	addq	%r10, %rdx
	addq	%rdx, %rsi
	addq	(%rax), %rsi
	cmpb	$67, %r8b
	je	.Lhrdbf_104
	cmpb	$78, %r8b
	je	.Lhrdbf_105
	movzbl	(%rsi), %eax
	cmpb	$68, %r8b
	je	.Lhrdbf_106
	movl	%eax, %edx
	andl	$-33, %edx
	cmpb	$84, %dl
	je	.Lhrdbf_47
	cmpb	$89, %dl
	je	.Lhrdbf_47
	movl	%eax, %edx
	andl	$-9, %edx
	cmpb	$102, %dl
	je	.Lhrdbf_101
	subl	$32, %eax
	movl	$5, %r8d
	cmpb	$46, %al
	ja	.Lhrdbf_100
	movabsq	$-70645769568258, %rdx
	btq	%rax, %rdx
	jc	.Lhrdbf_100
	.p2align 4,,10
	.p2align 3
.Lhrdbf_101:
	xorl	%r8d, %r8d
.Lhrdbf_100:
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_47:
	xorl	%r8d, %r8d
	movb	$1, 28(%rcx)
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_104:
	movq	%rsi, 8(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_100
	.p2align 4,,10
	.p2align 3
.Lhrdbf_105:
	testl	%edi, %edi
	je	.Lhrdbf_101
	movq	%rsi, %rdx
	xorl	%eax, %eax
	jmp	.Lhrdbf_26
	.p2align 4,,10
	.p2align 3
.Lhrdbf_27:
	addl	$1, %eax
	addq	$1, %rdx
	cmpl	%eax, %edi
	je	.Lhrdbf_101
.Lhrdbf_26:
	movzbl	(%rdx), %r8d
	cmpb	$32, %r8b
	je	.Lhrdbf_27
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrdbf_29
	.p2align 4,,10
	.p2align 3
.Lhrdbf_53:
	movl	%edx, %edi
.Lhrdbf_29:
	cmpl	%edi, %eax
	jnb	.Lhrdbf_28
	leal	-1(%rdi), %r10d
	cmpb	$32, (%rsi,%r10)
	movq	%r10, %rdx
	je	.Lhrdbf_53
	leal	-43(%r8), %edx
	andl	$253, %edx
	jne	.Lhrdbf_73
	cmpb	$45, %r8b
	sete	%dl
.Lhrdbf_51:
	movabsq	$-9223372036854775808, %rbp
	movl	%edx, %r12d
	addl	$1, %eax
	andl	$1, %r12d
	testb	%dl, %dl
	movabsq	$9223372036854775807, %rdx
	cmove	%rdx, %rbp
.Lhrdbf_31:
	cmpl	%eax, %edi
	jbe	.Lhrdbf_58
	movl	%eax, %edx
	movzbl	(%rsi,%rdx), %r8d
.Lhrdbf_50:
	addl	$1, %eax
	xorl	%edx, %edx
	xorl	%r13d, %r13d
	xorl	%r11d, %r11d
	movq	%rax, %r10
	addq	%rax, %rsi
	xorl	%ebx, %ebx
	movabsq	$-3689348814741910323, %r14
	subl	%esi, %r10d
	jmp	.Lhrdbf_35
	.p2align 4,,10
	.p2align 3
.Lhrdbf_107:
	testl	%ebx, %ebx
	jne	.Lhrdbf_74
	movl	$1, %ebx
.Lhrdbf_32:
	leal	(%r10,%rsi), %eax
	cmpl	%eax, %edi
	jbe	.Lhrdbf_34
	movzbl	(%rsi), %r8d
	addq	$1, %rsi
.Lhrdbf_35:
	movzbl	%r8b, %eax
	cmpb	$46, %r8b
	je	.Lhrdbf_107
.Lhrdbf_74:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.Lhrdbf_58
	movl	%eax, %r15d
	movq	%rbp, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rax
	mulq	%r14
	shrq	$3, %rdx
	cmpq	%r11, %rdx
	jb	.Lhrdbf_64
	leaq	(%r11,%r11,4), %rax
	movl	$1, %edx
	leaq	-48(%r8,%rax,2), %r11
	testl	%ebx, %ebx
	je	.Lhrdbf_32
	addl	$1, %r13d
	movl	%ebx, %edx
	jmp	.Lhrdbf_32
	.p2align 4,,10
	.p2align 3
.Lhrdbf_106:
	leaq	8(%rsi), %rdx
	movq	%rsi, %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_44:
	cmpb	$32, (%rax)
	jne	.Lhrdbf_66
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_44
	jmp	.Lhrdbf_101
.Lhrdbf_66:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.Lhrdbf_43:
	movzbl	(%rsi), %eax
	leal	-48(%rax), %edi
	cmpb	$9, %dil
	ja	.Lhrdbf_67
	leal	(%r9,%r9,4), %edi
	addq	$1, %rsi
	leal	-48(%rax,%rdi,2), %r9d
	cmpq	%rdx, %rsi
	jne	.Lhrdbf_43
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
	jbe	.Lhrdbf_100
	cmpl	$11, %edx
	ja	.Lhrdbf_100
	testl	%edi, %edi
	je	.Lhrdbf_100
	movzbl	hrdbf_local_days.1(%rdx), %r10d
	cmpl	$2, %eax
	je	.Lhrdbf_108
.Lhrdbf_45:
	movl	$5, %r8d
	cmpl	%r10d, %edi
	ja	.Lhrdbf_100
	movl	%r9d, 24(%rcx)
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_100
.Lhrdbf_34:
	movl	$5, %r8d
	testl	%edx, %edx
	je	.Lhrdbf_21
	cmpl	%r13d, %r9d
	jb	.Lhrdbf_21
	leal	1(%r13), %eax
	jbe	.Lhrdbf_36
	movabsq	$922337203685477580, %rsi
	cmpq	%rsi, %r11
	jbe	.Lhrdbf_37
	jmp	.Lhrdbf_64
	.p2align 4,,10
	.p2align 3
.Lhrdbf_38:
	cmpq	%rsi, %r11
	ja	.Lhrdbf_64
.Lhrdbf_37:
	leaq	(%r11,%r11,4), %r11
	movl	%eax, %edx
	addl	$1, %eax
	addq	%r11, %r11
	cmpl	%edx, %r9d
	jne	.Lhrdbf_38
	testl	%r12d, %r12d
	jne	.Lhrdbf_49
.Lhrdbf_40:
	movq	%r11, %rax
.Lhrdbf_41:
	movq	%rax, 16(%rcx)
	xorl	%r8d, %r8d
.Lhrdbf_21:
	popq	%rbx
	movl	%r8d, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_64:
	movl	$4, %r8d
	jmp	.Lhrdbf_21
.Lhrdbf_28:
	je	.Lhrdbf_23
	movabsq	$9223372036854775807, %rbp
	movl	%eax, %edx
	xorl	%r12d, %r12d
	movzbl	(%rsi,%rdx), %edx
	leal	-43(%rdx), %r8d
	andl	$253, %r8d
	jne	.Lhrdbf_31
	cmpb	$45, %dl
	sete	%dl
	jmp	.Lhrdbf_51
	.p2align 4,,10
	.p2align 3
.Lhrdbf_23:
	xorl	%r8d, %r8d
	jmp	.Lhrdbf_21
.Lhrdbf_58:
	movl	$5, %r8d
	jmp	.Lhrdbf_21
.Lhrdbf_73:
	movabsq	$9223372036854775807, %rbp
	xorl	%r12d, %r12d
	jmp	.Lhrdbf_50
.Lhrdbf_67:
	movl	$5, %r8d
	jmp	.Lhrdbf_100
.Lhrdbf_108:
	movl	$3518437209, %eax
	imulq	%rax, %rsi
	shrq	$45, %rsi
	testb	$3, %sil
	jne	.Lhrdbf_45
	movl	$100, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_46
	movl	$400, %r8d
	movl	%esi, %eax
	xorl	%edx, %edx
	divl	%r8d
	testl	%edx, %edx
	jne	.Lhrdbf_45
.Lhrdbf_46:
	addl	$1, %r10d
	jmp	.Lhrdbf_45
.Lhrdbf_36:
	testl	%r12d, %r12d
	je	.Lhrdbf_40
	movl	$1, %edx
	movq	%r11, %rax
	salq	$63, %rdx
	cmpq	%rdx, %r11
	je	.Lhrdbf_41
.Lhrdbf_49:
	movq	%r11, %rax
	negq	%rax
	jmp	.Lhrdbf_41
	.size	hrdbf_get, .-hrdbf_get
	.p2align 4
	.globl	hrdbf_deleted
	.type	hrdbf_deleted, @function
hrdbf_deleted:
.Lhrdbf_entry_hrdbf_deleted:
	endbr64
	cmpb	$0, 40(%rdi)
	movl	$6, %eax
	je	.Lhrdbf_109
	movq	24(%rdi), %rax
	movl	16(%rdi), %ecx
	xorl	%edx, %edx
	cmpq	%rcx, %rax
	ja	.Lhrdbf_111
	movzwl	34(%rdi), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32(%rdi), %edx
	addq	(%rdi), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%dl
.Lhrdbf_111:
	movb	%dl, (%rsi)
	xorl	%eax, %eax
.Lhrdbf_109:
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
	jbe	.Lhrdbf_150
	cmpb	$3, (%rsi)
	movl	$2, %eax
	jne	.Lhrdbf_114
	cmpb	$0, 14(%rsi)
	jne	.Lhrdbf_114
	cmpb	$0, 15(%rsi)
	jne	.Lhrdbf_114
	cmpb	$0, 28(%rsi)
	jne	.Lhrdbf_114
	cmpb	$0, 29(%rsi)
	jne	.Lhrdbf_114
	movzwl	8(%rsi), %eax
	movzwl	10(%rsi), %r13d
	movl	4(%rsi), %r15d
	movw	%ax, 112(%rsp)
	movw	%r13w, 114(%rsp)
	movl	%r15d, 96(%rsp)
	cmpw	$32, %ax
	jbe	.Lhrdbf_150
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
	je	.Lhrdbf_166
	.p2align 4,,10
	.p2align 3
.Lhrdbf_150:
	movl	$1, %eax
.Lhrdbf_114:
	addq	$2184, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrdbf_166:
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
.Lhrdbf_130:
	movzbl	(%r11), %ecx
	movl	%r14d, %edi
	cmpb	$13, %cl
	je	.Lhrdbf_167
	cmpq	8(%rsp), %r14
	je	.Lhrdbf_150
	cmpq	$4128, %r8
	je	.Lhrdbf_151
	movl	%r14d, %eax
	movl	%r14d, %ebx
	xorl	%edx, %edx
	jmp	.Lhrdbf_121
	.p2align 4,,10
	.p2align 3
.Lhrdbf_168:
	movzbl	(%r11,%rdx), %ecx
.Lhrdbf_121:
	movb	%cl, 42(%r10,%rdx)
	addq	$1, %rdx
	cmpq	$11, %rdx
	jne	.Lhrdbf_168
	movzbl	42(%r10), %r12d
	testb	%r12b, %r12b
	je	.Lhrdbf_150
	leal	1(%rax), %edx
	cmpl	$1, %edx
	jbe	.Lhrdbf_122
	leal	-1(%rax), %ebp
	leaq	149(%rsp), %rax
	xorl	%edi, %edi
	salq	$4, %rbp
	leaq	133(%rsp), %rcx
	addq	%rax, %rbp
	.p2align 4,,10
	.p2align 3
.Lhrdbf_123:
	leaq	-11(%rcx), %rax
	movl	%r12d, %edx
	jmp	.Lhrdbf_125
	.p2align 4,,10
	.p2align 3
.Lhrdbf_170:
	leaq	(%rdi,%rax), %rdx
	movzbl	(%rdx,%r9), %edx
.Lhrdbf_125:
	cmpb	%dl, (%rax)
	jne	.Lhrdbf_169
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrdbf_170
	movl	$1, %eax
	jmp	.Lhrdbf_114
	.p2align 4,,10
	.p2align 3
.Lhrdbf_169:
	addq	$16, %rcx
	subq	$16, %rdi
	cmpq	%rbp, %rcx
	jne	.Lhrdbf_123
.Lhrdbf_122:
	movzbl	11(%r11), %edx
	movzbl	16(%r11), %eax
	movw	%si, 56(%r10)
	movzbl	17(%r11), %ecx
	movb	%dl, 53(%r10)
	movb	%al, 54(%r10)
	movb	%cl, 55(%r10)
	testb	%al, %al
	je	.Lhrdbf_150
	cmpb	$67, %dl
	je	.Lhrdbf_171
	cmpb	$78, %dl
	je	.Lhrdbf_172
	cmpb	$76, %dl
	je	.Lhrdbf_173
	cmpb	$68, %dl
	jne	.Lhrdbf_149
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$8, 134(%rsp,%rdx)
	jne	.Lhrdbf_150
.Lhrdbf_127:
	addl	%eax, %esi
	cmpl	$65535, %esi
	ja	.Lhrdbf_151
	addq	$32, %r8
	addq	$1, %r14
	addq	$32, %r11
	addq	$16, %r10
	addq	$16, %r9
	movl	$1, %eax
	cmpq	%r8, (%rsp)
	ja	.Lhrdbf_130
	jmp	.Lhrdbf_150
.Lhrdbf_171:
	testb	%cl, %cl
	je	.Lhrdbf_127
.Lhrdbf_149:
	movl	$3, %eax
	jmp	.Lhrdbf_114
	.p2align 4,,10
	.p2align 3
.Lhrdbf_172:
	cmpb	%cl, %al
	jbe	.Lhrdbf_151
	cmpb	$17, %cl
	jbe	.Lhrdbf_127
.Lhrdbf_151:
	movl	$4, %eax
	jmp	.Lhrdbf_114
.Lhrdbf_173:
	movslq	%ebx, %rdx
	salq	$4, %rdx
	cmpw	$1, 134(%rsp,%rdx)
	je	.Lhrdbf_127
	jmp	.Lhrdbf_150
	.p2align 4,,10
	.p2align 3
.Lhrdbf_167:
	movl	%esi, %edx
	movq	%r8, %rcx
	movq	24(%rsp), %rbx
	movq	32(%rsp), %rsi
	movq	40(%rsp), %r8
	testb	%al, %al
	je	.Lhrdbf_150
	movw	%r14w, 116(%rsp)
	cmpl	%edx, 20(%rsp)
	jne	.Lhrdbf_150
	testw	%r14w, %r14w
	je	.Lhrdbf_150
	movq	%rcx, %rax
	addq	$1, %rax
	jmp	.Lhrdbf_118
.Lhrdbf_131:
	addq	$1, %rax
	cmpb	$0, -1(%rsi,%rax)
	jne	.Lhrdbf_150
.Lhrdbf_118:
	cmpq	%rax, (%rsp)
	ja	.Lhrdbf_131
	movq	(%rsp), %rcx
	movq	%r8, %rax
	xorl	%edx, %edx
	movl	%r15d, %ebp
	subq	%rcx, %rax
	divq	%r13
	cmpq	%rax, %rbp
	ja	.Lhrdbf_150
	movq	%rbp, %rax
	imulq	%r13, %rax
	addq	%rcx, %rax
	cmpq	%rax, %r8
	je	.Lhrdbf_132
	movq	%r8, %rdx
	subq	%rax, %rdx
	subq	$1, %rdx
	jne	.Lhrdbf_150
	cmpb	$26, (%rsi,%rax)
	jne	.Lhrdbf_150
.Lhrdbf_132:
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
.Lhrdbf_133:
	cmpq	%r14, %rbp
	jbe	.Lhrdbf_174
	movzbl	(%r12), %eax
	cmpb	$32, %al
	je	.Lhrdbf_153
	cmpb	$42, %al
	jne	.Lhrdbf_152
.Lhrdbf_153:
	addq	$1, %r14
	movl	$1, %r15d
	movq	%r14, 104(%rsp)
	jmp	.Lhrdbf_135
.Lhrdbf_176:
	addl	$1, %r15d
	cmpl	%r15d, (%rsp)
	jb	.Lhrdbf_175
.Lhrdbf_135:
	leaq	48(%rsp), %rdx
	movl	%r15d, %esi
	leaq	80(%rsp), %rdi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	je	.Lhrdbf_176
	jmp	.Lhrdbf_114
.Lhrdbf_174:
	movl	$262, %ecx
	movq	%rbx, %rdi
	leaq	80(%rsp), %rsi
	xorl	%eax, %eax
	movq	$1, 104(%rsp)
	rep movsq
	jmp	.Lhrdbf_114
.Lhrdbf_152:
	movl	$5, %eax
	jmp	.Lhrdbf_114
.Lhrdbf_175:
	addq	%r13, %r12
	jmp	.Lhrdbf_133
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
	ja	.Lhrdbf_179
	je	.Lhrdbf_198
	xorl	%eax, %eax
	cmpl	$5, %edx
	je	.Lhrdbf_179
	shrq	$8, %rdi
	movl	$4, %eax
	jne	.Lhrdbf_179
	xorl	%eax, %eax
	cmpl	$11, %edx
	jne	.Lhrdbf_179
	movl	$4, %eax
	cmpq	$99991231, %rsi
	ja	.Lhrdbf_179
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_179
	movabsq	$3777893186295716171, %rdx
	movq	%rsi, %rax
	mulq	%rdx
	movl	$4, %eax
	movq	%rdx, %rcx
	shrq	$11, %rcx
	leal	-1(%rcx), %edx
	cmpl	$9998, %edx
	ja	.Lhrdbf_179
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
	ja	.Lhrdbf_194
	testq	%rsi, %rsi
	je	.Lhrdbf_194
	movl	hrdbf_local_days.0(,%rax,4), %eax
	cmpl	$2, %edx
	je	.Lhrdbf_199
.Lhrdbf_182:
	cmpl	%esi, %eax
	setb	%al
	movzbl	%al, %eax
	sall	$2, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_198:
	movq	%rdi, %rcx
	shrq	$32, %rcx
	jne	.Lhrdbf_179
	movq	%rdi, %rdx
	shrq	$16, %rdx
	jne	.Lhrdbf_200
.Lhrdbf_179:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_200:
	testb	$-1, %dh
	jne	.Lhrdbf_179
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
.Lhrdbf_194:
	movl	$4, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_199:
	testb	$3, %cl
	jne	.Lhrdbf_182
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.Lhrdbf_183
	addl	$1, %eax
	jmp	.Lhrdbf_182
.Lhrdbf_183:
	rorl	$4, %ecx
	cmpl	$10737419, %ecx
	adcl	$0, %eax
	jmp	.Lhrdbf_182
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
	ja	.Lhrdbf_201
	movzbl	hrdbf_local_CSWTCH.73(%rdx), %eax
.Lhrdbf_201:
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
	jne	.Lhrdbf_204
	movzbl	%r9b, %edx
	cmpb	$12, %r9b
	je	.Lhrdbf_214
	testl	%edx, %edx
	je	.Lhrdbf_207
	cmpl	$9, %edx
	je	.Lhrdbf_207
	movl	$1, %eax
.Lhrdbf_204:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_214:
	testl	$65280, %r9d
	jne	.Lhrdbf_215
.Lhrdbf_207:
	movq	%r10, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_215:
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
	jne	.Lhrdbf_216
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_216
	movzbl	%bpl, %r13d
	movzbl	%r10b, %r12d
	cmpb	$11, %bpl
	jne	.Lhrdbf_218
	cmpl	$11, %r12d
	jne	.Lhrdbf_218
.Lhrdbf_231:
	xorl	%edx, %edx
	cmpq	%r11, %r9
	sete	%dl
	movl	%edx, (%rbx)
.Lhrdbf_216:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_218:
	cmpl	$1, %r13d
	je	.Lhrdbf_234
	cmpl	$1, %r12d
	je	.Lhrdbf_234
	cmpl	$3, %r13d
	jne	.Lhrdbf_221
	cmpl	$3, %r12d
	jne	.Lhrdbf_221
	testq	%r9, %r9
	sete	%dl
	testq	%r11, %r11
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_216
	.p2align 4,,10
	.p2align 3
.Lhrdbf_234:
	xorl	%edx, %edx
	cmpl	%r13d, %r12d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.Lhrdbf_216
	.p2align 4,,10
	.p2align 3
.Lhrdbf_221:
	movq	%rbp, %rdi
	movq	%r9, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_216
	cmpl	$12, %r13d
	je	.Lhrdbf_257
	testl	%r13d, %r13d
	je	.Lhrdbf_224
	movl	$1, %eax
	cmpl	$9, %r13d
	jne	.Lhrdbf_216
.Lhrdbf_224:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_216
	cmpl	$12, %r12d
	je	.Lhrdbf_258
	testl	%r12d, %r12d
	je	.Lhrdbf_231
	cmpl	$9, %r12d
	je	.Lhrdbf_231
	movl	$1, %eax
	jmp	.Lhrdbf_216
	.p2align 4,,10
	.p2align 3
.Lhrdbf_257:
	testl	$65280, %ebp
	je	.Lhrdbf_224
.Lhrdbf_230:
	movl	$2, %eax
	jmp	.Lhrdbf_216
	.p2align 4,,10
	.p2align 3
.Lhrdbf_258:
	testl	$65280, %r10d
	je	.Lhrdbf_231
	jmp	.Lhrdbf_230
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
	jne	.Lhrdbf_259
	movzbl	%r9b, %ecx
	cmpb	$12, %r9b
	ja	.Lhrdbf_263
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.Lhrdbf_261
	cmpl	$1, %ecx
	je	.Lhrdbf_264
.Lhrdbf_263:
	movl	$1, %eax
.Lhrdbf_259:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_261:
	xorl	%edx, %edx
	testq	%r10, %r10
	sete	%dl
	movl	%edx, (%r11)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_264:
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
	jne	.Lhrdbf_265
	movq	%r11, %rcx
	movzbl	%r10b, %eax
	cmpb	$11, %r10b
	je	.Lhrdbf_312
	cmpl	$12, %eax
	jne	.Lhrdbf_291
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
.Lhrdbf_273:
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
	ja	.Lhrdbf_273
	cmpl	%r12d, %r10d
	jb	.Lhrdbf_313
	movl	$1, %esi
.Lhrdbf_274:
	leal	1(%rsi,%r10), %eax
.Lhrdbf_275:
	movq	%r11, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	%r14d, %edx
	cmpq	%rbx, %rdx
	ja	.Lhrdbf_276
	movq	%rdx, 0(%rbp)
	cmpl	%r14d, %eax
	ja	.Lhrdbf_314
	subl	%eax, %r14d
	je	.Lhrdbf_284
	leal	-1(%r14), %edx
	movq	%r9, %rax
	leaq	1(%r9,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_283:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_283
.Lhrdbf_284:
	testq	%r11, %r11
	jns	.Lhrdbf_282
	movl	%r14d, %eax
	addl	$1, %r14d
	movb	$45, (%r9,%rax)
.Lhrdbf_282:
	testl	%esi, %esi
	je	.Lhrdbf_285
	leal	-1(%rsi,%r10), %eax
	leal	(%r14,%rax), %edi
	jmp	.Lhrdbf_287
	.p2align 4,,10
	.p2align 3
.Lhrdbf_295:
	movl	%edx, %eax
.Lhrdbf_287:
	movl	%edi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_286
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_286:
	movb	%cl, (%r9,%rdx)
	leal	-1(%rax), %edx
	cmpl	%r10d, %eax
	jne	.Lhrdbf_295
	addl	%esi, %r14d
.Lhrdbf_285:
	testl	%r10d, %r10d
	je	.Lhrdbf_265
	movl	%r14d, %eax
	leal	(%r14,%r10), %esi
	movb	$46, (%r9,%rax)
	leal	-1(%r10), %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_289:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%r12d, %eax
	jnb	.Lhrdbf_288
	movl	%eax, %ecx
	movzbl	(%rsp,%rcx), %ecx
.Lhrdbf_288:
	movb	%cl, (%r9,%rdx)
	subl	$1, %eax
	jnb	.Lhrdbf_289
.Lhrdbf_265:
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
.Lhrdbf_312:
	cmpq	$7, %rbx
	jbe	.Lhrdbf_276
	movq	$8, 0(%rbp)
	testq	%r11, %r11
	jne	.Lhrdbf_269
	movl	$36, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_271:
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
	jne	.Lhrdbf_271
	jmp	.Lhrdbf_265
	.p2align 4,,10
	.p2align 3
.Lhrdbf_291:
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
.Lhrdbf_313:
	movl	%r12d, %esi
	subl	%r10d, %esi
	testl	%r10d, %r10d
	jne	.Lhrdbf_274
	movl	%esi, %eax
	jmp	.Lhrdbf_275
	.p2align 4,,10
	.p2align 3
.Lhrdbf_276:
	movl	$3, %r8d
	jmp	.Lhrdbf_265
	.p2align 4,,10
	.p2align 3
.Lhrdbf_269:
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
	jmp	.Lhrdbf_265
	.p2align 4,,10
	.p2align 3
.Lhrdbf_314:
	testl	%r14d, %r14d
	je	.Lhrdbf_265
	leal	-1(%r14), %eax
	leaq	1(%r9,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_279:
	movb	$42, (%r9)
	addq	$1, %r9
	cmpq	%r9, %rax
	jne	.Lhrdbf_279
	jmp	.Lhrdbf_265
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
	ja	.Lhrdbf_315
	movl	%edi, %edi
	movq	hrdbf_local_CSWTCH.92(,%rdi,8), %rax
.Lhrdbf_315:
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
	je	.Lhrdbf_321
	movq	2104(%r8), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_322
.Lhrdbf_321:
	movq	$0, 2096(%r8)
	xorl	%eax, %eax
	movq	$0, 2104(%r8)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_322:
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
	je	.Lhrdbf_324
	.p2align 4,,10
	.p2align 3
.Lhrdbf_325:
	addq	$1, %rdx
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrdbf_325
.Lhrdbf_324:
	movl	$1, %r9d
	movl	$2, %edi
	movq	%r9, %rax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_file_close
	xorl	%edx, %edx
	movl	$60, %eax
	movq	%r9, %rdi
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
	je	.Lhrdbf_332
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_352
.Lhrdbf_332:
	xorl	%r10d, %r10d
	movl	$257, %r9d
	movl	$524288, %edx
	movq	$0, 2096(%rbp)
	movq	$0, 2104(%rbp)
	movq	$-100, %rdi
	.p2align 4,,10
	.p2align 3
.Lhrdbf_330:
	movq	%r9, %rax
	movq	%r8, %rsi
#APP
# 11 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movq	%rax, %rbx
	cmpq	$-4, %rax
	je	.Lhrdbf_330
	testq	%rax, %rax
	js	.Lhrdbf_352
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
	js	.Lhrdbf_372
	cmpq	$32, %rax
	jle	.Lhrdbf_373
	cmpq	$67108864, %rax
	jg	.Lhrdbf_374
	movq	%r8, %rax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_375
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
	jb	.Lhrdbf_341
	movq	$0, 2096(%rbp)
.Lhrdbf_342:
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
	jns	.Lhrdbf_336
	.p2align 4,,10
	.p2align 3
.Lhrdbf_371:
	movl	$7, %r8d
	jmp	.Lhrdbf_336
	.p2align 4,,10
	.p2align 3
.Lhrdbf_352:
	movl	$7, %r8d
.Lhrdbf_328:
	addq	$24, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_372:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
.Lhrdbf_336:
	movq	2096(%rbp), %rdi
	movq	$0, 0(%rbp)
	movq	$0, 8(%rbp)
	movl	$0, 16(%rbp)
	movq	$0, 24(%rbp)
	movl	$16842752, 36(%rbp)
	movb	$0, 40(%rbp)
	testq	%rdi, %rdi
	je	.Lhrdbf_351
	movq	2104(%rbp), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_352
.Lhrdbf_351:
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
.Lhrdbf_374:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$4, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_336
	jmp	.Lhrdbf_371
	.p2align 4,,10
	.p2align 3
.Lhrdbf_373:
	movl	$3, %eax
	movq	%r13, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$1, %r8d
	testq	%rax, %rax
	jns	.Lhrdbf_336
	jmp	.Lhrdbf_371
	.p2align 4,,10
	.p2align 3
.Lhrdbf_341:
	movq	%rax, 2096(%rbp)
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.Lhrdbf_342
	movq	2104(%rbp), %rdx
	xorl	%r8d, %r8d
	xorl	%r9d, %r9d
	testq	%rdx, %rdx
	jne	.Lhrdbf_343
	jmp	.Lhrdbf_344
	.p2align 4,,10
	.p2align 3
.Lhrdbf_376:
	movq	2096(%rbp), %rsi
.Lhrdbf_343:
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
	je	.Lhrdbf_345
	testq	%rax, %rax
	jle	.Lhrdbf_355
	addq	%rax, %r8
.Lhrdbf_345:
	movq	2104(%rbp), %rdx
	cmpq	%r8, %rdx
	ja	.Lhrdbf_376
.Lhrdbf_344:
	leaq	15(%rsp), %rsi
	xorl	%r8d, %r8d
	movl	$1, %edx
	.p2align 4,,10
	.p2align 3
.Lhrdbf_347:
	movq	%r8, %rax
	movq	%rbx, %rdi
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	cmpq	$-4, %rax
	je	.Lhrdbf_347
	testq	%rax, %rax
	je	.Lhrdbf_348
	movl	$3, %eax
	movq	%r8, %rsi
	movq	%r8, %rdx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	movl	$7, %r8d
	jmp	.Lhrdbf_336
.Lhrdbf_348:
	movq	2104(%rbp), %rdx
	movq	2096(%rbp), %rsi
	movq	%rbp, %rdi
	call .Lhrdbf_entry_hrdbf_open
	movl	%eax, %r8d
.Lhrdbf_346:
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
	js	.Lhrdbf_371
	testl	%r8d, %r8d
	je	.Lhrdbf_328
	jmp	.Lhrdbf_336
	.p2align 4,,10
	.p2align 3
.Lhrdbf_375:
	movl	$3, %eax
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	jmp	.Lhrdbf_371
.Lhrdbf_355:
	movl	$7, %r8d
	jmp	.Lhrdbf_346
	.size	hrdbf_file_open, .-hrdbf_file_open
	.section	.rodata.str1.1
.Lhrdbf_C1:
	.string	"hbc: DBF close failed\n"
	.text
	.p2align 4
	.globl	hrdbf_app_close
	.type	hrdbf_app_close, @function
hrdbf_app_close:
.Lhrdbf_entry_hrdbf_app_close:
	endbr64
	movq	hrdbf_app_state+2096(%rip), %rdi
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_state+8(%rip)
	movl	$0, hrdbf_app_state+16(%rip)
	movq	$0, hrdbf_app_state+24(%rip)
	movl	$16842752, hrdbf_app_state+36(%rip)
	movb	$0, hrdbf_app_state+40(%rip)
	testq	%rdi, %rdi
	je	.Lhrdbf_378
	movq	hrdbf_app_state+2104(%rip), %rsi
	movl	$11, %eax
	xorl	%edx, %edx
#APP
# 10 "runtime/hrdbf_file_linux.c" 1
	syscall
# 0 "" 2
#NO_APP
	testq	%rax, %rax
	js	.Lhrdbf_382
.Lhrdbf_378:
	movq	$0, hrdbf_app_state+2096(%rip)
	movq	$0, hrdbf_app_state+2104(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_382:
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
	.align 8
.Lhrdbf_C5:
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
	je	.Lhrdbf_384
	cmpb	$0, hrdbf_app_state+40(%rip)
	jne	.Lhrdbf_394
.Lhrdbf_384:
	leaq	-1(%rsi), %rax
	cmpq	$4094, %rax
	ja	.Lhrdbf_395
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.Lhrdbf_385:
	movzbl	(%rdi,%rax), %edx
	testb	%dl, %dl
	je	.Lhrdbf_396
	movb	%dl, (%rsp,%rax)
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.Lhrdbf_385
	movb	$0, (%rsp,%rsi)
	movl	$hrdbf_app_state, %edi
	movq	%rsp, %rsi
	call .Lhrdbf_entry_hrdbf_file_open
	testl	%eax, %eax
	jne	.Lhrdbf_397
	addq	$4104, %rsp
	ret
.Lhrdbf_396:
	movl	$.Lhrdbf_C4, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_395:
	movl	$.Lhrdbf_C3, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_394:
	movl	$.Lhrdbf_C2, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_397:
	movl	$.Lhrdbf_C5, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_open, .-hrdbf_app_open
	.section	.rodata.str1.1
.Lhrdbf_C6:
	.string	"hbc: DBF no workarea is open\n"
	.text
	.p2align 4
	.globl	hrdbf_app_top
	.type	hrdbf_app_top, @function
hrdbf_app_top:
.Lhrdbf_entry_hrdbf_app_top:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_400
	movl	hrdbf_app_state+16(%rip), %eax
	movq	$1, hrdbf_app_state+24(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, hrdbf_app_state+39(%rip)
	movb	%al, hrdbf_app_state+38(%rip)
	ret
.Lhrdbf_400:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_top, .-hrdbf_app_top
	.p2align 4
	.globl	hrdbf_app_skip
	.type	hrdbf_app_skip, @function
hrdbf_app_skip:
.Lhrdbf_entry_hrdbf_app_skip:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_416
	testq	%rdi, %rdi
	je	.Lhrdbf_401
	movb	$0, hrdbf_app_state+38(%rip)
	movq	hrdbf_app_state+24(%rip), %rdx
	jle	.Lhrdbf_404
	movl	hrdbf_app_state+16(%rip), %eax
	movq	%rax, %rsi
	movq	%rax, %rcx
	addq	$1, %rax
	subq	%rdx, %rsi
	addq	%rdi, %rdx
	addq	$1, %rsi
	cmpq	%rdi, %rsi
	cmovnb	%rdx, %rax
	movq	%rax, hrdbf_app_state+24(%rip)
.Lhrdbf_406:
	movl	$1, %eax
	testl	%ecx, %ecx
	jne	.Lhrdbf_417
	movb	%al, hrdbf_app_state+39(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_401:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_404:
	movq	%rdi, %rax
	negq	%rax
	cmpq	%rdx, %rax
	jb	.Lhrdbf_407
	xorl	%eax, %eax
	movb	$1, hrdbf_app_state+38(%rip)
	movq	$1, hrdbf_app_state+24(%rip)
	movb	%al, hrdbf_app_state+39(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_417:
	cmpq	%rcx, hrdbf_app_state+24(%rip)
	seta	%al
	movb	%al, hrdbf_app_state+39(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_407:
	addq	%rdx, %rdi
	movl	hrdbf_app_state+16(%rip), %ecx
	movq	%rdi, hrdbf_app_state+24(%rip)
	jmp	.Lhrdbf_406
.Lhrdbf_416:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_skip, .-hrdbf_app_skip
	.p2align 4
	.globl	hrdbf_app_recno
	.type	hrdbf_app_recno, @function
hrdbf_app_recno:
.Lhrdbf_entry_hrdbf_app_recno:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_420
	movq	hrdbf_app_state+24(%rip), %rax
	ret
.Lhrdbf_420:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_recno, .-hrdbf_app_recno
	.p2align 4
	.globl	hrdbf_app_lastrec
	.type	hrdbf_app_lastrec, @function
hrdbf_app_lastrec:
.Lhrdbf_entry_hrdbf_app_lastrec:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_423
	movl	hrdbf_app_state+16(%rip), %eax
	ret
.Lhrdbf_423:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_lastrec, .-hrdbf_app_lastrec
	.p2align 4
	.globl	hrdbf_app_bof
	.type	hrdbf_app_bof, @function
hrdbf_app_bof:
.Lhrdbf_entry_hrdbf_app_bof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_426
	movzbl	hrdbf_app_state+38(%rip), %eax
	ret
.Lhrdbf_426:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_bof, .-hrdbf_app_bof
	.p2align 4
	.globl	hrdbf_app_eof
	.type	hrdbf_app_eof, @function
hrdbf_app_eof:
.Lhrdbf_entry_hrdbf_app_eof:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_429
	movzbl	hrdbf_app_state+39(%rip), %eax
	ret
.Lhrdbf_429:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_eof, .-hrdbf_app_eof
	.p2align 4
	.globl	hrdbf_app_deleted
	.type	hrdbf_app_deleted, @function
hrdbf_app_deleted:
.Lhrdbf_entry_hrdbf_app_deleted:
	endbr64
	cmpb	$0, hrdbf_app_state+40(%rip)
	je	.Lhrdbf_434
	movq	hrdbf_app_state+24(%rip), %rax
	movl	hrdbf_app_state+16(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.Lhrdbf_430
	movzwl	hrdbf_app_state+34(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	hrdbf_app_state+32(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.Lhrdbf_430:
	movq	%r8, %rax
	ret
.Lhrdbf_434:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_deleted, .-hrdbf_app_deleted
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C7:
	.string	"hbc: DBF field decoding failed\n"
	.align 8
.Lhrdbf_C8:
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
	je	.Lhrdbf_452
	testq	%rdi, %rdi
	jle	.Lhrdbf_447
	movzwl	hrdbf_app_state+36(%rip), %eax
	cmpq	%rdi, %rax
	jge	.Lhrdbf_453
.Lhrdbf_447:
	movl	$1, %eax
	xorl	%edx, %edx
.Lhrdbf_437:
	addq	$288, %rsp
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_453:
	movq	%rsi, %rbx
	movq	%rsp, %rdx
	movl	%edi, %esi
	movl	$hrdbf_app_state, %edi
	call .Lhrdbf_entry_hrdbf_get
	testl	%eax, %eax
	jne	.Lhrdbf_454
	movzbl	(%rsp), %eax
	cmpb	$67, %al
	je	.Lhrdbf_455
	cmpb	$78, %al
	je	.Lhrdbf_456
	cmpb	$68, %al
	je	.Lhrdbf_457
	movzbl	28(%rsp), %edx
	addq	$288, %rsp
	movl	$3, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_455:
	movq	8(%rsp), %rdi
	movzbl	1(%rsp), %esi
	testq	%rdi, %rdi
	je	.Lhrdbf_458
.Lhrdbf_440:
	call	*%rbx
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.Lhrdbf_459
	addq	$288, %rsp
	movl	$4, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_456:
	movzbl	2(%rsp), %eax
	movzbl	1(%rsp), %edx
	salq	$8, %rax
	salq	$16, %rdx
	orq	%rdx, %rax
	movq	16(%rsp), %rdx
	orq	$12, %rax
	jmp	.Lhrdbf_437
	.p2align 4,,10
	.p2align 3
.Lhrdbf_457:
	movl	24(%rsp), %edx
	movl	$11, %eax
	jmp	.Lhrdbf_437
	.p2align 4,,10
	.p2align 3
.Lhrdbf_458:
	leaq	32(%rsp), %rax
	leaq	(%rax,%rsi), %rdx
	testq	%rsi, %rsi
	je	.Lhrdbf_443
	.p2align 4,,10
	.p2align 3
.Lhrdbf_442:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.Lhrdbf_442
.Lhrdbf_443:
	leaq	32(%rsp), %rdi
	jmp	.Lhrdbf_440
.Lhrdbf_452:
	movl	$.Lhrdbf_C6, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_454:
	movl	$.Lhrdbf_C7, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_459:
	movl	$.Lhrdbf_C8, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_get, .-hrdbf_app_get
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C9:
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
	jne	.Lhrdbf_463
	movq	8(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_463:
	movl	$.Lhrdbf_C9, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_render, .-hrdbf_app_render
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C10:
	.string	"hbc: DBF decimal numeric cannot enter I64 operation\n"
	.align 8
.Lhrdbf_C11:
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
	jne	.Lhrdbf_465
	movzbl	%r9b, %eax
	cmpb	$12, %r9b
	je	.Lhrdbf_481
	testl	%eax, %eax
	je	.Lhrdbf_473
	cmpl	$9, %eax
	jne	.Lhrdbf_469
.Lhrdbf_473:
	movq	%r10, %rax
	addq	$8, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_481:
	testl	$65280, %r9d
	je	.Lhrdbf_473
.Lhrdbf_468:
	movl	$.Lhrdbf_C10, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_465:
	cmpl	$2, %eax
	je	.Lhrdbf_468
.Lhrdbf_469:
	movl	$.Lhrdbf_C11, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_integer, .-hrdbf_app_integer
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C12:
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
	je	.Lhrdbf_486
	testl	%eax, %eax
	jne	.Lhrdbf_487
	movslq	12(%rsp), %rax
	addq	$24, %rsp
	ret
.Lhrdbf_486:
	movl	$.Lhrdbf_C10, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
.Lhrdbf_487:
	movl	$.Lhrdbf_C12, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_equal, .-hrdbf_app_equal
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C13:
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
	jne	.Lhrdbf_489
	cmpb	$11, %dl
	je	.Lhrdbf_531
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_495
.Lhrdbf_499:
	movl	$.Lhrdbf_C11, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_495:
	cmpl	$2, %eax
	jne	.Lhrdbf_499
.Lhrdbf_498:
	movl	$.Lhrdbf_C10, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_489:
	movzbl	%dil, %ebx
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_495
	cmpl	$12, %ebx
	jne	.Lhrdbf_496
	testl	$65280, %r9d
	jne	.Lhrdbf_498
.Lhrdbf_497:
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_495
	movzbl	%r10b, %eax
	cmpb	$12, %r10b
	je	.Lhrdbf_532
	testl	%eax, %eax
	je	.Lhrdbf_505
	cmpl	$9, %eax
	jne	.Lhrdbf_499
.Lhrdbf_505:
	cmpq	%r11, %rbp
	jl	.Lhrdbf_507
	setg	%al
	movzbl	%al, %eax
.Lhrdbf_488:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_496:
	testl	%ebx, %ebx
	je	.Lhrdbf_497
	cmpl	$9, %ebx
	je	.Lhrdbf_497
	jmp	.Lhrdbf_499
	.p2align 4,,10
	.p2align 3
.Lhrdbf_507:
	addq	$8, %rsp
	movq	$-1, %rax
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_531:
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_492
	movq	%r10, %rdi
	movq	%r11, %rsi
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_492
	cmpq	%r11, %rbp
	jb	.Lhrdbf_507
	seta	%al
	movzbl	%al, %eax
	jmp	.Lhrdbf_488
	.p2align 4,,10
	.p2align 3
.Lhrdbf_532:
	testl	$65280, %r10d
	je	.Lhrdbf_505
	jmp	.Lhrdbf_498
.Lhrdbf_492:
	movl	$.Lhrdbf_C13, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_compare, .-hrdbf_app_compare
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C15:
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
	jne	.Lhrdbf_534
	movq	-8(%rsi), %rdx
	testq	%rdx, %rdx
	je	.Lhrdbf_543
	movabsq	$-4294977025, %rcx
	addq	%rsi, %rdx
	jmp	.Lhrdbf_536
	.p2align 4,,10
	.p2align 3
.Lhrdbf_555:
	btq	%rax, %rcx
	jc	.Lhrdbf_547
	addq	$1, %r9
	cmpq	%r9, %rdx
	je	.Lhrdbf_543
.Lhrdbf_536:
	movzbl	(%r9), %eax
	cmpb	$32, %al
	jbe	.Lhrdbf_555
.Lhrdbf_547:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_534:
	cmpl	$8, %r10d
	je	.Lhrdbf_556
	cmpl	$5, %r10d
	je	.Lhrdbf_557
	cmpl	$7, %r10d
	je	.Lhrdbf_547
	subq	$8, %rsp
	call .Lhrdbf_entry_hrv_validate
	testl	%eax, %eax
	jne	.Lhrdbf_540
	cmpl	$12, %r10d
	ja	.Lhrdbf_540
	movl	$1, %eax
	movl	%r10d, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.Lhrdbf_541
	cmpl	$1, %r10d
	je	.Lhrdbf_548
.Lhrdbf_540:
	movl	$.Lhrdbf_C15, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.Lhrdbf_543:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_556:
	movl	$1, %eax
	testq	%rsi, %rsi
	je	.Lhrdbf_552
	xorl	%eax, %eax
	cmpq	$0, -8(%rsi)
	sete	%al
	ret
.Lhrdbf_552:
	ret
	.p2align 4,,10
	.p2align 3
.Lhrdbf_557:
	movq	%rsi, %xmm0
	xorl	%eax, %eax
	movl	$0, %edx
	ucomisd	.Lhrdbf_C14(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	ret
.Lhrdbf_541:
	xorl	%eax, %eax
	testq	%r9, %r9
	sete	%al
.Lhrdbf_533:
	addq	$8, %rsp
	ret
.Lhrdbf_548:
	movl	$1, %eax
	jmp	.Lhrdbf_533
	.size	hrdbf_app_empty, .-hrdbf_app_empty
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C16:
	.string	"hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n"
	.text
	.p2align 4
	.globl	hrdbf_app_unsupported
	.type	hrdbf_app_unsupported, @function
hrdbf_app_unsupported:
.Lhrdbf_entry_hrdbf_app_unsupported:
	endbr64
	movl	$.Lhrdbf_C16, %edi
	call .Lhrdbf_entry_hrdbf_app_fail
	.size	hrdbf_app_unsupported, .-hrdbf_app_unsupported
	.section	.rodata.str1.1
.Lhrdbf_C17:
	.string	"ok"
	.section	.rodata.str1.8
	.align 8
.Lhrdbf_C18:
	.string	"DBF value type outside admitted operation"
	.align 8
.Lhrdbf_C19:
	.string	"DBF decimal numeric cannot enter I64 operation"
	.align 8
.Lhrdbf_C20:
	.string	"DBF value output buffer too short"
	.align 8
.Lhrdbf_C21:
	.string	"DBF value tag or metadata invalid"
	.section	.rodata
	.align 32
	.type	hrdbf_local_CSWTCH.92, @object
	.size	hrdbf_local_CSWTCH.92, 40
hrdbf_local_CSWTCH.92:
.Lhrdbf_entry_hrdbf_local_CSWTCH.92:
	.quad	.Lhrdbf_C17
	.quad	.Lhrdbf_C18
	.quad	.Lhrdbf_C19
	.quad	.Lhrdbf_C20
	.quad	.Lhrdbf_C21
	.align 8
	.type	hrdbf_local_CSWTCH.73, @object
	.size	hrdbf_local_CSWTCH.73, 13
hrdbf_local_CSWTCH.73:
.Lhrdbf_entry_hrdbf_local_CSWTCH.73:
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
	.local	hrdbf_app_state
	.comm	hrdbf_app_state,2112,32
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.Lhrdbf_C14:
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
