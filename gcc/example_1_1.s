	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "a[2]=%d, b[2]=%d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$40, %rsp
	.seh_stackalloc	40
	.seh_endprologue
	call	__main
	movl	$5, %r8d
	movl	$4, %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
