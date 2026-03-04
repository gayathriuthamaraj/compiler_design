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
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$64, %rsp
	.seh_stackalloc	64
	.seh_endprologue
	call	__main
	movl	$4, -4(%rbp)
	movl	$5, -8(%rbp)
	movl	$3, -12(%rbp)
	movl	-4(%rbp), %eax
	imull	-8(%rbp), %eax
	movl	%eax, %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -16(%rbp)
	movl	-4(%rbp), %eax
	imull	-8(%rbp), %eax
	movl	%eax, %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -20(%rbp)
	movl	-16(%rbp), %edx
	movl	-20(%rbp), %eax
	addl	%edx, %eax
	movl	%eax, -24(%rbp)
	movl	-24(%rbp), %r8d
	movl	-20(%rbp), %edx
	movl	-16(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%r8d, %r9d
	movl	%edx, %r8d
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$64, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
