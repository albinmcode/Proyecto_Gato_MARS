.data
	display: .space 1024
	casilla: .space 40
	colores_hex: .word 0x00ffb6, 0xfff700, 0x8300ff, 0xff2a00 #(incluir cuantos se desee)
	colores: .asciiz "Colores a escoger:\n1) Cian\n2) Amarrillo\n3) Morado\n4) Naranja\n"
	j1: .asciiz "Jugador 1: "
	j2: .asciiz "Jugador 2: "
	seleccion: .asciiz "\nEscoja un n�mero de casilla [1, 9]: "
	
.text
	main:
		li $a1, 0xffffff
		jal crear_tablero
		la $s0, display($zero)
		jal casillas
		jal juego
		jal resultado
		j end
	
	crear_tablero:
		li $t1, 0
    fill:
      sw $a1, display($t1)
      addi $t1, $t1, 4
      beq $t1, 1024, lineas
      j fill
    lineas:
      li $a1, 0x000000
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
      
  casillas: #direcci�n de memoria de las casillas a marcar, indexable luego con (n�mero de casilla * 4) + direcci�n inicial del space casilla.
		addi $t0, $s0, 136 #primera linea de pixeles de seleccion
		addi $t2, $s0, 776 #ultima linea
		la $t3, casilla
		
		new_line: 
		addi $t1, $t0, 40
		line:
		addi $t3, $t3, 4 #posici�n 0 ignorada para facilituar futura indexaci�n
		sw $t0, ($t3) #se guarda la direccion de memoria de cada campo marcable
		addi $t0, $t0, 20
		ble $t0, $t1, line
		
		addi $t0, $t0, 260
		bgt $t0, $t2, ret
		j new_line
		
  juego:
  	perfil: #se le pide a cada jugador escoger un color de los disponibles
  		move $t3, $ra #conservar el retorno a main
  		la $t1, colores_hex
  		la $a0, colores #msg colores disponinles
  		li $v0, 4
  		syscall
  		
  		la $a0, j1 #primer color 
  		jal selec_color
  		move $s1, $v1
  		segundo: la $a0, j2 #segundo color 
  		jal selec_color
  		beq $s1, $t0, segundo #cada jugador debe tener un color distinto
  		move $s2, $v1 
  		move $ra, $t3
  		j ret
  		
  		selec_color:
  			li $v0, 4
  			syscall
  			li $v0, 5
  			syscall
  			sub $t0, $v0, 1
  			mul $t0, $t0, 4
  			add $t2, $t1, $t0   
  			lw $v1, 0($t2) # codigo del color escogido
  			j ret

  	entrada: #numero de casilla, codificar a direcci�n de memoria
  	gane: #definir si hay ganador, ir a "ret" o a "continuar" *
  	continuar: #reviza si hay al menos una casilla disponible, ir a "ret" o a "entrada"

  resultado:
    #comparar registro rgb de jugador con rgb ganador, empate si es el color de fondo
    #imprimir en consola ganador
    #llamar a fill con $a1 = rgb ganador
	ret:
  	jr $ra
	
	end:
