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
	subq	$104, %rsp
	.seh_stackalloc	104
	.seh_endprologue
	call	__main
	movl	$0, 64(%rsp)
	movl	$2, 68(%rsp)
	movl	$4, 72(%rsp)
	movl	$6, 76(%rsp)
	movl	$8, 80(%rsp)
	leaq	64(%rsp), %rax
	leaq	32(%rsp), %rcx
	leaq	84(%rsp), %r8
.L2:
	movl	(%rax), %edx
	addl	$1, %edx
	movl	%edx, (%rcx)
	addq	$4, %rax
	addq	$4, %rcx
	cmpq	%r8, %rax
	jne	.L2
	movl	40(%rsp), %r8d
	movl	$4, %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	movl	$0, %eax
	addq	$104, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
