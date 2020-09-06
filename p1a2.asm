;Para realizar la comparaci�n restamos los dos n�mero (A-B).
; Si al realizar la resta los dos n�meros son iguales el resultado ser� cero, activ�ndose el bit Z del registro de
; Estado.
; Si al realizar la resta (suma del complemento a 2 de B) se produce un bit de acarreo el resultado es positivo
; (A> B). Ejemplo: 3-2 = 0011 + 1110 = 1 0001.
; Si no se produce acarreo el resultado es negativo (A<B). Ejemplo: 2-3 = 0010 + 1101 = 0 1111.
list p=16F84
include P16F84.INC
NumA equ 0x0C ;Variable del n�mero A
NumB equ 0x0D ;Variable del n�mero B
Mayor equ 0x0E ;Variable que almacenar� el mayor de los n�meros
Suma equ 0x0F
org 0x00 ;Vector de reset

goto Inicio ;Salto incondicional al principio del programa
org 0x05 ;Vector de interrupci�n

Inicio
	movf NumB,W ;NumB -> W (acumulador)
	subwf NumA,W ;A-W -> W
	btfsc STATUS,Z ;Bit de cero del registro de Estado a 1 0
	goto A_Igual_B ;Si
	btfsc STATUS,C ;v 1
	goto A_Mayor_B
	goto A_Menor_B ;Si
	

A_Menor_B
	movf NumB,W ;No, A es menor que B
	movwf Mayor ;Suma A m�s B
	goto Fin

A_Mayor_B
	movf NumA,W ;No, A es menor que B
	movwf Mayor ;Suma A m�s B
	goto Fin

A_Igual_B 
	clrf Mayor ;Pone a 0 el resultado

Fin	goto inicio
	end
