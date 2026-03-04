// Dead Code Elimination Example
// GCC removes assignments whose results are never used
// Compile: gcc -O1 -o dce example_1_1.c

#include <stdio.h>

int main() {
    int a = 5;
    int b = 20;      // b is computed but never used — dead code
    int c = a + 10;  // only c is used

    // 'b' assignment is dead — GCC removes it entirely
    printf("c = %d\n", c);  // prints 15
    return 0;
}
