global _start
section .text
_start:
	; print hello world
	mov rax,0x1
	mov rdi,0x1
	mov rsi,hello
	mov rdx,0xb
	syscall
	mov rax,60
	mov rdi,69
	syscall


section .data

	hello: db'Hello World'
