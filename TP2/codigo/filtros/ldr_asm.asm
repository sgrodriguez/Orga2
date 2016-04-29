
global ldr_asm

section .data
max: dd 4876875.0	;Float por el cual hay que dividir (max)

;Mascara que uso para hacer 0 los alpha de todos los pixels dentro de un registro XMM
shuf_mascara_cero_alpha: db 0x00, 0x01, 0x02, 0xFF, 0x04, 0x05, 0xFF, 0x07, 0x08, 0x09, 0xFF, 0x0B, 0x0C, 0x0E, 0xFF

section .text
;void ldr_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size,
	;int alpha)

ldr_asm:
	push RBP		;A
	mov RBP, RSP
	push R12		;D
	push RBX		;A
	push R13		;D
	sub RSP, 8		;A

	;RDI = src
	;RSI = dst
	;EDX = filas
	;ECX = cols
	;R8D = src_row_size
	;R9D = dst_row_size
	;DWORD [RBP + 16] = alpha	([RBP + 0] = RBP anterior, [RBP + 8] = Direccion de retorno, [RBP + 16] = primer parametro de pila)

	;Debo recorrer filas * cols pixels
	xor R10, R10	;Offset de fila
	xor R11, R11 	;Offset total (offset de fila + offset columna)
	xor RAX, RAX	;Contador de columnas temporal

	xor RBX, RBX	;Filas original
	mov EBX, EDX

	xor R12, R12 	;Para hacer calculos para ver cuando estoy en caso borde

	xor R13, R13	;Contador de filas para el calculo de los vecinos

	pxor XMM15, XMM15 ;Lo uso para extender la precision
	insertps XMM14, [max], 00001110		; XMM14 = [ 0 | 0 | 0 | max ]
	.ciclo_filas:
		xor R11, R11
		mov R11D, R10D
		mov EAX, ECX

		;Si estoy en la fila 0, 1, filas-2 o filas-1 entonces tengo que copiar src a dst
		;En EDX si estoy en la fila i tengo filas-i, y en EBX tengo filas, entonces tengo que copiar src a dst si: (i = fila actual, f = filas)
		;1) EDX = EBX (EDX = f => EDX = f - 0 => i = 0)
		;2) EDX = EBX - 1 (EDX = f - 1 => i = 1)
		;3) EDX = 2 (EDX = f - (f - 2) => i = f - 2)
		;4) EDX = 1 (EDX = f - (f - 1) => i = f - 1) ;Los ultimos 2 se pueden resumir como EDX <= 2
		cmp EDX, EBX		;1)
		je .ciclo_copiado
		xor R12, R12
		mov R12D, EBX
		dec R12D
		cmp EDX, R12D		;2)
		je .ciclo_copiado
		xor R12, R12
		mov R12D, 2
		cmp EDX, R12D		;3) y 4)
		jle .ciclo_copiado

		.ciclo_cols_ldr:
			;En R11 tengo R10 (el offset de la fila en la que estoy parado) + 16 * [cantidad de paquetes de pixels procesados]

			;Si estoy en la columna 0, 1, cols-2 o cols-1 entonces tengo que copiar src a dst (solo 8 bytes = 2 pixels)
			;En EAX si estoy en la col i tengo cols-i, y en ECX tengo cols, entonces tengo que copiar src a dst si: (i = col actual, f = col)
			;Como en .ciclo_cols_ldr_copiado proceso 2 pixels, los unicos casos que van a ocurrir son el 1) y el 3)
			;1) EAX = ECX (EAX = c => EAX = c - 0 => i = 0)
			;2) EAX = ECX - 1 (EAX = c - 1 => i = 1)
			;3) EAX = 2 (EAX = c - (c - 2) => i = c - 2)
			;4) EAX = 1 (EAX = c - (c - 1) => i = c - 1) ;Los ultimos 2 se pueden resumir como EAX <= 2
			cmp EAX, ECX		;1) => 2)
			je .ciclo_cols_ldr_copiado
			xor R12, R12
			mov R12D, 2
			cmp EAX, R12D		;3) y 4)
			jle .ciclo_cols_ldr_copiado
			
			;==============A PARTIR DE ACA TRABAJO CON EL FILTRO LDR REALMENTE==============
			;Voy a usar R12 para direccionar a las posiciones en las cuales me tengo que traer los paquetes, que son las siguientes: (s = src_row_size)
			; | R11+2s-2 | R11+2s-1 | R11+2s+0 | R11+2s+1 || R11+2s+2 | R11+2s+3 | R11+2s+4 | R11+2s+5 |
			; | R11+1s-2 | R11+1s-1 | R11+1s+0 | R11+1s+1 || R11+1s+2 | R11+1s+3 | R11+1s+4 | R11+1s+5 |
			; | R11+0s-2 | R11+0s-1 | R11+0s+0 | R11+0s+1 || R11+0s+2 | R11+0s+3 | R11+0s+4 | R11+0s+5 |
			; | R11-1s-2 | R11-1s-1 | R11-1s+0 | R11-1s+1 || R11-1s+2 | R11-1s+3 | R11-1s+4 | R11-1s+5 |
			; | R11-2s-2 | R11-2s-1 | R11-2s+0 | R11-2s+1 || R11-2s+2 | R11-2s+3 | R11-2s+4 | R11-2s+5 |

			;El paquete que voy a procesar son los 4 pixeles que se encuentran a partir de R11+0s+0, con p0 y p1 en la parte mas significativa de XMM4, y p2 y p3 en la menos significativa de XMM5
			;Toda esta informacion se trae con 10 copias a registros XMM desde memoria.
			;Si quisiera procesar 1 pixel, deberia hacer 10 accesos a memoria de todas formas, ya que son 5 lineas de informacion (que estan separadas en memoria), 
			;	y 5 pixels por linea de informacion, que no entran en un solo registro XMM (20 bytes, registros XMM solo pueden traer 16 bytes).

			;Voy a la punta inferior izquierda de la grilla de vecinos
			mov R12, R11
			sub R12, 8
			sub R12, R8D
			sub R12, R8D
			;R12 = R11 - 2s - 2

			;Procesando de a 1 pixel
			pxor XMM2, XMM2 ;Acumulador
			xor R13, R13	;Contador

			.ciclo_vecinos:
				cmp R13, 2 ;Estoy en la fila del medio, por lo que aprovecho y me traigo a XMM10 los pixeles que voy a modificar
				jne .ciclo_vecinos_continuar
					;Pongo en XMM10 los 4 pixeles que voy a tener que volver a guardar en memoria:
					pblendw XMM10, XMM0, 01010000b ; XMM10 = [ p1 | p0 | . | . ]
					pblendw XMM10, XMM1, 00000101b ; XMM10 = [ p1 | p0 | p3 | p2 ]
					pshufd XMM10, XMM10, 00011110b ; XMM10 = [ p3 | p2 | p1 | p0 ]
				.ciclo_vecinos_continuar:

				;Traigo fila
				movdqu XMM0, [RDI + R12]
				movdqu XMM1, [RDI + R12 + 16]

				;Hago cero los pixels inutiles
				pxor XMM6, XMM6					; XMM6 = [ 0  | 0  | 0  | 0  ]
				pblendw XMM6, XMM0, 00000001b	; XMM6 = [ 0  | 0  | 0  | p4 ]

				pxor XMM7, XMM7					; XMM7 = [ 0  | 0  | 0  | 0  ]
				pblendw XMM7, XMM1, 01010101b	; XMM7 = [ p3 | p2 | p1 | p0 ]

				;Hago la sumaRGB de la fila
				movdqu XMM8, XMM6				; XMM8 = XMM6
				punpckhbw XMM8, XMM15 			; XMM8 = [ p7 | p6 ]
				punpcklbw XMM6, XMM15			; XMM6 = [ p5 | p4 ]

				movdqu XMM9, XMM7				; XMM9 = XMM7
				punpckhbw XMM9, XMM15 			; XMM9 = [ p3 | p2 ]
				punpcklbw XMM7, XMM15			; XMM7 = [ p1 | p0 ]

				paddusw XMM6, XMM8				; XMM6 = [ p3 + p1 | p0 + p2 ] - Sumados canal a canal
				paddusw XMM7, XMM9				; XMM7 = [ p7 + p5 | p6 + p4 ]
				paddusw XMM6, XMM7				; XMM6 = [ p3 + p1 + p7 + p5 | p0 + p2 + p6 + p4 ]
				movdqu XMM7, XMM6				; XMM7 = XMM6
				psrldq XMM7, 64					; XMM7 = [ 0				 | p3 + p1 + p7 + p5 ]
				paddusw XMM6, XMM7				; XMM6 = [ *				 | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 ]
												; XMM6 = [ 64 bits || a_s | r_s | g_s | b_s ]	- Tengo las sumas de A, R, G y B en las 3 words menos significativas
				movdqu XMM7, XMM6				; XMM7 = XMM6
				psrlq XMM7, 16					; XMM7 = [ 64 bits || 0   | a_s | r_s | g_s ]
				paddusw XMM6, XMM7				; XMM6 = [ 64 bits || a_s |  *  | r_s + g_s | g_s + b_s ]
				psrlq XMM7, 16					; XMM7 = [ 64 bits || 0   | 0   | a_s | r_s ]
				paddusw XMM6, XMM7				; XMM6 = [ 64 bits || a_s |  *  |  *  | r_s + g_s + b_s ] - Tengo la suma de R,G y B entre si en la word menos significativa

				;Acumulo en XMM2
				paddusw XMM2, XMM6
			inc R13
			add R12, R8D
			cmp R13, 5
			jl .ciclo_vecinos
			
			;Convierto a float el valor de sumargb

			;Necesito ademas el valor de alpha en float y el valor de max, multiplico todo y divido y luego multiplico por la identidad y transformo a entero nuevamente

			;Procesando de a 4 pixels


		;Procesando de a 1 pixel
		add R11, 4
		sub EAX, 1
		cmp EAX, 0
		;Procesando de a 4 pixels
		;Cuando termino de trabajar con el paquete de pixels de la posicion i, me muevo a la posicion i + 4 (que esta 16 bytes mas adelante)
		;add R11, 16
		;sub EAX, 4
		;cmp EAX, 0
		jne .ciclo_cols_ldr
		jmp .ciclo_filas_continuar

		.ciclo_cols_ldr_copiado:	;Esta etiqueta es para copiar las 2 primeras y las 2 ultimas columnas de cada fila que si se procesa
			;Como 8 bytes es el size de un registro de proposito general, voy a usar uno para copiar de source a destino 2 pixels
			mov R12, [RDI + R11]
			mov [RSI + R11], R12

		add R11, 8	;Procese 2 pixels = avanzo 8 bytes
		sub EAX, 2	;Solo 2 columnas procesadas
		cmp EAX, 0
		jne .ciclo_cols_ldr
		jmp .ciclo_filas_continuar

		.ciclo_copiado:				;Esta etiqueta es para copiar todas las columnas de cada fila que no se procesa
			;En R11 tengo R10 (el offset de la fila en la que estoy parado) + 16 * [cantidad de paquetes de pixels procesados]

			;Traigo el paquete de pixels de la fuente a XMM0 y luego lo copio asi como esta al destino
			movdqu XMM0, [RDI + R11] 	; XMMO = [ a3 | r3 | g3 | b3 || a2 | r2 | g2 | b2 || a1 | r1 | g1 | b1 || a0 | r0 | g0 | b0 ]
			movdqu [RSI + R11], XMM0

		;Cuando termino de trabajar con el paquete de pixels de la posicion i, me muevo a la posicion i + 4 (que esta 16 bytes mas adelante)
		add R11, 16
		sub EAX, 4
		cmp EAX, 0
		jne .ciclo_copiado

		.ciclo_filas_continuar:
	;Cuanto termino de ciclar las columnas de la fila i, voy a la fila i + 1 (que comienza en [i+1]*src_row_size)
	add R10D, R8D
	dec EDX
	cmp EDX, 0
	jne .ciclo_filas

	
	add RSP, 8
	pop R13
	pop RBX
	pop R12
	pop RBP
    ret
 
;sumar_pixels:
	;push RBP			;A
	;mov RBP, RSP

	;Esta funcion toma como parametro dos registros XMM (XMM6 y XMM7) con pixels en precision BYTE, y los usa.
	;Devuelve en la word menos significativa de XMM6 la suma canal a canal de los pixels

	;pxor XMM15, XMM15
	
	; XMM6 = [ p7 | p6 | p5 | p4 ]
	; XMM7 = [ p3 | p2 | p1 | p0 ]

	;movdqu XMM8, XMM6				; XMM8 = XMM6
	;punpckhbw XMM8, XMM15 			; XMM8 = [ p7 | p6 ]
	;punpcklbw XMM6, XMM15			; XMM6 = [ p5 | p4 ]

	;movdqu XMM9, XMM7				; XMM9 = XMM7
	;punpckhbw XMM9, XMM15 			; XMM9 = [ p3 | p2 ]
	;punpcklbw XMM7, XMM15			; XMM7 = [ p1 | p0 ]

	;paddusw XMM6, XMM8				; XMM6 = [ p3 + p1 | p0 + p2 ] - Sumados canal a canal
	;paddusw XMM7, XMM9				; XMM7 = [ p7 + p5 | p6 + p4 ]
	;paddusw XMM6, XMM7				; XMM6 = [ p3 + p1 + p7 + p5 | p0 + p2 + p6 + p4 ]
	;movdqu XMM7, XMM6				; XMM7 = XMM6
	;psrldq XMM7, 64					; XMM7 = [ 0				 | p3 + p1 + p7 + p5 ]
	;paddusw XMM6, XMM7				; XMM6 = [ *				 | p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 ]
									; XMM6 = [ 64 bits || a_s | r_s | g_s | b_s ]	- Tengo las sumas de A, R, G y B en las 3 words menos significativas
	;movdqu XMM7, XMM6				; XMM7 = XMM6
	;psrlq XMM7, 16					; XMM7 = [ 64 bits || 0   | a_s | r_s | g_s ]
	;paddusw XMM6, XMM7				; XMM6 = [ 64 bits || a_s |  *  | r_s + g_s | g_s + b_s ]
	;psrlq XMM7, 16					; XMM7 = [ 64 bits || 0   | 0   | a_s | r_s ]
	;paddusw XMM6, XMM7				; XMM6 = [ 64 bits || a_s |  *  |  *  | r_s + g_s + b_s ] - Tengo la suma de R,G y B entre si en la word menos significativa

	; XMM6 = [ . | . | . | . | . | . | . | r_s + g_s + b_s ]

	;pop RBP
	;ret