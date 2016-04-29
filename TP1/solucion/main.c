#include "tdt.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main (void){
	
    tdt* tabla = tdt_crear("Tablita de Santigo");
    uint8_t clave1[3] = {1,2,3};
	uint8_t valor1[15] = {3,4,5,6,7,8,4,5,63,2,3,4,5,6,5};
	uint8_t clave2[3] = {2,2,2};
	uint8_t valor2[15] = {3,4,5,3,7,8,4,5,63,2,3,4,5,6,5};
	uint8_t clave3[3] = {15,2,3};
	uint8_t valor3[15] = {3,4,5,6,7,8,4,5,0,2,3,4,5,6,5};
	uint8_t clave4[3] = {8,9,3};
	uint8_t valor4[15] = {3,4,5,6,7,8,4,5,63,2,3,4,5,6,5};
	
	//bloque b1 = {{1,5,3},{3,4,5,6,7,8,4,5,6,2,3,4,5,0,5}};
	
	//bloque b2 = {{2,5,2},{3,4,5,3,7,8,4,3,0,2,0,4,5,6,5}};
	uint8_t valorEntrada1[15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	uint8_t valorEntrada2[15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	uint8_t valorEntrada3[15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	tdt_agregar(tabla, clave1, valor1);
	tdt_traducir(tabla,clave1,valorEntrada2);
	tdt_traducir(tabla,clave3,valorEntrada3);
	tdt_traducir(tabla,clave2,valorEntrada1);
	
	tdt_agregar(tabla, clave2, valor2);
	
	tdt_agregar(tabla, clave3, valor3);
	
	tdt_agregar(tabla, clave4, valor4);
	
	
	//tdt_borrar(tabla,clave1);

    tdt_destruir(&(tabla));
    
    return 0;    
}
