%include "util.asm"

global _start

section .text

_start:
	mov rdi,num1
	call printstr
	call readint
	mov [user_num1],rax   ;a
	mov rdi,num2
	call printstr
	call readint
	mov [user_num2],rax   ;b
	mov rdi,op
	call printstr
	mov rdi,user_op   ; operator
	mov rsi,2
	call readstr
compare:	
	mov r12,[user_op]
	cmp r12,0x2b
	je addition
	cmp r12,0x2d
	je subtraction
	cmp r12,0x2a
	je multiply
	cmp r12,0x2f
	je divide
	cmp r12,0x25
	je remainder
error:
	mov rdi,err
	call printstr
results:
	call endl
	call exit0

addition:
	mov rdi,result
	call printstr
	mov rdi,[user_num1]
	add rdi,[user_num2]
	call printint
	call results
subtraction:
	mov rdi,result
        call printstr
        mov rdi,[user_num1]
        sub rdi,[user_num2]
        call printint
	call results
multiply:
	mov rdi,result
        call printstr
        mov rdi,[user_num1]
        imul rdi,[user_num2]
        call printint
        call results
divide:
	mov rdi,result
        call printstr
	mov rdx,0
        mov rax,[user_num1]
        mov rbx,[user_num2]
	idiv rbx
	mov rdi,rax
        call printint
        call results
remainder:
	mov rdi,result
        call printstr
        mov rdx,0
        mov rax,[user_num1]
        mov rbx,[user_num2]
        idiv rbx
        mov rdi,rdx
        call printint
        call results
section .data
	num1: db "Enter Number 1:",0
	num2: db "Enter Number 2:",0
	num3: db "Enter Number 3:",0
	op: db "Enter operator to perform(+:ADDITION,-:SUBTRACTION,*:MULTIPLICATON,/:DIVIDE,%:REMAINDER):",0
	err:db"Operation not supported!",0
	result:db"Result is:",0
section .bss
	user_num1: resb 8
	user_num2: resb 8
	user_num3: resb 8
	user_op: resb 2
