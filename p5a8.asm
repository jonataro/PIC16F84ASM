;;Rects	
;Ret05 	bsf 	STATUS,RP0 ;Selección de la página 1
;		movlw 	b’00000111’ ;Inicialización del registro OPTION con un divisor de frecuencia
;		movwf 	OPTION_REG ;de 256
;		bcf 	INTCON,T0IF ;Borrado del bit de fin de cuenta
;		bcf 	STATUS,RP0 ;Selección de la página 0
;		movlw 	0x07A1 ;Complemento a 2 del número de ciclos
;		sublw 	0x0000 ;0x0000-0x07A1
;		movwf	TMR0 ;Inicialización del registro TMR0 con la resta anterior
;Bucle 	btfss 	INTCON,T0IF ;Comprobación del final de la cuenta
;		goto 	Bucle ;Si no es el final, se sigue esperando
;	return

;Actividad 8: Diseñe una subrutina denominada Retcs que genere un retardo de una
;centésima de segundo utilizando el temporizador TMR0. 

		list 	p=16F84A
		include P16F84A.INC
;DEFINICION DE CONSTANTES
;CONFIGURACION DEL REGISTRO OPTION

  		org		0
    	goto    inicio

Retcs	bsf		STATUS,RP0 		;Selección del banco 1
		movlw 	0x07	 		;configuracion de prescaler a 256
		movwf 	OPTION_REG		;carga del byte OPTIONREG con el prescaler a 256
		bcf	    STATUS,RP0		;Selección del banco 0
		bcf 	INTCON,T0IF 	;Borrado del bit de fin de cuenta 		
		movlw	0x47			;inicializacion TMR0 a dec'71' para retardo 10ms
		movwf 	TMR0			;carga del valor preconfigurado en TMR0
WaitTmr	btfss 	INTCON,T0IF 	;Comprobación del final de la cuenta
		goto 	WaitTmr			;Si no es el final, se sigue esperando
		return
		
inicio	call Retcs
		goto 	inicio
end
