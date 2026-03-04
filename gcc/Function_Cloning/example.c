// Function Cloning Example
// GCC creates specialized clones of a function for specific argument values
// Compile: gcc -O3 -o func_clone example_1_1.c

#include <stdio.h>

// GCC may clone this function for the constant call-sites (e.g., mode=0, mode=1)
int process(int value, int mode) {
    if (mode == 0) {
        return value * 2;
    } else {
        return value + 100;
    }
}

int main() {
    // GCC clones process() with mode=0 and mode=1 specialized versions
    int r1 = process(10, 0);   // clone: return 10 * 2 = 20
    int r2 = process(10, 1);   // clone: return 10 + 100 = 110

    printf("r1 = %d, r2 = %d\n", r1, r2);
    return 0;
}
