	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "arr[10] = %d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	subq	$440, %rsp
	.seh_stackalloc	440
	.seh_endprologue
	call	__main
	leaq	32(%rsp), %rax
	leaq	432(%rsp), %rcx
	movl	$21, %edx
	.p2align 4
.L2:
	movl	%edx, (%rax)
	addl	$1, %edx
	addq	$4, %rax
	cmpq	%rcx, %rax
	jne	.L2
	movl	72(%rsp), %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	movl	$0, %eax
	addq	$440, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
