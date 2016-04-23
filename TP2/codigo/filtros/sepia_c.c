
#include "../tp2.h"


void sepia_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    unsigned short suma;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
            *p_d = *p_s;
            suma = p_s->r + p_s->g + p_s->b;
            p_d->r = (suma * 0.5 > 255) ? 255 : (suma * 0.5);
            p_d->g = (suma * 0.3 > 255) ? 255 : (suma * 0.3);
            p_d->b = (suma * 0.2 > 255) ? 255 : (suma * 0.2);
            p_d->a = p_s->a;
        }
    }	//COMPLETAR

    /*for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            suma = p_d->r + p_d->g + p_d->b
            p_d->r = (unsigned char) suma * 0.5
            p_d->g = (unsigned char) suma * 0.3
            p_d->b = (unsigned char) suma * 0.2
        }
    }*/
}


