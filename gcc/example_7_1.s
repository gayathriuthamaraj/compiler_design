	.file	"example_7_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "%d\12\0"
	.text
	.globl	example1
	.def	example1;	.scl	2;	.type	32;	.endef
	.seh_proc	example1
example1:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$48, %rsp
	.seh_stackalloc	48
	.seh_endprologue
	movl	%ecx, 16(%rbp)
	movl	$0, -4(%rbp)
	movl	$0, -8(%rbp)
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%eax, %edx
	call	__mingw_printf
	addl	$2, -4(%rbp)
	addl	$1, -8(%rbp)
.L2:
	movl	-8(%rbp), %eax
	cmpl	16(%rbp), %eax
	jl	.L3
	nop
	nop
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
