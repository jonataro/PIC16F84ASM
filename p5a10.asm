;Actividad 10 Reloj segundero muestra cuenta por puerto B
		list 	p=16F84A
		include P16F84A.INC
;definición de constantes y variables
	NDelay	equ	0x0c		;Parametro para llamar N veces a la rutina Retcs
;Inicio de programa
  		org		0x00
    	goto    inicio
;rutina configuracion puerto B
ConfigB	clrf	PORTB
		bsf		STATUS, RP0	;Selecciona banco 1
		movlw 	0x00		;Valor para configurar todo b como salida
		movwf 	TRISB		;Fija PORTB<0:7> como salidas
		bcf		STATUS, RP0	;Selecciona banco 0
		return
;rutina delay 1 centesima
Retcs	bsf		STATUS,RP0 	;Selección del banco 1
		movlw 	0x07	 	;configuracion de prescaler a 256
		movwf 	OPTION_REG	;carga del byte OPTIONREG con el prescaler a 256
		bcf	    STATUS,RP0	;Selección del banco 0
		bcf 	INTCON,T0IF ;Borrado del bit de fin de cuenta 		
		movlw	0x47		;inicializacion TMR0 a dec'71' para retardo 10ms
		movwf 	TMR0		;carga del valor preconfigurado en TMR0
WaitTmr	btfss 	INTCON,T0IF ;Comprobación del final de la cuenta
		goto 	WaitTmr		;Si no es el final, se sigue esperando
		return
;rutina que llama n veces a delay 1 centesima
RetNcs	movwf	NDelay						
Cent	call	Retcs
		decfsz	NDelay
		goto 	Cent	
		return		 
;programa principal			
inicio	call 	ConfigB		;inicializar puertoB
		movlw	0x64		;carga de parametro subrituna a traves de w		
Loop	call	RetNcs		;llamada subrutina
		incf	PORTB,1
		goto	Loop		
end
