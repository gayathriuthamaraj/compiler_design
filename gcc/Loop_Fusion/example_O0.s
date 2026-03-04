	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "a[2]=%d, b[2]=%d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$96, %rsp
	.seh_stackalloc	96
	.seh_endprologue
	call	__main
	movl	$0, -4(%rbp)
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	leal	(%rax,%rax), %edx
	movl	-4(%rbp), %eax
	cltq
	movl	%edx, -32(%rbp,%rax,4)
	addl	$1, -4(%rbp)
.L2:
	cmpl	$4, -4(%rbp)
	jle	.L3
	movl	$0, -8(%rbp)
	jmp	.L4
.L5:
	movl	-8(%rbp), %eax
	cltq
	movl	-32(%rbp,%rax,4), %eax
	leal	1(%rax), %edx
	movl	-8(%rbp), %eax
	cltq
	movl	%edx, -64(%rbp,%rax,4)
	addl	$1, -8(%rbp)
.L4:
	cmpl	$4, -8(%rbp)
	jle	.L5
	movl	-56(%rbp), %edx
	movl	-24(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%edx, %r8d
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$96, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
