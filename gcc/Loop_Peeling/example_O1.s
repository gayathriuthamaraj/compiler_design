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
	subq	$72, %rsp
	.seh_stackalloc	72
	.seh_endprologue
	call	__main
	pxor	%xmm0, %xmm0
	movups	%xmm0, 32(%rsp)
	movups	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rdx
	movl	$0, %eax
	jmp	.L4
	.p2align 5
.L2:
	movl	$0, (%rdx)
	addl	$1, %eax
	addq	$4, %rdx
.L4:
	testl	%eax, %eax
	jle	.L2
	movl	%eax, %ecx
	addl	-4(%rdx), %ecx
	movl	%ecx, (%rdx)
	addl	$1, %eax
	cmpl	$8, %eax
	je	.L3
	addq	$4, %rdx
	jmp	.L4
.L3:
	movl	52(%rsp), %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	movl	$0, %eax
	addq	$72, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev13, Built by MSYS2 project) 15.2.0"
