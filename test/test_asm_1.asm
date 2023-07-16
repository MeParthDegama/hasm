%bits 64

%text

$start:
  mov rax, 1       
  mov rdi, 1        ;   STDOUT_FILENO,   
  mov rsi, $msg;      ;   "Hello, world!\n",
  mov rdx, 14   ;   sizeof("Hello, world!\n")
  syscall           ; );

  mov rax, 60       ; exit(
  mov rdi, 0        ;   EXIT_SUCCESS
  syscall           ; );

%data

  $msg: db "Hello, world!", "10
