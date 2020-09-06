;cabecera*****************************************************************************************
;Controlador PID regulado por interrupcion ciclica

		list 	p=16F84A
		include P16F84A.INC
		__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC		
;vectores de inicio e interupcion*****************************************************************
		org		0x00
    		goto    	Inicio
		org		0x04
   		goto		Tmr0Int
;definicion de constantes y variables*************************************************************
;	variables filtro------------------------------------
n1		equ		0x10		; 1ªLectura
n2		equ		0x11		; 2ªLectura
n3		equ		0x12		; 3ªLectura
n4		equ		0x13		; 4ªLectura
n5		equ		0x14		; 5ªLectura
n6		equ		0x15		; 6ªLectura
n7		equ		0x16		; 7ªLectura
n8		equ		0x17		; 8ªLectura
ind		equ		0x18		;indice para el buffer circular
aux1		equ		0x19		;variable auxiliar para calculo por arbol binario
aux2		equ		0x1A		;variable auxiliar para calculo por arbol binario
aux3		equ		0x1B		;variable auxiliar para calculo por arbol binario
aux4		equ		0x1C		;variable auxiliar para calculo por arbol binario
bufferIn	equ		0x1D		;valor con el que ir cargando en el buffer		
average		equ		0x1E		;media de las ultimas 8 lecturas
;	variables PID--------------------------------------
PidCmd		equ		0x20	
Feedback	equ		0x21
MyError		equ		0x22
LastError	equ		0x23
PidAction	equ		0x24
Integ		equ		0x25
Diff		equ		0x26
;		constantes	
kp		equ		d'1'
ki		equ		d'1'
kd		equ		d'1'
;	variables multiplicador--------------------------------------
MultipA		equ		0x28
MultipB		equ		0x29
DH		equ		0x2A
DL		equ		0x2B
i		equ		0x2C
;	variables interrupcion--------------------------------------
;		constante
NDelay		equ 		d'10'
WTemp		equ		0x2D	
StaTemp		equ 		0x2E
Counter		equ		0x2F
;tratamiento de interrupcion******************************************************************
;---almacenamiento de contexto
Tmr0Int		movwf 		WTemp		;Copia W a W_TEMP
		swapf 		STATUS,0 	;Copia STATUS a W con intercambio de nibbles
		movwf 		StaTemp 	;Guarda STATUS en STATUS_TEMP a través de W	
;---Instrucciones tratamiento interrupción por desbordamiento del timer
		bcf     	INTCON,GIE  	;Deshabilitar interrupciones
		call		Int1cs		;Prepara el temporizados para nueva interrupción en 10ms.
		call		_10msec		;codigo que se ejecuta cada 10ms
		decfsz		Counter,1	;contador := contador-1, if (contador==0)
		goto		NDelay1		;then hemos hecho n delays
		goto		NDelay0		;else todavia no hemos hecho n delays
NDelay0		call		_n_10msec	;codigo que se ejecuta cada n x 10msec
		movlw		NDelay	; vuelvo a recargar el valor Ndelay;=W
		movwf		Counter	;reinicio el valor del indice contador:=W:=Ndelay
;---limpieza contexto y retfie
NDelay1		swapf		StaTemp,0	;Copia STATUS_TEMP a W con intercambio de nibbles
		movwf		StaTemp 	;Restaura STATUS_TEMP a STATUS a través de W
		swapf		WTemp,1		;Copia W_TEMP en W_TEMP con intercambio de nibbles
		swapf		WTemp,0		;Restaura W_TEMP a W con intercambio de nibbles	
		bcf		INTCON,2	;Limpieza del bit de interrupción
		retfie				;recupera de la pila la dirección en la que había sido interrumpido
						;el programa y la carga en el contador de programa PC y vuelve a
						; habilitar globalmente las interrupciones
;rutina  que provoca una interrupcion de 1 centesima*******************************************
Int1cs		movlw  	 	b'10100000'	;Byte para configurar el registro INTCON
	    	movwf   	INTCON	    	;activamos  bits T0IE y GIE 	
		bsf		STATUS,RP0 	;Selección del banco 1
		movlw 		0x07	 	;configuracion de prescaler a 256
		movwf 		OPTION_REG	;carga del byte OPTIONREG con el prescaler a 256
		bcf	    	STATUS,RP0	;Selección del banco 0
		bcf 		INTCON,T0IF 	;Borrado del bit de fin de cuenta 		
		movlw		0x47		;inicializacion TMR0 a dec'71' para retardo 10ms
		movwf 		TMR0		;carga del valor preconfigurado en TMR0
		return
;rutina que se ejecuta cada  n centesima*************************************************************
_10msec		movf		PORTB,0 	;leer el valor del Puerto B
		movwf		bufferIn		
		call		ringbuf		;almacena el valor de PB en buffer circular
		return
;rutina que se ejecuta cada n decimas****************************************************************
_n_10msec	call		calcAvg		; Calcula valor promedio
		movwf		Feedback	;asigna el promedio de las ultimas lecturas como feedback filtrado del PID
		call		PID		;calcular la accion de control
		movwf		PORTA		;ecribir la accion de control en puerto A	
		call		EepromW		;escribir ultimo dato filtrado en la EEPROM
		return	
;rutina de configuracion de puertos A y B*********************************************************
ConfigP		clrf		PORTB
		bsf		STATUS, RP0	;Selecciona banco 1
		movlw 		0xE0		;Valor para configurar los puertos de A (todos como entrada) copiado al W
		movwf 		TRISA 		;Fija PORTA<0:4> como salidas
		movlw 		0xFF		;Valor para configurar todo b como entrada
		movwf 		TRISB		;Fija PORTB<0:7> como entradas
		bcf		STATUS, RP0	;Selecciona banco 0
		return
;Rutina de almacenamiento en buffer cicular*******************************************************
ringbuf		movf		ind,0 		;carga el valor del indice en W
		movwf 		FSR 		;carga el valor de w(indice) en FSR
		movf		bufferIn,0	;carga del valor a almacenar en W
		movwf		INDF		;carga de w en el INDF(indf apunta a la dirección de FSR)
		movlw		n1 		;carga la direccion n1 en W
		subwf		ind,0		;resta de n1-indice 
		btfsc		STATUS,Z 	;si la resta es cero el indice es =n1
		goto		reload
		goto		decI
reload		movlw		n8
		movwf		ind
		return	
decI		decfsz		ind		
		return
;rutina que calcula media aritmetica del buffer de 8 muestras**************************************************************
calcAvg		movf		n1,0   		;aux1=(n1+n2)/2     
            	addwf		n2,0
		movwf		aux1        
           	 rrf		aux1,1   	
            	movf		n3,0   		;aux2=(n3+n4)/2     
            	addwf		n4,0
		movwf		aux2        
           	rrf		aux2,1              
            	movf    	n5,0		;aux3=(n5+n6)/2        
            	addwf		n6,0        
            	movwf		aux3        
            	rrf		aux3,1       
            	movf    	n7,0	;aux4=(n7+n8)/2
            	addwf		n8,0
		movwf		aux4        
	    	rrf		aux4,1
            	movf		aux1,0		;aux2=(aux1+aux2)/2   
            	addwf		aux2,1        
            	rrf		aux2,1
     		movf		aux3,0		;aux4=(aux3+aux4)/2
            	addwf		aux4,1        
            	rrf		aux4,1
		movf		aux2,0		;aux4=(aux2+aux4)/2        
            	addwf		aux4,1        
            	rrf		aux4,1
            	movwf		average		;Average=aux4
            	return
;rutina que guarda valor filtrado en EEPROM*******************************************************
EepromW		movlw		0x00
		movwf		EEADR		; escribe la dirección en eeadr
		movf		average,0
		movwf		EEDATA		; se escribe el dato en eedata 
		bsf		STATUS,RP0	; selecciona el banco 1
		bsf		EECON1,WREN	; permiso de escritura activado
		movlw		0x55		;comienzo de la secuencia de escritura
		movwf		EECON2		; se escribe el dato 55 h en eecon2
		movlw		0xaa
		movwf		EECON2		; se escribe aa h en eecon2
		bsf		EECON1,WR	; comienza la escritura
		bcf		EECON1,WREN	; permiso de escritura desactivado
waitWrite	btfsc		EECON1,WR	; espera a que termine la escritura
		goto		waitWrite
		bcf		STATUS,RP0 	; selecciona el banco 0
		return
;rutina que calcula la accion de control PID******************************************************
	;actualizacion de error anterior
PID		movf		MyError,0
		movwf		LastError
	;actualizacion error
            	movf		Feedback,0    
            	subwf   	PidCmd,0     
           	movwf  	 	MyError
	;calculo Accion Intergral
		addwf		Integ,1 	;sumar W(Error a integral
		movwf		MultipA
		movlw		ki
		movwf		MultipB
		call 		Multip
		movwf		PidAction	;= +integralAction
	;calculo derivativa (error-last error)*kd*/0,1
		movf		LastError,0	;error-last error
		subwf		MyError,0
		movwf		Diff
		movwf		MultipA
		movlw		kd
		movwf		MultipB
		call 		Multip
		Movwf		MultipA	
		movlw		0x0A			
		movwf		MultipB
		call 		Multip
Action		addwf		PidAction,1	;= +integralAction +differential action
	;calculo accion proporcional
		movf		MyError,0
		movwf		MultipA
		movlw		kp
		movwf		MultipB
		call		Multip
		addwf		PidAction,1	;= +integralAction +differential action+ PID action
		return

;subrutina multiplicacion**********************************************************************
Multip		clrf		DH
		clrf		DL
		bcf     	STATUS,C
		movf		MultipB,0
		movwf		DL
		Movlw		0x09		;inicialización variable indexado i, se inicia a 9 para que ejecute el ciclo 8 veces
		Movwf		i;
		movf		MultipA,W	;Cargar NumA en W
_for		decfsz		i,f		;for (i=0; i<8; i++)			
		goto		_if
		goto 		_endfor			
_if		btfsc		DL,0		;salto si el bit 0 
		goto		_then1
		goto		_else1
_then1		addwf		DH,1		;DH := DH + NumA
		goto		_endif1
_else1		bcf     	STATUS,C
_endif1		rrf		DH,1		;Desplazar DH hacia la derecha inyectando el bit de Carry por la izquierda
		rrf		DL,1		;Desplazar DL hacia la derecha inyectando por la izquierda el bit desplazado del DH en el paso previo	
		goto		_for
_endfor		return

;programa principal*******************************************************************************		
Inicio		movlw		n8 		;inicializacion del buffer circular para almacenar valores del sensor
		movwf 		ind		;idem
		call		ConfigP		;configuracion de los puertos A y B		
		call		Int1cs		;llamada subrutina que configura la intrrupcion por primera vez
		goto		$		;todo el codigo se ejecuta en rutinas llamadas desde la interrupcion ciclica	
		end

