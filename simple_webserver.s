.intel_syntax noprefix

.bss

    request: .zero 1024
    response: .zero 256

.data

    message: .ascii "HTTP/1.0 200 OK\r\n\r\n"

.global _start

.section .text

_start:

    # Create Socket
    mov rdi,2
    mov rsi,1
    mov rdx,0
    mov rax,41
    syscall

    # Save socket fd
    mov r10,rax

    # Setup sockaddr_in on stack
    sub rsp,16
    mov word ptr [rsp],2
    mov word ptr [rsp+2],0x5000 # "80" in big endian
    mov dword ptr [rsp+4],0
    mov qword ptr [rsp+8],0

    # Bind socket
    mov rdi,r10
    mov rsi,rsp
    mov rdx,16
    mov rax,49
    syscall

    # Listen
    mov rdi,r10
    mov rsi,0
    mov rax,50
    syscall

accept_loop:
   
    # Accept
    mov rdi,r10
    xor rsi,rsi
    xor rdx,rdx
    mov rax,43
    syscall

    # Save client socket fd
    mov r12,rax

    # Fork
    mov rax,57
    syscall
   
    # Check if child (rax == 0) or parent (rax > 0)
    test rax,rax
    jz child_process
   
    # Parent Process: Close client socket
    mov rdi,r12
    mov rax,3
    syscall

    jmp accept_loop

child_process:

    # Child Process: Close listening socket
    mov rdi,r10
    mov rax,3
    syscall

    # Read HTTP request
    mov rdi,r12
    lea rsi,[rip+request]
    mov rdx,1024
    mov rax,0
    syscall
   
    # Save the total bytes of request
    mov r13,rax
   
    # If read failed or empty, send response and exit
    cmp r13,0
    jle send_response_and_exit
   
    # Parse request method
    lea r14,[rip+request]
    mov eax,dword ptr [r14]
    # Check for GET
    cmp eax,0x20544547 # "GET " in little endian
    je GET
    # Check for POST
    cmp eax,0x54534f50 # "POST" in little endian
    je POST
    # Unknown Method - still send response
    jmp send_response_and_exit

GET:

    # Request format: "GET /path HTTP/1.1\r\n..."
   
    lea rdi,[rip+request]
    add rdi,4 # Skip "GET " (4 bytes)
    mov r15,r13
    sub r15,4

find_space:

    # Find end of path (space or \r)

    cmp r15,0
    jle send_response_and_exit
   
    mov al,byte ptr [rdi]
    cmp al,' '
    je get_end_path
    cmp al,13
    je get_end_path
    cmp al,0
    je send_response_and_exit
   
    inc rdi
    dec r15
    jmp find_space

get_end_path:
   
    mov byte ptr [rdi],0 # NULL-terminate the path
   
    lea rbx,[rip+request+4] # Pointer to path after "GET "
    xor r15,r15

    # Open the file
    mov rdi,rbx
    xor rsi,rsi
    xor rdx,rdx
    mov rax,2
    syscall

    # Save file fd
    mov r14,rax
   
    # Check if open failed
    cmp r14,0
    je send_http_header_only

    # Read file content
    mov rdi,r14
    lea rsi,[rip+response]
    mov rdx,256
    mov rax,0
    syscall
   
    # Save number of bytes read
    mov r15,rax
    # Close file
    mov rdi,r14
    mov rax,3
    syscall
   
send_http_header_only:

    # Send HTTP response header
    mov rdi,r12
    lea rsi,[rip+message]
    mov rdx,19
    mov rax,1
    syscall

    # Send file content if read was successful
    cmp r15,0
    jle close_and_exit
   
    mov rdi,r12
    lea rsi,[rip+response]
    mov rdx,r15
    mov rax,1
    syscall

    jmp close_and_exit

POST:

    # Request format: "POST /path HTTP/1.1\r\n...headers...\r\n\r\nbody"
   
    lea rdi,[rip+request]
    add rdi,5 # Skip "POST " (5 bytes)
    mov rsi,rdi
    mov r15,r13
    sub r15,5

scan_path:

    # Find end of path
    cmp r15,0
    jle send_response_and_exit
   
    mov al,byte ptr [rsi]
    cmp al,' '
    je post_end_path
    cmp al,13
    je post_end_path
    cmp al,0
    je send_response_and_exit
   
    inc rsi
    dec r15
    jmp scan_path
   
post_end_path:
   
    mov byte ptr [rsi],0 # NULL-terminate the path
   
    lea rbx,[rip+request+5] # Pointer to path after "POST "

    # Open/Create the file (O_CREAT | O_WRONLY = 65)
    mov rdi,rbx
    mov rsi,65
    mov rdx,0777
    mov rax,2
    syscall

    # Save file fd
    mov r14,rax
   
    # Check if open failed
    cmp r14,0
    jl send_response_and_exit

    # Find the body (after \r\n\r\n)
    lea rsi,[rip+request]
    mov r15,r13
   
find_body:

    cmp r15,4
    jl close_file_post
   
    mov eax,dword ptr [rsi]
    cmp eax,0x0a0d0a0d # "\r\n\r\n" in little endian
    je found_body
   
    inc rsi
    dec r15
    jmp find_body

found_body:
   
    add rsi,4 # Skip past \r\n\r\n
    sub r15,4 # r15 now has body length
   
    # Write body to file if there's data
    cmp r15,0
    jle close_file_post
   
    mov rdi,r14
    mov rdx,r15
    mov rax,1
    syscall

close_file_post:

    # Close file
    mov rdi,r14
    mov rax,3
    syscall

send_response_and_exit:

    # Send HTTP response
    mov rdi,r12
    lea rsi,[rip+message]
    mov rdx,19
    mov rax,1
    syscall

close_and_exit:

    # Close client socket
    mov rdi,r12
    mov rax,3
    syscall

    # Exit child process
    mov rdi,0
    mov rax,60
    syscall
