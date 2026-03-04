	.file	"example_7.c"
	.text
	.section .rdata,"dr"
.LC2:
	.ascii "arr[3] = %d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$88, %rsp
	.seh_stackalloc	88
	.seh_endprologue
	call	__main
	leaq	32(%rsp), %rax
	leaq	72(%rsp), %rdx
	movq	.LC0(%rip), %xmm0
	movq	.LC1(%rip), %xmm2
.L2:
	movdqa	%xmm0, %xmm1
	addq	$8, %rax
	pslld	$1, %xmm1
	paddd	%xmm0, %xmm1
	paddd	%xmm2, %xmm0
	movq	%xmm1, -8(%rax)
	cmpq	%rdx, %rax
	jne	.L2
	movl	44(%rsp), %edx
	leaq	.LC2(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$88, %rsp
	ret
	.seh_endproc
	.section .rdata,"dr"
	.align 8
.LC0:
	.long	0
	.long	1
	.align 8
.LC1:
	.long	2
	.long	2
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
