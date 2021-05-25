//gcc -m32 -O0 -fpack-struct -std=c99 main.c -o main
#include "f.h"
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define OUTPUT_NAME "output.bmp"

#define BMP_HEADER_SIZE 54

#define BMP_PIXEL_OFFSET 54

#define BMP_PLANES 1

#define BMP_BPP 24

#define BMP_HORIZONTAL_RES 500

#define BMP_VERTICAL_RES 500

#define BMP_DIB_HEADER_SIZE 40

typedef struct {
    unsigned char sig_0;
    unsigned char sig_1;
    uint32_t size;
    uint32_t reserved;
    uint32_t pixel_offset;
    uint32_t header_size;
    uint32_t width;
    uint32_t height;
    uint16_t planes;
    uint16_t bpp_type;
    uint32_t compression;
    uint32_t image_size;
    uint32_t horizontal_res;
    uint32_t vertical_res;
    uint32_t color_plette;
    uint32_t important_colors;
} BmpHeader;

void init_bmp_header(BmpHeader *header)
{
    header->sig_0 = 'B';
    header->sig_1 = 'M';
    header->reserved = 0;
    header->pixel_offset = BMP_PIXEL_OFFSET;
    header->header_size = BMP_DIB_HEADER_SIZE;
    header->planes = BMP_PLANES;
    header->bpp_type = BMP_BPP;
    header->compression = 0;
    header->image_size = 0;
    header->horizontal_res = BMP_HORIZONTAL_RES;
    header->vertical_res = BMP_VERTICAL_RES;
    header->color_plette = 0;
    header->important_colors = 0;
}

void write_bytes_to_bmp(unsigned char *buffer, size_t size)
{
    FILE *file;

    file = fopen(OUTPUT_NAME, "wb");
    if (file == NULL)
    {
        printf("Error");
        exit(-1);
    }
    fwrite(buffer, 1, size, file);
    fclose(file);
}



unsigned char *generate_empty_bitmap(unsigned int width, unsigned int height, size_t *output_size)
{
    unsigned int row_size = (width * 3 + 3) & ~3;
    *output_size = row_size * height + BMP_HEADER_SIZE;
    unsigned char *bitmap = (unsigned char *) malloc(*output_size);

    BmpHeader header;
    init_bmp_header(&header);
    header.size = *output_size;
    header.width = width;
    header.height = height;

    memcpy(bitmap, &header, BMP_HEADER_SIZE);
    int i = BMP_HEADER_SIZE;
    for (BMP_HEADER_SIZE; i < *output_size; ++i)
    {
        bitmap[i] = 0xff;
        // if(i % 2 == 0)
        // {
        //     bitmap[i] = 0xff;
        // }
        // else
        // {
        //     bitmap[i] = 0xff;
        // }
    }
    return bitmap;
}

int main()
{
    size_t bmp_size = 0;
    unsigned char *bmp_buffer = generate_empty_bitmap(100, 100, &bmp_size);
    printf("%d\n", sizeof(BmpHeader));
    printf("%d\n", bmp_size);
    f(bmp_buffer, 50, 50, 0x0000FF00);
    write_bytes_to_bmp(bmp_buffer, bmp_size);
    free(bmp_buffer);
    return 0;
}