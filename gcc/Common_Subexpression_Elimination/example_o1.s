	.file	"example_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "x = %d, y = %d, z = %d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$40, %rsp
	.seh_stackalloc	40
	.seh_endprologue
	call	__main
	movl	$46, %r9d
	movl	$23, %r8d
	movl	$23, %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	movl	$0, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
