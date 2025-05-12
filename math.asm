global main

section .text

main:

add:
	mov rax,2
	add rax,3

sub:
	mov rax,4
	sub rax,2

multiply:
	mov rax,6
	imul rax,rax,2

idiv:
	mov rdx,0
	mov rax,100
	mov rbx,2
	idiv rbx

_exit:
	mov rax,60
	mov rdi,0
	syscall
