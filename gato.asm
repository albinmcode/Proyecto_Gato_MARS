.data
	display: .space 1024
	casilla: .space 40
	jugador_1: .asciiz "Color del primer jugador (num [0, 16M]): "
	jugador_2: .asciiz "Color del segundo jugador (num [0, 16M]): "
	endl: .asciiz "\n"
	
.text
	main:
		li $a1, 0xffffff
		jal crear_tablero
		la $a0, display($zero)
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
		addi $t0, $a0, 136 #primera linea de pixeles de seleccion
		addi $t2, $a0, 776 #ultima linea
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
  	perfil: #se le pide a cada jugador escoger un color de dos disponibles (opcional)
  		la $a0, jugador_1
  		li $v0, 4
  		syscall
  		li $v0, 5
  		syscall
  		move $s1, $v0
  		la $a0, jugador_2
  		li $v0, 4
  		syscall
  		li $v0, 5
  		syscall
  		move $s2, $v0
  		bne $s2, $s1, entrada #cada jugador debe tener un color distinto
  		j perfil
  	
  	entrada: #numero de casilla, codificar a direcci�n de memoria 
  	valido: #revizar casilla si esta disponible
  	gane: #definir si hay ganador, ir a "ret" o a "continuar" *
  	continuar: #reviza si hay al menos una casilla disponible, ir a "ret" o a "entrada"

  resultado:
    #comparar registro rgb de jugador con rgb ganador, empate si es el color de fondo
    #imprimir en consola ganador
    #llamar a fill con $a1 = rgb ganador
	ret:
  	jr $ra
	
	end:
