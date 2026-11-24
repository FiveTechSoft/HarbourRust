	.file	"hrdbf_embedded_windows.c"
	.text
	.p2align 4
	.def	dset;	.scl	3;	.type	32;	.endef
dset:
	leaq	32778(%rcx), %rax
	leaq	32937(%rcx), %r8
	jmp	.L2
	.p2align 4,,10
	.p2align 3
.L4:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%r8, %rax
	jnb	.L3
.L2:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L4
.L3:
	movb	$0, (%rax)
	ret
	.p2align 4
	.def	dcat;	.scl	3;	.type	32;	.endef
dcat:
	leaq	32778(%rcx), %rax
	addq	$32937, %rcx
	jmp	.L7
	.p2align 4,,10
	.p2align 3
.L9:
	addq	$1, %rax
	cmpq	%rax, %rcx
	jbe	.L8
.L7:
	cmpb	$0, (%rax)
	jne	.L9
	jmp	.L13
	.p2align 4,,10
	.p2align 3
.L11:
	movb	%r8b, (%rax)
	addq	$1, %rdx
	addq	$1, %rax
.L13:
	cmpq	%rax, %rcx
	jbe	.L8
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.L11
.L8:
	movb	$0, (%rax)
	ret
	.p2align 4
	.def	hrv_to_double;	.scl	3;	.type	32;	.endef
hrv_to_double:
	pushq	%rbp
	movq	(%rcx), %rax
	movq	%rdx, %r10
	movq	8(%rcx), %rcx
	movl	%eax, %edx
	movq	%rsp, %rbp
	andq	$-16, %rsp
	andl	$255, %edx
	je	.L24
	cmpl	$9, %edx
	je	.L24
	cmpl	$12, %edx
	je	.L30
	movl	$1, %r9d
	cmpl	$5, %edx
	je	.L31
	leave
	movl	%r9d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L24:
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
.L31:
	movq	%rcx, %r11
	testq	%rax, %rax
	js	.L32
	shrq	$8, %rax
	movl	$2, %edx
	testl	%eax, %eax
	cmove	%edx, %eax
.L22:
	xorl	%r9d, %r9d
	movq	%r11, (%r10)
	movl	%eax, (%r8)
	movl	%r9d, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L30:
	pxor	%xmm0, %xmm0
	movzbl	%ah, %edx
	cvtsi2sdq	%rcx, %xmm0
	testb	$-1, %ah
	je	.L19
	movsd	.LC0(%rip), %xmm1
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L20:
	divsd	%xmm1, %xmm0
	addl	$1, %eax
	cmpl	%edx, %eax
	jne	.L20
.L19:
	xorl	%r9d, %r9d
	movsd	%xmm0, (%r10)
	movl	%r9d, %eax
	movl	%edx, (%r8)
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L32:
	movq	(%rcx), %r11
	movzwl	8(%rcx), %eax
	jmp	.L22
	.p2align 4
	.def	bn_shl;	.scl	3;	.type	32;	.endef
bn_shl:
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
	ja	.L33
	movl	%edx, %ebp
	movq	%rcx, %r8
	movl	%edx, %r11d
	andl	$31, %ebp
	je	.L36
	testl	%r12d, %r12d
	je	.L37
	movl	$32, %esi
	leal	-1(%r12), %edx
	movq	%rcx, %rax
	xorl	%r10d, %r10d
	subl	%ebp, %esi
	leaq	4(%rcx,%rdx,4), %rdi
	.p2align 4,,10
	.p2align 3
.L38:
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
	jne	.L38
	testl	%r10d, %r10d
	je	.L42
	leal	1(%r12), %eax
	movl	%r12d, %r12d
	movl	%eax, 288(%r8)
	movl	%r10d, (%r8,%r12,4)
.L42:
	cmpl	$31, %r11d
	jbe	.L33
	movl	288(%r8), %r10d
	leal	-1(%r10), %edx
	addl	%ebx, %r10d
	jmp	.L47
	.p2align 4,,10
	.p2align 3
.L36:
	cmpl	$31, %edx
	jbe	.L33
	leal	-1(%r12), %edx
	testl	%r12d, %r12d
	je	.L40
.L47:
	movl	%edx, %eax
	addl	%ebx, %edx
	leaq	(%r8,%rax,4), %rax
	.p2align 4,,10
	.p2align 3
.L43:
	movl	(%rax), %r9d
	movl	%edx, %ecx
	subl	$1, %edx
	movl	%r9d, (%r8,%rcx,4)
	movq	%rax, %rcx
	subq	$4, %rax
	cmpq	%r8, %rcx
	jne	.L43
.L40:
	testl	%ebx, %ebx
	je	.L46
	leal	-1(%rbx), %edx
	movq	%r8, %rax
	leaq	4(%r8,%rdx,4), %rdx
	.p2align 4,,10
	.p2align 3
.L45:
	movl	$0, (%rax)
	addq	$4, %rax
	cmpq	%rax, %rdx
	jne	.L45
.L46:
	movl	%r10d, 288(%r8)
.L33:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L37:
	cmpl	$31, %edx
	jbe	.L33
	movl	%ebx, %r10d
	jmp	.L40
	.p2align 4
	.def	bn_divmod_1e9;	.scl	3;	.type	32;	.endef
bn_divmod_1e9:
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %edi
	testl	%edi, %edi
	je	.L66
	leal	-1(%rdi), %r9d
	movq	%rcx, %r11
	xorl	%r8d, %r8d
	movabsq	$19342813113834067, %rsi
	movl	%r9d, %eax
	leaq	(%rcx,%rax,4), %r10
	movq	%r10, %rcx
	.p2align 4,,10
	.p2align 3
.L63:
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
	jne	.L63
	movl	%r8d, %eax
	cmpl	$1, %edi
	jne	.L64
	jmp	.L61
	.p2align 4,,10
	.p2align 3
.L65:
	movl	%r9d, 288(%r11)
	subq	$4, %r10
	subl	$1, %r9d
	je	.L61
.L64:
	movl	(%r10), %edx
	testl	%edx, %edx
	je	.L65
.L61:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L66:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4
	.def	hrdbfw_device_eq;	.scl	3;	.type	32;	.endef
hrdbfw_device_eq:
	testq	%rdx, %rdx
	je	.L87
	pushq	%rbx
	movq	%rdx, %r11
	movq	%rcx, %rbx
	xorl	%ecx, %ecx
	jmp	.L74
	.p2align 4,,10
	.p2align 3
.L79:
	movzwl	(%rbx,%rcx,2), %eax
	leal	-97(%rax), %r10d
	leal	-32(%rax), %r9d
	cmpl	$26, %r10d
	cmovb	%r9d, %eax
	cmpl	%eax, %edx
	jne	.L81
	addq	$1, %rcx
	cmpq	%rcx, %r11
	je	.L78
.L74:
	movzbl	(%r8,%rcx), %edx
	testb	%dl, %dl
	jne	.L79
.L81:
	xorl	%eax, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L78:
	addq	%r11, %r8
	xorl	%eax, %eax
	popq	%rbx
	cmpb	$0, (%r8)
	sete	%al
	ret
.L87:
	xorl	%eax, %eax
	cmpb	$0, (%r8)
	sete	%al
	ret
	.p2align 4
	.def	fset;	.scl	3;	.type	32;	.endef
fset:
	leaq	fsink(%rip), %r9
	movq	%r9, %rax
	leaq	159(%r9), %r8
	jmp	.L89
	.p2align 4,,10
	.p2align 3
.L91:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.L90
.L89:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.L91
.L90:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, fsink_len(%rip)
	ret
	.p2align 4
	.def	fcat;	.scl	3;	.type	32;	.endef
fcat:
	movl	fsink_len(%rip), %eax
	leaq	fsink(%rip), %r9
	leaq	159(%r9), %r8
	addq	%r9, %rax
	cmpq	%r8, %rax
	jb	.L93
	jmp	.L94
	.p2align 4,,10
	.p2align 3
.L95:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%r8, %rax
	jnb	.L94
.L93:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.L95
.L94:
	movb	$0, (%rax)
	subq	%r9, %rax
	movl	%eax, fsink_len(%rip)
	ret
	.p2align 4
	.def	nxvisit;	.scl	3;	.type	32;	.endef
nxvisit:
	cmpl	$63, %r8d
	ja	.L140
	movl	%edx, %r9d
	testl	%edx, %edx
	je	.L140
	testl	$1023, %edx
	jne	.L140
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
	ja	.L101
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
	jne	.L101
	movq	(%r10), %r14
	orl	%ecx, %edx
	movb	%dl, (%rax)
	movzwl	32(%rbx), %eax
	addq	%r14, %rdi
	movzwl	(%rdi), %r13d
	cmpw	%ax, %r13w
	ja	.L101
	testw	%r13w, %r13w
	jne	.L125
	testl	%r8d, %r8d
	je	.L125
	.p2align 4,,10
	.p2align 3
.L101:
	movl	$1, %eax
.L97:
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
.L140:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L125:
	leal	4(%rax,%rax), %eax
	xorl	%r12d, %r12d
	leaq	4(%rdi), %r15
	movl	%eax, 40(%rsp)
.L106:
	movzwl	%r12w, %eax
	movzwl	2(%rdi,%rax,2), %r11d
	movq	%r11, %rax
	cmpl	40(%rsp), %r11d
	jl	.L101
	movzwl	34(%rbx), %edx
	addq	%rdx, %rax
	movq	%rdx, %r10
	cmpq	$1024, %rax
	ja	.L101
	testw	%r12w, %r12w
	je	.L103
	leal	-1(%r12), %edx
	leaq	2(%rdi), %rax
	movzwl	%dx, %edx
	leal	(%r11,%r10), %ebp
	leaq	(%r15,%rdx,2), %rsi
	.p2align 4,,10
	.p2align 3
.L105:
	movzwl	(%rax), %edx
	leal	(%rdx,%r10), %ecx
	cmpl	%ecx, %r11d
	jge	.L104
	cmpl	%ebp, %edx
	jl	.L101
.L104:
	addq	$2, %rax
	cmpq	%rsi, %rax
	jne	.L105
.L103:
	addl	$1, %r12d
	cmpw	%r12w, %r13w
	jnb	.L106
	movzwl	2(%rdi), %eax
	movl	(%rdi,%rax), %ebp
	testl	%ebp, %ebp
	jne	.L107
	movl	40(%rbx), %eax
	testl	%eax, %eax
	js	.L144
	cmpl	%r8d, %eax
	jne	.L101
.L107:
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
.L121:
	movzwl	2(%rsi), %r13d
	movl	(%rdi,%r13), %edx
	movq	%r13, %r12
	testl	%edx, %edx
	setne	%al
	cmpb	55(%rsp), %al
	jne	.L101
	testl	%ebp, %ebp
	jne	.L109
.L112:
	cmpq	%rsi, 40(%rsp)
	je	.L110
	movl	4(%rdi,%r13), %edx
	testl	%edx, %edx
	je	.L114
	movq	8(%rbx), %rax
	movl	16(%rax), %eax
	cmpl	%edx, %eax
	jb	.L114
	cmpl	36(%rbx), %eax
	jbe	.L114
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
	jne	.L114
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
	je	.L115
	xorl	%ecx, %ecx
	leaq	(%r14,%r11), %r9
	addq	%r13, %r8
	jmp	.L116
	.p2align 4,,10
	.p2align 3
.L146:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.L145
.L116:
	movzbl	(%r8,%rcx), %r13d
	cmpb	%r13b, (%r9,%rcx)
	je	.L146
.L114:
	movl	$4, %eax
	jmp	.L97
.L109:
	movl	64(%rsp), %r8d
	movq	%rbx, %rcx
	call	nxvisit
	testl	%eax, %eax
	je	.L112
	jmp	.L97
	.p2align 4,,10
	.p2align 3
.L145:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	jne	.L124
.L143:
	movq	16(%r10), %r9
.L119:
	movl	%ecx, %r8d
	addl	$1, %ecx
	addq	$2, %rsi
	leaq	(%r9,%r8,8), %r8
	movl	%edx, (%r8)
	movl	%eax, 4(%r8)
	movl	%ecx, 36(%rbx)
	cmpq	%rsi, 56(%rsp)
	jne	.L121
.L110:
	xorl	%eax, %eax
	jmp	.L97
.L144:
	movl	%r8d, 40(%rbx)
	jmp	.L107
.L124:
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	addq	%r14, %r12
	leaq	(%r9,%r8,8), %r8
	movl	4(%r8), %r10d
	movl	(%r8), %r13d
	addq	%r10, %r12
	leaq	(%r14,%r10), %r8
	movq	%r12, 72(%rsp)
	jmp	.L120
.L118:
	addq	$1, %r8
	cmpq	72(%rsp), %r8
	je	.L122
.L120:
	movq	%r8, %r12
	subq	%r10, %r12
	movzbl	(%r12,%r11), %r12d
	cmpb	%r12b, (%r8)
	je	.L118
	jb	.L119
	jmp	.L101
.L115:
	movl	36(%rbx), %ecx
	testl	%ecx, %ecx
	je	.L143
	movq	16(%r10), %r9
	leal	-1(%rcx), %r8d
	movl	(%r9,%r8,8), %r13d
.L122:
	cmpl	%r13d, %edx
	ja	.L119
	jmp	.L101
	.p2align 4
	.globl	hrntx_open
	.def	hrntx_open;	.scl	2;	.type	32;	.endef
hrntx_open:
	leaq	-2048(%r8), %rax
	movq	$0, (%rcx)
	cmpq	$67106816, %rax
	movq	$0, 8(%rcx)
	movl	$1, %eax
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	ja	.L168
	testq	%rdx, %rdx
	je	.L168
	testl	$1023, %r8d
	jne	.L169
	testq	%r9, %r9
	je	.L169
	cmpb	$0, 40(%r9)
	je	.L211
	cmpw	$6, (%rdx)
	movl	$2, %eax
	jne	.L211
	cmpw	$0, 16(%rdx)
	jne	.L211
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
	jmp	.L150
	.p2align 4,,10
	.p2align 3
.L149:
	addq	$1, %rax
	cmpq	$486, %rax
	je	.L214
.L150:
	cmpq	$11, %rax
	jbe	.L149
	cmpb	$0, 538(%rdx,%rax)
	je	.L149
.L183:
	movl	$2, %eax
.L147:
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
.L168:
	ret
	.p2align 4,,10
	.p2align 3
.L211:
	ret
	.p2align 4,,10
	.p2align 3
.L169:
	ret
.L214:
	movzwl	14(%rdx), %r13d
	movl	$1, %eax
	leal	-1(%r13), %ecx
	cmpw	$254, %cx
	ja	.L147
	leal	8(%r13), %r14d
	cmpw	%r14w, 12(%rdx)
	jne	.L147
	movzwl	18(%rdx), %r15d
	leal	-1(%r15), %ecx
	cmpw	$509, %cx
	ja	.L147
	movl	%r15d, %ecx
	shrw	%cx
	cmpw	20(%rdx), %cx
	jne	.L147
	leal	1(%r15), %ecx
	movzwl	%r14w, %r11d
	xorl	%edi, %edi
	movzwl	%cx, %r10d
	addq	%rcx, %rcx
	imulq	%r11, %r10
	andl	$131070, %ecx
	leaq	2(%r10,%rcx), %rcx
	cmpq	$1024, %rcx
	jbe	.L151
	jmp	.L147
	.p2align 4,,10
	.p2align 3
.L152:
	addq	$1, %rdi
	cmpq	$256, %rdi
	je	.L183
.L151:
	cmpb	$0, 22(%rdx,%rdi)
	jne	.L152
	testq	%rdi, %rdi
	je	.L183
	movzwl	36(%r9), %eax
	movw	%ax, 46(%rsp)
	testq	%rax, %rax
	je	.L183
	movq	%r8, 192(%rsp)
	movq	%r9, %rbp
	xorl	%r12d, %r12d
	movq	%rax, %r8
.L153:
	xorl	%ecx, %ecx
	jmp	.L162
	.p2align 4,,10
	.p2align 3
.L215:
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
	jne	.L155
	addq	$1, %rcx
	cmpq	%rdi, %rcx
	jnb	.L154
	cmpq	$10, %rcx
	ja	.L154
.L162:
	movzbl	42(%rbp,%rcx), %eax
	testb	%al, %al
	jne	.L215
.L155:
	cmpq	%rdi, %rcx
	je	.L167
.L159:
	addq	$1, %r12
	addq	$16, %rbp
	cmpq	%r8, %r12
	jne	.L153
	jmp	.L183
.L154:
	cmpq	%rdi, %rcx
	jne	.L159
	cmpq	$11, %rcx
	je	.L160
.L167:
	movq	%r12, %rax
	salq	$4, %rax
	addq	%r9, %rax
	cmpb	$0, 42(%rcx,%rax)
	jne	.L159
.L160:
	movq	192(%rsp), %r8
	movl	%r12d, %r10d
	cmpw	%r12w, 46(%rsp)
	je	.L183
	movq	%r12, %rcx
	movl	$2, %eax
	salq	$4, %rcx
	addq	%r9, %rcx
	cmpb	$67, 53(%rcx)
	jne	.L147
	movzbl	54(%rcx), %ecx
	cmpw	%r13w, %cx
	jne	.L147
	movl	16(%r9), %eax
	cmpq	216(%rsp), %rax
	ja	.L189
	cmpq	$0, 208(%rsp)
	jne	.L190
	testl	%eax, %eax
	jne	.L189
.L190:
	movq	%r8, %rcx
	addq	$7, %rax
	shrq	$10, %rcx
	shrq	$3, %rax
	addq	$7, %rcx
	shrq	$3, %rcx
	cmpq	$0, 224(%rsp)
	je	.L189
	addq	%rcx, %rax
	cmpq	232(%rsp), %rax
	ja	.L189
	movq	224(%rsp), %r11
	addq	%r11, %rax
.L164:
	movb	$0, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.L164
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
	call	nxvisit
	testl	%eax, %eax
	jne	.L165
	movq	200(%rsp), %r9
	movl	84(%rsp), %edx
	cmpl	16(%r9), %edx
	je	.L166
	movl	$4, %eax
.L165:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L147
.L166:
	movl	%edx, 24(%rbx)
	jmp	.L147
.L189:
	movl	$3, %eax
	jmp	.L147
	.p2align 4
	.def	nxputslot;	.scl	3;	.type	32;	.endef
nxputslot:
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
.L218:
	xorl	%edx, %edx
	testq	%rcx, %rcx
	je	.L217
	movzbl	(%rcx,%rax), %edx
.L217:
	movb	%dl, 8(%r9,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.L218
	popq	%rbx
	ret
	.p2align 4
	.def	cxleaf_header;	.scl	3;	.type	32;	.endef
cxleaf_header:
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
	jne	.L229
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.L231
.L229:
	movl	$1, %eax
.L223:
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
.L231:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.L223
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.L223
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.L223
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.L229
	cmpl	%r10d, %r13d
	jb	.L229
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.L223
	.p2align 4
	.def	cxkey;	.scl	3;	.type	32;	.endef
cxkey:
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
	je	.L233
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L234:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.L234
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.L235
	testl	%edx, %edx
	je	.L235
.L237:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L235:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.L237
.L243:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.L237
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.L237
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.L238
	xorl	%eax, %eax
	jmp	.L239
	.p2align 4,,10
	.p2align 3
.L256:
	movq	(%rsi), %rcx
.L239:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.L256
.L238:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.L242
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L241:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L241
.L242:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L233:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.L243
	.p2align 4
	.def	cxvisit;	.scl	3;	.type	32;	.endef
cxvisit:
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
	je	.L260
	cmpl	$1023, %edx
	ja	.L311
.L260:
	movl	$1, %r12d
.L257:
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
.L311:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.L260
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.L260
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
	jne	.L260
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.L261
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.L260
.L261:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.L312
	cmpl	%r10d, %ecx
	jne	.L260
	cmpl	%edx, 312(%rax)
	jne	.L260
.L283:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.L265
	cmpl	$1023, %ecx
	jbe	.L260
	testl	$511, %ecx
	jne	.L260
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.L260
.L265:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.L266
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.L313
	cmpl	%r8d, %eax
	jne	.L260
.L268:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L257
	testl	%r13d, %r13d
	je	.L278
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.L269:
	movq	72(%rsp), %rax
	movzwl	28(%r14), %r9d
	movl	%r12d, %r8d
	movq	%r15, %rdx
	movq	%rbp, 32(%rsp)
	movq	%rsi, %rcx
	movq	%rax, 48(%rsp)
	movq	80(%rsp), %rax
	movq	%rax, 40(%rsp)
	call	cxkey
	testl	%eax, %eax
	jne	.L288
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.L271
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.L271
	cmpl	48(%rbx), %edx
	jbe	.L271
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.L271
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
	je	.L272
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.L273
.L315:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.L314
	movq	%rdx, %rax
.L273:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.L315
.L271:
	movl	$4, %r12d
	jmp	.L257
	.p2align 4,,10
	.p2align 3
.L312:
	cmpl	$-1, %r10d
	jne	.L260
	jmp	.L283
.L266:
	testl	%r13d, %r13d
	je	.L260
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.L260
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.L281:
	addl	$8, %eax
	movl	%r15d, %r8d
	movq	%rbx, %rcx
	movl	%r9d, %r14d
	imull	%ebp, %eax
	leal	12(%rax), %edi
	addq	%rsi, %rdi
	movl	4(%rdx,%rdi), %edx
	bswap	%edx
	call	cxvisit
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L257
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.L260
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
	jne	.L260
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.L279
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.L280
	.p2align 4,,10
	.p2align 3
.L316:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L279
.L280:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.L316
	jmp	.L260
.L313:
	movl	%r8d, 52(%rbx)
	jmp	.L268
.L279:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.L257
	movzwl	%r8w, %eax
	jmp	.L281
.L314:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.L286
.L310:
	movq	16(%r14), %rcx
.L276:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.L269
	movzwl	94(%rsp), %edi
.L278:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.L257
.L286:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.L277
.L275:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.L284
	movq	%r11, %r8
.L277:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.L275
	jb	.L276
	jmp	.L260
.L272:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.L310
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.L284:
	cmpl	%edi, %r9d
	ja	.L276
	jmp	.L260
.L288:
	movl	%eax, %r12d
	jmp	.L257
	.p2align 4
	.def	cxheader;	.scl	3;	.type	32;	.endef
cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.L317
	cmpb	$1, 15(%rcx)
	jne	.L317
	cmpw	$1024, 16(%rcx)
	jne	.L317
	cmpw	$512, 18(%rcx)
	jne	.L317
	cmpw	$0, 502(%rcx)
	jne	.L317
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.L320
	.p2align 4,,10
	.p2align 3
.L340:
	cmpl	$23, %eax
	ja	.L327
.L319:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.L339
.L320:
	cmpb	$0, (%rcx,%rax)
	je	.L319
	testb	%dl, %dl
	je	.L340
.L327:
	movl	$2, %eax
.L317:
	ret
.L339:
	testl	%r8d, %r8d
	je	.L321
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.L317
	cmpb	$67, 21(%rcx)
	jne	.L317
	cmpb	$72, 22(%rcx)
	jne	.L317
	cmpb	$66, 23(%rcx)
	jne	.L317
.L321:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.L317
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.L317
	xorl	%eax, %eax
	cmpw	$0, 508(%rcx)
	setne	%al
	addl	%eax, %eax
	ret
	.p2align 4
	.def	hrdbf_app_pad_ll;	.scl	3;	.type	32;	.endef
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
	js	.L360
	jne	.L343
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r11
	je	.L345
.L344:
	leaq	(%r8,%r9), %rdx
	leaq	(%rdx,%r11), %r10
	.p2align 4,,10
	.p2align 3
.L349:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%r10, %rdx
	jne	.L349
	addq	%r9, %r11
.L345:
	movq	%rsp, %r10
	addq	%r11, %r8
	leaq	(%r10,%rcx), %rdx
	.p2align 4,,10
	.p2align 3
.L350:
	movzbl	-1(%rdx), %r9d
	subq	$1, %rdx
	addq	$1, %r8
	movb	%r9b, -1(%r8)
	cmpq	%r10, %rdx
	jne	.L350
	addq	$40, %rsp
	leaq	(%rcx,%r11), %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L360:
	negq	%r9
.L343:
	xorl	%ecx, %ecx
	leaq	-1(%rsp), %rbp
	movabsq	$-3689348814741910323, %rsi
	.p2align 4,,10
	.p2align 3
.L346:
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
	ja	.L346
	testq	%rdi, %rdi
	jns	.L352
	movb	$45, (%r8)
	addq	$2, %rbx
	movl	$1, %r9d
.L347:
	subq	%rbx, %r11
	jne	.L344
	movq	%r9, %r11
	jmp	.L345
.L352:
	movq	%rcx, %rbx
	xorl	%r9d, %r9d
	jmp	.L347
	.p2align 4
	.def	hrdbf_app_write;	.scl	3;	.type	32;	.endef
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.L362
	.p2align 4,,10
	.p2align 3
.L363:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.L363
.L362:
	movl	$-12, %ecx
	call	*__imp_GetStdHandle(%rip)
	leaq	60(%rsp), %r9
	movl	%ebx, %r8d
	movq	%r12, %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*__imp_WriteFile(%rip)
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
	.def	write_at;	.scl	3;	.type	32;	.endef
write_at:
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
	call	*__imp_SetFilePointerEx(%rip)
	testl	%eax, %eax
	je	.L370
	movq	__imp_WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.L371
	jmp	.L372
	.p2align 4,,10
	.p2align 3
.L383:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.L370
	cmpq	%rax, %rbx
	jb	.L370
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.L372
.L371:
	movq	32968(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.L383
.L370:
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
.L372:
	addq	$64, %rsp
	xorl	%eax, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4
	.def	hrdbf_get.part.0;	.scl	3;	.type	32;	.endef
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
	ja	.L384
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.L464
	cmpb	$78, %r9b
	je	.L465
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.L466
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.L411
	cmpb	$89, %al
	je	.L411
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.L384
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.L384
	movabsq	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.L384:
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
.L411:
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
.L465:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.L388
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.L389
	.p2align 4,,10
	.p2align 3
.L390:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.L388
.L389:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.L390
	jmp	.L392
	.p2align 4,,10
	.p2align 3
.L416:
	movl	%r9d, %ecx
.L392:
	cmpl	%eax, %ecx
	jbe	.L391
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.L416
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.L394
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.L414:
	movl	%eax, %ecx
	subl	%eax, %r9d
	xorl	%ebp, %ebp
	xorl	%ebx, %ebx
	leaq	1(%rdx,%rcx), %rax
	leaq	(%rdx,%rcx), %r11
	xorl	%esi, %esi
	xorl	%edx, %edx
	movabsq	$-3689348814741910323, %r13
	addq	%rax, %r9
	jmp	.L398
	.p2align 4,,10
	.p2align 3
.L468:
	testl	%esi, %esi
	jne	.L435
	movl	$1, %esi
.L396:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.L467
.L398:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.L468
.L435:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L428
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.L425
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.L396
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.L396
	.p2align 4,,10
	.p2align 3
.L464:
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
.L466:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.L407:
	cmpb	$32, (%rax)
	jne	.L427
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.L407
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L384
	.p2align 4,,10
	.p2align 3
.L428:
	movl	$5, %r11d
	jmp	.L384
	.p2align 4,,10
	.p2align 3
.L427:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L406:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.L428
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.L406
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
	jbe	.L384
	cmpl	$11, %edx
	ja	.L384
	testl	%r10d, %r10d
	je	.L384
	leaq	days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.L469
.L409:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.L384
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L384
	.p2align 4,,10
	.p2align 3
.L394:
	movabsq	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.L395:
	cmpl	%eax, %ecx
	jbe	.L428
	leal	-1(%rcx), %r9d
	jmp	.L414
	.p2align 4,,10
	.p2align 3
.L425:
	movl	$4, %r11d
	jmp	.L384
	.p2align 4,,10
	.p2align 3
.L467:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.L384
	cmpl	%ebp, %r10d
	jb	.L384
	leal	1(%rbp), %eax
	jbe	.L399
	movabsq	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.L400
	jmp	.L425
	.p2align 4,,10
	.p2align 3
.L401:
	cmpq	%rcx, %rbx
	ja	.L425
.L400:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.L401
	testl	%r12d, %r12d
	jne	.L413
.L404:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L384
.L391:
	je	.L388
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.L394
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.L395
	.p2align 4,,10
	.p2align 3
.L388:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L384
.L469:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.L409
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.L410
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L409
.L410:
	addl	$1, %edx
	jmp	.L409
.L399:
	testl	%r12d, %r12d
	je	.L404
	movabsq	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.L404
.L413:
	negq	%rbx
	jmp	.L404
	.p2align 4
	.def	hrntx_file_close.constprop.0;	.scl	3;	.type	32;	.endef
hrntx_file_close.constprop.0:
	pushq	%r12
	subq	$32, %rsp
	movq	64+hrdbf_app_order(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, 8+hrdbf_app_order(%rip)
	movq	$0, 16+hrdbf_app_order(%rip)
	movq	$0, 24+hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	je	.L473
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L485
.L473:
	xorl	%r12d, %r12d
.L472:
	movq	32+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L474
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L486
	movl	$7, %r12d
.L474:
	movq	40+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L470
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L477
	movq	$0, 40+hrdbf_app_order(%rip)
	movq	$0, 56+hrdbf_app_order(%rip)
.L470:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L486:
	movq	$0, 32+hrdbf_app_order(%rip)
	movq	$0, 48+hrdbf_app_order(%rip)
	jmp	.L474
	.p2align 4,,10
	.p2align 3
.L485:
	movl	$7, %r12d
	jmp	.L472
	.p2align 4,,10
	.p2align 3
.L477:
	movl	$7, %r12d
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4
	.def	cxmark.isra.0;	.scl	3;	.type	32;	.endef
cxmark.isra.0:
	movq	%rcx, %r8
	movl	%edx, %ecx
	shrl	$3, %edx
	movl	$1, %eax
	andl	$7, %ecx
	addq	%r8, %rdx
	sall	%cl, %eax
	movzbl	(%rdx), %ecx
	testb	%al, %cl
	jne	.L487
	orl	%ecx, %eax
	movb	%al, (%rdx)
.L487:
	ret
	.p2align 4
	.globl	hrcdx_open
	.def	hrcdx_open;	.scl	2;	.type	32;	.endef
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
	ja	.L493
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.L493
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.L493
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.L493
	cmpb	$0, 40(%r9)
	je	.L493
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	cxheader
	testl	%eax, %eax
	jne	.L489
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.L489
	cmpw	$1, 510(%rdi)
	jne	.L489
	cmpb	$0, 512(%rdi)
	jne	.L489
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.L493
	testl	$511, %r12d
	jne	.L493
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.L493
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.L489
	cmpw	$1, 2(%rdi,%rdx)
	jne	.L489
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.L493
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.L493
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L489
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
	call	cxkey
	testl	%eax, %eax
	jne	.L489
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L493
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.L493
	testl	$511, %eax
	jne	.L493
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.L493
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.L493
	cmpl	%r12d, %eax
	je	.L493
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.L493
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L494
.L567:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.L531
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L566
.L494:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L567
.L531:
	movl	$2, %eax
	jmp	.L489
	.p2align 4,,10
	.p2align 3
.L493:
	movl	$1, %eax
.L489:
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
.L566:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	cxheader
	testl	%eax, %eax
	jne	.L489
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L531
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.L531
	cmpb	$0, (%rdi,%rcx)
	jne	.L531
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.L495:
	cmpb	$0, (%r14,%rcx)
	je	.L531
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L495
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.L496:
	cmpq	%r9, %r8
	jbe	.L531
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.L505:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.L499
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.L500
	subl	$32, %ecx
.L500:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.L501
	subl	$32, %r13d
.L501:
	cmpb	%cl, %r13b
	jne	.L499
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L497
	cmpq	$11, %rdx
	jne	.L505
	cmpq	$11, %rax
	jne	.L499
.L503:
	cmpl	%r9d, 72(%rsp)
	je	.L531
	cmpb	$67, 53(%r10)
	jne	.L531
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.L530
	cmpw	12(%rdi,%r11), %ax
	jne	.L531
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.L535
	cmpq	$0, 1072(%rsp)
	jne	.L537
	testl	%eax, %eax
	jne	.L535
.L537:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.L535
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.L535
	xorl	%edx, %edx
.L507:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L507
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L508
	orl	$1, %eax
	movb	%al, (%rcx)
.L508:
	testb	$2, %al
	jne	.L509
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L509:
	movq	1088(%rsp), %rcx
	movl	%r12d, %edx
	shrl	$9, %edx
	call	cxmark.isra.0
	movl	84(%rsp), %edx
	movq	1088(%rsp), %rcx
	shrl	$9, %edx
	call	cxmark.isra.0
	movl	84(%rsp), %edx
	movq	1088(%rsp), %rcx
	shrl	$9, %edx
	addl	$1, %edx
	call	cxmark.isra.0
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
.L510:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L510
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	cxvisit
	testl	%eax, %eax
	je	.L568
.L511:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L489
.L497:
	cmpq	$11, %rax
	je	.L503
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L503
.L499:
	addq	$1, %r9
	jmp	.L496
.L535:
	movl	$3, %eax
	jmp	.L489
.L530:
	movl	$5, %eax
	jmp	.L489
.L568:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.L511
	xorl	%edx, %edx
	jmp	.L513
.L569:
	cmpq	$63, %rdx
	ja	.L538
.L513:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.L512
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.L512:
	addq	$1, %rdx
	testb	$1, %al
	je	.L569
.L538:
	testl	%eax, %eax
	jne	.L511
	movl	%ecx, 24(%rbx)
	jmp	.L489
	.p2align 4
	.def	put_number.isra.0;	.scl	3;	.type	32;	.endef
put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.L570
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.L591
	subl	%r10d, %edx
	je	.L576
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.L577:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.L577
.L576:
	testl	%r10d, %r10d
	je	.L575
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.L578:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.L578
.L575:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L570:
	ret
	.p2align 4,,10
	.p2align 3
.L591:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.L575
	.p2align 4,,10
	.p2align 3
.L574:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.L575
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.L574
	jmp	.L575
	.p2align 4
	.def	hrdbf_write_number_scaled.part.0;	.scl	3;	.type	32;	.endef
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
	ja	.L592
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.L618
	cmpb	%r8b, %r13b
	jnb	.L618
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.L594
	negq	%rcx
	movl	$1, %r11d
.L594:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.L595
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.L596
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L597:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.L597
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq	%r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.L598
.L596:
	addq	$1, %rcx
.L598:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabsq	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.L603:
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
	ja	.L603
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
	ja	.L646
	testl	%r11d, %r11d
	je	.L609
	movb	$45, 96(%rsp)
.L609:
	cmpl	%r10d, %ebp
	jb	.L647
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.L611:
	testb	%r13b, %r13b
	je	.L613
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.L614
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L615:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.L615
	addl	%ebp, %eax
.L614:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.L616:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.L616
.L613:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	put_number.isra.0
.L592:
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
.L618:
	movl	$4, %eax
	jmp	.L592
	.p2align 4,,10
	.p2align 3
.L595:
	jnb	.L598
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.L598
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.L599
	xorl	%eax, %eax
	jmp	.L600
	.p2align 4,,10
	.p2align 3
.L602:
	cmpq	%rdx, %rcx
	ja	.L599
.L600:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.L602
	jmp	.L598
	.p2align 4,,10
	.p2align 3
.L647:
	testl	%r14d, %r14d
	je	.L622
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.L612
	.p2align 4,,10
	.p2align 3
.L648:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.L612:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.L648
	jmp	.L611
	.p2align 4,,10
	.p2align 3
.L646:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L607:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L607
	xorl	%eax, %eax
	jmp	.L592
	.p2align 4,,10
	.p2align 3
.L599:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.L601:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.L601
	xorl	%eax, %eax
	jmp	.L592
.L622:
	movl	%r11d, %edx
	jmp	.L611
	.p2align 4
	.def	bn_shr_round;	.scl	3;	.type	32;	.endef
bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.L698
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.L701
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.L657
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.L659
.L658:
	xorl	%ecx, %ecx
	jmp	.L662
	.p2align 4,,10
	.p2align 3
.L661:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.L702
	movl	%eax, %ecx
.L662:
	cmpl	%ecx, %r10d
	jbe	.L661
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L661
.L660:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.L659
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.L667
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.L666:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.L666
.L667:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.L659
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L668:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L668
.L659:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.L649
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.L669
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.L670:
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
	jne	.L670
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.L649
	movl	%edi, 288(%r9)
	jmp	.L649
	.p2align 4,,10
	.p2align 3
.L701:
	testl	%r10d, %r10d
	je	.L652
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L654:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.L654
	testl	%eax, %eax
	je	.L652
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L655:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.L655
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.L652
	jne	.L677
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.L652
.L677:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.L652:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.L649:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L698:
	ret
	.p2align 4,,10
	.p2align 3
.L657:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.L658
	jmp	.L660
	.p2align 4,,10
	.p2align 3
.L702:
	xorl	%eax, %eax
	jmp	.L660
.L669:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.L649
	.p2align 4
	.def	fdec;	.scl	3;	.type	32;	.endef
fdec:
	pushq	%rsi
	movq	%rcx, %r8
	xorl	%r10d, %r10d
	movabsq	$-3689348814741910323, %r9
	pushq	%rbx
	subq	$56, %rsp
	.p2align 4,,10
	.p2align 3
.L704:
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
	jbe	.L712
	cmpl	$19, %r10d
	jbe	.L704
.L712:
	leaq	fsink(%rip), %rbx
	movl	fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.L710:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.L706
	jmp	.L707
	.p2align 4,,10
	.p2align 3
.L708:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.L707
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.L706:
	testb	%cl, %cl
	jne	.L708
.L707:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.L703
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L710
	.p2align 4,,10
	.p2align 3
.L703:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
	.def	hrdbf_file_append.part.0;	.scl	3;	.type	32;	.endef
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
	ja	.L719
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, %r13
	testq	%rax, %rax
	je	.L727
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 32952(%rbx)
	je	.L724
	.p2align 4,,10
	.p2align 3
.L721:
	movq	32944(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	32952(%rbx), %rax
	jb	.L721
.L724:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.L723
	.p2align 4,,10
	.p2align 3
.L722:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L722
	addq	%r14, %rdx
.L723:
	movb	$26, (%rdx)
	leaq	32(%rsp), %rcx
	call	*__imp_GetSystemTime(%rip)
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
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	je	.L739
.L725:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*__imp_VirtualFree(%rip)
.L719:
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
.L739:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L725
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L725
	xorl	%edx, %edx
	movq	32944(%rbx), %rcx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L730
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
	jmp	.L719
	.p2align 4,,10
	.p2align 3
.L727:
	movl	$8, %r15d
	jmp	.L719
.L730:
	movl	$7, %r15d
	jmp	.L725
	.p2align 4
	.def	hrdbf_fmt_harbour.part.0;	.scl	3;	.type	32;	.endef
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
	je	.L748
	movabsq	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.L986
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.L746:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.L751:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L752:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.L752
	testq	%rax, %rax
	je	.L753
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.L753:
	subl	$1, %r9d
	jne	.L751
	testb	%r11b, %r11b
	je	.L755
	movl	%r10d, 352(%rsp)
.L755:
	testl	%r12d, %r12d
	js	.L756
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	bn_shl
.L983:
	movl	352(%rsp), %eax
.L759:
	xorl	%ebx, %ebx
	jmp	.L757
	.p2align 4,,10
	.p2align 3
.L762:
	cmpq	$80, %rbx
	je	.L987
	movq	%rdi, %rcx
	call	bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.L757:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.L762
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.L762
	testl	%ebx, %ebx
	jne	.L988
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.L747
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.L989
.L748:
	xorl	%eax, %eax
.L740:
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
.L986:
	testq	%rax, %rax
	jne	.L990
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.L747
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.L748
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L750:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L750
	jmp	.L740
.L747:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.L748
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.L740
.L990:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.L746
.L756:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	bn_shr_round
	cmpl	$1, %eax
	jbe	.L983
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.L855
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.L761:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.L761
	testq	%rdx, %rdx
	je	.L759
	leal	1(%rax), %edx
.L760:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.L759
.L987:
	movl	$79, %r10d
.L765:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.L769:
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
	ja	.L769
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.L771
.L991:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L771:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.L991
	testl	%r10d, %r10d
	je	.L772
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.L774:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.L773:
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
	jne	.L773
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.L992
	movq	%rax, %rbp
	jmp	.L774
.L992:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.L772:
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
.L776:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L777:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L777
	testq	%rax, %rax
	je	.L778
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.L778:
	subl	$1, %r9d
	jne	.L776
	testb	%dil, %dil
	je	.L780
	movl	%r10d, 656(%rsp)
.L780:
	leal	339(%r15), %r14d
	movq	%r11, %rcx
	movl	%r14d, %edx
	call	bn_shl
	cmpl	$-1074, %r15d
	movabsq	$4503599627370496, %rax
	setne	%r11b
	cmpq	%rax, 40(%rsp)
	sete	%al
	andb	%al, %r11b
	je	.L781
	movl	$340, %ebx
	xorl	%ebp, %ebp
	movl	$2, %edi
	movabsq	$18014398509481983, %rax
	movq	%rax, 672(%rsp)
	leaq	672(%rsp), %r9
	leaq	676(%rsp), %r10
	movl	$2, 960(%rsp)
	.p2align 4,,10
	.p2align 3
.L782:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L783:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L783
	testq	%rax, %rax
	je	.L784
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L784:
	subl	$1, %ebx
	jne	.L782
	testb	%bpl, %bpl
	je	.L786
	movl	%edi, 960(%rsp)
.L786:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	bn_shl
.L787:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.L794
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.L821:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L795:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.L795
	cmpb	$53, (%rdi)
	ja	.L796
	je	.L993
.L797:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.L994
.L799:
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
	je	.L803
	.p2align 4,,10
	.p2align 3
.L802:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L804:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.L804
	testq	%rax, %rax
	je	.L805
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.L805:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.L802
	testb	%r15b, %r15b
	je	.L803
	movl	%r9d, 1264(%rsp)
.L803:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.L808
	jnb	.L809
	cmpl	656(%rsp), %r8d
	jne	.L810
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.L817
	.p2align 4,,10
	.p2align 3
.L820:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.L995
.L817:
	cmpl	$-1, %eax
	jne	.L820
.L816:
	testb	$1, 40(%rsp)
	je	.L975
.L810:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.L976
	cmpl	%r12d, %ebp
	jb	.L821
.L976:
	movq	2400(%rsp), %rsi
.L794:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.L823:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.L824:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.L824
	cmpl	%r12d, %ebp
	jnb	.L825
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.L826
	jne	.L825
	testb	$1, %r8b
	jne	.L826
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.L825
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.L827
.L996:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.L825
.L827:
	cmpb	$48, (%rcx)
	je	.L996
.L826:
	addq	$1, %r8
.L825:
	movabsq	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.L828:
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
	ja	.L828
	cmpl	%ebp, %ecx
	jbe	.L829
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.L833
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.L829:
	xorl	%edx, %edx
	jmp	.L831
.L997:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L831:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L997
	cmpl	$1, %ecx
	jbe	.L832
.L998:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L832
	movl	%eax, %ecx
.L833:
	cmpl	$1, %ecx
	ja	.L998
.L832:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.L999
	cmpl	%ecx, %r8d
	jge	.L838
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.L844
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.L841
.L840:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.L1000
	movq	%rcx, %rdx
.L841:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.L840
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.L844
	.p2align 4,,10
	.p2align 3
.L1002:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.L1001
	movl	%edx, %r8d
.L844:
	cmpl	$1, %r8d
	jne	.L1002
.L843:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.L836
	.p2align 4,,10
	.p2align 3
.L808:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.L813
	.p2align 4,,10
	.p2align 3
.L815:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.L1003
.L813:
	cmpl	$-1, %edx
	jne	.L815
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.L817
	jmp	.L816
.L993:
	testb	$1, %r8b
	jne	.L796
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.L797
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.L798
.L1004:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L797
.L798:
	cmpb	$48, (%rax)
	je	.L1004
.L796:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.L799
.L994:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L800:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.L800
	cmpl	%ebp, %r9d
	jbe	.L799
	movabsq	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.L799
.L995:
	jnb	.L819
	cmpl	$1, %ecx
	je	.L975
.L819:
	testl	%ecx, %ecx
	jne	.L810
	jmp	.L816
.L1003:
	jnb	.L814
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.L817
	jmp	.L810
.L809:
	cmpl	656(%rsp), %r8d
	jne	.L984
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.L817
.L984:
	jnb	.L810
.L975:
	movq	2400(%rsp), %rsi
	jmp	.L823
.L814:
	cmpl	656(%rsp), %r8d
	jne	.L984
	movl	$1, %ecx
	jmp	.L817
.L781:
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
.L789:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L790:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.L790
	testq	%rax, %rax
	je	.L791
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L791:
	subl	$1, %ebx
	jne	.L789
	testb	%r11b, %r11b
	je	.L793
	movl	%edi, 960(%rsp)
.L793:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	bn_shl
	jmp	.L787
.L838:
	cmpl	$1, %ecx
	je	.L843
.L836:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.L845:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.L748
	testl	%r10d, %r10d
	je	.L869
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.L847:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.L848
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.L850:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.L849
	movzbl	0(%r13,%rdx), %r11d
.L849:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.L850
	addl	%r10d, %eax
.L851:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.L740
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.L853
.L1006:
	cmpl	%ecx, %edx
	jnb	.L871
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.L852:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.L1005
.L853:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.L1006
.L871:
	movl	$48, %r10d
	jmp	.L852
.L869:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.L847
.L999:
	jne	.L835
	cmpb	$52, 1600(%rsp)
	jbe	.L835
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.L836
.L835:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.L845
.L848:
	movb	$48, (%rdx)
	jmp	.L851
.L1005:
	addl	%r9d, %eax
	jmp	.L740
.L988:
	subl	$1, %r10d
	jmp	.L765
.L989:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L768:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L768
	jmp	.L740
.L1001:
	movl	%r8d, %ecx
	jmp	.L836
.L855:
	movl	$1, %edx
	jmp	.L760
.L1000:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.L844
	.p2align 4
	.def	hrdbf_write_number_double.part.0;	.scl	3;	.type	32;	.endef
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.L1014
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.L1007
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.L1007
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	put_number.isra.0
.L1007:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1014:
	ret
	.section .rdata,"dr"
.LC1:
	.ascii " (win32 error \0"
	.text
	.p2align 4
	.def	werr;	.scl	3;	.type	32;	.endef
werr:
	pushq	%rsi
	leaq	fsink(%rip), %rsi
	movl	%edx, %r8d
	pushq	%rbx
	movq	%rsi, %rax
	leaq	159(%rsi), %rbx
	subq	$40, %rsp
	jmp	.L1018
	.p2align 4,,10
	.p2align 3
.L1020:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L1019
.L1018:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.L1020
.L1019:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L1021
	movl	$32, %ecx
	leaq	.LC1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.L1023:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.L1027
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1023
.L1027:
	movl	%eax, %edx
	subl	%esi, %edx
.L1021:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, fsink_len(%rip)
	call	fdec
	movl	fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L1024
	movb	$41, (%rax)
	addq	$1, %rax
.L1024:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, fsink_len(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
	.def	ddec;	.scl	3;	.type	32;	.endef
ddec:
	pushq	%rsi
	movq	%rcx, %r8
	movq	%rdx, %r9
	xorl	%r10d, %r10d
	movabsq	$-3689348814741910323, %r11
	pushq	%rbx
	subq	$56, %rsp
	.p2align 4,,10
	.p2align 3
.L1029:
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
	jbe	.L1039
	cmpl	$19, %r10d
	jbe	.L1029
.L1039:
	leaq	32778(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$32937, %r8
	.p2align 4,,10
	.p2align 3
.L1037:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.L1031
	.p2align 4,,10
	.p2align 3
.L1033:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.L1032
.L1031:
	cmpb	$0, (%rax)
	jne	.L1033
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.L1034
	jmp	.L1032
	.p2align 4,,10
	.p2align 3
.L1035:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.L1032
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.L1034:
	testb	%cl, %cl
	jne	.L1035
.L1032:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.L1028
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L1037
.L1028:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4
	.def	dname;	.scl	3;	.type	32;	.endef
dname:
	pushq	%rbx
	movq	%rcx, %r10
	movq	%rdx, %r11
	xorl	%r9d, %r9d
	movl	$63, %ebx
	leaq	32937(%rcx), %r8
	subq	$16, %rsp
	.p2align 4,,10
	.p2align 3
.L1047:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.L1046
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	32778(%r10), %rax
	jmp	.L1049
	.p2align 4,,10
	.p2align 3
.L1051:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.L1050
.L1049:
	cmpb	$0, (%rax)
	jne	.L1051
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.L1052
	jmp	.L1050
	.p2align 4,,10
	.p2align 3
.L1053:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.L1050
.L1052:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1053
.L1050:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.L1047
.L1046:
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
.LC2:
	.ascii "0123456789ABCDEF\0"
	.text
	.p2align 4
	.def	dhex;	.scl	3;	.type	32;	.endef
dhex:
	pushq	%rbx
	movl	%edx, %eax
	leaq	.LC2(%rip), %rbx
	movl	%edx, %r11d
	shrl	$4, %eax
	subq	$16, %rsp
	movzbl	(%rbx,%rax), %r8d
	leaq	32778(%rcx), %rax
	addq	$32937, %rcx
	movb	$0, 15(%rsp)
	movq	%rax, %rdx
	movb	%r8b, 14(%rsp)
	jmp	.L1061
	.p2align 4,,10
	.p2align 3
.L1063:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.L1062
.L1061:
	cmpb	$0, (%rdx)
	jne	.L1063
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.L1064
	jmp	.L1062
	.p2align 4,,10
	.p2align 3
.L1066:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.L1062
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.L1064:
	testb	%r8b, %r8b
	jne	.L1066
.L1062:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.L1068
	.p2align 4,,10
	.p2align 3
.L1070:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.L1069
.L1068:
	cmpb	$0, (%rax)
	jne	.L1070
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.L1071
	jmp	.L1069
	.p2align 4,,10
	.p2align 3
.L1072:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.L1069
.L1071:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.L1072
.L1069:
	movb	$0, (%rax)
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
.LC3:
	.ascii "CON\0"
.LC4:
	.ascii "PRN\0"
.LC5:
	.ascii "AUX\0"
.LC6:
	.ascii "NUL\0"
.LC7:
	.ascii "CONIN$\0"
.LC8:
	.ascii "CONOUT$\0"
.LC9:
	.ascii "CLOCK$\0"
.LC10:
	.ascii "COM\0"
.LC11:
	.ascii "LPT\0"
	.text
	.p2align 4
	.def	hrdbfw_path.part.0;	.scl	3;	.type	32;	.endef
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
	je	.L1150
	js	.L1084
	movabsq	$-4611681598906040321, %r8
	xorl	%ebx, %ebx
	jmp	.L1083
	.p2align 4,,10
	.p2align 3
.L1152:
	movl	%eax, %edx
	andl	$-65, %edx
	cmpb	$60, %dl
	je	.L1084
.L1088:
	movw	%ax, (%r15,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.L1151
	testb	%al, %al
	js	.L1084
	cmpq	$258, %rbx
	ja	.L1084
.L1083:
	cmpb	$63, %al
	ja	.L1152
	btq	%rax, %r8
	jc	.L1084
	cmpb	$60, %al
	je	.L1084
	cmpb	$58, %al
	jne	.L1087
	cmpq	$1, %rbx
	jne	.L1084
	movzbl	(%rcx), %eax
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	ja	.L1084
	movl	$58, %eax
	jmp	.L1088
	.p2align 4,,10
	.p2align 3
.L1087:
	cmpb	$47, %al
	jne	.L1088
	movl	$92, %eax
	jmp	.L1088
	.p2align 4,,10
	.p2align 3
.L1158:
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
	cmpw	$46, %r13w
	je	.L1094
	.p2align 4,,10
	.p2align 3
.L1084:
	xorl	%eax, %eax
.L1080:
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
.L1151:
	xorl	%eax, %eax
	xorl	%r14d, %r14d
	leaq	.LC3(%rip), %rdi
	movw	%ax, (%r15,%rbx,2)
	leaq	.LC4(%rip), %rbp
	xorl	%eax, %eax
	jmp	.L1109
	.p2align 4,,10
	.p2align 3
.L1154:
	addq	$1, %r14
.L1091:
	cmpq	%r14, %rbx
	jb	.L1153
.L1109:
	cmpq	%r14, %rbx
	je	.L1090
	cmpw	$92, (%r15,%r14,2)
	jne	.L1154
.L1090:
	movq	%r14, %rsi
	subq	%rax, %rsi
	je	.L1092
	movzwl	-2(%r15,%r14,2), %edx
	cmpw	$32, %dx
	je	.L1093
	cmpw	$46, %dx
	je	.L1093
	leaq	(%r15,%rax,2), %r12
	movzwl	(%r12), %r13d
.L1094:
	movl	%r13d, %edx
	xorl	%eax, %eax
	jmp	.L1096
	.p2align 4,,10
	.p2align 3
.L1097:
	movzwl	(%r12,%rax,2), %edx
.L1096:
	cmpw	$46, %dx
	je	.L1155
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.L1097
	cmpw	$32, -2(%r12,%rsi,2)
	jne	.L1099
	.p2align 4,,10
	.p2align 3
.L1103:
	subq	$1, %rsi
	je	.L1099
.L1102:
	cmpw	$32, -2(%r12,%rsi,2)
	je	.L1103
.L1099:
	movq	%rdi, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	movq	%rbp, %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	leaq	.LC5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	leaq	.LC6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	leaq	.LC7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	leaq	.LC8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	leaq	.LC9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r12, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1084
	cmpq	$4, %rsi
	jne	.L1092
	movzwl	6(%r12), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.L1092
	movzwl	%r13w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.L1106
.L1156:
	leaq	.LC10(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.L1114
	movzwl	(%r12,%rcx,2), %eax
.L1106:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.L1114
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.L1156
	jmp	.L1084
.L1114:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.L1108
.L1157:
	movzwl	(%r12,%rdx,2), %r13d
.L1108:
	movzwl	%r13w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.L1092
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.L1084
	leaq	.LC11(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.L1157
	.p2align 4,,10
	.p2align 3
.L1092:
	leaq	1(%r14), %rax
	movq	%rax, %r14
	jmp	.L1091
	.p2align 4,,10
	.p2align 3
.L1093:
	cmpq	$1, %rsi
	je	.L1158
	cmpq	$2, %rsi
	jne	.L1084
	addq	%rax, %rax
	leaq	(%r15,%rax), %r12
	cmpw	$46, (%r12)
	jne	.L1084
	movzwl	2(%r15,%rax), %r13d
	cmpw	$46, %r13w
	je	.L1094
	jmp	.L1084
	.p2align 4,,10
	.p2align 3
.L1155:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.L1102
	jmp	.L1099
.L1153:
	cmpw	$92, (%r15)
	je	.L1084
	movl	$1, %eax
	cmpq	$1, %rbx
	je	.L1080
	cmpw	$58, 2(%r15)
	jne	.L1080
	cmpq	$2, %rbx
	je	.L1084
	cmpw	$92, 4(%r15)
	jne	.L1084
	jmp	.L1080
.L1150:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movw	%dx, (%r15)
	jmp	.L1080
	.p2align 4
	.def	hrntx_file_flush.part.0.constprop.0;	.scl	3;	.type	32;	.endef
hrntx_file_flush.part.0.constprop.0:
	movzbl	hrdbf_app_ntxpath(%rip), %eax
	testb	%al, %al
	je	.L1200
	cmpb	$92, %al
	je	.L1204
	cmpb	$47, %al
	jne	.L1164
	cmpb	$47, 1+hrdbf_app_ntxpath(%rip)
	je	.L1200
.L1164:
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
	je	.L1202
	movq	64+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L1167
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
.L1167:
	movq	%r12, %rcx
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	movl	$1073741824, %edx
	movq	$0, 48(%rsp)
	movl	$128, 40(%rsp)
	movl	$3, 32(%rsp)
	call	*__imp_CreateFileW(%rip)
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.L1202
	xorl	%r9d, %r9d
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	movq	%rax, %rcx
	call	*__imp_SetFilePointerEx(%rip)
	testl	%eax, %eax
	je	.L1171
	movq	__imp_SetEndOfFile(%rip), %rdi
	movq	%r12, %rcx
	call	*%rdi
	testl	%eax, %eax
	je	.L1171
	movq	48+hrdbf_app_order(%rip), %r8
	movq	__imp_WriteFile(%rip), %rsi
	xorl	%ebx, %ebx
	leaq	76(%rsp), %rbp
	testq	%r8, %r8
	jne	.L1169
	jmp	.L1170
	.p2align 4,,10
	.p2align 3
.L1205:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.L1171
	movq	48+hrdbf_app_order(%rip), %r8
	addq	%rax, %rbx
	cmpq	%rbx, %r8
	jbe	.L1170
.L1169:
	movq	32+hrdbf_app_order(%rip), %rdx
	subl	%ebx, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	addq	%rbx, %rdx
	call	*%rsi
	testl	%eax, %eax
	jne	.L1205
.L1171:
	movq	%r12, %rcx
.L1203:
	call	*__imp_CloseHandle(%rip)
.L1202:
	movl	$7, %eax
.L1159:
	addq	$608, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1204:
	cmpb	$92, 1+hrdbf_app_ntxpath(%rip)
	jne	.L1164
.L1200:
	movl	$7, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1170:
	movq	%r12, %rcx
	call	*%rdi
	movq	%r12, %rcx
	testl	%eax, %eax
	je	.L1203
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L1202
	movl	$0, 72+hrdbf_app_order(%rip)
	xorl	%eax, %eax
	jmp	.L1159
	.section .rdata,"dr"
	.align 8
.LC12:
	.ascii "path is not a supported plain file path (reserved device name or characters)\0"
	.align 8
.LC13:
	.ascii "OS open failed (2=missing, 5=access denied, 32=another program has it open)\0"
.LC14:
	.ascii "GetFileSizeEx failed\0"
	.align 8
.LC15:
	.ascii "file has fewer than the 33 header bytes\0"
.LC16:
	.ascii "file size \0"
.LC17:
	.ascii " exceeds the 1 GiB limit\0"
	.align 8
.LC18:
	.ascii "file size is not a whole number of pages\0"
	.align 8
.LC19:
	.ascii "out of memory snapshotting the file\0"
.LC20:
	.ascii "OS read failed\0"
	.align 8
.LC21:
	.ascii "file changed size while being read\0"
	.text
	.p2align 4
	.def	hrdbfw_snapshot;	.scl	3;	.type	32;	.endef
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
	je	.L1210
	movq	%rdx, %rsi
	movq	%r8, %rbx
	movq	%r9, %rdi
	cmpb	$92, %al
	je	.L1254
	cmpb	$47, %al
	jne	.L1211
	cmpb	$47, 1(%rcx)
	je	.L1210
.L1211:
	leaq	96(%rsp), %r12
	movq	%r12, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.L1210
	cmpl	$2, %ebp
	je	.L1231
	xorl	%r8d, %r8d
	movl	$-1073741824, %edx
	cmpl	$1, %ebp
	movl	$-2147483648, %eax
	cmovne	%eax, %edx
.L1214:
	movq	%r12, %rcx
	movl	$128, 40(%rsp)
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$3, 32(%rsp)
	call	*__imp_CreateFileW(%rip)
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.L1255
	movq	%rax, (%rdi)
	movq	__imp_GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%rax, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.L1256
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.L1257
	cmpq	$1073741824, %r10
	jg	.L1258
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.L1219
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.L1259
.L1219:
	movq	%r10, %rdx
	movq	%r10, (%rbx)
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, (%rsi)
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.L1220
	movq	(%rbx), %r8
	movq	__imp_ReadFile(%rip), %rdi
	xorl	%r15d, %r15d
	leaq	76(%rsp), %rbp
	movq	__imp_GetLastError(%rip), %r13
	testq	%r8, %r8
	jne	.L1221
	jmp	.L1222
	.p2align 4,,10
	.p2align 3
.L1226:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.L1253
	movq	(%rbx), %r8
	movl	%eax, %edx
	movq	%r8, %rax
	subq	%r15, %rax
	cmpq	%rax, %rdx
	ja	.L1260
	addq	%rdx, %r15
	cmpq	%r15, %r8
	jbe	.L1222
	movq	(%rsi), %rdx
.L1221:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rbp, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rdi
	testl	%eax, %eax
	jne	.L1226
	call	*%r13
	testl	%eax, %eax
	je	.L1226
	.p2align 4,,10
	.p2align 3
.L1253:
	movl	%eax, %edx
	leaq	.LC20(%rip), %rcx
	movl	$7, %r13d
	call	werr
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1254:
	cmpb	$92, 1(%rcx)
	jne	.L1211
	.p2align 4,,10
	.p2align 3
.L1210:
	leaq	.LC12(%rip), %rcx
	movl	$7, %r13d
	call	fset
.L1206:
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
.L1231:
	movl	$3, %r8d
	movl	$-2147483648, %edx
	jmp	.L1214
	.p2align 4,,10
	.p2align 3
.L1257:
	leaq	.LC15(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1222:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rbp, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rdi
	testl	%eax, %eax
	je	.L1261
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.L1230
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.L1230
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.L1206
.L1230:
	leaq	.LC21(%rip), %rcx
	movl	$7, %r13d
	call	fset
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1258:
	leaq	.LC16(%rip), %rcx
	movl	$1, %r13d
	call	fset
	movq	80(%rsp), %rcx
	call	fdec
	leaq	.LC17(%rip), %rcx
	call	fcat
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1260:
	xorl	%eax, %eax
	jmp	.L1253
	.p2align 4,,10
	.p2align 3
.L1256:
	call	*__imp_GetLastError(%rip)
	leaq	.LC14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1255:
	call	*__imp_GetLastError(%rip)
	leaq	.LC13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1206
	.p2align 4,,10
	.p2align 3
.L1259:
	leaq	.LC18(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1206
.L1220:
	leaq	.LC19(%rip), %rcx
	movl	$8, %r13d
	call	fset
	jmp	.L1206
.L1261:
	call	*__imp_GetLastError(%rip)
	jmp	.L1253
	.p2align 4
	.def	hrntx_file_open.part.0.constprop.0;	.scl	3;	.type	32;	.endef
hrntx_file_open.part.0.constprop.0:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	movl	%edx, %ebx
	subq	$72, %rsp
	testl	%edx, %edx
	je	.L1284
	leaq	64+hrdbf_app_order(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L1265
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rdi
.L1268:
	movl	$4, %r12d
	cmpq	$67108864, %rdi
	ja	.L1265
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
	movq	%rdx, 56+hrdbf_app_order(%rip)
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, 40+hrdbf_app_order(%rip)
	testq	%rax, %rax
	je	.L1272
	testl	%ebx, %ebx
	leaq	hrntx_open(%rip), %rdx
	leaq	hrcdx_open(%rip), %r10
	movq	%rax, 32(%rsp)
	cmove	%rdx, %r10
	addq	%r12, %rsi
	addq	%rax, %rdi
	movq	48+hrdbf_app_order(%rip), %r8
	movq	%rsi, 56(%rsp)
	movl	16+hrdbf_app_state(%rip), %esi
	leaq	hrdbf_app_state(%rip), %r9
	leaq	hrdbf_app_order(%rip), %rcx
	movq	%rdi, 48(%rsp)
	movq	32+hrdbf_app_order(%rip), %rdx
	movq	%rsi, 40(%rsp)
	call	*%r10
	movl	%eax, %r12d
	testl	%eax, %eax
	je	.L1262
	cmpl	$5, %eax
	sete	%r12b
	movzbl	%r12b, %r12d
	leal	1(%r12,%r12), %r12d
	.p2align 4,,10
	.p2align 3
.L1265:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmovne	%eax, %r12d
.L1262:
	addq	$72, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1284:
	leaq	64+hrdbf_app_order(%rip), %r9
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L1265
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rdi
	jmp	.L1268
	.p2align 4,,10
	.p2align 3
.L1272:
	movl	$8, %r12d
	jmp	.L1265
	.p2align 4
	.globl	hrdbf_close
	.def	hrdbf_close;	.scl	2;	.type	32;	.endef
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
	.def	hrdbf_top;	.scl	2;	.type	32;	.endef
hrdbf_top:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1286
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.L1286:
	ret
	.p2align 4
	.globl	hrdbf_skip
	.def	hrdbf_skip;	.scl	2;	.type	32;	.endef
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1289
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.L1289
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.L1291
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
.L1293:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.L1303
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1289:
	ret
	.p2align 4,,10
	.p2align 3
.L1291:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.L1294
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L1303:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1294:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.L1293
	.p2align 4
	.globl	hrdbf_get
	.def	hrdbf_get;	.scl	2;	.type	32;	.endef
hrdbf_get:
	movl	$85, %eax
	movb	$0, 28(%r8)
	movw	%ax, (%r8)
	movb	$0, 2(%r8)
	movq	$0, 8(%r8)
	movq	$0, 16(%r8)
	movl	$0, 24(%r8)
	cmpb	$0, 40(%rcx)
	je	.L1306
	testl	%edx, %edx
	je	.L1308
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.L1308
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.L1308:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1306:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
	.def	hrdbf_deleted;	.scl	2;	.type	32;	.endef
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1309
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.L1311
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.L1311:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.L1309:
	ret
	.section .rdata,"dr"
	.align 8
.LC22:
	.ascii "' content is not valid for its type\0"
	.align 8
.LC23:
	.ascii "' numeric content overflows int64\0"
.LC24:
	.ascii "version byte 0x\0"
	.align 8
.LC25:
	.ascii " is not 0x03 (dBASE III table without memo; 0x83/0xF5 carry a memo file)\0"
.LC26:
	.ascii "implausible header length \0"
.LC27:
	.ascii " or record length \0"
.LC28:
	.ascii " for file size \0"
.LC29:
	.ascii "field descriptor \0"
	.align 8
.LC30:
	.ascii " truncated before end of header\0"
	.align 8
.LC31:
	.ascii "more than 2046 field descriptors\0"
.LC32:
	.ascii " has an empty name\0"
.LC33:
	.ascii "field '\0"
.LC34:
	.ascii "' has zero width\0"
.LC35:
	.ascii "C field '\0"
.LC36:
	.ascii "' declares decimals\0"
.LC37:
	.ascii "N field '\0"
.LC38:
	.ascii "' width \0"
.LC39:
	.ascii " / decimals \0"
.LC40:
	.ascii " outside supported range\0"
.LC41:
	.ascii "L field '\0"
	.align 8
.LC42:
	.ascii "' width must be 1 with no decimals\0"
.LC43:
	.ascii "D field '\0"
	.align 8
.LC44:
	.ascii "' width must be 8 with no decimals\0"
.LC45:
	.ascii "' has unsupported type '\0"
.LC46:
	.ascii "' (only C/N/D/L, no memo)\0"
	.align 8
.LC47:
	.ascii "field widths exceed the 65535 record limit\0"
	.align 8
.LC48:
	.ascii "field descriptors not terminated by 0x0D\0"
.LC49:
	.ascii "table declares no fields\0"
	.align 8
.LC50:
	.ascii "field widths plus delete flag sum to \0"
.LC51:
	.ascii " but header record length is \0"
	.align 8
.LC52:
	.ascii "nonzero byte between field descriptors and header end\0"
.LC53:
	.ascii "header record count \0"
.LC54:
	.ascii " exceeds the \0"
.LC55:
	.ascii " records physically present\0"
	.align 8
.LC56:
	.ascii "unexpected trailing bytes after the last record (no 0x1A terminator)\0"
.LC57:
	.ascii "record \0"
.LC58:
	.ascii " has delete flag 0x\0"
.LC59:
	.ascii " (expected space or '*')\0"
.LC60:
	.ascii " field '\0"
	.align 8
.LC61:
	.ascii " (logical byte must be T/F/Y/N/?/space)\0"
.LC62:
	.ascii " inside a deleted record\0"
.LC63:
	.ascii "duplicate field name '\0"
.LC64:
	.ascii "'\0"
	.text
	.p2align 4
	.globl	hrdbf_open
	.def	hrdbf_open;	.scl	2;	.type	32;	.endef
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
	movb	$0, 32778+hrdbf_open_tmp(%rip)
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movq	$0, hrdbf_open_tmp(%rip)
	movq	$0, 8+hrdbf_open_tmp(%rip)
	movl	$0, 16+hrdbf_open_tmp(%rip)
	movq	$0, 24+hrdbf_open_tmp(%rip)
	movl	$16842752, 36+hrdbf_open_tmp(%rip)
	movb	$0, 40+hrdbf_open_tmp(%rip)
	cmpq	$32, %r8
	jbe	.L1392
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.L1393
	movzwl	8(%rdx), %eax
	movq	%r8, %r13
	movw	%ax, 32+hrdbf_open_tmp(%rip)
	movzwl	10(%rdx), %edi
	movw	%di, 34+hrdbf_open_tmp(%rip)
	movl	4(%rdx), %ebp
	movl	%edi, 56(%rsp)
	movl	%ebp, 16+hrdbf_open_tmp(%rip)
	cmpw	$32, %ax
	jbe	.L1318
	movq	%rax, 40(%rsp)
	testl	%edi, %edi
	je	.L1318
	cmpq	%r8, %rax
	ja	.L1318
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
.L1342:
	cmpb	$13, (%rsi)
	je	.L1394
	cmpq	48(%rsp), %r13
	je	.L1395
	movzwl	36+hrdbf_open_tmp(%rip), %eax
	cmpw	$2046, %ax
	je	.L1396
	leal	1(%rax), %ecx
	movq	%rax, %r10
	movq	%rax, 32(%rsp)
	movzwl	%ax, %r15d
	movw	%cx, 36+hrdbf_open_tmp(%rip)
	salq	$4, %r10
	xorl	%eax, %eax
	leaq	(%rdi,%r10), %r8
	.p2align 4,,10
	.p2align 3
.L1326:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, 42(%r8,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1326
	movq	%r15, %rax
	salq	$4, %rax
	movzbl	42(%rax,%rdi), %ebp
	testb	%bpl, %bpl
	je	.L1327
	movzwl	%cx, %eax
	cmpw	$1, %cx
	jbe	.L1328
	movq	32(%rsp), %r9
	leal	-1(%rax), %r11d
	leaq	43(%rdi,%r10), %r14
	xorl	%r8d, %r8d
	leaq	53+hrdbf_open_tmp(%rip), %rax
	salq	$4, %r11
	negq	%r9
	addq	%rax, %r10
	salq	$4, %r9
	.p2align 4,,10
	.p2align 3
.L1329:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.L1332
	.p2align 4,,10
	.p2align 3
.L1398:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1332:
	leaq	(%rax,%r9), %rcx
	cmpb	%dl, -1(%rcx,%r8)
	jne	.L1397
	cmpq	%rax, %r10
	jne	.L1398
	leaq	.LC63(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC64(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
	.p2align 4,,10
	.p2align 3
.L1318:
	leaq	.LC26(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movzwl	32+hrdbf_open_tmp(%rip), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC27(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	34+hrdbf_open_tmp(%rip), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC28(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	movl	$1, %eax
.L1314:
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
.L1397:
	addq	$16, %r8
	cmpq	%r8, %r11
	jne	.L1329
.L1328:
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
	je	.L1399
	cmpb	$67, %cl
	je	.L1400
	cmpb	$78, %cl
	je	.L1401
	cmpb	$76, %cl
	je	.L1402
	cmpb	$68, %cl
	jne	.L1339
	cmpw	$8, 22(%rax)
	je	.L1335
	leaq	.LC43(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC44(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
	.p2align 4,,10
	.p2align 3
.L1392:
	leaq	.LC15(%rip), %rdx
	call	dset
	movl	$1, %eax
	jmp	.L1314
.L1393:
	leaq	.LC24(%rip), %rdx
	call	dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	dhex
	leaq	.LC25(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$2, %eax
	jmp	.L1314
.L1400:
	testb	%r8b, %r8b
	jne	.L1403
.L1335:
	addl	%edx, %ebx
	cmpl	$65535, %ebx
	ja	.L1404
	addq	$32, %r13
	addq	$32, %rsi
	cmpq	%r13, 40(%rsp)
	ja	.L1342
	leaq	.LC48(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1314
.L1401:
	cmpb	$17, %r8b
	ja	.L1366
	cmpb	%r8b, %dl
	ja	.L1335
.L1366:
	leaq	.LC37(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC38(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movq	%r15, %rax
	movq	%r12, %rcx
	addq	$2, %rax
	salq	$4, %rax
	addq	%rax, %rdi
	movzbl	22(%rdi), %edx
	call	ddec
	leaq	.LC39(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzbl	23(%rdi), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC40(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$4, %eax
	jmp	.L1314
	.p2align 4,,10
	.p2align 3
.L1402:
	cmpw	$1, 22(%rax)
	je	.L1335
	leaq	.LC41(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC42(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
	.p2align 4,,10
	.p2align 3
.L1395:
	leaq	.LC29(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movzwl	36+hrdbf_open_tmp(%rip), %eax
	movq	%r12, %rcx
	leaq	1(%rax), %rdx
	call	ddec
	leaq	.LC30(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
.L1396:
	leaq	.LC31(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$4, %eax
	jmp	.L1314
.L1394:
	cmpw	$0, 36+hrdbf_open_tmp(%rip)
	movl	%ebx, %esi
	movq	%r13, %rax
	movl	60(%rsp), %ebp
	movq	184(%rsp), %rbx
	movq	192(%rsp), %r13
	je	.L1405
	addq	$1, %rax
	cmpl	%esi, 56(%rsp)
	je	.L1344
	jmp	.L1406
	.p2align 4,,10
	.p2align 3
.L1345:
	addq	$1, %rax
	cmpb	$0, -1(%rbx,%rax)
	jne	.L1407
.L1344:
	cmpq	%rax, 40(%rsp)
	ja	.L1345
	movl	%esi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	40(%rsp), %rax
	divq	%rcx
	movl	%ebp, %r8d
	cmpq	%rax, %r8
	ja	.L1408
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	40(%rsp), %rax
	cmpq	%rax, %r13
	je	.L1347
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1348
	cmpb	$26, (%rbx,%rax)
	je	.L1347
.L1348:
	leaq	.LC56(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1314
.L1327:
	leaq	.LC29(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movzwl	36+hrdbf_open_tmp(%rip), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC32(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
.L1399:
	leaq	.LC33(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC34(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
.L1407:
	leaq	.LC52(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1314
.L1404:
	leaq	.LC47(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$4, %eax
	jmp	.L1314
.L1403:
	leaq	.LC35(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC36(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$3, %eax
	jmp	.L1314
.L1406:
	leaq	.LC50(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	%esi, %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC51(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	34+hrdbf_open_tmp(%rip), %edx
	movq	%r12, %rcx
	call	ddec
	movl	$1, %eax
	jmp	.L1314
.L1405:
	leaq	.LC49(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1314
.L1339:
	leaq	.LC33(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	32(%rsp), %rax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	42(%rdi,%rax), %rdx
	call	dname
	leaq	.LC45(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzbl	(%r14), %eax
	movq	%r12, %rcx
	movb	$0, 65(%rsp)
	leal	-32(%rax), %edx
	cmpb	$95, %dl
	movl	$63, %edx
	cmovnb	%edx, %eax
	leaq	64(%rsp), %rdx
	movb	%al, 64(%rsp)
	call	dcat
	leaq	.LC46(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$3, %eax
	jmp	.L1314
.L1347:
	testl	%ebp, %ebp
	movq	%rbx, hrdbf_open_tmp(%rip)
	sete	%al
	movq	%r13, 8+hrdbf_open_tmp(%rip)
	movb	$1, 40+hrdbf_open_tmp(%rip)
	movq	$1, 24+hrdbf_open_tmp(%rip)
	movb	%al, 39+hrdbf_open_tmp(%rip)
	movb	%al, 38+hrdbf_open_tmp(%rip)
	testq	%r8, %r8
	je	.L1363
	xorl	%r13d, %r13d
	leaq	hrdbf_open_tmp(%rip), %rbp
	leaq	64(%rsp), %r8
.L1352:
	movzwl	34+hrdbf_open_tmp(%rip), %eax
	movzwl	32+hrdbf_open_tmp(%rip), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.L1350
	cmpb	$42, %dil
	jne	.L1409
.L1350:
	cmpw	$0, 36+hrdbf_open_tmp(%rip)
	movq	%r13, 24+hrdbf_open_tmp(%rip)
	movl	$1, %esi
	movq	%rbp, %r14
	jne	.L1351
	jmp	.L1358
	.p2align 4,,10
	.p2align 3
.L1354:
	movl	%esi, %edx
	movq	%rbp, %rcx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1410
	movzwl	36+hrdbf_open_tmp(%rip), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.L1358
.L1351:
	movl	$85, %eax
	cmpb	$0, 40+hrdbf_open_tmp(%rip)
	movb	$0, 92(%rsp)
	movw	%ax, 64(%rsp)
	movb	$0, 66(%rsp)
	movq	$0, 72(%rsp)
	movq	$0, 80(%rsp)
	movl	$0, 88(%rsp)
	jne	.L1354
	leaq	.LC57(%rip), %rdx
	movq	%r12, %rcx
	leal	-1(%rsi), %ebx
	call	dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC60(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	leal	1(%rsi), %eax
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	10(%rbp,%rax), %rdx
	call	dname
	movl	$6, %eax
	leaq	.LC22(%rip), %rdx
.L1355:
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	dcat
	movl	%ebx, %edx
	movl	32(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 53(%rdx,%rbp)
	je	.L1411
.L1357:
	cmpb	$42, %dil
	jne	.L1314
	leaq	.LC62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	call	dcat
	movl	32(%rsp), %eax
	jmp	.L1314
.L1358:
	movl	16+hrdbf_open_tmp(%rip), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.L1352
	cmpb	$0, 40+hrdbf_open_tmp(%rip)
	je	.L1359
.L1349:
	movq	$1, 24+hrdbf_open_tmp(%rip)
	testl	%eax, %eax
	sete	%dl
	movb	%dl, 39+hrdbf_open_tmp(%rip)
	movb	%dl, 38+hrdbf_open_tmp(%rip)
.L1359:
	movl	%eax, 16(%r12)
	movq	24+hrdbf_open_tmp(%rip), %rax
	xorl	%r8d, %r8d
	movq	hrdbf_open_tmp(%rip), %rdx
	movq	%rax, 24(%r12)
	movzwl	32+hrdbf_open_tmp(%rip), %eax
	movq	%rdx, (%r12)
	movq	8+hrdbf_open_tmp(%rip), %rdx
	movw	%ax, 32(%r12)
	movzwl	34+hrdbf_open_tmp(%rip), %eax
	movq	%rdx, 8(%r12)
	leaq	hrdbf_open_tmp(%rip), %rdx
	movw	%ax, 34(%r12)
	movzwl	36+hrdbf_open_tmp(%rip), %eax
	movw	%ax, 36(%r12)
	movzbl	38+hrdbf_open_tmp(%rip), %eax
	movzwl	36+hrdbf_open_tmp(%rip), %r9d
	movb	%al, 38(%r12)
	movzbl	39+hrdbf_open_tmp(%rip), %eax
	movb	%al, 39(%r12)
	movl	$53, %eax
.L1360:
	cmpl	%r8d, %r9d
	jbe	.L1412
	leaq	-11(%rax), %rcx
.L1361:
	movzbl	(%r14,%rcx), %r10d
	movb	%r10b, (%r12,%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.L1361
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
	jmp	.L1360
.L1411:
	leaq	.LC61(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	32(%rsp), %eax
	jmp	.L1357
.L1412:
	movb	$0, 32778(%r12)
	xorl	%eax, %eax
	movb	$1, 40(%r12)
	jmp	.L1314
.L1408:
	leaq	.LC53(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	16+hrdbf_open_tmp(%rip), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC54(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	32+hrdbf_open_tmp(%rip), %edx
	movzwl	34+hrdbf_open_tmp(%rip), %ecx
	movq	%r13, %rax
	subq	%rdx, %rax
	xorl	%edx, %edx
	divq	%rcx
	movq	%r12, %rcx
	movq	%rax, %rdx
	call	ddec
	leaq	.LC55(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1314
.L1409:
	leaq	.LC57(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC58(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzbl	%dil, %edx
	movq	%r12, %rcx
	call	dhex
	leaq	.LC59(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$5, %eax
	jmp	.L1314
.L1363:
	xorl	%eax, %eax
	leaq	hrdbf_open_tmp(%rip), %r14
	jmp	.L1349
.L1410:
	leaq	.LC57(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 32(%rsp)
	leal	-1(%rsi), %ebx
	call	dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC60(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	leal	1(%rsi), %edx
	movq	%r12, %rcx
	salq	$4, %rdx
	leaq	10(%rbp,%rdx), %rdx
	call	dname
	movl	32(%rsp), %eax
	leaq	.LC22(%rip), %rdx
	leaq	.LC23(%rip), %rcx
	cmpl	$4, %eax
	cmove	%rcx, %rdx
	jmp	.L1355
	.p2align 4
	.globl	hrv_date
	.def	hrv_date;	.scl	2;	.type	32;	.endef
hrv_date:
	movl	%edx, %edx
	movq	$11, (%rcx)
	movq	%rcx, %rax
	movq	%rdx, 8(%rcx)
	ret
	.p2align 4
	.globl	hrv_number
	.def	hrv_number;	.scl	2;	.type	32;	.endef
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
	.def	hrv_validate;	.scl	2;	.type	32;	.endef
hrv_validate:
	pushq	%rbp
	movq	(%rcx), %rax
	movl	$4, %r8d
	movq	8(%rcx), %rcx
	movzbl	%al, %edx
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %edx
	ja	.L1415
	je	.L1446
	cmpl	$5, %edx
	je	.L1419
	shrq	$8, %rax
	jne	.L1415
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.L1415
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.L1415
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.L1415
	movq	%rcx, %rax
	movl	$4, %r8d
	movabsq	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.L1415
	movabsq	$2951479051793528259, %r10
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
	ja	.L1433
	testq	%rcx, %rcx
	je	.L1433
	leaq	days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1447
.L1421:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.L1415:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1446:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.L1415
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.L1415
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.L1433
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.L1433
	cmpl	%edx, %eax
	jb	.L1415
.L1433:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1419:
	testq	%rax, %rax
	jns	.L1428
	movabsq	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.L1415
.L1428:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1447:
	testb	$3, %r9b
	jne	.L1421
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1422
	addl	$1, %eax
	jmp	.L1421
.L1422:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.L1421
	.p2align 4
	.globl	hrv_valtype
	.def	hrv_valtype;	.scl	2;	.type	32;	.endef
hrv_valtype:
	pushq	%rbp
	movzbl	(%rcx), %eax
	movl	$63, %r8d
	movq	%rsp, %rbp
	andq	$-16, %rsp
	cmpl	$12, %eax
	ja	.L1448
	leaq	CSWTCH.413(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.L1448:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4
	.globl	hrv_i64
	.def	hrv_i64;	.scl	2;	.type	32;	.endef
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
	jne	.L1453
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.L1464
	testl	%edx, %edx
	je	.L1456
	cmpl	$9, %edx
	je	.L1456
	movl	$1, %eax
.L1453:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1464:
	testl	$65280, %r11d
	jne	.L1465
.L1456:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1465:
	movl	$2, %eax
	jmp	.L1453
	.p2align 4
	.globl	hrv_equal
	.def	hrv_equal;	.scl	2;	.type	32;	.endef
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
	jne	.L1466
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1466
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.L1468
	cmpl	$11, %r14d
	jne	.L1468
.L1479:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.L1466:
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
.L1468:
	cmpl	$1, %r15d
	je	.L1482
	cmpl	$1, %r14d
	je	.L1482
	cmpl	$3, %r15d
	jne	.L1471
	cmpl	$3, %r14d
	jne	.L1471
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1466
	.p2align 4,,10
	.p2align 3
.L1482:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1466
	.p2align 4,,10
	.p2align 3
.L1471:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1475
	cmpl	$12, %r15d
	je	.L1505
	testl	%r15d, %r15d
	je	.L1474
	cmpl	$9, %r15d
	jne	.L1475
.L1474:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1475
	cmpl	$12, %r14d
	je	.L1506
	testl	%r14d, %r14d
	je	.L1479
	cmpl	$9, %r14d
	je	.L1479
	.p2align 4,,10
	.p2align 3
.L1475:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1507
.L1481:
	movl	$1, %eax
	jmp	.L1466
	.p2align 4,,10
	.p2align 3
.L1505:
	testl	$65280, %r11d
	je	.L1474
	jmp	.L1475
	.p2align 4,,10
	.p2align 3
.L1507:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1481
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1466
	.p2align 4,,10
	.p2align 3
.L1506:
	testl	$65280, %edi
	je	.L1479
	jmp	.L1475
	.p2align 4
	.globl	hrv_compare
	.def	hrv_compare;	.scl	2;	.type	32;	.endef
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
	jne	.L1508
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.L1529
.L1508:
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
.L1529:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1510
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1530
	testl	%eax, %eax
	je	.L1512
	cmpl	$9, %eax
	je	.L1512
	.p2align 4,,10
	.p2align 3
.L1510:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1531
.L1518:
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
.L1531:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1518
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1519
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1519:
	movq	%rdx, (%rbx)
	jmp	.L1508
	.p2align 4,,10
	.p2align 3
.L1530:
	testl	$65280, %r11d
	jne	.L1510
.L1512:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1510
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.L1532
	testl	%edx, %edx
	je	.L1515
	cmpl	$9, %edx
	jne	.L1510
.L1515:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.L1508
	.p2align 4,,10
	.p2align 3
.L1532:
	testl	$65280, %esi
	je	.L1515
	jmp	.L1510
	.p2align 4
	.globl	hrv_empty
	.def	hrv_empty;	.scl	2;	.type	32;	.endef
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
	jne	.L1533
	movzbl	%r11b, %ecx
	cmpb	$12, %r11b
	ja	.L1537
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.L1535
	andl	$2, %edx
	jne	.L1539
.L1537:
	movl	$1, %eax
.L1533:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1535:
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
.L1539:
	movl	$1, (%rsi)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4
	.globl	hrv_render
	.def	hrv_render;	.scl	2;	.type	32;	.endef
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
	jne	.L1540
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.L1587
	cmpl	$12, %eax
	jne	.L1566
	movl	%ebx, %eax
	negq	%rcx
	movzbl	%bh, %ebx
	movl	$1, %r10d
	shrl	$16, %eax
	testq	%r13, %r13
	leaq	63(%rsp), %r14
	movabsq	$-3689348814741910323, %r9
	movl	%eax, 44(%rsp)
	cmovns	%r13, %rcx
	.p2align 4,,10
	.p2align 3
.L1548:
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
	ja	.L1548
	cmpl	%ebx, %r8d
	ja	.L1588
	movl	$1, %r9d
.L1549:
	leal	1(%r9,%rbx), %eax
.L1550:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.L1551
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.L1589
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.L1559
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1558:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L1558
.L1559:
	testq	%r13, %r13
	jns	.L1557
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.L1557:
	testl	%r9d, %r9d
	je	.L1560
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.L1562
	.p2align 4,,10
	.p2align 3
.L1570:
	movl	%edx, %eax
.L1562:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1561
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1561:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.L1570
	addl	%r9d, %r10d
.L1560:
	testl	%ebx, %ebx
	je	.L1540
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.L1564:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1563
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1563:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.L1564
.L1540:
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
.L1587:
	cmpq	$7, %rsi
	jbe	.L1551
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.L1546
	movq	%r13, %rax
	movb	$47, 2(%r11)
	movabsq	$3777893186295716171, %rdx
	movabsq	$2951479051793528259, %r9
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
	jmp	.L1540
	.p2align 4,,10
	.p2align 3
.L1566:
	movl	$1, %r12d
	jmp	.L1540
	.p2align 4,,10
	.p2align 3
.L1590:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.L1565
.L1545:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.L1540
.L1546:
	cmpl	$2, %ecx
	jne	.L1590
.L1565:
	movl	$47, %eax
	jmp	.L1545
	.p2align 4,,10
	.p2align 3
.L1588:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.L1549
	movl	%r9d, %eax
	jmp	.L1550
	.p2align 4,,10
	.p2align 3
.L1551:
	movl	$3, %r12d
	jmp	.L1540
	.p2align 4,,10
	.p2align 3
.L1589:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.L1540
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1554:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.L1554
	jmp	.L1540
	.p2align 4
	.globl	hrv_arith
	.def	hrv_arith;	.scl	2;	.type	32;	.endef
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
	jne	.L1591
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1591
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.L1631
	cmpl	$42, %ebx
	je	.L1631
	cmpl	$47, %ebx
	je	.L1606
	cmpl	$37, %ebx
	je	.L1633
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.L1633
.L1591:
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
.L1631:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1606
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1653
	testl	%eax, %eax
	je	.L1597
	cmpl	$9, %eax
	je	.L1597
	.p2align 4,,10
	.p2align 3
.L1606:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1591
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1591
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.L1654
	testl	%r13d, %r13d
	je	.L1655
	cmpl	$42, %ebx
	je	.L1656
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1632
	jne	.L1632
	movl	$5, %r8d
	jmp	.L1591
	.p2align 4,,10
	.p2align 3
.L1653:
	testl	$65280, %r11d
	jne	.L1606
.L1597:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1606
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.L1657
	testl	%eax, %eax
	je	.L1600
	cmpl	$9, %eax
	jne	.L1606
.L1600:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.L1658
	testl	%r13d, %r13d
	je	.L1659
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1591
	.p2align 4,,10
	.p2align 3
.L1633:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1591
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1591
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1615
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1616
	jne	.L1616
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.L1591
	.p2align 4,,10
	.p2align 3
.L1657:
	testl	$65280, %edi
	je	.L1600
	jmp	.L1606
	.p2align 4,,10
	.p2align 3
.L1656:
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
.L1609:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1591
	.p2align 4,,10
	.p2align 3
.L1632:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1609
	.p2align 4,,10
	.p2align 3
.L1654:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.L1652:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1609
	.p2align 4,,10
	.p2align 3
.L1655:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1652
	.p2align 4,,10
	.p2align 3
.L1658:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1591
.L1615:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabsq	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.L1660
	testq	%r10, %r10
	jne	.L1625
.L1620:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1618
	testq	%r9, %r9
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1618:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1591
.L1659:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.L1591
.L1616:
	movsd	56(%rsp), %xmm1
	movsd	%xmm0, 80(%rsp)
	movsd	%xmm1, 72(%rsp)
/APP
 # 101 "runtime/hrvalue.c" 1
	fldl 80(%rsp)
	fldl 72(%rsp)
	1: fprem
	fnstsw %ax
	test $4,%ah
	jnz 1b
	fstpl 88(%rsp)
	fstp %st(0)
 # 0 "" 2
/NO_APP
	movq	88(%rsp), %rdx
	jmp	.L1618
.L1660:
	testq	%r10, %r10
	je	.L1620
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.L1621
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.L1628
	jne	.L1628
.L1621:
	movq	%r10, 72(%rsp)
	movsd	%xmm0, 80(%rsp)
/APP
 # 107 "runtime/hrvalue.c" 1
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
 # 0 "" 2
/NO_APP
	movabsq	$4841369599423283199, %rcx
	movq	88(%rsp), %rdx
	cmpq	%rcx, %rax
	ja	.L1618
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.L1618
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1618
.L1625:
	movq	%rcx, 72(%rsp)
	movsd	%xmm0, 80(%rsp)
/APP
 # 107 "runtime/hrvalue.c" 1
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
 # 0 "" 2
/NO_APP
	movq	88(%rsp), %rdx
	jmp	.L1618
.L1628:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1618
	.section .rdata,"dr"
.LC67:
	.ascii "DBF unknown value error\0"
	.align 8
.LC68:
	.ascii "DBF value output buffer too short\0"
	.align 8
.LC69:
	.ascii "DBF value type outside admitted operation\0"
.LC70:
	.ascii "ok\0"
	.align 8
.LC71:
	.ascii "DBF value tag or metadata invalid\0"
	.align 8
.LC72:
	.ascii "DBF decimal numeric cannot enter I64 operation\0"
	.align 8
.LC73:
	.ascii "DBF arithmetic division by zero\0"
	.text
	.p2align 4
	.globl	hrv_error_name
	.def	hrv_error_name;	.scl	2;	.type	32;	.endef
hrv_error_name:
	leaq	.LC68(%rip), %rax
	cmpl	$3, %ecx
	je	.L1661
	ja	.L1663
	leaq	.LC69(%rip), %rax
	cmpl	$1, %ecx
	je	.L1661
	leaq	.LC72(%rip), %rax
	cmpl	$2, %ecx
	jne	.L1674
.L1661:
	ret
	.p2align 4,,10
	.p2align 3
.L1674:
	testl	%ecx, %ecx
	leaq	.LC70(%rip), %rdx
	leaq	.LC67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1663:
	leaq	.LC71(%rip), %rax
	cmpl	$4, %ecx
	je	.L1661
	cmpl	$5, %ecx
	leaq	.LC73(%rip), %rdx
	leaq	.LC67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4
	.globl	hrdbf_fmt_fixed
	.def	hrdbf_fmt_fixed;	.scl	2;	.type	32;	.endef
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
	ja	.L1678
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.L1678
	movabsq	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.L1773
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.L1682:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.L1689
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.L1688:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1690:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.L1690
	testq	%rax, %rax
	je	.L1691
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.L1691:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.L1688
	testb	%r12b, %r12b
	je	.L1689
	movl	%r9d, 544(%rsp)
.L1689:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.L1694
	movq	%rbp, %rcx
	call	bn_shl
	movl	544(%rsp), %edi
.L1695:
	xorl	%r12d, %r12d
	jmp	.L1701
	.p2align 4,,10
	.p2align 3
.L1702:
	cmpq	$48, %r12
	je	.L1774
	movq	%rbp, %rcx
	call	bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.L1701:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.L1702
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.L1702
	testl	%r12d, %r12d
	jne	.L1775
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.L1707:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.L1710
	.p2align 4,,10
	.p2align 3
.L1776:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.L1710:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1776
	testl	%r13d, %r13d
	je	.L1711
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.L1713:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.L1712:
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
	jne	.L1712
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1777
	movq	%rax, %r12
	jmp	.L1713
	.p2align 4,,10
	.p2align 3
.L1678:
	xorl	%eax, %eax
.L1675:
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
.L1773:
	testq	%rax, %rax
	jne	.L1778
	cmpq	$0, 40(%rsp)
	jne	.L1779
	xorl	%edx, %edx
.L1683:
	testl	%ebx, %ebx
	je	.L1684
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.L1678
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1686:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.L1686
	addl	%ebx, %eax
	jmp	.L1675
.L1779:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.L1678
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.L1683
.L1694:
	negl	%edx
	movq	%rbp, %rcx
	call	bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.L1780
	cmpl	$2, %eax
	jne	.L1695
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.L1695
	testl	%edi, %edi
	je	.L1728
.L1698:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.L1700
	.p2align 4,,10
	.p2align 3
.L1781:
	movl	(%rcx), %edx
.L1700:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.L1781
	testq	%rax, %rax
	je	.L1695
	movl	%edi, %eax
	addl	$1, %edi
.L1697:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.L1695
	.p2align 4,,10
	.p2align 3
.L1777:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.L1711:
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
	ja	.L1678
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.L1716
	movb	$45, (%rsi)
	movl	$1, %edx
.L1716:
	cmpl	%edi, %ebx
	jnb	.L1717
	testl	%eax, %eax
	je	.L1733
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1719:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1719
.L1718:
	testl	%ebx, %ebx
	je	.L1675
.L1720:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.L1721
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1722:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.L1722
	addl	%ebx, %edx
.L1721:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.L1723:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1723
	jmp	.L1675
.L1774:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.L1705:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.L1708:
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
	ja	.L1708
	jmp	.L1707
.L1778:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.L1682
.L1684:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.L1678
	movb	$48, (%rsi,%rdx)
	jmp	.L1675
.L1717:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1720
.L1780:
	testl	%edi, %edi
	je	.L1727
	movl	256(%rsp), %edx
	jmp	.L1698
.L1733:
	movl	%edx, %eax
	jmp	.L1718
.L1728:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.L1697
.L1727:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.L1697
.L1775:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.L1705
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.def	hrdbf_fmt_harbour;	.scl	2;	.type	32;	.endef
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.L1783
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1783:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
	.def	hrdbf_write_char;	.scl	2;	.type	32;	.endef
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.L1784
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.L1786
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1787:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.L1787
	movzbl	12(%rdx), %eax
.L1786:
	cmpq	%rax, %r9
	jnb	.L1789
	.p2align 4,,10
	.p2align 3
.L1788:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.L1788
.L1789:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1784:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.def	hrdbf_write_number_scaled;	.scl	2;	.type	32;	.endef
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.L1798
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1798:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
	.def	hrdbf_write_number_double;	.scl	2;	.type	32;	.endef
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.L1800
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1800:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
	.def	hrdbf_write_date;	.scl	2;	.type	32;	.endef
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.L1821
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.L1824
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
	ja	.L1821
	cmpl	$9999, %r8d
	jbe	.L1821
	testl	%r11d, %r11d
	je	.L1821
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.L1805
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.L1807
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.L1807:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.L1801
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
.L1801:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1824:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.L1804:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.L1804
	xorl	%r10d, %r10d
.L1821:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1805:
	movl	$28, %edx
	testb	$3, %bl
	jne	.L1807
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.L1807
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.L1807
	.p2align 4
	.globl	hrdbf_write_logical
	.def	hrdbf_write_logical;	.scl	2;	.type	32;	.endef
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.L1825
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.L1825:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
	.def	hrdbf_write_blank;	.scl	2;	.type	32;	.endef
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.L1837
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1836
.L1837:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.L1835
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1834:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1834
.L1835:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1836:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_deleted
	.def	hrdbf_write_deleted;	.scl	2;	.type	32;	.endef
hrdbf_write_deleted:
	cmpb	$1, %dl
	sbbl	%eax, %eax
	andl	$-10, %eax
	addl	$42, %eax
	movb	%al, (%rcx)
	ret
	.p2align 4
	.globl	hrdbf_file_close
	.def	hrdbf_file_close;	.scl	2;	.type	32;	.endef
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
	je	.L1848
	movq	$0, 32968(%rbx)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L1855
.L1848:
	xorl	%r12d, %r12d
.L1847:
	movq	32944(%rbx), %rcx
	testq	%rcx, %rcx
	je	.L1845
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1850
	movq	$0, 32944(%rbx)
	movq	$0, 32952(%rbx)
.L1845:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1855:
	movl	$7, %r12d
	jmp	.L1847
	.p2align 4,,10
	.p2align 3
.L1850:
	movl	$7, %r12d
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4
	.def	hrdbf_file_open.part.0;	.scl	3;	.type	32;	.endef
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
	movb	$0, fsink(%rip)
	sete	%al
	movl	%r8d, 48(%rsp)
	leaq	32952(%r12), %r8
	movb	$0, 32976(%r12)
	movl	%eax, 32960(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.L1857
	movl	%eax, %r13d
	leaq	fsink(%rip), %rax
	leaq	32976(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.L1858
	.p2align 4,,10
	.p2align 3
.L1860:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.L1859
.L1858:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.L1860
.L1859:
	movb	$0, (%rdx)
.L1862:
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
.L1857:
	movq	32944(%r12), %rdx
	movq	32952(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.L1862
	addq	$72, %rsp
	movl	%r13d, %eax
	popq	%r12
	popq	%r13
	ret
	.p2align 4
	.def	hrdbf_app_exit;	.scl	3;	.type	32;	.endef
hrdbf_app_exit:
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_close
	movl	$1, %ecx
	call	*__imp_ExitProcess(%rip)
	.p2align 4
	.def	hrdbf_app_fail;	.scl	3;	.type	32;	.endef
hrdbf_app_fail:
	subq	$40, %rsp
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.section .rdata,"dr"
	.align 8
.LC74:
	.ascii "hbc: DBF field decoding failed\12\0"
	.align 8
.LC75:
	.ascii "hbc: DBF field string allocation failed\12\0"
	.text
	.p2align 4
	.def	hrdbfw_app_get_ord.part.0;	.scl	3;	.type	32;	.endef
hrdbfw_app_get_ord.part.0:
	pushq	%r12
	movl	$85, %eax
	pushq	%rbx
	subq	$328, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	movb	$0, 60(%rsp)
	movw	%ax, 32(%rsp)
	movb	$0, 34(%rsp)
	movq	$0, 40(%rsp)
	movq	$0, 48(%rsp)
	movl	$0, 56(%rsp)
	je	.L1873
	movzwl	36+hrdbf_app_state(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.L1883
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1873
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.L1887
	cmpb	$78, %al
	je	.L1888
	cmpb	$68, %al
	je	.L1882
	movzbl	60(%rsp), %eax
.L1872:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1887:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.L1889
.L1875:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.L1890
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1873:
	leaq	.LC74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1883:
	xorl	%eax, %eax
	jmp	.L1872
	.p2align 4,,10
	.p2align 3
.L1888:
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
.L1882:
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
.L1889:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.L1878
	.p2align 4,,10
	.p2align 3
.L1877:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1877
.L1878:
	movq	%rcx, 40(%rsp)
	jmp	.L1875
.L1890:
	leaq	.LC75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC76:
	.ascii "\12\0"
	.text
	.p2align 4
	.def	hrdbfw_app_field_missing;	.scl	3;	.type	32;	.endef
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
	movq	__imp_GetStdHandle(%rip), %rdi
	call	*%rdi
	leaq	60(%rsp), %rsi
	movq	__imp_WriteFile(%rip), %rbx
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
	leaq	.LC76(%rip), %rdx
	movq	$0, 32(%rsp)
	movq	%rax, %rcx
	call	*%rbx
	call	hrntx_file_close.constprop.0
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_close
	movl	$1, %ecx
	call	*__imp_ExitProcess(%rip)
	.p2align 4
	.globl	hrdbf_file_open
	.def	hrdbf_file_open;	.scl	2;	.type	32;	.endef
hrdbf_file_open:
	pushq	%r13
	movq	%rdx, %r13
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	movl	%r8d, %ebx
	subq	$32, %rsp
	movb	$0, 32976(%rcx)
	movb	$0, fsink(%rip)
	movq	$0, 8(%rcx)
	movq	$0, (%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movl	$0, 32960(%rcx)
	movq	32968(%rcx), %rcx
	testq	%rcx, %rcx
	je	.L1913
	movq	$0, 32968(%r12)
	call	*__imp_CloseHandle(%rip)
	movq	32944(%r12), %rcx
	testl	%eax, %eax
	jne	.L1897
	testq	%rcx, %rcx
	je	.L1893
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1893
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
.L1897:
	testq	%rcx, %rcx
	je	.L1896
.L1895:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L1911
.L1893:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1913:
	movq	32944(%r12), %rcx
	testq	%rcx, %rcx
	jne	.L1895
.L1896:
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
.L1911:
	movq	$0, 32944(%r12)
	movq	$0, 32952(%r12)
	jmp	.L1896
	.p2align 4
	.globl	hrdbf_file_write_record
	.def	hrdbf_file_write_record;	.scl	2;	.type	32;	.endef
hrdbf_file_write_record:
	movl	32960(%rcx), %eax
	testl	%eax, %eax
	je	.L1918
	cmpq	$0, 32968(%rcx)
	je	.L1918
	cmpb	$0, 40(%rcx)
	je	.L1918
	testq	%rdx, %rdx
	je	.L1919
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.L1921
	ret
	.p2align 4,,10
	.p2align 3
.L1918:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1919:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1921:
	movzwl	34(%rcx), %r9d
	subq	$1, %rdx
	movzwl	32(%rcx), %eax
	movq	32944(%rcx), %r8
	imulq	%r9, %rdx
	addq	%rax, %rdx
	addq	%rdx, %r8
	jmp	write_at
	.p2align 4
	.globl	hrdbf_file_append
	.def	hrdbf_file_append;	.scl	2;	.type	32;	.endef
hrdbf_file_append:
	movl	32960(%rcx), %eax
	testl	%eax, %eax
	je	.L1922
	cmpq	$0, 32968(%rcx)
	je	.L1922
	cmpb	$0, 40(%rcx)
	je	.L1922
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1922:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrntx_close
	.def	hrntx_close;	.scl	2;	.type	32;	.endef
hrntx_close:
	movq	$0, (%rcx)
	movq	$0, 8(%rcx)
	movq	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	ret
	.p2align 4
	.globl	hrntx_seek
	.def	hrntx_seek;	.scl	2;	.type	32;	.endef
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
	je	.L1929
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L1934:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl	%r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.L1947
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1933
	.p2align 4,,10
	.p2align 3
.L1931:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1947
.L1933:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.L1931
	jnb	.L1947
	leal	1(%r10), %r11d
.L1930:
	cmpl	%r9d, %r11d
	jb	.L1934
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.L1938
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.L1937:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.L1939
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1940
	.p2align 4,,10
	.p2align 3
.L1972:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1939
.L1940:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.L1972
.L1938:
	testl	%ebp, %ebp
	je	.L1928
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.L1973
	movl	%r11d, %r9d
.L1928:
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
.L1947:
	movl	%r10d, %r9d
	jmp	.L1930
.L1939:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.L1928
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.L1941
	.p2align 4,,10
	.p2align 3
.L1946:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl	%r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.L1942
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1945
	.p2align 4,,10
	.p2align 3
.L1943:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1942
.L1945:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.L1943
	jb	.L1942
	movl	%r9d, %r10d
.L1944:
	cmpl	%r10d, %r11d
	jb	.L1946
.L1941:
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
.L1942:
	leal	1(%r9), %r11d
	jmp	.L1944
.L1973:
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
.L1929:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.L1928
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.L1937
	.p2align 4
	.globl	hrntx_build
	.def	hrntx_build;	.scl	2;	.type	32;	.endef
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
	je	.L1978
	movq	%rdx, %r11
	testq	%rdx, %rdx
	je	.L1978
	cmpb	$0, 40(%r9)
	je	.L1978
	movzwl	28(%r8), %edi
	movw	%di, 80(%rsp)
	testw	%di, %di
	je	.L1978
	testq	%rsi, %rsi
	je	.L1978
	movq	%rcx, %rbx
	movl	16(%r9), %ecx
	movq	%rcx, %rax
	movq	%rcx, 112(%rsp)
	salq	$4, %rax
	cmpq	56(%rbp), %rax
	ja	.L1978
	movzwl	18(%rdx), %edx
	movw	%dx, 86(%rsp)
	testw	%dx, %dx
	je	.L1978
	movzwl	%dx, %r15d
	movzwl	%di, %r10d
	leaq	8(%r10), %rdi
	movq	%r15, %rax
	leaq	4(%r15,%r15), %r12
	movq	%r15, 104(%rsp)
	imulq	%rdi, %rax
	addq	%r12, %rax
	cmpq	$1024, %rax
	ja	.L1978
	movq	%r15, %rdx
	movzwl	30(%r8), %eax
	addq	$1, %rdx
	movq	%rdx, 96(%rsp)
	cmpq	%r15, %rcx
	ja	.L1979
	testq	%rcx, %rcx
	je	.L2024
.L1980:
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
.L1982:
	leal	1(%rax), %r8d
	addq	$1, %rax
	movq	%rcx, 8(%rdx)
	addq	$16, %rdx
	movl	%r8d, -16(%rdx)
	addq	%r13, %rcx
	cmpq	%rax, %r9
	ja	.L1982
	cmpq	$1, 112(%rsp)
	jbe	.L2001
	movq	%r12, 120(%rsp)
	movq	112(%rsp), %r14
	leaq	16(%rsi), %r15
	movl	$1, %r13d
	movq	%rdi, 128(%rsp)
	.p2align 4,,10
	.p2align 3
.L1989:
	movl	(%r15), %r12d
	movq	8(%r15), %rcx
	movq	%r15, %r8
	.p2align 4,,10
	.p2align 3
.L1984:
	movl	-16(%r8), %r9d
	movq	-8(%r8), %rdx
	movq	%r8, %rdi
	xorl	%eax, %eax
	movl	%r9d, 136(%rsp)
	.p2align 4,,10
	.p2align 3
.L1988:
	movzbl	(%rdx,%rax), %r9d
	cmpb	%r9b, (%rcx,%rax)
	jne	.L2025
	addq	$1, %rax
	cmpq	%rax, %r10
	ja	.L1988
	movl	136(%rsp), %r9d
	cmpl	%r12d, %r9d
	jbe	.L1985
.L1987:
	movdqu	-16(%r8), %xmm0
	subq	$16, %r8
	movups	%xmm0, 16(%r8)
	cmpq	%rsi, %r8
	jne	.L1984
	movq	%rsi, %rdi
	.p2align 4,,10
	.p2align 3
.L1985:
	addq	$1, %r13
	movl	%r12d, (%rdi)
	addq	$16, %r15
	movq	%rcx, 8(%rdi)
	cmpq	%r13, %r14
	jne	.L1989
	movq	128(%rsp), %rdi
	movq	120(%rsp), %r12
.L2001:
	movq	112(%rsp), %rax
	movq	104(%rsp), %rcx
	xorl	%edx, %edx
	leaq	1(%rax,%rcx), %rax
	divq	96(%rsp)
	movq	%rax, 128(%rsp)
	cmpq	%rcx, %rax
	jbe	.L1981
	.p2align 4,,10
	.p2align 3
.L1978:
	xorl	%eax, %eax
.L1974:
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
.L1979:
	movq	104(%rsp), %rcx
	movq	%rcx, %rdx
	imulq	%rcx, %rdx
	cmpq	112(%rsp), %rdx
	jnb	.L1980
	jmp	.L1978
.L2024:
	movq	$1, 128(%rsp)
.L1981:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1990:
	movzbl	(%r11,%rax), %edx
	movb	%dl, (%rbx,%rax)
	addq	$1, %rax
	cmpq	$1024, %rax
	jne	.L1990
	movq	128(%rsp), %rax
	testq	%rax, %rax
	je	.L1991
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
.L1994:
	movq	72(%rsp), %rsi
	cmpq	%rsi, 136(%rsp)
	je	.L2026
	movzbl	86(%rsp), %eax
	movq	104(%rsp), %r13
	movb	%al, (%r12)
	movzbl	84(%rsp), %eax
	movb	%al, 1(%r12)
.L1993:
	movq	120(%rsp), %rax
	xorl	%r14d, %r14d
	salq	$4, %rax
	addq	48(%rbp), %rax
	movq	%rax, %rsi
	.p2align 4,,10
	.p2align 3
.L1996:
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
	call	nxputslot
	cmpq	%r13, %r14
	jne	.L1996
.L1997:
	movl	%ebx, 56(%rsp)
	movq	%r13, %rdx
	movq	%r12, %rcx
	movq	%rdi, %r9
	movq	$0, 48(%rsp)
	movq	%r15, %r8
	addq	$1024, %r12
	movl	$0, 40(%rsp)
	movl	$0, 32(%rsp)
	call	nxputslot
	movq	96(%rsp), %rdx
	addq	%rdx, 120(%rsp)
	addq	$1, 136(%rsp)
	movq	136(%rsp), %rax
	subq	%rdx, 88(%rsp)
	cmpq	128(%rsp), %rax
	jne	.L1994
	movq	128(%rsp), %rax
	movq	16(%rbp), %rbx
	movq	%r15, %r12
	movq	48(%rbp), %rsi
	cmpq	$1, %rax
	je	.L1991
	leaq	1(%rax), %r13
	subl	$1, %eax
	movq	104(%rsp), %r14
	movl	$1, %r15d
	salq	$10, %r13
	leaq	(%rbx,%r13), %rcx
	movw	%ax, (%rcx)
	movq	%rcx, %rbx
	jmp	.L1998
.L2004:
	movq	%rax, %r15
.L1998:
	leaq	-1(%r15), %rdx
	cmpq	%r14, 112(%rsp)
	jbe	.L1978
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
	call	nxputslot
	leaq	1(%r15), %rax
	addq	96(%rsp), %r14
	cmpq	128(%rsp), %rax
	jne	.L2004
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
	call	nxputslot
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
.L1999:
	addq	128(%rsp), %rax
	salq	$10, %rax
	jmp	.L1974
	.p2align 4,,10
	.p2align 3
.L2025:
	jb	.L1987
	jmp	.L1985
.L2026:
	movq	88(%rsp), %rsi
	cmpq	%rsi, 104(%rsp)
	jb	.L1978
	movl	%esi, %eax
	movb	%sil, (%r12)
	shrw	$8, %ax
	movb	%al, 1(%r12)
	testq	%rsi, %rsi
	jne	.L2003
	xorl	%r13d, %r13d
	jmp	.L1997
.L2003:
	movq	88(%rsp), %r13
	jmp	.L1993
.L1991:
	movl	$1024, 4(%rbx)
	movl	$1, %eax
	jmp	.L1999
	.section .rdata,"dr"
	.align 8
.LC77:
	.ascii "hbc: DBF NTX index rebuild failed\12\0"
	.text
	.p2align 4
	.def	hrdbf_app_rebuild_index;	.scl	3;	.type	32;	.endef
hrdbf_app_rebuild_index:
	movq	hrdbf_app_order(%rip), %rax
	testq	%rax, %rax
	je	.L2067
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.L2072
.L2067:
	ret
	.p2align 4,,10
	.p2align 3
.L2072:
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
	movl	16+hrdbf_app_state(%rip), %ecx
	movzwl	18(%rax), %eax
	testl	%ecx, %ecx
	jne	.L2029
	testw	%ax, %ax
	je	.L2033
	movl	$1, %ebx
	movl	$2048, %edx
.L2031:
	movl	%ecx, %r15d
	movq	__imp_VirtualAlloc(%rip), %r13
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
	je	.L2033
	leaq	(%rdi,%rsi), %r14
	movl	$4, %r9d
	movl	$12288, %r8d
	xorl	%ecx, %ecx
	addq	%rbx, %r14
	movq	%r14, %rdx
	call	*%r13
	movq	%rax, %r13
	testq	%rax, %rax
	je	.L2073
	movq	%rdi, 40(%rsp)
	movq	hrdbf_app_order(%rip), %rdx
	movq	%r12, %rcx
	leaq	hrdbf_app_state(%rip), %r9
	movq	%rax, 32(%rsp)
	leaq	hrdbf_app_order(%rip), %r8
	call	hrntx_build
	movq	%rax, %rdi
	testq	%rax, %rax
	je	.L2070
	leaq	0(%r13,%r15,8), %rax
	addq	%rsi, %rbx
	movq	%r13, 32(%rsp)
	movq	%rdi, %r8
	movq	%rax, 48(%rsp)
	movl	16+hrdbf_app_state(%rip), %eax
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
	jne	.L2070
	movq	64+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L2038
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
.L2038:
	movq	32+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L2039
	movl	$32768, %r8d
	xorl	%edx, %edx
	call	*__imp_VirtualFree(%rip)
.L2039:
	movq	40+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L2040
	movl	$32768, %r8d
	xorl	%edx, %edx
	call	*__imp_VirtualFree(%rip)
.L2040:
	movdqu	80(%rsp), %xmm1
	movdqu	64(%rsp), %xmm0
	xorl	%eax, %eax
	movq	%r12, 32+hrdbf_app_order(%rip)
	movq	%rdi, 48+hrdbf_app_order(%rip)
	movq	24+hrdbf_app_state(%rip), %r9
	movups	%xmm1, 16+hrdbf_app_order(%rip)
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	16+hrdbf_app_order(%rip), %r8
	movq	%r13, 40+hrdbf_app_order(%rip)
	movq	%r14, 56+hrdbf_app_order(%rip)
	movl	$1, 72+hrdbf_app_order(%rip)
	movq	%rcx, hrdbf_app_pos(%rip)
	movups	%xmm0, hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	jne	.L2045
	jmp	.L2071
	.p2align 4,,10
	.p2align 3
.L2043:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2071
.L2045:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.L2043
	cmpq	%rax, %rcx
	movq	%rax, hrdbf_app_pos(%rip)
	setbe	%al
	jbe	.L2042
.L2044:
	movq	%rdx, 24+hrdbf_app_state(%rip)
	movb	%al, 39+hrdbf_app_state(%rip)
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
.L2029:
	movzwl	%ax, %r8d
	xorl	%edx, %edx
	leal	-1(%rcx,%rax), %eax
	divq	%r8
	cmpq	%rax, %r8
	jb	.L2033
	cmpq	$1, %rax
	jbe	.L2034
	leaq	2(%rax), %rdx
	leaq	9(%rax), %rbx
	salq	$10, %rdx
	shrq	$3, %rbx
	jmp	.L2031
	.p2align 4,,10
	.p2align 3
.L2071:
	movl	$1, %eax
.L2042:
	movl	16+hrdbf_app_state(%rip), %edx
	addq	$1, %rdx
	jmp	.L2044
	.p2align 4,,10
	.p2align 3
.L2070:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r12, %rcx
	movq	__imp_VirtualFree(%rip), %rbx
	call	*%rbx
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*%rbx
.L2033:
	leaq	.LC77(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2073:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r12, %rcx
	call	*__imp_VirtualFree(%rip)
	jmp	.L2033
.L2034:
	leaq	1(%rax), %rdx
	movl	$1, %ebx
	salq	$10, %rdx
	jmp	.L2031
	.section .rdata,"dr"
.LC78:
	.ascii "hbc: DBF index flush failed\12\0"
.LC79:
	.ascii "hbc: DBF/NTX close failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_close
	.def	hrdbfw_app_close;	.scl	2;	.type	32;	.endef
hrdbfw_app_close:
	pushq	%rbx
	subq	$32, %rsp
	movl	72+hrdbf_app_order(%rip), %eax
	testl	%eax, %eax
	je	.L2075
	cmpq	$0, 32+hrdbf_app_order(%rip)
	je	.L2075
	cmpq	$0, 48+hrdbf_app_order(%rip)
	jne	.L2081
.L2075:
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
	jne	.L2082
	addq	$32, %rsp
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L2081:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.L2075
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L2082:
	leaq	.LC79(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC80:
	.ascii "out of memory\0"
	.align 8
.LC81:
	.ascii "unsupported table version or header flags\0"
.LC82:
	.ascii "unsupported field type\0"
.LC83:
	.ascii "record content invalid\0"
.LC84:
	.ascii "I/O error\0"
	.align 8
.LC85:
	.ascii "size or field-count limit exceeded\0"
.LC86:
	.ascii "table format not supported\0"
	.align 8
.LC87:
	.ascii "hbc: DBF only one workarea is supported\12\0"
	.align 8
.LC88:
	.ascii "hbc: DBF filename length outside supported range\12\0"
	.align 8
.LC89:
	.ascii "hbc: DBF filename contains NUL\12\0"
.LC90:
	.ascii "hbc: DBF index close failed\12\0"
	.align 8
.LC91:
	.ascii "hbc: DBF open mode outside supported range\12\0"
.LC92:
	.ascii "hbc: DBF open rejected: \0"
	.text
	.p2align 4
	.globl	hrdbfw_app_open
	.def	hrdbfw_app_open;	.scl	2;	.type	32;	.endef
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
	je	.L2084
	cmpb	$0, 40+hrdbf_app_state(%rip)
	jne	.L2154
.L2084:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.L2155
	xorl	%ebx, %ebx
	jmp	.L2085
	.p2align 4,,10
	.p2align 3
.L2120:
	movq	%rsi, %rbx
.L2085:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.L2156
	leaq	1(%rbx), %rsi
	movb	%al, 64(%rsp,%rbx)
	leaq	64(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.L2120
	movb	$0, 64(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2157
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
	ja	.L2158
	sete	%al
	xorl	%edx, %edx
	movzbl	%al, %eax
	movl	%eax, hrdbf_app_shared(%rip)
	xorl	%eax, %eax
	jmp	.L2091
	.p2align 4,,10
	.p2align 3
.L2089:
	cmpq	%r8, %rbx
	je	.L2159
.L2091:
	movzbl	(%rdi,%rdx), %ecx
	movq	%rdx, %r8
	addq	$1, %rdx
	cmpb	$47, %cl
	je	.L2131
	cmpb	$92, %cl
	jne	.L2089
.L2131:
	movq	%rdx, %rax
	cmpq	%r8, %rbx
	jne	.L2091
.L2159:
	cmpq	%rsi, %rax
	jb	.L2094
	jmp	.L2160
	.p2align 4,,10
	.p2align 3
.L2121:
	movq	%rdx, %rax
.L2094:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.L2121
	movq	%rsi, hrdbf_app_baselen(%rip)
	testq	%rsi, %rsi
	je	.L2095
.L2118:
	xorl	%edx, %edx
	leaq	hrdbf_app_basename(%rip), %r9
	jmp	.L2097
	.p2align 4,,10
	.p2align 3
.L2161:
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jbe	.L2095
.L2097:
	movzbl	(%rdi,%rdx), %eax
	cmpb	$92, %al
	jne	.L2161
	movl	$47, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	ja	.L2097
.L2095:
	leaq	hrdbf_app_state(%rip), %rcx
	movb	$0, 32976+hrdbf_app_state(%rip)
	movb	$0, fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.L2162
.L2098:
	leaq	32976+hrdbf_app_state(%rip), %r12
	cmpb	$0, 32976+hrdbf_app_state(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.L2101
	leaq	.LC84(%rip), %r12
	cmpl	$7, %eax
	je	.L2101
	leaq	.LC80(%rip), %r12
	cmpl	$8, %eax
	je	.L2101
	leaq	.LC85(%rip), %r12
	cmpl	$4, %eax
	je	.L2101
	leaq	.LC81(%rip), %r12
	cmpl	$2, %eax
	je	.L2101
	leaq	.LC82(%rip), %r12
	cmpl	$3, %eax
	je	.L2101
	cmpl	$5, %eax
	leaq	.LC83(%rip), %r12
	leaq	.LC86(%rip), %rax
	cmovne	%rax, %r12
.L2101:
	leaq	.LC92(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.L2162:
	movl	%ebp, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L2098
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	je	.L2083
	leaq	4(%rsi), %rax
	cmpq	$259, %rax
	jbe	.L2163
.L2083:
	addq	$872, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	ret
.L2163:
	movb	$46, 64(%rsp,%rsi)
	movzbl	64(%rsp), %eax
	movb	$99, 65(%rsp,%rsi)
	movb	$100, 66(%rsp,%rsi)
	movb	$120, 67(%rsp,%rsi)
	movb	$0, 68(%rsp,%rsi)
	testb	%al, %al
	je	.L2106
	cmpb	$92, %al
	je	.L2164
	cmpb	$47, %al
	je	.L2110
.L2109:
	leaq	336(%rsp), %r13
	movq	%r12, %rcx
	movq	%r13, %rdx
	call	hrdbfw_path.part.0
	testl	%eax, %eax
	je	.L2106
	movq	%r13, %rcx
	xorl	%r9d, %r9d
	movq	$0, 48(%rsp)
	movl	$1, %r8d
	movl	$128, 40(%rsp)
	movl	$-2147483648, %edx
	movl	$3, 32(%rsp)
	call	*__imp_CreateFileW(%rip)
	movq	%rax, %rcx
	cmpq	$-1, %rax
	je	.L2165
	call	*__imp_CloseHandle(%rip)
.L2106:
	cmpq	$1, %rbp
	je	.L2166
	movl	hrdbf_app_shared(%rip), %eax
	testl	%eax, %eax
	je	.L2115
	movl	$4, hrdbf_app_struct(%rip)
	jmp	.L2083
.L2160:
	movq	%rsi, hrdbf_app_baselen(%rip)
	jmp	.L2118
.L2165:
	call	*__imp_GetLastError(%rip)
	subl	$2, %eax
	cmpl	$1, %eax
	jbe	.L2083
	jmp	.L2106
	.p2align 4,,10
	.p2align 3
.L2110:
	cmpb	$47, 65(%rsp)
	jne	.L2109
	jmp	.L2106
.L2115:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2116
	movl	$1, %edx
	movq	%r12, %rcx
	call	hrntx_file_open.part.0.constprop.0
	movl	%eax, %r8d
	movl	$1, %eax
	testl	%r8d, %r8d
	jne	.L2116
.L2117:
	movl	%eax, hrdbf_app_struct(%rip)
	jmp	.L2083
.L2164:
	cmpb	$92, 65(%rsp)
	jne	.L2109
	jmp	.L2106
.L2166:
	movl	$2, hrdbf_app_struct(%rip)
	jmp	.L2083
.L2116:
	movl	$3, %eax
	jmp	.L2117
.L2156:
	leaq	.LC89(%rip), %rcx
	call	hrdbf_app_fail
.L2158:
	leaq	.LC91(%rip), %rcx
	call	hrdbf_app_fail
.L2157:
	leaq	.LC90(%rip), %rcx
	call	hrdbf_app_fail
.L2155:
	leaq	.LC88(%rip), %rcx
	call	hrdbf_app_fail
.L2154:
	leaq	.LC87(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC93:
	.ascii "hbc: DBF no workarea is open\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_top
	.def	hrdbfw_app_top;	.scl	2;	.type	32;	.endef
hrdbfw_app_top:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2177
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2169
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L2170
.L2169:
	movl	16+hrdbf_app_state(%rip), %eax
	movq	$1, 24+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2170:
	movl	24+hrdbf_app_order(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L2172
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx), %ecx
.L2173:
	testq	%rdx, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	sete	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2172:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
	jmp	.L2173
.L2177:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
	.def	hrdbfw_app_bottom;	.scl	2;	.type	32;	.endef
hrdbfw_app_bottom:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2189
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2180
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2180
	movl	24+hrdbf_app_order(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.L2190
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.L2184:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
.L2185:
	cmpq	%r8, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	setnb	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2190:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.L2184
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.L2185
	.p2align 4,,10
	.p2align 3
.L2180:
	movl	16+hrdbf_app_state(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, 24+hrdbf_app_state(%rip)
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
.L2189:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
	.def	hrdbfw_app_skip;	.scl	2;	.type	32;	.endef
hrdbfw_app_skip:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2209
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L2193
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2193
	testq	%rcx, %rcx
	je	.L2191
	movb	$0, 38+hrdbf_app_state(%rip)
	movl	24+hrdbf_app_order(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.L2196
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.L2202
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.L2197:
	movq	%rdx, hrdbf_app_pos(%rip)
.L2198:
	cmpq	%rax, %rdx
	jnb	.L2200
	movq	16+hrdbf_app_order(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.L2201:
	movq	%rax, 24+hrdbf_app_state(%rip)
	movb	%cl, 39+hrdbf_app_state(%rip)
.L2191:
	ret
	.p2align 4,,10
	.p2align 3
.L2193:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L2202:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.L2197
	.p2align 4,,10
	.p2align 3
.L2200:
	movl	16+hrdbf_app_state(%rip), %eax
	addq	$1, %rax
	jmp	.L2201
	.p2align 4,,10
	.p2align 3
.L2196:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.L2199
	testq	%rax, %rax
	movb	$1, 38+hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.L2198
	.p2align 4,,10
	.p2align 3
.L2199:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.L2198
.L2209:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC94:
	.ascii "hbc: CDX direct character key field width must be <=240\12\0"
	.align 8
.LC95:
	.ascii "hbc: DBF index read-only open rejected (subset, format, DBF mismatch, size or I/O)\12\0"
	.align 8
.LC96:
	.ascii "hbc: DBF index filename length outside supported range\12\0"
	.align 8
.LC97:
	.ascii "hbc: DBF index filename contains NUL\12\0"
	.align 8
.LC98:
	.ascii "hbc: structural CDX on a readonly=.F. open is outside this increment (index maintenance)\12\0"
	.align 8
.LC99:
	.ascii "hbc: structural CDX present but not admitted (one tag, subset, size or format)\12\0"
	.align 8
.LC100:
	.ascii "hbc: structural CDX on a shared=.T. open is outside this increment (index lock protocol)\12\0"
	.align 8
.LC101:
	.ascii "hbc: DBF index on a shared=.T. open is outside this increment (index lock protocol)\12\0"
	.align 8
.LC102:
	.ascii "hbc: DBF index only one index is supported\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_order_add
	.def	hrdbfw_app_order_add;	.scl	2;	.type	32;	.endef
hrdbfw_app_order_add:
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$304, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2268
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.L2269
	movq	%rcx, %r8
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	jmp	.L2212
	.p2align 4,,10
	.p2align 3
.L2214:
	cmpq	%rbx, %r9
	je	.L2270
.L2240:
	movq	%rbx, %rdx
.L2212:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.L2271
	movb	%al, 32(%rsp,%rdx)
	leaq	32(%rsp), %rsi
	leaq	1(%rdx), %rbx
	cmpb	$47, %al
	je	.L2246
	cmpb	$92, %al
	jne	.L2214
.L2246:
	movq	%rbx, %rcx
	cmpq	%rbx, %r9
	jne	.L2240
.L2270:
	movq	%rbx, %rax
	xorl	%r9d, %r9d
	cmpq	%rbx, %rcx
	jnb	.L2216
	movl	$1, %r11d
	jmp	.L2218
	.p2align 4,,10
	.p2align 3
.L2242:
	movq	%r10, %rcx
.L2218:
	cmpb	$46, (%r8,%rcx)
	leaq	1(%rcx), %r10
	cmove	%rcx, %rax
	cmove	%r11d, %r9d
	cmpq	%rdx, %rcx
	jne	.L2242
.L2216:
	movl	hrdbf_app_cdx(%rip), %r12d
	testl	%r12d, %r12d
	jne	.L2272
.L2219:
	movl	hrdbf_app_shared(%rip), %ecx
	testl	%ecx, %ecx
	jne	.L2273
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2274
	testl	%r9d, %r9d
	je	.L2275
	movb	$0, 32(%rsp,%rbx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2230
.L2278:
	movl	%r12d, %edx
	movq	%rsi, %rcx
	call	hrntx_file_open.part.0.constprop.0
	testl	%eax, %eax
	jne	.L2230
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.L2234
	xorl	%eax, %eax
	leaq	hrdbf_app_ntxpath(%rip), %rcx
	.p2align 4,,10
	.p2align 3
.L2235:
	movzbl	(%rsi,%rax), %edx
	movb	%dl, (%rcx,%rax)
	movq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rdx, %rbx
	jne	.L2235
	jmp	.L2236
	.p2align 4,,10
	.p2align 3
.L2272:
	cmpq	%rax, hrdbf_app_baselen(%rip)
	jne	.L2219
	testq	%rax, %rax
	je	.L2220
	movl	$1, %r11d
	xorl	%r10d, %r10d
	leaq	hrdbf_app_basename(%rip), %r14
	xorl	%r13d, %r13d
	jmp	.L2223
	.p2align 4,,10
	.p2align 3
.L2277:
	leal	-97(%rcx), %ebp
	leal	-32(%rcx), %edi
	cmpb	$26, %bpl
	cmovb	%edi, %ecx
.L2221:
	cmpb	%cl, (%r14,%r10)
	cmovne	%r13d, %r11d
	addq	$1, %r10
	cmpq	%rax, %r10
	je	.L2276
.L2223:
	movzbl	(%r8,%r10), %ecx
	cmpb	$92, %cl
	jne	.L2277
	movl	$47, %ecx
	jmp	.L2221
	.p2align 4,,10
	.p2align 3
.L2234:
	movb	$0, hrdbf_app_ntxpath(%rip)
.L2236:
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
.L2275:
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
	je	.L2278
.L2230:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L2247
	leaq	.LC94(%rip), %rcx
	cmpl	$3, %eax
	je	.L2232
.L2247:
	leaq	.LC95(%rip), %rcx
.L2232:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2276:
	testl	%r11d, %r11d
	je	.L2219
.L2220:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$1, %eax
	je	.L2236
	cmpl	$2, %eax
	je	.L2279
	cmpl	$3, %eax
	je	.L2280
	cmpl	$4, %eax
	jne	.L2219
	leaq	.LC100(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2271:
	leaq	.LC97(%rip), %rcx
	call	hrdbf_app_fail
.L2280:
	leaq	.LC99(%rip), %rcx
	call	hrdbf_app_fail
.L2279:
	leaq	.LC98(%rip), %rcx
	call	hrdbf_app_fail
.L2269:
	leaq	.LC96(%rip), %rcx
	call	hrdbf_app_fail
.L2268:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2274:
	leaq	.LC102(%rip), %rcx
	call	hrdbf_app_fail
.L2273:
	leaq	.LC101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
	.def	hrdbfw_app_order_clear;	.scl	2;	.type	32;	.endef
hrdbfw_app_order_clear:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2289
	movl	72+hrdbf_app_order(%rip), %eax
	testl	%eax, %eax
	je	.L2283
	cmpq	$0, 32+hrdbf_app_order(%rip)
	je	.L2283
	cmpq	$0, 48+hrdbf_app_order(%rip)
	jne	.L2290
.L2283:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2291
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	movb	$0, hrdbf_app_ntxpath(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2290:
	call	hrntx_file_flush.part.0.constprop.0
	testl	%eax, %eax
	je	.L2283
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L2289:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2291:
	leaq	.LC90(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
	.def	hrdbfw_app_found;	.scl	2;	.type	32;	.endef
hrdbfw_app_found:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2297
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2297:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC103:
	.ascii "hbc: DBF index seek requires an open index\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
	.def	hrdbfw_app_seek;	.scl	2;	.type	32;	.endef
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2305
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2300
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2300
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
	movl	24+hrdbf_app_order(%rip), %r8d
	movl	%eax, %eax
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%r8, %rcx
	movl	%edx, hrdbf_app_found_flag(%rip)
	cmpq	%r8, %rax
	jb	.L2306
	movl	16+hrdbf_app_state(%rip), %r9d
	addq	$1, %r9
.L2303:
	cmpq	%r8, %rax
	movq	%r9, 24+hrdbf_app_state(%rip)
	movslq	%edx, %rax
	setnb	39+hrdbf_app_state(%rip)
	orl	hrdbf_app_cdx(%rip), %ecx
	sete	38+hrdbf_app_state(%rip)
	addq	$72, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2306:
	movq	16+hrdbf_app_order(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.L2303
.L2300:
	leaq	.LC103(%rip), %rcx
	call	hrdbf_app_fail
.L2305:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC104:
	.ascii "hbc: DBF index seek expects a character key value\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_seek_dyn
	.def	hrdbfw_app_seek_dyn;	.scl	2;	.type	32;	.endef
hrdbfw_app_seek_dyn:
	pushq	%r12
	pushq	%rbx
	subq	$344, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2345
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2309
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2309
	movq	%rcx, %rax
	movq	%rdx, %rcx
	movq	%r8, %rbx
	movzbl	%al, %edx
	leal	-2(%rdx), %r8d
	andl	$-3, %r8d
	je	.L2346
	testl	%edx, %edx
	je	.L2324
	cmpl	$9, %edx
	je	.L2324
	cmpl	$5, %edx
	je	.L2347
	cmpl	$12, %edx
	je	.L2348
	movl	24+hrdbf_app_order(%rip), %eax
	movb	$1, 39+hrdbf_app_state(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	movq	%rax, hrdbf_app_pos(%rip)
	movq	%rax, %rdx
	movl	16+hrdbf_app_state(%rip), %eax
	addq	$1, %rax
	orl	hrdbf_app_cdx(%rip), %edx
	movq	%rax, 24+hrdbf_app_state(%rip)
	sete	38+hrdbf_app_state(%rip)
	addq	$344, %rsp
	xorl	%eax, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2346:
	testq	%rcx, %rcx
	je	.L2349
	movq	-8(%rcx), %rdx
	addq	$344, %rsp
	movq	%rbx, %r8
	popq	%rbx
	popq	%r12
	jmp	hrdbfw_app_seek
	.p2align 4,,10
	.p2align 3
.L2348:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rcx, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.L2322
	movsd	.LC0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.L2323:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.L2323
.L2322:
	comisd	.LC105(%rip), %xmm0
	movabsq	$9223372036854775807, %rcx
	ja	.L2324
.L2344:
	movsd	.LC106(%rip), %xmm1
	addq	$1, %rcx
	comisd	%xmm0, %xmm1
	jbe	.L2350
.L2324:
	leaq	48(%rsp), %r12
	movzwl	28+hrdbf_app_order(%rip), %edx
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
.L2347:
	testq	%rax, %rax
	js	.L2351
.L2317:
	movq	%rcx, %xmm0
	comisd	.LC105(%rip), %xmm0
	movabsq	$9223372036854775807, %rcx
	ja	.L2324
	jmp	.L2344
	.p2align 4,,10
	.p2align 3
.L2350:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L2352
	addsd	.LC107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.L2324
	.p2align 4,,10
	.p2align 3
.L2351:
	movq	(%rcx), %rcx
	jmp	.L2317
	.p2align 4,,10
	.p2align 3
.L2352:
	subsd	.LC107(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.L2324
.L2309:
	leaq	.LC103(%rip), %rcx
	call	hrdbf_app_fail
.L2345:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2349:
	leaq	.LC104(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
	.def	hrdbfw_app_recno;	.scl	2;	.type	32;	.endef
hrdbfw_app_recno:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2358
	movq	24+hrdbf_app_state(%rip), %rax
	ret
.L2358:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
	.def	hrdbfw_app_lastrec;	.scl	2;	.type	32;	.endef
hrdbfw_app_lastrec:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2364
	movl	16+hrdbf_app_state(%rip), %eax
	ret
.L2364:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
	.def	hrdbfw_app_fcount;	.scl	2;	.type	32;	.endef
hrdbfw_app_fcount:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2370
	movzwl	36+hrdbf_app_state(%rip), %eax
	ret
.L2370:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
	.def	hrdbfw_app_goto;	.scl	2;	.type	32;	.endef
hrdbfw_app_goto:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2385
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	16+hrdbf_app_state(%rip), %eax
	testq	%rcx, %rcx
	jle	.L2373
	cmpq	%rax, %rcx
	jbe	.L2374
.L2373:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, 24+hrdbf_app_state(%rip)
	movw	%cx, 38+hrdbf_app_state(%rip)
.L2375:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2371
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2386
.L2371:
	ret
	.p2align 4,,10
	.p2align 3
.L2374:
	xorl	%edx, %edx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	movw	%dx, 38+hrdbf_app_state(%rip)
	jmp	.L2375
	.p2align 4,,10
	.p2align 3
.L2386:
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r8
	testl	%ecx, %ecx
	je	.L2380
	movq	16+hrdbf_app_order(%rip), %r9
	xorl	%eax, %eax
	jmp	.L2379
	.p2align 4,,10
	.p2align 3
.L2378:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2377
.L2379:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.L2378
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2380:
	xorl	%ecx, %ecx
.L2377:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2385:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
	.def	hrdbfw_app_ordselect;	.scl	2;	.type	32;	.endef
hrdbfw_app_ordselect:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2403
	testq	%rcx, %rcx
	jle	.L2389
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2404
	cmpq	$1, %rcx
	jne	.L2389
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r9
	xorl	%eax, %eax
	movl	$1, hrdbf_app_order_active(%rip)
	movq	16+hrdbf_app_order(%rip), %r8
	testl	%ecx, %ecx
	jne	.L2395
	jmp	.L2405
	.p2align 4,,10
	.p2align 3
.L2394:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2397
.L2395:
	movl	(%r8,%rax,8), %edx
	cmpq	%rdx, %r9
	jne	.L2394
	movq	%rax, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2404:
	movl	hrdbf_app_struct(%rip), %eax
	cmpl	$2, %eax
	je	.L2406
	cmpl	$3, %eax
	je	.L2407
	cmpl	$4, %eax
	je	.L2408
.L2389:
	movl	$0, hrdbf_app_order_active(%rip)
	addq	$40, %rsp
	ret
.L2405:
	xorl	%ecx, %ecx
.L2397:
	movq	%rcx, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	ret
.L2403:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2406:
	leaq	.LC98(%rip), %rcx
	call	hrdbf_app_fail
.L2408:
	leaq	.LC100(%rip), %rcx
	call	hrdbf_app_fail
.L2407:
	leaq	.LC99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
	.def	hrdbfw_app_bof;	.scl	2;	.type	32;	.endef
hrdbfw_app_bof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2414
	movzbl	38+hrdbf_app_state(%rip), %eax
	ret
.L2414:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
	.def	hrdbfw_app_eof;	.scl	2;	.type	32;	.endef
hrdbfw_app_eof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2420
	movzbl	39+hrdbf_app_state(%rip), %eax
	ret
.L2420:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
	.def	hrdbfw_app_deleted;	.scl	2;	.type	32;	.endef
hrdbfw_app_deleted:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2428
	movq	24+hrdbf_app_state(%rip), %rax
	movl	16+hrdbf_app_state(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2421
	movzwl	34+hrdbf_app_state(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2421:
	movq	%r8, %rax
	ret
.L2428:
	subq	$40, %rsp
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
	.def	hrdbfw_app_get;	.scl	2;	.type	32;	.endef
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2435
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.L2431
	movzwl	36+hrdbf_app_state(%rip), %eax
	cmpq	%rax, %rdx
	jle	.L2432
.L2431:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2432:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.L2435:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get_name
	.def	hrdbfw_app_get_name;	.scl	2;	.type	32;	.endef
hrdbfw_app_get_name:
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2437
	movzwl	36+hrdbf_app_state(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.L2439
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.L2451:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2440:
	cmpb	$0, (%r10,%rax)
	je	.L2441
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2440
.L2441:
	cmpq	%r8, %rax
	je	.L2461
.L2443:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.L2451
.L2439:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2461:
	testq	%r8, %r8
	je	.L2444
	xorl	%ecx, %ecx
	jmp	.L2448
	.p2align 4,,10
	.p2align 3
.L2462:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.L2444
.L2448:
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
	je	.L2462
	cmpq	%rcx, %r8
	jne	.L2443
	.p2align 4,,10
	.p2align 3
.L2444:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.L2449
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
.L2449:
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
.L2437:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC108:
	.ascii "hbc: DBF field write requires a readonly=.F. open\12\0"
	.align 8
.LC109:
	.ascii "hbc: DBF field write with an open CDX index is outside this increment (NTX only)\12\0"
	.align 8
.LC110:
	.ascii "hbc: DBF field ordinal outside the open area\12\0"
	.align 8
.LC111:
	.ascii "hbc: DBF field write type mismatch\12\0"
	.align 8
.LC112:
	.ascii "hbc: DBF field write encoding rejected\12\0"
	.align 8
.LC113:
	.ascii "hbc: DBF field write commit failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_fieldput
	.def	hrdbfw_app_fieldput;	.scl	2;	.type	32;	.endef
hrdbfw_app_fieldput:
	pushq	%r12
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2529
	movl	32960+hrdbf_app_state(%rip), %r9d
	testl	%r9d, %r9d
	je	.L2530
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rbx
	movq	%rdx, %r9
	je	.L2466
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.L2531
.L2466:
	testq	%rbx, %rbx
	jle	.L2467
	movzwl	36+hrdbf_app_state(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r11
	cmpq	%rbx, %rax
	jl	.L2467
	movq	24+hrdbf_app_state(%rip), %r10
	leaq	1(%rbx), %rax
	leaq	-1(%rbx), %rsi
	movzbl	%r9b, %edi
	movzwl	34+hrdbf_app_state(%rip), %edx
	salq	$4, %rax
	leaq	-1(%r10), %rcx
	leaq	10(%r11,%rax), %r12
	addq	%r11, %rax
	imulq	%rdx, %rcx
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	%rdx, %rcx
	movzbl	21(%rax), %edx
	addq	32944+hrdbf_app_state(%rip), %rcx
	cmpb	$76, %dl
	je	.L2469
	ja	.L2470
	cmpb	$67, %dl
	je	.L2471
	cmpb	$68, %dl
	jne	.L2473
	cmpl	$11, %edi
	je	.L2532
	cmpl	$1, %edi
	jne	.L2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.L2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2493
	.p2align 4,,10
	.p2align 3
.L2533:
	addq	$1, %rax
.L2493:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2533
.L2478:
	movq	24+hrdbf_app_state(%rip), %r10
.L2482:
	movq	%r10, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2534
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2463
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.L2463
	movzwl	30+hrdbf_app_order(%rip), %eax
	addq	$1, %rax
	cmpq	%rbx, %rax
	je	.L2535
.L2463:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2470:
	cmpb	$78, %dl
	jne	.L2473
	cmpl	$12, %edi
	je	.L2536
	testl	%edi, %edi
	je	.L2502
	cmpl	$9, %edi
	je	.L2502
	cmpl	$5, %edi
	je	.L2537
	cmpl	$1, %edi
	jne	.L2473
	addq	$2, %rsi
	salq	$4, %rsi
	addq	%rsi, %r11
	movzbl	22(%r11), %edx
	movzwl	24(%r11), %eax
	testl	%edx, %edx
	je	.L2482
	addq	%rax, %rcx
	subl	$1, %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2491
	.p2align 4,,10
	.p2align 3
.L2538:
	addq	$1, %rax
.L2491:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2538
	jmp	.L2478
	.p2align 4,,10
	.p2align 3
.L2471:
	leal	-2(%rdi), %edx
	andl	$-3, %edx
	je	.L2539
	cmpl	$1, %edi
	jne	.L2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.L2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2483
	.p2align 4,,10
	.p2align 3
.L2540:
	addq	$1, %rax
.L2483:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2540
	jmp	.L2478
	.p2align 4,,10
	.p2align 3
.L2469:
	cmpl	$3, %edi
	je	.L2541
	cmpl	$1, %edi
	jne	.L2473
	movzbl	22(%rax), %r8d
	movzwl	24(%rax), %edx
	testl	%r8d, %r8d
	je	.L2482
	addq	%rdx, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2496
	.p2align 4,,10
	.p2align 3
.L2542:
	addq	$1, %rax
.L2496:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2542
	jmp	.L2478
	.p2align 4,,10
	.p2align 3
.L2541:
	cmpq	$1, %r8
	movzwl	24(%rax), %eax
	sbbl	%edx, %edx
	andl	$-14, %edx
	addl	$84, %edx
	movb	%dl, (%rcx,%rax)
	movq	24+hrdbf_app_state(%rip), %r10
	jmp	.L2482
	.p2align 4,,10
	.p2align 3
.L2536:
	movl	%r9d, %eax
	movq	%r12, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.L2485:
	cmpl	$3, %eax
	je	.L2473
	testl	%eax, %eax
	je	.L2478
	leaq	.LC112(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2539:
	movzwl	24(%rax), %edx
	addq	%rdx, %rcx
	movzbl	22(%rax), %edx
	cmpq	%rdx, -8(%r8)
	movq	%rdx, %rax
	cmovbe	-8(%r8), %rax
	testq	%rax, %rax
	je	.L2476
	movq	%rcx, %r9
	leaq	(%r8,%rax), %r10
	subq	%r8, %r9
	.p2align 4,,10
	.p2align 3
.L2477:
	movzbl	(%r8), %edx
	movb	%dl, (%r9,%r8)
	addq	$1, %r8
	cmpq	%r10, %r8
	jne	.L2477
	movq	%rsi, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r11), %edx
.L2476:
	cmpq	%rax, %rdx
	jbe	.L2478
	leaq	2(%rsi), %rdx
	salq	$4, %rdx
	addq	%rdx, %r11
	.p2align 4,,10
	.p2align 3
.L2479:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r11), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2479
	jmp	.L2478
	.p2align 4,,10
	.p2align 3
.L2532:
	movq	%r12, %rdx
	call	hrdbf_write_date
	jmp	.L2485
.L2473:
	leaq	.LC111(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2502:
	xorl	%r9d, %r9d
	movq	%r12, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2485
	.p2align 4,,10
	.p2align 3
.L2535:
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%r12
	jmp	hrdbf_app_rebuild_index
	.p2align 4,,10
	.p2align 3
.L2537:
	testq	%r9, %r9
	jns	.L2489
	movq	(%r8), %r8
.L2489:
	movq	%r8, %xmm2
	movq	%r12, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.L2485
.L2467:
	leaq	.LC110(%rip), %rcx
	call	hrdbf_app_fail
.L2529:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2530:
	leaq	.LC108(%rip), %rcx
	call	hrdbf_app_fail
.L2531:
	leaq	.LC109(%rip), %rcx
	call	hrdbf_app_fail
.L2534:
	leaq	.LC113(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC114:
	.ascii "hbc: DBF delete/recall requires a readonly=.F. open\12\0"
	.align 8
.LC115:
	.ascii "hbc: DBF delete/recall with an open CDX index is outside this increment (NTX only)\12\0"
	.align 8
.LC116:
	.ascii "hbc: DBF delete commit failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_delete
	.def	hrdbfw_app_delete;	.scl	2;	.type	32;	.endef
hrdbfw_app_delete:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2551
	movl	32960+hrdbf_app_state(%rip), %ecx
	testl	%ecx, %ecx
	je	.L2552
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2546
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.L2553
.L2546:
	movq	24+hrdbf_app_state(%rip), %rax
	movl	16+hrdbf_app_state(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.L2554
.L2543:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2554:
	movzwl	34+hrdbf_app_state(%rip), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	32944+hrdbf_app_state(%rip), %rax
	movb	$42, (%rax,%rdx)
	movl	32960+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L2549
	cmpq	$0, 32968+hrdbf_app_state(%rip)
	je	.L2549
	cmpb	$0, 40+hrdbf_app_state(%rip)
	movq	24+hrdbf_app_state(%rip), %rax
	je	.L2549
	testq	%rax, %rax
	je	.L2549
	movl	16+hrdbf_app_state(%rip), %edx
	cmpq	%rdx, %rax
	ja	.L2549
	leaq	-1(%rax), %rdx
	movzwl	34+hrdbf_app_state(%rip), %r9d
	movq	32944+hrdbf_app_state(%rip), %r8
	leaq	hrdbf_app_state(%rip), %rcx
	movq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	imulq	%r9, %rax
	addq	%rax, %rdx
	addq	%rdx, %r8
	call	write_at
	testl	%eax, %eax
	je	.L2543
	.p2align 4,,10
	.p2align 3
.L2549:
	leaq	.LC116(%rip), %rcx
	call	hrdbf_app_fail
.L2551:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2552:
	leaq	.LC114(%rip), %rcx
	call	hrdbf_app_fail
.L2553:
	leaq	.LC115(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC117:
	.ascii "hbc: DBF recall commit failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_recall
	.def	hrdbfw_app_recall;	.scl	2;	.type	32;	.endef
hrdbfw_app_recall:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2563
	movl	32960+hrdbf_app_state(%rip), %ecx
	testl	%ecx, %ecx
	je	.L2564
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2558
	movl	hrdbf_app_cdx(%rip), %edx
	testl	%edx, %edx
	jne	.L2565
.L2558:
	movq	24+hrdbf_app_state(%rip), %rax
	movl	16+hrdbf_app_state(%rip), %edx
	cmpq	%rdx, %rax
	jbe	.L2566
.L2555:
	addq	$40, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2566:
	movzwl	34+hrdbf_app_state(%rip), %edx
	subq	$1, %rax
	imulq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	32944+hrdbf_app_state(%rip), %rax
	movb	$32, (%rax,%rdx)
	movl	32960+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L2561
	cmpq	$0, 32968+hrdbf_app_state(%rip)
	je	.L2561
	cmpb	$0, 40+hrdbf_app_state(%rip)
	movq	24+hrdbf_app_state(%rip), %rax
	je	.L2561
	testq	%rax, %rax
	je	.L2561
	movl	16+hrdbf_app_state(%rip), %edx
	cmpq	%rdx, %rax
	ja	.L2561
	leaq	-1(%rax), %rdx
	movzwl	34+hrdbf_app_state(%rip), %r9d
	movq	32944+hrdbf_app_state(%rip), %r8
	leaq	hrdbf_app_state(%rip), %rcx
	movq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	imulq	%r9, %rax
	addq	%rax, %rdx
	addq	%rdx, %r8
	call	write_at
	testl	%eax, %eax
	je	.L2555
	.p2align 4,,10
	.p2align 3
.L2561:
	leaq	.LC117(%rip), %rcx
	call	hrdbf_app_fail
.L2563:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2564:
	leaq	.LC114(%rip), %rcx
	call	hrdbf_app_fail
.L2565:
	leaq	.LC115(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_commit
	.def	hrdbfw_app_commit;	.scl	2;	.type	32;	.endef
hrdbfw_app_commit:
	ret
	.p2align 4
	.globl	hrdbfw_app_set_name
	.def	hrdbfw_app_set_name;	.scl	2;	.type	32;	.endef
hrdbfw_app_set_name:
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	subq	$32, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2594
	movl	32960+hrdbf_app_state(%rip), %r10d
	testl	%r10d, %r10d
	je	.L2595
	movq	%rcx, %r13
	movq	%rdx, %r12
	movq	%r8, %r14
	movq	%r9, %rsi
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2574
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.L2596
.L2574:
	movzwl	36+hrdbf_app_state(%rip), %ebx
	testl	%ebx, %ebx
	je	.L2573
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L2584:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2575:
	cmpb	$0, (%r10,%rax)
	je	.L2576
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2575
.L2576:
	cmpq	%rax, %r12
	je	.L2597
.L2578:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.L2584
.L2573:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2597:
	testq	%r12, %r12
	je	.L2579
	xorl	%ecx, %ecx
	jmp	.L2583
	.p2align 4,,10
	.p2align 3
.L2598:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.L2579
.L2583:
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
	je	.L2598
	cmpq	%rcx, %r12
	jne	.L2578
.L2579:
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
.L2596:
	leaq	.LC109(%rip), %rcx
	call	hrdbf_app_fail
.L2595:
	leaq	.LC108(%rip), %rcx
	call	hrdbf_app_fail
.L2594:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC118:
	.ascii "hbc: DBF append failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_append
	.def	hrdbfw_app_append;	.scl	2;	.type	32;	.endef
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2606
	movl	32960+hrdbf_app_state(%rip), %edx
	testl	%edx, %edx
	je	.L2607
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2602
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	jne	.L2608
.L2602:
	cmpq	$0, 32968+hrdbf_app_state(%rip)
	je	.L2604
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2604
	movl	$0, hrdbf_app_found_flag(%rip)
	call	hrdbf_app_rebuild_index
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2604:
	leaq	.LC118(%rip), %rcx
	call	hrdbf_app_fail
.L2606:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_fail
.L2607:
	leaq	.LC108(%rip), %rcx
	call	hrdbf_app_fail
.L2608:
	leaq	.LC109(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC119:
	.ascii "hbc: DBF scalar render rejected\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_render
	.def	hrdbfw_app_render;	.scl	2;	.type	32;	.endef
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
	jne	.L2612
	movq	56(%rsp), %rax
	leave
	ret
.L2612:
	leaq	.LC119(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC120:
	.ascii "hbc: DBF decimal numeric cannot enter I64 operation\12\0"
	.align 8
.LC121:
	.ascii "hbc: DBF scalar cannot enter I64 operation\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_integer
	.def	hrdbfw_app_integer;	.scl	2;	.type	32;	.endef
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
	jne	.L2614
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L2630
	testl	%eax, %eax
	je	.L2622
	cmpl	$9, %eax
	jne	.L2618
.L2622:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2630:
	testl	$65280, %r11d
	je	.L2622
.L2617:
	leaq	.LC120(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2614:
	cmpl	$2, %eax
	je	.L2617
.L2618:
	leaq	.LC121(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC122:
	.ascii "hbc: DBF scalar comparison is outside this increment\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_equal
	.def	hrdbfw_app_equal;	.scl	2;	.type	32;	.endef
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
	jne	.L2634
	movslq	76(%rsp), %rax
	leave
	ret
.L2634:
	leaq	.LC122(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC123:
	.ascii "hbc: DBF invalid Date comparison\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_compare
	.def	hrdbfw_app_compare;	.scl	2;	.type	32;	.endef
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
	jne	.L2636
	cmpb	$11, %r8b
	je	.L2643
.L2636:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2644
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L2643:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2638
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2638
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
.L2644:
	leaq	.LC122(%rip), %rcx
	call	hrdbf_app_fail
.L2638:
	leaq	.LC123(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC124:
	.ascii "hbc: DBF scalar Empty rejected\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_empty
	.def	hrdbfw_app_empty;	.scl	2;	.type	32;	.endef
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
	jne	.L2646
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.L2657
	movabsq	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.L2648
	.p2align 4,,10
	.p2align 3
.L2665:
	btq	%rax, %rcx
	jnc	.L2661
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.L2657
.L2648:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.L2665
.L2661:
	xorl	%eax, %eax
.L2645:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2646:
	cmpl	$8, %ebx
	je	.L2666
	cmpl	$5, %ebx
	je	.L2667
	cmpl	$7, %ebx
	je	.L2661
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2653
	cmpl	$12, %ebx
	ja	.L2653
	movl	$1, %eax
	movl	%ebx, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.L2654
	testb	$2, %al
	jne	.L2657
.L2653:
	leaq	.LC124(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2657:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2666:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.L2645
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.L2645
	.p2align 4,,10
	.p2align 3
.L2667:
	testq	%rcx, %rcx
	js	.L2668
.L2652:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.LC65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.L2645
.L2668:
	movq	(%rdx), %r11
	jmp	.L2652
.L2654:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.L2645
	.section .rdata,"dr"
	.align 8
.LC125:
	.ascii "hbc: DBF arithmetic division by zero\12\0"
	.align 8
.LC126:
	.ascii "hbc: DBF arithmetic on a NIL or non-numeric operand\12\0"
.LC127:
	.ascii "hbc: DBF arithmetic rejected\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_arith
	.def	hrdbfw_app_arith;	.scl	2;	.type	32;	.endef
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
	je	.L2674
	cmpl	$1, %eax
	je	.L2675
	testl	%eax, %eax
	jne	.L2676
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.L2674:
	leaq	.LC125(%rip), %rcx
	call	hrdbf_app_fail
.L2676:
	leaq	.LC127(%rip), %rcx
	call	hrdbf_app_fail
.L2675:
	leaq	.LC126(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC128:
	.ascii "hbc: DBF-active dynamic scalar consumer is outside the admitted subset\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
	.def	hrdbfw_app_unsupported;	.scl	2;	.type	32;	.endef
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.LC128(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
CSWTCH.413:
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
days.0:
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
days.1:
	.ascii "\37\34\37\36\37\36\37\37\36\37\36\37"
	.align 32
hrdbf_app_pre_field:
	.ascii "hbc: DBF field not found in the open area: \0"
.lcomm hrdbf_app_shared,4,4
.lcomm hrdbf_app_struct,4,4
.lcomm hrdbf_app_ntxpath,260,32
.lcomm hrdbf_app_baselen,8,8
.lcomm hrdbf_app_basename,260,32
.lcomm hrdbf_app_cdx,4,4
.lcomm hrdbf_app_order_active,4,4
.lcomm hrdbf_app_found_flag,4,4
.lcomm hrdbf_app_pos,8,8
.lcomm hrdbf_app_order,80,32
.lcomm hrdbf_app_state,33136,32
.lcomm fsink_len,4,4
.lcomm fsink,160,32
.lcomm hrdbf_open_tmp,32944,32
	.align 8
.LC0:
	.long	0
	.long	1076101120
	.align 8
.LC65:
	.long	0
	.long	0
	.align 8
.LC105:
	.long	-798530048
	.long	1138748221
	.align 8
.LC106:
	.long	-798530048
	.long	-1008735427
	.align 8
.LC107:
	.long	0
	.long	1071644672
