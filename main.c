//gcc -m32 -O0 -fpack-struct -std=c99 main.c -o main
#include "f.h"
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <gtk/gtk.h>

GtkAdjustment* a_value;
GtkAdjustment* b_value;
GtkAdjustment* c_value;
GtkAdjustment* s_value;
GtkImage* plot;


#define OUTPUT_NAME "output.bmp"

#define BMP_HEADER_SIZE 54

#define BMP_PIXEL_OFFSET 54

#define BMP_PLANES 1

#define BMP_BPP 24

#define BMP_HORIZONTAL_RES 500

#define BMP_VERTICAL_RES 500

#define BMP_DIB_HEADER_SIZE 40

typedef struct __attribute__((__packed__)){
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

double x(double, double, double, double);
double y(double, double, double, double);
int set_pixel(unsigned char*, unsigned int, unsigned int);

void f(unsigned char*,double, double, double, double);

void on_destory()
{
    gtk_main_quit();
}

void on_change()
{
    size_t bmp_size = 0;
    unsigned char *bmp_buffer = generate_empty_bitmap(512, 512, &bmp_size);
    printf("%d\n", sizeof(BmpHeader));
    printf("%d\n", bmp_size);

    double a = gtk_adjustment_get_value(a_value);
    double b = gtk_adjustment_get_value(b_value);
    double c = gtk_adjustment_get_value(c_value);
    double s = gtk_adjustment_get_value(s_value);

    f(bmp_buffer, a, b, c, s);

    // double p = (-b)/(2*a);
    // double q = y(a, b, c, p);

    // double new_x = p;
    // double new_y = q;

    // for(int i = 0; i <= 512; i++)
    // {
    //     set_pixel(bmp_buffer, i, 256);
    //     set_pixel(bmp_buffer, 256, i);
    // }

    // int colored;

    // do{
    //     colored = set_pixel(bmp_buffer, (int)new_x + 256, (int)new_y + 256);
    //     colored |= set_pixel(bmp_buffer, (int)((2*p - new_x) + 256), (int)new_y + 256);
    //     new_x = x(new_x, s, a, b);
    //     new_y = y(a, b, c, new_x);
    //     printf("x: %f, ", new_x);
    //     printf("y: %f\n", new_y);
    // }while(colored);

    write_bytes_to_bmp(bmp_buffer, bmp_size);
    free(bmp_buffer);
    gtk_image_set_from_file(plot, OUTPUT_NAME);
}

int main(int argc, char* argv[]) {

    GtkBuilder* builder;
    GtkWidget* window;

    gtk_init(&argc, &argv);

    builder = gtk_builder_new();
    gtk_builder_add_from_file(builder, "x86_GUI.glade", NULL);

    window = GTK_WIDGET(gtk_builder_get_object(builder, "window"));
    gtk_builder_connect_signals(builder, NULL);

    a_value = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "a_value"));
    b_value = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "b_value"));
    c_value = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "c_value"));
    s_value = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "s_value"));
    plot = GTK_IMAGE(gtk_builder_get_object(builder, "plot"));

    g_object_unref(builder);
    // gtk_image_set_from_file(plot, OUTPUT_NAME);
    gtk_widget_show(window);
    gtk_main();

    return 0;
}
