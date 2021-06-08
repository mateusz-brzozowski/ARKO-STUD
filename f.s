section .text

;Global values:
;rdi - dest_bitmap
;rsi - width    (Only Function Argument)
;rdx - height   (Only Function Argument)
;xmm0 - a
;xmm1 - b
;xmm2 - c
;xmm3 - s
;xmm6 - x
;xmm7 - y
;xmm10 - 2p

;Temporary values:
;xmm8 - tmp_x
;xmm9 - tmp_p
;r10 - iterator

global f
f:
    push r12
    mov r10, rdx
    cmp r10, rsi
    cmovl r10, rsi  ; int i = width > height

    mov r8, rsi
    shr r8, 1 ; int half_width = width / 2
    mov r9, rdx
    shr r9, 1 ; int half_height = height / 2

axis_loop:

    mov rsi, r8    ; x = half_width
    mov rdx, r10    ; y = i
    call draw_pixel  ; draw_pixel(dest_bitmap, x, y)

    mov rsi, r10    ; x = i
    mov rdx, r9    ; y = height
    call draw_pixel  ; draw_pixel(dest_bitmap, x, y)

    dec r10         ; i--
    test r10, r10   ; i > 0
    jnz axis_loop

    mov rax, __float64__(-0.5)
    movq xmm6, rax  ; x = -0.5
    mulsd xmm6, xmm1    ; x = -0.5b
    divsd xmm6, xmm0    ; x = -0.5b/a
    movq xmm10, xmm6    ; p = x
    addsd xmm10, xmm10  ; p = 2p

    call y  ;get first y value

draw_loop:
    cvttsd2si rsi, xmm6 ; (int)x
    add rsi, r8    ; x + half_width
    cvttsd2si rdx, xmm7 ; (int)y
    add rdx, r9    ; y + height
    call draw_pixel  ; pixel of right arm

    movq xmm8, xmm6 ; tmp_x = x
    movq xmm9, xmm10    ; tmp_p = 2p
    subsd xmm9, xmm8    ; tmp_p = 2p - x
    cvttsd2si rsi, xmm9 ; (int)x
    add rsi, r8    ; x + half_width
    call draw_pixel  ; pixel of left arm

    call x  ; count next x
    call y  ; count next y

    test r12, r12   ; check if pixel is drawn
    ja draw_loop    ; if yes, draw next

    pop r12
    ret

;Arguments:
;xmm6 - x
;xmm0 - a
;xmm1 - b
;xmm3 - s

;Temporary values:
;xmm8 - tmp
;xmm9 - tmp_value

;'Return':
;xmm6
x:
    movq xmm8, xmm0 ; tmp = a
    addsd xmm8, xmm8    ;tmp = 2a
    mulsd xmm8, xmm6    ;tmp = 2ax
    addsd xmm8, xmm1    ;tmp = 2ax+b
    mulsd xmm8, xmm8    ;tmp = (2ax+b)^2

    mov rax, __float64__(1.0)
    movq xmm9, rax  ;tmp_value = 1.0

    addsd xmm8, xmm9    ;tmp = (2ax+b)^2 + 1
    sqrtsd xmm8, xmm8   ;tmp = sqrt((2ax+b)^2 + 1))
    movq xmm9, xmm3 ; tmp_value = s
    divsd xmm9, xmm8    ;tmp_value = s / tmp
    addsd xmm6, xmm9    ;x = old_x + tmp_value
    ret


;Arguments:
;xmm6 - x
;xmm0 - a
;xmm1 - b
;xmm2 - c

;Temporary values:
;xmm8 - tmp

;'Return':
;xmm7
y:
    movq xmm7, xmm0 ; y = a
    mulsd xmm7, xmm6    ; y = ax
    mulsd xmm7, xmm6    ; y = ax^2
    movq xmm8, xmm1 ; tmp = b
    mulsd xmm8, xmm6    ; tmp = bx
    addsd xmm7, xmm8    ; y = ax^2 + bx
    addsd xmm7, xmm2    ; y = ax^2 + bx + c
    ret

;Arguments:
;rdi - bmp_plot
;rsi - x
;rdx - y

;Temporary values:
;rbx - width
;rcx - height

;'Return':
;rdi
;r12

draw_pixel:
    xor r12, r12    ; clear r12
    movsx rbx, dword[rdi+18]    ; move width of img to rbx
    movsx rcx, dword[rdi+22]    ; move height of img to rcx
    cmp rsi, rbx    ; x > width
    ja exit
    cmp rdx, rcx    ; y > height
    ja exit

    lea rbx, [rbx + rbx*2]  ; width = width * 3
    add rbx, 3  ; width = width + 3
    and rbx, 0xFFFFFFFFFFFFFFFC ; width&~3
    imul rbx, rdx   ; height = height * y

    lea rsi, [rsi + rsi*2]  ; x = x * 3
    add rbx, rsi    ; width = width + x
    add rbx, rdi    ; width = width + bmp
    add rbx, 54 ; width = width + 54

    mov r12, 1  ; set r12 1
    mov word[rbx], 0x00 ; rbx* = 0x00
    mov byte[rbx+2], 0x00   ; rbx*+2 = 0x00

exit:
    ret