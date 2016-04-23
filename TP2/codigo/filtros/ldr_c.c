
#include "../tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2

void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
	int alpha)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    //Un unsigned short (2 bytes) alcanza para almacenar la sumaij porque el valor maximo es (0xFF * 25) = 0x18E7, que son 2 bytes
    unsigned short suma;
    int ldr;
    int max = 5 * 5 * 255 * 3 * 255;
    bgra_t* p_temp;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];

            //Si es un caso borde se mantiene el color del source
            if (i < 2 || i > filas - 2 || j < 2 || j > cols - 2)
                *p_d = *p_s;
            else {
                //Si no:
                suma = 0;
                for (int i1 = i - 2; i1 <= i + 2; i1++){
                    for (int j1 = j - 2; j1 <= j + 2; j1++){
                        p_temp = (bgra_t*) &src_matrix[i1][j1 * 4];
                        suma = suma + p_temp->r + p_temp->g + p_temp->b;
                    }
                }

                ldr = p_s->r + ((alpha * suma * p_s->r) / max);
                p_d->r = (ldr < 0) ? 0 : ((ldr > 255) ? 255 : ldr);
                ldr = p_s->g + ((alpha * suma * p_s->g) / max);
                p_d->g = (ldr < 0) ? 0 : ((ldr > 255) ? 255 : ldr);
                ldr = p_s->b + ((alpha * suma * p_s->b) / max);
                p_d->b = (ldr < 0) ? 0 : ((ldr > 255) ? 255 : ldr);
                p_d->a = p_s->a;
            }

        }
    }
}


