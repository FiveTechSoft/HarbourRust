	.text
	.section .rodata
.Lhrfile_C0:
.byte 100,105,103,105,116,0
.Lhrfile_C1:
.byte 108,111,119,101,114,0
.Lhrfile_C2:
.byte 117,112,112,101,114,0
.Lhrfile_C3:
.byte 97,108,112,104,97,0
.Lhrfile_C4:
.byte 97,108,110,117,109,0
.Lhrfile_C5:
.byte 120,100,105,103,105,116,0
.Lhrfile_C6:
.byte 115,112,97,99,101,0
.Lhrfile_C7:
.byte 98,108,97,110,107,0
.Lhrfile_C8:
.byte 99,110,116,114,108,0
.Lhrfile_C9:
.byte 112,114,105,110,116,0
.Lhrfile_C10:
.byte 103,114,97,112,104,0
.Lhrfile_C11:
.byte 112,117,110,99,116,0
	.text
	.p2align 4
	.type	hrfile_one, @function
hrfile_one:
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbp
	pushq	%rbx
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$776, %rsp
	movzbl	(%rdi), %r8d
	movq	%rdi, 64(%rsp)
	testb	%r8b, %r8b
	je	.Lhrfile_2
	movq	%rdi, %rcx
	xorl	%edx, %edx
	.p2align 4,,10
	.p2align 3
.Lhrfile_3:
	movq	%rdx, %rax
	leaq	1(%rdx), %rdx
	cmpb	$0, 1(%rcx,%rax)
	jne	.Lhrfile_3
	movq	64(%rsp), %r9
	movl	%r8d, %edi
	xorl	%edx, %edx
	xorl	%esi, %esi
	jmp	.Lhrfile_6
	.p2align 4,,10
	.p2align 3
.Lhrfile_213:
	movzbl	1(%r9,%rdx), %edi
	movq	%rcx, %rdx
.Lhrfile_6:
	leaq	1(%rdx), %rcx
	cmpb	$47, %dil
	cmove	%rcx, %rsi
	cmpq	%rdx, %rax
	jne	.Lhrfile_213
	testq	%rsi, %rsi
	je	.Lhrfile_2
	movq	64(%rsp), %rcx
	xorl	%edx, %edx
	leaq	224(%rsp), %rax
	jmp	.Lhrfile_8
.Lhrfile_214:
	movzbl	(%rcx,%rdx), %r8d
.Lhrfile_8:
	movb	%r8b, (%rax,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rsi
	jne	.Lhrfile_214
	movq	64(%rsp), %r14
	movq	%rdx, 40(%rsp)
	movb	$0, 224(%rsp,%rdx)
	addq	%rdx, %r14
	movzbl	(%r14), %r8d
.Lhrfile_9:
	testb	%r8b, %r8b
	je	.Lhrfile_12
	leaq	224(%rsp), %rsi
	xorl	%r10d, %r10d
	movl	$257, %eax
	movq	$-100, %rdi
	movl	$65536, %edx
	syscall
	movq	%rax, 72(%rsp)
	movq	%rax, %rdi
	testq	%rax, %rax
	js	.Lhrfile_12
	leaq	768(%rsp), %rsi
	movl	$217, %eax
	movl	$8192, %edx
	movq	%rsi, 32(%rsp)
	syscall
	movq	%rax, 24(%rsp)
	testq	%rax, %rax
	jle	.Lhrfile_14
.Lhrfile_13:
	xorl	%r13d, %r13d
	cmpq	$19, 24(%rsp)
	jle	.Lhrfile_16
	movq	%r13, (%rsp)
	movq	%r14, %r13
	.p2align 4,,10
	.p2align 3
.Lhrfile_79:
	movq	32(%rsp), %r14
	addq	(%rsp), %r14
	movzwl	16(%r14), %eax
	cmpw	$19, %ax
	jbe	.Lhrfile_197
	addq	%rax, (%rsp)
	movq	(%rsp), %rbx
	cmpq	24(%rsp), %rbx
	ja	.Lhrfile_197
	movzbl	19(%r14), %r15d
	movzbl	0(%r13), %edx
	movb	%r15b, 60(%rsp)
	testb	%r15b, %r15b
	je	.Lhrfile_103
	xorl	%ebx, %ebx
	movq	$-1, %rbp
	xorl	%r12d, %r12d
	xorl	%eax, %eax
	jmp	.Lhrfile_80
.Lhrfile_22:
	cmpq	$-1, %rbp
	je	.Lhrfile_84
	leaq	1(%rbx), %r12
	movzbl	0(%r13,%rbp), %edx
	movq	%rbp, %rax
	movq	%r12, %rbx
.Lhrfile_21:
	movzbl	19(%r14,%r12), %r15d
	testb	%r15b, %r15b
	je	.Lhrfile_17
.Lhrfile_80:
	cmpb	$42, %dl
	je	.Lhrfile_19
	testb	%dl, %dl
	je	.Lhrfile_22
	leaq	1(%rax), %rdi
	movzbl	%r15b, %r11d
	movq	%rdi, 16(%rsp)
	movzbl	%dl, %edi
	movl	%edi, 12(%rsp)
	cmpb	$63, %dl
	je	.Lhrfile_23
	cmpl	$92, %edi
	je	.Lhrfile_215
	cmpl	$91, 12(%rsp)
	je	.Lhrfile_216
.Lhrfile_26:
	xorl	%eax, %eax
	cmpl	12(%rsp), %r11d
	sete	%al
.Lhrfile_25:
	testl	%eax, %eax
	je	.Lhrfile_22
.Lhrfile_23:
	movq	16(%rsp), %rax
	addq	$1, %r12
	movzbl	0(%r13,%rax), %edx
.Lhrfile_221:
	movzbl	19(%r14,%r12), %r15d
	testb	%r15b, %r15b
	jne	.Lhrfile_80
	.p2align 4,,10
	.p2align 3
.Lhrfile_17:
	cmpb	$42, %dl
	jne	.Lhrfile_81
	leaq	1(%r13,%rax), %rax
	.p2align 4,,10
	.p2align 3
.Lhrfile_82:
	movzbl	(%rax), %edx
	addq	$1, %rax
	cmpb	$42, %dl
	je	.Lhrfile_82
.Lhrfile_81:
	testb	%dl, %dl
	je	.Lhrfile_217
.Lhrfile_84:
	movq	(%rsp), %rax
	addq	$19, %rax
	cmpq	24(%rsp), %rax
	jb	.Lhrfile_79
.Lhrfile_197:
	movq	%r13, %r14
.Lhrfile_16:
	movq	72(%rsp), %rdi
	movq	32(%rsp), %rsi
	xorl	%r10d, %r10d
	movl	$217, %eax
	movl	$8192, %edx
	syscall
	movq	%rax, 24(%rsp)
	testq	%rax, %rax
	jg	.Lhrfile_13
.Lhrfile_14:
	xorl	%r8d, %r8d
.Lhrfile_95:
	xorl	%edx, %edx
	movq	72(%rsp), %rdi
	xorl	%r10d, %r10d
	movl	$3, %eax
	movq	%rdx, %rsi
	syscall
	jmp	.Lhrfile_1
.Lhrfile_12:
	xorl	%r8d, %r8d
.Lhrfile_1:
	addq	$8968, %rsp
	movl	%r8d, %eax
	popq	%rbx
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.Lhrfile_2:
	movl	$46, %eax
	movq	64(%rsp), %r14
	movq	$0, 40(%rsp)
	movw	%ax, 224(%rsp)
	jmp	.Lhrfile_9
	.p2align 4,,10
	.p2align 3
.Lhrfile_19:
	addq	$1, %rax
	movzbl	0(%r13,%rax), %edx
	cmpb	$42, %dl
	je	.Lhrfile_19
	testb	%dl, %dl
	je	.Lhrfile_123
	movq	%r12, %rbx
	movq	%rax, %rbp
	jmp	.Lhrfile_21
	.p2align 4,,10
	.p2align 3
.Lhrfile_123:
	xorl	%eax, %eax
.Lhrfile_85:
	addq	$1, %rax
	cmpb	$0, 19(%r14,%rax)
	jne	.Lhrfile_85
	movq	40(%rsp), %rbx
	leaq	(%rbx,%rax), %rdx
	cmpq	$263, %rdx
	ja	.Lhrfile_84
	cmpq	$0, 40(%rsp)
	je	.Lhrfile_218
.Lhrfile_87:
	movq	40(%rsp), %rdi
	movq	64(%rsp), %r8
	xorl	%edx, %edx
	leaq	496(%rsp), %rsi
	.p2align 4,,10
	.p2align 3
.Lhrfile_91:
	movzbl	(%r8,%rdx), %ecx
	movb	%cl, (%rsi,%rdx)
	addq	$1, %rdx
	cmpq	%rdx, %rdi
	jne	.Lhrfile_91
	movq	40(%rsp), %rbx
	leaq	(%rsi,%rbx), %rcx
	movb	$0, (%rcx)
	testq	%rax, %rax
	je	.Lhrfile_88
.Lhrfile_90:
	movzbl	60(%rsp), %edi
	xorl	%edx, %edx
	jmp	.Lhrfile_93
	.p2align 4,,10
	.p2align 3
.Lhrfile_219:
	movzbl	19(%r14,%rdx), %edi
.Lhrfile_93:
	movb	%dil, (%rcx,%rdx)
	addq	$1, %rdx
	cmpq	%rax, %rdx
	jne	.Lhrfile_219
.Lhrfile_88:
	movl	$262, %r8d
	movb	$0, (%rcx,%rax)
	leaq	80(%rsp), %rdx
	xorl	%r10d, %r10d
	movq	$-100, %rdi
	movq	%r8, %rax
	syscall
	testq	%rax, %rax
	jns	.Lhrfile_94
	movl	$256, %r10d
	movq	%r8, %rax
	syscall
.Lhrfile_94:
	testq	%rax, %rax
	jne	.Lhrfile_84
	movl	104(%rsp), %eax
	andl	$61440, %eax
	cmpl	$16384, %eax
	je	.Lhrfile_84
	movl	$1, %r8d
	jmp	.Lhrfile_95
	.p2align 4,,10
	.p2align 3
.Lhrfile_215:
	movq	16(%rsp), %rdi
	movzbl	0(%r13,%rdi), %edx
	testb	%dl, %dl
	je	.Lhrfile_22
	addq	$2, %rax
	movq	%rax, 16(%rsp)
	xorl	%eax, %eax
	cmpl	%r11d, %edx
	sete	%al
	jmp	.Lhrfile_25
	.p2align 4,,10
	.p2align 3
.Lhrfile_216:
	movq	16(%rsp), %rdx
	movzbl	0(%r13,%rdx), %esi
	cmpb	$33, %sil
	je	.Lhrfile_131
	movl	$0, 56(%rsp)
	cmpb	$94, %sil
	je	.Lhrfile_131
.Lhrfile_27:
	leal	-48(%r15), %ecx
	xorl	%r10d, %r10d
	movabs	$35465847073801215, %rax
	shrq	%cl, %rax
	movb	%cl, 62(%rsp)
	andl	$1, %eax
	movb	%al, 63(%rsp)
	testb	%sil, %sil
	je	.Lhrfile_26
	.p2align 4,,10
	.p2align 3
.Lhrfile_75:
	movzbl	1(%r13,%rdx), %eax
	leaq	1(%rdx), %rdi
	testl	%r10d, %r10d
	je	.Lhrfile_29
	cmpb	$92, %sil
	je	.Lhrfile_220
	cmpb	$91, %sil
	jne	.Lhrfile_106
	cmpb	$61, %al
	ja	.Lhrfile_107
	movabs	$-2594143754109583361, %rcx
	btq	%rax, %rcx
	jc	.Lhrfile_33
	leaq	2(%rdx), %rcx
	movzbl	2(%r13,%rdx), %edx
	testb	%dl, %dl
	jne	.Lhrfile_34
	jmp	.Lhrfile_33
	.p2align 4,,10
	.p2align 3
.Lhrfile_35:
	testb	%dl, %dl
	je	.Lhrfile_33
.Lhrfile_34:
	movq	%rcx, %r8
	movl	%edx, %esi
	addq	$1, %rcx
	movzbl	0(%r13,%rcx), %edx
	cmpb	%al, %sil
	jne	.Lhrfile_35
	cmpb	$93, %dl
	jne	.Lhrfile_35
	movzbl	2(%r13,%r8), %esi
	leaq	2(%r8), %rdx
	.p2align 4,,10
	.p2align 3
.Lhrfile_31:
	testb	%sil, %sil
	je	.Lhrfile_26
.Lhrfile_32:
	cmpb	$93, %sil
	jne	.Lhrfile_75
	cmpq	%rdx, 16(%rsp)
	jnb	.Lhrfile_26
	cmpl	56(%rsp), %r10d
	je	.Lhrfile_22
	leaq	1(%rdx), %rax
	addq	$1, %r12
	movq	%rax, 16(%rsp)
	movq	16(%rsp), %rax
	movzbl	0(%r13,%rax), %edx
	jmp	.Lhrfile_221
	.p2align 4,,10
	.p2align 3
.Lhrfile_29:
	cmpb	$91, %sil
	je	.Lhrfile_222
	movzbl	%sil, %ecx
	cmpb	$92, %sil
	jne	.Lhrfile_38
	testb	%al, %al
	je	.Lhrfile_26
	movzbl	%al, %ecx
	movzbl	2(%r13,%rdx), %eax
	leaq	2(%rdx), %rdi
.Lhrfile_38:
	cmpb	$45, %al
	je	.Lhrfile_223
.Lhrfile_70:
	xorl	%r10d, %r10d
	cmpl	%ecx, %r11d
	movl	%eax, %esi
	movq	%rdi, %rdx
	sete	%r10b
	jmp	.Lhrfile_31
	.p2align 4,,10
	.p2align 3
.Lhrfile_222:
	cmpb	$61, %al
	ja	.Lhrfile_111
	movabs	$-2594143754109583361, %rcx
	btq	%rax, %rcx
	jc	.Lhrfile_111
	leaq	2(%rdx), %r8
	leaq	0(%r13,%r8), %rcx
	movq	%rcx, 48(%rsp)
	movzbl	(%rcx), %ecx
	movb	%cl, 61(%rsp)
	testb	%cl, %cl
	jne	.Lhrfile_39
	jmp	.Lhrfile_111
	.p2align 4,,10
	.p2align 3
.Lhrfile_40:
	testb	%cl, %cl
	je	.Lhrfile_111
.Lhrfile_39:
	movq	%r8, %rsi
	movl	%ecx, %r9d
	leaq	1(%r8), %r8
	movzbl	1(%r13,%rsi), %ecx
	cmpb	%al, %r9b
	jne	.Lhrfile_40
	cmpb	$93, %cl
	jne	.Lhrfile_40
	cmpb	$58, %al
	je	.Lhrfile_224
	addq	$3, %rdx
	cmpq	%rsi, %rdx
	jne	.Lhrfile_22
	movzbl	61(%rsp), %eax
	xorl	%r10d, %r10d
	cmpl	%r11d, %eax
	sete	%r10b
.Lhrfile_54:
	leaq	2(%rsi), %rdx
	movzbl	2(%r13,%rsi), %esi
	jmp	.Lhrfile_31
	.p2align 4,,10
	.p2align 3
.Lhrfile_220:
	testb	%al, %al
	je	.Lhrfile_26
	addq	$2, %rdx
	movzbl	0(%r13,%rdx), %esi
	jmp	.Lhrfile_31
	.p2align 4,,10
	.p2align 3
.Lhrfile_111:
	movl	$91, %ecx
	cmpb	$45, %al
	jne	.Lhrfile_70
.Lhrfile_223:
	movzbl	1(%r13,%rdi), %eax
	cmpb	$93, %al
	je	.Lhrfile_71
	testb	%al, %al
	je	.Lhrfile_71
	movzbl	2(%r13,%rdi), %esi
	leaq	2(%rdi), %rdx
	cmpb	$92, %al
	je	.Lhrfile_225
.Lhrfile_73:
	cmpl	%ecx, %r11d
	setnb	%cl
	xorl	%r10d, %r10d
	cmpl	%eax, %r11d
	setbe	%r10b
	andl	%ecx, %r10d
	jmp	.Lhrfile_31
	.p2align 4,,10
	.p2align 3
.Lhrfile_107:
	movl	%eax, %esi
	movq	%rdi, %rdx
	jmp	.Lhrfile_32
	.p2align 4,,10
	.p2align 3
.Lhrfile_71:
	xorl	%r10d, %r10d
	cmpl	%ecx, %r11d
	movl	$45, %esi
	movq	%rdi, %rdx
	sete	%r10b
	jmp	.Lhrfile_75
	.p2align 4,,10
	.p2align 3
.Lhrfile_33:
	testb	%al, %al
	je	.Lhrfile_26
	movl	%eax, %esi
	movq	%rdi, %rdx
	jmp	.Lhrfile_75
	.p2align 4,,10
	.p2align 3
.Lhrfile_106:
	movl	%eax, %esi
	movq	%rdi, %rdx
	jmp	.Lhrfile_31
	.p2align 4,,10
	.p2align 3
.Lhrfile_131:
	movl	$1, 56(%rsp)
	movzbl	2(%r13,%rax), %esi
	leaq	2(%rax), %rdx
	jmp	.Lhrfile_27
.Lhrfile_225:
	testb	%sil, %sil
	je	.Lhrfile_26
	movzbl	%sil, %eax
	leaq	3(%rdi), %rdx
	movzbl	3(%r13,%rdi), %esi
	jmp	.Lhrfile_73
.Lhrfile_217:
	cmpb	$0, 60(%rsp)
	jne	.Lhrfile_123
	cmpq	$263, 40(%rsp)
	ja	.Lhrfile_84
	xorl	%eax, %eax
	cmpq	$0, 40(%rsp)
	jne	.Lhrfile_87
	leaq	496(%rsp), %rsi
	movb	$0, 496(%rsp)
	movq	%rsi, %rcx
	jmp	.Lhrfile_88
	.p2align 4,,10
	.p2align 3
.Lhrfile_224:
	movq	%rsi, %rax
	subq	%rdx, %rax
	leaq	-2(%rax), %rdx
	cmpq	$7, %rax
	je	.Lhrfile_226
	cmpq	$6, %rdx
	jne	.Lhrfile_22
	movq	48(%rsp), %rdi
	movzbl	61(%rsp), %ecx
	movl	$120, %edx
	xorl	%eax, %eax
	jmp	.Lhrfile_56
.Lhrfile_227:
	leaq	.Lhrfile_C5(%rip), %rdx
	movzbl	(%rdi,%rax), %ecx
	movzbl	(%rdx,%rax), %edx
.Lhrfile_56:
	cmpb	%dl, %cl
	jne	.Lhrfile_22
	addq	$1, %rax
	cmpq	$6, %rax
	jne	.Lhrfile_227
	movzbl	62(%rsp), %edi
	movzbl	63(%rsp), %eax
	cmpb	$55, %dil
	cmovb	%eax, %r10d
	jmp	.Lhrfile_54
	.p2align 4,,10
	.p2align 3
.Lhrfile_103:
	xorl	%eax, %eax
	jmp	.Lhrfile_17
.Lhrfile_226:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$100, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C0(%rip), %rdi
	jmp	.Lhrfile_45
	.p2align 4,,10
	.p2align 3
.Lhrfile_228:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_45:
	cmpb	%cl, %dl
	jne	.Lhrfile_112
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_228
.Lhrfile_44:
	leal	-48(%r11), %eax
	xorl	%r10d, %r10d
	cmpl	$9, %eax
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_112:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$108, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C1(%rip), %rdi
	jmp	.Lhrfile_43
	.p2align 4,,10
	.p2align 3
.Lhrfile_229:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_43:
	cmpb	%cl, %dl
	jne	.Lhrfile_113
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_229
	leal	-97(%r11), %eax
	xorl	%r10d, %r10d
	cmpl	$25, %eax
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_113:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$117, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C2(%rip), %rdi
	jmp	.Lhrfile_46
	.p2align 4,,10
	.p2align 3
.Lhrfile_230:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_46:
	cmpb	%cl, %dl
	jne	.Lhrfile_114
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_230
	leal	-65(%r11), %eax
	xorl	%r10d, %r10d
	cmpl	$25, %eax
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_114:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$97, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C3(%rip), %rdi
	jmp	.Lhrfile_48
	.p2align 4,,10
	.p2align 3
.Lhrfile_231:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_48:
	cmpb	%cl, %dl
	jne	.Lhrfile_115
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_231
	movl	%r15d, %eax
	xorl	%r10d, %r10d
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_115:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$97, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C4(%rip), %rdi
	jmp	.Lhrfile_50
	.p2align 4,,10
	.p2align 3
.Lhrfile_232:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_50:
	cmpb	%cl, %dl
	jne	.Lhrfile_116
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_232
	movl	%r15d, %eax
	movl	$1, %r10d
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	jbe	.Lhrfile_54
	jmp	.Lhrfile_44
.Lhrfile_218:
	leaq	496(%rsp), %rsi
	movb	$0, 496(%rsp)
	movq	%rsi, %rcx
	jmp	.Lhrfile_90
.Lhrfile_116:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$115, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C6(%rip), %rdi
	jmp	.Lhrfile_52
	.p2align 4,,10
	.p2align 3
.Lhrfile_233:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_52:
	cmpb	%cl, %dl
	jne	.Lhrfile_117
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_233
	leal	-9(%r11), %eax
	cmpl	$4, %eax
	setbe	%al
	cmpl	$32, %r11d
	sete	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
.Lhrfile_97:
	testl	%eax, %eax
	cmovne	%eax, %r10d
	jmp	.Lhrfile_54
	.p2align 4,,10
	.p2align 3
.Lhrfile_117:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$98, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C7(%rip), %rdi
	jmp	.Lhrfile_57
	.p2align 4,,10
	.p2align 3
.Lhrfile_234:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_57:
	cmpb	%cl, %dl
	jne	.Lhrfile_118
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_234
	cmpl	$32, %r11d
	sete	%al
	cmpl	$9, %r11d
	sete	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrfile_97
.Lhrfile_118:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$99, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C8(%rip), %rdi
	jmp	.Lhrfile_59
	.p2align 4,,10
	.p2align 3
.Lhrfile_235:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_59:
	cmpb	%cl, %dl
	jne	.Lhrfile_119
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_235
	cmpl	$31, %r11d
	setbe	%al
	cmpl	$127, %r11d
	sete	%dl
	orl	%edx, %eax
	movzbl	%al, %eax
	jmp	.Lhrfile_97
.Lhrfile_119:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %r8
	movl	$112, %edx
	xorl	%eax, %eax
	leaq	.Lhrfile_C9(%rip), %rdi
	jmp	.Lhrfile_61
	.p2align 4,,10
	.p2align 3
.Lhrfile_236:
	movzbl	(%r8,%rax), %ecx
	movzbl	(%rdi,%rax), %edx
.Lhrfile_61:
	cmpb	%cl, %dl
	jne	.Lhrfile_120
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_236
	leal	-32(%r11), %eax
	xorl	%r10d, %r10d
	cmpl	$94, %eax
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_120:
	movzbl	61(%rsp), %ecx
	movq	48(%rsp), %rdi
	movl	$103, %edx
	xorl	%eax, %eax
	jmp	.Lhrfile_63
	.p2align 4,,10
	.p2align 3
.Lhrfile_237:
	leaq	.Lhrfile_C10(%rip), %rdx
	movzbl	(%rdi,%rax), %ecx
	movzbl	(%rdx,%rax), %edx
.Lhrfile_63:
	cmpb	%cl, %dl
	jne	.Lhrfile_121
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_237
	leal	-33(%r11), %eax
	xorl	%r10d, %r10d
	cmpl	$93, %eax
	setbe	%r10b
	jmp	.Lhrfile_54
.Lhrfile_121:
	movq	48(%rsp), %rdi
	movzbl	61(%rsp), %ecx
	movl	$112, %edx
	xorl	%eax, %eax
	jmp	.Lhrfile_65
	.p2align 4,,10
	.p2align 3
.Lhrfile_238:
	leaq	.Lhrfile_C11(%rip), %rdx
	movzbl	(%rdi,%rax), %ecx
	movzbl	(%rdx,%rax), %edx
.Lhrfile_65:
	cmpb	%cl, %dl
	jne	.Lhrfile_22
	addq	$1, %rax
	cmpq	$5, %rax
	jne	.Lhrfile_238
	leal	-33(%r11), %eax
	cmpl	$93, %eax
	ja	.Lhrfile_54
	movl	%r15d, %eax
	leal	-48(%r11), %edx
	andl	$-33, %eax
	subl	$65, %eax
	cmpb	$25, %al
	seta	%al
	xorl	%r10d, %r10d
	cmpl	$9, %edx
	seta	%r10b
	andl	%eax, %r10d
	jmp	.Lhrfile_54
	.size	hrfile_one, .-hrfile_one
	.p2align 4
	.type	hrfile_join, @function
hrfile_join:
	movq	%rdi, %r8
	movl	$262, %edi
	subq	$280, %rsp
	movq	%rdx, %r11
	cmpq	%rdi, %rsi
	movq	%rsp, %r9
	cmovbe	%rsi, %rdi
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	.Lhrfile_264
	.p2align 4,,10
	.p2align 3
.Lhrfile_240:
	movzbl	(%r8,%rax), %edx
	movb	%dl, (%r9,%rax)
	addq	$1, %rax
	cmpq	%rdi, %rax
	jb	.Lhrfile_240
	leaq	(%r9,%rdi), %r10
	movb	$0, (%r10)
	testq	%rcx, %rcx
	je	.Lhrfile_243
	cmpb	$47, -1(%r8,%rdi)
	je	.Lhrfile_243
	cmpq	$260, %rsi
	jbe	.Lhrfile_265
	.p2align 4,,10
	.p2align 3
.Lhrfile_243:
	movl	$262, %eax
	subq	%rdi, %rax
	cmpq	%rcx, %rax
	cmovbe	%rax, %rcx
	xorl	%eax, %eax
	testq	%rcx, %rcx
	je	.Lhrfile_246
	.p2align 4,,10
	.p2align 3
.Lhrfile_245:
	movzbl	(%r11,%rax), %edx
	movb	%dl, (%r10,%rax)
	addq	$1, %rax
	cmpq	%rax, %rcx
	jne	.Lhrfile_245
.Lhrfile_246:
	movb	$0, (%r10,%rcx)
	movq	%r9, %rdi
	call	hrfile_one
	addq	$280, %rsp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_265:
	leaq	1(%rdi), %rax
	movb	$47, (%rsp,%rdi)
	leaq	(%r9,%rax), %r10
	movq	%rax, %rdi
	jmp	.Lhrfile_243
	.p2align 4,,10
	.p2align 3
.Lhrfile_264:
	leaq	(%r9,%rdi), %r10
	movb	$0, (%r10)
	jmp	.Lhrfile_243
	.size	hrfile_join, .-hrfile_join
	.p2align 4
	.globl	hrfile_set
	.type	hrfile_set, @function
hrfile_set:
	endbr64
	movl	$65535, %eax
	cmpq	%rax, %rdx
	cmovbe	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrfile_286
	xorl	%edx, %edx
	jmp	.Lhrfile_267
	.p2align 4,,10
	.p2align 3
.Lhrfile_271:
	addq	$1, %rdx
	cmpq	%rdx, %rax
	jbe	.Lhrfile_287
.Lhrfile_267:
	cmpb	$0, (%rsi,%rdx)
	jne	.Lhrfile_271
	testq	%rdi, %rdi
	jne	.Lhrfile_272
	testq	%rdx, %rdx
	je	.Lhrfile_285
.Lhrfile_273:
	xorl	%eax, %eax
	leaq	hrfile_default(%rip), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrfile_277:
	movzbl	(%rsi,%rax), %ecx
	movb	%cl, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rax, %rdx
	jne	.Lhrfile_277
	addq	%rdx, %rdi
.Lhrfile_269:
	movb	$0, (%rdi)
	movq	%rdx, hrfile_dn(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_287:
	testq	%rdi, %rdi
	je	.Lhrfile_273
	movl	$1, hrfile_path_active(%rip)
.Lhrfile_278:
	xorl	%eax, %eax
	leaq	hrfile_paths(%rip), %rdi
	.p2align 4,,10
	.p2align 3
.Lhrfile_275:
	movzbl	(%rsi,%rax), %ecx
	movb	%cl, (%rdi,%rax)
	addq	$1, %rax
	cmpq	%rdx, %rax
	jb	.Lhrfile_275
	addq	%rdx, %rdi
.Lhrfile_274:
	movb	$0, (%rdi)
	movq	%rdx, hrfile_pn(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_272:
	movl	$1, hrfile_path_active(%rip)
	leaq	hrfile_paths(%rip), %rdi
	testq	%rdx, %rdx
	jne	.Lhrfile_278
	jmp	.Lhrfile_274
.Lhrfile_286:
	testq	%rdi, %rdi
	je	.Lhrfile_285
	movl	$1, hrfile_path_active(%rip)
	leaq	hrfile_paths(%rip), %rdi
	jmp	.Lhrfile_274
.Lhrfile_285:
	leaq	hrfile_default(%rip), %rdi
	jmp	.Lhrfile_269
	.size	hrfile_set, .-hrfile_set
	.section .rodata
.Lhrfile_C12:
.byte 0
	.text
	.p2align 4
	.globl	hrfile_exists
	.type	hrfile_exists, @function
hrfile_exists:
	endbr64
	movl	$263, %eax
	cmpq	%rax, %rsi
	cmovbe	%rsi, %rax
	testq	%rsi, %rsi
	je	.Lhrfile_320
	pushq	%r14
	pushq	%r13
	movq	%rdi, %r13
	pushq	%r12
	xorl	%r12d, %r12d
	pushq	%rbp
	pushq	%rbx
	jmp	.Lhrfile_289
	.p2align 4,,10
	.p2align 3
.Lhrfile_292:
	addq	$1, %r12
	cmpq	%r12, %rax
	jbe	.Lhrfile_291
.Lhrfile_289:
	cmpb	$0, 0(%r13,%r12)
	jne	.Lhrfile_292
	testq	%r12, %r12
	jne	.Lhrfile_291
.Lhrfile_290:
	popq	%rbx
	xorl	%eax, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_291:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %ecx
	.p2align 4,,10
	.p2align 3
.Lhrfile_294:
	cmpb	$47, 0(%r13,%rax)
	cmove	%ecx, %edx
	addq	$1, %rax
	cmpq	%rax, %r12
	ja	.Lhrfile_294
	testl	%edx, %edx
	movq	%r12, %rcx
	movq	%r13, %rdx
	jne	.Lhrfile_321
	movq	hrfile_dn(%rip), %rsi
	leaq	hrfile_default(%rip), %rdi
	call	hrfile_join
	testl	%eax, %eax
	jne	.Lhrfile_300
	movl	hrfile_path_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrfile_290
	movq	hrfile_pn(%rip), %rbp
	xorl	%edi, %edi
	leaq	hrfile_paths(%rip), %r14
	.p2align 4,,10
	.p2align 3
.Lhrfile_303:
	movq	%rdi, %rbx
	cmpq	%rdi, %rbp
	ja	.Lhrfile_298
	jmp	.Lhrfile_322
	.p2align 4,,10
	.p2align 3
.Lhrfile_301:
	addq	$1, %rbx
	cmpq	%rbx, %rbp
	je	.Lhrfile_323
.Lhrfile_298:
	cmpb	$58, (%r14,%rbx)
	jne	.Lhrfile_301
	movq	%rbx, %rsi
	movq	%r12, %rcx
	movq	%r13, %rdx
	subq	%rdi, %rsi
	addq	%r14, %rdi
	call	hrfile_join
	testl	%eax, %eax
	jne	.Lhrfile_300
.Lhrfile_304:
	leaq	1(%rbx), %rdi
	jmp	.Lhrfile_303
	.p2align 4,,10
	.p2align 3
.Lhrfile_321:
	xorl	%esi, %esi
	leaq	.Lhrfile_C12(%rip), %rdi
	call	hrfile_join
	popq	%rbx
	popq	%rbp
	cltq
	popq	%r12
	popq	%r13
	popq	%r14
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_323:
	movq	%rbp, %rsi
	movq	%r12, %rcx
	movq	%r13, %rdx
	subq	%rdi, %rsi
	addq	%r14, %rdi
	call	hrfile_join
	testl	%eax, %eax
	je	.Lhrfile_290
.Lhrfile_300:
	popq	%rbx
	movl	$1, %eax
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	ret
.Lhrfile_322:
	xorl	%esi, %esi
	leaq	(%r14,%rdi), %rdi
	movq	%r12, %rcx
	movq	%r13, %rdx
	call	hrfile_join
	testl	%eax, %eax
	jne	.Lhrfile_300
	cmpq	%rbx, %rbp
	jne	.Lhrfile_304
	jmp	.Lhrfile_290
	.p2align 4,,10
	.p2align 3
.Lhrfile_320:
	xorl	%eax, %eax
	ret
	.size	hrfile_exists, .-hrfile_exists

.bss
.balign 8
hrfile_pn:
.zero 8
.text

.bss
.balign 8
hrfile_dn:
.zero 8
.text

.bss
.balign 4
hrfile_path_active:
.zero 4
.text

.bss
.balign 32
hrfile_paths:
.zero 65536
.text

.bss
.balign 32
hrfile_default:
.zero 65536
.text
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
.byte 71,78,85,0
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:

.text
hrfile_app_exists:
    jmp hrfile_exists
hrfile_app_set:
    jmp hrfile_set
