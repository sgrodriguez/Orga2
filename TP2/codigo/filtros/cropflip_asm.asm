global cropflip_asm
%define TAM_PIXEL   4
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
	;RBP + 8 = tamx (entero)
	;RBP + 16 = tamy (entero)
	;RBP + 24 = offsetx (entero)
	;RBP + 32 = offsety (entero)

	push RBP		
	mov RSP, RBP; Creando mi stack peolona
	push R12
	push R13
	push R14
	push RBX


	xor R12,R12;	Me guardo mi poss Actual de columna => empieza con (offsetFila + OffsetColumna)*4
	xor R13,R13;	
	xor R14,R14;
	xor R10,R10
	xor R11,R11
	xor RBX,RBX
	mov R10D,[RBP+24];guardo mi offsetx temporal
	mov R11D,[RBP+32];guardo mi offsety temporal
	mov R13D,[RBP+8]; ne guardo mi tamx Cuantas Columnas voy a iterar HINT Son multiplo de 4 este numero
	mov R12D,[RBP+16]; me guardo mi tamy Cuantas filas voy iterar
	;mul R10D,TAM_PIXEL; AHORA EN R10D TENGO MI DESPLAZAMIENTO EN Columnas
	mov EBX,EDX;me traigo mi tamnio de columna
	;mul EBX, TAM_PIXEL;Columna*4
	;mul R11D,EBX; Ahora tengo en r11d mi primera posicion a donde tengo que copiar es decir offsetFila * columna*4
	add R10D,R11D; Ahora me estoy guardando en r10d mi primera poscion donde tengo q copiar es decir estoy en la primer fila indicada por offsety y en la primer columan indicado por offsetx
	mov R14D,R10D; Muevo este resultado a R14D
	mov R10D,[RBP+24];Vuelvo a guardar mi offsetx original
	mov R11D,[RBP+32];Vuelvo a guardar mi offsety original


.cicloFilas:
	CMP R12D,0
	je .termineCopiar

	;RECALCULO R14 RESETEO MI TAMX osea mi fila y le resto 1 a mi offsety

	mov R13D,[RBP+24];reseteo mi tamx
	jmp .cicloColumna

.cicloColumna:
	
	;movdqu xmm1, [rdi+bla bla] 
	;movdqu [rsi+algo], [bla bla];revisar como ponerlo al revez jejeje  	
	
	sub R13D,TAM_PIXEL ;le resto lo 4 pixeles q ya procese
	cmp R13D,0
	jne .cicloColumna
	sub R12D,1
	jmp .cicloFilas

.termineCopiar:

	pop RBX
	pop R14
	pop R13
	pop R12
	pop RBP
	ret
    