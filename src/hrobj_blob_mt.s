	.text
	.p2align 4
	.globl	hrobj_new
	.type	hrobj_new, @function
hrobj_new:
	endbr64
	pushq	%r14
	pushq	%r13
	pushq	%r12
	movq	%rdi, %r12
	pushq	%rbp
	pushq	%rbx
.Lhrobj_lk:
	lock btsq	$0, 80(%r12)
	jnc	.Lhrobj_lkd
.Lhrobj_lks:
	pause
	lock btsq	$0, 80(%r12)
	jc	.Lhrobj_lks
.Lhrobj_lkd:
	cmpq	$0, 48(%rdi)
	je	.Lhrobj_29
.Lhrobj_2:
	movq	56(%r12), %r14
	movl	20(%r12), %eax
	testq	%r14, %r14
	je	.Lhrobj_8
	movq	8(%r14), %rdx
	movq	%rdx, 56(%r12)
.Lhrobj_9:
	lock btrq	$0, 80(%r12)
	movq	%r12, (%r14)
	xorl	%ebp, %ebp
	movq	$1, 8(%r14)
	testl	%eax, %eax
	jne	.Lhrobj_12
	jmp	.Lhrobj_1
	.p2align 4,,10
	.p2align 3
.Lhrobj_13:
	addq	%r14, %rbx
	addl	$1, %ebp
	movq	%r13, 16(%rbx)
	movq	%rdi, 24(%rbx)
	cmpl	%ebp, 20(%r12)
	jbe	.Lhrobj_1
.Lhrobj_12:
	movq	48(%r12), %rax
	movl	%ebp, %ebx
	salq	$4, %rbx
	addq	%rbx, %rax
	movq	(%rax), %r13
	movq	8(%rax), %rdi
	cmpq	$4, %r13
	jne	.Lhrobj_13
	xorl	%esi, %esi
	cmpb	$0, (%rdi)
	je	.Lhrobj_14
	.p2align 4,,10
	.p2align 3
.Lhrobj_15:
	addq	$1, %rsi
	cmpb	$0, (%rdi,%rsi)
	jne	.Lhrobj_15
.Lhrobj_14:
	call	hbc_strcpy
	movq	%rax, %rdi
	jmp	.Lhrobj_13
	.p2align 4,,10
	.p2align 3
.Lhrobj_1:
	popq	%rbx
	movq	%r14, %rax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrobj_8:
	leal	1(%rax), %edx
	movq	64(%r12), %rbx
	sall	$4, %edx
	movl	%edx, %ebp
	cmpq	%rbp, %rbx
	jb	.Lhrobj_10
	movq	72(%r12), %r14
.Lhrobj_11:
	leaq	(%r14,%rbp), %rdx
	subq	%rbp, %rbx
	movq	%rdx, 72(%r12)
	movq	%rbx, 64(%r12)
	jmp	.Lhrobj_9
.Lhrobj_10:
	movl	$4096, %eax
	cmpl	%eax, %edx
	cmovb	%eax, %edx
	movl	%edx, %ebx
	movq	%rbx, %rdi
	call	hbc_alloc
	movq	%rax, %r14
	movl	20(%r12), %eax
	jmp	.Lhrobj_11
	.p2align 4,,10
	.p2align 3
.Lhrobj_29:
	movl	20(%rdi), %edi
	sall	$4, %edi
	testl	%edi, %edi
	jne	.Lhrobj_30b
	movl	$16, %edi
.Lhrobj_30b:
	call	hbc_alloc
	movl	20(%r12), %ecx
	movq	%rax, %rbp
	testl	%ecx, %ecx
	je	.Lhrobj_6
	salq	$4, %rcx
	movq	%rax, %rdx
	addq	%rax, %rcx
	.p2align 4,,10
	.p2align 3
.Lhrobj_5:
	movq	$1, (%rdx)
	addq	$16, %rdx
	movq	$0, -8(%rdx)
	cmpq	%rdx, %rcx
	jne	.Lhrobj_5
.Lhrobj_6:
	movq	%r12, %rbx
	.p2align 4,,10
	.p2align 3
.Lhrobj_4:
	movq	40(%rbx), %rdx
	testq	%rdx, %rdx
	je	.Lhrobj_7
	movq	%rbp, %rdi
	call	*%rdx
.Lhrobj_7:
	movq	8(%rbx), %rbx
	testq	%rbx, %rbx
	jne	.Lhrobj_4
	movq	%rbp, 48(%r12)
	jmp	.Lhrobj_2
	.size	hrobj_new, .-hrobj_new
	.p2align 4
	.globl	hrobj_retain
	.type	hrobj_retain, @function
hrobj_retain:
	endbr64
	testq	%rdi, %rdi
	je	.Lhrobj_30
	lock addq	$1, 8(%rdi)
.Lhrobj_30:
	ret
	.size	hrobj_retain, .-hrobj_retain
	.p2align 4
	.globl	hrobj_release
	.type	hrobj_release, @function
hrobj_release:
	endbr64
	testq	%rdi, %rdi
	je	.Lhrobj_44
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$8, %rsp
	lock subq	$1, 8(%rdi)
	jne	.Lhrobj_35
	movq	(%rdi), %rdx
	movl	20(%rdx), %eax
	testl	%eax, %eax
	je	.Lhrobj_39
	xorl	%ebx, %ebx
	jmp	.Lhrobj_41
	.p2align 4,,10
	.p2align 3
.Lhrobj_40:
	addl	$1, %ebx
	cmpl	%ebx, 20(%rdx)
	jbe	.Lhrobj_39
.Lhrobj_41:
	movl	%ebx, %eax
	salq	$4, %rax
	addq	%rbp, %rax
	cmpq	$4, 16(%rax)
	jne	.Lhrobj_40
	movq	24(%rax), %rdi
	addl	$1, %ebx
	call	hbc_freestr
	movq	0(%rbp), %rdx
	cmpl	%ebx, 20(%rdx)
	ja	.Lhrobj_41
	.p2align 4,,10
	.p2align 3
.Lhrobj_39:
	lock btsq	$0, 80(%rdx)
	jnc	.Lhrobj_39k
.Lhrobj_39s:
	pause
	lock btsq	$0, 80(%rdx)
	jc	.Lhrobj_39s
.Lhrobj_39k:
	movq	56(%rdx), %rax
	movq	%rax, 8(%rbp)
	movq	%rbp, 56(%rdx)
	lock btrq	$0, 80(%rdx)
.Lhrobj_35:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrobj_44:
	ret
	.size	hrobj_release, .-hrobj_release
	.hidden	hbc_freestr
	.hidden	hbc_alloc
	.hidden	hbc_strcpy
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
