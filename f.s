section .text

;rdi - dest_bitmap
;xmm0 - a
;xmm1 - b
;xmm2 - c
;xmm3 - s

;xmm6 - x
;xmm7 - y
;xmm10 - p

global f
f:
    mov r10, 512

axis_loop:

    mov rsi, 256
    mov rdx, r10
    call set_pixel

    mov rsi, r10
    mov rdx, 256
    call set_pixel

    dec r10
    test r10, r10
    jnz axis_loop

    mov rax, __float64__(-0.5)
    movq xmm6, rax  ; x = -0.5
    mulsd xmm6, xmm1    ; x = -0.5b
    divsd xmm6, xmm0    ; x = -0.5b/a
    movq xmm10, xmm6
    addsd xmm10, xmm10  ; p = 2p

    call y

    mov r10, 500
draw_loop:

    cvttsd2si rsi, xmm6 ; (int)x
    add rsi, 256
    cvttsd2si rdx, xmm7 ; (int)y
    add rdx, 256
    call set_pixel

    movq xmm8, xmm6
    movq xmm9, xmm10
    subsd xmm9, xmm8
    cvttsd2si rsi, xmm9 ; (int)x
    add rsi, 256
    call set_pixel

    call x
    call y

    dec r10
    test r10, r10
    jnz draw_loop

    ret

;Global values:
;xmm0 - a
;xmm1 - b
;xmm3 - s
;xmm7 - y

;Temporary values:
;xmm6 - x(return)
;xmm8
;xmm9
global x
x:
    movq xmm8, xmm0
    addsd xmm8, xmm8    ;xmm1 = 2a
    mulsd xmm8, xmm6    ;xmm1 = 2ax
    addsd xmm8, xmm1    ;xmm1 = 2ax+b
    mulsd xmm8, xmm8    ;xmm1 = (2ax+b)^2

    mov rax, __float64__(1.0)
    movq xmm9, rax

    addsd xmm8, xmm9    ;xmm1 = (2ax+b)^2 + 1
    sqrtsd xmm8, xmm8   ;xmm1 = sqrt((2ax+b)^2 + 1))
    movq xmm9, xmm3
    divsd xmm9, xmm8    ;xmm3 = s / xmm1
    addsd xmm6, xmm9    ;xmm0 = new x !
    ret


;Global values:
;xmm0 - a
;xmm1 - b
;xmm2 - c
;xmm6 - x

;Temporary values:
;xmm7 - y (return)
;xmm8 - bx

; y = ax^2 + bx + c
y:
    movq xmm7, xmm0
    mulsd xmm7, xmm6
    mulsd xmm7, xmm6
    movq xmm8, xmm1
    mulsd xmm8, xmm6
    addsd xmm7, xmm8
    addsd xmm7, xmm2
    ret

;Temporary values:
;rdi - bmp_
;rsi - x
;rdx - y

set_pixel:
    xor rax, rax
    movsx rbx, dword[rdi+18]    ;move width of img to rbx
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