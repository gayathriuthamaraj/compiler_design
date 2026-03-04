// Strength Reduction Example
// GCC replaces expensive operations with cheaper equivalent operations
// Compile: gcc -O2 -o strength_red example_1_1.c

#include <stdio.h>

int main() {
    int x = 9;

    // Multiplication by power-of-2 replaced by left shift
    // x * 8  --> x << 3  (cheaper on hardware)
    int a = x * 8;

    // Division by power-of-2 replaced by right shift
    // x * 4  --> x << 2
    int b = x * 4;

    printf("a = %d, b = %d\n", a, b);  // 72, 36
    return 0;
}
