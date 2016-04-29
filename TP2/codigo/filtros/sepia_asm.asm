section .data
DEFAULT REL

section .rodata
constantes_mult: dd 0.2, 0.3, 0.5, 1.0

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
	movdqu XMM15, [constantes_mult]
	pxor XMM14, XMM14 ;Lo uso para extender la precision
	.ciclo_filas:
		xor R11, R11
		mov R11D, R10D
		mov EAX, EDX
		.ciclo_cols:
			;En R11 tengo R10 (el offset de la fila en la que estoy parado) + 16 * [cantidad de paquetes de pixeles procesados]
			
			;Traigo el paquete de pixeles a XMM0 y XMM1
			movdqu XMM0, [RDI + R11] 	; XMMO = [ a3 | r3 | g3 | b3 || a2 | r2 | g2 | b2 || a1 | r1 | g1 | b1 || a0 | r0 | g0 | b0 ]
			movdqu XMM1, XMM0

			;Aumento precision de Byte a Word para todos canales de los pixeles (sino no puedo hacer la suma de RGB sin asegurarme que no haya OVERFLOW)
			punpcklbw XMM1, XMM14		; XMM1 = [ a1 | r1 | g1 | b1 || a0 | r0 | g0 | b0 ]
			punpckhbw XMM0, XMM14		; XMM0 = [ a3 | r3 | g3 | b3 || a2 | r2 | g2 | b2 ]
			
			;Sumo los valores de R, G y B de los 2 pixeles de XMM1, y distrubuyo esa suma a todos los canales (excepto alpha)
			movdqu XMM2, XMM1			; XMM2 = [ a1 | r1 | g1 | b1 || a0 | r0 | g0 | b0 ]
			psrlq XMM2, 16				; XMM2 = [  0 | a1 | r1 | g1 ||  0 | a0 | r0 | g0 ]
			paddusw XMM1, XMM2			; XMM1 = [ a1 |  - |  - | b1 + g1 || a0 |  - |  - | b0 + g0 ]
			psrlq XMM2, 16				; XMM2 = [  0 |  0 | a1 | r1 ||  0 |  0 | a0 | r0 ]
			paddusw XMM1, XMM2			; XMM1 = [ a1 |  - |  - | b1 + g1 + r1 || a0 |  - |  - | b0 + g0 + r0 ]	** bi + gi + ri = si
			pshuflw XMM1, XMM1, 0xC0	; XMM1 = [ a1 |  - |  - | b1 + g1 + r1 || a0 | s0 | s0 | s0 ]
			pshufhw XMM1, XMM1, 0xC0	; XMM1 = [ a1 | s1 | s1 | s1 || a0 | s0 | s0 | s0 ]

			;Metodo 1, convierto XMM1 de Word a D-Word, y de D-Word a Float de precision simple, realizo la multiplicacion, y vuelvo a Word
			movdqu XMM2, XMM1
			punpcklwd XMM1, XMM14		; XMM1 = [ a0 | s0 | s0 | s0 ]
			punpckhwd XMM2, XMM14		; XMM2 = [ a1 | s1 | s1 | s1 ]
			cvtdq2ps XMM3, XMM1			; XMM3 = [ a0 | s0 | s0 | s0 ] * floats
			cvtdq2ps XMM4, XMM2			; XMM4 = [ a1 | s1 | s1 | s1 ] * floats
			mulps XMM4, XMM15			; XMM4 = [ a1 * 1.0 | s1 * 0.5 | s1 * 0.3 | s1 * 0.2 ] * floats
			mulps XMM3, XMM15			; XMM3 = [ a0 * 1.0 | s0 * 0.5 | s0 * 0.3 | s0 * 0.2 ] * floats
			cvtps2dq XMM2, XMM4			; XMM2 = [ a1 * 1.0 | s1 * 0.5 | s1 * 0.3 | s1 * 0.2 ]
			cvtps2dq XMM1, XMM3			; XMM1 = [ a0 * 1.0 | s0 * 0.5 | s0 * 0.3 | s0 * 0.2 ] ** Le agrego un _s a los canales ya procesados
			packusdw XMM1, XMM2			; XMM1 = [ a1_s | r1_s | g1_s | b1_s || a0_s | r0_s | g0_s | b0_s ]

			;Sumo los valores de R, G y B de los 2 pixeles de XMM0, y distrubuyo esa suma a todos los canales (excepto alpha)
			movdqu XMM2, XMM0			; XMM2 = [ a3 | r3 | g3 | b3 || a2 | r2 | g2 | b2 ]
			psrlq XMM2, 16				; XMM2 = [  0 | a3 | r3 | g3 ||  0 | a2 | r2 | g2 ]
			paddusw XMM0, XMM2			; XMM0 = [ a3 |  - |  - | b3 + g3 || a2 |  - |  - | b2 + g2 ]
			psrlq XMM2, 16				; XMM2 = [  0 |  0 | a3 | r3 ||  0 |  0 | a2 | r2 ]
			paddusw XMM0, XMM2			; XMM0 = [ a3 |  - |  - | b3 + g3 + r3 || a2 |  - |  - | b2 + g2 + r2 ]	** bi + gi + ri = si
			pshuflw XMM0, XMM0, 0xC0	; XMM0 = [ a3 |  - |  - | b3 + g3 + r3 || a2 | s2 | s2 | s2 ]
			pshufhw XMM0, XMM0, 0xC0	; XMM0 = [ a3 | s3 | s3 | s3 || a2 | s2 | s2 | s2 ]

			;Metodo 1, convierto XMM2 de Word a D-Word, y de D-Word a Float de precision simple, realizo la multiplicacion, y vuelvo a Word
			movdqu XMM2, XMM0			
			punpcklwd XMM0, XMM14		; XMM0 = [ a2 | s2 | s2 | s2 ]
			punpckhwd XMM2, XMM14		; XMM2 = [ a3 | s3 | s3 | s3 ]
			cvtdq2ps XMM3, XMM0			; XMM3 = [ a2 | s2 | s2 | s2 ]
			cvtdq2ps XMM4, XMM2			; XMM4 = [ a3 | s3 | s3 | s3 ]
			mulps XMM4, XMM15			; XMM4 = [ a3 * 1.0 | s3 * 0.5 | s3 * 0.3 | s3 * 0.2 ] * floats
			mulps XMM3, XMM15			; XMM3 = [ a2 * 1.0 | s2 * 0.5 | s2 * 0.3 | s2 * 0.2 ] * floats
			cvtps2dq XMM2, XMM4			; XMM2 = [ a3 * 1.0 | s3 * 0.5 | s3 * 0.3 | s3 * 0.2 ]
			cvtps2dq XMM0, XMM3			; XMM0 = [ a2 * 1.0 | s2 * 0.5 | s2 * 0.3 | s2 * 0.2 ] ** Le agrego un _s a los canales ya procesados
			packusdw XMM0, XMM2			; XMM0 = [ a3_s | r3_s | g3_s | b3_s || a2_s | r2_s | g2_s | b2_s ]

			;Re-empaqueto de Word a Byte con saturacion
			packuswb XMM1, XMM0			; XMM1 = [ a3_s | r3_s | g3_s | b3_s || a2_s | r2_s | g2_s | b2_s || a1_s | r1_s | g1_s | b1_s || a0_s | r0_s | g0_s | b0_s ]
			movdqu [RSI + R11], XMM1	;Guardo en memoria


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