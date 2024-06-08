.data
	display: .space 1024
	
.text
	li $t0, 0xffffff
	li $t1, 0
	
	fill:
	sw $t0, display($t1)
	addi $t1, $t1, 4
	beq $t1, 1024, lineas
	j fill
	
	lineas:
	li $t0, 0x000000
	li $t1, 320
	li $t2, 640
	horizontal:
	sw $t0, display($t1)
	sw $t0, display($t2)
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bge $t1, 383, listoh
	j horizontal
	
	listoh:
	li $t0, 0x000000	
	li $t1, 20
	li $t2, 40
	
	vertical:
	sw $t0, display($t1)
	sw $t0, display($t2)
	addi $t1, $t1, 64
	addi $t2, $t2, 64
	bge $t2, 1004, listov
	j vertical
	listov:
	
	fin:
	li $v0, 10 
	syscall
