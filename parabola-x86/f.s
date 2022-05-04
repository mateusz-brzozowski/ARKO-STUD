section .text

;Global values:
;rdi - dest_bitmap
;rsi - width
;rdx - height
;r12 - draw_flag
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
    push r13

    mov r8, rsi
    sar r8, 1 ; int half_width = width / 2
    mov r9, rdx
    sar r9, 1 ; int half_height = height / 2

    mov r10, rdx    ; int i = (height - 1)
    dec r10

x_axis_loop:
    mov r13, r8    ; x = half_width

    ; draw_pixel
    mov rbx, rsi    ; temp_width = width

    lea rbx, [rbx + rbx*2]  ; width = width * 3
    add rbx, 3  ; width = width + 3
    and rbx, 0xFFFFFFFFFFFFFFFC ; width&~3
    imul rbx, r10   ; height = height * y

    lea r13, [r13 + r13*2]  ; x = x * 3
    add rbx, r13    ; width = width + x
    add rbx, rdi    ; width = width + bmp
    add rbx, 54 ; width = width + 54

    mov word[rbx], 0x00 ; rbx* = 0x00
    mov byte[rbx+2], 0x00   ; rbx*+2 = 0x00

    dec r10         ; i--
    jnz x_axis_loop

    mov r10, rsi    ; int i = (width - 1)
    dec r10

y_axis_loop:
    mov r13, r10    ; x = i

    ; draw_pixel
    mov rbx, rsi    ; temp_width = width

    lea rbx, [rbx + rbx*2]  ; width = width * 3
    add rbx, 3  ; width = width + 3
    and rbx, 0xFFFFFFFFFFFFFFFC ; width&~3
    imul rbx, r9   ; height = height * y

    lea r13, [r13 + r13*2]  ; x = x * 3
    add rbx, r13    ; width = width + x
    add rbx, rdi    ; width = width + bmp
    add rbx, 54 ; width = width + 54

    mov word[rbx], 0x00 ; rbx* = 0x00
    mov byte[rbx+2], 0x00   ; rbx*+2 = 0x00

    dec r10         ; i--
    jnz y_axis_loop

    mov rax, __float64__(-0.5)
    movq xmm6, rax  ; x = -0.5
    mulsd xmm6, xmm1    ; x = -0.5b
    divsd xmm6, xmm0    ; x = -0.5b/a
    movq xmm10, xmm6    ; p = x
    addsd xmm10, xmm10  ; p = 2p

    ; count y
    movq xmm7, xmm0 ; y = a
    mulsd xmm7, xmm6    ; y = ax
    mulsd xmm7, xmm6    ; y = ax^2
    movq xmm8, xmm1 ; tmp = b
    mulsd xmm8, xmm6    ; tmp = bx
    addsd xmm7, xmm8    ; y = ax^2 + bx
    addsd xmm7, xmm2    ; y = ax^2 + bx + c

draw_loop:
    xor r12, r12    ; clear draw flag

    ; offset x nad y
    cvttsd2si r13, xmm6 ; (int)x
    add r13, r8    ; x + half_width
    cvttsd2si r11, xmm7 ; (int)y
    add r11, r9    ; y + height

    ; draw_pixel of right arm
    mov rbx, rsi    ; temp_width = width
    mov rcx, rdx    ; temp_height = height

    cmp r13, rbx    ; x >= width
    jae reflection

    cmp r11, rcx    ; y >= height
    jae reflection

    lea rbx, [rbx + rbx*2]  ; width = width * 3
    add rbx, 3  ; width = width + 3
    and rbx, 0xFFFFFFFFFFFFFFFC ; width&~3
    imul rbx, r11   ; height = height * y

    lea r13, [r13 + r13*2]  ; x = x * 3
    add rbx, r13    ; width = width + x
    add rbx, rdi    ; width = width + bmp
    add rbx, 54 ; width = width + 54

    mov word[rbx], 0x00 ; rbx* = 0x00
    mov byte[rbx+2], 0x00   ; rbx*+2 = 0x00
    mov r12, 1  ; set r12 1

    ; f(-x) reflection of the function about the y axis
reflection:
    movq xmm8, xmm6 ; tmp_x = x
    movq xmm9, xmm10    ; tmp_p = 2p
    subsd xmm9, xmm8    ; tmp_p = 2p - x
    cvttsd2si r13, xmm9 ; (int)x
    add r13, r8    ; x + half_width

    ; draw_pixel of left arm
    mov rbx, rsi    ; temp_width = width
    mov rcx, rdx    ; temp_height = height

    cmp r13, rbx    ; x >= width
    jae next_values

    cmp r11, rcx    ; y >= height
    jae next_values

    lea rbx, [rbx + rbx*2]  ; width = width * 3
    add rbx, 3  ; width = width + 3
    and rbx, 0xFFFFFFFFFFFFFFFC ; width&~3
    imul rbx, r11   ; height = height * y

    lea r13, [r13 + r13*2]  ; x = x * 3
    add rbx, r13    ; width = width + x
    add rbx, rdi    ; width = width + bmp
    add rbx, 54 ; width = width + 54

    mov word[rbx], 0x00 ; rbx* = 0x00
    mov byte[rbx+2], 0x00   ; rbx*+2 = 0x00
    mov r12, 1  ; set r12 1

next_values:
    ; count next x
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

    ; count next y
    movq xmm7, xmm0 ; y = a
    mulsd xmm7, xmm6    ; y = ax
    mulsd xmm7, xmm6    ; y = ax^2
    movq xmm8, xmm1 ; tmp = b
    mulsd xmm8, xmm6    ; tmp = bx
    addsd xmm7, xmm8    ; y = ax^2 + bx
    addsd xmm7, xmm2    ; y = ax^2 + bx + c

    test r12, r12   ; check if pixel is drawn
    ja draw_loop    ; if yes, draw next

    pop r12
    pop r13
    ret