	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "a=%d, b=%d, c=%d, d=%d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$56, %rsp
	.seh_stackalloc	56
	.seh_endprologue
	call	__main
	movl	$20, %r9d
	movl	$16, %r8d
	movl	$43, 32(%rsp)
	movl	$7, %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$56, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
