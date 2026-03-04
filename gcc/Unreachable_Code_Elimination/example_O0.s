	.file	"example_1_1.c"
	.text
	.globl	getValue
	.def	getValue;	.scl	2;	.type	32;	.endef
	.seh_proc	getValue
getValue:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	.seh_endprologue
	movl	$42, %eax
	popq	%rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "x is positive\0"
.LC1:
	.ascii "x is not positive\0"
.LC2:
	.ascii "v = %d\12\0"
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
	movl	$1, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jle	.L4
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	puts
	jmp	.L5
.L4:
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	puts
.L5:
	call	getValue
	movl	%eax, -8(%rbp)
	movl	-8(%rbp), %eax
	leaq	.LC2(%rip), %rcx
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
	.def	puts;	.scl	2;	.type	32;	.endef
