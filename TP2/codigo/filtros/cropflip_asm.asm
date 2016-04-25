global cropflip_asm

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);

cropflip_asm:

	;RDI = src (puntero a char)
	;RSI = dst (puntero a char)
	;EDX = cols (entero)
	;ECX = filas (entero)
	;R8D = src_row_size (entero)
	;R9D = dst_row_size (entero)
	;BUSCARLOS EN LA PILA EL RESTO DE LOS ARG
	;verificar
	;RBP - 8 = tamx (entero)
	;RBP - 16 = tamy (entero)
	;RBP - 24 = offsetx (entero)
	;RBP - 32 = offsety (entero)

	push RBP		
	mov RSP, RBP; Creando mi stack peolona
	push R12
	push R13
	push R14



	xor R12,R12;	Me guardo mi poss Actual de columna => empieza con (offsetFila + OffsetColumna)*4
	xor R13,R13;	
	xor R14,R14;
	mov R14,[RDI+]
	mov R13D,[RBP-24]; ne guardo mi tamx Cuantas Columnas voy a iterar HINT Son multiplo de 4 este numero
	mov R12D,[RBP-32]; me guardo mi tamy Cuantas filas voy iterar

.cicloFilas:
	CMP R12D,0
	je .termineCopiar
	//recalculo R14
	mov R13D,[RBP-24];reseteo mi tamx
	jmp .cicloColumna

.cicloColumna:
	
	movdqu xmm1, [rdi+bla bla] 
	movdqu [rsi+algo], [bla bla];revisar como ponerlo al revez jejeje  	
	sub R13D,4
	cmp R13D,0
	jne .cicloColumna
	sub R12D,1
	jmp .cicloFilas

.termineCopiar:

	pop R14
	pop R13
	pop R12
	pop RBP
	ret
    
