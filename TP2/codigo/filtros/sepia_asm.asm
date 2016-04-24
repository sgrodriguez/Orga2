section .data
DEFAULT REL

section .text
global sepia_asm
sepia_asm:
;COMPLETAR
	push RBP		;A
	mov RSP, RBP

	;Parametros = unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size
	;RDI = src (puntero a char)
	;RSI = dst (puntero a char)
	;EDX = cols (entero)
	;ECX = filas (entero)
	;R8D = src_row_size (entero)
	;R9D = dst_row_size (entero)

	;Debo recorrer filas * cols pixeles
	xor R10, R10	;Offset de fila
	xor R11, R11 	;Offset total (offset de fila + offset columna)
	xor RAX, RAX	;Contador de columnas temporal

	.ciclo_filas:
		xor R11, R11
		mov R11D, R10D
		mov EAX, EDX
		.ciclo_cols:
			movdqu XMM0, [RDI + R11] ;En R11 tengo R10 (el offset de la fila en la que estoy parado) + 16 * [cantidad de paquetes de pixeles procesados]
			;Hacer cosas con el paquete

		;Cuando termino de trabajar con el paquete de pixeles de la posicion i, me muevo a la posicion i + 4 (que esta 16 bytes mas adelante)
		add R11, 16
		sub EAX, 4
		cmp EAX, 0
		jne .ciclo_cols
	;Cuanto termino de ciclar las columnas de la fila i, voy a la fila i + 1 (que comienza en [i+1]*src_row_size)
	add R10D, R8D
	dec ECX
	cmp ECX, 0
	jne .ciclo_filas

	pop RBP
	ret