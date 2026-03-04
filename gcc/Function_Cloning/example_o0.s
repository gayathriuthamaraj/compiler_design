	.file	"example_5.c"
	.text
	.globl	process
	.def	process;	.scl	2;	.type	32;	.endef
	.seh_proc	process
process:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	.seh_endprologue
	movl	%ecx, 16(%rbp)
	movl	%edx, 24(%rbp)
	cmpl	$0, 24(%rbp)
	jne	.L2
	movl	16(%rbp), %eax
	addl	%eax, %eax
	jmp	.L3
.L2:
	movl	16(%rbp), %eax
	addl	$100, %eax
.L3:
	popq	%rbp
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "r1 = %d, r2 = %d\12\0"
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
	movl	$0, %edx
	movl	$10, %ecx
	call	process
	movl	%eax, -4(%rbp)
	movl	$1, %edx
	movl	$10, %ecx
	call	process
	movl	%eax, -8(%rbp)
	movl	-8(%rbp), %edx
	movl	-4(%rbp), %eax
	leaq	.LC0(%rip), %rcx
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
