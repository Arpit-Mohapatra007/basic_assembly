%include "util.asm"
global _start

section .text

_start:
	mov rdi,msg
	call printstr
	call readint
	mov [user_input],rax
	mov r12,1
multiply:
	mov rbx,[user_input]
	imul rbx,r12
	mov rdi,rbx
	call printint
	call endl
	add r12,1
	cmp r12,11
	jne multiply
	call exit0
	
section .data
	msg: db "Enter Number:",0
	
section .bss
	user_input: resb 8
	
