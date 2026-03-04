	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC3:
	.ascii "arr[10] = %d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$440, %rsp
	.seh_stackalloc	440
	.seh_endprologue
	call	__main
	movl	$21, %ecx
	leaq	32(%rsp), %rax
	movdqu	.LC0(%rip), %xmm0
	movd	%ecx, %xmm3
	movl	$4, %ecx
	movd	%ecx, %xmm2
	pshufd	$0, %xmm3, %xmm3
	pshufd	$0, %xmm2, %xmm2
	.p2align 6
	.p2align 4
	.p2align 3
.L2:
	movdqa	%xmm0, %xmm1
	addq	$16, %rax
	leaq	432(%rsp), %rdx
	paddd	%xmm3, %xmm1
	paddd	%xmm2, %xmm0
	movups	%xmm1, -16(%rax)
	cmpq	%rax, %rdx
	jne	.L2
	movl	72(%rsp), %edx
	leaq	.LC3(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$440, %rsp
	ret
	.seh_endproc
	.section .rdata,"dr"
	.align 16
.LC0:
	.long	0
	.long	1
	.long	2
	.long	3
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
