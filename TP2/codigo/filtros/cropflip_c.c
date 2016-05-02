
#include "../tp2.h"

void cropflip_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	int tamx,
	int tamy,
	int offsetx,
	int offsety)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	// ejemplo de uso de src_matrix y dst_matrix (copia una parte de la imagen)

	int i = 0;
	int j;

	while(i < tamy){
		j = 0;
		while(j < tamx){ 
	
			bgra_t *p_d = (bgra_t*)&dst_matrix[tamy-i-1][j * 4]; //PARA DARLOS VUELTA
            bgra_t *p_s = (bgra_t*)&src_matrix[offsety+i][(offsetx+j) * 4];

			p_d->b = p_s->b;
			p_d->g = p_s->g;
			p_d->r = p_s->r;
			p_d->a = p_s->a;
			j = j+1;
		}

		i = i+1;
	}

	//HACER LA QUE ME LA DA VUELTA


}
