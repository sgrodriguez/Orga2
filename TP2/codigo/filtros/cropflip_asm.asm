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
	;RBP + 16 = tamx (entero)
	;RBP + 24 = tamy (entero)
	;RBP + 32 = offsetx (entero)
	;RBP + 40 = offsety (entero)

	push RBP		
	mov RBP, RSP; Creando mi stack peolona
	push R12
	push R13
	push R14
	push RBX
	push rcx
	push r11
	push r12
	push r13



	xor rax,rax
	xor rcx,rcx
	xor R12,R12;	Me guardo mi poss Actual de columna => empieza con (offsetFila + OffsetColumna)*4
	xor R13,R13;	
	xor R14,R14;
	xor R10,R10
	xor R11,R11
	xor RBX,RBX
	mov R10D,[RBP+32];guardo mi offsetx temporal
	mov R11D,[RBP+40];guardo mi offsety temporal
	mov R13D,[RBP+16]; ne guardo mi tamx Cuantas Columnas voy a iterar HINT Son multiplo de 4 este numero
	mov R12D,[RBP+24]; me guardo mi tamy Cuantas filas voy iterar
	mov r14d,TAM_PIXEL
	mov EBX,EDX;me traigo mi tamnio de columna
	shl RBX,2; en RBX tengo columna *4
	mov R10D,[RBP+32];Vuelvo a guardar mi offsetx original
	mov R11D,[RBP+40];Vuelvo a guardar mi offsety original
	mov ecx,[RBP+40];Vuelvo a guardar mi offsety original
	

	;eax tengo mi multiplicando y dsp multiplico por un registro
	;
.cicloFilas:
	;cuando entro a este ciclo debo asegurar que mi r11 tengo mi poss 
	CMP R12D,0
	je .termineCopiar

	;./tp2 -v cropflip -i asm lena32.bmp 32 32 128 128
	;RECALCULO R14 RESETEO MI TAMX osea mi fila y le resto 1 a mi offsety

	shl R10,2; AHORA EN R10 TENGO MI DESPLAZAMIENTO EN Columnas
	
	mov eax,ecx
	mul ebx
	mov r11d,eax
	mov R13D,[RBP+24];reseteo mi tamx

	jmp .cicloColumna

.cicloColumna:
	;cuando entro a este ciclo debo asegurar que en r11 este mi offsetfila(actualizado)*columna*4
	;y en r10 debo tener mi offset x actualizado es decir r10 * tam_pixel
	add r11,r10
	movdqu xmm1, [rdi+r11+16];
	;TENGO Q PONER UN OFFSET PARA IR PONIENDO LOS PIXEL EN LA IMAGEN DESTINO 
	movdqu [rsi], xmm1;revisar como ponerlo al revez jejeje  	;PENSAR COMO CARAJO PONERLO
	
	shr R10,2
	add R10,1
	shl r10,2;ahora actualizo mi offsetx

	sub R13D,TAM_PIXEL ;le resto lo 4 pixeles q ya procese
	cmp R13D,0
	jne .cicloColumna
	xor r10,r10
	mov R10D,[RBP+32];Vuelvo a guardar mi offsetx original

	;DEBO RESTAR O SUMAR 1 A MI OFFSET Y EN ESTA PARTDE DEL CICLO?
	add ecx,1;le sumo a mi offsety 1
	sub r12d,1;le resto a mi tamy 1
	jmp .cicloFilas

.termineCopiar:

	pop r13
	pop r12
	pop r11
	pop rcx
	pop RBX
	pop R14
	pop R13
	pop R12
	pop RBP
	ret
    