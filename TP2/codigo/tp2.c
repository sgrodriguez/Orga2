
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <math.h>

#include "tp2.h"
#include "helper/tiempo.h"
#include "helper/libbmp.h"
#include "helper/utils.h"
#include "helper/imagenes.h"

// ~~~ seteo de los filtros ~~~

#define N_ENTRADAS_cropflip 1
#define N_ENTRADAS_sepia 1
#define N_ENTRADAS_ldr 1

DECLARAR_FILTRO(cropflip)
DECLARAR_FILTRO(sepia)
DECLARAR_FILTRO(ldr)

filtro_t filtros[] = {
	DEFINIR_FILTRO(cropflip) ,
	DEFINIR_FILTRO(sepia) ,
	DEFINIR_FILTRO(ldr) ,
	{0,0,0,0,0}
};

// ~~~ fin de seteo de filtros. Para agregar otro debe agregarse ~~~
//    ~~~ una linea en cada una de las tres partes anteriores ~~~

// ~~~ Funciones auxiliares para medicion de tiempo ~~~

int comp (const void * elem1, const void * elem2) 
{
    unsigned long long int f = *((unsigned long long int*)elem1);
    unsigned long long int s = *((unsigned long long int*)elem2);
    return (f > s) - (f < s);
}

float standard_deviation(unsigned long long int data[], int n)
{
    unsigned long long int mean=0;
    float sum_deviation=0;
    int i;

    for(i=0; i<n;++i)
        mean += data[i];

    mean=mean/n;
    for(i=0; i<n;++i)
    	sum_deviation += (float) ((data[i]-mean)*(data[i]-mean));

    return (int) sqrt( (float) sum_deviation/n );
}

// ~~~ fin de funciones auxiliares para medicion de tiempo ~~~

int main( int argc, char** argv ) {

	configuracion_t config;
	config.dst.width = 0;

	procesar_opciones(argc, argv, &config);
	// Imprimo info
	if (!config.nombre)
	{
		printf ( "Procesando...\n");
		printf ( "  Filtro             : %s\n", config.nombre_filtro);
		printf ( "  Implementación     : %s\n", C_ASM( (&config) ) );
		printf ( "  Archivo de entrada : %s\n", config.archivo_entrada);
	}

	filtro_t *filtro = detectar_filtro(&config);

	if (filtro != NULL) {
		filtro->leer_params(&config, argc, argv);
		correr_filtro_imagen(&config, filtro->aplicador);
	}

	return 0;
}

filtro_t* detectar_filtro(configuracion_t *config)
{
	for (int i = 0; filtros[i].nombre != 0; i++)
	{
		if (strcmp(config->nombre_filtro, filtros[i].nombre) == 0)
			return &filtros[i];
	}

	fprintf(stderr, "Filtro desconocido\n");
	return NULL; // avoid C warning
}


void imprimir_tiempos_ejecucion(unsigned long long int start, unsigned long long int end, int cant_iteraciones) {
	unsigned long long int cant_ciclos = end-start;

	printf("Tiempo de ejecución:\n");
	printf("  Comienzo                          : %llu\n", start);
	printf("  Fin                               : %llu\n", end);
	printf("  # iteraciones                     : %d\n", cant_iteraciones);
	printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
	printf("  # de ciclos insumidos por llamada : %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);
}

//Nueva funcion que procesa todas las iteraciones y devuelve informacion mas precisa
void imprimir_tiempos_ejecucion_con_protocolo(unsigned long long int* tiempos, int cant_iteraciones) {
	//Metodo 1
	//unsigned long long int Q1, Q3, IQR;
	//int posicion;
	
	//Metodo 2
	float mean, sd;

	int outliers;
	unsigned long long int sum;
	outliers = 0;
	//Ordeno las iteraciones por su tiempo utilizado
	qsort(tiempos, cant_iteraciones, sizeof(unsigned long long int*), comp);


	//Metodo 1
	/*
	//Cuento outliers (que estan al final del arreglo) y hago sumatoria
	sum = 0;
	posicion = cant_iteraciones / 4;
	Q1 = tiempos[posicion];
	Q3 = tiempos[ ((cant_iteraciones > (posicion * 3)) ? (posicion * 3) : cant_iteraciones) ];
	IQR = Q3 - Q1;
	Q3 = (int) (Q3 + 1.5 * IQR);
	for (int i = 0; i < cant_iteraciones; i++){
		if (tiempos[i] > Q3)
			outliers++;
		else
			sum = sum + tiempos[i];
	}
	*/

	//Metodo 2
	for (int i = 0; i < cant_iteraciones; i++){
		sum = sum + tiempos[i];
	}
	mean = (float) sum / cant_iteraciones;
	sd = standard_deviation(tiempos, cant_iteraciones);

	sum = 0;
	for (int i = 0; i < cant_iteraciones; i++){
		if (tiempos[i] > mean + (unsigned long long int) (3 * sd))
			outliers++;
		else
			sum += tiempos[i];
	}

	printf("Tiempo de ejecución:\n");
	printf("Valores obtenidos descartando outliers:\n");
	//for (int i = 0; i < cant_iteraciones - outliers; i++)
	//	printf("%llu\n", tiempos[i]);
	printf("Promedio: %.3f\n", (float)sum/(float)(cant_iteraciones-outliers));

}

void correr_filtro_imagen(configuracion_t *config, aplicador_fn_t aplicador)
{
	snprintf(config->archivo_salida, sizeof  (config->archivo_salida), "%s/%s.%s.%s%s.bmp",
             config->carpeta_salida, basename(config->archivo_entrada),
             config->nombre_filtro,  C_ASM(config), config->extra_archivo_salida );

	if (config->nombre)
	{
		printf("%s\n", basename(config->archivo_salida));
	}
	else
	{
		imagenes_abrir(config);
		unsigned long long start, end;

		unsigned long long int *tiempos;
		unsigned long long int tiempo_iteracion;
		tiempos = malloc(sizeof(unsigned long long) * config->cant_iteraciones);


		for (int i = 0; i < config->cant_iteraciones; i++) {
			MEDIR_TIEMPO_START(start)
				aplicador(config);
			MEDIR_TIEMPO_STOP(end)
			tiempo_iteracion = (end - start);
			tiempos[i] = tiempo_iteracion;
		}
		



		imagenes_guardar(config);
		imagenes_liberar(config);
		//imprimir_tiempos_ejecucion(start, end, config->cant_iteraciones);
		imprimir_tiempos_ejecucion_con_protocolo(tiempos, config->cant_iteraciones);

		free(tiempos);
	}
}
