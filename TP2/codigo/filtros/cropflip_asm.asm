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
	push R14
	push RBX
	push r11
	push r13
	push rcx
	push r15
	add rsp,8
	;corregir stack


	xor rax,rax
	xor r15,r15
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
	mov eax,r12d
	dec eax
	mul r9d
	mov ecx,eax;aca tengo mi primera fila destino a la que voy a copiar los pixeles
	xor rax,rax
	mov eax,r11d
	mul ebx
	mov r11d,eax; tengo mi primera fila a la cual quiero copiar
	xor rax,rax
	xor rbx,rbx
	shl R10,2; AHORA EN R10 TENGO MI DESPLAZAMIENTO EN Columnas
	add r11,r10

	;eax tengo mi multiplicando y dsp multiplico por un registro
	;
.cicloFilas:
	;cuando entro a este ciclo debo asegurar que mi r11 tengo mi poss 
	CMP R12D,0
	je .termineCopiar

	;./tp2 -v cropflip -i asm lena32.bmp 256 256 128 0
	;RECALCULO R14 RESETEO MI TAMX osea mi fila y le resto 1 a mi offsety

	xor r15,r15
	mov R13D,[RBP+16];reseteo mi tamx
	mov eax,r11d
	mov ebx,ecx

	jmp .cicloColumna

.cicloColumna:
	;cuando entro a este ciclo debo asegurar que en r11 este mi offsetfila(actualizado)*columna*4
	;y en r10 debo tener mi offset x actualizado es decir r10 * tam_pixel
	movdqu xmm1, [rdi+rax];
	;TENGO Q PONER UN OFFSET PARA IR PONIENDO LOS PIXEL EN LA IMAGEN DESTINO 
	add ebx,r15d
	movdqu [rsi+rbx], xmm1;revisar como ponerlo al revez jejeje  	;PENSAR COMO CARAJO PONERLO
	sub ebx,r15d

	add eax,16

	sub R13D,TAM_PIXEL ;le resto lo 4 pixeles q ya procese
	add r15d,16
	cmp R13D,0
	jne .cicloColumna
	;Salgo del ciclo

	add r11d,r8d
	sub ecx,r9d;le resto dst_row size para que me baje a la siguiente fila
	dec r12d;le resto a mi tamy 1
	jmp .cicloFilas

.termineCopiar:

	sub rsp,8
	pop r15
	pop rcx
	pop r13
	pop r11
	pop RBX
	pop R14
	pop R12
	pop RBP
	ret
    