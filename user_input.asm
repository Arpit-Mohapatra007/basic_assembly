global _start

section .text

_start:
	mov rax,1
	mov rdi,1
	mov rsi,wlcm_msg
	mov rdx,msg_len
	syscall
user_input:
	mov rax,0
	mov rdi,0
	mov rsi,input
	mov rdx,100
	syscall
	mov rbx,rax
printing_hello:
	mov rax,1
	mov rdi,1
	mov rsi,hello
	mov rdx,hel_len
	syscall
printing_userinput:
	mov rax,1
	mov rdi,1
	mov rsi,input
	mov rdx,rbx
	syscall
exit:
	mov rax,60
	mov rdi,69
	syscall


section .data
	wlcm_msg: db'Enter your name: '
	msg_len: equ $-wlcm_msg
	hello: db'Hello!'
	hel_len: equ $-hello
section .bss
	input: resb 100
