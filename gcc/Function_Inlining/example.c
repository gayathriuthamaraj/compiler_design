// Function Inlining Example
// GCC replaces a function call with the body of the function
// Compile: gcc -O2 -o func_inline example_1_1.c

#include <stdio.h>

// GCC will inline this small function at the call site
static inline int square(int x) {
    return x * x;
}

int main() {
    int a = 6;
    // After inlining: result = a * a = 36 (no function call overhead)
    int result = square(a);

    printf("square(%d) = %d\n", a, result);
    return 0;
}
