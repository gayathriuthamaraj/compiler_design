	.file	"example_1_1.c"
	.text
	.section .rdata,"dr"
.LC0:
	.ascii "arr[5] = %d\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$80, %rsp
	.seh_stackalloc	80
	.seh_endprologue
	call	__main
	pxor	%xmm0, %xmm0
	movups	%xmm0, -48(%rbp)
	movups	%xmm0, -32(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L2
.L5:
	cmpl	$0, -4(%rbp)
	jle	.L3
	movl	-4(%rbp), %eax
	subl	$1, %eax
	cltq
	movl	-48(%rbp,%rax,4), %edx
	movl	-4(%rbp), %eax
	addl	%eax, %edx
	movl	-4(%rbp), %eax
	cltq
	movl	%edx, -48(%rbp,%rax,4)
	jmp	.L4
.L3:
	movl	-4(%rbp), %eax
	cltq
	movl	$0, -48(%rbp,%rax,4)
.L4:
	addl	$1, -4(%rbp)
.L2:
	cmpl	$7, -4(%rbp)
	jle	.L5
	movl	-28(%rbp), %eax
	leaq	.LC0(%rip), %rcx
	movl	%eax, %edx
	call	__mingw_printf
	movl	$0, %eax
	addq	$80, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
