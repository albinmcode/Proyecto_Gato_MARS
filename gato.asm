.data
	display: .space 1024
	casilla: .space 40
	seleccion: .asciiz "Escoja un número de casilla [1, 9]: "
	
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
      
  casillas: #direcciï¿½n de memoria de las casillas a marcar, indexable luego con (nï¿½mero de casilla * 4) + direcciï¿½n inicial del space casilla.
		addi $t0, $s0, 136 #primera linea de pixeles de seleccion
		addi $t2, $s0, 776 #ultima linea
		la $t3, casilla
		
		new_line: 
		addi $t1, $t0, 40
		line:
		addi $t3, $t3, 4 #posiciï¿½n 0 ignorada para facilituar futura indexaciï¿½n
		sw $t0, ($t3) #se guarda la direccion de memoria de cada campo marcable
		addi $t0, $t0, 20
		ble $t0, $t1, line
		
		addi $t0, $t0, 260
		bgt $t0, $t2, ret
		j new_line
		
  juego:
  	perfil: #se le pide a cada jugador escoger un color de dos disponibles (opcional)
  	entrada: #numero de casilla, codificar a direcciï¿½n de memoria
  		move $a1, $s1 #asignacion al inicio de un turno especifico(funcion de rondas)
  		sw $a1, display($zero)
  		#lw $t0, 0xffff0004 #entrada de teclado
  		la $a0, seleccion
  		li $v0, 4
  		syscall
  		li $v0, 5
  		syscall
  		mul $t0, $v0, 4 
  		lw $t1, casilla($t0)
  		validez:
  			lw $t0, ($t1) #color actual de la casilla
  			bne $t0, 0xffffff, entrada #si tiene un color distinto al de fondo se vuelve a pedir otra posicion
  			addi $s3, $s3, 1 #contador de casillas marcadas
  		marcar:
  			sw $a1, ($t1)
  			addi $t1, $t1, 4
  			sw $a1, ($t1)
				addi $t1, $t1, 60
  			sw $a1, ($t1)
  			addi $t1, $t1, 4
  			sw $a1, ($t1)  		
  	
  	gane: #definir si hay ganador, ir a "ret" o a "continuar" *
  	continuar: #reviza si hay al menos una casilla disponible, ir a "ret" o a "entrada"

  resultado:
    #comparar registro rgb de jugador con rgb ganador, empate si es el color de fondo
    #imprimir en consola ganador
    #llamar a fill con $a1 = rgb ganador
	ret:
  	jr $ra
	
	end:
