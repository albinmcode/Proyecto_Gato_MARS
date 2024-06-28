.data
	display: .space 1024
	casilla: .space 40
	colores_hex: .word 0x00ffb6, 0xfff700, 0x8300ff, 0xff2a00
	colores: .asciiz "Colores a escoger:\n1) Cian\n2) Amarillo\n3) Morado\n4) Rojo\n"
	j1: .asciiz "Jugador 1: "
	j2: .asciiz "Jugador 2: "
	seleccion: .asciiz "\nEscoja un numero de casilla [1, 9]: "
	resultado_msg: .asciiz "\n<//////////////>\nEl resultado es: "
	empate_msg: .asciiz "empate!\n"
	ganador_msg: .asciiz "ganador: Jugador "
	turno_j1: .asciiz "\n/-----------------/\nTurno del Jugador 1"
	turno_j2: .asciiz "\n/-----------------/\nTurno del Jugador 2"
	turno_actual: .asciiz "Turno actual: "
	turnos: .asciiz "Numero de turnos: "

.text
main:
	li $a1, 0xffffff            # Color inicial (blanco)
	jal crear_tablero           # Crear el tablero de juego
	la $s0, display($zero)      # Dirección base para la visualización
	jal casillas                # Inicializar las casillas
	jal juego
	j terminar_juego                   # Iniciar el juego
	j end                       # Terminar el programa

# Subrutina para crear el tablero de juego
crear_tablero:
	li $t1, 0
fill:
	sw $a1, display($t1)        # Rellenar el display con color blanco
	addi $t1, $t1, 4
	beq $t1, 1024, lineas       # Si se ha llenado el display, pasar a dibujar las líneas
	j fill
lineas:
	li $a1, 0x000000            # Color negro para las líneas
	li $t1, 320
	li $t2, 640
horizontal:
	sw $a1, display($t1)
	sw $a1, display($t2)
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bge $t1, 383, listoh
	j horizontal
listoh:
	li $t1, 20
	li $t2, 40
vertical:
	sw $a1, display($t1)
	sw $a1, display($t2)
	addi $t1, $t1, 64
	addi $t2, $t2, 64
	bge $t2, 1004, ret
	j vertical

# Subrutina para inicializar las casillas
casillas:
	addi $t0, $s0, 136
	addi $t2, $s0, 776
	la $t3, casilla

new_line: 
	addi $t1, $t0, 40
line:
	addi $t3, $t3, 4
	sw $t0, ($t3)
	addi $t0, $t0, 20
	ble $t0, $t1, line

	addi $t0, $t0, 260
	bgt $t0, $t2, ret
	j new_line

# Subrutina principal del juego
juego:
	move $t9, $ra
	jal perfil                  # Seleccionar colores para los jugadores
	li $s3, 0                   # Inicializar el número de turnos
	move $s4, $zero             # Inicializar el turno actual (0 para Jugador 1, 1 para Jugador 2)
	jal entrada                 # Empezar el primer turno
	move $ra, $t9
	j ret

# Subrutina para seleccionar el perfil de los jugadores
perfil:
	move $t3, $ra
	la $t1, colores_hex
	la $a0, colores
	li $v0, 4
	syscall

	la $a0, j1
	jal selec_color
	move $s1, $v1
segundo: 
	la $a0, j2
	jal selec_color
	beq $s1, $t0, segundo
	move $s2, $v1 
	move $ra, $t3
	j ret

# Subrutina para seleccionar el color de un jugador
selec_color:
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	sub $t0, $v0, 1
	mul $t0, $t0, 4
	add $t2, $t1, $t0   
	lw $v1, 0($t2)
	j ret

# Subrutina para gestionar la entrada del jugador
entrada:
	move $t8, $ra
	# Mostrar turno del jugador
	beq $s4, $zero, turno_jugador1
	la $a0, turno_j2
	li $v0, 4
	syscall
	j ejecutar_entrada

turno_jugador1:
	la $a0, turno_j1
	li $v0, 4
	syscall

ejecutar_entrada:
	# Rondas de jugadores
	la $a0, seleccion
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	mul $t1, $v0, 4 
	lw $t2, casilla($t1)
validez:
	lw $t3, ($t2)
	bne $t3, 0xffffff, entrada

	# Asignar color basado en el turno actual
	beq $s4, $zero, marcar_jugador1
	move $a1, $s2  # Color del Jugador 2
	j marcar

marcar_jugador1:
	move $a1, $s1  # Color del Jugador 1

marcar:
	sw $a1, ($t2)
	addi $t2, $t2, 4
	sw $a1, ($t2)
	addi $t2, $t2, 60
	sw $a1, ($t2)
	addi $t2, $t2, 4
	sw $a1, ($t2)

	# Incrementar el número de turnos
	addi $s3, $s3, 1

	# Cambiar turno
	xori $s4, $s4, 1  # Alternar entre 0 y 1 para los turnos
	jal gane
	move $ra, $t9
	j ret

# Subrutina para verificar si hay un ganador o un empate
gane:
	move $t7, $ra
	li $v1, 0
	jal verificar_ganador
	bnez $v1, acabar
	# Si el número de turnos es 9, declarar empate
	beq $s3, 9, acabar
	j entrada            # Continuar el juego si el número de turnos es menor a 9
	acabar: move $ra, $t7
	j ret

# Subrutina para verificar si hay un ganador
verificar_ganador:
	li $v0, 0  # Inicializar v0 a 0 (no hay ganador)

	# Verificar filas
	li $t0, 4 # primer direccion del space casillas vacia
	li $t1, 0
fila_loop:
	add $t2, $t0, $t1 
	lw $a3, casilla($t2) # direccion de primera casilla de la fila
	lw $a0, ($a3) # color primera casilla de la fila
	beq $a0, 0xffffff, next_fila
	addi $t2, $t2, 4
	lw $a3, casilla($t2) # direccion de segunda casilla
	lw $a1, ($a3) # color de segunda casilla
	addi $t2, $t2, 4
	lw $a3, casilla($t2) # direccion tercera casilla
	lw $a2, ($a3) # color tercera casilla
	beq $a0, $a1, fila_check1
	j next_fila

fila_check1:
	beq $a1, $a2, fila_ganador # fila del mismo color
	j next_fila

next_fila:
	addi $t1, $t1, 12 # siguiente fila
	blt $t1, 36, fila_loop 

	# Verificar columnas
	la $t0, casilla
	li $t1, 4
columna_loop:
	add $t2, $t0, $t1
	lw $a3, ($t2)
	lw $a0, ($a3)
	beq $a0, 0xffffff, next_columna
	addi $t2, $t2, 12
	lw $a3, ($t2)
	lw $a1, ($a3)
	addi $t2, $t2, 12
	lw $a3, ($t2)
	lw $a2, ($a3)
	beq $a0, $a1, columna_check1
	j next_columna

columna_check1:
	beq $a1, $a2, columna_ganador
	j next_columna

next_columna:
	addi $t1, $t1, 4
	ble $t1, 12, columna_loop

	# Verificar diagonales
	# Diagonal 1
	la $t0, casilla
	addi $t0, $t0, 4 # primer campo del space casilla vacio
	lw $a3, ($t0)
	lw $a0, ($a3)
	beq $a0, 0xffffff, diag2 #casilla vacia, no hay combinacion
	addi $t2, $t0, 16
	lw $a3, ($t2)
	lw $a1, ($a3)
	addi $t2, $t2, 16
	lw $a3, ($t2)
	lw $a2, ($a3)
	beq $a0, $a1, diag_check1
	j diag2

diag_check1:
	beq $a1, $a2, diagonal_ganador
	j diag2

	# Diagonal 2
diag2:
	addi $t0, $t0, 8 
	lw $a3, ($t0)
	lw $a0, ($a3)
	beq $a0, 0xffffff, verificar_ganador_no_ganador #casilla vacia, no hay combinacion
	addi $t2, $t0, 8
	lw $a3, ($t2)
	lw $a1, ($a3)
	addi $t2, $t2, 8
	lw $a3, ($t2)
	lw $a2, ($a3)
	beq $a0, $a1, diag_check2
	j verificar_ganador_no_ganador

diag_check2:
	beq $a1, $a2, diagonal_ganador

verificar_ganador_no_ganador:
	j ret

fila_ganador:
	beq $a0, $s1, set_ganador1
	beq $a0, $s2, set_ganador2
	j verificar_ganador_no_ganador

columna_ganador:
	beq $a0, $s1, set_ganador1
	beq $a0, $s2, set_ganador2
	j verificar_ganador_no_ganador

diagonal_ganador:
	beq $a0, $s1, set_ganador1
	beq $a0, $s2, set_ganador2
	j verificar_ganador_no_ganador

set_ganador1:
	li $v1, 1
	j ret
set_ganador2:
	li $v1, 2
	j ret

set_ganador2:
	li $v0, 2
	j ret

# Subrutina para terminar el juego
terminar_juego:
	# Mostrar el resultado del juego
	la $a0, resultado_msg
	li $v0, 4
	syscall
	beq $v1, 1, mostrar_ganador1
	beq $v1, 2, mostrar_ganador2
	la $a0, empate_msg
	li $v0, 4
	syscall
	j end

mostrar_ganador1:
	la $a0, ganador_msg
	li $v0, 4
	syscall
	li $a0, 1
	li $v0, 1
	syscall
	j end

mostrar_ganador2:
	la $a0, ganador_msg
	li $v0, 4
	syscall
	li $a0, 2
	li $v0, 1
	syscall
	j end



ret:
	jr $ra

end:
	li $v0, 10
	syscall
