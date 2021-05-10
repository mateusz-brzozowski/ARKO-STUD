#include <stdio.h>

// CONSTANT PI VALUE multiplied by scale
#define M_PI 3373259426

//Constant CORDIC value 1/K multiplied by scale
#define CORDIC 652032874

//Scale to avoid non-integer constant variables 2^30
#define SCALE 1073741824.0

//Size of precomputed lookup table
#define L_TABLE_SIZE 32

//Precomputed lookup table
int L_TABLE[] = 
{ 
    0x3243F6A8, 0x1DAC6705, 0x0FADBAFC, 0x07F56EA6, 0x03FEAB76, 
    0x01FFD55B, 0x00FFFAAA, 0x007FFF55, 0x003FFFEA, 0x001FFFFD, 
    0x000FFFFF, 0x0007FFFF, 0x0003FFFF, 0x0001FFFF, 0x0000FFFF, 
    0x00007FFF, 0x00003FFF, 0x00001FFF, 0x00000FFF, 0x000007FF,
    0x000003FF, 0x000001FF, 0x000000FF, 0x0000007F, 0x0000003F, 
    0x0000001F, 0x0000000F, 0x00000008, 0x00000004, 0x00000002, 
    0x00000001, 0x00000000 
};

void cordic(int theta, int* sin, int *cos) {
    int x = CORDIC;
    int y = 0;
    int z = theta;
    int d, tx, ty, tz;
    int i = 0;
    for (i; i < L_TABLE_SIZE; ++i) {
        int tx = y >> i;
        int ty = x >> i;
        int tz = L_TABLE[i];
        if (z >= 0) { 
            x -= tx;
            y += ty;
            z -= tz;
        }
        else { 
            x += tx;
            y -= ty;
            z += tz;
        }
    }

    *sin = y;
    *cos = x;
}

int main() {
    double theta = M_PI / 2;
    int sin, cos;
    cordic(theta, &sin, &cos);
    printf("sin: %f\n", sin / SCALE);
    printf("cos: %f\n", cos / SCALE);
    return 0;
}
