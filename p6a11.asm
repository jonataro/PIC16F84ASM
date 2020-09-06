;Actividad 11 	Diseñe una subrutina que provoque una interrupción
;				cada Centésima de segundo utilizando el temporizador

;Cuando es necesario producir una interrupción de forma regular
;recurriendo al temporizador TMR0, además de las consideraciones 
;descritas previamente hay que tener en cuenta que:
;	1. Hay que programar el temporizador y cargarle un valor inicial 
;	para que produzca la primera interrupción, o disparar el flag de
;	interrupción la primera vez.
;	2. En la rutina de tratamiento de interrupción se debe volver a 
;	cargar el temporizador para que se inicie la siguiente cuenta y,
;	por tanto, la siguiente interrupción.
		list 	p=16F84A
		include P16F84A.INC
;definición de constantes y variables
NDelay	equ	0x0c		;Parametro para llamar N veces a la rutina Retcs
;Inicio de programa
  		org		0x00
    	goto    Inicio
		org		0x04
   		goto	Tmr0Int

;rutina  que provoca una interrupcion de 1 centesima
Int1cs	movlw   b'10100000'	;Byte para configurar el registro INTCON
    	movwf   INTCON	    ;activamos  bits T0IE y GIE 	
		bsf		STATUS,RP0 	;Selección del banco 1
		movlw 	0x07	 	;configuracion de prescaler a 256
		movwf 	OPTION_REG	;carga del byte OPTIONREG con el prescaler a 256
		bcf	    STATUS,RP0	;Selección del banco 0
		bcf 	INTCON,T0IF ;Borrado del bit de fin de cuenta 		
		movlw	0x47		;inicializacion TMR0 a dec'71' para retardo 10ms
		movwf 	TMR0		;carga del valor preconfigurado en TMR0
		return
	 
;programa principal			
Inicio		
		call	Int1cs		;llamada subrutina que configura la intrrupcion
		goto	$		
end
