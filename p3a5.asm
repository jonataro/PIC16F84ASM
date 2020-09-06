;subrutina que provoca un delay de 5ms
		list 	p=16F84A
		include P16F84A.INC

c1 		equ 	0x0C 	;primer registro de delay
c2	 	equ 	0x0D 	;segundo registro de delay
d3		equ		0x0E	;contador de ciclos de retardo

		goto 	Inicio	;bucle infinito	

Delay	movlw	0x01	;carga valor inicial contador 2 en w
		movwf	c1		;carga de w en contador 1
		movlw	0x02	;carga valor inical contador 1 en w
		movwf	c2		;carga de w en contador 2
dec_c2	decfsz	c1,f	;decremento contador 2
		goto	dec_c2	;si no  cont2 =0 vuelve a dec_c2  
	  	decfsz	c2,f	;decremento contador 1
		goto	dec_c2	;si  no cont1=0 vuelve a ini_c2
		return			;vuelve a progrma principal
		
Inicio	incf	d3,1	;contador de ciclos
		call 	Delay	;llamada a subrutina
		goto 	Inicio	;bucle infinito
		end

