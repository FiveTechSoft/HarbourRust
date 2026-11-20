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
	js	.L353
	jne	.L336
	movb	$48, (%rsp)
	movl	$1, %ecx
	subq	$1, %r11
	je	.L338
.L337:
	leaq	(%r8,%r9), %rdx
	leaq	(%rdx,%r11), %r10
	.p2align 4,,10
	.p2align 3
.L342:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%r10, %rdx
	jne	.L342
	addq	%r9, %r11
.L338:
	movq	%rsp, %r10
	addq	%r11, %r8
	leaq	(%r10,%rcx), %rdx
	.p2align 4,,10
	.p2align 3
.L343:
	movzbl	-1(%rdx), %r9d
	subq	$1, %rdx
	addq	$1, %r8
	movb	%r9b, -1(%r8)
	cmpq	%r10, %rdx
	jne	.L343
	addq	$40, %rsp
	leaq	(%rcx,%r11), %rax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L353:
	negq	%r9
.L336:
	xorl	%ecx, %ecx
	leaq	-1(%rsp), %rbp
	movabsq	$-3689348814741910323, %rsi
	.p2align 4,,10
	.p2align 3
.L339:
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
	ja	.L339
	testq	%rdi, %rdi
	jns	.L345
	movb	$45, (%r8)
	addq	$2, %rbx
	movl	$1, %r9d
.L340:
	subq	%rbx, %r11
	jne	.L337
	movq	%r9, %r11
	jmp	.L338
.L345:
	movq	%rcx, %rbx
	xorl	%r9d, %r9d
	jmp	.L340
	.p2align 4
	.def	hrdbf_app_write;	.scl	3;	.type	32;	.endef
hrdbf_app_write:
	pushq	%r12
	movq	%rcx, %r12
	pushq	%rbx
	xorl	%ebx, %ebx
	subq	$72, %rsp
	cmpb	$0, (%rcx)
	je	.L355
	.p2align 4,,10
	.p2align 3
.L356:
	addq	$1, %rbx
	cmpb	$0, (%r12,%rbx)
	jne	.L356
.L355:
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
	je	.L363
	movq	__imp_WriteFile(%rip), %rbp
	leaq	60(%rsp), %r12
	testq	%rbx, %rbx
	jne	.L364
	jmp	.L365
	.p2align 4,,10
	.p2align 3
.L376:
	movl	60(%rsp), %eax
	testl	%eax, %eax
	je	.L363
	cmpq	%rax, %rbx
	jb	.L363
	addq	%rax, %rsi
	subq	%rax, %rbx
	je	.L365
.L364:
	movq	2280(%rdi), %rcx
	movq	%r12, %r9
	movl	%ebx, %r8d
	movq	%rsi, %rdx
	movl	$0, 60(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbp
	testl	%eax, %eax
	jne	.L376
.L363:
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
.L365:
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
	ja	.L377
	movzwl	34(%rcx), %esi
	subq	$1, %rdx
	movzwl	56(%rax), %eax
	imulq	%rsi, %rdx
	movzwl	32(%rcx), %esi
	addq	%rsi, %rdx
	addq	%rax, %rdx
	addq	(%rcx), %rdx
	cmpb	$67, %r9b
	je	.L457
	cmpb	$78, %r9b
	je	.L458
	movzbl	(%rdx), %ecx
	cmpb	$68, %r9b
	je	.L459
	movl	%ecx, %eax
	andl	$-33, %eax
	cmpb	$84, %al
	je	.L404
	cmpb	$89, %al
	je	.L404
	movl	%ecx, %eax
	andl	$-9, %eax
	cmpb	$102, %al
	je	.L377
	subl	$32, %ecx
	movl	$5, %r11d
	cmpb	$46, %cl
	ja	.L377
	movabsq	$70645769568257, %r11
	shrq	%cl, %r11
	notq	%r11
	sall	$31, %r11d
	sarl	$31, %r11d
	andl	$5, %r11d
.L377:
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
.L404:
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
.L458:
	movzbl	%bl, %ecx
	testl	%ecx, %ecx
	je	.L381
	movq	%rdx, %r9
	xorl	%eax, %eax
	jmp	.L382
	.p2align 4,,10
	.p2align 3
.L383:
	addl	$1, %eax
	addq	$1, %r9
	cmpl	%eax, %ecx
	je	.L381
.L382:
	movzbl	(%r9), %r11d
	cmpb	$32, %r11b
	je	.L383
	jmp	.L385
	.p2align 4,,10
	.p2align 3
.L409:
	movl	%r9d, %ecx
.L385:
	cmpl	%eax, %ecx
	jbe	.L384
	leal	-1(%rcx), %ebx
	cmpb	$32, (%rdx,%rbx)
	movq	%rbx, %r9
	je	.L409
	leal	-43(%r11), %ebx
	andl	$253, %ebx
	je	.L387
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
.L407:
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
	jmp	.L391
	.p2align 4,,10
	.p2align 3
.L461:
	testl	%esi, %esi
	jne	.L428
	movl	$1, %esi
.L389:
	addq	$1, %r11
	cmpq	%r11, %r9
	je	.L460
.L391:
	movzbl	(%r11), %eax
	movq	%rax, %rcx
	cmpb	$46, %al
	je	.L461
.L428:
	subl	$48, %eax
	cmpl	$9, %eax
	ja	.L421
	movl	%eax, %r14d
	movq	%rdi, %rdx
	subq	%r14, %rdx
	movq	%rdx, %rax
	mulq	%r13
	shrq	$3, %rdx
	cmpq	%rbx, %rdx
	jb	.L418
	leaq	(%rbx,%rbx,4), %rax
	movl	$1, %edx
	leaq	-48(%rcx,%rax,2), %rbx
	testl	%esi, %esi
	je	.L389
	addl	$1, %ebp
	movl	%esi, %edx
	jmp	.L389
	.p2align 4,,10
	.p2align 3
.L457:
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
.L459:
	leaq	8(%rdx), %rcx
	movq	%rdx, %rax
	.p2align 4,,10
	.p2align 3
.L400:
	cmpb	$32, (%rax)
	jne	.L420
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.L400
	movl	$0, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L377
	.p2align 4,,10
	.p2align 3
.L421:
	movl	$5, %r11d
	jmp	.L377
	.p2align 4,,10
	.p2align 3
.L420:
	xorl	%r9d, %r9d
	.p2align 4,,10
	.p2align 3
.L399:
	movzbl	(%rdx), %eax
	leal	-48(%rax), %r10d
	cmpb	$9, %r10b
	ja	.L421
	leal	(%r9,%r9,4), %r9d
	addq	$1, %rdx
	leal	-48(%rax,%r9,2), %r9d
	cmpq	%rcx, %rdx
	jne	.L399
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
	jbe	.L377
	cmpl	$11, %edx
	ja	.L377
	testl	%r10d, %r10d
	je	.L377
	leaq	days.1(%rip), %r11
	movzbl	(%r11,%rdx), %edx
	cmpl	$2, %eax
	je	.L462
.L402:
	movl	$5, %r11d
	cmpl	%edx, %r10d
	ja	.L377
	movl	%r9d, 24(%r8)
	xorl	%r11d, %r11d
	jmp	.L377
	.p2align 4,,10
	.p2align 3
.L387:
	movabsq	$9223372036854775807, %r9
	cmpb	$45, %r11b
	sete	%dil
	sete	%r12b
	addl	$1, %eax
	movzbl	%dil, %edi
	movzbl	%r12b, %r12d
	addq	%r9, %rdi
.L388:
	cmpl	%eax, %ecx
	jbe	.L421
	leal	-1(%rcx), %r9d
	jmp	.L407
	.p2align 4,,10
	.p2align 3
.L418:
	movl	$4, %r11d
	jmp	.L377
	.p2align 4,,10
	.p2align 3
.L460:
	movl	$5, %r11d
	testl	%edx, %edx
	je	.L377
	cmpl	%ebp, %r10d
	jb	.L377
	leal	1(%rbp), %eax
	jbe	.L392
	movabsq	$922337203685477580, %rcx
	cmpq	%rcx, %rbx
	jbe	.L393
	jmp	.L418
	.p2align 4,,10
	.p2align 3
.L394:
	cmpq	%rcx, %rbx
	ja	.L418
.L393:
	leaq	(%rbx,%rbx,4), %rbx
	movl	%eax, %edx
	addl	$1, %eax
	addq	%rbx, %rbx
	cmpl	%edx, %r10d
	jne	.L394
	testl	%r12d, %r12d
	jne	.L406
.L397:
	movq	%rbx, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L377
.L384:
	je	.L381
	movl	%eax, %r9d
	movzbl	(%rdx,%r9), %r11d
	leal	-43(%r11), %r9d
	andl	$253, %r9d
	je	.L387
	movabsq	$9223372036854775807, %rdi
	xorl	%r12d, %r12d
	jmp	.L388
	.p2align 4,,10
	.p2align 3
.L381:
	movq	$0, 16(%r8)
	xorl	%r11d, %r11d
	jmp	.L377
.L462:
	movl	$3518437209, %eax
	imulq	%rax, %rcx
	shrq	$45, %rcx
	testb	$3, %cl
	jne	.L402
	imull	$-1030792151, %ecx, %ecx
	movl	%ecx, %eax
	rorl	$2, %eax
	cmpl	$42949672, %eax
	ja	.L403
	rorl	$4, %ecx
	cmpl	$10737418, %ecx
	ja	.L402
.L403:
	addl	$1, %edx
	jmp	.L402
.L392:
	testl	%r12d, %r12d
	je	.L397
	movabsq	$-9223372036854775808, %rax
	cmpq	%rax, %rbx
	je	.L397
.L406:
	negq	%rbx
	jmp	.L397
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
	je	.L466
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L478
.L466:
	xorl	%r12d, %r12d
.L465:
	movq	32+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L467
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L479
	movl	$7, %r12d
.L467:
	movq	40+hrdbf_app_order(%rip), %rcx
	testq	%rcx, %rcx
	je	.L463
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L470
	movq	$0, 40+hrdbf_app_order(%rip)
	movq	$0, 56+hrdbf_app_order(%rip)
.L463:
	addq	$32, %rsp
	movl	%r12d, %eax
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L479:
	movq	$0, 32+hrdbf_app_order(%rip)
	movq	$0, 48+hrdbf_app_order(%rip)
	jmp	.L467
	.p2align 4,,10
	.p2align 3
.L478:
	movl	$7, %r12d
	jmp	.L465
	.p2align 4,,10
	.p2align 3
.L470:
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
	jne	.L480
	orl	%ecx, %eax
	movb	%al, (%rdx)
.L480:
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
	ja	.L486
	movq	%rdx, %rdi
	testq	%rdx, %rdx
	je	.L486
	movq	%r8, %rsi
	testl	$511, %r8d
	jne	.L486
	movq	%r9, %rbp
	testq	%r9, %r9
	je	.L486
	cmpb	$0, 40(%r9)
	je	.L486
	movq	%rcx, %rbx
	movl	$1, %r8d
	movl	$224, %edx
	movq	%rdi, %rcx
	call	cxheader
	testl	%eax, %eax
	jne	.L482
	cmpw	$10, 12(%rdi)
	movl	$2, %eax
	jne	.L482
	cmpw	$1, 510(%rdi)
	jne	.L482
	cmpb	$0, 512(%rdi)
	jne	.L482
	movl	(%rdi), %r12d
	cmpl	$1023, %r12d
	jbe	.L486
	testl	$511, %r12d
	jne	.L486
	movl	%r12d, %edx
	leaq	-512(%rsi), %r13
	cmpq	%r13, %rdx
	ja	.L486
	leaq	(%rdi,%rdx), %r14
	cmpw	$3, (%r14)
	jne	.L482
	cmpw	$1, 2(%rdi,%rdx)
	jne	.L482
	cmpl	$-1, 4(%rdi,%rdx)
	jne	.L486
	cmpl	$-1, 8(%rdi,%rdx)
	jne	.L486
	leaq	96(%rsp), %r10
	movl	$10, %edx
	movq	%r14, %rcx
	movq	%r10, %r8
	movq	%r10, 72(%rsp)
	call	cxleaf_header
	testl	%eax, %eax
	jne	.L482
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
	jne	.L482
	movl	112(%rsp), %eax
	leal	24(%rax), %edx
	movq	88(%rsp), %rax
	subq	%rdx, %rax
	movzwl	98(%rsp), %edx
	cmpq	%rdx, %rax
	jne	.L486
	movl	84(%rsp), %eax
	cmpl	$1023, %eax
	jbe	.L486
	testl	$511, %eax
	jne	.L486
	movl	%eax, %r11d
	cmpq	%r11, %r13
	jb	.L486
	leaq	-1024(%rsi), %rdx
	cmpq	%r11, %rdx
	jb	.L486
	cmpl	%r12d, %eax
	je	.L486
	leal	512(%rax), %r10d
	cmpl	%r12d, %r10d
	je	.L486
	movabsq	$-8646911293074243583, %rdx
	xorl	%eax, %eax
	jmp	.L487
.L560:
	movq	%rdx, %r14
	shrq	%cl, %r14
	movq	%r14, %rcx
	andb	$1, %cl
	je	.L524
	addq	$1, %rax
	cmpq	$10, %rax
	je	.L559
.L487:
	movzbl	(%r15,%rax), %ecx
	subl	$32, %ecx
	cmpb	$63, %cl
	jbe	.L560
.L524:
	movl	$2, %eax
	jmp	.L482
	.p2align 4,,10
	.p2align 3
.L486:
	movl	$1, %eax
.L482:
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
.L559:
	xorl	%r8d, %r8d
	leaq	(%rdi,%r11), %rcx
	movl	$96, %edx
	call	cxheader
	testl	%eax, %eax
	jne	.L482
	movzwl	510(%rdi,%r11), %eax
	leaq	-2(%rax), %rdx
	cmpq	$254, %rdx
	ja	.L524
	movl	%r10d, %edx
	leaq	(%rdx,%rax), %rcx
	cmpb	$0, -1(%rdi,%rcx)
	jne	.L524
	cmpb	$0, (%rdi,%rcx)
	jne	.L524
	xorl	%ecx, %ecx
	leaq	(%rdi,%rdx), %r14
	subq	$1, %rax
.L488:
	cmpb	$0, (%r14,%rcx)
	je	.L524
	addq	$1, %rcx
	cmpq	%rcx, %rax
	ja	.L488
	movzwl	36(%rbp), %ecx
	xorl	%r9d, %r9d
	movl	%ecx, 72(%rsp)
	movq	%rcx, %r8
.L489:
	cmpq	%r9, %r8
	jbe	.L524
	movq	%r9, %r10
	xorl	%edx, %edx
	salq	$4, %r10
	addq	%rbp, %r10
.L498:
	movzbl	42(%r10,%rdx), %ecx
	testb	%cl, %cl
	je	.L492
	leal	-97(%rcx), %r13d
	cmpb	$25, %r13b
	ja	.L493
	subl	$32, %ecx
.L493:
	movzbl	(%r14,%rdx), %r13d
	leal	-97(%r13), %r15d
	cmpb	$25, %r15b
	ja	.L494
	subl	$32, %r13d
.L494:
	cmpb	%cl, %r13b
	jne	.L492
	addq	$1, %rdx
	cmpq	%rdx, %rax
	je	.L490
	cmpq	$11, %rdx
	jne	.L498
	cmpq	$11, %rax
	jne	.L492
.L496:
	cmpl	%r9d, 72(%rsp)
	je	.L524
	cmpb	$67, 53(%r10)
	jne	.L524
	movzbl	54(%r10), %eax
	cmpb	$-16, %al
	ja	.L523
	cmpw	12(%rdi,%r11), %ax
	jne	.L524
	movl	16(%rbp), %eax
	cmpq	1080(%rsp), %rax
	ja	.L528
	cmpq	$0, 1072(%rsp)
	jne	.L530
	testl	%eax, %eax
	jne	.L528
.L530:
	movq	%rsi, %r11
	addq	$7, %rax
	shrq	$9, %r11
	shrq	$3, %rax
	addq	$7, %r11
	shrq	$3, %r11
	cmpq	$0, 1088(%rsp)
	je	.L528
	addq	%r11, %rax
	cmpq	1096(%rsp), %rax
	ja	.L528
	xorl	%edx, %edx
.L500:
	movq	1088(%rsp), %rcx
	movb	$0, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jne	.L500
	movzbl	(%rcx), %eax
	testb	$1, %al
	jne	.L501
	orl	$1, %eax
	movb	%al, (%rcx)
.L501:
	testb	$2, %al
	jne	.L502
	movq	1088(%rsp), %rcx
	orl	$2, %eax
	movb	%al, (%rcx)
.L502:
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
.L503:
	movl	$0, 312(%rax)
	addq	$4, %rax
	movl	$0, 52(%rax)
	cmpq	%rdx, %rax
	jne	.L503
	movl	84(%rsp), %eax
	xorl	%r8d, %r8d
	movq	%rsi, %rcx
	movl	(%rdi,%rax), %edx
	call	cxvisit
	testl	%eax, %eax
	je	.L561
.L504:
	movq	$0, (%rbx)
	movq	$0, 8(%rbx)
	movq	$0, 16(%rbx)
	movq	$0, 24(%rbx)
	jmp	.L482
.L490:
	cmpq	$11, %rax
	je	.L496
	movq	%r9, %rdx
	salq	$4, %rdx
	addq	%rbp, %rdx
	cmpb	$0, 42(%rdx,%rax)
	je	.L496
.L492:
	addq	$1, %r9
	jmp	.L489
.L528:
	movl	$3, %eax
	jmp	.L482
.L523:
	movl	$5, %eax
	jmp	.L482
.L561:
	movl	432(%rsp), %ecx
	movl	$4, %eax
	cmpl	16(%rbp), %ecx
	jne	.L504
	xorl	%edx, %edx
	jmp	.L506
.L562:
	cmpq	$63, %rdx
	ja	.L531
.L506:
	movl	56(%rsi,%rdx,4), %eax
	testl	%eax, %eax
	je	.L505
	xorl	%eax, %eax
	cmpl	$-1, 312(%rsi,%rdx,4)
	setne	%al
.L505:
	addq	$1, %rdx
	testb	$1, %al
	je	.L562
.L531:
	testl	%eax, %eax
	jne	.L504
	movl	%ecx, 24(%rbx)
	jmp	.L482
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
	ja	.L563
	movq	%rcx, %rbx
	movq	%rdx, %rdi
	movl	$4, %r9d
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	movq	%rbp, %rdx
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, %r13
	testq	%rax, %rax
	je	.L571
	xorl	%edx, %edx
	xorl	%eax, %eax
	cmpq	$0, 2264(%rbx)
	je	.L568
	.p2align 4,,10
	.p2align 3
.L565:
	movq	2256(%rbx), %rcx
	movzbl	(%rcx,%rax), %ecx
	movb	%cl, 0(%r13,%rax)
	leal	1(%rdx), %eax
	movq	%rax, %rdx
	cmpq	2264(%rbx), %rax
	jb	.L565
.L568:
	leaq	0(%r13,%r12), %r14
	xorl	%eax, %eax
	cmpw	$0, 34(%rbx)
	movq	%r14, %rdx
	je	.L567
	.p2align 4,,10
	.p2align 3
.L566:
	movb	$32, (%r14,%rax)
	movzwl	34(%rbx), %ecx
	addq	$1, %rax
	movq	%rcx, %rdx
	cmpl	%eax, %ecx
	ja	.L566
	addq	%r14, %rdx
.L567:
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
	je	.L583
.L569:
	movl	$32768, %r8d
	xorl	%edx, %edx
	movq	%r13, %rcx
	call	*__imp_VirtualFree(%rip)
.L563:
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
.L583:
	movl	$1, %r9d
	leaq	28(%r13), %r8
	movl	$28, %edx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L569
	movq	%rsi, %r9
	movq	%r14, %r8
	movq	%r12, %rdx
	movq	%rbx, %rcx
	call	write_at
	movl	%eax, %r15d
	testl	%eax, %eax
	jne	.L569
	xorl	%edx, %edx
	movq	2256(%rbx), %rcx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L574
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
	jmp	.L563
	.p2align 4,,10
	.p2align 3
.L571:
	movl	$8, %r15d
	jmp	.L563
.L574:
	movl	$7, %r15d
	jmp	.L569
	.p2align 4
	.def	put_number.isra.0;	.scl	3;	.type	32;	.endef
put_number.isra.0:
	movl	48(%rsp), %r10d
	movl	$3, %eax
	cmpb	$78, %dl
	jne	.L584
	movzwl	%r9w, %r9d
	movzbl	%r8b, %edx
	addq	%r9, %rcx
	cmpl	%r10d, %edx
	jb	.L605
	subl	%r10d, %edx
	je	.L590
	leal	-1(%rdx), %r9d
	movq	%rcx, %rax
	addq	%rcx, %r9
	.p2align 4,,10
	.p2align 3
.L591:
	movq	%rax, %r8
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%r9, %r8
	jne	.L591
.L590:
	testl	%r10d, %r10d
	je	.L589
	movq	40(%rsp), %r11
	leal	-1(%r10), %eax
	leaq	1(%r11,%rax), %r10
	subl	%r11d, %edx
	movq	%r11, %rax
	.p2align 4,,10
	.p2align 3
.L592:
	movzbl	(%rax), %r9d
	leal	(%rdx,%rax), %r8d
	addq	$1, %rax
	movb	%r9b, (%rcx,%r8)
	cmpq	%r10, %rax
	jne	.L592
.L589:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L584:
	ret
	.p2align 4,,10
	.p2align 3
.L605:
	movzbl	%r8b, %r8d
	leaq	(%rcx,%r8), %rax
	testl	%edx, %edx
	je	.L589
	.p2align 4,,10
	.p2align 3
.L588:
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	je	.L589
	movb	$42, (%rcx)
	addq	$1, %rcx
	cmpq	%rax, %rcx
	jne	.L588
	jmp	.L589
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
	ja	.L606
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%r8, %rcx
	movzbl	12(%rdx), %r8d
	cmpl	$17, %r9d
	ja	.L632
	cmpb	%r8b, %r13b
	jnb	.L632
	xorl	%r11d, %r11d
	testq	%rcx, %rcx
	jns	.L608
	negq	%rcx
	movl	$1, %r11d
.L608:
	movzbl	%r13b, %ebp
	cmpl	%ebp, %r9d
	jbe	.L609
	movl	%r9d, %eax
	subl	%ebp, %eax
	je	.L610
	xorl	%edx, %edx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L611:
	leaq	(%r9,%r9,4), %r9
	addl	$1, %edx
	addq	%r9, %r9
	cmpl	%edx, %eax
	jne	.L611
	movq	%rcx, %rax
	xorl	%edx, %edx
	divq	%r9
	shrq	%r9
	movq	%rax, %rcx
	cmpq	%r9, %rdx
	jb	.L612
.L610:
	addq	$1, %rcx
.L612:
	leaq	48(%rsp), %r9
	xorl	%r10d, %r10d
	movabsq	$-3689348814741910323, %rdi
	.p2align 4,,10
	.p2align 3
.L617:
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
	ja	.L617
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
	ja	.L660
	testl	%r11d, %r11d
	je	.L623
	movb	$45, 96(%rsp)
.L623:
	cmpl	%r10d, %ebp
	jb	.L661
	leal	1(%r11), %edx
	movl	%r11d, %r11d
	movb	$48, 96(%rsp,%r11)
.L625:
	testb	%r13b, %r13b
	je	.L627
	cmpl	%r10d, %ebp
	movl	%edx, %ecx
	leal	1(%rdx), %eax
	cmovbe	%ebp, %r10d
	movb	$46, 96(%rsp,%rcx)
	subl	%r10d, %ebp
	je	.L628
	leal	1(%rbp,%rdx), %r11d
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L629:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, 96(%rsp,%rcx)
	cmpl	%r11d, %edx
	jne	.L629
	addl	%ebp, %eax
.L628:
	leal	(%r10,%rax), %edx
	leal	-1(%r10,%rax), %r11d
	.p2align 4,,10
	.p2align 3
.L630:
	movl	%r11d, %r10d
	movl	%eax, %ecx
	subl	%eax, %r10d
	addl	$1, %eax
	movzbl	48(%rsp,%r10), %r10d
	movb	%r10b, 96(%rsp,%rcx)
	cmpl	%edx, %eax
	jne	.L630
.L627:
	leaq	96(%rsp), %rax
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rax, 32(%rsp)
	movl	%r10d, %edx
	call	put_number.isra.0
.L606:
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
.L632:
	movl	$4, %eax
	jmp	.L606
	.p2align 4,,10
	.p2align 3
.L609:
	jnb	.L612
	movl	%ebp, %r10d
	subl	%r9d, %r10d
	je	.L612
	movabsq	$1844674407370955161, %rdx
	cmpq	%rdx, %rcx
	ja	.L613
	xorl	%eax, %eax
	jmp	.L614
	.p2align 4,,10
	.p2align 3
.L616:
	cmpq	%rdx, %rcx
	ja	.L613
.L614:
	leaq	(%rcx,%rcx,4), %rcx
	addl	$1, %eax
	addq	%rcx, %rcx
	cmpl	%eax, %r10d
	jne	.L616
	jmp	.L612
	.p2align 4,,10
	.p2align 3
.L661:
	testl	%r14d, %r14d
	je	.L636
	movl	%ecx, %edx
	addl	%r11d, %esi
	jmp	.L626
	.p2align 4,,10
	.p2align 3
.L662:
	movl	%esi, %eax
	movl	%edi, %r11d
	subl	%edi, %eax
	movzbl	48(%rsp,%rax), %eax
.L626:
	leal	1(%r11), %edi
	movl	%r11d, %r11d
	movb	%al, 96(%rsp,%r11)
	cmpl	%ecx, %edi
	jne	.L662
	jmp	.L625
	.p2align 4,,10
	.p2align 3
.L660:
	xorl	%eax, %eax
	leaq	(%r12,%r9), %rdx
	.p2align 4,,10
	.p2align 3
.L621:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %edi
	ja	.L621
	xorl	%eax, %eax
	jmp	.L606
	.p2align 4,,10
	.p2align 3
.L613:
	movzwl	14(%rbx), %edx
	xorl	%eax, %eax
	addq	%r12, %rdx
	.p2align 4,,10
	.p2align 3
.L615:
	movb	$42, (%rdx,%rax)
	addq	$1, %rax
	cmpl	%eax, %r8d
	ja	.L615
	xorl	%eax, %eax
	jmp	.L606
.L636:
	movl	%r11d, %edx
	jmp	.L625
	.p2align 4
	.def	bn_shr_round;	.scl	3;	.type	32;	.endef
bn_shr_round:
	xorl	%eax, %eax
	testl	%edx, %edx
	je	.L712
	pushq	%rdi
	movq	%rcx, %r9
	movl	%edx, %r8d
	pushq	%rsi
	pushq	%rbx
	movl	288(%rcx), %r11d
	movl	%r11d, %r10d
	sall	$5, %r10d
	cmpl	%edx, %r10d
	jbe	.L715
	leal	-1(%rdx), %ecx
	cmpl	%ecx, %r10d
	ja	.L671
	xorl	%edx, %edx
	cmpl	$1, %r8d
	je	.L673
.L672:
	xorl	%ecx, %ecx
	jmp	.L676
	.p2align 4,,10
	.p2align 3
.L675:
	leal	1(%rcx), %eax
	addl	$2, %ecx
	cmpl	%ecx, %r8d
	jbe	.L716
	movl	%eax, %ecx
.L676:
	cmpl	%ecx, %r10d
	jbe	.L675
	movl	%ecx, %eax
	shrl	$5, %eax
	movl	(%r9,%rax,4), %eax
	shrl	%cl, %eax
	andl	$1, %eax
	je	.L675
.L674:
	leal	(%rax,%rdx,2), %eax
	cmpl	$31, %r8d
	jbe	.L673
	movl	%r8d, %esi
	shrl	$5, %esi
	cmpl	%esi, %r11d
	jbe	.L681
	leal	-1(%r11), %ecx
	movq	%r9, %rdx
	movl	%esi, %r10d
	subl	%esi, %ecx
	leaq	4(%r9,%rcx,4), %rbx
	.p2align 4,,10
	.p2align 3
.L680:
	movl	(%rdx,%r10,4), %ecx
	addq	$4, %rdx
	movl	%ecx, -4(%rdx)
	cmpq	%rbx, %rdx
	jne	.L680
.L681:
	movl	%r11d, %edx
	subl	%esi, %edx
	movl	%edx, 288(%r9)
	cmpl	%edx, %r11d
	jbe	.L673
	movl	%edx, %ecx
	leal	-1(%rsi), %r10d
	leaq	(%r9,%rcx,4), %rdx
	addq	%r10, %rcx
	leaq	4(%r9,%rcx,4), %rcx
	.p2align 4,,10
	.p2align 3
.L682:
	movl	$0, (%rdx)
	addq	$4, %rdx
	cmpq	%rcx, %rdx
	jne	.L682
.L673:
	movl	%r8d, %r11d
	andl	$31, %r11d
	je	.L663
	movl	288(%r9), %ecx
	leal	-1(%rcx), %edi
	cmpl	$1, %ecx
	jbe	.L683
	movl	$32, %ebx
	subl	$2, %ecx
	movq	%r9, %rdx
	subl	%r11d, %ebx
	leaq	4(%r9,%rcx,4), %rsi
	.p2align 4,,10
	.p2align 3
.L684:
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
	jne	.L684
	movl	%edi, %r8d
	movl	%r11d, %ecx
	movl	(%r9,%r8,4), %edx
	shrl	%cl, %edx
	movl	%edx, (%r9,%r8,4)
	testl	%edx, %edx
	jne	.L663
	movl	%edi, 288(%r9)
	jmp	.L663
	.p2align 4,,10
	.p2align 3
.L715:
	testl	%r10d, %r10d
	je	.L666
	xorl	%r11d, %r11d
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L668:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmovne	%edx, %eax
	cmovne	%ecx, %r11d
	addl	$1, %ecx
	cmpl	%ecx, %r10d
	jne	.L668
	testl	%eax, %eax
	je	.L666
	xorl	%ebx, %ebx
	xorl	%ecx, %ecx
	.p2align 4,,10
	.p2align 3
.L669:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	addl	$1, %ecx
	andl	$1, %edx
	addl	%edx, %ebx
	cmpl	%ecx, %r10d
	jne	.L669
	subl	$1, %r8d
	cmpl	%r11d, %r8d
	ja	.L666
	jne	.L691
	movl	$2, %eax
	cmpl	$1, %ebx
	je	.L666
.L691:
	movl	$3, %eax
	.p2align 4,,10
	.p2align 3
.L666:
	movl	$1, 288(%r9)
	movl	$0, (%r9)
.L663:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L712:
	ret
	.p2align 4,,10
	.p2align 3
.L671:
	movl	%ecx, %edx
	shrl	$5, %edx
	movl	(%r9,%rdx,4), %edx
	shrl	%cl, %edx
	andl	$1, %edx
	cmpl	$1, %r8d
	jne	.L672
	jmp	.L674
	.p2align 4,,10
	.p2align 3
.L716:
	xorl	%eax, %eax
	jmp	.L674
.L683:
	movl	%r11d, %ecx
	shrl	%cl, (%r9,%rdi,4)
	jmp	.L663
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
.L718:
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
	jbe	.L726
	cmpl	$19, %r10d
	jbe	.L718
.L726:
	leaq	fsink(%rip), %rbx
	movl	fsink_len(%rip), %edx
	leaq	14(%rsp), %rsi
	leaq	159(%rbx), %r9
	.p2align 4,,10
	.p2align 3
.L724:
	movl	%edx, %eax
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rsi, %rdx
	addq	%rbx, %rax
	movb	$0, 15(%rsp)
	cmpq	%r9, %rax
	jb	.L720
	jmp	.L721
	.p2align 4,,10
	.p2align 3
.L722:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r8
	cmpq	%r9, %rax
	jnb	.L721
	movzbl	1(%rdx), %ecx
	movq	%r8, %rdx
.L720:
	testb	%cl, %cl
	jne	.L722
.L721:
	movb	$0, (%rax)
	subq	%rbx, %rax
	movl	%eax, fsink_len(%rip)
	movl	%eax, %edx
	testl	%r11d, %r11d
	je	.L717
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L724
	.p2align 4,,10
	.p2align 3
.L717:
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
	je	.L741
	movabsq	$4503599627370495, %rax
	andq	56(%rsp), %rax
	movq	%rcx, %rsi
	movq	%rax, 40(%rsp)
	testq	%r12, %r12
	je	.L979
	btsq	$52, 40(%rsp)
	movq	40(%rsp), %rax
	leal	-1075(%r12), %r15d
	movl	$2, %r10d
	subl	$735, %r12d
	movq	%rax, 64(%rsp)
.L739:
	movl	%r10d, 352(%rsp)
	movl	$340, %r9d
	xorl	%r11d, %r11d
	leaq	64(%rsp), %rdi
	leaq	68(%rsp), %rbx
	.p2align 4,,10
	.p2align 3
.L744:
	leal	-1(%r10), %eax
	movq	%rdi, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L745:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%r8, %rcx
	jne	.L745
	testq	%rax, %rax
	je	.L746
	movl	%r10d, %edx
	movl	$1, %r11d
	addl	$1, %r10d
	movl	%eax, 64(%rsp,%rdx,4)
.L746:
	subl	$1, %r9d
	jne	.L744
	testb	%r11b, %r11b
	je	.L748
	movl	%r10d, 352(%rsp)
.L748:
	testl	%r12d, %r12d
	js	.L749
	movl	%r12d, %edx
	movq	%rdi, %rcx
	call	bn_shl
.L976:
	movl	352(%rsp), %eax
.L752:
	xorl	%ebx, %ebx
	jmp	.L750
	.p2align 4,,10
	.p2align 3
.L755:
	cmpq	$80, %rbx
	je	.L980
	movq	%rdi, %rcx
	call	bn_divmod_1e9
	movl	%eax, 1280(%rsp,%rbx,4)
	movl	352(%rsp), %eax
	addq	$1, %rbx
.L750:
	movl	%ebx, %r10d
	cmpl	$1, %eax
	jne	.L755
	movl	64(%rsp), %ebp
	testl	%ebp, %ebp
	jne	.L755
	testl	%ebx, %ebx
	jne	.L981
	movl	2424(%rsp), %ebx
	testl	%ebx, %ebx
	je	.L740
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jnb	.L982
.L741:
	xorl	%eax, %eax
.L733:
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
.L979:
	testq	%rax, %rax
	jne	.L983
	movl	2424(%rsp), %r13d
	testl	%r13d, %r13d
	je	.L740
	movl	2424(%rsp), %eax
	addl	$2, %eax
	cmpl	%eax, 2408(%rsp)
	jb	.L741
	movl	2424(%rsp), %edi
	movl	$11824, %ecx
	leaq	2(%rsi), %rdx
	movw	%cx, (%rsi)
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L743:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rcx
	jne	.L743
	jmp	.L733
.L740:
	movl	2408(%rsp), %r12d
	testl	%r12d, %r12d
	je	.L741
	movb	$48, (%rsi)
	movl	$1, %eax
	jmp	.L733
.L983:
	movq	40(%rsp), %rax
	movl	$-734, %r12d
	movl	$-1074, %r15d
	movq	%rax, 64(%rsp)
	shrq	$32, %rax
	cmpq	$1, %rax
	sbbl	%r10d, %r10d
	addl	$2, %r10d
	jmp	.L739
.L749:
	movl	$-340, %edx
	movq	%rdi, %rcx
	subl	%r15d, %edx
	call	bn_shr_round
	cmpl	$1, %eax
	jbe	.L976
	movl	352(%rsp), %eax
	testl	%eax, %eax
	je	.L848
	leal	-1(%rax), %edx
	movq	%rdi, %r8
	leaq	(%rbx,%rdx,4), %r9
	movl	$1, %edx
.L754:
	movl	(%r8), %ecx
	addq	$4, %r8
	addq	%rcx, %rdx
	movl	%edx, -4(%r8)
	shrq	$32, %rdx
	cmpq	%r9, %r8
	jne	.L754
	testq	%rdx, %rdx
	je	.L752
	leal	1(%rax), %edx
.L753:
	movl	%eax, %eax
	movl	%edx, 352(%rsp)
	movl	$1, 64(%rsp,%rax,4)
	movl	%edx, %eax
	jmp	.L752
.L980:
	movl	$79, %r10d
.L758:
	movl	%r10d, %eax
	movl	$1, %edx
	leaq	975(%rsp), %rbx
	movl	$3435973837, %r11d
	movl	1280(%rsp,%rax,4), %ecx
.L762:
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
	ja	.L762
	leaq	1600(%rsp), %r13
	addq	%r13, %r8
	movq	%r13, %rdx
	leal	-1(%r12,%r13), %ecx
	jmp	.L764
.L984:
	movl	%ecx, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L764:
	movb	%al, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rdx
	jne	.L984
	testl	%r10d, %r10d
	je	.L765
	leal	-1(%r10), %eax
	leal	-1(%r12), %edi
	movl	$3435973837, %ebx
	leaq	1280(%rsp), %r14
	leaq	(%r14,%rax,4), %rbp
.L767:
	movl	%edi, %r9d
	movl	0(%rbp), %edx
	addl	$9, %edi
	movl	%edi, %ecx
	.p2align 4,,10
	.p2align 3
.L766:
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
	jne	.L766
	leaq	-4(%rbp), %rax
	cmpq	%rbp, %r14
	je	.L985
	movq	%rax, %rbp
	jmp	.L767
.L985:
	leal	(%r10,%r10,8), %eax
	addl	%eax, %r12d
.L765:
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
.L769:
	leal	-1(%r10), %eax
	movq	%r11, %rcx
	leaq	(%rbx,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L770:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L770
	testq	%rax, %rax
	je	.L771
	movl	%r10d, %edx
	movl	$1, %edi
	addl	$1, %r10d
	movl	%eax, 368(%rsp,%rdx,4)
.L771:
	subl	$1, %r9d
	jne	.L769
	testb	%dil, %dil
	je	.L773
	movl	%r10d, 656(%rsp)
.L773:
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
	je	.L774
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
.L775:
	leal	-1(%rdi), %eax
	movq	%r9, %rcx
	leaq	(%r10,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L776:
	movl	(%rcx), %edx
	addq	$4, %rcx
	leaq	(%rdx,%rdx,4), %rdx
	addq	%rdx, %rax
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpq	%rcx, %r8
	jne	.L776
	testq	%rax, %rax
	je	.L777
	movl	%edi, %edx
	movl	%r11d, %ebp
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L777:
	subl	$1, %ebx
	jne	.L775
	testb	%bpl, %bpl
	je	.L779
	movl	%edi, 960(%rsp)
.L779:
	leal	338(%r15), %edx
	movq	%r9, %rcx
	call	bn_shl
.L780:
	leaq	976(%rsp), %rbx
	cmpl	$1, %r12d
	je	.L787
	movq	%rsi, 2400(%rsp)
	movl	$1, %ebp
	movl	%r12d, %esi
	leaq	1601(%rsp), %rdi
	leaq	976(%rsp), %rbx
.L814:
	movq	%r13, %rcx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L788:
	movzbl	(%rcx), %eax
	leaq	(%r8,%r8,4), %rdx
	addq	$1, %rcx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rdx,2), %r8
	cmpq	%rcx, %rdi
	jne	.L788
	cmpb	$53, (%rdi)
	ja	.L789
	je	.L986
.L790:
	movl	%r12d, %r11d
	subl	%ebp, %r11d
	cmpq	$9, %r8
	ja	.L987
.L792:
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
	je	.L796
	.p2align 4,,10
	.p2align 3
.L795:
	leal	-1(%r9), %eax
	movq	%rbx, %rdx
	leaq	(%r14,%rax,4), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L797:
	movl	(%rdx), %r8d
	addq	$4, %rdx
	leaq	(%r8,%r8,4), %r8
	addq	%r8, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rcx, %rdx
	jne	.L797
	testq	%rax, %rax
	je	.L798
	movl	%r9d, %edx
	movl	$1, %r15d
	addl	$1, %r9d
	movl	%eax, 976(%rsp,%rdx,4)
.L798:
	addl	$1, %r10d
	cmpl	%r11d, %r10d
	jne	.L795
	testb	%r15b, %r15b
	je	.L796
	movl	%r9d, 1264(%rsp)
.L796:
	movl	%r11d, %edx
	movq	%rbx, %rcx
	call	bn_shl
	movl	1264(%rsp), %r8d
	cmpl	960(%rsp), %r8d
	je	.L801
	jnb	.L802
	cmpl	656(%rsp), %r8d
	jne	.L803
	movl	$-1, %ecx
	leal	-1(%r8), %eax
	jmp	.L810
	.p2align 4,,10
	.p2align 3
.L813:
	movl	%eax, %edx
	subl	$1, %eax
	movl	368(%rsp,%rdx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rdx,4)
	jne	.L988
.L810:
	cmpl	$-1, %eax
	jne	.L813
.L809:
	testb	$1, 40(%rsp)
	je	.L968
.L803:
	addl	$1, %ebp
	subl	$1, %esi
	addq	$1, %rdi
	cmpl	$17, %ebp
	ja	.L969
	cmpl	%r12d, %ebp
	jb	.L814
.L969:
	movq	2400(%rsp), %rsi
.L787:
	cmpl	$17, %r12d
	movl	$17, %ebp
	cmovbe	%r12d, %ebp
.L816:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.L817:
	movzbl	0(%r13,%rdx), %eax
	leaq	(%r8,%r8,4), %rcx
	addq	$1, %rdx
	subl	$48, %eax
	cltq
	leaq	(%rax,%rcx,2), %r8
	cmpl	%edx, %ebp
	ja	.L817
	cmpl	%r12d, %ebp
	jnb	.L818
	movl	%ebp, %eax
	cmpb	$53, 1600(%rsp,%rax)
	ja	.L819
	jne	.L818
	testb	$1, %r8b
	jne	.L819
	leal	1(%rbp), %edx
	cmpl	%r12d, %edx
	jnb	.L818
	leal	-2(%r12), %eax
	leaq	0(%r13,%rdx), %rcx
	subl	%ebp, %eax
	leaq	1(%r13,%rdx), %rdx
	addq	%rdx, %rax
	jmp	.L820
.L989:
	addq	$1, %rcx
	cmpq	%rcx, %rax
	je	.L818
.L820:
	cmpb	$48, (%rcx)
	je	.L989
.L819:
	addq	$1, %r8
.L818:
	movabsq	$-3689348814741910323, %r10
	xorl	%ecx, %ecx
.L821:
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
	ja	.L821
	cmpl	%ebp, %ecx
	jbe	.L822
	leal	-340(%r12), %eax
	xorl	%ecx, %ecx
	movl	%eax, 52(%rsp)
	testl	%r9d, %r9d
	je	.L826
	leal	-1(%r9), %eax
	movl	%r9d, %ecx
	movq	%rax, %rdx
	movzbl	976(%rsp,%rax), %eax
	movl	%edx, %r9d
.L822:
	xorl	%edx, %edx
	jmp	.L824
.L990:
	movl	%r9d, %eax
	subl	%edx, %eax
	movzbl	976(%rsp,%rax), %eax
.L824:
	movb	%al, 0(%r13,%rdx)
	addq	$1, %rdx
	cmpl	%ecx, %edx
	jb	.L990
	cmpl	$1, %ecx
	jbe	.L825
.L991:
	leal	-1(%rcx), %edx
	cmpb	$48, 1600(%rsp,%rdx)
	movq	%rdx, %rax
	jne	.L825
	movl	%eax, %ecx
.L826:
	cmpl	$1, %ecx
	ja	.L991
.L825:
	movl	2424(%rsp), %edi
	movq	56(%rsp), %rax
	leal	1(%rdi), %r9d
	movl	52(%rsp), %edi
	shrq	$63, %rax
	movl	%eax, %r10d
	leal	(%rdi,%r9), %r8d
	testl	%r8d, %r8d
	jle	.L992
	cmpl	%ecx, %r8d
	jge	.L831
	movslq	%r8d, %rdx
	cmpb	$52, 1600(%rsp,%rdx)
	jbe	.L837
	leal	-1(%r8), %edx
	movq	%rdx, %rcx
	addq	%r13, %rdx
	subl	%edx, %ecx
	movl	%ecx, %r11d
	jmp	.L834
.L833:
	movb	$48, (%rdx)
	leaq	-1(%rdx), %rcx
	cmpq	%rdx, %r13
	je	.L993
	movq	%rcx, %rdx
.L834:
	movzbl	(%rdx), %ecx
	leal	(%r11,%rdx), %ebx
	cmpb	$57, %cl
	je	.L833
	movl	%ebx, %edx
	addl	$1, %ecx
	movb	%cl, 1600(%rsp,%rdx)
	jmp	.L837
	.p2align 4,,10
	.p2align 3
.L995:
	leal	-1(%r8), %ecx
	cmpb	$48, 1600(%rsp,%rcx)
	movq	%rcx, %rdx
	jne	.L994
	movl	%edx, %r8d
.L837:
	cmpl	$1, %r8d
	jne	.L995
.L836:
	xorl	%edx, %edx
	cmpb	$48, 1600(%rsp)
	movl	$1, %ecx
	cmove	%edx, %eax
	cmove	%edx, %r10d
	jmp	.L829
	.p2align 4,,10
	.p2align 3
.L801:
	leal	-1(%r8), %eax
	movl	%eax, %edx
	jmp	.L806
	.p2align 4,,10
	.p2align 3
.L808:
	movl	%edx, %ecx
	subl	$1, %edx
	movl	672(%rsp,%rcx,4), %r14d
	cmpl	%r14d, 976(%rsp,%rcx,4)
	jne	.L996
.L806:
	cmpl	$-1, %edx
	jne	.L808
	xorl	%ecx, %ecx
	cmpl	%r8d, 656(%rsp)
	je	.L810
	jmp	.L809
.L986:
	testb	$1, %r8b
	jne	.L789
	leal	1(%rbp), %eax
	cmpl	%r12d, %eax
	jnb	.L790
	leal	-3(%rsi), %edx
	leaq	1(%rdi), %rax
	leaq	2(%rdi,%rdx), %rdx
	jmp	.L791
.L997:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L790
.L791:
	cmpb	$48, (%rax)
	je	.L997
.L789:
	movl	%r12d, %r11d
	addq	$1, %r8
	subl	%ebp, %r11d
	cmpq	$9, %r8
	jbe	.L792
.L987:
	movq	%r8, %rdx
	movl	$1, %r9d
	.p2align 4,,10
	.p2align 3
.L793:
	movabsq	$-3689348814741910323, %rax
	movq	%rdx, %rcx
	addl	$1, %r9d
	mulq	%rdx
	shrq	$3, %rdx
	cmpq	$99, %rcx
	ja	.L793
	cmpl	%ebp, %r9d
	jbe	.L792
	movabsq	$-3689348814741910323, %rax
	movl	%esi, %r11d
	mulq	%r8
	movq	%rdx, %r8
	shrq	$3, %r8
	jmp	.L792
.L988:
	jnb	.L812
	cmpl	$1, %ecx
	je	.L968
.L812:
	testl	%ecx, %ecx
	jne	.L803
	jmp	.L809
.L996:
	jnb	.L807
	movl	$-1, %ecx
	cmpl	656(%rsp), %r8d
	je	.L810
	jmp	.L803
.L802:
	cmpl	656(%rsp), %r8d
	jne	.L977
	movl	$1, %ecx
	leal	-1(%r8), %eax
	jmp	.L810
.L977:
	jnb	.L803
.L968:
	movq	2400(%rsp), %rsi
	jmp	.L816
.L807:
	cmpl	656(%rsp), %r8d
	jne	.L977
	movl	$1, %ecx
	jmp	.L810
.L774:
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
	cmpq	%r8, %rcx
	jne	.L783
	testq	%rax, %rax
	je	.L784
	movl	%edi, %edx
	movl	$1, %r11d
	addl	$1, %edi
	movl	%eax, 672(%rsp,%rdx,4)
.L784:
	subl	$1, %ebx
	jne	.L782
	testb	%r11b, %r11b
	je	.L786
	movl	%edi, 960(%rsp)
.L786:
	movl	%r14d, %edx
	movq	%r9, %rcx
	call	bn_shl
	jmp	.L780
.L831:
	cmpl	$1, %ecx
	je	.L836
.L829:
	movl	52(%rsp), %edi
	movl	$1, %r8d
	leal	1(%rdi), %edx
	testl	%edi, %edi
	cmovs	%r8d, %edx
.L838:
	movl	2424(%rsp), %r11d
	leal	(%rdx,%r9), %r8d
	testl	%r11d, %r11d
	cmovne	%r8d, %edx
	addl	%edx, %eax
	movl	$400, %edx
	cmpl	$400, 2408(%rsp)
	cmovle	2408(%rsp), %edx
	cmpl	%edx, %eax
	jg	.L741
	testl	%r10d, %r10d
	je	.L862
	movb	$45, (%rsi)
	leaq	1(%rsi), %rdx
	movl	$2, %eax
.L840:
	movl	52(%rsp), %edi
	testl	%edi, %edi
	js	.L841
	leal	1(%rdi), %eax
	xorl	%edx, %edx
	movslq	%eax, %rbx
.L843:
	leal	(%r10,%rdx), %r8d
	movl	$48, %r11d
	cmpl	%ecx, %edx
	jnb	.L842
	movzbl	0(%r13,%rdx), %r11d
.L842:
	addq	$1, %rdx
	movb	%r11b, (%rsi,%r8)
	cmpq	%rdx, %rbx
	jne	.L843
	addl	%r10d, %eax
.L844:
	movl	2424(%rsp), %r8d
	testl	%r8d, %r8d
	je	.L733
	movl	52(%rsp), %edi
	movl	%eax, %edx
	movl	%eax, %r11d
	movb	$46, (%rsi,%rdx)
	leal	(%r9,%rdi), %ebx
	leal	1(%rdi), %edx
	subl	%edi, %r11d
	jmp	.L846
.L999:
	cmpl	%ecx, %edx
	jnb	.L864
	movslq	%edx, %r10
	movzbl	1600(%rsp,%r10), %r10d
.L845:
	addl	$1, %edx
	movb	%r10b, (%rsi,%r8)
	cmpl	%edx, %ebx
	je	.L998
.L846:
	leal	(%r11,%rdx), %r8d
	testl	%edx, %edx
	jns	.L999
.L864:
	movl	$48, %r10d
	jmp	.L845
.L862:
	movq	%rsi, %rdx
	movl	$1, %eax
	jmp	.L840
.L992:
	jne	.L828
	cmpb	$52, 1600(%rsp)
	jbe	.L828
	movl	2424(%rsp), %edi
	movb	$49, 1600(%rsp)
	movl	$1, %ecx
	negl	%edi
	movl	%edi, 52(%rsp)
	jmp	.L829
.L828:
	xorl	%r10d, %r10d
	xorl	%eax, %eax
	movl	$1, %edx
	movl	$1, %ecx
	movb	$48, 1600(%rsp)
	movl	$0, 52(%rsp)
	jmp	.L838
.L841:
	movb	$48, (%rdx)
	jmp	.L844
.L998:
	addl	%r9d, %eax
	jmp	.L733
.L981:
	subl	$1, %r10d
	jmp	.L758
.L982:
	movl	2424(%rsp), %edi
	movl	$11824, %edx
	movw	%dx, (%rsi)
	leaq	2(%rsi), %rdx
	leal	-1(%rdi), %ecx
	leaq	3(%rsi,%rcx), %rcx
.L761:
	movb	$48, (%rdx)
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jne	.L761
	jmp	.L733
.L994:
	movl	%r8d, %ecx
	jmp	.L829
.L848:
	movl	$1, %edx
	jmp	.L753
.L993:
	addl	$1, 52(%rsp)
	movb	$49, 1600(%rsp)
	jmp	.L837
	.p2align 4
	.def	hrdbf_write_number_double.part.0;	.scl	3;	.type	32;	.endef
hrdbf_write_number_double.part.0:
	movzbl	13(%rdx), %r9d
	movl	$4, %eax
	cmpb	$17, %r9b
	ja	.L1007
	pushq	%r12
	pushq	%rsi
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$448, %rsp
	cmpb	12(%rdx), %r9b
	jnb	.L1000
	leaq	48(%rsp), %rsi
	movl	$400, %edx
	movq	%rcx, %r12
	movq	%rsi, %rcx
	call	hrdbf_fmt_harbour.part.0
	movl	%eax, %edx
	movl	$5, %eax
	testl	%edx, %edx
	je	.L1000
	movzbl	11(%rbx), %r10d
	movl	%edx, 40(%rsp)
	movq	%r12, %rcx
	movq	%rsi, 32(%rsp)
	movzwl	14(%rbx), %r9d
	movzbl	12(%rbx), %r8d
	movl	%r10d, %edx
	call	put_number.isra.0
.L1000:
	addq	$448, %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1007:
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
	jmp	.L1011
	.p2align 4,,10
	.p2align 3
.L1013:
	movb	%dl, (%rax)
	addq	$1, %rax
	addq	$1, %rcx
	cmpq	%rbx, %rax
	jnb	.L1012
.L1011:
	movzbl	(%rcx), %edx
	testb	%dl, %dl
	jne	.L1013
.L1012:
	movb	$0, (%rax)
	subq	%rsi, %rax
	movl	%eax, %edx
	movl	%eax, %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L1014
	movl	$32, %ecx
	leaq	.LC1(%rip), %rdx
	.p2align 4,,10
	.p2align 3
.L1016:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rbx, %rax
	jnb	.L1020
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1016
.L1020:
	movl	%eax, %edx
	subl	%esi, %edx
.L1014:
	movb	$0, (%rax)
	movl	%r8d, %ecx
	movl	%edx, fsink_len(%rip)
	call	fdec
	movl	fsink_len(%rip), %eax
	addq	%rsi, %rax
	cmpq	%rbx, %rax
	jnb	.L1017
	movb	$41, (%rax)
	addq	$1, %rax
.L1017:
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
.L1022:
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
	jbe	.L1032
	cmpl	$19, %r10d
	jbe	.L1022
.L1032:
	leaq	2090(%r8), %rbx
	leaq	14(%rsp), %rsi
	addq	$2249, %r8
	.p2align 4,,10
	.p2align 3
.L1030:
	movb	%cl, 14(%rsp)
	leal	-1(%r10), %r11d
	movq	%rbx, %rax
	movb	$0, 15(%rsp)
	jmp	.L1024
	.p2align 4,,10
	.p2align 3
.L1026:
	addq	$1, %rax
	cmpq	%r8, %rax
	jnb	.L1025
.L1024:
	cmpb	$0, (%rax)
	jne	.L1026
	movq	%rsi, %rdx
	cmpq	%r8, %rax
	jb	.L1027
	jmp	.L1025
	.p2align 4,,10
	.p2align 3
.L1028:
	movb	%cl, (%rax)
	addq	$1, %rax
	leaq	1(%rdx), %r9
	cmpq	%r8, %rax
	jnb	.L1025
	movzbl	1(%rdx), %ecx
	movq	%r9, %rdx
.L1027:
	testb	%cl, %cl
	jne	.L1028
.L1025:
	movb	$0, (%rax)
	testl	%r11d, %r11d
	je	.L1021
	leal	-2(%r10), %eax
	movl	%r11d, %r10d
	movzbl	16(%rsp,%rax), %ecx
	jmp	.L1030
.L1021:
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
.L1040:
	movl	%r9d, %eax
	movzbl	(%r11,%rax), %eax
	testb	%al, %al
	je	.L1039
	leal	-32(%rax), %edx
	movb	$0, 15(%rsp)
	cmpb	$95, %dl
	cmovnb	%ebx, %eax
	movb	%al, 14(%rsp)
	leaq	2090(%r10), %rax
	jmp	.L1042
	.p2align 4,,10
	.p2align 3
.L1044:
	addq	$1, %rax
	cmpq	%rax, %r8
	jbe	.L1043
.L1042:
	cmpb	$0, (%rax)
	jne	.L1044
	leaq	14(%rsp), %rdx
	cmpq	%rax, %r8
	ja	.L1045
	jmp	.L1043
	.p2align 4,,10
	.p2align 3
.L1046:
	movb	%cl, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rax, %r8
	jbe	.L1043
.L1045:
	movzbl	(%rdx), %ecx
	testb	%cl, %cl
	jne	.L1046
.L1043:
	addl	$1, %r9d
	movb	$0, (%rax)
	cmpl	$11, %r9d
	jne	.L1040
.L1039:
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
	jmp	.L1054
	.p2align 4,,10
	.p2align 3
.L1056:
	addq	$1, %rdx
	cmpq	%rcx, %rdx
	jnb	.L1055
.L1054:
	cmpb	$0, (%rdx)
	jne	.L1056
	leaq	14(%rsp), %r9
	cmpq	%rcx, %rdx
	jb	.L1057
	jmp	.L1055
	.p2align 4,,10
	.p2align 3
.L1059:
	movb	%r8b, (%rdx)
	addq	$1, %rdx
	leaq	1(%r9), %r10
	cmpq	%rcx, %rdx
	jnb	.L1055
	movzbl	1(%r9), %r8d
	movq	%r10, %r9
.L1057:
	testb	%r8b, %r8b
	jne	.L1059
.L1055:
	andl	$15, %r11d
	movb	$0, (%rdx)
	movzbl	(%rbx,%r11), %edx
	movb	%dl, 14(%rsp)
	jmp	.L1061
	.p2align 4,,10
	.p2align 3
.L1063:
	addq	$1, %rax
	cmpq	%rcx, %rax
	jnb	.L1062
.L1061:
	cmpb	$0, (%rax)
	jne	.L1063
	leaq	14(%rsp), %rdx
	cmpq	%rcx, %rax
	jb	.L1064
	jmp	.L1062
	.p2align 4,,10
	.p2align 3
.L1065:
	movb	%r8b, (%rax)
	addq	$1, %rax
	addq	$1, %rdx
	cmpq	%rcx, %rax
	jnb	.L1062
.L1064:
	movzbl	(%rdx), %r8d
	testb	%r8b, %r8b
	jne	.L1065
.L1062:
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
	je	.L1077
	movq	%r8, %rdi
	cmpb	$92, %dl
	je	.L1180
	cmpb	$47, %dl
	jne	.L1173
	cmpb	$47, 1(%rcx)
	je	.L1077
	movl	$47, %eax
.L1078:
	movabsq	$-4611681598906040321, %r9
	andl	$-33, %edx
	xorl	%ebx, %ebx
	subl	$65, %edx
	jmp	.L1079
	.p2align 4,,10
	.p2align 3
.L1182:
	movl	%eax, %r8d
	andl	$-65, %r8d
	cmpb	$60, %r8b
	je	.L1077
.L1083:
	leaq	96(%rsp), %r12
	movw	%ax, (%r12,%rbx,2)
	addq	$1, %rbx
	movzbl	(%rcx,%rbx), %eax
	testb	%al, %al
	je	.L1181
	js	.L1077
	cmpq	$258, %rbx
	ja	.L1077
.L1079:
	cmpb	$63, %al
	ja	.L1182
	btq	%rax, %r9
	jc	.L1077
	cmpb	$60, %al
	je	.L1077
	cmpb	$58, %al
	jne	.L1082
	cmpq	$1, %rbx
	jne	.L1077
	cmpb	$25, %dl
	ja	.L1077
	movl	$58, %eax
	jmp	.L1083
	.p2align 4,,10
	.p2align 3
.L1187:
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
	cmpw	$46, %r14w
	je	.L1088
	.p2align 4,,10
	.p2align 3
.L1077:
	leaq	.LC3(%rip), %rcx
	movl	$7, %r13d
	call	fset
.L1073:
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
.L1180:
	cmpb	$92, 1(%rcx)
	movl	$92, %eax
	jne	.L1078
	jmp	.L1077
	.p2align 4,,10
	.p2align 3
.L1082:
	cmpb	$47, %al
	jne	.L1083
	movl	$92, %eax
	jmp	.L1083
	.p2align 4,,10
	.p2align 3
.L1173:
	movzbl	%dl, %eax
	testb	%dl, %dl
	jns	.L1078
	jmp	.L1077
	.p2align 4,,10
	.p2align 3
.L1181:
	xorl	%edx, %edx
	movl	$1, %r14d
	xorl	%r15d, %r15d
	xorl	%ecx, %ecx
	movw	%dx, 96(%rsp,%rbx,2)
	movq	%rdi, 720(%rsp)
	movq	%r12, %rdi
	movq	%rbx, %r12
	movq	%r14, %rbx
	jmp	.L1103
	.p2align 4,,10
	.p2align 3
.L1086:
	addq	$1, %r15
	leaq	1(%rbx), %rax
	cmpq	%rbx, %r12
	jb	.L1183
	movq	%rax, %rbx
.L1103:
	cmpq	%r15, %r12
	je	.L1085
	cmpw	$92, (%rdi,%r15,2)
	jne	.L1086
.L1085:
	movq	%r15, %rsi
	subq	%rcx, %rsi
	je	.L1132
	movzwl	-2(%rdi,%r15,2), %eax
	cmpw	$32, %ax
	je	.L1087
	cmpw	$46, %ax
	je	.L1087
	leaq	(%rdi,%rcx,2), %r13
	movzwl	0(%r13), %r14d
.L1088:
	movl	%r14d, %edx
	xorl	%eax, %eax
	jmp	.L1090
	.p2align 4,,10
	.p2align 3
.L1091:
	movzwl	0(%r13,%rax,2), %edx
.L1090:
	cmpw	$46, %dx
	je	.L1184
	addq	$1, %rax
	cmpq	%rax, %rsi
	jne	.L1091
	cmpw	$32, -2(%r13,%rsi,2)
	jne	.L1093
	.p2align 4,,10
	.p2align 3
.L1097:
	subq	$1, %rsi
	je	.L1093
.L1096:
	cmpw	$32, -2(%r13,%rsi,2)
	je	.L1097
.L1093:
	leaq	.LC4(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC5(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC6(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC7(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC8(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC9(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	leaq	.LC10(%rip), %r8
	movq	%rsi, %rdx
	movq	%r13, %rcx
	call	hrdbfw_device_eq
	testl	%eax, %eax
	jne	.L1077
	movq	%rbx, %rcx
	cmpq	$4, %rsi
	jne	.L1086
	movzwl	6(%r13), %eax
	subl	$48, %eax
	cmpw	$9, %ax
	ja	.L1086
	movzwl	%r14w, %eax
	xorl	%ecx, %ecx
	movl	$67, %edx
	jmp	.L1100
.L1185:
	leaq	.LC11(%rip), %rax
	movzbl	(%rax,%rcx), %edx
	testb	%dl, %dl
	je	.L1130
	movzwl	0(%r13,%rcx,2), %eax
.L1100:
	leal	-97(%rax), %r9d
	leal	-32(%rax), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %eax
	cmpl	%eax, %edx
	jne	.L1130
	addq	$1, %rcx
	cmpq	$3, %rcx
	jne	.L1185
	jmp	.L1077
.L1130:
	xorl	%edx, %edx
	movl	$76, %eax
	jmp	.L1102
.L1186:
	movzwl	0(%r13,%rdx,2), %r14d
.L1102:
	movzwl	%r14w, %ecx
	leal	-97(%rcx), %r9d
	leal	-32(%rcx), %r8d
	cmpl	$26, %r9d
	cmovb	%r8d, %ecx
	cmpl	%ecx, %eax
	jne	.L1132
	addq	$1, %rdx
	cmpq	$3, %rdx
	je	.L1077
	leaq	.LC12(%rip), %rax
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.L1186
	.p2align 4,,10
	.p2align 3
.L1132:
	movq	%rbx, %rcx
	jmp	.L1086
	.p2align 4,,10
	.p2align 3
.L1087:
	cmpq	$1, %rsi
	je	.L1187
	cmpq	$2, %rsi
	jne	.L1077
	addq	%rcx, %rcx
	leaq	(%rdi,%rcx), %r13
	cmpw	$46, 0(%r13)
	jne	.L1077
	movzwl	98(%rsp,%rcx), %r14d
	cmpw	$46, %r14w
	je	.L1088
	jmp	.L1077
	.p2align 4,,10
	.p2align 3
.L1184:
	movq	%rax, %rsi
	testq	%rax, %rax
	jne	.L1096
	jmp	.L1093
.L1183:
	cmpw	$92, 96(%rsp)
	movq	%r12, %rbx
	movq	%rdi, %r12
	movq	720(%rsp), %rdi
	je	.L1077
	cmpq	$1, %rbx
	je	.L1104
	cmpw	$58, 98(%rsp)
	je	.L1188
.L1104:
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
	je	.L1189
	movq	728(%rsp), %rax
	movq	__imp_GetFileSizeEx(%rip), %r14
	leaq	80(%rsp), %rdx
	movq	%r12, %rcx
	movq	%r12, (%rax)
	call	*%r14
	testl	%eax, %eax
	je	.L1190
	movq	80(%rsp), %r10
	cmpq	736(%rsp), %r10
	jl	.L1191
	cmpq	$67108864, %r10
	jg	.L1192
	movl	744(%rsp), %eax
	testl	%eax, %eax
	je	.L1110
	movq	%r10, %rax
	movl	744(%rsp), %ecx
	cqto
	idivq	%rcx
	testq	%rdx, %rdx
	jne	.L1193
.L1110:
	movq	%r10, (%rdi)
	movl	$4, %r9d
	movq	%r10, %rdx
	xorl	%ecx, %ecx
	movl	$12288, %r8d
	call	*__imp_VirtualAlloc(%rip)
	movq	%rax, 0(%rbp)
	testq	%rax, %rax
	je	.L1111
	movq	(%rdi), %r8
	movq	__imp_ReadFile(%rip), %rbx
	xorl	%r15d, %r15d
	movq	%rax, %rdx
	movq	__imp_GetLastError(%rip), %r13
	leaq	76(%rsp), %rsi
	testq	%r8, %r8
	jne	.L1112
	jmp	.L1113
	.p2align 4,,10
	.p2align 3
.L1117:
	movl	76(%rsp), %eax
	testl	%eax, %eax
	je	.L1179
	movq	(%rdi), %r8
	movq	%r8, %rdx
	subq	%r15, %rdx
	cmpq	%rdx, %rax
	ja	.L1194
	addq	%rax, %r15
	cmpq	%r15, %r8
	jbe	.L1113
	movq	0(%rbp), %rdx
.L1112:
	addq	%r15, %rdx
	subl	%r15d, %r8d
	movq	%rsi, %r9
	movq	%r12, %rcx
	movl	$0, 76(%rsp)
	movq	$0, 32(%rsp)
	call	*%rbx
	testl	%eax, %eax
	jne	.L1117
	call	*%r13
	testl	%eax, %eax
	je	.L1117
	.p2align 4,,10
	.p2align 3
.L1179:
	movl	%eax, %edx
	leaq	.LC20(%rip), %rcx
	movl	$7, %r13d
	call	werr
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1191:
	leaq	.LC15(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1192:
	leaq	.LC16(%rip), %rcx
	movl	$1, %r13d
	call	fset
	movq	80(%rsp), %rcx
	call	fdec
	leaq	.LC17(%rip), %rcx
	call	fcat
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1113:
	movl	$0, 76(%rsp)
	leaq	75(%rsp), %rdx
	movq	%rsi, %r9
	movq	%r12, %rcx
	movq	$0, 32(%rsp)
	movl	$1, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.L1195
	movl	76(%rsp), %r13d
	testl	%r13d, %r13d
	jne	.L1121
	leaq	88(%rsp), %rdx
	movq	%r12, %rcx
	call	*%r14
	testl	%eax, %eax
	je	.L1121
	movq	80(%rsp), %rax
	cmpq	%rax, 88(%rsp)
	je	.L1073
.L1121:
	leaq	.LC21(%rip), %rcx
	movl	$7, %r13d
	call	fset
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1194:
	xorl	%eax, %eax
	jmp	.L1179
	.p2align 4,,10
	.p2align 3
.L1190:
	call	*__imp_GetLastError(%rip)
	leaq	.LC14(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1189:
	call	*__imp_GetLastError(%rip)
	leaq	.LC13(%rip), %rcx
	movl	$7, %r13d
	movl	%eax, %edx
	call	werr
	jmp	.L1073
	.p2align 4,,10
	.p2align 3
.L1193:
	leaq	.LC18(%rip), %rcx
	movl	$1, %r13d
	call	fset
	jmp	.L1073
.L1111:
	leaq	.LC19(%rip), %rcx
	movl	$8, %r13d
	call	fset
	jmp	.L1073
.L1195:
	call	*__imp_GetLastError(%rip)
	jmp	.L1179
.L1188:
	cmpq	$2, %rbx
	je	.L1077
	cmpw	$92, 100(%rsp)
	jne	.L1077
	jmp	.L1104
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
	je	.L1197
	movl	16(%rcx), %eax
	movq	$1, 24(%rcx)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39(%rcx)
	movb	%al, 38(%rcx)
	xorl	%eax, %eax
.L1197:
	ret
	.p2align 4
	.globl	hrdbf_skip
	.def	hrdbf_skip;	.scl	2;	.type	32;	.endef
hrdbf_skip:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1200
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.L1200
	movb	$0, 38(%rcx)
	movq	24(%rcx), %rax
	jle	.L1202
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
.L1204:
	movl	$1, %eax
	testl	%r9d, %r9d
	jne	.L1214
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1200:
	ret
	.p2align 4,,10
	.p2align 3
.L1202:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%r8, %rax
	ja	.L1205
	xorl	%eax, %eax
	movq	$1, 24(%rcx)
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	movb	$1, 38(%rcx)
	ret
	.p2align 4,,10
	.p2align 3
.L1214:
	cmpq	%r9, 24(%rcx)
	seta	%al
	movb	%al, 39(%rcx)
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1205:
	addq	%rax, %rdx
	movl	16(%rcx), %r9d
	movq	%rdx, 24(%rcx)
	jmp	.L1204
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
	je	.L1217
	testl	%edx, %edx
	je	.L1219
	movzwl	36(%rcx), %eax
	cmpl	%edx, %eax
	jb	.L1219
	jmp	hrdbf_get.part.0
	.p2align 4,,10
	.p2align 3
.L1219:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1217:
	movl	$6, %eax
	ret
	.p2align 4
	.globl	hrdbf_deleted
	.def	hrdbf_deleted;	.scl	2;	.type	32;	.endef
hrdbf_deleted:
	cmpb	$0, 40(%rcx)
	movl	$6, %eax
	je	.L1220
	movq	24(%rcx), %rax
	movl	16(%rcx), %r9d
	xorl	%r8d, %r8d
	cmpq	%r9, %rax
	ja	.L1222
	movzwl	34(%rcx), %r8d
	subq	$1, %rax
	imulq	%r8, %rax
	movzwl	32(%rcx), %r8d
	addq	(%rcx), %rax
	cmpb	$42, (%rax,%r8)
	sete	%r8b
.L1222:
	movb	%r8b, (%rdx)
	xorl	%eax, %eax
.L1220:
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
	jbe	.L1310
	cmpb	$3, (%rdx)
	movq	%rdx, %rbx
	jne	.L1311
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
	jbe	.L1229
	testl	%esi, %esi
	movq	%rax, 32(%rsp)
	sete	%dl
	cmpq	%r8, %rax
	seta	%al
	orb	%al, %dl
	je	.L1230
.L1229:
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
.L1225:
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
.L1230:
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
.L1256:
	movzbl	(%r8), %r10d
	movq	%r15, %r9
	salq	$5, %r9
	cmpb	$13, %r10b
	je	.L1312
	cmpq	%r15, 64(%rsp)
	je	.L1313
	cmpq	$129, %r15
	je	.L1314
	movw	%r15w, 46(%rsp)
	xorl	%eax, %eax
	jmp	.L1240
	.p2align 4,,10
	.p2align 3
.L1315:
	movzbl	(%r8,%rax), %r10d
.L1240:
	movb	%r10b, 42(%rsi,%rax)
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L1315
	movzbl	-11(%rcx), %ebp
	testb	%bpl, %bpl
	je	.L1241
	cmpl	$1, %r15d
	jbe	.L1242
	leal	-1(%r15), %edi
	xorl	%r10d, %r10d
	salq	$4, %rdi
	.p2align 4,,10
	.p2align 3
.L1243:
	movq	%r14, %rax
	movl	%ebp, %edx
	jmp	.L1246
	.p2align 4,,10
	.p2align 3
.L1317:
	movzbl	(%rax), %edx
	addq	$1, %rax
.L1246:
	leaq	(%r11,%rax), %r9
	cmpb	%dl, -1(%r9,%r10)
	jne	.L1316
	cmpq	%rax, %rcx
	jne	.L1317
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
	jmp	.L1225
	.p2align 4,,10
	.p2align 3
.L1316:
	addq	$16, %r10
	cmpq	%r10, %rdi
	jne	.L1243
.L1242:
	movzbl	11(%r8), %edx
	movzbl	16(%r8), %eax
	movw	%bx, 3(%rcx)
	movzbl	17(%r8), %r9d
	movb	%dl, (%rcx)
	movb	%al, 1(%rcx)
	movb	%r9b, 2(%rcx)
	testb	%al, %al
	je	.L1318
	cmpb	$67, %dl
	je	.L1319
	cmpb	$78, %dl
	je	.L1320
	cmpb	$76, %dl
	je	.L1321
	cmpb	$68, %dl
	jne	.L1253
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$8, 166(%rsp,%rdx)
	je	.L1249
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
	jmp	.L1225
	.p2align 4,,10
	.p2align 3
.L1310:
	leaq	.LC15(%rip), %rdx
	call	dset
	movl	$1, %eax
	jmp	.L1225
.L1311:
	leaq	.LC24(%rip), %rdx
	call	dset
	movzbl	(%rbx), %edx
	movq	%r12, %rcx
	call	dhex
	leaq	.LC25(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	$2, %eax
	jmp	.L1225
.L1319:
	testb	%r9b, %r9b
	jne	.L1322
.L1249:
	addl	%eax, %ebx
	cmpl	$65535, %ebx
	ja	.L1323
	addq	$1, %r15
	addq	$32, %r8
	addq	$16, %rsi
	addq	$16, %r14
	addl	$1, 40(%rsp)
	subq	$16, %r11
	addq	$16, %rcx
	movl	$1, %edx
	cmpq	72(%rsp), %r15
	jne	.L1256
	movzwl	46(%rsp), %eax
	leaq	.LC48(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	$1, %eax
	jmp	.L1225
.L1320:
	cmpb	$17, %r9b
	ja	.L1277
	cmpb	%r9b, %al
	ja	.L1249
.L1277:
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
	jmp	.L1225
	.p2align 4,,10
	.p2align 3
.L1321:
	movslq	40(%rsp), %rdx
	salq	$4, %rdx
	cmpw	$1, 166(%rsp,%rdx)
	je	.L1249
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
	jmp	.L1225
	.p2align 4,,10
	.p2align 3
.L1313:
	testb	%dl, %dl
	je	.L1236
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1236:
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
	jmp	.L1225
.L1314:
	testb	%dl, %dl
	je	.L1238
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1238:
	leaq	.LC31(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$4, %eax
	jmp	.L1225
.L1312:
	movl	%ebx, %edi
	movq	2456(%rsp), %rbx
	testb	%dl, %dl
	je	.L1232
	movzwl	40(%rsp), %eax
	movw	%ax, 148(%rsp)
.L1232:
	cmpw	$0, 148(%rsp)
	je	.L1324
	addq	$1, %r9
	cmpl	%edi, 52(%rsp)
	je	.L1258
	jmp	.L1325
	.p2align 4,,10
	.p2align 3
.L1259:
	addq	$1, %r9
	cmpb	$0, -1(%rbx,%r9)
	jne	.L1326
.L1258:
	cmpq	%r9, 32(%rsp)
	ja	.L1259
	movl	%edi, %ecx
	movq	%r13, %rax
	xorl	%edx, %edx
	subq	32(%rsp), %rax
	divq	%rcx
	movl	48(%rsp), %r8d
	cmpq	%rax, %r8
	ja	.L1327
	movq	%rcx, %rax
	imulq	%r8, %rax
	addq	32(%rsp), %rax
	cmpq	%rax, %r13
	je	.L1261
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	jne	.L1262
	cmpb	$26, (%rbx,%rax)
	je	.L1261
.L1262:
	leaq	.LC56(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1225
.L1241:
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
	jmp	.L1225
.L1318:
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
	jmp	.L1225
.L1326:
	leaq	.LC52(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1225
.L1323:
	movzwl	46(%rsp), %eax
	leaq	.LC47(%rip), %rdx
	movq	%r12, %rcx
	movw	%ax, 148(%rsp)
	call	dset
	movl	$4, %eax
	jmp	.L1225
.L1322:
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
	jmp	.L1225
.L1325:
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
	jmp	.L1225
.L1324:
	leaq	.LC49(%rip), %rdx
	movq	%r12, %rcx
	call	dset
	movl	$1, %eax
	jmp	.L1225
.L1253:
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
	jmp	.L1225
.L1261:
	cmpl	$0, 48(%rsp)
	movq	%rbx, 112(%rsp)
	sete	%al
	movq	%r13, 120(%rsp)
	movb	$1, 152(%rsp)
	movq	$1, 136(%rsp)
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
	testq	%r8, %r8
	je	.L1274
	xorl	%r13d, %r13d
	leaq	80(%rsp), %r8
.L1266:
	movzwl	146(%rsp), %eax
	movzwl	144(%rsp), %edx
	imulq	%r13, %rax
	addq	$1, %r13
	addq	%rbx, %rax
	movzbl	(%rax,%rdx), %edi
	cmpb	$32, %dil
	je	.L1264
	cmpb	$42, %dil
	jne	.L1328
.L1264:
	cmpw	$0, 148(%rsp)
	movq	%r13, 136(%rsp)
	movl	$1, %esi
	jne	.L1265
	jmp	.L1272
	.p2align 4,,10
	.p2align 3
.L1268:
	movq	56(%rsp), %rcx
	movl	%esi, %edx
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1329
	movzwl	148(%rsp), %eax
	addl	$1, %esi
	cmpl	%esi, %eax
	jb	.L1272
.L1265:
	movl	$85, %eax
	cmpb	$0, 152(%rsp)
	movb	$0, 108(%rsp)
	movw	%ax, 80(%rsp)
	movb	$0, 82(%rsp)
	movq	$0, 88(%rsp)
	movq	$0, 96(%rsp)
	movl	$0, 104(%rsp)
	jne	.L1268
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
.L1269:
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	dcat
	movl	%ebx, %edx
	movl	40(%rsp), %eax
	salq	$4, %rdx
	cmpb	$76, 165(%rsp,%rdx)
	je	.L1330
.L1271:
	cmpb	$42, %dil
	jne	.L1225
	leaq	.LC62(%rip), %rdx
	movq	%r12, %rcx
	movl	%eax, 40(%rsp)
	call	dcat
	movl	40(%rsp), %eax
	jmp	.L1225
.L1272:
	movl	128(%rsp), %edx
	movq	%rdx, %rax
	cmpq	%r13, %rdx
	ja	.L1266
	cmpb	$0, 152(%rsp)
	je	.L1273
.L1263:
	movq	$1, 136(%rsp)
	testl	%eax, %eax
	sete	%al
	movb	%al, 151(%rsp)
	movb	%al, 150(%rsp)
.L1273:
	movq	56(%rsp), %rsi
	movl	$282, %ecx
	movq	%r12, %rdi
	xorl	%eax, %eax
	rep movsq
	jmp	.L1225
.L1330:
	leaq	.LC61(%rip), %rdx
	movq	%r12, %rcx
	call	dcat
	movl	40(%rsp), %eax
	jmp	.L1271
.L1327:
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
	jmp	.L1225
.L1328:
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
	jmp	.L1225
.L1274:
	xorl	%eax, %eax
	jmp	.L1263
.L1329:
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
	jmp	.L1269
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
	ja	.L1333
	je	.L1364
	cmpl	$5, %edx
	je	.L1337
	shrq	$8, %rax
	jne	.L1333
	xorl	%r8d, %r8d
	cmpl	$11, %edx
	jne	.L1333
	movl	$4, %r8d
	cmpq	$99991231, %rcx
	ja	.L1333
	xorl	%r8d, %r8d
	testq	%rcx, %rcx
	je	.L1333
	movq	%rcx, %rax
	movl	$4, %r8d
	movabsq	$3777893186295716171, %rdx
	mulq	%rdx
	shrq	$11, %rdx
	leal	-1(%rdx), %eax
	movq	%rdx, %r9
	cmpl	$9998, %eax
	ja	.L1333
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
	ja	.L1351
	testq	%rcx, %rcx
	je	.L1351
	leaq	days.0(%rip), %r8
	movl	(%r8,%rax,4), %eax
	cmpl	$2, %edx
	je	.L1365
.L1339:
	xorl	%r8d, %r8d
	cmpl	%ecx, %eax
	setb	%r8b
	sall	$2, %r8d
.L1333:
	leave
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1364:
	movq	%rax, %rdx
	shrq	$32, %rdx
	jne	.L1333
	movq	%rax, %rdx
	shrq	$16, %rdx
	je	.L1333
	movl	%edx, %r8d
	andl	$65280, %r8d
	jne	.L1351
	movzbl	%ah, %eax
	cmpl	$17, %eax
	ja	.L1351
	cmpl	%edx, %eax
	jb	.L1333
.L1351:
	leave
	movl	$4, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1337:
	testq	%rax, %rax
	jns	.L1346
	movabsq	$-9223372036854775803, %rdx
	cmpq	%rdx, %rax
	jne	.L1333
.L1346:
	leave
	xorl	%r8d, %r8d
	movl	%r8d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1365:
	testb	$3, %r9b
	jne	.L1339
	imull	$-1030792151, %r9d, %r9d
	movl	%r9d, %edx
	rorl	$2, %edx
	cmpl	$42949672, %edx
	jbe	.L1340
	addl	$1, %eax
	jmp	.L1339
.L1340:
	rorl	$4, %r9d
	cmpl	$10737419, %r9d
	adcl	$0, %eax
	jmp	.L1339
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
	ja	.L1366
	leaq	CSWTCH.385(%rip), %rdx
	movzbl	(%rdx,%rax), %r8d
.L1366:
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
	jne	.L1371
	movzbl	%r11b, %edx
	cmpb	$12, %r11b
	je	.L1382
	testl	%edx, %edx
	je	.L1374
	cmpl	$9, %edx
	je	.L1374
	movl	$1, %eax
.L1371:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1382:
	testl	$65280, %r11d
	jne	.L1383
.L1374:
	movq	%rsi, (%rbx)
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1383:
	movl	$2, %eax
	jmp	.L1371
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
	jne	.L1384
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1384
	movzbl	%r11b, %r15d
	movzbl	%dil, %r14d
	cmpb	$11, %r11b
	jne	.L1386
	cmpl	$11, %r14d
	jne	.L1386
.L1397:
	xorl	%edx, %edx
	cmpq	%r13, %rsi
	sete	%dl
	movl	%edx, (%rbx)
.L1384:
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
.L1386:
	cmpl	$1, %r15d
	je	.L1400
	cmpl	$1, %r14d
	je	.L1400
	cmpl	$3, %r15d
	jne	.L1389
	cmpl	$3, %r14d
	jne	.L1389
	testq	%rsi, %rsi
	sete	%dl
	testq	%r13, %r13
	setne	%cl
	xorl	%ecx, %edx
	movzbl	%dl, %edx
	movl	%edx, (%rbx)
	jmp	.L1384
	.p2align 4,,10
	.p2align 3
.L1400:
	xorl	%edx, %edx
	cmpl	%r15d, %r14d
	sete	%dl
	movl	%edx, (%rbx)
	jmp	.L1384
	.p2align 4,,10
	.p2align 3
.L1389:
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1393
	cmpl	$12, %r15d
	je	.L1423
	testl	%r15d, %r15d
	je	.L1392
	cmpl	$9, %r15d
	jne	.L1393
.L1392:
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1393
	cmpl	$12, %r14d
	je	.L1424
	testl	%r14d, %r14d
	je	.L1397
	cmpl	$9, %r14d
	je	.L1397
	.p2align 4,,10
	.p2align 3
.L1393:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r12, %rcx
	movq	%r11, 32(%rsp)
	movq	%rsi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1425
.L1399:
	movl	$1, %eax
	jmp	.L1384
	.p2align 4,,10
	.p2align 3
.L1423:
	testl	$65280, %r11d
	je	.L1392
	jmp	.L1393
	.p2align 4,,10
	.p2align 3
.L1425:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r12, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r13, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1399
	xorl	%edx, %edx
	movsd	64(%rsp), %xmm0
	ucomisd	72(%rsp), %xmm0
	setnp	%dl
	cmovne	%eax, %edx
	movl	%edx, (%rbx)
	jmp	.L1384
	.p2align 4,,10
	.p2align 3
.L1424:
	testl	$65280, %edi
	je	.L1397
	jmp	.L1393
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
	jne	.L1426
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	je	.L1447
.L1426:
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
.L1447:
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1428
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1448
	testl	%eax, %eax
	je	.L1430
	cmpl	$9, %eax
	je	.L1430
	.p2align 4,,10
	.p2align 3
.L1428:
	leaq	64(%rsp), %rdx
	leaq	56(%rsp), %r8
	movq	%r13, %rcx
	movq	%r11, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	je	.L1449
.L1436:
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
.L1449:
	leaq	72(%rsp), %rdx
	leaq	60(%rsp), %r8
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_to_double
	testl	%eax, %eax
	jne	.L1436
	movsd	64(%rsp), %xmm1
	movsd	72(%rsp), %xmm0
	movq	$-1, %rdx
	comisd	%xmm1, %xmm0
	ja	.L1437
	xorl	%edx, %edx
	comisd	%xmm0, %xmm1
	seta	%dl
.L1437:
	movq	%rdx, (%rbx)
	jmp	.L1426
	.p2align 4,,10
	.p2align 3
.L1448:
	testl	$65280, %r11d
	jne	.L1428
.L1430:
	movq	%r13, %rcx
	movq	%rsi, 32(%rsp)
	movq	%rdi, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1428
	movzbl	%sil, %edx
	cmpb	$12, %sil
	je	.L1450
	testl	%edx, %edx
	je	.L1433
	cmpl	$9, %edx
	jne	.L1428
.L1433:
	xorl	%edx, %edx
	cmpq	%rdi, %r12
	movq	$-1, %rcx
	setg	%dl
	cmovl	%rcx, %rdx
	movq	%rdx, (%rbx)
	jmp	.L1426
	.p2align 4,,10
	.p2align 3
.L1450:
	testl	$65280, %esi
	je	.L1433
	jmp	.L1428
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
	jne	.L1451
	movzbl	%r11b, %ecx
	cmpb	$12, %r11b
	ja	.L1455
	movl	$1, %edx
	salq	%cl, %rdx
	testl	$6665, %edx
	jne	.L1453
	andl	$2, %edx
	jne	.L1457
.L1455:
	movl	$1, %eax
.L1451:
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L1453:
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
.L1457:
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
	jne	.L1458
	movq	%r13, %rcx
	movzbl	%bl, %eax
	cmpb	$11, %bl
	je	.L1505
	cmpl	$12, %eax
	jne	.L1484
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
.L1466:
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
	ja	.L1466
	cmpl	%ebx, %r8d
	ja	.L1506
	movl	$1, %r9d
.L1467:
	leal	1(%r9,%rbx), %eax
.L1468:
	movq	%r13, %rdx
	shrq	$63, %rdx
	addl	%edx, %eax
	movl	44(%rsp), %edx
	cmpq	%rsi, %rdx
	ja	.L1469
	movq	%rdx, (%rdi)
	cmpl	%edx, %eax
	ja	.L1507
	movl	44(%rsp), %r10d
	subl	%eax, %r10d
	je	.L1477
	leal	-1(%r10), %edx
	movq	%r11, %rax
	leaq	1(%r11,%rdx), %rdx
	.p2align 4,,10
	.p2align 3
.L1476:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.L1476
.L1477:
	testq	%r13, %r13
	jns	.L1475
	movl	%r10d, %eax
	addl	$1, %r10d
	movb	$45, (%r11,%rax)
.L1475:
	testl	%r9d, %r9d
	je	.L1478
	leal	-1(%r9,%rbx), %eax
	leal	(%r10,%rax), %esi
	jmp	.L1480
	.p2align 4,,10
	.p2align 3
.L1488:
	movl	%edx, %eax
.L1480:
	movl	%esi, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1479
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1479:
	movb	%cl, (%r11,%rdx)
	leal	-1(%rax), %edx
	cmpl	%eax, %ebx
	jne	.L1488
	addl	%r9d, %r10d
.L1478:
	testl	%ebx, %ebx
	je	.L1458
	movl	%r10d, %eax
	leal	(%r10,%rbx), %r9d
	movb	$46, (%r11,%rax)
	leal	-1(%rbx), %eax
	.p2align 4,,10
	.p2align 3
.L1482:
	movl	%r9d, %edx
	movl	$48, %ecx
	subl	%eax, %edx
	cmpl	%eax, %r8d
	jbe	.L1481
	movl	%eax, %ecx
	movzbl	64(%rsp,%rcx), %ecx
.L1481:
	movb	%cl, (%r11,%rdx)
	subl	$1, %eax
	jnb	.L1482
.L1458:
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
.L1505:
	cmpq	$7, %rsi
	jbe	.L1469
	movq	$8, (%rdi)
	testq	%r13, %r13
	je	.L1464
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
	jmp	.L1458
	.p2align 4,,10
	.p2align 3
.L1484:
	movl	$1, %r12d
	jmp	.L1458
	.p2align 4,,10
	.p2align 3
.L1508:
	movl	$32, %eax
	cmpl	$5, %ecx
	je	.L1483
.L1463:
	movb	%al, (%r11,%rcx)
	addq	$1, %rcx
	cmpq	$8, %rcx
	je	.L1458
.L1464:
	cmpl	$2, %ecx
	jne	.L1508
.L1483:
	movl	$47, %eax
	jmp	.L1463
	.p2align 4,,10
	.p2align 3
.L1506:
	movl	%r8d, %r9d
	subl	%ebx, %r9d
	testl	%ebx, %ebx
	jne	.L1467
	movl	%r9d, %eax
	jmp	.L1468
	.p2align 4,,10
	.p2align 3
.L1469:
	movl	$3, %r12d
	jmp	.L1458
	.p2align 4,,10
	.p2align 3
.L1507:
	movl	%edx, %eax
	testl	%edx, %edx
	je	.L1458
	subl	$1, %eax
	leaq	1(%r11,%rax), %rax
	.p2align 4,,10
	.p2align 3
.L1472:
	movb	$42, (%r11)
	addq	$1, %r11
	cmpq	%r11, %rax
	jne	.L1472
	jmp	.L1458
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
	jne	.L1509
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1509
	leal	-43(%rbx), %r13d
	andl	$-3, %r13d
	je	.L1549
	cmpl	$42, %ebx
	je	.L1549
	cmpl	$47, %ebx
	je	.L1524
	cmpl	$37, %ebx
	je	.L1551
	movl	$1, %r8d
	cmpl	$94, %ebx
	je	.L1551
.L1509:
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
.L1549:
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L1524
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L1571
	testl	%eax, %eax
	je	.L1515
	cmpl	$9, %eax
	je	.L1515
	.p2align 4,,10
	.p2align 3
.L1524:
	leaq	64(%rsp), %r8
	leaq	80(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1509
	leaq	72(%rsp), %r8
	leaq	88(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1509
	movsd	88(%rsp), %xmm0
	cmpl	$43, %ebx
	je	.L1572
	testl	%r13d, %r13d
	je	.L1573
	cmpl	$42, %ebx
	je	.L1574
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1550
	jne	.L1550
	movl	$5, %r8d
	jmp	.L1509
	.p2align 4,,10
	.p2align 3
.L1571:
	testl	$65280, %r11d
	jne	.L1524
.L1515:
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_validate
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1524
	movzbl	%dil, %eax
	cmpb	$12, %dil
	je	.L1575
	testl	%eax, %eax
	je	.L1518
	cmpl	$9, %eax
	jne	.L1524
.L1518:
	movq	$0, (%rsi)
	cmpl	$43, %ebx
	je	.L1576
	testl	%r13d, %r13d
	je	.L1577
	imulq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1509
	.p2align 4,,10
	.p2align 3
.L1551:
	leaq	48(%rsp), %r8
	leaq	56(%rsp), %rdx
	movq	%r15, %rcx
	movq	%r11, 32(%rsp)
	movq	%r14, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1509
	leaq	52(%rsp), %r8
	leaq	64(%rsp), %rdx
	movq	%r15, %rcx
	movq	%rdi, 32(%rsp)
	movq	%r12, 40(%rsp)
	call	hrv_to_double
	movl	%eax, %r8d
	testl	%eax, %eax
	jne	.L1509
	movsd	64(%rsp), %xmm0
	cmpl	$37, %ebx
	jne	.L1533
	ucomisd	.LC65(%rip), %xmm0
	jp	.L1534
	jne	.L1534
	movq	$0, (%rsi)
	movq	$0, 8(%rsi)
	jmp	.L1509
	.p2align 4,,10
	.p2align 3
.L1575:
	testl	$65280, %edi
	je	.L1518
	jmp	.L1524
	.p2align 4,,10
	.p2align 3
.L1574:
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
.L1527:
	movq	%rax, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1509
	.p2align 4,,10
	.p2align 3
.L1550:
	movsd	80(%rsp), %xmm1
	movl	$517, %eax
	divsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1527
	.p2align 4,,10
	.p2align 3
.L1572:
	addsd	80(%rsp), %xmm0
	movq	%xmm0, %rdx
.L1570:
	movl	64(%rsp), %eax
	cmpl	%eax, 72(%rsp)
	cmovnb	72(%rsp), %eax
	movl	%eax, %eax
	salq	$8, %rax
	orq	$5, %rax
	jmp	.L1527
	.p2align 4,,10
	.p2align 3
.L1573:
	movsd	80(%rsp), %xmm1
	subsd	%xmm0, %xmm1
	movq	%xmm1, %rdx
	jmp	.L1570
	.p2align 4,,10
	.p2align 3
.L1576:
	addq	%r14, %r12
	movq	%r12, 8(%rsi)
	jmp	.L1509
.L1533:
	movq	56(%rsp), %rcx
	movq	%xmm0, %r9
	movabsq	$9223372036854775807, %rax
	movq	%rcx, %r10
	andq	%rax, %r10
	andq	%r9, %rax
	testq	%rcx, %rcx
	js	.L1578
	testq	%r10, %r10
	jne	.L1543
.L1538:
	movabsq	$4607182418800017408, %rdx
	testq	%rax, %rax
	je	.L1536
	testq	%r9, %r9
	movl	$0, %edx
	movabsq	$9218868437227405312, %rax
	cmovs	%rax, %rdx
	.p2align 4,,10
	.p2align 3
.L1536:
	movq	$517, (%rsi)
	movq	%rdx, 8(%rsi)
	jmp	.L1509
.L1577:
	subq	%r12, %r14
	xorl	%r8d, %r8d
	movq	%r14, 8(%rsi)
	jmp	.L1509
.L1534:
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
	jmp	.L1536
.L1578:
	testq	%r10, %r10
	je	.L1538
	movabsq	$4841369599423283199, %rdx
	movq	%rax, %xmm1
	cmpq	%rdx, %rax
	ja	.L1539
	cvttsd2siq	%xmm1, %rdx
	pxor	%xmm2, %xmm2
	cvtsi2sdq	%rdx, %xmm2
	ucomisd	%xmm1, %xmm2
	jp	.L1546
	jne	.L1546
.L1539:
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
	ja	.L1536
	cvttsd2siq	%xmm1, %rax
	testb	$1, %al
	je	.L1536
	movq	%rdx, %xmm3
	pxor	%xmm0, %xmm0
	subsd	%xmm3, %xmm0
	movq	%xmm0, %rdx
	jmp	.L1536
.L1543:
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
	jmp	.L1536
.L1546:
	movl	$4095, %edx
	salq	$51, %rdx
	jmp	.L1536
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
	je	.L1579
	ja	.L1581
	leaq	.LC69(%rip), %rax
	cmpl	$1, %ecx
	je	.L1579
	leaq	.LC72(%rip), %rax
	cmpl	$2, %ecx
	jne	.L1592
.L1579:
	ret
	.p2align 4,,10
	.p2align 3
.L1592:
	testl	%ecx, %ecx
	leaq	.LC70(%rip), %rdx
	leaq	.LC67(%rip), %rax
	cmove	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.L1581:
	leaq	.LC71(%rip), %rax
	cmpl	$4, %ecx
	je	.L1579
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
	ja	.L1596
	movq	%xmm2, %r11
	movq	%xmm2, %rdi
	movq	%xmm2, %rax
	shrq	$52, %r11
	shrq	$63, %rdi
	andl	$2047, %r11d
	movq	%rdi, 40(%rsp)
	cmpq	$2047, %r11
	je	.L1596
	movabsq	$4503599627370495, %rdx
	movq	%rcx, %rsi
	movl	%r9d, %ebx
	andq	%rdx, %rax
	testq	%r11, %r11
	je	.L1691
	btsq	$52, %rax
	subl	$1075, %r11d
	movl	$2, %r9d
	movq	%rax, 256(%rsp)
.L1600:
	movl	%r9d, 544(%rsp)
	leaq	256(%rsp), %rbp
	testl	%ebx, %ebx
	je	.L1607
	xorl	%r12d, %r12d
	xorl	%r10d, %r10d
	leaq	256(%rsp), %rbp
	leaq	260(%rsp), %rdi
	.p2align 4,,10
	.p2align 3
.L1606:
	leal	-1(%r9), %eax
	movq	%rbp, %rdx
	leaq	(%rdi,%rax,4), %r8
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1608:
	movl	(%rdx), %ecx
	addq	$4, %rdx
	leaq	(%rcx,%rcx,4), %rcx
	addq	%rcx, %rax
	movl	%eax, -4(%rdx)
	shrq	$32, %rax
	cmpq	%rdx, %r8
	jne	.L1608
	testq	%rax, %rax
	je	.L1609
	movl	%r9d, %edx
	movl	$1, %r12d
	addl	$1, %r9d
	movl	%eax, 256(%rsp,%rdx,4)
.L1609:
	addl	$1, %r10d
	cmpl	%r10d, %ebx
	jne	.L1606
	testb	%r12b, %r12b
	je	.L1607
	movl	%r9d, 544(%rsp)
.L1607:
	movl	%r11d, %edx
	addl	%ebx, %edx
	js	.L1612
	movq	%rbp, %rcx
	call	bn_shl
	movl	544(%rsp), %edi
.L1613:
	xorl	%r12d, %r12d
	jmp	.L1619
	.p2align 4,,10
	.p2align 3
.L1620:
	cmpq	$48, %r12
	je	.L1692
	movq	%rbp, %rcx
	call	bn_divmod_1e9
	movl	544(%rsp), %edi
	movl	%eax, 64(%rsp,%r12,4)
	addq	$1, %r12
.L1619:
	movl	%r12d, %r13d
	cmpl	$1, %edi
	jne	.L1620
	movl	256(%rsp), %eax
	testl	%eax, %eax
	jne	.L1620
	testl	%r12d, %r12d
	jne	.L1693
	movl	$0, 64(%rsp)
	movl	$48, %edx
	movb	$48, 54(%rsp)
.L1625:
	leaq	560(%rsp), %r14
	movl	%edi, %ecx
	addq	%r14, %rcx
	movq	%r14, %rax
	leal	-1(%rdi,%r14), %r8d
	jmp	.L1628
	.p2align 4,,10
	.p2align 3
.L1694:
	movl	%r8d, %edx
	subl	%eax, %edx
	movzbl	54(%rsp,%rdx), %edx
.L1628:
	movb	%dl, (%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.L1694
	testl	%r13d, %r13d
	je	.L1629
	leaq	64(%rsp), %r15
	leal	-1(%r13), %eax
	movl	$3435973837, %r9d
	leaq	(%r15,%rax,4), %r12
	leal	-1(%rdi), %ebp
	.p2align 4,,10
	.p2align 3
.L1631:
	movl	%ebp, %r10d
	movl	(%r12), %edx
	addl	$9, %ebp
	movl	%ebp, %ecx
	.p2align 4,,10
	.p2align 3
.L1630:
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
	jne	.L1630
	leaq	-4(%r12), %rax
	cmpq	%r12, %r15
	je	.L1695
	movq	%rax, %r12
	jmp	.L1631
	.p2align 4,,10
	.p2align 3
.L1596:
	xorl	%eax, %eax
.L1593:
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
.L1691:
	testq	%rax, %rax
	jne	.L1696
	cmpq	$0, 40(%rsp)
	jne	.L1697
	xorl	%edx, %edx
.L1601:
	testl	%ebx, %ebx
	je	.L1602
	leal	2(%rdx,%rbx), %r8d
	cmpl	1000(%rsp), %r8d
	ja	.L1596
	movl	%edx, %eax
	movb	$48, (%rsi,%rax)
	leal	2(%rdx), %eax
	addl	$1, %edx
	movb	$46, (%rsi,%rdx)
	movl	%eax, %edx
	.p2align 4,,10
	.p2align 3
.L1604:
	movl	%edx, %ecx
	addl	$1, %edx
	movb	$48, (%rsi,%rcx)
	cmpl	%edx, %r8d
	jne	.L1604
	addl	%ebx, %eax
	jmp	.L1593
.L1697:
	movl	1000(%rsp), %edx
	testl	%edx, %edx
	je	.L1596
	movb	$45, (%rcx)
	movl	$1, %edx
	jmp	.L1601
.L1612:
	negl	%edx
	movq	%rbp, %rcx
	call	bn_shr_round
	movl	544(%rsp), %edi
	cmpl	$3, %eax
	je	.L1698
	cmpl	$2, %eax
	jne	.L1613
	movl	256(%rsp), %edx
	movl	%edx, %ecx
	andl	$1, %ecx
	je	.L1613
	testl	%edi, %edi
	je	.L1646
.L1616:
	movq	%rbp, %rcx
	movl	$1, %eax
	xorl	%r8d, %r8d
	jmp	.L1618
	.p2align 4,,10
	.p2align 3
.L1699:
	movl	(%rcx), %edx
.L1618:
	addq	%rdx, %rax
	addl	$1, %r8d
	addq	$4, %rcx
	movl	%eax, -4(%rcx)
	shrq	$32, %rax
	cmpl	%edi, %r8d
	jb	.L1699
	testq	%rax, %rax
	je	.L1613
	movl	%edi, %eax
	addl	$1, %edi
.L1615:
	movl	%edi, 544(%rsp)
	movl	$1, 256(%rsp,%rax,4)
	jmp	.L1613
	.p2align 4,,10
	.p2align 3
.L1695:
	leal	0(%r13,%r13,8), %eax
	addl	%eax, %edi
.L1629:
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
	ja	.L1596
	xorl	%edx, %edx
	testq	%r15, %r15
	je	.L1634
	movb	$45, (%rsi)
	movl	$1, %edx
.L1634:
	cmpl	%edi, %ebx
	jnb	.L1635
	testl	%eax, %eax
	je	.L1651
	addl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1637:
	movzbl	(%r14), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	addq	$1, %r14
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1637
.L1636:
	testl	%ebx, %ebx
	je	.L1593
.L1638:
	cmpl	%edi, %ebx
	movl	%edi, %r10d
	leal	1(%rax), %edx
	movl	%eax, %ecx
	cmovbe	%ebx, %r10d
	movb	$46, (%rsi,%rcx)
	subl	%r10d, %ebx
	je	.L1639
	leal	1(%rbx,%rax), %r8d
	movl	%edx, %eax
	.p2align 4,,10
	.p2align 3
.L1640:
	movl	%eax, %ecx
	addl	$1, %eax
	movb	$48, (%rsi,%rcx)
	cmpl	%r8d, %eax
	jne	.L1640
	addl	%ebx, %edx
.L1639:
	subl	%r10d, %edi
	leal	(%r10,%rdx), %eax
	subl	%edx, %edi
	.p2align 4,,10
	.p2align 3
.L1641:
	leal	(%rdi,%rdx), %r8d
	movl	%edx, %ecx
	addl	$1, %edx
	movzbl	560(%rsp,%r8), %r8d
	movb	%r8b, (%rsi,%rcx)
	cmpl	%eax, %edx
	jne	.L1641
	jmp	.L1593
.L1692:
	movl	252(%rsp), %r8d
	movl	$47, %r13d
.L1623:
	movl	$1, %r9d
	leaq	53(%rsp), %r11
	movl	$3435973837, %r10d
	.p2align 4,,10
	.p2align 3
.L1626:
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
	ja	.L1626
	jmp	.L1625
.L1696:
	movq	%rax, 256(%rsp)
	shrq	$32, %rax
	movl	$-1074, %r11d
	cmpq	$1, %rax
	sbbl	%r9d, %r9d
	addl	$2, %r9d
	jmp	.L1600
.L1602:
	leal	1(%rdx), %eax
	cmpl	1000(%rsp), %eax
	ja	.L1596
	movb	$48, (%rsi,%rdx)
	jmp	.L1593
.L1635:
	movb	$48, (%rsi,%rdx)
	leal	1(%rdx), %eax
	jmp	.L1638
.L1698:
	testl	%edi, %edi
	je	.L1645
	movl	256(%rsp), %edx
	jmp	.L1616
.L1651:
	movl	%edx, %eax
	jmp	.L1636
.L1646:
	xorl	%eax, %eax
	movl	%ecx, %edi
	jmp	.L1615
.L1645:
	xorl	%eax, %eax
	movl	$1, %edi
	jmp	.L1615
.L1693:
	leal	-1(%r12), %eax
	movl	64(%rsp,%rax,4), %r8d
	movq	%rax, %r13
	jmp	.L1623
	.p2align 4
	.globl	hrdbf_fmt_harbour
	.def	hrdbf_fmt_harbour;	.scl	2;	.type	32;	.endef
hrdbf_fmt_harbour:
	cmpl	$32, %r9d
	ja	.L1701
	jmp	hrdbf_fmt_harbour.part.0
	.p2align 4,,10
	.p2align 3
.L1701:
	xorl	%eax, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_char
	.def	hrdbf_write_char;	.scl	2;	.type	32;	.endef
hrdbf_write_char:
	cmpb	$67, 11(%rdx)
	movl	$3, %eax
	jne	.L1702
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	movzbl	12(%rdx), %eax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	testq	%r9, %r9
	je	.L1704
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L1705:
	movzbl	(%r8,%rax), %r10d
	movb	%r10b, (%rcx,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.L1705
	movzbl	12(%rdx), %eax
.L1704:
	cmpq	%rax, %r9
	jnb	.L1707
	.p2align 4,,10
	.p2align 3
.L1706:
	movb	$32, (%rcx,%r9)
	movzbl	12(%rdx), %eax
	addq	$1, %r9
	cmpq	%r9, %rax
	ja	.L1706
.L1707:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1702:
	ret
	.p2align 4
	.globl	hrdbf_write_number_scaled
	.def	hrdbf_write_number_scaled;	.scl	2;	.type	32;	.endef
hrdbf_write_number_scaled:
	cmpb	$78, 11(%rdx)
	jne	.L1716
	jmp	hrdbf_write_number_scaled.part.0
	.p2align 4,,10
	.p2align 3
.L1716:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_number_double
	.def	hrdbf_write_number_double;	.scl	2;	.type	32;	.endef
hrdbf_write_number_double:
	cmpb	$78, 11(%rdx)
	jne	.L1718
	jmp	hrdbf_write_number_double.part.0
	.p2align 4,,10
	.p2align 3
.L1718:
	movl	$3, %eax
	ret
	.p2align 4
	.globl	hrdbf_write_date
	.def	hrdbf_write_date;	.scl	2;	.type	32;	.endef
hrdbf_write_date:
	cmpb	$68, 11(%rdx)
	movl	$3, %r10d
	jne	.L1739
	movzwl	14(%rdx), %eax
	addq	%rax, %rcx
	testl	%r8d, %r8d
	je	.L1742
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
	ja	.L1739
	cmpl	$9999, %r8d
	jbe	.L1739
	testl	%r11d, %r11d
	je	.L1739
	pushq	%rbx
	movl	$3518437209, %ebx
	imulq	%r9, %rbx
	shrq	$45, %rbx
	cmpl	$2, %eax
	je	.L1723
	movl	%eax, %r8d
	movl	$30, %edx
	andl	$-3, %r8d
	cmpl	$4, %r8d
	je	.L1725
	xorl	%edx, %edx
	cmpl	$9, %r8d
	setne	%dl
	addl	$30, %edx
.L1725:
	movl	$5, %r10d
	cmpl	%r11d, %edx
	jb	.L1719
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
.L1719:
	movl	%r10d, %eax
	popq	%rbx
	ret
	.p2align 4,,10
	.p2align 3
.L1742:
	leaq	8(%rcx), %rax
	.p2align 4,,10
	.p2align 3
.L1722:
	movb	$32, (%rcx)
	addq	$1, %rcx
	cmpq	%rcx, %rax
	jne	.L1722
	xorl	%r10d, %r10d
.L1739:
	movl	%r10d, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1723:
	movl	$28, %edx
	testb	$3, %bl
	jne	.L1725
	imull	$-1030792151, %ebx, %r8d
	movl	$29, %edx
	movl	%r8d, %r10d
	rorl	$2, %r10d
	cmpl	$42949672, %r10d
	ja	.L1725
	rorl	$4, %r8d
	xorl	%edx, %edx
	cmpl	$10737419, %r8d
	setb	%dl
	addl	$28, %edx
	jmp	.L1725
	.p2align 4
	.globl	hrdbf_write_logical
	.def	hrdbf_write_logical;	.scl	2;	.type	32;	.endef
hrdbf_write_logical:
	cmpb	$76, 11(%rdx)
	movl	$3, %eax
	jne	.L1743
	cmpb	$1, %r8b
	movzwl	14(%rdx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	xorl	%eax, %eax
.L1743:
	ret
	.p2align 4
	.globl	hrdbf_write_blank
	.def	hrdbf_write_blank;	.scl	2;	.type	32;	.endef
hrdbf_write_blank:
	movzbl	11(%rdx), %eax
	movzwl	14(%rdx), %r8d
	leal	-67(%rax), %r9d
	cmpb	$1, %r9b
	jbe	.L1755
	andl	$-3, %eax
	cmpb	$76, %al
	jne	.L1754
.L1755:
	movzbl	12(%rdx), %r9d
	testl	%r9d, %r9d
	je	.L1753
	leaq	1(%rcx,%r8), %rdx
	leaq	(%rcx,%r8), %rax
	leal	-1(%r9), %ecx
	addq	%rcx, %rdx
	.p2align 4,,10
	.p2align 3
.L1752:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1752
.L1753:
	xorl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1754:
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
	je	.L1766
	movq	$0, 2280(%rbx)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	je	.L1773
.L1766:
	xorl	%r12d, %r12d
.L1765:
	movq	2256(%rbx), %rcx
	testq	%rcx, %rcx
	je	.L1763
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1768
	movq	$0, 2256(%rbx)
	movq	$0, 2264(%rbx)
.L1763:
	addq	$40, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1773:
	movl	$7, %r12d
	jmp	.L1765
	.p2align 4,,10
	.p2align 3
.L1768:
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
	je	.L1775
	movl	%eax, %r13d
	leaq	fsink(%rip), %rax
	leaq	2288(%r12), %rdx
	leaq	159(%rax), %r8
	jmp	.L1776
	.p2align 4,,10
	.p2align 3
.L1778:
	addq	$1, %rax
	movb	%cl, (%rdx)
	addq	$1, %rdx
	cmpq	%r8, %rax
	je	.L1777
.L1776:
	movzbl	(%rax), %ecx
	testb	%cl, %cl
	jne	.L1778
.L1777:
	movb	$0, (%rdx)
.L1780:
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
.L1775:
	movq	2256(%r12), %rdx
	movq	2264(%r12), %r8
	movq	%r12, %rcx
	call	hrdbf_open
	movl	%eax, %r13d
	testl	%eax, %eax
	jne	.L1780
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
	je	.L1791
	movzwl	36+hrdbf_app_state(%rip), %eax
	movq	%rcx, %r12
	cmpl	%eax, %edx
	ja	.L1801
	movq	%r8, %rbx
	leaq	hrdbf_app_state(%rip), %rcx
	leaq	32(%rsp), %r8
	call	hrdbf_get.part.0
	testl	%eax, %eax
	jne	.L1791
	movzbl	32(%rsp), %eax
	cmpb	$67, %al
	je	.L1805
	cmpb	$78, %al
	je	.L1806
	cmpb	$68, %al
	je	.L1800
	movzbl	60(%rsp), %eax
.L1790:
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$3, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1805:
	movq	40(%rsp), %rcx
	movzbl	33(%rsp), %r8d
	testq	%rcx, %rcx
	je	.L1807
.L1793:
	movq	%r8, %rdx
	call	*%rbx
	testq	%rax, %rax
	je	.L1808
	movq	%rax, 8(%r12)
	movq	%r12, %rax
	movq	$4, (%r12)
	addq	$328, %rsp
	popq	%rbx
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L1791:
	leaq	.LC74(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L1801:
	xorl	%eax, %eax
	jmp	.L1790
	.p2align 4,,10
	.p2align 3
.L1806:
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
.L1800:
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
.L1807:
	leaq	64(%rsp), %rcx
	movq	%rcx, %rax
	leaq	(%rcx,%r8), %rdx
	testq	%r8, %r8
	je	.L1796
	.p2align 4,,10
	.p2align 3
.L1795:
	movb	$32, (%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jne	.L1795
.L1796:
	movq	%rcx, 40(%rsp)
	jmp	.L1793
.L1808:
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
	je	.L1815
	movl	2272+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L1816
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L1817
	movl	16+hrdbf_app_state(%rip), %eax
	cmpq	%rax, 24+hrdbf_app_state(%rip)
	ja	.L1818
	addq	$40, %rsp
	ret
.L1815:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L1818:
	leaq	.LC79(%rip), %rcx
	call	hrdbf_app_fail
.L1817:
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L1816:
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
	je	.L1841
	movq	$0, 2280(%r12)
	call	*__imp_CloseHandle(%rip)
	movq	2256(%r12), %rcx
	testl	%eax, %eax
	jne	.L1825
	testq	%rcx, %rcx
	je	.L1821
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1821
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
.L1825:
	testq	%rcx, %rcx
	je	.L1824
.L1823:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	jne	.L1839
.L1821:
	addq	$32, %rsp
	movl	$7, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
	.p2align 4,,10
	.p2align 3
.L1841:
	movq	2256(%r12), %rcx
	testq	%rcx, %rcx
	jne	.L1823
.L1824:
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
.L1839:
	movq	$0, 2256(%r12)
	movq	$0, 2264(%r12)
	jmp	.L1824
	.p2align 4
	.globl	hrdbf_file_write_record
	.def	hrdbf_file_write_record;	.scl	2;	.type	32;	.endef
hrdbf_file_write_record:
	movl	2272(%rcx), %eax
	testl	%eax, %eax
	je	.L1846
	cmpq	$0, 2280(%rcx)
	je	.L1846
	cmpb	$0, 40(%rcx)
	je	.L1846
	testq	%rdx, %rdx
	je	.L1847
	movl	16(%rcx), %r8d
	movl	$1, %eax
	cmpq	%rdx, %r8
	jnb	.L1849
	ret
	.p2align 4,,10
	.p2align 3
.L1846:
	movl	$6, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1847:
	movl	$1, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L1849:
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
	je	.L1850
	cmpq	$0, 2280(%rcx)
	je	.L1850
	cmpb	$0, 40(%rcx)
	je	.L1850
	jmp	hrdbf_file_append.part.0
	.p2align 4,,10
	.p2align 3
.L1850:
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
	je	.L1857
	movq	(%rsi), %rdi
	movq	16(%rsi), %rbx
	xorl	%r11d, %r11d
	.p2align 4,,10
	.p2align 3
.L1862:
	movl	%r9d, %r10d
	subl	%r11d, %r10d
	shrl	%r10d
	leal	(%r10,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r10
	testq	%rdx, %rdx
	je	.L1875
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1861
	.p2align 4,,10
	.p2align 3
.L1859:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1875
.L1861:
	movzbl	(%rcx,%rax), %r14d
	cmpb	%r14b, (%r8,%rax)
	je	.L1859
	jnb	.L1875
	leal	1(%r10), %r11d
.L1858:
	cmpl	%r9d, %r11d
	jb	.L1862
	movl	24(%rsi), %r9d
	cmpl	%r11d, %r9d
	jbe	.L1866
	movl	%r11d, %eax
	leaq	(%rbx,%rax,8), %rax
.L1865:
	movl	4(%rax), %r8d
	testq	%rdx, %rdx
	je	.L1867
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1868
	.p2align 4,,10
	.p2align 3
.L1900:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1867
.L1868:
	movzbl	(%rcx,%rax), %r10d
	cmpb	%r10b, (%r8,%rax)
	je	.L1900
.L1866:
	testl	%ebp, %ebp
	je	.L1856
	movl	88(%rsp), %eax
	testl	%eax, %eax
	jne	.L1901
	movl	%r11d, %r9d
.L1856:
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
.L1875:
	movl	%r10d, %r9d
	jmp	.L1858
.L1867:
	movl	88(%rsp), %r8d
	movl	$1, (%r12)
	movl	%r11d, %r9d
	testl	%r8d, %r8d
	je	.L1856
	movl	24(%rsi), %r10d
	cmpl	%r11d, %r10d
	jbe	.L1869
	.p2align 4,,10
	.p2align 3
.L1874:
	movl	%r10d, %r9d
	subl	%r11d, %r9d
	shrl	%r9d
	leal	(%r9,%r11), %eax
	movl	4(%rbx,%rax,8), %r8d
	movq	%rax, %r9
	testq	%rdx, %rdx
	je	.L1870
	xorl	%eax, %eax
	addq	%rdi, %r8
	jmp	.L1873
	.p2align 4,,10
	.p2align 3
.L1871:
	addq	$1, %rax
	cmpq	%rax, %rdx
	je	.L1870
.L1873:
	movzbl	(%rcx,%rax), %esi
	cmpb	%sil, (%r8,%rax)
	je	.L1871
	jb	.L1870
	movl	%r9d, %r10d
.L1872:
	cmpl	%r10d, %r11d
	jb	.L1874
.L1869:
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
.L1870:
	leal	1(%r9), %r11d
	jmp	.L1872
.L1901:
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
.L1857:
	movl	24(%rsi), %r9d
	testl	%r9d, %r9d
	je	.L1856
	movq	16(%rsi), %rbx
	movq	(%rsi), %rdi
	xorl	%r11d, %r11d
	movq	%rbx, %rax
	jmp	.L1865
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
	je	.L1907
	movq	$0, 2280+hrdbf_app_state(%rip)
	call	*__imp_CloseHandle(%rip)
	testl	%eax, %eax
	jne	.L1907
	movq	2256+hrdbf_app_state(%rip), %rcx
	testq	%rcx, %rcx
	je	.L1908
	movl	$7, %esi
	jmp	.L1904
	.p2align 4,,10
	.p2align 3
.L1907:
	movq	2256+hrdbf_app_state(%rip), %rcx
	testq	%rcx, %rcx
	jne	.L1917
.L1905:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	testl	%ebx, %ebx
	jne	.L1910
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.L1917:
	xorl	%esi, %esi
.L1904:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*__imp_VirtualFree(%rip)
	testl	%eax, %eax
	je	.L1908
	movq	$0, 2256+hrdbf_app_state(%rip)
	orl	%esi, %ebx
	movq	$0, 2264+hrdbf_app_state(%rip)
	jmp	.L1905
.L1908:
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
.L1910:
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
	je	.L1919
	cmpb	$0, 40+hrdbf_app_state(%rip)
	jne	.L1965
.L1919:
	leaq	-1(%rdx), %rax
	cmpq	$258, %rax
	ja	.L1966
	xorl	%ebx, %ebx
	jmp	.L1920
	.p2align 4,,10
	.p2align 3
.L1938:
	movq	%rsi, %rbx
.L1920:
	movzbl	(%rdi,%rbx), %eax
	testb	%al, %al
	je	.L1967
	leaq	1(%rbx), %rsi
	movb	%al, 32(%rsp,%rbx)
	leaq	32(%rsp), %r12
	cmpq	%rsi, %rdx
	jne	.L1938
	movb	$0, 32(%rsp,%rdx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L1968
	movl	$0, hrdbf_app_found_flag(%rip)
	xorl	%eax, %eax
	testq	%rbp, %rbp
	movl	$0, hrdbf_app_order_active(%rip)
	setne	%al
	xorl	%r8d, %r8d
	movl	%eax, hrdbf_app_cdx(%rip)
	xorl	%eax, %eax
	movq	$0, hrdbf_app_pos(%rip)
	jmp	.L1925
	.p2align 4,,10
	.p2align 3
.L1923:
	cmpq	%rcx, %rbx
	je	.L1969
.L1925:
	movzbl	(%rdi,%rax), %edx
	movq	%rax, %rcx
	addq	$1, %rax
	cmpb	$47, %dl
	je	.L1948
	cmpb	$92, %dl
	jne	.L1923
.L1948:
	movq	%rax, %r8
	cmpq	%rcx, %rbx
	jne	.L1925
.L1969:
	cmpq	%rsi, %r8
	jnb	.L1926
	movq	%r8, %rax
	jmp	.L1928
	.p2align 4,,10
	.p2align 3
.L1939:
	movq	%rdx, %rax
.L1928:
	cmpb	$46, (%rdi,%rax)
	leaq	1(%rax), %rdx
	cmove	%rax, %rsi
	cmpq	%rbx, %rax
	jne	.L1939
.L1926:
	subq	%r8, %rsi
	leaq	(%rdi,%r8), %r10
	movl	$0, %edx
	movq	%rsi, hrdbf_app_baselen(%rip)
	leaq	hrdbf_app_basename(%rip), %r9
	je	.L1933
	.p2align 4,,10
	.p2align 3
.L1929:
	movzbl	(%r10,%rdx), %eax
	leal	-97(%rax), %r8d
	leal	-32(%rax), %ecx
	cmpb	$26, %r8b
	cmovb	%ecx, %eax
	movb	%al, (%r9,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.L1929
.L1933:
	xorl	%ebx, %ebx
	leaq	hrdbf_app_state(%rip), %rcx
	cmpq	$0, 384(%rsp)
	movb	$0, 2288+hrdbf_app_state(%rip)
	setne	%bl
	movb	$0, fsink(%rip)
	call	hrdbf_file_close
	testl	%eax, %eax
	je	.L1970
.L1930:
	leaq	2288+hrdbf_app_state(%rip), %r12
	cmpb	$0, 2288+hrdbf_app_state(%rip)
	leaq	-198(%r12), %rdx
	cmove	%rdx, %r12
	cmpb	$0, (%r12)
	jne	.L1936
	leaq	.LC86(%rip), %r12
	cmpl	$7, %eax
	je	.L1936
	leaq	.LC82(%rip), %r12
	cmpl	$8, %eax
	je	.L1936
	leaq	.LC87(%rip), %r12
	cmpl	$4, %eax
	je	.L1936
	leaq	.LC83(%rip), %r12
	cmpl	$2, %eax
	je	.L1936
	leaq	.LC84(%rip), %r12
	cmpl	$3, %eax
	je	.L1936
	cmpl	$5, %eax
	leaq	.LC85(%rip), %r12
	leaq	.LC88(%rip), %rax
	cmovne	%rax, %r12
.L1936:
	leaq	.LC93(%rip), %rcx
	call	hrdbf_app_write
	movq	%r12, %rcx
	call	hrdbf_app_write
	leaq	.LC80(%rip), %rcx
	call	hrdbf_app_write
	call	hrdbf_app_exit
	.p2align 4,,10
	.p2align 3
.L1970:
	movl	%ebx, %r8d
	movq	%r12, %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_open.part.0
	testl	%eax, %eax
	jne	.L1930
	addq	$304, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	ret
.L1967:
	leaq	.LC91(%rip), %rcx
	call	hrdbf_app_fail
.L1966:
	leaq	.LC90(%rip), %rcx
	call	hrdbf_app_fail
.L1965:
	leaq	.LC89(%rip), %rcx
	call	hrdbf_app_fail
.L1968:
	leaq	.LC92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_top
	.def	hrdbfw_app_top;	.scl	2;	.type	32;	.endef
hrdbfw_app_top:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1981
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1973
	movl	hrdbf_app_order_active(%rip), %edx
	testl	%edx, %edx
	jne	.L1974
.L1973:
	movl	16+hrdbf_app_state(%rip), %eax
	movq	$1, 24+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1974:
	movl	24+hrdbf_app_order(%rip), %edx
	movq	$0, hrdbf_app_pos(%rip)
	movq	%rdx, %rax
	testq	%rdx, %rdx
	je	.L1976
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx), %ecx
.L1977:
	testq	%rdx, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	sete	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1976:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
	jmp	.L1977
.L1981:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bottom
	.def	hrdbfw_app_bottom;	.scl	2;	.type	32;	.endef
hrdbfw_app_bottom:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L1993
	cmpq	$0, hrdbf_app_order(%rip)
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1984
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1984
	movl	24+hrdbf_app_order(%rip), %r8d
	movq	%r8, %rax
	testl	%r8d, %r8d
	jne	.L1994
	movq	$0, hrdbf_app_pos(%rip)
	xorl	%edx, %edx
.L1988:
	movl	16+hrdbf_app_state(%rip), %ecx
	addq	$1, %rcx
.L1989:
	cmpq	%r8, %rdx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	setnb	39+hrdbf_app_state(%rip)
	testl	%eax, %eax
	sete	38+hrdbf_app_state(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L1994:
	leal	-1(%r8), %edx
	movq	%rdx, hrdbf_app_pos(%rip)
	cmpq	%r8, %rdx
	jnb	.L1988
	movq	16+hrdbf_app_order(%rip), %rcx
	movl	(%rcx,%rdx,8), %ecx
	jmp	.L1989
	.p2align 4,,10
	.p2align 3
.L1984:
	movl	16+hrdbf_app_state(%rip), %eax
	movl	$1, %edx
	testl	%eax, %eax
	cmove	%rdx, %rax
	movq	%rax, 24+hrdbf_app_state(%rip)
	sete	%al
	movb	%al, 39+hrdbf_app_state(%rip)
	movb	%al, 38+hrdbf_app_state(%rip)
	ret
.L1993:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_skip
	.def	hrdbfw_app_skip;	.scl	2;	.type	32;	.endef
hrdbfw_app_skip:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2013
	cmpq	$0, hrdbf_app_order(%rip)
	movq	%rcx, %rdx
	movl	$0, hrdbf_app_found_flag(%rip)
	je	.L1997
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L1997
	testq	%rcx, %rcx
	je	.L1995
	movb	$0, 38+hrdbf_app_state(%rip)
	movl	24+hrdbf_app_order(%rip), %eax
	movq	hrdbf_app_pos(%rip), %rcx
	jle	.L2000
	movq	%rax, %r8
	subq	%rcx, %r8
	cmpq	%rdx, %r8
	jb	.L2006
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	setnb	%cl
.L2001:
	movq	%rdx, hrdbf_app_pos(%rip)
.L2002:
	cmpq	%rax, %rdx
	jnb	.L2004
	movq	16+hrdbf_app_order(%rip), %rax
	movl	(%rax,%rdx,8), %eax
.L2005:
	movq	%rax, 24+hrdbf_app_state(%rip)
	movb	%cl, 39+hrdbf_app_state(%rip)
.L1995:
	ret
	.p2align 4,,10
	.p2align 3
.L1997:
	leaq	hrdbf_app_state(%rip), %rcx
	jmp	hrdbf_skip
	.p2align 4,,10
	.p2align 3
.L2006:
	movq	%rax, %rdx
	movl	$1, %ecx
	jmp	.L2001
	.p2align 4,,10
	.p2align 3
.L2004:
	movl	16+hrdbf_app_state(%rip), %eax
	addq	$1, %rax
	jmp	.L2005
	.p2align 4,,10
	.p2align 3
.L2000:
	movq	%rdx, %r8
	negq	%r8
	cmpq	%rcx, %r8
	jbe	.L2003
	testq	%rax, %rax
	movb	$1, 38+hrdbf_app_state(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	sete	%cl
	xorl	%edx, %edx
	jmp	.L2002
	.p2align 4,,10
	.p2align 3
.L2003:
	addq	%rcx, %rdx
	cmpq	%rax, %rdx
	movq	%rdx, hrdbf_app_pos(%rip)
	setnb	%cl
	jmp	.L2002
.L2013:
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
	je	.L2088
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2089
	leaq	-1(%rdx), %rax
	movq	%rdx, %r9
	cmpq	$254, %rax
	ja	.L2090
	movq	%rcx, %r8
	xorl	%esi, %esi
	xorl	%edx, %edx
	jmp	.L2017
	.p2align 4,,10
	.p2align 3
.L2019:
	cmpq	%rcx, %r9
	je	.L2091
.L2055:
	movq	%rcx, %rdx
.L2017:
	movzbl	(%r8,%rdx), %eax
	testb	%al, %al
	je	.L2092
	movb	%al, 64(%rsp,%rdx)
	leaq	64(%rsp), %r12
	leaq	1(%rdx), %rcx
	cmpb	$47, %al
	je	.L2059
	cmpb	$92, %al
	jne	.L2019
.L2059:
	movq	%rcx, %rsi
	cmpq	%rcx, %r9
	jne	.L2055
.L2091:
	movl	hrdbf_app_cdx(%rip), %ebx
	cmpq	%rcx, %rsi
	jnb	.L2021
	movq	%rcx, %r9
	movq	%rsi, %rax
	xorl	%r10d, %r10d
	movl	$1, %edi
	jmp	.L2023
	.p2align 4,,10
	.p2align 3
.L2056:
	movq	%r11, %rax
.L2023:
	cmpb	$46, (%r8,%rax)
	leaq	1(%rax), %r11
	cmove	%rax, %r9
	cmove	%edi, %r10d
	cmpq	%rdx, %rax
	jne	.L2056
	testl	%ebx, %ebx
	je	.L2027
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %r9
	cmpq	%rdi, %r9
	je	.L2053
.L2028:
	testl	%r10d, %r10d
	je	.L2051
.L2052:
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2033
	testl	%ebx, %ebx
	je	.L2035
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
	jne	.L2047
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	%ebx, %esi
	movl	$512, %r8d
	leaq	0(,%rcx,8), %rbp
.L2046:
	cmpq	$67108864, %rbp
	ja	.L2087
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
	je	.L2087
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
	je	.L2040
	cmpl	$5, %eax
	je	.L2041
	.p2align 4,,10
	.p2align 3
.L2087:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2033
.L2042:
	leaq	.LC95(%rip), %rcx
	jmp	.L2043
	.p2align 4,,10
	.p2align 3
.L2027:
	testl	%r10d, %r10d
	je	.L2026
	movb	$0, 64(%rsp,%rcx)
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2033
.L2035:
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
	jne	.L2047
	movl	16+hrdbf_app_state(%rip), %ecx
	movq	48+hrdbf_app_order(%rip), %rax
	movl	$1024, %r8d
	leaq	0(,%rcx,8), %rbp
	jmp	.L2046
	.p2align 4,,10
	.p2align 3
.L2026:
	movb	$46, 64(%rsp,%rcx)
	xorl	%ebx, %ebx
	leaq	3(%rdx), %rcx
	movl	$116, %eax
	movb	$110, 66(%rsp,%rdx)
.L2050:
	movb	%al, 64(%rsp,%rcx)
	leaq	5(%rdx), %rcx
	movb	$120, 68(%rsp,%rdx)
	jmp	.L2052
.L2021:
	testl	%ebx, %ebx
	je	.L2026
	movq	%rcx, %rax
	movq	hrdbf_app_baselen(%rip), %rdi
	subq	%rsi, %rax
	cmpq	%rdi, %rax
	je	.L2093
	.p2align 4,,10
	.p2align 3
.L2051:
	movb	$46, 64(%rsp,%rcx)
	movl	$100, %eax
	leaq	3(%rdx), %rcx
	movb	$99, 66(%rsp,%rdx)
	jmp	.L2050
	.p2align 4,,10
	.p2align 3
.L2047:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	cmove	%esi, %eax
.L2033:
	cmpl	$0, hrdbf_app_cdx(%rip)
	je	.L2042
	cmpl	$3, %eax
	je	.L2044
	jmp	.L2042
	.p2align 4,,10
	.p2align 3
.L2040:
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
.L2093:
	xorl	%r10d, %r10d
.L2053:
	testq	%rdi, %rdi
	je	.L2029
	movl	$1, %r11d
	xorl	%r9d, %r9d
	leaq	(%r8,%rsi), %r14
	xorl	%ebp, %ebp
	leaq	hrdbf_app_basename(%rip), %r13
	.p2align 4,,10
	.p2align 3
.L2032:
	movzbl	(%r14,%r9), %eax
	leal	-97(%rax), %esi
	leal	-32(%rax), %r8d
	cmpb	$26, %sil
	cmovb	%r8d, %eax
	cmpb	%al, 0(%r13,%r9)
	cmovne	%ebp, %r11d
	addq	$1, %r9
	cmpq	%rdi, %r9
	jne	.L2032
	testl	%r11d, %r11d
	je	.L2028
.L2029:
	leaq	.LC99(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2041:
	call	hrntx_file_close.constprop.0
	testl	%eax, %eax
	jne	.L2033
	movl	hrdbf_app_cdx(%rip), %eax
	testl	%eax, %eax
	je	.L2042
.L2044:
	leaq	.LC94(%rip), %rcx
.L2043:
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2092:
	leaq	.LC98(%rip), %rcx
	call	hrdbf_app_fail
.L2089:
	leaq	.LC96(%rip), %rcx
	call	hrdbf_app_fail
.L2088:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L2090:
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
	je	.L2120
	movq	64+hrdbf_app_order(%rip), %rcx
	movq	$0, hrdbf_app_order(%rip)
	movq	$0, 8+hrdbf_app_order(%rip)
	movq	$0, 16+hrdbf_app_order(%rip)
	movq	$0, 24+hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	je	.L2121
	movq	$0, 64+hrdbf_app_order(%rip)
	call	*__imp_CloseHandle(%rip)
	movq	32+hrdbf_app_order(%rip), %rcx
	testl	%eax, %eax
	jne	.L2100
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.L2122
.L2097:
	xorl	%edx, %edx
	movq	__imp_VirtualFree(%rip), %rbx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.L2101
	movq	40+hrdbf_app_order(%rip), %rcx
	movl	$7, %esi
	testq	%rcx, %rcx
	je	.L2102
.L2098:
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	je	.L2102
.L2123:
	movq	$0, 40+hrdbf_app_order(%rip)
	movq	$0, 56+hrdbf_app_order(%rip)
.L2103:
	testl	%esi, %esi
	jne	.L2102
.L2099:
	movl	$0, hrdbf_app_order_active(%rip)
	movq	$0, hrdbf_app_pos(%rip)
	addq	$40, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.p2align 4,,10
	.p2align 3
.L2100:
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.L2097
.L2118:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	__imp_VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	je	.L2099
	xorl	%edx, %edx
	movl	$32768, %r8d
	call	*%rbx
	testl	%eax, %eax
	jne	.L2123
	.p2align 4,,10
	.p2align 3
.L2102:
	leaq	.LC92(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2121:
	movq	32+hrdbf_app_order(%rip), %rcx
	xorl	%esi, %esi
	testq	%rcx, %rcx
	jne	.L2097
	jmp	.L2118
	.p2align 4,,10
	.p2align 3
.L2101:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	$0, 32+hrdbf_app_order(%rip)
	movq	$0, 48+hrdbf_app_order(%rip)
	testq	%rcx, %rcx
	jne	.L2098
	jmp	.L2103
	.p2align 4,,10
	.p2align 3
.L2122:
	movq	40+hrdbf_app_order(%rip), %rcx
	movq	__imp_VirtualFree(%rip), %rbx
	testq	%rcx, %rcx
	jne	.L2098
	jmp	.L2102
.L2120:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_found
	.def	hrdbfw_app_found;	.scl	2;	.type	32;	.endef
hrdbfw_app_found:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2129
	movl	hrdbf_app_found_flag(%rip), %eax
	ret
.L2129:
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
	je	.L2137
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2132
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2132
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
	jb	.L2138
	movl	16+hrdbf_app_state(%rip), %r9d
	addq	$1, %r9
.L2135:
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
.L2138:
	movq	16+hrdbf_app_order(%rip), %r9
	movl	(%r9,%rax,8), %r9d
	jmp	.L2135
.L2132:
	leaq	.LC100(%rip), %rcx
	call	hrdbf_app_fail
.L2137:
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
	pushq	%r12
	pushq	%rbx
	subq	$344, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2177
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2141
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	je	.L2141
	movq	%rcx, %rax
	movq	%rdx, %rcx
	movq	%r8, %rbx
	movzbl	%al, %edx
	leal	-2(%rdx), %r8d
	andl	$-3, %r8d
	je	.L2178
	testl	%edx, %edx
	je	.L2156
	cmpl	$9, %edx
	je	.L2156
	cmpl	$5, %edx
	je	.L2179
	cmpl	$12, %edx
	je	.L2180
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
.L2178:
	testq	%rcx, %rcx
	je	.L2181
	movq	-8(%rcx), %rdx
	addq	$344, %rsp
	movq	%rbx, %r8
	popq	%rbx
	popq	%r12
	jmp	hrdbfw_app_seek
	.p2align 4,,10
	.p2align 3
.L2180:
	movzbl	%ah, %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rcx, %xmm0
	leal	-1(%rax), %edx
	testl	%eax, %eax
	je	.L2154
	movsd	.LC0(%rip), %xmm1
	.p2align 4,,10
	.p2align 3
.L2155:
	divsd	%xmm1, %xmm0
	subl	$1, %edx
	jnb	.L2155
.L2154:
	comisd	.LC102(%rip), %xmm0
	movabsq	$9223372036854775807, %rcx
	ja	.L2156
.L2176:
	movsd	.LC103(%rip), %xmm1
	addq	$1, %rcx
	comisd	%xmm0, %xmm1
	jbe	.L2182
.L2156:
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
.L2179:
	testq	%rax, %rax
	js	.L2183
.L2149:
	movq	%rcx, %xmm0
	comisd	.LC102(%rip), %xmm0
	movabsq	$9223372036854775807, %rcx
	ja	.L2156
	jmp	.L2176
	.p2align 4,,10
	.p2align 3
.L2182:
	pxor	%xmm1, %xmm1
	comisd	%xmm0, %xmm1
	ja	.L2184
	addsd	.LC104(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.L2156
	.p2align 4,,10
	.p2align 3
.L2183:
	movq	(%rcx), %rcx
	jmp	.L2149
	.p2align 4,,10
	.p2align 3
.L2184:
	subsd	.LC104(%rip), %xmm0
	cvttsd2siq	%xmm0, %rcx
	jmp	.L2156
.L2141:
	leaq	.LC100(%rip), %rcx
	call	hrdbf_app_fail
.L2177:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L2181:
	leaq	.LC101(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_recno
	.def	hrdbfw_app_recno;	.scl	2;	.type	32;	.endef
hrdbfw_app_recno:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2190
	movq	24+hrdbf_app_state(%rip), %rax
	ret
.L2190:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_lastrec
	.def	hrdbfw_app_lastrec;	.scl	2;	.type	32;	.endef
hrdbfw_app_lastrec:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2196
	movl	16+hrdbf_app_state(%rip), %eax
	ret
.L2196:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_fcount
	.def	hrdbfw_app_fcount;	.scl	2;	.type	32;	.endef
hrdbfw_app_fcount:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2202
	movzwl	36+hrdbf_app_state(%rip), %eax
	ret
.L2202:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_goto
	.def	hrdbfw_app_goto;	.scl	2;	.type	32;	.endef
hrdbfw_app_goto:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2217
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	16+hrdbf_app_state(%rip), %eax
	testq	%rcx, %rcx
	jle	.L2205
	cmpq	%rax, %rcx
	jbe	.L2206
.L2205:
	addq	$1, %rax
	movl	$257, %ecx
	movq	%rax, 24+hrdbf_app_state(%rip)
	movw	%cx, 38+hrdbf_app_state(%rip)
.L2207:
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2203
	movl	hrdbf_app_order_active(%rip), %eax
	testl	%eax, %eax
	jne	.L2218
.L2203:
	ret
	.p2align 4,,10
	.p2align 3
.L2206:
	xorl	%edx, %edx
	movq	%rcx, 24+hrdbf_app_state(%rip)
	movw	%dx, 38+hrdbf_app_state(%rip)
	jmp	.L2207
	.p2align 4,,10
	.p2align 3
.L2218:
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r8
	testl	%ecx, %ecx
	je	.L2212
	movq	16+hrdbf_app_order(%rip), %r9
	xorl	%eax, %eax
	jmp	.L2211
	.p2align 4,,10
	.p2align 3
.L2210:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2209
.L2211:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.L2210
	movq	%rax, hrdbf_app_pos(%rip)
	ret
.L2212:
	xorl	%ecx, %ecx
.L2209:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2217:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_ordselect
	.def	hrdbfw_app_ordselect;	.scl	2;	.type	32;	.endef
hrdbfw_app_ordselect:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2232
	cmpq	$1, %rcx
	jne	.L2221
	cmpq	$0, hrdbf_app_order(%rip)
	je	.L2221
	movl	24+hrdbf_app_order(%rip), %ecx
	movq	24+hrdbf_app_state(%rip), %r8
	movl	$1, hrdbf_app_order_active(%rip)
	testl	%ecx, %ecx
	je	.L2227
	movq	16+hrdbf_app_order(%rip), %r9
	xorl	%eax, %eax
	jmp	.L2226
	.p2align 4,,10
	.p2align 3
.L2225:
	addq	$1, %rax
	cmpq	%rax, %rcx
	je	.L2224
.L2226:
	movl	(%r9,%rax,8), %edx
	cmpq	%rdx, %r8
	jne	.L2225
	movq	%rax, hrdbf_app_pos(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.L2221:
	movl	$0, hrdbf_app_order_active(%rip)
	ret
.L2227:
	xorl	%ecx, %ecx
.L2224:
	movq	%rcx, hrdbf_app_pos(%rip)
	ret
.L2232:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_bof
	.def	hrdbfw_app_bof;	.scl	2;	.type	32;	.endef
hrdbfw_app_bof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2238
	movzbl	38+hrdbf_app_state(%rip), %eax
	ret
.L2238:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_eof
	.def	hrdbfw_app_eof;	.scl	2;	.type	32;	.endef
hrdbfw_app_eof:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2244
	movzbl	39+hrdbf_app_state(%rip), %eax
	ret
.L2244:
	subq	$40, %rsp
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4
	.globl	hrdbfw_app_deleted
	.def	hrdbfw_app_deleted;	.scl	2;	.type	32;	.endef
hrdbfw_app_deleted:
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2252
	movq	24+hrdbf_app_state(%rip), %rax
	movl	16+hrdbf_app_state(%rip), %edx
	xorl	%r8d, %r8d
	cmpq	%rdx, %rax
	ja	.L2245
	movzwl	34+hrdbf_app_state(%rip), %edx
	subq	$1, %rax
	xorl	%r8d, %r8d
	imulq	%rdx, %rax
	movzwl	32+hrdbf_app_state(%rip), %edx
	addq	hrdbf_app_state(%rip), %rax
	cmpb	$42, (%rax,%rdx)
	sete	%r8b
.L2245:
	movq	%r8, %rax
	ret
.L2252:
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
	je	.L2259
	movq	%rcx, %r12
	testq	%rdx, %rdx
	jle	.L2255
	movzwl	36+hrdbf_app_state(%rip), %eax
	cmpq	%rax, %rdx
	jle	.L2256
.L2255:
	movq	$1, (%r12)
	movq	%r12, %rax
	movq	$0, 8(%r12)
	addq	$32, %rsp
	popq	%r12
	ret
	.p2align 4,,10
	.p2align 3
.L2256:
	call	hrdbfw_app_get_ord.part.0
	addq	$32, %rsp
	movq	%r12, %rax
	popq	%r12
	ret
.L2259:
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
	je	.L2261
	movzwl	36+hrdbf_app_state(%rip), %esi
	movq	%rdx, %r12
	movq	%rsi, %rdi
	testl	%esi, %esi
	je	.L2263
	movq	%rcx, %r13
	movq	%r9, %rbp
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.L2275:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2264:
	cmpb	$0, (%r10,%rax)
	je	.L2265
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2264
.L2265:
	cmpq	%r8, %rax
	je	.L2285
.L2267:
	addl	$1, %ebx
	addq	$16, %r10
	cmpl	%ebx, %esi
	jne	.L2275
.L2263:
	movq	%r8, %rdx
	movq	%r12, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2285:
	testq	%r8, %r8
	je	.L2268
	xorl	%ecx, %ecx
	jmp	.L2272
	.p2align 4,,10
	.p2align 3
.L2286:
	addq	$1, %rcx
	cmpq	%rcx, %r8
	je	.L2268
.L2272:
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
	je	.L2286
	cmpq	%rcx, %r8
	jne	.L2267
	.p2align 4,,10
	.p2align 3
.L2268:
	leal	1(%rbx), %edx
	cmpq	%rdi, %rdx
	jle	.L2273
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
.L2273:
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
.L2261:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC105:
	.ascii "hbc: DBF field ordinal outside the open area\12\0"
	.align 8
.LC106:
	.ascii "hbc: DBF field write type mismatch\12\0"
	.align 8
.LC107:
	.ascii "hbc: DBF field write encoding rejected\12\0"
	.align 8
.LC108:
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
	jle	.L2288
	movzwl	36+hrdbf_app_state(%rip), %eax
	leaq	hrdbf_app_state(%rip), %r9
	cmpq	%rbx, %rax
	jl	.L2288
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
	je	.L2290
	ja	.L2291
	cmpb	$67, %al
	je	.L2292
	cmpb	$68, %al
	jne	.L2294
	cmpl	$11, %r8d
	je	.L2349
	cmpl	$1, %r8d
	jne	.L2294
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2303
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2314
	.p2align 4,,10
	.p2align 3
.L2350:
	addq	$1, %rax
.L2314:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2350
.L2299:
	movq	24+hrdbf_app_state(%rip), %rdx
.L2303:
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_write_record
	testl	%eax, %eax
	jne	.L2351
	addq	$32, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	ret
	.p2align 4,,10
	.p2align 3
.L2291:
	cmpb	$78, %al
	jne	.L2294
	cmpl	$12, %r8d
	je	.L2352
	testl	%r8d, %r8d
	je	.L2322
	cmpl	$9, %r8d
	je	.L2322
	cmpl	$5, %r8d
	je	.L2353
	cmpl	$1, %r8d
	jne	.L2294
	addq	$2, %r10
	salq	$4, %r10
	addq	%r10, %r9
	movzbl	22(%r9), %r8d
	movzwl	24(%r9), %eax
	testl	%r8d, %r8d
	je	.L2303
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2312
	.p2align 4,,10
	.p2align 3
.L2354:
	addq	$1, %rax
.L2312:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2354
	jmp	.L2299
	.p2align 4,,10
	.p2align 3
.L2292:
	leal	-2(%r8), %eax
	andl	$-3, %eax
	je	.L2355
	cmpl	$1, %r8d
	jne	.L2294
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2303
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2304
	.p2align 4,,10
	.p2align 3
.L2356:
	addq	$1, %rax
.L2304:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rax, %rdx
	jne	.L2356
	jmp	.L2299
	.p2align 4,,10
	.p2align 3
.L2290:
	cmpl	$3, %r8d
	je	.L2357
	cmpl	$1, %r8d
	jne	.L2294
	movzbl	22(%rbx), %r8d
	movzwl	24(%rbx), %eax
	testl	%r8d, %r8d
	je	.L2303
	addq	%rax, %rcx
	leal	-1(%r8), %edx
	leaq	1(%rcx), %rax
	addq	%rax, %rdx
	jmp	.L2317
	.p2align 4,,10
	.p2align 3
.L2358:
	addq	$1, %rax
.L2317:
	movb	$32, (%rcx)
	movq	%rax, %rcx
	cmpq	%rdx, %rax
	jne	.L2358
	jmp	.L2299
	.p2align 4,,10
	.p2align 3
.L2352:
	movl	%edi, %eax
	movq	%rsi, %r8
	movq	%r11, %rdx
	movzbl	%ah, %eax
	movl	%eax, %r9d
	call	hrdbf_write_number_scaled.part.0
.L2306:
	cmpl	$3, %eax
	je	.L2294
	testl	%eax, %eax
	je	.L2299
	leaq	.LC107(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2357:
	cmpq	$1, %rsi
	movzwl	24(%rbx), %edx
	sbbl	%eax, %eax
	andl	$-14, %eax
	addl	$84, %eax
	movb	%al, (%rcx,%rdx)
	movq	24+hrdbf_app_state(%rip), %rdx
	jmp	.L2303
	.p2align 4,,10
	.p2align 3
.L2355:
	movzwl	24(%rbx), %eax
	movzbl	22(%rbx), %edx
	addq	%rax, %rcx
	cmpq	%rdx, -8(%rsi)
	movq	%rdx, %rax
	cmovbe	-8(%rsi), %rax
	testq	%rax, %rax
	je	.L2297
	movq	%rcx, %r8
	leaq	(%rsi,%rax), %r11
	subq	%rsi, %r8
	.p2align 4,,10
	.p2align 3
.L2298:
	movzbl	(%rsi), %edx
	movb	%dl, (%r8,%rsi)
	addq	$1, %rsi
	cmpq	%r11, %rsi
	jne	.L2298
	movq	%r10, %rdx
	salq	$4, %rdx
	movzbl	54(%rdx,%r9), %edx
.L2297:
	cmpq	%rax, %rdx
	jbe	.L2299
	leaq	2(%r10), %rdx
	salq	$4, %rdx
	addq	%rdx, %r9
	.p2align 4,,10
	.p2align 3
.L2300:
	movb	$32, (%rcx,%rax)
	movzbl	22(%r9), %edx
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.L2300
	jmp	.L2299
	.p2align 4,,10
	.p2align 3
.L2349:
	movl	%esi, %r8d
	movq	%r11, %rdx
	call	hrdbf_write_date
	jmp	.L2306
.L2294:
	leaq	.LC106(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2322:
	xorl	%r9d, %r9d
	movq	%rsi, %r8
	movq	%r11, %rdx
	call	hrdbf_write_number_scaled.part.0
	jmp	.L2306
	.p2align 4,,10
	.p2align 3
.L2353:
	testq	%rdi, %rdi
	jns	.L2310
	movq	(%rsi), %rsi
.L2310:
	movq	%rsi, %xmm2
	movq	%r11, %rdx
	call	hrdbf_write_number_double.part.0
	jmp	.L2306
.L2288:
	leaq	.LC105(%rip), %rcx
	call	hrdbf_app_fail
.L2351:
	leaq	.LC108(%rip), %rcx
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
	je	.L2360
	leaq	42+hrdbf_app_state(%rip), %r10
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L2370:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L2361:
	cmpb	$0, (%r10,%rax)
	je	.L2362
	addq	$1, %rax
	cmpq	$11, %rax
	jne	.L2361
.L2362:
	cmpq	%r12, %rax
	je	.L2383
.L2364:
	addl	$1, %r8d
	addq	$16, %r10
	cmpl	%ebx, %r8d
	jne	.L2370
.L2360:
	movq	%r12, %rdx
	movq	%r13, %rcx
	call	hrdbfw_app_field_missing
	.p2align 4,,10
	.p2align 3
.L2383:
	testq	%r12, %r12
	je	.L2365
	xorl	%ecx, %ecx
	jmp	.L2369
	.p2align 4,,10
	.p2align 3
.L2384:
	addq	$1, %rcx
	cmpq	%rcx, %r12
	je	.L2365
.L2369:
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
	je	.L2384
	cmpq	%rcx, %r12
	jne	.L2364
.L2365:
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
.LC109:
	.ascii "hbc: DBF append failed\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_append
	.def	hrdbfw_app_append;	.scl	2;	.type	32;	.endef
hrdbfw_app_append:
	subq	$56, %rsp
	cmpb	$0, 40+hrdbf_app_state(%rip)
	je	.L2393
	movl	2272+hrdbf_app_state(%rip), %eax
	testl	%eax, %eax
	je	.L2394
	cmpq	$0, hrdbf_app_order(%rip)
	jne	.L2395
	movl	16+hrdbf_app_state(%rip), %eax
	cmpq	%rax, 24+hrdbf_app_state(%rip)
	ja	.L2396
	cmpq	$0, 2280+hrdbf_app_state(%rip)
	je	.L2391
	leaq	44(%rsp), %rdx
	leaq	hrdbf_app_state(%rip), %rcx
	call	hrdbf_file_append.part.0
	testl	%eax, %eax
	jne	.L2391
	movl	$0, hrdbf_app_found_flag(%rip)
	movl	44(%rsp), %eax
	addq	$56, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.L2391:
	leaq	.LC109(%rip), %rcx
	call	hrdbf_app_fail
.L2393:
	leaq	.LC76(%rip), %rcx
	call	hrdbf_app_fail
.L2396:
	leaq	.LC79(%rip), %rcx
	call	hrdbf_app_fail
.L2395:
	leaq	.LC78(%rip), %rcx
	call	hrdbf_app_fail
.L2394:
	leaq	.LC77(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC110:
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
	jne	.L2400
	movq	56(%rsp), %rax
	leave
	ret
.L2400:
	leaq	.LC110(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC111:
	.ascii "hbc: DBF decimal numeric cannot enter I64 operation\12\0"
	.align 8
.LC112:
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
	jne	.L2402
	movzbl	%r11b, %eax
	cmpb	$12, %r11b
	je	.L2418
	testl	%eax, %eax
	je	.L2410
	cmpl	$9, %eax
	jne	.L2406
.L2410:
	movq	%r12, %rax
	movq	-8(%rbp), %r12
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2418:
	testl	$65280, %r11d
	je	.L2410
.L2405:
	leaq	.LC111(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2402:
	cmpl	$2, %eax
	je	.L2405
.L2406:
	leaq	.LC112(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC113:
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
	jne	.L2422
	movslq	76(%rsp), %rax
	leave
	ret
.L2422:
	leaq	.LC113(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC114:
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
	jne	.L2424
	cmpb	$11, %r8b
	je	.L2431
.L2424:
	leaq	32(%rsp), %rdx
	leaq	48(%rsp), %rcx
	movq	%r11, 32(%rsp)
	leaq	72(%rsp), %r8
	movq	%rbx, 40(%rsp)
	call	hrv_compare
	testl	%eax, %eax
	jne	.L2432
	movq	72(%rsp), %rax
	leaq	-24(%rbp), %rsp
	popq	%rbx
	popq	%rsi
	popq	%r12
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.L2431:
	leaq	48(%rsp), %r12
	movq	%r12, %rcx
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2426
	movq	%r12, %rcx
	movq	%r11, 48(%rsp)
	movq	%rbx, 56(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2426
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
.L2432:
	leaq	.LC113(%rip), %rcx
	call	hrdbf_app_fail
.L2426:
	leaq	.LC114(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC115:
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
	jne	.L2434
	movq	-8(%rdx), %rdx
	testq	%rdx, %rdx
	je	.L2445
	movabsq	$4294977024, %rcx
	addq	%r11, %rdx
	jmp	.L2436
	.p2align 4,,10
	.p2align 3
.L2453:
	btq	%rax, %rcx
	jnc	.L2449
	addq	$1, %r11
	cmpq	%r11, %rdx
	je	.L2445
.L2436:
	movzbl	(%r11), %eax
	cmpb	$32, %al
	jbe	.L2453
.L2449:
	xorl	%eax, %eax
.L2433:
	movq	-8(%rbp), %rbx
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2434:
	cmpl	$8, %ebx
	je	.L2454
	cmpl	$5, %ebx
	je	.L2455
	cmpl	$7, %ebx
	je	.L2449
	movq	%rcx, 32(%rsp)
	leaq	32(%rsp), %rcx
	movq	%rdx, 40(%rsp)
	call	hrv_validate
	testl	%eax, %eax
	jne	.L2441
	cmpl	$12, %ebx
	ja	.L2441
	movl	$1, %eax
	movl	%ebx, %ecx
	salq	%cl, %rax
	testl	$6665, %eax
	jne	.L2442
	testb	$2, %al
	jne	.L2445
.L2441:
	leaq	.LC115(%rip), %rcx
	call	hrdbf_app_fail
	.p2align 4,,10
	.p2align 3
.L2445:
	movq	-8(%rbp), %rbx
	movl	$1, %eax
	leave
	ret
	.p2align 4,,10
	.p2align 3
.L2454:
	movl	$1, %eax
	testq	%rdx, %rdx
	je	.L2433
	xorl	%eax, %eax
	cmpq	$0, -8(%rdx)
	sete	%al
	jmp	.L2433
	.p2align 4,,10
	.p2align 3
.L2455:
	testq	%rcx, %rcx
	js	.L2456
.L2440:
	xorl	%eax, %eax
	movq	%r11, %xmm0
	movl	$0, %edx
	ucomisd	.LC65(%rip), %xmm0
	setnp	%al
	cmovne	%rdx, %rax
	jmp	.L2433
.L2456:
	movq	(%rdx), %r11
	jmp	.L2440
.L2442:
	xorl	%eax, %eax
	testq	%r11, %r11
	sete	%al
	jmp	.L2433
	.section .rdata,"dr"
	.align 8
.LC116:
	.ascii "hbc: DBF arithmetic division by zero\12\0"
	.align 8
.LC117:
	.ascii "hbc: DBF arithmetic on a NIL or non-numeric operand\12\0"
.LC118:
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
	je	.L2462
	cmpl	$1, %eax
	je	.L2463
	testl	%eax, %eax
	jne	.L2464
	movdqu	64(%rsp), %xmm0
	movq	%r12, %rax
	movups	%xmm0, (%r12)
	movq	-8(%rbp), %r12
	leave
	ret
.L2462:
	leaq	.LC116(%rip), %rcx
	call	hrdbf_app_fail
.L2464:
	leaq	.LC118(%rip), %rcx
	call	hrdbf_app_fail
.L2463:
	leaq	.LC117(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
.LC119:
	.ascii "hbc: DBF-active dynamic scalar consumer is outside the admitted subset\12\0"
	.text
	.p2align 4
	.globl	hrdbfw_app_unsupported
	.def	hrdbfw_app_unsupported;	.scl	2;	.type	32;	.endef
hrdbfw_app_unsupported:
	subq	$40, %rsp
	leaq	.LC119(%rip), %rcx
	call	hrdbf_app_fail
	.section .rdata,"dr"
	.align 8
CSWTCH.385:
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
	.align 8
.LC102:
	.long	-798530048
	.long	1138748221
	.align 8
.LC103:
	.long	-798530048
	.long	-1008735427
	.align 8
.LC104:
	.long	0
	.long	1071644672
