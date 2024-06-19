.data
	display: .space 1024
	casilla: .space 36
	
.text
	main:
		li $a1, 0xffffff
		jal crear_tablero
		jal casillas #dirección de memoria de las casillas a marcar
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
      
  casillas:
  	li $a1, 0x8aff33 
		li $t0, 136 #primera linea
		li $t2, 776 #ultima linea
		
		new_line: addi $t1, $t0, 40
		mark:
		sw $a1, display($t0)
		addi $t3, $t0, 4
		sw $a1, display($t3)
		addi $t3, $t3, 60
		sw $a1, display($t3)
		addi $t3, $t3, 4
		sw $a1, display($t3)
		addi $t0, $t0, 20
		ble $t0, $t1, mark
		addi $t0, $t0, 260
		ble $t0, $t2, new_line
		j ret
		
  juego:
  	perfil: #se le pide a cada jugador escoger un color de dos disponibles (opcional)
  	entrada: #numero de casilla, codificar a dirección de memoria 
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
