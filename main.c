#include "f.h"
#include <stdint.h>
#include <stdio.h>
#include <gtk/gtk.h>

#define BMP_FNAME "output.bmp"
#define BMP_HEADER_SIZE 54
#define BMP_WIDTH 512
#define BMP_HEIGHT 512

typedef struct __attribute__((__packed__)){
    unsigned char sig_0;
    unsigned char sig_1;
    uint32_t size;
    uint32_t reserved;
    uint32_t offset;
    uint32_t dib_header_size;
    uint32_t width_px;
    uint32_t height_px;
    uint16_t num_planes;
    uint16_t bits_per_pixel;
    uint32_t compression;
    uint32_t image_size_bytes;
    uint32_t x_resolution_ppm;
    uint32_t y_resolution_ppm;
    uint32_t num_colors;
    uint32_t important_colors;
} BmpHeader;

void create_bmp(BmpHeader *header)
{
    header->sig_0 = 'B';
    header->sig_1 = 'M';
    header->reserved = 0;
    header->offset = 54;
    header->dib_header_size = 40;
    header->num_planes = 1;
    header->bits_per_pixel = 24;
    header->compression = 0;
    header->image_size_bytes = 0;
    header->x_resolution_ppm = 500;
    header->y_resolution_ppm = 500;
    header->num_colors = 0;
    header->important_colors = 0;
}

unsigned char *create_white_bmp(unsigned int width, unsigned int height, size_t *size)
{
    unsigned int row_size = (width * 3 + 3) & ~3;
    *size = row_size * height + BMP_HEADER_SIZE;
    unsigned char *bitmap = (unsigned char *) malloc(*size);

    BmpHeader header;
    create_bmp(&header);
    header.size = *size;
    header.width_px = width;
    header.height_px = height;

    memcpy(bitmap, &header, BMP_HEADER_SIZE);
    int i = BMP_HEADER_SIZE;
    for (; i < *size; ++i)
    {
        bitmap[i] = 0xff;
    }
    return bitmap;
}

void fill_bmp(unsigned char *buffer, size_t size)
{
    FILE *file;

    file = fopen(BMP_FNAME, "wb");
    if (file == NULL)
        exit(-1);
    fwrite(buffer, 1, size, file);
    fclose(file);
}

GtkAdjustment* a_value;
GtkAdjustment* b_value;
GtkAdjustment* c_value;
GtkAdjustment* s_value;
GtkAdjustment* bmp_width;
GtkAdjustment* bmp_height;
GtkImage* plot;

void f(unsigned char*, int, int, double, double, double, double);

void on_change()
{
    // Get values from interface
    double a = gtk_adjustment_get_value(a_value);
    if(a == 0 )
        return;
    double b = gtk_adjustment_get_value(b_value);
    double c = gtk_adjustment_get_value(c_value);
    double s = gtk_adjustment_get_value(s_value);
    int width = gtk_adjustment_get_value(bmp_width);
    int height = gtk_adjustment_get_value(bmp_height);

    // BMP initialize
    size_t bmp_size = 0;
    unsigned char *bmp_buffer = create_white_bmp(width, height, &bmp_size);

    // assembly function drawing quadratic function
    f(bmp_buffer, width, height, a, b, c, s);

    // convert buffer to bmp
    fill_bmp(bmp_buffer, bmp_size);

    // memory release
    free(bmp_buffer);

    // display bmp to user
    gtk_image_set_from_file(plot, BMP_FNAME);
}

void on_destroy()
{
    gtk_main_quit();
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
    bmp_width = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "bmp_width"));
    bmp_height = GTK_ADJUSTMENT(gtk_builder_get_object(builder, "bmp_height"));
    plot = GTK_IMAGE(gtk_builder_get_object(builder, "plot"));

    g_object_unref(builder);
    gtk_widget_show(window);
    gtk_main();

    return 0;
}
