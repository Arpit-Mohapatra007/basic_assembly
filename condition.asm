global main

section .text

main:
wlcm:
	mov rax,1
	mov rdi,1
	mov rsi,welcome_msg
	mov rdx,length_wlcm
	syscall

user_input:
	mov rax,0
	mov rdi,0
	mov rsi,user_key
	mov rdx,64
	syscall
	mov rbx,rax

cmp_key:
	cmp rbx,length_key
	jne access_denied
	mov rsi,key
	mov rdi,user_key
	mov rcx,length_key
	cld
	repe cmpsb
	je access_granted
	jne access_denied

access_denied:
	mov rax,1
	mov rdi,2
	mov rsi,access_denied_msg
 	mov rdx,length_denied_msg
	syscall
	jmp _exit
access_granted:
	mov rax,1
        mov rdi,1
        mov rsi,access_granted_msg
        mov rdx,length_granted_msg
	syscall
_exit:
	mov rax,60
	mov rdi,0
	syscall
section .data
	welcome_msg: db "Enter Key:"
	length_wlcm: equ $-welcome_msg
	access_denied_msg: db "Access Denied!",0xa
	length_denied_msg: equ $-access_denied_msg
	access_granted_msg: db "Access Granted!",0xa
	length_granted_msg: equ $-access_granted_msg
	key: db "arpit",0xa
	length_key: equ $-key
section .bss
	user_key: resb 64
