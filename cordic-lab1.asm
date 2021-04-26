.data
	#Constant CORDIC value 1/K multiplied by scale
CORDIC:	.word 0x26DD3B6A
	#Scale to avoid non-integer constant variables 2^30
SCALE:	.word 0x40000000
	#Size of precomputed lookup table
L_TABLE_SIZE: 	.word 32
	#Precomputed lookup table
L_TABLE:	.word 0x3243F6A8, 0x1DAC6705, 0x0FADBAFC, 0x07F56EA6, 0x03FEAB76
	.word 0x01FFD55B, 0x00FFFAAA, 0x007FFF55, 0x003FFFEA, 0x001FFFFD
	.word 0x000FFFFF, 0x0007FFFF, 0x0003FFFF, 0x0001FFFF, 0x0000FFFF
	.word 0x00007FFF, 0x00003FFF, 0x00001FFF, 0x00000FFF, 0x000007FF
	.word 0x000003FF, 0x000001FF, 0x000000FF, 0x0000007F, 0x0000003F
	.word 0x0000001F, 0x0000000F, 0x00000008, 0x00000004, 0x00000002
	.word 0x00000001, 0x00000000

PROMPT_INPUT:	.asciiz "Enter an angle between -pi/2 and pi/2, multiplied by 2^30\n"
PROMPT_OUTPUT:	.asciiz "Results multiplied by 2^30:\n"
PORMPT_SIN:	.asciiz "sin = "
PROMPT_COS:	.asciiz "\ncos = "

	.text
	.globl main
main:
	li $v0, 4
	la $a0, PROMPT_INPUT
	syscall
	
	li $v0, 5		#int z = theta;
	syscall
	
	blt $v0, -1686629713, main
	bgt $v0, 1686629713, main
cordic:
	lw $t0, CORDIC		#int x = CORDIC;
	li $t1, 0		#int y = 0;
	li $t2, 0		#int i = 0;
	la $t3, L_TABLE		#Load adress of first table element
	
	#for (i; i < L_TABLE_SIZE; ++i)
for:
	srav $s0, $t1, $t2	#int tx = y >> i;
	srav $s1, $t0, $t2	#int ty = x >> i;
	lw $s2, ($t3)		#int tz = L_TABLE[i];
	
	bgez $v0, else		#if (z >= 0)
	
	add $t0, $t0, $s0	#x += tx;
	sub $t1, $t1, $s1	#y -= ty;
	add $v0, $v0, $s2	#z += tz;
	b end_for		
else:
	sub $t0, $t0, $s0	#x -= tx;
	add $t1, $t1, $s1	#y += ty;
	sub $v0, $v0, $s2	#z -= tz;
end_for:
	addiu $t2, $t2, 1	#i++
	addiu $t3, $t3, 4	#L_TABLE[i]++
	
	lw $s4, L_TABLE_SIZE
	bne $t2, $s4, for	#~i < L_TABLE_SIZE
	move $t4, $v0
	
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
