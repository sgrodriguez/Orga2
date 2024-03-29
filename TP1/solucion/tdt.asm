; FUNCIONES de C ////ME FALTA ARREGLAR UN PAR DE COSITAS////
  extern malloc
  extern free
  extern strcpy
  extern tdt_agregar
  extern tdt_borrar

; FUNCIONES
  global tdt_crear
  global tdt_recrear
  global tdt_cantidad
  global tdt_agregarBloque
  global tdt_agregarBloques
  global tdt_borrarBloque
  global tdt_borrarBloques
  global tdt_traducir
  global tdt_traducirBloque
  global tdt_traducirBloques
  global tdt_destruir

; /** defines offsets y size **/
  %define TDT_OFFSET_IDENTIFICACION   0
  %define TDT_OFFSET_PRIMERA          8
  %define TDT_OFFSET_CANTIDAD        16
  %define TDT_SIZE                   20
  NULL        EQU                     0
  %define TDT_OFFSET_PUNTERO          8
  %define TDT_SIZE_TABLA           2040
  %define SIZE_ARREGLO1               1
  %define SIZE_ARREGLO2               2
  %define TDT_SIZE_TN3                8
  %define BLOQUE_VALOR                3



section .text

; =====================================
; tdt* tdt_crear(char* identificacion)
tdt_crear:

    PUSH RBP
    MOV  RBP, RSP
    PUSH R12
    PUSH RBX

    XOR R12,R12
    XOR RBX,RBX
    MOV R12, RDI;ME GUARDO MI PUNTERO A CARACTER
  .cicloChar:
    CMP byte [RDI], NULL; TODO REVISAR
    JE  .segui
    INC RDI
    INC RBX
    JMP .cicloChar
  .segui:
    INC RBX
    MOV RDI, RBX
    call malloc
    MOV RDI, RAX
    MOV RSI, R12
    CALL strcpy
    MOV R12, RAX
    MOV RDI ,TDT_SIZE;LA CANTIDAD DE BYTES QUE QUIERO EN MI MALLLOC
    CALL malloc
    MOV [RAX+TDT_OFFSET_IDENTIFICACION], R12;LE ASIGNO EL PUNTERO A CARACTER AL PRIMER ESPACIO DE MI MALLLOC
    MOV qword [RAX+TDT_OFFSET_PRIMERA], NULL
    MOV dword [RAX+TDT_OFFSET_CANTIDAD], NULL

    POP RBX
    POP R12
    POP RBP
    RET

; =====================================
; void tdt_recrear(tdt** tabla, char* identificacion)
tdt_recrear:

    PUSH RBP
    MOV  RBP, RSP
    PUSH R12
    PUSH RBX

    XOR R12,R12
    XOR RBX,RBX
    MOV RBX, RDI;ME GUARDO MI PUNTERO A PUNTERO TABLA
    MOV R12, RSI;ME GUARDO MI PUNTERO A CARACTER
    CMP RSI, NULL
    JE .copiarAnterior
    CALL tdt_destruir
    MOV RDI,R12
    CALL tdt_crear
    MOV RDI, RBX
    MOV [RDI],RAX
    JMP .fin
    .copiarAnterior:
    MOV RDI, [RDI+TDT_OFFSET_IDENTIFICACION]
    CALL tdt_crear
    MOV R12,RAX
    MOV RDI, RBX
    CALL tdt_destruir
    MOV [RBX],R12
    JMP .fin

    .fin:

    POP RBX
    POP R12
    POP RBP
    RET

; =====================================
; uint32_t tdt_cantidad(tdt* tabla)
tdt_cantidad:

  MOV EAX, [RDI+TDT_OFFSET_CANTIDAD]
  RET

; =====================================
; void tdt_agregarBloque(tdt* tabla, bloque* b)
tdt_agregarBloque:
  PUSH RBP
  MOV RBP,RSP

  MOV R10,RSI
  ADD RSI,BLOQUE_VALOR
  MOV RDX,RSI
  MOV RSI,R10
  CALL tdt_agregar

  POP RBP
  RET
; =====================================
; void tdt_agregarBloques(tdt* tabla, bloque** b)
tdt_agregarBloques:
  PUSH RBP
  MOV RBP,RSP
  PUSH R12
  PUSH R13


  MOV R12,RDI
  MOV R13,RSI
  MOV R14,RSI
 .ciclo:
	  CMP qword [R14],NULL
	  JE .termine
	  MOV RDI,R12
	  MOV RSI,[R14]
	  CALL tdt_agregarBloque
	  ADD R14, TDT_OFFSET_PUNTERO
	  JMP .ciclo


  .termine:

  POP R13
  POP R12
  POP RBP
  RET

; =====================================
; void tdt_borrarBloque(tdt* tabla, bloque* b)
tdt_borrarBloque:
  PUSH RBP
  MOV RBP,RSP


  CALL tdt_borrar

  POP RBP
  RET
; =====================================
; void tdt_borrarBloques(tdt* tabla, bloque** b)
tdt_borrarBloques:

  PUSH RBP
  MOV RBP,RSP
  PUSH R12
  PUSH R13


  MOV R12,RDI
  MOV R13,RSI
  MOV R14,RSI
 .ciclo:
	  CMP qword [R14],NULL
	  JE .termine
	  MOV RDI,R12
	  MOV RSI,[R14]
	  CALL tdt_borrarBloque
	  ADD R14, TDT_OFFSET_PUNTERO
	  JMP .ciclo


  .termine:

  POP R13
  POP R12
  POP RBP
  RET

; =====================================
; void tdt_traducir(tdt* tabla, uint8_t* clave, uint8_t* valor)
tdt_traducir:
    PUSH RBP ;ALINIADO
    MOV  RBP, RSP
    PUSH R12;DesalineadO
    PUSH R13;ALINIADO
    PUSH R14;DesalineadO
    PUSH R15;Alineado
    PUSH rcx
    push r8

    XOR R8,R8
    XOR RAX,RAX
    XOR R12,R12
    XOR R13,R13
    XOR R14,R14
    xor rcx,rcx
    MOV R12, RDI;ME GUARDO MI PUNTERO A tabla
    MOV R13, RSI;ME GUARDO MI PUNTERO A CLAVE
    MOV R14, RDX;ME GUARDO MI PUNTERO A VALOR

    CMP qword [R12+TDT_OFFSET_PRIMERA], NULL
    JE .termine
    MOV R10,[R12+TDT_OFFSET_PRIMERA]
    MOV AL,[R13]
    CMP qword [R10+RAX*TDT_OFFSET_PUNTERO], NULL
    JE .termine
    MOV R11,[R10+RAX*TDT_OFFSET_PUNTERO]
    INC R13
    MOV AL,[R13];Comparo segunda tabla
    CMP qword [R11+RAX*TDT_OFFSET_PUNTERO], NULL
    JE .termine
    MOV R11,[R11+RAX*TDT_OFFSET_PUNTERO]
    INC R13
    MOV AL,[R13]
    SHL RAX,1
    MOV CL,[R11+RAX*8+15]
    CMP CL ,NULL
    JE .termine
    ;copio el valor a mi puntero valor.
    XOR R10,R10
    MOV R10, NULL
    lea R11,[R11+RAX*8];tengo la direccion de mi primer valor

 .cicloCopiar:
    xor rax,rax; ;uso temporalmente al para almacenar el valor
    mov al,[r11]
    mov [r14],al;en r14 que tengo mi puntero a uint8_t* valor pego mi valor
    inc r14 ;
    INC R11
    INC R10
    CMP R10, 15
    JE .termine
    JMP .cicloCopiar


  .termine:
    pop r8
    pop rcx
    POP R15
    POP R14
    POP R13
    POP R12
    POP RBP
    RET
 ;=====================================
; void tdt_traducirBloque(tdt* tabla, bloque* b)
tdt_traducirBloque:
  PUSH RBP
  MOV RBP,RSP

  lea RDX,[RSI+BLOQUE_VALOR]
  CALL tdt_traducir

  POP RBP
  RET
; =====================================
; void tdt_traducirBloques(tdt* tabla, bloque** b)
tdt_traducirBloques:

 PUSH RBP
  MOV RBP,RSP
  PUSH R12
  PUSH R13


  MOV R12,RDI
  MOV R13,RSI
  MOV R14,RSI
 .ciclo:
	  CMP qword [R14],NULL
	  JE .termine
	  MOV RDI,R12
	  MOV RSI,[R14]
	  CALL tdt_traducirBloque
	  ADD R14, TDT_OFFSET_PUNTERO
	  JMP .ciclo


  .termine:

  POP R13
  POP R12
  POP RBP
  RET

; =====================================
; void tdt_destruir(tdt** tabla)
tdt_destruir:


  PUSH RBP ;Aliniado
  MOV  RBP, RSP
  SUB  RSP,24;DAD
  PUSH R12;Desalineada
  PUSH R13;Aliniado
  PUSH R14;Desalineada
  PUSH R15;Aliniado
  PUSH RBX;Desalineada


  XOR R12,R12
  XOR R13,R13
  XOR R14,R14


  MOV R12,RDI;PUNTERO A PUNTERO DE tabla
  MOV R13,[RDI]; MI TABLA
  MOV R14, [R13+TDT_OFFSET_PRIMERA]; ME GUARDO MI PRIMERA
  CMP qword [R13+TDT_OFFSET_PRIMERA], NULL; SI MI TABLA ESTA VACIA PROCEDO A BORRAR MI TABLA ORIGINAL
  JE .borrarTabla
  XOR RCX,RCX
  XOR R15,R15


.borrarTabla1:            ; tengo que loopear toda mi array y en las poss donde es diferente de null entro y repito este procedimiento
  CMP  qword [R14], NULL
  JE  .seguirTabla1
  JMP .borrarTabla2

.seguirTabla1:
  ADD R14,TDT_OFFSET_PUNTERO
  ADD RCX,TDT_OFFSET_PUNTERO
  CMP RCX, TDT_SIZE_TABLA
  JG .borrarTabla
  JMP .borrarTabla1


.borrarTabla2:
  XOR R15, R15
  MOV R15, RCX; ME GUARDO MI RCX PARA CUANDO VUELVA AL LOOP ANTERIOR SEPA DONDE ESTOY EN EL ARRAY
  XOR RCX,RCX
  MOV RDI,[R14]
  MOV [RBP-8], RDI
  MOV [RBP-16],R14
  MOV R14, [R14]

  JMP .loopearTabla2

.loopearTabla2:
  CMP qword [R14],NULL
  JE .seguirTabla2
  MOV RDI, [R14]
  MOV RBX, RCX
  CALL free
  MOV RCX, RBX
  JMP .seguirTabla2


.seguirTabla2:
  ADD R14, TDT_OFFSET_PUNTERO
  ADD RCX, TDT_OFFSET_PUNTERO
  CMP RCX, TDT_SIZE_TABLA
  JG  .borrarTablaFinal2
  JMP .loopearTabla2


.borrarTablaFinal2:
  MOV RDI,[RBP-8]
  MOV R14,[RBP-16]
  CALL free
  MOV RCX, R15
  JMP .seguirTabla1
  ;BORRAR LA TALBA 2 Y VOLVER AL LOOP DE TABLA PRIMERA
  ;RESTABLECER RCX


.borrarTabla:

  MOV RDI, [R13+TDT_OFFSET_IDENTIFICACION]
  CALL free
  MOV RDI, [R13+TDT_OFFSET_PRIMERA]
  CALL free
  MOV RDI, [R12]
  CALL free

  ;BORRAR LA PRIMERA
  ;BORRAR EL STRING
  ;BORRAR TODA LA TABLA DE TRADUCCION


  POP RBX
  POP R15
  POP R14
  POP R13
  POP R12
  ADD RSP,24
  POP RBP
  ret
