#include "tdt.h" // ME FALTA AGREGAR LA ULTIMA FUNCION Y ARREGLAR UN PAR DE COSITAS

void tdt_agregar(tdt* tabla, uint8_t* clave, uint8_t* valor){
	
	if(tabla->primera == NULL){
		struct tdtN1_t* subtabla = malloc(sizeof(struct tdtN1_t)); //si es el primero elemento que agrego creo la primera subtabla
		int i = 0;
		while(i<256){//Debo recorrer toda mi subtabla poniendo null en todo el arreglo
		    subtabla->entradas[i] = NULL;
		    i = i+1;
		}
		tabla->primera = subtabla;
		struct tdtN2_t* subtabla2 = malloc(sizeof(struct tdtN2_t)); //ahora debo crear mi subtabla 2 setearla en 0 y asignarla en la tabla 1 donde corresponda
		i = 0;
		while(i<256) {
		    subtabla2->entradas[i] = NULL;
		    i = i +1;
		}
		tabla->primera->entradas[clave[0]] = subtabla2;
		struct tdtN3_t* subtabla3 = malloc(sizeof(struct tdtN3_t));//Ahora debo crear mi ultima tabla y poner ahi mi valor! con0
		
		i = 0;
		int f=0;
		while(i<256){
			f = 0;
			while(f < 15) {
			    subtabla3->entradas[i].valor.val[f] = 0;
			    f= f+1;
			}
			subtabla3->entradas[i].valido = 0;
			i=i+1;
		}
		subtabla3->entradas[clave[2]].valido = 1;
		f = 0;
		while(f < 15) {
			    subtabla3->entradas[clave[2]].valor.val[f] = valor[f];
			    f= f+1;
		}
		tabla->primera->entradas[clave[0]]->entradas[clave[1]] = subtabla3;
		tabla->cantidad = tabla->cantidad +1;	
	}else{
		if(tabla->primera->entradas[clave[0]] == NULL){
			struct tdtN2_t* subtabla2 = malloc(sizeof(struct tdtN2_t));
			int i = 0;
			while(i<256) {
		    subtabla2->entradas[i] = NULL;
		    i = i +1;
			}
			tabla->primera->entradas[clave[0]] = subtabla2;
			struct tdtN3_t* subtabla3 = malloc(sizeof(struct tdtN3_t));//Ahora debo crear mi ultima tabla y poner ahi mi valor! con0
			
			i = 0;
			int f=0;
			while(i<256){
				f = 0;
				while(f < 15) {
				    subtabla3->entradas[i].valor.val[f] = 0;
				    f= f+1;
				}
				subtabla3->entradas[i].valido = 0;
				i=i+1;
			}
			subtabla3->entradas[clave[2]].valido = 1;
			f = 0;
			while(f < 15) {
				    subtabla3->entradas[clave[2]].valor.val[f] = valor[f];
				    f= f+1;
			}
			tabla->primera->entradas[clave[0]]->entradas[clave[1]] = subtabla3;
			tabla->cantidad = tabla->cantidad +1;	
		}else{//EXISTE MI PRIMERA TABLA AHORA VEAMOS 
			if(tabla->primera->entradas[clave[0]]->entradas[clave[1]] == NULL){//no existe la tabla 3
					struct tdtN3_t* subtabla3 = malloc(sizeof(struct tdtN3_t));//Ahora debo crear mi ultima tabla y poner ahi mi valor! con0
					int i = 0;
					int f=0;
					while(i<256){
						f = 0;
						while(f < 15) {
						    subtabla3->entradas[i].valor.val[f] = 0;
						    f= f+1;
						}
						subtabla3->entradas[i].valido = 0;
						i=i+1;
					}
					//Seteo mi valor
					subtabla3->entradas[clave[2]].valido = 1;
					f = 0;
					while(f < 15) {
						subtabla3->entradas[clave[2]].valor.val[f] = valor[f];
						 f= f+1;
					}
					
					tabla->primera->entradas[clave[0]]->entradas[clave[1]]= subtabla3;
					tabla->cantidad = tabla->cantidad +1;

			}else{//EXISTE LA TABLA 3

				if(tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valido == 1){
						
						printf("QUE HACES PAPA SETEANDO UN VALOR EXISTENTE DENUNCIADO DESPEDITE DE TU TDT\n");
						int f=0;
						while(f < 15) {
						    tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valor.val[f] = valor[f];
						    f= f+1;
						}

					}else{

						tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valido = 1;
						int f=0;
						while(f < 15) {
					    tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valor.val[f] = valor[f];
					    f= f+1;
						}

						tabla->cantidad = tabla->cantidad +1; 	
					}
			}
		}		
	}
	 
}

void tdt_borrar(tdt* tabla, uint8_t* clave) {

	if(tabla->primera != NULL){
		if(tabla->primera->entradas[clave[0]] != NULL){

	if (tabla->primera->entradas[clave[0]]->entradas[clave[1]] !=NULL){
		
		tabla->cantidad = tabla->cantidad -1;
		int f=0;
		while(f < 15) {
		    tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valor.val[f] = 0;
		    f= f+1;
		}
		tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valido = 0;
		int hayAlgo = 0;
		int i = 0;
		while(i < 256){
		   hayAlgo = hayAlgo || (tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[i].valido == 1);
		    i = i+1;
		}
		if(hayAlgo==0){
			//BORRAR
			free(tabla->primera->entradas[clave[0]]->entradas[clave[1]]);
			tabla->primera->entradas[clave[0]]->entradas[clave[1]] = NULL;
			i = 0;
			hayAlgo = 0;
			while(i<256){
				hayAlgo = hayAlgo || (tabla->primera->entradas[clave[0]]->entradas[i] != NULL);
				i = i +1;
			}
			if(hayAlgo==0){
				free(tabla->primera->entradas[clave[0]]);
				tabla->primera->entradas[clave[0]] = NULL;
				i = 0;
				hayAlgo = 0;
				while(i < 256){
				    hayAlgo = hayAlgo || (tabla->primera->entradas[i] != NULL);
				    i = i +1;
				}
				if(!hayAlgo){
					free(tabla->primera);
					tabla->primera = NULL;
				}
			}

		}

	}else{
		printf("Estas Borrando ALGo que no existe\n");
	}

}else{
	printf("Estas Borrando ALGo que no existe\n");
}	
	}else{
		printf("Estas Borrando ALGo que no existe\n");
	}
	
}

void tdt_imprimirTraducciones(tdt* tabla, FILE* pFile) {
	fprintf(pFile,"- %s -\n",tabla->identificacion);
	if(tabla->primera != NULL){
		int i = 0;
		while(i < 256) {
		    if(tabla->primera->entradas[i] != NULL){
		    	int f = 0;
		    	while(f < 256) {
		    	   if (tabla->primera->entradas[i]->entradas[f] != NULL){
		    	   		int k = 0;
		    	   		while(k < 256) {
		    	   			if (tabla->primera->entradas[i]->entradas[f]->entradas[k].valido != 0){ 
		    	   				fprintf(pFile,"%02X%02X%02X => ",i,f,k );
		    	   				int numeros = 0;
		    	   				while(numeros < 15) {
		    	   					fprintf(pFile,"%02X",tabla->primera->entradas[i]->entradas[f]->entradas[k].valor.val[numeros]);
		    	   				    numeros = numeros +1;
		    	   				}
		    	   				fprintf(pFile,"\n");
		    	   			
		    	   			}
		    	   		    k = k +1;
		    	   		}
		    	   }
		    	   f = f+1;
		    	}
		    }
		    i = i+1;
		}
	}
}

maxmin* tdt_obtenerMaxMin(tdt* tabla) {

	struct maxmin* init = calloc(1,sizeof(maxmin));

	
		
	


  return init;
}
