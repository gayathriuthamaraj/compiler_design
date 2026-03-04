	.file	"example_1_1.c"
	.text
	.p2align 4
	.globl	getValue
	.def	getValue;	.scl	2;	.type	32;	.endef
	.seh_proc	getValue
getValue:
	.seh_endprologue
	movl	$42, %eax
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "x is positive\0"
.LC1:
	.ascii "v = %d\12\0"
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
	leaq	.LC0(%rip), %rcx
	call	puts
	movl	$42, %edx
	leaq	.LC1(%rip), %rcx
	call	__mingw_printf
	xorl	%eax, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
