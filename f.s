section .text

;rdi - dest_bitmap
;xmm0 - a
;xmm1 - b
;xmm2 - c
;xmm3 - s

;xmm6 - x
;xmm7 - y

global f
f:


    cvttsd2si rsi, xmm6 ; (int)x
    cvttsd2si rdx, xmm7 ; (int)y
    ;set_pixel(rdi - bmp_buffer, rsi - x, rdx - y);
    call set_pixel
    ;xmm6 - x(xmm6 - new_x,xmm3 - s,xmm0 - a,xmm1 - b);
    call x
    ;xmm7 - y(xmm0 - a,xmm1 - b,xmm2 - c,xmm6 - new_x);
    call y
    ret

global x
x:
    addsd xmm2, xmm2    ;xmm1 = 2a
    mulsd xmm2, xmm0    ;xmm1 = 2ax
    addsd xmm2, xmm3    ;xmm1 = 2ax+b
    mulsd xmm2, xmm2    ;xmm1 = (2ax+b)^2

    mov rax, __float64__(1.0)
    movq xmm3, rax

    addsd xmm2, xmm3    ;xmm1 = (2ax+b)^2 + 1
    sqrtsd xmm2, xmm2   ;xmm1 = sqrt((2ax+b)^2 + 1))
    divsd xmm1, xmm2    ;xmm3 = s / xmm1
    addsd xmm0, xmm1    ;xmm0 = new x !
    ret

global y
y:
    ; y = ax^2 + bx + c
    ;
    mulsd xmm0, xmm3
    mulsd xmm0, xmm3
    mulsd xmm1, xmm3
    addsd xmm0, xmm1
    addsd xmm0, xmm2
    ret

;rdi - bmp_
;rsi - x
;rdx - y

global set_pixel
set_pixel:
    xor rax, rax
    movsx rbx, dword[rdi+18]   ;move width of img to rbx
    movsx rcx, dword[rdi+22]    ;move height of img to rcx
    cmp rsi, rbx
    ja exit
    cmp rdx, rcx
    ja exit

    lea rbx, [rbx + rbx*2]  ;ebx = ebx * 3
    ;imul rbx, 3
    add rbx, 3  ;+=3
    and rbx, 0xFFFFFFFFFFFFFFFC ;& ~3
    imul rbx, rdx   ;ebx = ebx * ecx

    lea rsi, [rsi + rsi*2]
    ;imul rsi, 3
    add rbx, rsi
    add rbx, rdi
    add rbx, 54

    mov rax, 1
    mov word[rbx], 0x00
    mov byte[rbx+2], 0x00

exit:
    ret