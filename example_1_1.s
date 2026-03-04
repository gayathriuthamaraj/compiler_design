	.file	"example_1_1.c"
	.text
	.globl	example1
	.def	example1;	.scl	2;	.type	32;	.endef
	.seh_proc	example1
example1:
	pushq	%rbp
	.seh_pushreg	%rbp
	subq	$416, %rsp
	.seh_stackalloc	416
	leaq	128(%rsp), %rbp
	.seh_setframe	%rbp, 128
	.seh_endprologue
	movl	%ecx, 304(%rbp)
	movl	$5, 280(%rbp)
	movl	$10, 276(%rbp)
	movl	$0, 284(%rbp)
	jmp	.L2
.L3:
	movl	280(%rbp), %eax
	imull	276(%rbp), %eax
	movl	%eax, %edx
	movl	284(%rbp), %eax
	addl	%eax, %edx
	movl	284(%rbp), %eax
	cltq
	movl	%edx, -128(%rbp,%rax,4)
	addl	$1, 284(%rbp)
.L2:
	movl	284(%rbp), %eax
	cmpl	304(%rbp), %eax
	jl	.L3
	nop
	nop
	addq	$416, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
