;multiplicacion de dos numeros de cuatro bits usando sumas parciales
			list 	p=16F84A
			include P16F84A.INC

;configuracion puertos
			clrf	PORTB
			bsf		STATUS, RP0	;Selecciona banco 1
			movlw 	0x1F		;Valor para configurar los puertos de A (todos como entrada) copiado al W
			movwf 	TRISA 		;Fija PORTA<0:4> como entradas
			movlw 	0x00		;Valor para configurar los puertos (todos como salida) copiado al W
			movwf 	TRISB		;Fija PORTB<0:7> como salidas
			bcf		STATUS, RP0	;Selecciona banco 0

;declaracion variables
DH 			equ 	0x0C 	;primer registro de delay
DL	 		equ 	0x0D 	;segundo registro de delay
NumA		equ		0x10
NumB		equ		0x11
i			equ		0x12

;inicio	
			goto	_inicio

;subrutina multiplicacion
Multip		clrf	DH
			clrf	DL
			bcf     STATUS,C
			movf	NumB,0
			movwf	DL
			Movlw	0x09	;inicialización variable indexado i, se inicia a 9 para que ejecute el ciclo 8 veces
			Movwf	i;
			movf	NumA,W	;Cargar NumA en W
_for		decfsz	i,f		;for (i=0; i<8; i++)			
			goto	_if

			goto 	_endfor			
_if			btfsc	DL,0	;salto si el bit 0 
			goto	_then1
			goto	_else1
_then1		addwf	DH,1	;DH := DH + NumA
			goto	_endif1

_else1		bcf     STATUS,C
_endif1		rrf		DH,1	;Desplazar DH hacia la derecha inyectando el bit de Carry por la izquierda
			rrf		DL,1	;Desplazar DL hacia la derecha inyectando por la izquierda el bit desplazado del DH en el paso previo	
			goto	_for
_endfor		return

;programa principal
;carga de variables NumA NumB desde el puesrto A
_inicio		movlw	0x0f
			andwf	PORTA,0		
			btfsc	PORTA,4
			goto	_then0
			goto	_else0
_then0		Movwf	NumB
			goto	endif0 
_else0		Movwf	NumA
endif0 		call	Multip
			goto	_inicio
;fin programa 
			end



