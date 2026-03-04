	.file	"example_5.c"
	.text
	.globl	process
	.def	process;	.scl	2;	.type	32;	.endef
	.seh_proc	process
process:
	.seh_endprologue
	leal	(%rcx,%rcx), %eax
	addl	$100, %ecx
	testl	%edx, %edx
	cmovne	%ecx, %eax
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
	subq	$40, %rsp
	.seh_stackalloc	40
	.seh_endprologue
	call	__main
	movl	$110, %r8d
	movl	$20, %edx
	leaq	.LC0(%rip), %rcx
	call	__mingw_printf
	movl	$0, %eax
	addq	$40, %rsp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.ident	"GCC: (Rev8, Built by MSYS2 project) 15.2.0"
