// Constant Propagation Example
// GCC substitutes known constant values of variables into expressions
// Compile: gcc -O1 -o const_prop example_1_1.c

#include <stdio.h>

int main() {
    int x = 10;           // x is a known constant
    int y = x + 5;        // propagated: y = 10 + 5 = 15
    int z = y * 2;        // propagated: z = 15 * 2 = 30

    // GCC replaces all uses of x, y, z with their constant values
    printf("x=%d, y=%d, z=%d\n", x, y, z);
    return 0;
}
