# Windows (PE/COFF) hrobj runtime blob - GENERATED, do not edit.
# Derived from src/hrobj_blob.s (sha256 4546aa4258254af29ab3dfe7461f0366cfd1f8a00c5cbc547e3c9e18b6972284) by
# tests/generate_hrobj_windows_blob.py: instruction stream copied
# verbatim; ELF-only directives dropped (.type/.size/.hidden,
# trailing .note marker sections) - metadata with no emitted
# bytes. See the generator header for the derivation ledger.
# Regenerate after any change to src/hrobj_blob.s.
	.text
	.p2align 4
	.globl	hrobj_new
hrobj_new:
	endbr64
	pushq	%r14
	pushq	%r13
	pushq	%r12
	movq	%rdi, %r12
	pushq	%rbp
	pushq	%rbx
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
	cmpb	$5, %r13b
	jne	.Lhrobj_float_copy_not
	testq	%r13, %r13
	jns	.Lhrobj_13
	movq	%r13, %rax
	movq	%rdi, %rdx
	call	hbc_float_clone
	movq	%rax, %r13
	movq	%rdx, %rdi
	jmp	.Lhrobj_13
.Lhrobj_float_copy_not:
	cmpq	$4, %r13
	jne	.Lhrobj_13
	# hbc strings are NOT NUL-terminated: the length lives in the string
	# header at -8(%rdi) (written by hbc_stralloc). The spike blob's
	# strlen loop here read past the string end; it only worked on Linux
	# because mmap'd pages are zeroed (Windows HeapAlloc memory is not).
	movq	-8(%rdi), %rsi
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
	.p2align 4
	.globl	hrobj_retain
hrobj_retain:
	endbr64
	testq	%rdi, %rdi
	je	.Lhrobj_30
	addq	$1, 8(%rdi)
.Lhrobj_30:
	ret
	.p2align 4
	.globl	hrobj_release
hrobj_release:
	endbr64
	testq	%rdi, %rdi
	je	.Lhrobj_44
	pushq	%rbp
	movq	%rdi, %rbp
	pushq	%rbx
	subq	$8, %rsp
	subq	$1, 8(%rdi)
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
	je	.Lhrobj_payload_free
	cmpb	$5, 16(%rax)
	jne	.Lhrobj_40
	cmpq	$0, 16(%rax)
	jns	.Lhrobj_40
.Lhrobj_payload_free:
	movq	24(%rax), %rdi
	addl	$1, %ebx
	call	hbc_freestr
	movq	0(%rbp), %rdx
	cmpl	%ebx, 20(%rdx)
	ja	.Lhrobj_41
	.p2align 4,,10
	.p2align 3
.Lhrobj_39:
	movq	56(%rdx), %rax
	movq	%rax, 8(%rbp)
	movq	%rbp, 56(%rdx)
.Lhrobj_35:
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrobj_44:
	ret
