			list p=16F84A
			include P16F84A.INC

NumA 		equ 	0x0C 	;Parametrro1 del comparador:número A
NumB 		equ 	0x0D 	;Parametro2 del comparador:número B
Mayor 		equ 	0x0E 	;Variable que almacenará el mayor de los números
Resultado1 	equ 	0x0F
Resultado2  equ		0x10
Resultado3  equ		0x11	
			org 	0x00 	;Vector de reset			
			goto 	Inicio 	;Salto incondicional al principio del programa
			org 	0x05 	;Vector de interrupción

;rutina de comparad ghng hg h or;***************************************************************	
Comparador	movf 	NumB,W 		;NumB -> W (acumulador)							
			subwf	NumA,W 		;A-W -> W										
			btfsc 	STATUS,Z 	;Bit de cero del registro de Estado a 1 0		
			goto 	A_Igual_B	;Si												
			btfsc 	STATUS,C	;Bit de acarreo del registro de Estado a 1
			goto 	A_Mayor_B
			goto 	A_Menor_B 	;Si
A_Menor_B	movf 	NumB,W 		;No, A es menor que B
			movwf 	Mayor 		;Suma A más B
			return
A_Mayor_B	movf 	NumA,W 		;No, A es menor que B
			movwf	Mayor 		;Suma A más B
			return	
A_Igual_B	clrf 	Mayor 		;Pone a 0 el resultado	
			return

Inicio		movlw 	0x02
			movwf 	NumA ; Copia contenido de W en Parametro1 de la subrutina
			movlw 	0x02 		
			movwf 	NumB ; Copia contenido de W en Parametro2 de la subrutina
			call 	Comparador;
			movf	Mayor,0
			movwf	Resultado1

			movlw 	0x07 		; Copia valor 0xA2 en el acumulador W
			movwf 	NumA
			call 	Comparador;
			movf	Mayor,0
			movwf	Resultado2

			movlw 	0x01 		; Copia valor 0xA2 en el acumulador W
			movwf 	NumA
			call 	Comparador;
			movf	Mayor,0
			movwf	Resultado3
END
