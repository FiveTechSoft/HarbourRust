	.text
	.p2align 4
hrfile_join:
	pushq	%r13
	movl	$262, %r11d
	pushq	%r12
	pushq	%rbx
	movq	%rdx, %rbx
	subq	$1424, %rsp
	cmpq	$262, %rdx
	cmovbe	%rdx, %r11
	leaq	32(%rsp), %r10
	xorl	%eax, %eax
	testq	%rdx, %rdx
	je	.Lhrfile_44
	.p2align 4,,10
	.p2align 3
.Lhrfile_2:
	movzbl	(%rcx,%rax), %edx
	movb	%dl, (%r10,%rax)
	addq	$1, %rax
	cmpq	%rax, %r11
	ja	.Lhrfile_2
	leaq	(%r10,%r11), %r12
	movb	$0, (%r12)
	testq	%r9, %r9
	je	.Lhrfile_5
	movzbl	-1(%rcx,%r11), %ecx
	movl	$1, %eax
	subl	$47, %ecx
	cmpb	$45, %cl
	ja	.Lhrfile_7
	movabs	$35184372090881, %rax
	shrq	%cl, %rax
	notq	%rax
	andl	$1, %eax
.Lhrfile_7:
	cmpq	$260, %rbx
	ja	.Lhrfile_5
	testb	%al, %al
	jne	.Lhrfile_45
.Lhrfile_5:
	movl	$262, %eax
	subq	%r11, %rax
	cmpq	%r9, %rax
	cmovbe	%rax, %r9
	xorl	%eax, %eax
	testq	%r9, %r9
	je	.Lhrfile_11
	.p2align 4,,10
	.p2align 3
.Lhrfile_8:
	movzbl	(%r8,%rax), %edx
	movb	%dl, (%r12,%rax)
	addq	$1, %rax
	cmpq	%rax, %r9
	jne	.Lhrfile_8
.Lhrfile_11:
	movb	$0, (%r12,%r9)
	movzbl	32(%rsp), %eax
	xorl	%edx, %edx
	leaq	304(%rsp), %rcx
	leaq	hrfile_cp437.0(%rip), %r8
	testb	%al, %al
	jne	.Lhrfile_9
	jmp	.Lhrfile_10
	.p2align 4,,10
	.p2align 3
.Lhrfile_46:
	cmpq	$263, %rdx
	je	.Lhrfile_10
.Lhrfile_9:
	testb	%al, %al
	jns	.Lhrfile_13
	addl	$-128, %eax
	movzwl	(%r8,%rax,2), %eax
.Lhrfile_13:
	movw	%ax, (%rcx,%rdx,2)
	addq	$1, %rdx
	movzbl	(%r10,%rdx), %eax
	testb	%al, %al
	jne	.Lhrfile_46
.Lhrfile_10:
	xorl	%eax, %eax
	leaq	832(%rsp), %rbx
	movw	%ax, 304(%rsp,%rdx,2)
	movq	%rbx, %rdx
	call	FindFirstFileW
	movq	%rax, %r13
	cmpq	$-1, %rax
	jne	.Lhrfile_16
	jmp	.Lhrfile_21
	.p2align 4,,10
	.p2align 3
.Lhrfile_47:
	movq	%rbx, %rdx
	movq	%r13, %rcx
	call	FindNextFileW
	movl	%eax, %r12d
	testl	%eax, %eax
	je	.Lhrfile_15
.Lhrfile_16:
	testb	$22, 832(%rsp)
	jne	.Lhrfile_47
	movl	$1, %r12d
.Lhrfile_15:
	movq	%r13, %rcx
	call	FindClose
	addq	$1424, %rsp
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
.Lhrfile_45:
	leaq	1(%r11), %rax
	movb	$47, 32(%rsp,%r11)
	leaq	(%r10,%rax), %r12
	movq	%rax, %r11
	jmp	.Lhrfile_5
	.p2align 4,,10
	.p2align 3
.Lhrfile_21:
	addq	$1424, %rsp
	xorl	%r12d, %r12d
	movl	%r12d, %eax
	popq	%rbx
	popq	%r12
	popq	%r13
	ret
.Lhrfile_44:
	leaq	(%r10,%r11), %r12
	movb	$0, (%r12)
	jmp	.Lhrfile_5
	.p2align 4
	.globl	hrfile_set
hrfile_set:
	cmpq	$65535, %r8
	movl	$65535, %eax
	cmovbe	%r8, %rax
	testq	%r8, %r8
	je	.Lhrfile_68
	xorl	%r8d, %r8d
	jmp	.Lhrfile_49
	.p2align 4,,10
	.p2align 3
.Lhrfile_53:
	addq	$1, %r8
	cmpq	%r8, %rax
	jbe	.Lhrfile_69
.Lhrfile_49:
	cmpb	$0, (%rdx,%r8)
	jne	.Lhrfile_53
	testq	%rcx, %rcx
	jne	.Lhrfile_54
	testq	%r8, %r8
	je	.Lhrfile_67
.Lhrfile_55:
	xorl	%eax, %eax
	leaq	hrfile_default(%rip), %r9
	.p2align 4,,10
	.p2align 3
.Lhrfile_59:
	movzbl	(%rdx,%rax), %ecx
	movb	%cl, (%r9,%rax)
	addq	$1, %rax
	cmpq	%rax, %r8
	jne	.Lhrfile_59
	addq	%r8, %r9
.Lhrfile_51:
	movb	$0, (%r9)
	movq	%r8, hrfile_dn(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_69:
	testq	%rcx, %rcx
	je	.Lhrfile_55
	movl	$1, hrfile_path_active(%rip)
.Lhrfile_60:
	xorl	%eax, %eax
	leaq	hrfile_paths(%rip), %r9
	.p2align 4,,10
	.p2align 3
.Lhrfile_57:
	movzbl	(%rdx,%rax), %ecx
	movb	%cl, (%r9,%rax)
	addq	$1, %rax
	cmpq	%r8, %rax
	jb	.Lhrfile_57
	addq	%r8, %r9
.Lhrfile_56:
	movb	$0, (%r9)
	movq	%r8, hrfile_pn(%rip)
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_54:
	movl	$1, hrfile_path_active(%rip)
	leaq	hrfile_paths(%rip), %r9
	testq	%r8, %r8
	jne	.Lhrfile_60
	jmp	.Lhrfile_56
.Lhrfile_68:
	testq	%rcx, %rcx
	je	.Lhrfile_67
	movl	$1, hrfile_path_active(%rip)
	leaq	hrfile_paths(%rip), %r9
	jmp	.Lhrfile_56
.Lhrfile_67:
	leaq	hrfile_default(%rip), %r9
	jmp	.Lhrfile_51
	.section .rdata,"dr"
.Lhrfile_C0:
.byte 0
	.text
	.p2align 4
	.globl	hrfile_exists
hrfile_exists:
	cmpq	$263, %rdx
	movl	$263, %eax
	cmovbe	%rdx, %rax
	testq	%rdx, %rdx
	je	.Lhrfile_101
	pushq	%rbp
	pushq	%rdi
	movq	%rcx, %rdi
	pushq	%rsi
	xorl	%esi, %esi
	pushq	%rbx
	subq	$40, %rsp
	jmp	.Lhrfile_71
	.p2align 4,,10
	.p2align 3
.Lhrfile_74:
	addq	$1, %rsi
	cmpq	%rsi, %rax
	jbe	.Lhrfile_73
.Lhrfile_71:
	cmpb	$0, (%rdi,%rsi)
	jne	.Lhrfile_74
	testq	%rsi, %rsi
	jne	.Lhrfile_73
.Lhrfile_72:
	addq	$40, %rsp
	xorl	%eax, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.p2align 4,,10
	.p2align 3
.Lhrfile_73:
	xorl	%edx, %edx
	xorl	%eax, %eax
	movl	$1, %r8d
	movabs	$35184372090881, %r9
	.p2align 4,,10
	.p2align 3
.Lhrfile_76:
	movzbl	(%rdi,%rax), %ecx
	subl	$47, %ecx
	cmpb	$45, %cl
	ja	.Lhrfile_75
	movq	%r9, %rbx
	shrq	%cl, %rbx
	movq	%rbx, %rcx
	andl	$1, %ecx
	cmovne	%r8d, %edx
.Lhrfile_75:
	addq	$1, %rax
	cmpq	%rsi, %rax
	jb	.Lhrfile_76
	movq	%rsi, %r9
	movq	%rdi, %r8
	testl	%edx, %edx
	jne	.Lhrfile_102
	movq	hrfile_dn(%rip), %rdx
	leaq	hrfile_default(%rip), %rcx
	call	hrfile_join
	testl	%eax, %eax
	jne	.Lhrfile_83
	movl	hrfile_path_active(%rip), %eax
	testl	%eax, %eax
	je	.Lhrfile_72
	movq	hrfile_pn(%rip), %rax
	xorl	%ecx, %ecx
	leaq	hrfile_paths(%rip), %rbp
	.p2align 4,,10
	.p2align 3
.Lhrfile_84:
	movq	%rcx, %rbx
	xorl	%edx, %edx
	cmpq	%rax, %rcx
	jb	.Lhrfile_80
	jmp	.Lhrfile_81
	.p2align 4,,10
	.p2align 3
.Lhrfile_82:
	addq	$1, %rbx
	cmpq	%rax, %rbx
	je	.Lhrfile_100
.Lhrfile_80:
	cmpb	$59, 0(%rbp,%rbx)
	jne	.Lhrfile_82
.Lhrfile_100:
	movq	%rbx, %rdx
	subq	%rcx, %rdx
.Lhrfile_81:
	addq	%rbp, %rcx
	movq	%rsi, %r9
	movq	%rdi, %r8
	call	hrfile_join
	testl	%eax, %eax
	jne	.Lhrfile_83
	movq	hrfile_pn(%rip), %rax
	cmpq	%rbx, %rax
	je	.Lhrfile_72
	leaq	1(%rbx), %rcx
	jmp	.Lhrfile_84
	.p2align 4,,10
	.p2align 3
.Lhrfile_102:
	addq	$40, %rsp
	xorl	%edx, %edx
	leaq	.Lhrfile_C0(%rip), %rcx
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	jmp	hrfile_join
	.p2align 4,,10
	.p2align 3
.Lhrfile_83:
	addq	$40, %rsp
	movl	$1, %eax
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
.Lhrfile_101:
	xorl	%eax, %eax
	ret
	.section .rdata,"dr"
	.align 32
hrfile_cp437.0:
.byte 199,0
.byte 252,0
.byte 233,0
.byte 226,0
.byte 228,0
.byte 224,0
.byte 229,0
.byte 231,0
.byte 234,0
.byte 235,0
.byte 232,0
.byte 239,0
.byte 238,0
.byte 236,0
.byte 196,0
.byte 197,0
.byte 201,0
.byte 230,0
.byte 198,0
.byte 244,0
.byte 246,0
.byte 242,0
.byte 251,0
.byte 249,0
.byte 255,0
.byte 214,0
.byte 220,0
.byte 162,0
.byte 163,0
.byte 165,0
.byte 167,32
.byte 146,1
.byte 225,0
.byte 237,0
.byte 243,0
.byte 250,0
.byte 241,0
.byte 209,0
.byte 170,0
.byte 186,0
.byte 191,0
.byte 16,35
.byte 172,0
.byte 189,0
.byte 188,0
.byte 161,0
.byte 171,0
.byte 187,0
.byte 145,37
.byte 146,37
.byte 147,37
.byte 2,37
.byte 36,37
.byte 97,37
.byte 98,37
.byte 86,37
.byte 85,37
.byte 99,37
.byte 81,37
.byte 87,37
.byte 93,37
.byte 92,37
.byte 91,37
.byte 16,37
.byte 20,37
.byte 52,37
.byte 44,37
.byte 28,37
.byte 0,37
.byte 60,37
.byte 94,37
.byte 95,37
.byte 90,37
.byte 84,37
.byte 105,37
.byte 102,37
.byte 96,37
.byte 80,37
.byte 108,37
.byte 103,37
.byte 104,37
.byte 100,37
.byte 101,37
.byte 89,37
.byte 88,37
.byte 82,37
.byte 83,37
.byte 107,37
.byte 106,37
.byte 24,37
.byte 12,37
.byte 136,37
.byte 132,37
.byte 140,37
.byte 144,37
.byte 128,37
.byte 177,3
.byte 223,0
.byte 147,3
.byte 192,3
.byte 163,3
.byte 195,3
.byte 181,0
.byte 196,3
.byte 166,3
.byte 152,3
.byte 169,3
.byte 180,3
.byte 30,34
.byte 198,3
.byte 181,3
.byte 41,34
.byte 97,34
.byte 177,0
.byte 101,34
.byte 100,34
.byte 32,35
.byte 33,35
.byte 247,0
.byte 72,34
.byte 176,0
.byte 25,34
.byte 183,0
.byte 26,34
.byte 127,32
.byte 178,0
.byte 160,37
.byte 160,0
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
.text
hrfile_app_exists:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrfile_exists
    leave
    ret
hrfile_app_set:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp
    mov %rdx, %r8
    mov %rsi, %rdx
    mov %rdi, %rcx
    call hrfile_set
    leave
    ret
