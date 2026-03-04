	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "arr[5] = %d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$72, %rsp
	.seh_stackalloc	72
	.seh_endprologue
	call	__main
	pxor	%xmm0, %xmm0
	leaq	36(%rsp), %rdx
	movl	$1, %eax
	movups	%xmm0, 32(%rsp)
	movups	%xmm0, 48(%rsp)
	.p2align 5
	.p2align 4
	.p2align 3
.L2:
	movl	-4(%rdx), %ecx
	addq	$4, %rdx
	addl	%eax, %ecx
	addl	$1, %eax
	movl	%ecx, -4(%rdx)
	cmpl	$8, %eax
	jne	.L2
	movl	52(%rsp), %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$72, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
