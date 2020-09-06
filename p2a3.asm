list	p=16F84A
include P16F84A.INC
;configuracion puertos
clrf	PORTB
bsf		STATUS, RP0	;Selecciona banco 1
movlw 	0x1F		;Valor para configurar los puertos de A (todos como entrada) copiado al W
movwf 	TRISA 		;Fija PORTA<0:4> como entradas
movlw 	0x00		;Valor para configurar los puertos (todos como salida) copiado al W
movwf 	TRISB		;Fija PORTB<0:7> como salidas
bcf		STATUS, RP0	;Selecciona banco 0

LOOP
;CLRW
movF	PORTA,0; COPIAR EL VALOR DE PORTA => W
movwf	PORTB; COPIAR EL VALOR DE W =>PORTB
GOTO	LOOP; BUCLE
END
