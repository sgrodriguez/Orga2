#include "tdt.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
/*
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

*/

void printmaxmin(FILE *pFile, tdt* tabla) {
    int i;
    maxmin *mm = tdt_obtenerMaxMin(tabla);
    fprintf(pFile,"max_clave = %i",mm->max_clave[0]);
    for(i=1;i<3;i++) fprintf(pFile,"-%i",mm->max_clave[i]);
    fprintf(pFile,"\n");
    fprintf(pFile,"min_clave = %i",mm->min_clave[0]);
    for(i=1;i<3;i++) fprintf(pFile,"-%i",mm->min_clave[i]);
    fprintf(pFile,"\n");
    fprintf(pFile,"max_valor = %i",mm->max_valor[0]);
    for(i=1;i<15;i++) fprintf(pFile,"-%i",mm->max_valor[i]);
    fprintf(pFile,"\n");
    fprintf(pFile,"min_valor = %i",mm->min_valor[0]);
    for(i=1;i<15;i++) fprintf(pFile,"-%i",mm->min_valor[i]);
    fprintf(pFile,"\n");
    free(mm);
}


int main (void){

tdt* tabla = tdt_crear("pepe");

   FILE * pFile;

    pFile = fopen ("ej2.txt", "a");

    uint8_t clave1[3] = {0,0,0};
    uint8_t valor1[15] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
    uint8_t clave2[3] = {255,255,255};
    uint8_t valor2[15] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


    bloque b1 = {{5,5,5},{18,52,86,120,154,188,222,241,35,69,103,137,171,205,239}};
    bloque b2 = {{255,255,255},{17,34,51,68,85,102,119,136,153,170,187,204,221,238,255}};
    bloque b3 = {{83,255,170},{17, 18, 34, 51, 52, 68, 85, 86, 102, 119, 120, 136, 153, 154, 170}};
    bloque b4 = {{16,238,5},{17, 17, 34, 34, 51, 51, 68, 68, 85, 85, 102, 102, 119, 119, 136}};

    bloque* b[5] = {&b1,&b2,&b3,&b4,0};



    tdt_agregar(tabla, clave1, valor1);
    tdt_agregar(tabla, clave2, valor2);
  	tdt_agregarBloques(tabla,(bloque**)&b);
    tdt_borrarBloque(tabla, &b2);
    tdt_borrarBloque(tabla, &b3);
    
   printmaxmin(pFile, tabla);
   tdt_imprimirTraducciones(tabla, pFile);
   fprintf(pFile, "%i\n", tabla->cantidad);

  

    tdt_destruir(&(tabla));

  fclose(pFile);

    return 0;    
}
