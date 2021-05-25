section .text

global f
f:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]    ;addres of img header (1)
    mov ebx, [eax+18]   ;width of img
    mov ecx, [ebp+16]   ;y to ecx

    lea ebx, [ebx + ebx*2]  ;ebx = ebx * 3
    ;imul ebx, 3
    add ebx, 3  ;+=3
    and ebx, 0xFFFFFFFC ;& ~3
    imul ebx, ecx   ;ebx = ebx * ecx

    mov edx, [ebp+12]   ;x to edx (2)
    lea edx, [edx + edx*2]
    ;imul edx, 3
    add ebx, edx
    add ebx, eax
    add ebx, 54

    mov edx, [ebp+20]   ;color to edx
    mov [ebx], dx   ;move 2 bytes to ebx (RG)
    shr edx, 16     ;shift right
    mov [ebx+2], dl ;move last byte of color (B)

    mov esp, ebp
    pop ebp
    ret