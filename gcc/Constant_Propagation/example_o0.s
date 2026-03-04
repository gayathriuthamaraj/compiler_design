	.file	"example_2.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "x=%d, y=%d, z=%d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$48, %rsp
	.seh_stackalloc	48
	.seh_endprologue
	call	__main
	movl	$10, -4(%rbp)
	movl	-4(%rbp), %eax
	addl	$5, %eax
	movl	%eax, -8(%rbp)
	movl	-8(%rbp), %eax
	addl	%eax, %eax
	movl	%eax, -12(%rbp)
	movl	-12(%rbp), %r8d
	movl	-8(%rbp), %edx
	movl	-4(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%r8d, %r9d
	movl	%edx, %r8d
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
