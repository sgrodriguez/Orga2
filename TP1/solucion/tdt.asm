; FUNCIONES de C
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

    MOV RDI ,TDT_SIZE;LA CANTIDAD DE BYTES QUE QUIERO EN MI MALLLOC
    CALL malloc
    MOV qword [RAX+TDT_OFFSET_IDENTIFICACION], R12;LE ASIGNO EL PUNTERO A CARACTER AL PRIMER ESPACIO DE MI MALLLOC
    MOV qword [RAX+TDT_OFFSET_PRIMERA], NULL
    MOV word  [RAX+TDT_OFFSET_CANTIDAD], NULL
    
    POP RBX
    POP R12
    POP RBP
    RET

; =====================================
; void tdt_recrear(tdt** tabla, char* identificacion)
tdt_recrear:

; =====================================
; uint32_t tdt_cantidad(tdt* tabla)
tdt_cantidad:

  MOV RAX, [RDI+TDT_OFFSET_CANTIDAD]
  RET

; =====================================
; void tdt_agregarBloque(tdt* tabla, bloque* b)
tdt_agregarBloque:

; =====================================
; void tdt_agregarBloques(tdt* tabla, bloque** b)
tdt_agregarBloques:
        
; =====================================
; void tdt_borrarBloque(tdt* tabla, bloque* b)
tdt_borrarBloque:
        
; =====================================
; void tdt_borrarBloques(tdt* tabla, bloque** b)
tdt_borrarBloques:
        
; =====================================
; void tdt_traducir(tdt* tabla, uint8_t* clave, uint8_t* valor)
tdt_traducir:
        
; =====================================
; void tdt_traducirBloque(tdt* tabla, bloque* b)
tdt_traducirBloque:

; =====================================
; void tdt_traducirBloques(tdt* tabla, bloque** b)
tdt_traducirBloques:
        
; =====================================
; void tdt_destruir(tdt** tabla)
tdt_destruir:


