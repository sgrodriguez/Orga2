
global ldr_asm

section .data

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

	pxor XMM15, XMM15 ;Lo uso para extender la precision
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
			;Traigo el paquete de pixels de source a XMM0
			movdqu XMM0, [RDI + R11] 	; XMMO = [ a3 | r3 | g3 | b3 || a2 | r2 | g2 | b2 || a1 | r1 | g1 | b1 || a0 | r0 | g0 | b0 ]


		;Cuando termino de trabajar con el paquete de pixels de la posicion i, me muevo a la posicion i + 4 (que esta 16 bytes mas adelante)
		add R11, 16
		sub EAX, 4
		cmp EAX, 0
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
	pop R12
	pop RBP
    ret
 
