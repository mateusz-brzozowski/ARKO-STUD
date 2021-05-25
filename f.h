#ifdef F_H_
#define F_H_

double x(double x, double s, double a, double b);
double y(double a, double b, double c, double x);

int set_pixel(unsigned char* dest_bitmap, unsigned int x, unsigned int y);

void f(unsigned char* dest_bitmap,double a, double b, double c, double s);

#endif //F_H_