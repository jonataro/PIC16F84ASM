;********************************************************************************
;*	Actividad 12 Diseño tratamiento de interrupción para que gestione un retardo*
;* de N centésimas de segundo sin bloquear la ejecución del programa. Avisar al	*
;* programa principal a través de una bandera FlagNcs, será puesta a cero por	*
;* el programa principal cuando el retardo de 1 segundo se haya cumplido		*
;* descritas previamente hay que tener en cuenta que:							*
;*		1. Hay que programar el temporizador y cargarle un valor inicial 		*
;*		para que produzca la primera interrupción, o disparar el flag de		*
;*		interrupción la primera vez.											*
;*		2. En la rutina de tratamiento de interrupción se debe volver a 		*
;*		cargar el temporizador para que se inicie la siguiente cuenta y,		*
;*		por tanto, la siguiente interrupción.									*	
;********************************************************************************
		list 	p=16F84A
		include P16F84A.INC
;definición de constantes y variables***********************************************************
NDelay	equ		0x0c		;Parametro para llamar N veces a la rutina Retcs
WTemp	equ		0x0e	
StaTemp	equ 	0x0d
MyFlags	equ		0x10
Counter	equ		0x11
Secs	equ		0x12	
#define	FlagNcs	MyFlags,0	
;Inicio de programa*****************************************************************************
  		org		0x00
    	goto    Inicio
		org		0x04
   		goto	Tmr0Int

;tratamiento de interrupcion******************************************************************
Tmr0Int	call	Int1cs		;Prepara el temporizados para nueva interrupción en 1 cseg.
		decfsz	Counter,1	;contador := contador-1, if (contador==0)
		goto	NDelay1		;then
		goto	NDelay0		;else
NDelay0	movf	NDelay,0	;Ndelay;=W
		movwf	Counter		;contador:=W:=Ndelay
		bsf 	FlagNcs		;
NDelay1	bcf		INTCON,2	;Limpieza del bit de interrupción
		retfie				;recupera de la pila la dirección en la que había sido interrumpido
							;el programa y la carga en el contador de programa PC y vuelve a
							; habilitar globalmente las interrupciones


;rutina  que provoca una interrupcion de 1 centesima*******************************************
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
	 
;programa principal****************************************************************************	
Inicio	call	Int1cs		;llamada subrutina que configura la intrrupcion
loadN	movlw	0x64
		movwf	NDelay	
Loop	btfss	FlagNcs;	bit indica cuenta 1segundo
		goto 	Loop
		incf	Secs		
		bcf		FlagNcs
		goto 	Loop		
end
