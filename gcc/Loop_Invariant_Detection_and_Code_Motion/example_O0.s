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
	pushq	%rbp
	.seh_pushreg	%rbp
	subq	$448, %rsp
	.seh_stackalloc	448
	leaq	128(%rsp), %rbp
	.seh_setframe	%rbp, 128
	.seh_endprologue
	call	__main
	movl	$7, 312(%rbp)
	movl	$3, 308(%rbp)
	movl	$0, 316(%rbp)
	jmp	.L2
.L3:
	movl	312(%rbp), %eax
	imull	308(%rbp), %eax
	movl	%eax, %edx
	movl	316(%rbp), %eax
	addl	%eax, %edx
	movl	316(%rbp), %eax
	cltq
	movl	%edx, -96(%rbp,%rax,4)
	addl	$1, 316(%rbp)
.L2:
	cmpl	$99, 316(%rbp)
	jle	.L3
	movl	-56(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$448, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
