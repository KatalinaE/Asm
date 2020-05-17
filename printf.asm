;===========================================================================================
;     nasm -felf32 printf.asm && cc -o printf -m32 printf.o && ./printf
;===========================================================================================

section .text

global main
main:
    push ebp
    mov ebp, esp
    
    push dword 127
    push dword '!'
    push dword 100
    push dword 3802
    push dword arg
    push dword test_d
    
    call mprintf
    add esp, 18h
    
    xor eax, eax
    leave
    ret
    
;===========================================================================================
;Works in accordance with the cdecl agreement,
;                                   processes %[b, c, d, o, s, x] as a standard printf.
;===========================================================================================
global mprintf
mprintf:
    push ebp
    mov ebp, esp
    
    push edi
    push esi
    push ebx
    
    mov ebx, buff
    
    lea edi, [ebp + 08h]
    mov esi, [edi]
    add edi, 04h 
    
    jmp .check
    
    .next:    
    cmp ecx, '%'
    je .qualifiers
    
    .direct_print:
    call .putc
    jmp .continue
    
    .qualifiers:
    inc esi
    movzx ecx, byte [esi]
    
    cmp ecx, '%'
    je .direct_print
    
    cmp ecx, 'b'
    jb print_error
    cmp ecx, 'x'
    ja print_error
    
    mov eax, ecx
    sub eax, 'b'
    mov eax, [jump_table + 4 * eax]
    call eax 
    
    .continue:
    inc esi
    
    .check:
    movzx ecx, byte [esi]
    cmp ecx, 00h
    jnz .next
                  
    .end:
    cmp ebx, buff
    je .skip
    mov edx, ebx
    sub edx, buff 
    call .putBuff     
    
    .skip:
    pop ebx
    pop esi
    pop edi
    
    leave
    ret
    
;===========================================================================================
; Subfunction that implements the safe placement of a character in mprintf's buffer.
; Parameters: ecx - symbol
;             ebx - iteration pointer to the buffer
; Return: ebx - new iteration pointer to the buffer
;===========================================================================================
.putc:
    cmp ebx, endBuff
    jne .insert 

    push ecx
    
    mov edx, BUFF_SIZE
    call .putBuff
    mov ebx, buff
    
    pop ecx
              
    .insert:
    mov byte [ebx], cl
    inc ebx

    ret

;===========================================================================================
; Subfunction that implements mprintg's buffer output to the standard output stream.
; Parameters: edx - buffer length
; Spoils: eax, ebx, ecx
;===========================================================================================
.putBuff:
    mov ecx, buff
    mov eax, WRITE   
    mov ebx, STDOUT           
    int SYS
    ret

;===========================================================================================
; A function that reports an error parsing a format string and terminates the program.
;===========================================================================================    
print_error:
    mov eax, esi
    sub eax, [ebp + 08h]
    
    push eax
    push ecx
    push error
    call mprintf  
    add esp, 0Ch 
    
    mov eax, EXIT              
    mov ebx, ERROR_CODE              
    int SYS
    ret

print_binary:
    mov edx, 01h
    jmp print
    
print_octal:
    mov edx, 03h
    jmp print
    
print_heximal:
    mov edx, 04h

;===========================================================================================
; Subfunction that prints a number in the 2^edx system in the buffer.
; Parameters: edx - degree
;             edi - pointer to number
;             ebx - iteration pointer to the buffer
; Return: ebx - new iteration pointer to the buffer
;         edi - pointer to next number
;===========================================================================================    
    print:
    mov eax, [edi]
    add edi, 04h
    push edi
    mov edi, edx
    
    mov edx, eax
    push esi
    mov esi, 01h
    mov ecx, edi
    shr edx, cl
    
    cmp edx, 00h
    jz .print
    
    .find:
    shl esi, cl
    cmp esi, edx
    jbe .find
    
    .print:
    xor edx, edx
    div esi
    mov ecx, edi
    shr esi, cl
    movzx ecx, byte [hex + eax]
    mov eax, edx
    call mprintf.putc
    cmp esi, 00h
    jnz .print
    
    pop esi
    pop edi
    
    ret        

;===========================================================================================
; Subfunction that prints a number in the 10 system in the buffer.
; Parameters: edi - pointer to number
;             ebx - iteration pointer to the buffer
; Return: ebx - new iteration pointer to the buffer
;         edi - pointer to next number
;===========================================================================================    
print_decimal:
    mov eax, [edi]
    add edi, 04h
    
    push esi
    push edi
    mov edi, 10d
    cmp eax, 00h
    jnl .positive
    
    mov ecx, '-'
    call mprintf.putc
    neg eax
    
    .positive:
    mov ecx, eax
    xor edx, edx
    div edi
    mov edx, 01h
    cmp eax, 00h
    jz .print
    
    .find:
    imul edx, edi
    cmp edx, eax 
    jbe .find
    
    mov esi, edx
    .print:
    mov eax, ecx
    xor edx, edx
    div esi
    lea ecx, ['0' + eax]
    call mprintf.putc
    mov ecx, edx
    
    xor edx, edx
    mov eax, esi
    div edi
    mov esi, eax
    
    cmp esi, 00h
    jnz .print
    
    pop edi
    pop esi
    ret
    
;===========================================================================================
; Subfunction that prints a char in the buffer.
; Parameters: edi - pointer to char with integer promotion
;             ebx - iteration pointer to the buffer
; Return: ebx - new iteration pointer to the buffer
;         edi - pointer to next number
;===========================================================================================
print_char:
    mov ecx, [edi]
    add edi, 04h
    call mprintf.putc
    ret 

;===========================================================================================
; Subfunction that safty prints a string in the buffer.
; Parameters: edi - pointer to string
;             ebx - iteration pointer to the buffer
; Return: ebx - new iteration pointer to the buffer
;         edi - next pointer
;===========================================================================================
print_string:
    mov edx, [edi]
    add edi, 04h
    
    .while:
    movzx ecx, byte [edx]
    cmp ecx, 00h
    jz .end
    call mprintf.putc
    inc edx
    jmp .while
    
    .end:
    ret         
    
section .data
    STDOUT equ 01h
    WRITE equ 04h
    BUFF_SIZE equ 1000h
    EXIT equ 01h
    ERROR_CODE equ 01h
    SYS equ 80h
    
    error db "Founded %c(%d) - undefined behaviour", 00h
    hex db "0123456789ABCDEF"
    
    hello db "Hello world", 00h
    test_d db "I %s %x. %d%%%c%b", 0Ah, 00h
    arg db "love", 00h
    
jump_table  dd print_binary              ; 'b'
            dd print_char                ; 'c'
            dd print_decimal             ; 'd'
            times 'o'-'e' dd print_error ; ['e'; 'o')
            dd print_octal               ; 'o'
            times 's'-'p' dd print_error ; ['p'; 's')
            dd print_string              ; 's'
            times 'x'-'t' dd print_error ; ['t'; 'x')
            dd print_heximal             ; 'x'

section .bss
    buff resb BUFF_SIZE
    endBuff resb 00h