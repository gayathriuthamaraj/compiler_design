	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "a=%d, b=%d, c=%d, d=%d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$64, %rsp
	.seh_stackalloc	64
	.seh_endprologue
	call	__main
	movl	$7, -4(%rbp)
	movl	$16, -8(%rbp)
	movl	$20, -12(%rbp)
	movl	-4(%rbp), %edx
	movl	-8(%rbp), %eax
	addl	%eax, %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -16(%rbp)
	movl	-12(%rbp), %r9d
	movl	-8(%rbp), %r8d
	movl	-4(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	-16(%rbp), %edx
	movl	%edx, 32(%rsp)
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$64, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
