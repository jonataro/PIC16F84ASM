;*********************************************************************************************
;Actividad 13 Diseñe un reloj por interrupción que muestre una cuenta en segundos por el
;puerto B. Mientras realiza la cuenta el temporizador, el programa debe multiplicar la
;entrada del puerto B por la entrada del puerto A
;*********************************************************************************************
		list 	p=16F84A
		include P16F84A.INC
;definición de constantes y variables*********************************************************
;---variables para interrupcion ciclcica
NDelay	equ		0x0c		;Parametro para llamar N veces a la rutina Retcs
WTemp	equ		0x0e	
StaTemp	equ 	0x0d
MyFlags	equ		0x10
Counter	equ		0x11
#define	FlagNcs	MyFlags,0
;---variables subrituna multiplicacion
NumA	equ		0x12
NumB	equ		0x13
i		equ		0x14
DH 		equ 	0x15 	;primer registro de delay
DL	 	equ 	0x16 	;segundo registro de delay	
	
;Inicio de programa***************************************************************************
  		org		0x00
    	goto    Inicio
		org		0x04
   		goto	Tmr0Int

;tratamiento de interrupcion******************************************************************

;---almacenamiento de contexto
Tmr0Int	movwf 	WTemp		;Copia W a W_TEMP
		swapf 	STATUS,0 	;Copia STATUS a W con intercambio de nibbles
		movwf 	StaTemp 	;Guarda STATUS en STATUS_TEMP a través de W	
;---Instrucciones tratamiento interrupción por desbordamiento del timer
		call	Int1cs		;Prepara el temporizados para nueva interrupción en 1 cseg.
		decfsz	Counter,1	;contador := contador-1, if (contador==0)
		goto	NDelay1		;then
		goto	NDelay0		;else
NDelay0	movf	NDelay,0	;Ndelay;=W
		movwf	Counter		;contador:=W:=Ndelay
		bsf 	FlagNcs		;
;---limpieza contexto y retfie
NDelay1	swapf	StaTemp,0	;Copia STATUS_TEMP a W con intercambio de nibbles
		movwf	StaTemp 	;Restaura STATUS_TEMP a STATUS a través de W
		swapf	WTemp,1		;Copia W_TEMP en W_TEMP con intercambio de nibbles
		swapf	WTemp,0		;Restaura W_TEMP a W con intercambio de nibbles	
		bcf		INTCON,2	;Limpieza del bit de interrupción
		retfie				;recupera de la pila la dirección en la que había sido interrumpido
							;el programa y la carga en el contador de programa PC y vuelve a
							; habilitar globalmente las interrupciones

;rutina configuracion puertos A y B*****************************************************************
ConfigP	clrf	PORTB
		bsf		STATUS, RP0	;Selecciona banco 1
		movlw 	0x1F		;Valor para configurar los puertos de A (todos como entrada) copiado al W
		movwf 	TRISA 		;Fija PORTA<0:4> como entradas
		movlw 	0x00		;Valor para configurar todo b como salida
		movwf 	TRISB		;Fija PORTB<0:7> como salidas
		bcf		STATUS, RP0	;Selecciona banco 0
		return

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

;subrutina multiplicacion**********************************************************************
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
	 
;programa principal****************************************************************************	
Inicio	call 	ConfigP		;inicializar puertos
		bcf		FlagNcs		;FlagNcs := 0
		movlw	0x64		;W := 100
		movwf	NDelay		;N:=W
		call	Int1cs		;llamada subrutina que configura la intrrupcion	
Loop	btfss	FlagNcs;	si bit indica cuenta 1segundo
		goto 	Multi		;si no hay flag1seg ve amultiplicar
		incf	PORTB,1		;si ay flag1seg incrementa PB
		bcf		FlagNcs		;limpia PB
Multi	movf	PORTA,0;	;Pasar PA a parametro NumA de subrutina Multip
		movwf	NumA;
		movf	PORTB,0;	;Pasar PB a parametro NumB de subrutina Multip
		movwf	NumB;		
		call	Multip		;llamada a subrutuna multip
		goto 	Loop		;bucle;
end
