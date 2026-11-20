	.file	"hrdbf_embedded_windows.c"
	.text
	.p2align 4
	.def	dset;	.scl	3;	.type	32;	.endef
dset:
	leaq	2090(%rcx), %rax
	leaq	2249(%rcx), %r8
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
	leaq	2090(%rcx), %rax
	addq	$2249, %rcx
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
	jne	.L222
	movl	%esi, %ecx
	subl	$1, %ecx
	cmpb	$5, %cl
	jbe	.L224
.L222:
	movl	$1, %eax
.L216:
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
.L224:
	movl	%ebx, %r9d
	addl	%edx, %ebx
	movl	%r15d, %r11d
	movl	$1, %eax
	addl	%ebx, %r15d
	leal	0(,%rsi,8), %ecx
	cmpl	%ecx, %r15d
	jne	.L216
	movl	$1, %r8d
	movl	%edx, %ecx
	salq	%cl, %r8
	subl	$1, %r8d
	cmpl	%edi, %r8d
	jne	.L216
	movl	%eax, %edx
	movl	%r9d, %ecx
	sall	%cl, %edx
	subl	$1, %edx
	cmpl	%edx, %ebp
	jne	.L216
	movl	%r11d, %ecx
	sall	%cl, %eax
	subl	$1, %eax
	cmpl	%r13d, %eax
	setne	%dl
	cmpl	%r10d, %ebp
	setb	%al
	orb	%al, %dl
	jne	.L222
	cmpl	%r10d, %r13d
	jb	.L222
	xorl	%edx, %edx
	movl	$488, %eax
	divl	%esi
	cmpl	%eax, %r14d
	seta	%al
	cmpw	$488, %r12w
	seta	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.L216
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
	je	.L226
	movl	%r8d, %ecx
	xorl	%r10d, %r10d
	imull	%edx, %ecx
	leal	24(%rcx), %eax
	leal	24(%rcx,%rdx), %r12d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L227:
	movl	%eax, %edx
	addl	$1, %eax
	movzbl	(%r11,%rdx), %edx
	salq	%cl, %rdx
	addl	$8, %ecx
	orq	%rdx, %r10
	cmpl	%r12d, %eax
	jne	.L227
	movq	96(%rsp), %rax
	andl	%r10d, %ebp
	movq	%r10, %rdx
	movl	%ebp, (%rax)
	movl	4(%rbx), %ecx
	shrq	%cl, %rdx
	andl	24(%rbx), %edx
	testl	%r8d, %r8d
	jne	.L228
	testl	%edx, %edx
	je	.L228
.L230:
	popq	%rbx
	movl	$1, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L228:
	addl	8(%rbx), %ecx
	shrq	%cl, %r10
	andl	28(%rbx), %r10d
	leal	(%rdx,%r10), %eax
	cmpl	%eax, %r9d
	jb	.L230
.L236:
	movl	%r9d, %r8d
	movq	(%rsi), %rcx
	subl	%eax, %r8d
	movl	%r8d, %ebp
	cmpq	%rbp, %rcx
	jb	.L230
	movzwl	(%rbx), %eax
	movl	16(%rbx), %ebx
	subq	%rbp, %rcx
	imulq	%rbx, %rax
	addq	$24, %rax
	cmpq	%rax, %rcx
	jb	.L230
	movq	%rcx, (%rsi)
	testl	%r8d, %r8d
	je	.L231
	xorl	%eax, %eax
	jmp	.L232
	.p2align 4,,10
	.p2align 3
.L249:
	movq	(%rsi), %rcx
.L232:
	leaq	(%r11,%rax), %r8
	movzbl	(%r8,%rcx), %r8d
	leal	(%rdx,%rax), %ecx
	addq	$1, %rax
	movb	%r8b, (%rdi,%rcx)
	cmpq	%rax, %rbp
	jne	.L249
.L231:
	movl	%r9d, %eax
	subl	%r10d, %eax
	cmpl	%eax, %r9d
	jbe	.L235
	movl	%eax, %edx
	leal	-1(%r10), %ecx
	leaq	(%rdi,%rdx), %rax
	leaq	1(%rdi,%rdx), %rdx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L234:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L234
.L235:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L226:
	movq	96(%rsp), %rax
	xorl	%r10d, %r10d
	movl	$0, (%rax)
	xorl	%eax, %eax
	jmp	.L236
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
	je	.L253
	cmpl	$1023, %edx
	ja	.L304
.L253:
	movl	$1, %r12d
.L250:
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
.L304:
	movl	%edx, %ebp
	andl	$511, %ebp
	jne	.L253
	movq	8(%rcx), %rax
	movl	%edx, %esi
	movq	%rcx, %rbx
	subq	$512, %rax
	cmpq	%rsi, %rax
	jb	.L253
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
	jne	.L253
	orl	%r9d, %ecx
	movb	%cl, (%rax)
	addq	(%rbx), %rsi
	xorl	%ecx, %ecx
	testl	%r8d, %r8d
	movzwl	(%rsi), %eax
	sete	%cl
	movl	%eax, %r9d
	cmpl	%eax, %ecx
	je	.L254
	cmpl	$1, %r8d
	movl	$2, %ecx
	adcl	$0, %ecx
	cmpl	%eax, %ecx
	jne	.L253
.L254:
	movl	%r8d, %eax
	movl	4(%rsi), %r10d
	leaq	(%rbx,%rax,4), %rax
	movl	56(%rax), %ecx
	testl	%ecx, %ecx
	je	.L305
	cmpl	%r10d, %ecx
	jne	.L253
	cmpl	%edx, 312(%rax)
	jne	.L253
.L276:
	movl	8(%rsi), %ecx
	cmpl	$-1, %ecx
	je	.L258
	cmpl	$1023, %ecx
	jbe	.L253
	testl	$511, %ecx
	jne	.L253
	movq	8(%rbx), %rdi
	movl	%ecx, %r11d
	leaq	-512(%rdi), %r10
	cmpq	%r10, %r11
	ja	.L253
.L258:
	movzwl	2(%rsi), %r13d
	andl	$2, %r9d
	movl	%edx, 56(%rax)
	movl	%ecx, 312(%rax)
	movq	%r13, %rdi
	je	.L259
	movl	52(%rbx), %eax
	testl	%eax, %eax
	js	.L306
	cmpl	%r8d, %eax
	jne	.L253
.L261:
	movq	24(%rbx), %rax
	leaq	112(%rsp), %r15
	movq	%rsi, %rcx
	movq	%r15, %r8
	movzwl	28(%rax), %edx
	call	cxleaf_header
	movl	%eax, %r12d
	testl	%eax, %eax
	jne	.L250
	testl	%r13d, %r13d
	je	.L271
	leaq	100(%rsp), %rax
	movw	%di, 94(%rsp)
	movq	24(%rbx), %r14
	leaq	144(%rsp), %rbp
	movq	%rax, 72(%rsp)
	leaq	104(%rsp), %rax
	movq	%rax, 80(%rsp)
.L262:
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
	jne	.L281
	movl	100(%rsp), %eax
	testl	%eax, %eax
	je	.L264
	movq	16(%rbx), %rdx
	movl	16(%rdx), %edx
	cmpl	%edx, %eax
	ja	.L264
	cmpl	48(%rbx), %edx
	jbe	.L264
	subl	$1, %eax
	movl	$1, %edi
	movl	%eax, %ecx
	shrl	$3, %eax
	addq	40(%rbx), %rax
	andl	$7, %ecx
	movzbl	(%rax), %edx
	sall	%cl, %edi
	testb	%dil, %dl
	jne	.L264
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
	je	.L265
	xorl	%eax, %eax
	leaq	(%r10,%rdx), %r8
	jmp	.L266
.L308:
	leaq	1(%rax), %rdx
	cmpq	%rdx, %rcx
	je	.L307
	movq	%rdx, %rax
.L266:
	movzbl	(%r8,%rax), %edi
	cmpb	%dil, 0(%rbp,%rax)
	je	.L308
.L264:
	movl	$4, %r12d
	jmp	.L250
	.p2align 4,,10
	.p2align 3
.L305:
	cmpl	$-1, %r10d
	jne	.L253
	jmp	.L276
.L259:
	testl	%r13d, %r13d
	je	.L253
	movq	24(%rbx), %rax
	xorl	%edx, %edx
	movzwl	28(%rax), %ecx
	movl	$500, %eax
	leal	8(%rcx), %r10d
	divl	%r10d
	cmpl	%r13d, %eax
	jb	.L253
	movl	48(%rbx), %r9d
	movzwl	%cx, %edx
	leal	1(%r8), %r15d
	movl	%ecx, %eax
.L274:
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
	jne	.L250
	movl	48(%rbx), %r9d
	cmpl	%r14d, %r9d
	je	.L253
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
	jne	.L253
	movq	16(%rbx), %rax
	movq	(%rax), %r10
	testq	%rdx, %rdx
	je	.L272
	xorl	%eax, %eax
	addq	%r10, %rcx
	jmp	.L273
	.p2align 4,,10
	.p2align 3
.L309:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L272
.L273:
	movzbl	(%rcx,%rax), %r11d
	cmpb	%r11b, (%rdi,%rax)
	je	.L309
	jmp	.L253
.L306:
	movl	%r8d, 52(%rbx)
	jmp	.L261
.L272:
	addl	$1, %ebp
	cmpl	%ebp, %r13d
	je	.L250
	movzwl	%r8w, %eax
	jmp	.L274
.L307:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	jne	.L279
.L303:
	movq	16(%r14), %rcx
.L269:
	movl	%edx, %eax
	movl	88(%rsp), %edi
	addl	$1, %edx
	addl	$1, %r12d
	leaq	(%rcx,%rax,8), %rax
	movl	%r9d, (%rax)
	movl	%edi, 4(%rax)
	movl	%edx, 48(%rbx)
	cmpl	%r12d, %r13d
	jne	.L262
	movzwl	94(%rsp), %edi
.L271:
	movl	128(%rsp), %edx
	movq	104(%rsp), %rax
	xorl	%r12d, %r12d
	imulq	%rdi, %rdx
	subq	$24, %rax
	subq	%rdx, %rax
	movzwl	114(%rsp), %edx
	cmpq	%rdx, %rax
	setne	%r12b
	jmp	.L250
.L279:
	movq	16(%r14), %rcx
	leal	-1(%rdx), %r8d
	leaq	(%rcx,%r8,8), %r8
	movl	4(%r8), %r11d
	movl	(%r8), %edi
	xorl	%r8d, %r8d
	addq	%r11, %r10
	jmp	.L270
.L268:
	leaq	1(%r8), %r11
	cmpq	%rax, %r8
	je	.L277
	movq	%r11, %r8
.L270:
	movzbl	0(%rbp,%r8), %r11d
	cmpb	%r11b, (%r10,%r8)
	je	.L268
	jb	.L269
	jmp	.L253
.L265:
	movl	48(%rbx), %edx
	testl	%edx, %edx
	je	.L303
	movq	16(%r14), %rcx
	leal	-1(%rdx), %eax
	movl	(%rcx,%rax,8), %edi
.L277:
	cmpl	%edi, %r9d
	ja	.L269
	jmp	.L253
.L281:
	movl	%eax, %r12d
	jmp	.L250
	.p2align 4
	.def	cxheader;	.scl	3;	.type	32;	.endef
cxheader:
	movzbl	14(%rcx), %r9d
	movl	$2, %eax
	cmpl	%edx, %r9d
	jne	.L310
	cmpb	$1, 15(%rcx)
	jne	.L310
	cmpw	$1024, 16(%rcx)
	jne	.L310
	cmpw	$512, 18(%rcx)
	jne	.L310
	cmpw	$0, 502(%rcx)
	jne	.L310
	movl	%r8d, %edx
	movl	$20, %eax
	xorl	$1, %edx
	andl	$1, %edx
	jmp	.L313
	.p2align 4,,10
	.p2align 3
.L333:
	cmpl	$23, %eax
	ja	.L320
.L312:
	addq	$1, %rax
	cmpq	$502, %rax
	je	.L332
.L313:
	cmpb	$0, (%rcx,%rax)
	je	.L312
	testb	%dl, %dl
	je	.L333
.L320:
	movl	$2, %eax
.L310:
	ret
.L332:
	testl	%r8d, %r8d
	je	.L314
	cmpb	$82, 20(%rcx)
	movl	$2, %eax
	jne	.L310
	cmpb	$67, 21(%rcx)
	jne	.L310
	cmpb	$72, 22(%rcx)
	jne	.L310
	cmpb	$66, 23(%rcx)
	jne	.L310
.L314:
	cmpw	$1, 506(%rcx)
	movl	$2, %eax
	jne	.L310
	movzwl	504(%rcx), %edx
	cmpw	%dx, 510(%rcx)
	jne	.L310
	xorl	%eax, %eax
	cmpw	$0, 508(%rcx)
	setne	%al
	addl	%eax, %eax
	ret
	.p2align 4
	.def	hrdbf_app_write;	.scl	3;	.type	32;	.endef
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.L335
	.p2align 4,,10
	.p2align 3
.L336:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.L336
.L335:
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
	movq	2280(%rcx), %rcx
	call	*__imp_SetFilePointerEx(%rip)
	testl	%eax, %eax
	je	.L343
	movq	__imp_WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.L344
	jmp	.L345
	.p2align 4,,10
	.p2align 3
.L356:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.L343
	cmpq	%rax, %rbx
	jb	.L343
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.L345
.L344:
	movq	2280(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.L356
.L343:
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
.L345:
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
	ja	.L357
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.L437
	cmpb	$78, %r9b
	je	.L438
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.L439
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.L384
	cmpb	$89, %al
	je	.L384
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.L357
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.L357
	movabsq	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.L357:
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
.L384:
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
.L438:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.L361
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.L362
	.p2align 4,,10
	.p2align 3
.L363:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.L361
.L362:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.L363
	jmp	.L365
	.p2align 4,,10
	.p2align 3
.L389:
	movl	%r9d, %ecx
.L365:
	cmpl	%eax, %ecx
	jbe	.L364
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.L389
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.L367
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.L387:
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
	jmp	.L371
	.p2align 4,,10
	.p2align 3
.L441:
	testl	%esi, %esi
	jne	.L408
	movl	$1, %esi
.L369:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.L440
.L371:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.L441
.L408:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L401
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.L398
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.L369
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.L369
	.p2align 4,,10
	.p2align 3
.L437:
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
.L439:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.L380:
	cmpb	$32, (%rax)
	jne	.L400
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.L380
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L357
	.p2align 4,,10
	.p2align 3
.L401:
	movl	$5, %r11d
	jmp	.L357
	.p2align 4,,10
	.p2align 3
.L400:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L379:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.L401
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.L379
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
	jbe	.L357
	cmpl	$11, %edx
	ja	.L357
	testl	%r10d, %r10d
	je	.L357
	leaq	days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.L442
.L382:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.L357
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L357
	.p2align 4,,10
	.p2align 3
.L367:
	movabsq	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.L368:
	cmpl	%eax, %ecx
	jbe	.L401
	leal	-1(%rcx), %r9d
	jmp	.L387
	.p2align 4,,10
	.p2align 3
.L398:
	movl	$4, %r11d
	jmp	.L357
	.p2align 4,,10
	.p2align 3
.L440:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.L357
	cmpl	%ebp, %r10d
	jb	.L357
	leal	1(%rbp), %eax
	jbe	.L372
	movabsq	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.L373
	jmp	.L398
	.p2align 4,,10
	.p2align 3
.L374:
	cmpq	%rcx, %rbx
	ja	.L398
.L373:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.L374
	testl	%r12d, %r12d
	jne	.L386
.L377:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L357
.L364:
	je	.L361
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.L367
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.L368
	.p2align 4,,10
	.p2align 3
.L361:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L357
.L442:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.L382
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.L383
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L382
.L383:
	addl	$1, %edx
	jmp	.L382
.L372:
	testl	%r12d, %r12d
	je	.L377
	movabsq	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.L377
.L386:
	negq	%rbx
	jmp	.L377
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
	je	.L446
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L458
.L446:
	xorl	%r12d, %r12d
.L445:
	movq	32+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L447
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L459
	movl	$7, %r12d
.L447:
	movq	40+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L443
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L450
	movq	$0, 40+hrdbf_app_order(%rip)
	movq	$0, 56+hrdbf_app_order(%rip)
.L443:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L459:
	movq	$0, 32+hrdbf_app_order(%rip)
	movq	$0, 48+hrdbf_app_order(%rip)
	jmp	.L447
	.p2align 4,,10
	.p2align 3
.L458:
	movl	$7, %r12d
	jmp	.L445
	.p2align 4,,10
	.p2align 3
.L450:
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
	jne	.L460
	orl	%ecx, %eax
	movb	%al, (%rdx)
.L460:
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
	ja	.L466
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.L466
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.L466
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.L466
	cmpb	$0, 40(%r9)
	je	.L466
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	cxheader
	testl	%eax, %eax
	jne	.L462
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.L462
	cmpw	$1, 510(%rdi)
	jne	.L462
	cmpb	$0, 512(%rdi)
	jne	.L462
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.L466
	testl	$511, %r12d
	jne	.L466
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.L466
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.L462
	cmpw	$1, 2(%rdi,%rdx)
	jne	.L462
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.L466
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.L466
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L462
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
	jne	.L462
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L466
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.L466
	testl	$511, %eax
	jne	.L466
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.L466
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.L466
	cmpl	%r12d, %eax
	je	.L466
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.L466
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L467
.L540:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.L504
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L539
.L467:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L540
.L504:
	movl	$2, %eax
	jmp	.L462
	.p2align 4,,10
	.p2align 3
.L466:
	movl	$1, %eax
.L462:
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
.L539:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	cxheader
	testl	%eax, %eax
	jne	.L462
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L504
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.L504
	cmpb	$0, (%rdi,%rcx)
	jne	.L504
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.L468:
	cmpb	$0, (%r14,%rcx)
	je	.L504
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L468
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.L469:
	cmpq	%r9, %r8
	jbe	.L504
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.L478:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.L472
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.L473
	subl	$32, %ecx
.L473:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.L474
	subl	$32, %r13d
.L474:
	cmpb	%cl, %r13b
	jne	.L472
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L470
	cmpq	$11, %rdx
	jne	.L478
	cmpq	$11, %rax
	jne	.L472
.L476:
	cmpl	%r9d, 72(%rsp)
	je	.L504
	cmpb	$67, 53(%r10)
	jne	.L504
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.L503
	cmpw	12(%rdi,%r11), %ax
	jne	.L504
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.L508
	cmpq	$0, 1072(%rsp)
	jne	.L510
	testl	%eax, %eax
	jne	.L508
.L510:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.L508
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.L508
	xorl	%edx, %edx
.L480:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L480
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L481
	orl	$1, %eax
	movb	%al, (%rcx)
.L481:
	testb	$2, %al
	jne	.L482
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L482:
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
.L483:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L483
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	cxvisit
	testl	%eax, %eax
	je	.L541
.L484:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L462
.L470:
	cmpq	$11, %rax
	je	.L476
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L476
.L472:
	addq	$1, %r9
	jmp	.L469
.L508:
	movl	$3, %eax
	jmp	.L462
.L503:
	movl	$5, %eax
	jmp	.L462
.L541:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.L484
	xorl	%edx, %edx
	jmp	.L486
.L542:
	cmpq	$63, %rdx
	ja	.L511
.L486:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.L485
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.L485:
	addq	$1, %rdx
	testb	$1, %al
	je	.L542
.L511:
	testl	%eax, %eax
	jne	.L484
	movl	%ecx, 24(%rbx)
	jmp	.L462
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
	cmpq	$67108864, %rbp
	ja	.L543
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, %r13
	testq	%rax, %rax
	je	.L551
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.L548
	.p2align 4,,10
	.p2align 3
.L545:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.L545
.L548:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.L547
	.p2align 4,,10
	.p2align 3
.L546:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L546
	addq	%r14, %rdx
.L547:
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
	je	.L563
.L549:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*__imp_VirtualFree(%rip)
.L543:
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
.L563:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L549
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L549
	xorl	%edx, %edx
	movq	2256(%rbx), %rcx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L554
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
	jmp	.L543
	.p2align 4,,10
	.p2align 3
.L551:
	movl	$8, %r15d
	jmp	.L543
.L554:
	movl	$7, %r15d
	jmp	.L549
	.p2align 4
	.def	put_number.isra.0;	.scl	3;	.type	32;	.endef
put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.L564
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.L585
	subl	%r10d, %edx
	je	.L570
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.L571:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.L571
.L570:
	testl	%r10d, %r10d
	je	.L569
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.L572:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.L572
.L569:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L564:
	ret
	.p2align 4,,10
	.p2align 3
.L585:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.L569
	.p2align 4,,10
	.p2align 3
.L568:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.L569
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.L568
	jmp	.L569
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
	ja	.L586
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.L612
	cmpb	%r8b, %r13b
	jnb	.L612
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.L588
	negq	%rcx
	movl	$1, %r11d
.L588:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.L589
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.L590
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L591:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.L591
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq	%r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.L592
.L590:
	addq	$1, %rcx
.L592:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabsq	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.L597:
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
	ja	.L597
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
	ja	.L640
	testl	%r11d, %r11d
	je	.L603
	movb	$45, 96(%rsp)
.L603:
	cmpl	%r10d, %ebp
	jb	.L641
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.L605:
	testb	%r13b, %r13b
	je	.L607
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.L608
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L609:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.L609
	addl	%ebp, %eax
.L608:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.L610:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.L610
.L607:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	put_number.isra.0
.L586:
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
.L612:
	movl	$4, %eax
	jmp	.L586
	.p2align 4,,10
	.p2align 3
.L589:
	jnb	.L592
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.L592
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.L593
	xorl	%eax, %eax
	jmp	.L594
	.p2align 4,,10
	.p2align 3
.L596:
	cmpq	%rdx, %rcx
	ja	.L593
.L594:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.L596
	jmp	.L592
	.p2align 4,,10
	.p2align 3
.L641:
	testl	%r14d, %r14d
	je	.L616
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.L606
	.p2align 4,,10
	.p2align 3
.L642:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.L606:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.L642
	jmp	.L605
	.p2align 4,,10
	.p2align 3
.L640:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L601:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L601
	xorl	%eax, %eax
	jmp	.L586
	.p2align 4,,10
	.p2align 3
.L593:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.L595:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.L595
	xorl	%eax, %eax
	jmp	.L586
.L616:
	movl	%r11d, %edx
	jmp	.L605
	.p2align 4
	.def	bn_shr_round;	.scl	3;	.type	32;	.endef
bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.L692
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.L695
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.L651
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.L653
.L652:
	xorl	%ecx, %ecx
	jmp	.L656
	.p2align 4,,10
	.p2align 3
.L655:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.L696
	movl	%eax, %ecx
.L656:
	cmpl	%ecx, %r10d
	jbe	.L655
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L655
.L654:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.L653
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.L661
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.L660:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.L660
.L661:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.L653
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L662:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L662
.L653:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.L643
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.L663
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.L664:
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
	jne	.L664
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.L643
	movl	%edi, 288(%r9)
	jmp	.L643
	.p2align 4,,10
	.p2align 3
.L695:
	testl	%r10d, %r10d
	je	.L646
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L648:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.L648
	testl	%eax, %eax
	je	.L646
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L649:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.L649
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.L646
	jne	.L671
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.L646
.L671:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.L646:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.L643:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L692:
	ret
	.p2align 4,,10
	.p2align 3
.L651:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.L652
	jmp	.L654
	.p2align 4,,10
	.p2align 3
.L696:
	xorl	%eax, %eax
	jmp	.L654
.L663:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.L643
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
.L698:
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
	jbe	.L706
	cmpl	$19, %r10d
	jbe	.L698
.L706:
	leaq	fsink(%rip), %rbx
	movl	fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.L704:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.L700
	jmp	.L701
	.p2align 4,,10
	.p2align 3
.L702:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.L701
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.L700:
	testb	%cl, %cl
	jne	.L702
.L701:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.L697
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L704
	.p2align 4,,10
	.p2align 3
.L697:
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
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
	je	.L721
	movabsq	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.L959
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.L719:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.L724:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L725:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.L725
	testq	%rax, %rax
	je	.L726
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.L726:
	subl	$1, %r9d
	jne	.L724
	testb	%r11b, %r11b
	je	.L728
	movl	%r10d, 352(%rsp)
.L728:
	testl	%r12d, %r12d
	js	.L729
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	bn_shl
.L956:
	movl	352(%rsp), %eax
.L732:
	xorl	%ebx, %ebx
	jmp	.L730
	.p2align 4,,10
	.p2align 3
.L735:
	cmpq	$80, %rbx
	je	.L960
	movq	%rdi, %rcx
	call	bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.L730:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.L735
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.L735
	testl	%ebx, %ebx
	jne	.L961
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.L720
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.L962
.L721:
	xorl	%eax, %eax
.L713:
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
.L959:
	testq	%rax, %rax
	jne	.L963
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.L720
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.L721
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L723:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L723
	jmp	.L713
.L720:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.L721
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.L713
.L963:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.L719
.L729:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	bn_shr_round
	cmpl	$1, %eax
	jbe	.L956
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.L828
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.L734:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.L734
	testq	%rdx, %rdx
	je	.L732
	leal	1(%rax), %edx
.L733:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.L732
.L960:
	movl	$79, %r10d
.L738:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.L742:
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
	ja	.L742
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.L744
.L964:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L744:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.L964
	testl	%r10d, %r10d
	je	.L745
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.L747:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.L746:
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
	jne	.L746
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.L965
	movq	%rax, %rbp
	jmp	.L747
.L965:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.L745:
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
.L749:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L750:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L750
	testq	%rax, %rax
	je	.L751
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.L751:
	subl	$1, %r9d
	jne	.L749
	testb	%dil, %dil
	je	.L753
	movl	%r10d, 656(%rsp)
.L753:
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
	je	.L754
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
.L755:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L756:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L756
	testq	%rax, %rax
	je	.L757
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L757:
	subl	$1, %ebx
	jne	.L755
	testb	%bpl, %bpl
	je	.L759
	movl	%edi, 960(%rsp)
.L759:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	bn_shl
.L760:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.L767
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.L794:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L768:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.L768
	cmpb	$53, (%rdi)
	ja	.L769
	je	.L966
.L770:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.L967
.L772:
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
	je	.L776
	.p2align 4,,10
	.p2align 3
.L775:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L777:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.L777
	testq	%rax, %rax
	je	.L778
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.L778:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.L775
	testb	%r15b, %r15b
	je	.L776
	movl	%r9d, 1264(%rsp)
.L776:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.L781
	jnb	.L782
	cmpl	656(%rsp), %r8d
	jne	.L783
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.L790
	.p2align 4,,10
	.p2align 3
.L793:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.L968
.L790:
	cmpl	$-1, %eax
	jne	.L793
.L789:
	testb	$1, 40(%rsp)
	je	.L948
.L783:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.L949
	cmpl	%r12d, %ebp
	jb	.L794
.L949:
	movq	2400(%rsp), %rsi
.L767:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.L796:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.L797:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.L797
	cmpl	%r12d, %ebp
	jnb	.L798
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.L799
	jne	.L798
	testb	$1, %r8b
	jne	.L799
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.L798
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.L800
.L969:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.L798
.L800:
	cmpb	$48, (%rcx)
	je	.L969
.L799:
	addq	$1, %r8
.L798:
	movabsq	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.L801:
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
	ja	.L801
	cmpl	%ebp, %ecx
	jbe	.L802
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.L806
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.L802:
	xorl	%edx, %edx
	jmp	.L804
.L970:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L804:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L970
	cmpl	$1, %ecx
	jbe	.L805
.L971:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L805
	movl	%eax, %ecx
.L806:
	cmpl	$1, %ecx
	ja	.L971
.L805:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.L972
	cmpl	%ecx, %r8d
	jge	.L811
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.L817
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.L814
.L813:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.L973
	movq	%rcx, %rdx
.L814:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.L813
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.L817
	.p2align 4,,10
	.p2align 3
.L975:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.L974
	movl	%edx, %r8d
.L817:
	cmpl	$1, %r8d
	jne	.L975
.L816:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.L809
	.p2align 4,,10
	.p2align 3
.L781:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.L786
	.p2align 4,,10
	.p2align 3
.L788:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.L976
.L786:
	cmpl	$-1, %edx
	jne	.L788
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.L790
	jmp	.L789
.L966:
	testb	$1, %r8b
	jne	.L769
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.L770
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.L771
.L977:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L770
.L771:
	cmpb	$48, (%rax)
	je	.L977
.L769:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.L772
.L967:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L773:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.L773
	cmpl	%ebp, %r9d
	jbe	.L772
	movabsq	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.L772
.L968:
	jnb	.L792
	cmpl	$1, %ecx
	je	.L948
.L792:
	testl	%ecx, %ecx
	jne	.L783
	jmp	.L789
.L976:
	jnb	.L787
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.L790
	jmp	.L783
.L782:
	cmpl	656(%rsp), %r8d
	jne	.L957
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.L790
.L957:
	jnb	.L783
.L948:
	movq	2400(%rsp), %rsi
	jmp	.L796
.L787:
	cmpl	656(%rsp), %r8d
	jne	.L957
	movl	$1, %ecx
	jmp	.L790
.L754:
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
.L762:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L763:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.L763
	testq	%rax, %rax
	je	.L764
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L764:
	subl	$1, %ebx
	jne	.L762
	testb	%r11b, %r11b
	je	.L766
	movl	%edi, 960(%rsp)
.L766:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	bn_shl
	jmp	.L760
.L811:
	cmpl	$1, %ecx
	je	.L816
.L809:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.L818:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.L721
	testl	%r10d, %r10d
	je	.L842
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.L820:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.L821
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.L823:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.L822
	movzbl	0(%r13,%rdx), %r11d
.L822:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.L823
	addl	%r10d, %eax
.L824:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.L713
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.L826
.L979:
	cmpl	%ecx, %edx
	jnb	.L844
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.L825:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.L978
.L826:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.L979
.L844:
	movl	$48, %r10d
	jmp	.L825
.L842:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.L820
.L972:
	jne	.L808
	cmpb	$52, 1600(%rsp)
	jbe	.L808
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.L809
.L808:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.L818
.L821:
	movb	$48, (%rdx)
	jmp	.L824
.L978:
	addl	%r9d, %eax
	jmp	.L713
.L961:
	subl	$1, %r10d
	jmp	.L738
.L962:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L741:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L741
	jmp	.L713
.L974:
	movl	%r8d, %ecx
	jmp	.L809
.L828:
	movl	$1, %edx
	jmp	.L733
.L973:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.L817
	.p2align 4
	.def	hrdbf_write_number_double.part.0;	.scl	3;	.type	32;	.endef
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.L987
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.L980
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.L980
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	put_number.isra.0
.L980:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L987:
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
	jmp	.L991
	.p2align 4,,10
	.p2align 3
.L993:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L992
.L991:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.L993
.L992:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L994
	movl	$32, %ecx
	leaq	.LC1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.L996:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.L1000
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L996
.L1000:
	movl	%eax, %edx
	subl	%esi, %edx
.L994:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, fsink_len(%rip)
	call	fdec
	movl	fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L997
	movb	$41, (%rax)
	addq	$1, %rax
.L997:
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
.L1002:
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
	jbe	.L1012
	cmpl	$19, %r10d
	jbe	.L1002
.L1012:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.L1010:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.L1004
	.p2align 4,,10
	.p2align 3
.L1006:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.L1005
.L1004:
	cmpb	$0, (%rax)
	jne	.L1006
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.L1007
	jmp	.L1005
	.p2align 4,,10
	.p2align 3
.L1008:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.L1005
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.L1007:
	testb	%cl, %cl
	jne	.L1008
.L1005:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.L1001
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L1010
.L1001:
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
	leaq	2249(%rcx), %r8
	subq	$16, %rsp
	.p2align 4,,10
	.p2align 3
.L1020:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.L1019
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.L1022
	.p2align 4,,10
	.p2align 3
.L1024:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.L1023
.L1022:
	cmpb	$0, (%rax)
	jne	.L1024
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.L1025
	jmp	.L1023
	.p2align 4,,10
	.p2align 3
.L1026:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.L1023
.L1025:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1026
.L1023:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.L1020
.L1019:
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
	leaq	2090(%rcx), %rax
	addq	$2249, %rcx
	movb	$0, 15(%rsp)
	movq	%rax, %rdx
	movb	%r8b, 14(%rsp)
	jmp	.L1034
	.p2align 4,,10
	.p2align 3
.L1036:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.L1035
.L1034:
	cmpb	$0, (%rdx)
	jne	.L1036
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.L1037
	jmp	.L1035
	.p2align 4,,10
	.p2align 3
.L1039:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.L1035
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.L1037:
	testb	%r8b, %r8b
	jne	.L1039
.L1035:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.L1041
	.p2align 4,,10
	.p2align 3
.L1043:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.L1042
.L1041:
	cmpb	$0, (%rax)
	jne	.L1043
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.L1044
	jmp	.L1042
	.p2align 4,,10
	.p2align 3
.L1045:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.L1042
.L1044:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.L1045
.L1042:
	movb	$0, (%rax)
	addq	$16, %rsp
	popq	%rbx
	ret
	.section .rdata,"dr"
	.align 8
.LC3:
	.ascii "path is not a supported plain file path (reserved device name or characters)\0"
.LC4:
	.ascii "CON\0"
.LC5:
	.ascii "PRN\0"
.LC6:
	.ascii "AUX\0"
.LC7:
	.ascii "NUL\0"
.LC8:
	.ascii "CONIN$\0"
.LC9:
	.ascii "CONOUT$\0"
.LC10:
	.ascii "CLOCK$\0"
.LC11:
	.ascii "COM\0"
.LC12:
	.ascii "LPT\0"
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
	.ascii " exceeds the 64 MiB limit\0"
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
	movq	%rdx, %rbp
	pushq	%rdi
	pushq	%rsi
	pushq	%rbx
	subq	$632, %rsp
	movzbl	(%rcx), %edx
	movq	%r9, 728(%rsp)
	testb	%dl, %dl
	je	.L1057
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.L1160
	cmpb	$47, %dl
	jne	.L1153
	cmpb	$47, 1(%rcx)
	je	.L1057
	movl	$47, %eax
.L1058:
	movabsq	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.L1059
	.p2align 4,,10
	.p2align 3
.L1162:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.L1057
.L1063:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.L1161
	js	.L1057
	cmpq	$258, %rbx
	ja	.L1057
.L1059:
	cmpb	$63, %al
	ja	.L1162
	btq	%rax, %r9
	jc	.L1057
	cmpb	$60, %al
	je	.L1057
	cmpb	$58, %al
	jne	.L1062
	cmpq	$1, %rbx
	jne	.L1057
	cmpb	$25, %dl
	ja	.L1057
	movl	$58, %eax
	jmp	.L1063
	.p2align 4,,10
	.p2align 3
.L1167:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.L1068
	.p2align 4,,10
	.p2align 3
.L1057:
	leaq	.LC3(%rip), %rcx
	movl	$7, %r13d
	call	fset
.L1053:
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
.L1160:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.L1058
	jmp	.L1057
	.p2align 4,,10
	.p2align 3
.L1062:
	cmpb	$47, %al
	jne	.L1063
	movl	$92, %eax
	jmp	.L1063
	.p2align 4,,10
	.p2align 3
.L1153:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.L1058
	jmp	.L1057
	.p2align 4,,10
	.p2align 3
.L1161:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.L1083
	.p2align 4,,10
	.p2align 3
.L1066:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.L1163
	movq	%rax, %rbx
.L1083:
	cmpq	%r15, %r12
	je	.L1065
	cmpw	$92, (%rdi,%r15,2)
	jne	.L1066
.L1065:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.L1112
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.L1067
	cmpw	$46, %ax
	je	.L1067
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.L1068:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.L1070
	.p2align 4,,10
	.p2align 3
.L1071:
	movzwl	0(%r13,%rax,2), %edx
.L1070:
	cmpw	$46, %dx
	je	.L1164
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.L1071
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.L1073
	.p2align 4,,10
	.p2align 3
.L1077:
	subq	$1, %rsi
	je	.L1073
.L1076:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.L1077
.L1073:
	leaq	.LC4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	leaq	.LC10(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1057
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.L1066
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.L1066
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.L1080
.L1165:
	leaq	.LC11(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.L1110
	movzwl	0(%r13,%rcx,2), %eax
.L1080:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.L1110
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.L1165
	jmp	.L1057
.L1110:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.L1082
.L1166:
	movzwl	0(%r13,%rdx,2), %r14d
.L1082:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.L1112
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.L1057
	leaq	.LC12(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.L1166
	.p2align 4,,10
	.p2align 3
.L1112:
	movq	%rbx, %rcx
	jmp	.L1066
	.p2align 4,,10
	.p2align 3
.L1067:
	cmpq	$1, %rsi
	je	.L1167
	cmpq	$2, %rsi
	jne	.L1057
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.L1057
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.L1068
	jmp	.L1057
	.p2align 4,,10
	.p2align 3
.L1164:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.L1076
	jmp	.L1073
.L1163:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.L1057
	cmpq	$1, %rbx
	je	.L1084
	cmpw	$58, 98(%rsp)
	je	.L1168
.L1084:
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
	call	*__imp_CreateFileW(%rip)
	movq	%rax, %r12
	cmpq	$-1, %rax
	je	.L1169
	movq	728(%rsp), %rax
	movq	__imp_GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r14
	testl	%eax, %eax
	je	.L1170
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.L1171
	cmpq	$67108864, %r10
	jg	.L1172
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.L1090
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.L1173
.L1090:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.L1091
	movq	(%rdi), %r8
	movq	__imp_ReadFile(%rip), %rbx
	xorl	%r15d, %r15d
	movq	%rax, %rdx
	movq	__imp_GetLastError(%rip), %r13
	leaq	76(%rsp), %rsi
	testq	%r8, %r8
	jne	.L1092
	jmp	.L1093
	.p2align 4,,10
	.p2align 3
.L1097:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.L1159
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%r15, %rdx
	cmpq	%rdx, %rax
	ja	.L1174
	addq	%rax, %r15
	cmpq	%r15, %r8
	jbe	.L1093
	movq	0(%rbp), %rdx
.L1092:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rsi, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbx
	testl	%eax, %eax
	jne	.L1097
	call	*%r13
	testl	%eax, %eax
	je	.L1097
	.p2align 4,,10
	.p2align 3
.L1159:
	movl	%eax, %edx
	leaq	.LC20(%rip), %rcx
	movl	$7, %r13d
	call	werr
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1171:
	leaq	.LC15(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1172:
	leaq	.LC16(%rip), %rcx
	movl	$1, %r13d
	call	fset
	movq	80(%rsp), %rcx
	call	fdec
	leaq	.LC17(%rip), %rcx
	call	fcat
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1093:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rsi, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.L1175
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.L1101
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.L1101
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.L1053
.L1101:
	leaq	.LC21(%rip), %rcx
	movl	$7, %r13d
	call	fset
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1174:
	xorl	%eax, %eax
	jmp	.L1159
	.p2align 4,,10
	.p2align 3
.L1170:
	call	*__imp_GetLastError(%rip)
	leaq	.LC14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1169:
	call	*__imp_GetLastError(%rip)
	leaq	.LC13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1053
	.p2align 4,,10
	.p2align 3
.L1173:
	leaq	.LC18(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1053
.L1091:
	leaq	.LC19(%rip), %rcx
	movl	$8, %r13d
	call	fset
	jmp	.L1053
.L1175:
	call	*__imp_GetLastError(%rip)
	jmp	.L1159
.L1168:
	cmpq	$2, %rbx
	je	.L1057
	cmpw	$92, 100(%rsp)
	jne	.L1057
	jmp	.L1084
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
	je	.L1177
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.L1177:
	ret
	.p2align 4
	.globl	hrdbf_skip
	.def	hrdbf_skip;	.scl	2;	.type	32;	.endef
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1180
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.L1180
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.L1182
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
.L1184:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.L1194
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1180:
	ret
	.p2align 4,,10
	.p2align 3
.L1182:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.L1185
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L1194:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1185:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.L1184
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
	je	.L1197
	testl	%edx, %edx
	je	.L1199
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.L1199
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.L1199:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1197:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
	.def	hrdbf_deleted;	.scl	2;	.type	32;	.endef
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1200
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.L1202
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.L1202:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.L1200:
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
	.ascii "more than 128 field descriptors\0"
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
	jbe	.L1290
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.L1291
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
	jbe	.L1209
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.L1210
.L1209:
	leaq	.LC26(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movzwl	144(%rsp), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC27(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC28(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	movl	$1, %eax
.L1205:
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
.L1210:
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
.L1236:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.L1292
	cmpq	%r15, 64(%rsp)
	je	.L1293
	cmpq	$129, %r15
	je	.L1294
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.L1220
	.p2align 4,,10
	.p2align 3
.L1295:
	movzbl	(%r8,%rax), %r10d
.L1220:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1295
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.L1221
	cmpl	$1, %r15d
	jbe	.L1222
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.L1223:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.L1226
	.p2align 4,,10
	.p2align 3
.L1297:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1226:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.L1296
	cmpq	%rax, %rcx
	jne	.L1297
	movzwl	46(%rsp), %eax
	leaq	.LC63(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	dname
	leaq	.LC64(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
	.p2align 4,,10
	.p2align 3
.L1296:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.L1223
.L1222:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.L1298
	cmpb	$67, %dl
	je	.L1299
	cmpb	$78, %dl
	je	.L1300
	cmpb	$76, %dl
	je	.L1301
	cmpb	$68, %dl
	jne	.L1233
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.L1229
	movzwl	46(%rsp), %eax
	leaq	.LC43(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	dname
	leaq	.LC44(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
	.p2align 4,,10
	.p2align 3
.L1290:
	leaq	.LC15(%rip), %rdx
	call	dset
	movl	$1, %eax
	jmp	.L1205
.L1291:
	leaq	.LC24(%rip), %rdx
	call	dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	dhex
	leaq	.LC25(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$2, %eax
	jmp	.L1205
.L1299:
	testb	%r9b, %r9b
	jne	.L1302
.L1229:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.L1303
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.L1236
	movzwl	46(%rsp), %eax
	leaq	.LC48(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	$1, %eax
	jmp	.L1205
.L1300:
	cmpb	$17, %r9b
	ja	.L1257
	cmpb	%r9b, %al
	ja	.L1229
.L1257:
	movzwl	46(%rsp), %eax
	leaq	.LC37(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movslq	40(%rsp), %rbx
	movq	56(%rsp), %rdi
	movq	%r12, %rcx
	leal	2(%rbx), %eax
	addq	$2, %rbx
	cltq
	salq	$4, %rbx
	salq	$4, %rax
	leaq	10(%rdi,%rax), %rdx
	call	dname
	leaq	.LC38(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzbl	134(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC39(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzbl	135(%rsp,%rbx), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC40(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$4, %eax
	jmp	.L1205
	.p2align 4,,10
	.p2align 3
.L1301:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.L1229
	movzwl	46(%rsp), %eax
	leaq	.LC41(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	dname
	leaq	.LC42(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
	.p2align 4,,10
	.p2align 3
.L1293:
	testb	%dl, %dl
	je	.L1216
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1216:
	leaq	.LC29(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movzwl	148(%rsp), %eax
	movq	%r12, %rcx
	leaq	1(%rax), %rdx
	call	ddec
	leaq	.LC30(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
.L1294:
	testb	%dl, %dl
	je	.L1218
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1218:
	leaq	.LC31(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$4, %eax
	jmp	.L1205
.L1292:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.L1212
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1212:
	cmpw	$0, 148(%rsp)
	je	.L1304
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.L1238
	jmp	.L1305
	.p2align 4,,10
	.p2align 3
.L1239:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.L1306
.L1238:
	cmpq	%r9, 32(%rsp)
	ja	.L1239
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.L1307
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.L1241
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1242
	cmpb	$26, (%rbx,%rax)
	je	.L1241
.L1242:
	leaq	.LC56(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1205
.L1221:
	movzwl	46(%rsp), %eax
	leaq	.LC29(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movzwl	148(%rsp), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC32(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
.L1298:
	movzwl	46(%rsp), %eax
	leaq	.LC33(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	dname
	leaq	.LC34(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$1, %eax
	jmp	.L1205
.L1306:
	leaq	.LC52(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1205
.L1303:
	movzwl	46(%rsp), %eax
	leaq	.LC47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	$4, %eax
	jmp	.L1205
.L1302:
	movzwl	46(%rsp), %eax
	leaq	.LC35(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %eax
	movq	56(%rsp), %rbx
	movq	%r12, %rcx
	addl	$2, %eax
	cltq
	salq	$4, %rax
	leaq	10(%rbx,%rax), %rdx
	call	dname
	leaq	.LC36(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$3, %eax
	jmp	.L1205
.L1305:
	leaq	.LC50(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	%edi, %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC51(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	146(%rsp), %edx
	movq	%r12, %rcx
	call	ddec
	movl	$1, %eax
	jmp	.L1205
.L1304:
	leaq	.LC49(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1205
.L1233:
	movzwl	46(%rsp), %eax
	leaq	.LC33(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	40(%rsp), %ebx
	movq	56(%rsp), %rdi
	movq	%r12, %rcx
	leal	2(%rbx), %eax
	cltq
	salq	$4, %rax
	leaq	10(%rdi,%rax), %rdx
	call	dname
	leaq	.LC45(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
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
	call	dcat
	leaq	.LC46(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$3, %eax
	jmp	.L1205
.L1241:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.L1254
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.L1246:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.L1244
	cmpb	$42, %dil
	jne	.L1308
.L1244:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.L1245
	jmp	.L1252
	.p2align 4,,10
	.p2align 3
.L1248:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1309
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.L1252
.L1245:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.L1248
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
	movq	56(%rsp), %rsi
	movq	%r12, %rcx
	salq	$4, %rax
	leaq	10(%rsi,%rax), %rdx
	call	dname
	movl	$6, %eax
	leaq	.LC22(%rip), %rdx
.L1249:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.L1310
.L1251:
	cmpb	$42, %dil
	jne	.L1205
	leaq	.LC62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	dcat
	movl	40(%rsp), %eax
	jmp	.L1205
.L1252:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.L1246
	cmpb	$0, 152(%rsp)
	je	.L1253
.L1243:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.L1253:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.L1205
.L1310:
	leaq	.LC61(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	40(%rsp), %eax
	jmp	.L1251
.L1307:
	leaq	.LC53(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	128(%rsp), %edx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC54(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movzwl	144(%rsp), %edx
	movzwl	146(%rsp), %ecx
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
	jmp	.L1205
.L1308:
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
	jmp	.L1205
.L1254:
	xorl	%eax, %eax
	jmp	.L1243
.L1309:
	leaq	.LC57(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	leal	-1(%rsi), %ebx
	call	dset
	movq	%r13, %rdx
	movq	%r12, %rcx
	call	ddec
	leaq	.LC60(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movq	56(%rsp), %rax
	leal	1(%rsi), %edx
	movq	%r12, %rcx
	salq	$4, %rdx
	leaq	10(%rax,%rdx), %rdx
	call	dname
	movl	40(%rsp), %eax
	leaq	.LC22(%rip), %rdx
	leaq	.LC23(%rip), %rcx
	cmpl	$4, %eax
	cmove	%rcx, %rdx
	jmp	.L1249
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
	ja	.L1313
	je	.L1344
	cmpl	$5, %edx
	je	.L1317
	shrq	$8, %rax
	jne	.L1313
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.L1313
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.L1313
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.L1313
	movq	%rcx, %rax
	movl	$4, %r8d
	movabsq	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.L1313
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
	ja	.L1331
	testq	%rcx, %rcx
	je	.L1331
	leaq	days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1345
.L1319:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.L1313:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1344:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.L1313
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.L1313
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.L1331
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.L1331
	cmpl	%edx, %eax
	jb	.L1313
.L1331:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1317:
	testq	%rax, %rax
	jns	.L1326
	movabsq	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.L1313
.L1326:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1345:
	testb	$3, %r9b
	jne	.L1319
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1320
	addl	$1, %eax
	jmp	.L1319
.L1320:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.L1319
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
	ja	.L1346
	leaq	CSWTCH.365(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.L1346:
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
	jne	.L1351
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.L1362
	testl	%edx, %edx
	je	.L1354
	cmpl	$9, %edx
	je	.L1354
	movl	$1, %eax
.L1351:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1362:
	testl	$65280, %r11d
	jne	.L1363
.L1354:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1363:
	movl	$2, %eax
	jmp	.L1351
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
	jne	.L1364
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1364
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.L1366
	cmpl	$11, %r14d
	jne	.L1366
.L1377:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.L1364:
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
.L1366:
	cmpl	$1, %r15d
	je	.L1380
	cmpl	$1, %r14d
	je	.L1380
	cmpl	$3, %r15d
	jne	.L1369
	cmpl	$3, %r14d
	jne	.L1369
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1364
	.p2align 4,,10
	.p2align 3
.L1380:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1364
	.p2align 4,,10
	.p2align 3
.L1369:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1373
	cmpl	$12, %r15d
	je	.L1403
	testl	%r15d, %r15d
	je	.L1372
	cmpl	$9, %r15d
	jne	.L1373
.L1372:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1373
	cmpl	$12, %r14d
	je	.L1404
	testl	%r14d, %r14d
	je	.L1377
	cmpl	$9, %r14d
	je	.L1377
	.p2align 4,,10
	.p2align 3
.L1373:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1405
.L1379:
	movl	$1, %eax
	jmp	.L1364
	.p2align 4,,10
	.p2align 3
.L1403:
	testl	$65280, %r11d
	je	.L1372
	jmp	.L1373
	.p2align 4,,10
	.p2align 3
.L1405:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1379
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1364
	.p2align 4,,10
	.p2align 3
.L1404:
	testl	$65280, %edi
	je	.L1377
	jmp	.L1373
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
	jne	.L1406
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.L1427
.L1406:
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
.L1427:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1408
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1428
	testl	%eax, %eax
	je	.L1410
	cmpl	$9, %eax
	je	.L1410
	.p2align 4,,10
	.p2align 3
.L1408:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1429
.L1416:
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
.L1429:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1416
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1417
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1417:
	movq	%rdx, (%rbx)
	jmp	.L1406
	.p2align 4,,10
	.p2align 3
.L1428:
	testl	$65280, %r11d
	jne	.L1408
.L1410:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1408
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.L1430
	testl	%edx, %edx
	je	.L1413
	cmpl	$9, %edx
	jne	.L1408
.L1413:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.L1406
	.p2align 4,,10
	.p2align 3
.L1430:
	testl	$65280, %esi
	je	.L1413
	jmp	.L1408
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
	jne	.L1431
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	ja	.L1436
	leaq	.L1434(%rip), %rcx
	movslq	(%rcx,%rdx,4), %rdx
	addq	%rcx, %rdx
	jmp	*%rdx
	.section .rdata,"dr"
	.align 4
.L1434:
	.long	.L1433-.L1434
	.long	.L1435-.L1434
	.long	.L1436-.L1434
	.long	.L1433-.L1434
	.long	.L1436-.L1434
	.long	.L1436-.L1434
	.long	.L1436-.L1434
	.long	.L1436-.L1434
	.long	.L1436-.L1434
	.long	.L1433-.L1434
	.long	.L1436-.L1434
	.long	.L1433-.L1434
	.long	.L1433-.L1434
	.text
	.p2align 4,,10
	.p2align 3
.L1436:
	movl	$1, %eax
.L1431:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1433:
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
.L1435:
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
	jne	.L1438
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.L1485
	cmpl	$12, %eax
	jne	.L1464
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
.L1446:
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
	ja	.L1446
	cmpl	%ebx, %r8d
	ja	.L1486
	movl	$1, %r9d
.L1447:
	leal	1(%r9,%rbx), %eax
.L1448:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.L1449
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.L1487
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.L1457
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1456:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L1456
.L1457:
	testq	%r13, %r13
	jns	.L1455
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.L1455:
	testl	%r9d, %r9d
	je	.L1458
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.L1460
	.p2align 4,,10
	.p2align 3
.L1468:
	movl	%edx, %eax
.L1460:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1459
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1459:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.L1468
	addl	%r9d, %r10d
.L1458:
	testl	%ebx, %ebx
	je	.L1438
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.L1462:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1461
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1461:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.L1462
.L1438:
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
.L1485:
	cmpq	$7, %rsi
	jbe	.L1449
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.L1444
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
	jmp	.L1438
	.p2align 4,,10
	.p2align 3
.L1464:
	movl	$1, %r12d
	jmp	.L1438
	.p2align 4,,10
	.p2align 3
.L1488:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.L1463
.L1443:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.L1438
.L1444:
	cmpl	$2, %ecx
	jne	.L1488
.L1463:
	movl	$47, %eax
	jmp	.L1443
	.p2align 4,,10
	.p2align 3
.L1486:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.L1447
	movl	%r9d, %eax
	jmp	.L1448
	.p2align 4,,10
	.p2align 3
.L1449:
	movl	$3, %r12d
	jmp	.L1438
	.p2align 4,,10
	.p2align 3
.L1487:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.L1438
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1452:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.L1452
	jmp	.L1438
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
	jne	.L1489
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1489
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.L1529
	cmpl	$42, %ebx
	je	.L1529
	cmpl	$47, %ebx
	je	.L1504
	cmpl	$37, %ebx
	je	.L1531
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.L1531
.L1489:
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
.L1529:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1504
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1551
	testl	%eax, %eax
	je	.L1495
	cmpl	$9, %eax
	je	.L1495
	.p2align 4,,10
	.p2align 3
.L1504:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1489
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1489
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.L1552
	testl	%r13d, %r13d
	je	.L1553
	cmpl	$42, %ebx
	je	.L1554
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1530
	jne	.L1530
	movl	$5, %r8d
	jmp	.L1489
	.p2align 4,,10
	.p2align 3
.L1551:
	testl	$65280, %r11d
	jne	.L1504
.L1495:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1504
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.L1555
	testl	%eax, %eax
	je	.L1498
	cmpl	$9, %eax
	jne	.L1504
.L1498:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.L1556
	testl	%r13d, %r13d
	je	.L1557
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1489
	.p2align 4,,10
	.p2align 3
.L1531:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1489
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1489
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1513
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1514
	jne	.L1514
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.L1489
	.p2align 4,,10
	.p2align 3
.L1555:
	testl	$65280, %edi
	je	.L1498
	jmp	.L1504
	.p2align 4,,10
	.p2align 3
.L1554:
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
.L1507:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1489
	.p2align 4,,10
	.p2align 3
.L1530:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1507
	.p2align 4,,10
	.p2align 3
.L1552:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.L1550:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1507
	.p2align 4,,10
	.p2align 3
.L1553:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1550
	.p2align 4,,10
	.p2align 3
.L1556:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1489
.L1513:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabsq	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.L1558
	testq	%r10, %r10
	jne	.L1523
.L1518:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1516
	testq	%r9, %r9
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1516:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1489
.L1557:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.L1489
.L1514:
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
	jmp	.L1516
.L1558:
	testq	%r10, %r10
	je	.L1518
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.L1519
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.L1526
	jne	.L1526
.L1519:
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
	ja	.L1516
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.L1516
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1516
.L1523:
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
	jmp	.L1516
.L1526:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1516
	.section .rdata,"dr"
.LC67:
	.ascii "DBF unknown value error\0"
.LC68:
	.ascii "ok\0"
	.align 8
.LC69:
	.ascii "DBF decimal numeric cannot enter I64 operation\0"
	.align 8
.LC70:
	.ascii "DBF value output buffer too short\0"
	.align 8
.LC71:
	.ascii "DBF value tag or metadata invalid\0"
	.align 8
.LC72:
	.ascii "DBF arithmetic division by zero\0"
	.align 8
.LC73:
	.ascii "DBF value type outside admitted operation\0"
	.text
	.p2align 4
	.globl	hrv_error_name
	.def	hrv_error_name;	.scl	2;	.type	32;	.endef
hrv_error_name:
	cmpl	$5, %ecx
	ja	.L1560
	leaq	.L1562(%rip), %rdx
	movl	%ecx, %ecx
	movslq	(%rdx,%rcx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.L1562:
	.long	.L1568-.L1562
	.long	.L1566-.L1562
	.long	.L1565-.L1562
	.long	.L1564-.L1562
	.long	.L1563-.L1562
	.long	.L1561-.L1562
	.text
	.p2align 4,,10
	.p2align 3
.L1566:
	leaq	.LC73(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1568:
	leaq	.LC68(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1561:
	leaq	.LC72(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1565:
	leaq	.LC69(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1564:
	leaq	.LC70(%rip), %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1563:
	leaq	.LC71(%rip), %rax
	ret
.L1560:
	leaq	.LC67(%rip), %rax
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
	ja	.L1572
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.L1572
	movabsq	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.L1667
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.L1576:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.L1583
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.L1582:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1584:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.L1584
	testq	%rax, %rax
	je	.L1585
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.L1585:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.L1582
	testb	%r12b, %r12b
	je	.L1583
	movl	%r9d, 544(%rsp)
.L1583:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.L1588
	movq	%rbp, %rcx
	call	bn_shl
	movl	544(%rsp), %edi
.L1589:
	xorl	%r12d, %r12d
	jmp	.L1595
	.p2align 4,,10
	.p2align 3
.L1596:
	cmpq	$48, %r12
	je	.L1668
	movq	%rbp, %rcx
	call	bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.L1595:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.L1596
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.L1596
	testl	%r12d, %r12d
	jne	.L1669
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.L1601:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.L1604
	.p2align 4,,10
	.p2align 3
.L1670:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.L1604:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1670
	testl	%r13d, %r13d
	je	.L1605
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.L1607:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.L1606:
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
	jne	.L1606
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1671
	movq	%rax, %r12
	jmp	.L1607
	.p2align 4,,10
	.p2align 3
.L1572:
	xorl	%eax, %eax
.L1569:
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
.L1667:
	testq	%rax, %rax
	jne	.L1672
	cmpq	$0, 40(%rsp)
	jne	.L1673
	xorl	%edx, %edx
.L1577:
	testl	%ebx, %ebx
	je	.L1578
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.L1572
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1580:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.L1580
	addl	%ebx, %eax
	jmp	.L1569
.L1673:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.L1572
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.L1577
.L1588:
	negl	%edx
	movq	%rbp, %rcx
	call	bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.L1674
	cmpl	$2, %eax
	jne	.L1589
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.L1589
	testl	%edi, %edi
	je	.L1622
.L1592:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.L1594
	.p2align 4,,10
	.p2align 3
.L1675:
	movl	(%rcx), %edx
.L1594:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.L1675
	testq	%rax, %rax
	je	.L1589
	movl	%edi, %eax
	addl	$1, %edi
.L1591:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.L1589
	.p2align 4,,10
	.p2align 3
.L1671:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.L1605:
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
	ja	.L1572
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.L1610
	movb	$45, (%rsi)
	movl	$1, %edx
.L1610:
	cmpl	%edi, %ebx
	jnb	.L1611
	testl	%eax, %eax
	je	.L1627
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1613:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1613
.L1612:
	testl	%ebx, %ebx
	je	.L1569
.L1614:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.L1615
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1616:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.L1616
	addl	%ebx, %edx
.L1615:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.L1617:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1617
	jmp	.L1569
.L1668:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.L1599:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.L1602:
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
	ja	.L1602
	jmp	.L1601
.L1672:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.L1576
.L1578:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.L1572
	movb	$48, (%rsi,%rdx)
	jmp	.L1569
.L1611:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1614
.L1674:
	testl	%edi, %edi
	je	.L1621
	movl	256(%rsp), %edx
	jmp	.L1592
.L1627:
	movl	%edx, %eax
	jmp	.L1612
.L1622:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.L1591
.L1621:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.L1591
.L1669:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.L1599
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.def	hrdbf_fmt_harbour;	.scl	2;	.type	32;	.endef
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.L1677
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1677:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
	.def	hrdbf_write_char;	.scl	2;	.type	32;	.endef
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.L1678
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.L1680
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1681:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.L1681
	movzbl	12(%rdx), %eax
.L1680:
	cmpq	%rax, %r9
	jnb	.L1683
	.p2align 4,,10
	.p2align 3
.L1682:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.L1682
.L1683:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1678:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.def	hrdbf_write_number_scaled;	.scl	2;	.type	32;	.endef
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.L1692
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1692:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
	.def	hrdbf_write_number_double;	.scl	2;	.type	32;	.endef
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.L1694
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1694:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
	.def	hrdbf_write_date;	.scl	2;	.type	32;	.endef
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.L1715
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.L1718
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
	ja	.L1715
	cmpl	$9999, %r8d
	jbe	.L1715
	testl	%r11d, %r11d
	je	.L1715
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.L1699
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.L1701
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.L1701:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.L1695
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
.L1695:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1718:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.L1698:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.L1698
	xorl	%r10d, %r10d
.L1715:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1699:
	movl	$28, %edx
	testb	$3, %bl
	jne	.L1701
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.L1701
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.L1701
	.p2align 4
	.globl	hrdbf_write_logical
	.def	hrdbf_write_logical;	.scl	2;	.type	32;	.endef
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.L1719
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.L1719:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
	.def	hrdbf_write_blank;	.scl	2;	.type	32;	.endef
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.L1731
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1730
.L1731:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.L1729
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1728:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1728
.L1729:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1730:
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
	movl	$0, 2272(%rcx)
	movq	2280(%rcx), %rcx
	testq	%rcx, %rcx
	je	.L1742
	movq	$0, 2280(%rbx)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L1749
.L1742:
	xorl	%r12d, %r12d
.L1741:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.L1739
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1744
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.L1739:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1749:
	movl	$7, %r12d
	jmp	.L1741
	.p2align 4,,10
	.p2align 3
.L1744:
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
	leaq	2280(%r12), %r9
	leaq	2256(%r12), %rdx
	subq	$72, %rsp
	testl	%r8d, %r8d
	movb	$0, fsink(%rip)
	setne	%al
	movl	%r8d, 48(%rsp)
	leaq	2264(%r12), %r8
	movb	$0, 2288(%r12)
	movl	%eax, 2272(%r12)
	movl	$0, 40(%rsp)
	movq	$33, 32(%rsp)
	movl	$0, fsink_len(%rip)
	call	hrdbfw_snapshot
	testl	%eax, %eax
	je	.L1751
	movl	%eax, %r13d
	leaq	fsink(%rip), %rax
	leaq	2288(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.L1752
	.p2align 4,,10
	.p2align 3
.L1754:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.L1753
.L1752:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.L1754
.L1753:
	movb	$0, (%rdx)
.L1756:
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
.L1751:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.L1756
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
	je	.L1767
	movzwl	36+hrdbf_app_state(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.L1777
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1767
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.L1781
	cmpb	$78, %al
	je	.L1782
	cmpb	$68, %al
	je	.L1776
	movzbl	60(%rsp), %eax
.L1766:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1781:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.L1783
.L1769:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.L1784
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1767:
	leaq	.LC74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1777:
	xorl	%eax, %eax
	jmp	.L1766
	.p2align 4,,10
	.p2align 3
.L1782:
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
.L1776:
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
.L1783:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.L1772
	.p2align 4,,10
	.p2align 3
.L1771:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1771
.L1772:
	movq	%rcx, 40(%rsp)
	jmp	.L1769
.L1784:
	leaq	.LC75(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC76:
	.ascii "hbc: DBF no workarea is open\12\0"
	.align 8
.LC77:
	.ascii "hbc: DBF field write requires a readonly=.F. open\12\0"
	.align 8
.LC78:
	.ascii "hbc: DBF field write with an open index is outside this increment\12\0"
	.align 8
.LC79:
	.ascii "hbc: DBF field write with no record positioned\12\0"
	.text
	.p2align 4
	.def	hrdbf_app_require_writable;	.scl	3;	.type	32;	.endef
hrdbf_app_require_writable:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1791
	movl	2272+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L1792
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L1793
	movl	16+hrdbf_app_state(%rip), %eax
	cmpq	%rax, 24+hrdbf_app_state(%rip)
	ja	.L1794
	addq	$40, %rsp
	ret
.L1791:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L1794:
	leaq	.LC79(%rip), %rcx
	call	hrdbf_app_fail
.L1793:
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L1792:
	leaq	.LC77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC80:
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
	leaq	.LC80(%rip), %rdx
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
	movb	$0, 2288(%rcx)
	movb	$0, fsink(%rip)
	movq	$0, 8(%rcx)
	movq	$0, (%rcx)
	movl	$0, 16(%rcx)
	movq	$0, 24(%rcx)
	movl	$16842752, 36(%rcx)
	movb	$0, 40(%rcx)
	movl	$0, 2272(%rcx)
	movq	2280(%rcx), %rcx
	testq	%rcx, %rcx
	je	.L1817
	movq	$0, 2280(%r12)
	call	*__imp_CloseHandle(%rip)
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.L1801
	testq	%rcx, %rcx
	je	.L1797
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1797
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
.L1801:
	testq	%rcx, %rcx
	je	.L1800
.L1799:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L1815
.L1797:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1817:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.L1799
.L1800:
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
.L1815:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.L1800
	.p2align 4
	.globl	hrdbf_file_write_record
	.def	hrdbf_file_write_record;	.scl	2;	.type	32;	.endef
hrdbf_file_write_record:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.L1822
	cmpq	$0, 2280(%rcx)
	je	.L1822
	cmpb	$0, 40(%rcx)
	je	.L1822
	testq	%rdx, %rdx
	je	.L1823
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.L1825
	ret
	.p2align 4,,10
	.p2align 3
.L1822:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1823:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1825:
	movzwl	34(%rcx), %r9d
	subq	$1, %rdx
	movzwl	32(%rcx), %eax
	movq	2256(%rcx), %r8
	imulq	%r9, %rdx
	addq	%rax, %rdx
	addq	%rdx, %r8
	jmp	write_at
	.p2align 4
	.globl	hrdbf_file_append
	.def	hrdbf_file_append;	.scl	2;	.type	32;	.endef
hrdbf_file_append:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.L1826
	cmpq	$0, 2280(%rcx)
	je	.L1826
	cmpb	$0, 40(%rcx)
	je	.L1826
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1826:
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
	je	.L1833
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L1838:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl	%r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.L1851
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1837
	.p2align 4,,10
	.p2align 3
.L1835:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1851
.L1837:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.L1835
	jnb	.L1851
	leal	1(%r10), %r11d
.L1834:
	cmpl	%r9d, %r11d
	jb	.L1838
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.L1842
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.L1841:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.L1843
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1844
	.p2align 4,,10
	.p2align 3
.L1876:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1843
.L1844:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.L1876
.L1842:
	testl	%ebp, %ebp
	je	.L1832
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.L1877
	movl	%r11d, %r9d
.L1832:
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
.L1851:
	movl	%r10d, %r9d
	jmp	.L1834
.L1843:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.L1832
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.L1845
	.p2align 4,,10
	.p2align 3
.L1850:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl	%r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.L1846
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1849
	.p2align 4,,10
	.p2align 3
.L1847:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1846
.L1849:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.L1847
	jb	.L1846
	movl	%r9d, %r10d
.L1848:
	cmpl	%r10d, %r11d
	jb	.L1850
.L1845:
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
.L1846:
	leal	1(%r9), %r11d
	jmp	.L1848
.L1877:
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
.L1833:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.L1832
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.L1841
	.section .rdata,"dr"
.LC81:
	.ascii "hbc: DBF/NTX close failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_close
	.def	hrdbfw_app_close;	.scl	2;	.type	32;	.endef
hrdbfw_app_close:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	call	hrntx_file_close.constprop.0
	movq	2280+hrdbf_app_state(%rip), %rcx
	movq	$0, hrdbf_app_state(%rip)
	movq	$0, 8+hrdbf_app_state(%rip)
	movl	%eax, %ebx
	movl	$0, 16+hrdbf_app_state(%rip)
	movq	$0, 24+hrdbf_app_state(%rip)
	movl	$16842752, 36+hrdbf_app_state(%rip)
	movb	$0, 40+hrdbf_app_state(%rip)
	movl	$0, 2272+hrdbf_app_state(%rip)
	testq	%rcx, %rcx
	je	.L1883
	movq	$0, 2280+hrdbf_app_state(%rip)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	jne	.L1883
	movq	2256+hrdbf_app_state(%rip), %rcx
	testq	%rcx, %rcx
	je	.L1884
	movl	$7, %esi
	jmp	.L1880
	.p2align 4,,10
	.p2align 3
.L1883:
	movq	2256+hrdbf_app_state(%rip), %rcx
	testq	%rcx, %rcx
	jne	.L1893
.L1881:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.L1886
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.L1893:
	xorl	%esi, %esi
.L1880:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1884
	movq	$0, 2256+hrdbf_app_state(%rip)
	orl	%esi, %ebx
	movq	$0, 2264+hrdbf_app_state(%rip)
	jmp	.L1881
.L1884:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.L1886:
	leaq	.LC81(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
.LC82:
	.ascii "out of memory\0"
	.align 8
.LC83:
	.ascii "unsupported table version or header flags\0"
.LC84:
	.ascii "unsupported field type\0"
.LC85:
	.ascii "record content invalid\0"
.LC86:
	.ascii "I/O error\0"
	.align 8
.LC87:
	.ascii "size or field-count limit exceeded\0"
.LC88:
	.ascii "table format not supported\0"
	.align 8
.LC89:
	.ascii "hbc: DBF only one workarea is supported\12\0"
	.align 8
.LC90:
	.ascii "hbc: DBF filename length outside supported range\12\0"
	.align 8
.LC91:
	.ascii "hbc: DBF filename contains NUL\12\0"
.LC92:
	.ascii "hbc: DBF index close failed\12\0"
.LC93:
	.ascii "hbc: DBF open rejected: \0"
	.text
	.p2align 4
	.globl	hrdbfw_app_open
	.def	hrdbfw_app_open;	.scl	2;	.type	32;	.endef
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
	je	.L1895
	cmpb	$0, 40+hrdbf_app_state(%rip)
	jne	.L1941
.L1895:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.L1942
	xorl	%ebx, %ebx
	jmp	.L1896
	.p2align 4,,10
	.p2align 3
.L1914:
	movq	%rsi, %rbx
.L1896:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.L1943
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.L1914
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L1944
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	movq	$0, hrdbf_app_pos(%rip)
	jmp	.L1901
	.p2align 4,,10
	.p2align 3
.L1899:
	cmpq	%rcx, %rbx
	je	.L1945
.L1901:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.L1924
	cmpb	$92, %dl
	jne	.L1899
.L1924:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.L1901
.L1945:
	cmpq	%rsi, %r8
	jnb	.L1902
	movq	%r8, %rax
	jmp	.L1904
	.p2align 4,,10
	.p2align 3
.L1915:
	movq	%rdx, %rax
.L1904:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.L1915
.L1902:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.L1909
	.p2align 4,,10
	.p2align 3
.L1905:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.L1905
.L1909:
	xorl	%ebx, %ebx
	leaq	hrdbf_app_state(%rip), %rcx
	cmpq	$0, 384(%rsp)
	movb	$0, 2288+hrdbf_app_state(%rip)
	setne	%bl
	movb	$0, fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.L1946
.L1906:
	leaq	2288+hrdbf_app_state(%rip), %r12
	cmpb	$0, 2288+hrdbf_app_state(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.L1912
	leaq	.LC86(%rip), %r12
	cmpl	$7, %eax
	je	.L1912
	leaq	.LC82(%rip), %r12
	cmpl	$8, %eax
	je	.L1912
	leaq	.LC87(%rip), %r12
	cmpl	$4, %eax
	je	.L1912
	leaq	.LC83(%rip), %r12
	cmpl	$2, %eax
	je	.L1912
	leaq	.LC84(%rip), %r12
	cmpl	$3, %eax
	je	.L1912
	cmpl	$5, %eax
	leaq	.LC85(%rip), %r12
	leaq	.LC88(%rip), %rax
	cmovne	%rax, %r12
.L1912:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.LC80(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.L1946:
	movl	%ebx, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L1906
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.L1943:
	leaq	.LC91(%rip), %rcx
	call	hrdbf_app_fail
.L1942:
	leaq	.LC90(%rip), %rcx
	call	hrdbf_app_fail
.L1941:
	leaq	.LC89(%rip), %rcx
	call	hrdbf_app_fail
.L1944:
	leaq	.LC92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_top
	.def	hrdbfw_app_top;	.scl	2;	.type	32;	.endef
hrdbfw_app_top:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1957
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1949
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L1950
.L1949:
	movl	16+hrdbf_app_state(%rip), %eax
	movq	$1, 24+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1950:
	movl	24+hrdbf_app_order(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L1952
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx), %ecx
.L1953:
	testq	%rdx, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	sete	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1952:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
	jmp	.L1953
.L1957:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
	.def	hrdbfw_app_bottom;	.scl	2;	.type	32;	.endef
hrdbfw_app_bottom:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1969
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1960
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1960
	movl	24+hrdbf_app_order(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.L1970
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.L1964:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
.L1965:
	cmpq	%r8, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	setnb	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1970:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.L1964
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.L1965
	.p2align 4,,10
	.p2align 3
.L1960:
	movl	16+hrdbf_app_state(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, 24+hrdbf_app_state(%rip)
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
.L1969:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
	.def	hrdbfw_app_skip;	.scl	2;	.type	32;	.endef
hrdbfw_app_skip:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1989
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1973
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1973
	testq	%rcx, %rcx
	je	.L1971
	movb	$0, 38+hrdbf_app_state(%rip)
	movl	24+hrdbf_app_order(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.L1976
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.L1982
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.L1977:
	movq	%rdx, hrdbf_app_pos(%rip)
.L1978:
	cmpq	%rax, %rdx
	jnb	.L1980
	movq	16+hrdbf_app_order(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.L1981:
	movq	%rax, 24+hrdbf_app_state(%rip)
	movb	%cl, 39+hrdbf_app_state(%rip)
.L1971:
	ret
	.p2align 4,,10
	.p2align 3
.L1973:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L1982:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.L1977
	.p2align 4,,10
	.p2align 3
.L1980:
	movl	16+hrdbf_app_state(%rip), %eax
	addq	$1, %rax
	jmp	.L1981
	.p2align 4,,10
	.p2align 3
.L1976:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.L1979
	testq	%rax, %rax
	movb	$1, 38+hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.L1978
	.p2align 4,,10
	.p2align 3
.L1979:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.L1978
.L1989:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
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
	.ascii "hbc: DBF index only one index is supported\12\0"
	.align 8
.LC97:
	.ascii "hbc: DBF index filename length outside supported range\12\0"
	.align 8
.LC98:
	.ascii "hbc: DBF index filename contains NUL\12\0"
	.align 8
.LC99:
	.ascii "hbc: CDX must use a different basename from DBF; structural/autoopen indexes are outside this increment\12\0"
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
	subq	$336, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2064
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2065
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.L2066
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.L1993
	.p2align 4,,10
	.p2align 3
.L1995:
	cmpq	%rcx, %r9
	je	.L2067
.L2031:
	movq	%rcx, %rdx
.L1993:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.L2068
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.L2035
	cmpb	$92, %al
	jne	.L1995
.L2035:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.L2031
.L2067:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.L1997
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.L1999
	.p2align 4,,10
	.p2align 3
.L2032:
	movq	%r11, %rax
.L1999:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.L2032
	testl	%ebx, %ebx
	je	.L2003
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.L2029
.L2004:
	testl	%r10d, %r10d
	je	.L2027
.L2028:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2009
	testl	%ebx, %ebx
	je	.L2011
	leaq	64+hrdbf_app_order(%rip), %r9
	movq	%r12, %rcx
	movl	$0, 48(%rsp)
	movl	$512, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.L2023
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.L2022:
	cmpq	$67108864, %rbp
	ja	.L2063
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
	movq	%rdx, 56+hrdbf_app_order(%rip)
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, 40+hrdbf_app_order(%rip)
	testq	%rax, %rax
	je	.L2063
	testl	%esi, %esi
	leaq	hrntx_open(%rip), %rdx
	leaq	hrcdx_open(%rip), %r10
	movq	%rax, 32(%rsp)
	cmove	%rdx, %r10
	addq	%rdi, %rbx
	addq	%rax, %rbp
	movq	48+hrdbf_app_order(%rip), %r8
	movq	%rbx, 56(%rsp)
	movl	16+hrdbf_app_state(%rip), %ebx
	leaq	hrdbf_app_state(%rip), %r9
	leaq	hrdbf_app_order(%rip), %rcx
	movq	%rbp, 48(%rsp)
	movq	32+hrdbf_app_order(%rip), %rdx
	movq	%rbx, 40(%rsp)
	call	*%r10
	testl	%eax, %eax
	je	.L2016
	cmpl	$5, %eax
	je	.L2017
	.p2align 4,,10
	.p2align 3
.L2063:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2009
.L2018:
	leaq	.LC95(%rip), %rcx
	jmp	.L2019
	.p2align 4,,10
	.p2align 3
.L2003:
	testl	%r10d, %r10d
	je	.L2002
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2009
.L2011:
	leaq	64+hrdbf_app_order(%rip), %r9
	movq	%r12, %rcx
	movl	$0, 48(%rsp)
	movl	$1024, 40(%rsp)
	leaq	-16(%r9), %r8
	movq	$2048, 32(%rsp)
	leaq	-16(%r8), %rdx
	call	hrdbfw_snapshot
	movl	%eax, %esi
	testl	%eax, %eax
	jne	.L2023
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.L2022
	.p2align 4,,10
	.p2align 3
.L2002:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.L2026:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.L2028
.L1997:
	testl	%ebx, %ebx
	je	.L2002
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.L2069
	.p2align 4,,10
	.p2align 3
.L2027:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.L2026
	.p2align 4,,10
	.p2align 3
.L2023:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.L2009:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L2018
	cmpl	$3, %eax
	je	.L2020
	jmp	.L2018
	.p2align 4,,10
	.p2align 3
.L2016:
	movl	$1, hrdbf_app_order_active(%rip)
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
.L2069:
	xorl	%r10d, %r10d
.L2029:
	testq	%rdi, %rdi
	je	.L2005
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.L2008:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.L2008
	testl	%r11d, %r11d
	je	.L2004
.L2005:
	leaq	.LC99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2017:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2009
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.L2018
.L2020:
	leaq	.LC94(%rip), %rcx
.L2019:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2068:
	leaq	.LC98(%rip), %rcx
	call	hrdbf_app_fail
.L2065:
	leaq	.LC96(%rip), %rcx
	call	hrdbf_app_fail
.L2064:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L2066:
	leaq	.LC97(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_order_clear
	.def	hrdbfw_app_order_clear;	.scl	2;	.type	32;	.endef
hrdbfw_app_order_clear:
	pushq	%rsi
	pushq	%rbx
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2096
	movq	64+hrdbf_app_order(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, 8+hrdbf_app_order(%rip)
	movq	$0, 16+hrdbf_app_order(%rip)
	movq	$0, 24+hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	je	.L2097
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
	movq	32+hrdbf_app_order(%rip), %rcx
	testl	%eax, %eax
	jne	.L2076
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.L2098
.L2073:
	xorl	%edx, %edx
	movq	__imp_VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.L2077
	movq	40+hrdbf_app_order(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.L2078
.L2074:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.L2078
.L2099:
	movq	$0, 40+hrdbf_app_order(%rip)
	movq	$0, 56+hrdbf_app_order(%rip)
.L2079:
	testl	%esi, %esi
	jne	.L2078
.L2075:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.L2076:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.L2073
.L2094:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	__imp_VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.L2075
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.L2099
	.p2align 4,,10
	.p2align 3
.L2078:
	leaq	.LC92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2097:
	movq	32+hrdbf_app_order(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.L2073
	jmp	.L2094
	.p2align 4,,10
	.p2align 3
.L2077:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	$0, 32+hrdbf_app_order(%rip)
	movq	$0, 48+hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	jne	.L2074
	jmp	.L2079
	.p2align 4,,10
	.p2align 3
.L2098:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	__imp_VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.L2074
	jmp	.L2078
.L2096:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
	.def	hrdbfw_app_found;	.scl	2;	.type	32;	.endef
hrdbfw_app_found:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2105
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2105:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC100:
	.ascii "hbc: DBF index seek requires an open index\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_seek
	.def	hrdbfw_app_seek;	.scl	2;	.type	32;	.endef
hrdbfw_app_seek:
	subq	$72, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2113
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2108
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2108
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
	jb	.L2114
	movl	16+hrdbf_app_state(%rip), %r9d
	addq	$1, %r9
.L2111:
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
.L2114:
	movq	16+hrdbf_app_order(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.L2111
.L2108:
	leaq	.LC100(%rip), %rcx
	call	hrdbf_app_fail
.L2113:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC101:
	.ascii "hbc: DBF index seek expects a character key value\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_seek_dyn
	.def	hrdbfw_app_seek_dyn;	.scl	2;	.type	32;	.endef
hrdbfw_app_seek_dyn:
	subq	$40, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2121
	movzbl	%cl, %ecx
	subl	$2, %ecx
	andl	$-3, %ecx
	jne	.L2119
	movq	%rdx, %r10
	testq	%rdx, %rdx
	je	.L2119
	movq	-8(%rdx), %rdx
	movq	%r10, %rcx
	addq	$40, %rsp
	jmp	hrdbfw_app_seek
.L2119:
	leaq	.LC101(%rip), %rcx
	call	hrdbf_app_fail
.L2121:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
	.def	hrdbfw_app_recno;	.scl	2;	.type	32;	.endef
hrdbfw_app_recno:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2127
	movq	24+hrdbf_app_state(%rip), %rax
	ret
.L2127:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
	.def	hrdbfw_app_lastrec;	.scl	2;	.type	32;	.endef
hrdbfw_app_lastrec:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2133
	movl	16+hrdbf_app_state(%rip), %eax
	ret
.L2133:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
	.def	hrdbfw_app_fcount;	.scl	2;	.type	32;	.endef
hrdbfw_app_fcount:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2139
	movzwl	36+hrdbf_app_state(%rip), %eax
	ret
.L2139:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
	.def	hrdbfw_app_goto;	.scl	2;	.type	32;	.endef
hrdbfw_app_goto:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2154
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	16+hrdbf_app_state(%rip), %eax
	testq	%rcx, %rcx
	jle	.L2142
	cmpq	%rax, %rcx
	jbe	.L2143
.L2142:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, 24+hrdbf_app_state(%rip)
	movw	%cx, 38+hrdbf_app_state(%rip)
.L2144:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2140
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2155
.L2140:
	ret
	.p2align 4,,10
	.p2align 3
.L2143:
	xorl	%edx, %edx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	movw	%dx, 38+hrdbf_app_state(%rip)
	jmp	.L2144
	.p2align 4,,10
	.p2align 3
.L2155:
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r8
	testl	%ecx, %ecx
	je	.L2149
	movq	16+hrdbf_app_order(%rip), %r9
	xorl	%eax, %eax
	jmp	.L2148
	.p2align 4,,10
	.p2align 3
.L2147:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2146
.L2148:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.L2147
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2149:
	xorl	%ecx, %ecx
.L2146:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2154:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
	.def	hrdbfw_app_ordselect;	.scl	2;	.type	32;	.endef
hrdbfw_app_ordselect:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2169
	cmpq	$1, %rcx
	jne	.L2158
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2158
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r8
	movl	$1, hrdbf_app_order_active(%rip)
	testl	%ecx, %ecx
	je	.L2164
	movq	16+hrdbf_app_order(%rip), %r9
	xorl	%eax, %eax
	jmp	.L2163
	.p2align 4,,10
	.p2align 3
.L2162:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2161
.L2163:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.L2162
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2158:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.L2164:
	xorl	%ecx, %ecx
.L2161:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2169:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
	.def	hrdbfw_app_bof;	.scl	2;	.type	32;	.endef
hrdbfw_app_bof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2175
	movzbl	38+hrdbf_app_state(%rip), %eax
	ret
.L2175:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
	.def	hrdbfw_app_eof;	.scl	2;	.type	32;	.endef
hrdbfw_app_eof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2181
	movzbl	39+hrdbf_app_state(%rip), %eax
	ret
.L2181:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
	.def	hrdbfw_app_deleted;	.scl	2;	.type	32;	.endef
hrdbfw_app_deleted:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2189
	movq	24+hrdbf_app_state(%rip), %rax
	movl	16+hrdbf_app_state(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2182
	movzwl	34+hrdbf_app_state(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2182:
	movq	%r8, %rax
	ret
.L2189:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_get
	.def	hrdbfw_app_get;	.scl	2;	.type	32;	.endef
hrdbfw_app_get:
	pushq	%r12
	subq	$32, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2196
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.L2192
	movzwl	36+hrdbf_app_state(%rip), %eax
	cmpq	%rax, %rdx
	jle	.L2193
.L2192:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2193:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.L2196:
	leaq	.LC76(%rip), %rcx
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
	je	.L2198
	movzwl	36+hrdbf_app_state(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.L2200
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.L2212:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2201:
	cmpb	$0, (%r10,%rax)
	je	.L2202
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2201
.L2202:
	cmpq	%r8, %rax
	je	.L2222
.L2204:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.L2212
.L2200:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2222:
	testq	%r8, %r8
	je	.L2205
	xorl	%ecx, %ecx
	jmp	.L2209
	.p2align 4,,10
	.p2align 3
.L2223:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.L2205
.L2209:
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
	je	.L2223
	cmpq	%rcx, %r8
	jne	.L2204
	.p2align 4,,10
	.p2align 3
.L2205:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.L2210
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
.L2210:
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
.L2198:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC102:
	.ascii "hbc: DBF field ordinal outside the open area\12\0"
	.align 8
.LC103:
	.ascii "hbc: DBF field write type mismatch\12\0"
	.align 8
.LC104:
	.ascii "hbc: DBF field write encoding rejected\12\0"
	.align 8
.LC105:
	.ascii "hbc: DBF field write commit failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_fieldput
	.def	hrdbfw_app_fieldput;	.scl	2;	.type	32;	.endef
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
	jle	.L2225
	movzwl	36+hrdbf_app_state(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r9
	cmpq	%rbx, %rax
	jl	.L2225
	movq	24+hrdbf_app_state(%rip), %rdx
	movzwl	34+hrdbf_app_state(%rip), %eax
	leaq	-1(%rbx), %r10
	addq	$1, %rbx
	salq	$4, %rbx
	movzbl	%dil, %r8d
	leaq	-1(%rdx), %rcx
	leaq	10(%r9,%rbx), %r11
	addq	%r9, %rbx
	imulq	%rax, %rcx
	movzwl	32+hrdbf_app_state(%rip), %eax
	addq	%rax, %rcx
	movzbl	21(%rbx), %eax
	addq	2256+hrdbf_app_state(%rip), %rcx
	cmpb	$76, %al
	je	.L2227
	ja	.L2228
	cmpb	$67, %al
	je	.L2229
	cmpb	$68, %al
	jne	.L2231
	cmpl	$11, %r8d
	je	.L2286
	cmpl	$1, %r8d
	jne	.L2231
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2240
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2251
	.p2align 4,,10
	.p2align 3
.L2287:
	addq	$1, %rax
.L2251:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2287
.L2236:
	movq	24+hrdbf_app_state(%rip), %rdx
.L2240:
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2288
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L2228:
	cmpb	$78, %al
	jne	.L2231
	cmpl	$12, %r8d
	je	.L2289
	testl	%r8d, %r8d
	je	.L2259
	cmpl	$9, %r8d
	je	.L2259
	cmpl	$5, %r8d
	je	.L2290
	cmpl	$1, %r8d
	jne	.L2231
	addq	$2, %r10
	salq	$4, %r10
	addq	%r10, %r9
	movzbl	22(%r9), %r8d
	movzwl	24(%r9), %eax
	testl	%r8d, %r8d
	je	.L2240
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2249
	.p2align 4,,10
	.p2align 3
.L2291:
	addq	$1, %rax
.L2249:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2291
	jmp	.L2236
	.p2align 4,,10
	.p2align 3
.L2229:
	leal	-2(%r8), %eax
	andl	$-3, %eax
	je	.L2292
	cmpl	$1, %r8d
	jne	.L2231
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2240
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2241
	.p2align 4,,10
	.p2align 3
.L2293:
	addq	$1, %rax
.L2241:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2293
	jmp	.L2236
	.p2align 4,,10
	.p2align 3
.L2227:
	cmpl	$3, %r8d
	je	.L2294
	cmpl	$1, %r8d
	jne	.L2231
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2240
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2254
	.p2align 4,,10
	.p2align 3
.L2295:
	addq	$1, %rax
.L2254:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2295
	jmp	.L2236
	.p2align 4,,10
	.p2align 3
.L2289:
	movl	%edi, %eax
	movq	%rsi, %r8
	movq	%r11, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.L2243:
	cmpl	$3, %eax
	je	.L2231
	testl	%eax, %eax
	je	.L2236
	leaq	.LC104(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2294:
	cmpq	$1, %rsi
	movzwl	24(%rbx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	24+hrdbf_app_state(%rip), %rdx
	jmp	.L2240
	.p2align 4,,10
	.p2align 3
.L2292:
	movzwl	24(%rbx), %eax
	movzbl	22(%rbx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%rsi)
	movq	%rdx, %rax
	cmovbe	-8(%rsi), %rax
	testq	%rax, %rax
	je	.L2234
	movq	%rcx, %r8
	leaq	(%rsi,%rax), %r11
	subq	%rsi, %r8
	.p2align 4,,10
	.p2align 3
.L2235:
	movzbl	(%rsi), %edx
	movb	%dl, (%r8,%rsi)
	addq	$1, %rsi
	cmpq	%r11, %rsi
	jne	.L2235
	movq	%r10, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r9), %edx
.L2234:
	cmpq	%rax, %rdx
	jbe	.L2236
	leaq	2(%r10), %rdx
	salq	$4, %rdx
	addq	%rdx, %r9
	.p2align 4,,10
	.p2align 3
.L2237:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r9), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2237
	jmp	.L2236
	.p2align 4,,10
	.p2align 3
.L2286:
	movl	%esi, %r8d
	movq	%r11, %rdx
	call	hrdbf_write_date
	jmp	.L2243
.L2231:
	leaq	.LC103(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2259:
	xorl	%r9d, %r9d
	movq	%rsi, %r8
	movq	%r11, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2243
	.p2align 4,,10
	.p2align 3
.L2290:
	testq	%rdi, %rdi
	jns	.L2247
	movq	(%rsi), %rsi
.L2247:
	movq	%rsi, %xmm2
	movq	%r11, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.L2243
.L2225:
	leaq	.LC102(%rip), %rcx
	call	hrdbf_app_fail
.L2288:
	leaq	.LC105(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_set_name
	.def	hrdbfw_app_set_name;	.scl	2;	.type	32;	.endef
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
	movzwl	36+hrdbf_app_state(%rip), %ebx
	testl	%ebx, %ebx
	je	.L2297
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L2307:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2298:
	cmpb	$0, (%r10,%rax)
	je	.L2299
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2298
.L2299:
	cmpq	%r12, %rax
	je	.L2320
.L2301:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.L2307
.L2297:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2320:
	testq	%r12, %r12
	je	.L2302
	xorl	%ecx, %ecx
	jmp	.L2306
	.p2align 4,,10
	.p2align 3
.L2321:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.L2302
.L2306:
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
	je	.L2321
	cmpq	%rcx, %r12
	jne	.L2301
.L2302:
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
.LC106:
	.ascii "hbc: DBF append failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_append
	.def	hrdbfw_app_append;	.scl	2;	.type	32;	.endef
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2330
	movl	2272+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L2331
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2332
	movl	16+hrdbf_app_state(%rip), %eax
	cmpq	%rax, 24+hrdbf_app_state(%rip)
	ja	.L2333
	cmpq	$0, 2280+hrdbf_app_state(%rip)
	je	.L2328
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2328
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2328:
	leaq	.LC106(%rip), %rcx
	call	hrdbf_app_fail
.L2330:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L2333:
	leaq	.LC79(%rip), %rcx
	call	hrdbf_app_fail
.L2332:
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L2331:
	leaq	.LC77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC107:
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
	jne	.L2337
	movq	56(%rsp), %rax
	leave
	ret
.L2337:
	leaq	.LC107(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC108:
	.ascii "hbc: DBF decimal numeric cannot enter I64 operation\12\0"
	.align 8
.LC109:
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
	jne	.L2339
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L2355
	testl	%eax, %eax
	je	.L2347
	cmpl	$9, %eax
	jne	.L2343
.L2347:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2355:
	testl	$65280, %r11d
	je	.L2347
.L2342:
	leaq	.LC108(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2339:
	cmpl	$2, %eax
	je	.L2342
.L2343:
	leaq	.LC109(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC110:
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
	jne	.L2359
	movslq	76(%rsp), %rax
	leave
	ret
.L2359:
	leaq	.LC110(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC111:
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
	jne	.L2361
	cmpb	$11, %r8b
	je	.L2368
.L2361:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2369
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L2368:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2363
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2363
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
.L2369:
	leaq	.LC110(%rip), %rcx
	call	hrdbf_app_fail
.L2363:
	leaq	.LC111(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC112:
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
	jne	.L2371
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.L2383
	movabsq	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.L2373
	.p2align 4,,10
	.p2align 3
.L2391:
	btq	%rax, %rcx
	jnc	.L2387
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.L2383
.L2373:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.L2391
.L2387:
	xorl	%eax, %eax
.L2370:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2371:
	cmpl	$8, %ebx
	je	.L2392
	cmpl	$5, %ebx
	je	.L2393
	cmpl	$7, %ebx
	je	.L2387
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2378
	cmpl	$12, %ebx
	ja	.L2378
	leaq	.L2380(%rip), %rdx
	movslq	(%rdx,%rbx,4), %rax
	addq	%rdx, %rax
	jmp	*%rax
	.section .rdata,"dr"
	.align 4
.L2380:
	.long	.L2379-.L2380
	.long	.L2383-.L2380
	.long	.L2378-.L2380
	.long	.L2379-.L2380
	.long	.L2378-.L2380
	.long	.L2378-.L2380
	.long	.L2378-.L2380
	.long	.L2378-.L2380
	.long	.L2378-.L2380
	.long	.L2379-.L2380
	.long	.L2378-.L2380
	.long	.L2379-.L2380
	.long	.L2379-.L2380
	.text
	.p2align 4,,10
	.p2align 3
.L2383:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2392:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.L2370
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.L2370
	.p2align 4,,10
	.p2align 3
.L2378:
	leaq	.LC112(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2393:
	testq	%rcx, %rcx
	js	.L2394
.L2377:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.LC65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.L2370
.L2379:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.L2370
.L2394:
	movq	(%rdx), %r11
	jmp	.L2377
	.section .rdata,"dr"
	.align 8
.LC113:
	.ascii "hbc: DBF arithmetic division by zero\12\0"
	.align 8
.LC114:
	.ascii "hbc: DBF arithmetic on a NIL or non-numeric operand\12\0"
.LC115:
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
	je	.L2400
	cmpl	$1, %eax
	je	.L2401
	testl	%eax, %eax
	jne	.L2402
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.L2400:
	leaq	.LC113(%rip), %rcx
	call	hrdbf_app_fail
.L2402:
	leaq	.LC115(%rip), %rcx
	call	hrdbf_app_fail
.L2401:
	leaq	.LC114(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC116:
	.ascii "hbc: DBF-active dynamic scalar consumer is outside the admitted subset\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
	.def	hrdbfw_app_unsupported;	.scl	2;	.type	32;	.endef
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.LC116(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
CSWTCH.365:
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
.lcomm hrdbf_app_baselen,8,8
.lcomm hrdbf_app_basename,260,32
.lcomm hrdbf_app_cdx,4,4
.lcomm hrdbf_app_order_active,4,4
.lcomm hrdbf_app_found_flag,4,4
.lcomm hrdbf_app_pos,8,8
.lcomm hrdbf_app_order,72,32
.lcomm hrdbf_app_state,2448,32
.lcomm fsink_len,4,4
.lcomm fsink,160,32
	.align 8
.LC0:
	.long	0
	.long	1076101120
	.align 8
.LC65:
	.long	0
	.long	0
