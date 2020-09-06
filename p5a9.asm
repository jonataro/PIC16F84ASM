;Actividad 8: Diseñe una subrutina denominada Retcs que genere un retardo de una
;centésima de segundo utilizando el temporizador TMR0. 
		list 	p=16F84A
		include P16F84A.INC
;DEFINICION DE CONSTANTES Y VARIABLES
NDelay	equ	0x0c;	Parametro para llamar N veces a la rutina Retcs
Cuenta	equ	0x0d
  		org		0
    	goto    inicio
;rutina delay 1 centesima
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
;rutina que llama n veces a delay 1 centesima
RetNcs	nop						
Cent	call	Retcs
		decfsz	NDelay
		goto 	Cent	
		return		 
			
inicio	movlw	0x02; 0x64 dec100
		movwf	NDelay
		call	RetNcs
		incf	Cuenta		
end
