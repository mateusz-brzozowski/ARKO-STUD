	.data
	#Constant CORDIC value 1/K multiplied by scale
CORDIC:	.word 0x26DD3B6A
	#Size of precomputed lookup table
L_TABLE_SIZE: 	.word 30
	#Precomputed lookup table
L_TABLE:	.word 0x20000000, 0x12E4051D, 0x09FB385B, 0x051111D4, 0x028B0D43
	.word 0x0145D7E1, 0x00A2F61E, 0x00517C55, 0x0028BE53, 0x00145F2E
	.word 0x000A2F98, 0x000517CC, 0x00028BE6, 0x000145F3, 0x0000A2F9
	.word 0x0000517C, 0x000028BE, 0x0000145F, 0x00000A2F, 0x00000517
	.word 0x0000028B, 0x00000145, 0x000000A2, 0x00000051, 0x00000028
	.word 0x00000014, 0x0000000A, 0x00000005, 0x00000002, 0x00000001

PROMPT_INPUT:	.asciiz "Enter an angle between -1/2 and 1/2, multiplied by 2^8\n"
PROMPT_OUTPUT:	.asciiz "Results multiplied by 2^30:\n"
PORMPT_SIN:	.asciiz "sin = "
PROMPT_COS:	.asciiz "\ncos = "

	.text
	.globl main
main:
	li $v0, 4
	la $a0, PROMPT_INPUT
	syscall
	
	li $v0, 5		
	syscall
	
	blt $v0, -128, main
	bgt $v0, 128, main
cordic:
	sll $t5, $v0, 23	#int z = theta, shifted by 23;
	lw $t0, CORDIC		#int x = CORDIC;
	li $t1, 0		#int y = 0;
	li $t2, 0		#int i = 0;
	la $t3, L_TABLE		#Load adress of first table element
	
	#for (i; i < L_TABLE_SIZE; ++i)
for:
	srav $s0, $t1, $t2	#int tx = y >> i;
	srav $s1, $t0, $t2	#int ty = x >> i;
	lw $s2, ($t3)		#int tz = L_TABLE[i];
	
	bgez $t5, else		#if (z >= 0)
	
	add $t0, $t0, $s0	#x += tx;
	sub $t1, $t1, $s1	#y -= ty;
	add $t5, $t5, $s2	#z += tz;
	b end_for		
else:
	sub $t0, $t0, $s0	#x -= tx;
	add $t1, $t1, $s1	#y += ty;
	sub $t5, $t5, $s2	#z -= tz;
end_for:
	addiu $t2, $t2, 1	#i++
	addiu $t3, $t3, 4	#L_TABLE[i]++
	
	lw $s4, L_TABLE_SIZE
	bne $t2, $s4, for	#~i < L_TABLE_SIZE
	move $t4, $t5
	
exit:
	li $v0, 4
	la $a0, PROMPT_OUTPUT
	syscall

	li $v0, 4
	la $a0, PORMPT_SIN
	syscall
		
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, PROMPT_COS
	syscall
		
	li $v0, 1
	move $a0, $t0
	syscall

	li $v0, 10
	syscall
