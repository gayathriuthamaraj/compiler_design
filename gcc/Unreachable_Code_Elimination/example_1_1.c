// Unreachable Code Elimination Example
// GCC removes code that can never be executed
// Compile: gcc -O1 -o unreachable example_1_1.c

#include <stdio.h>

int getValue() {
    return 42;
    // Everything below is unreachable — GCC removes it entirely
    printf("This will never print\n");  // unreachable
    return -1;                          // unreachable
}

int main() {
    int x = 1;

    if (x > 0) {
        printf("x is positive\n");
    } else {
        // This block is unreachable because x=1 is always > 0
        printf("x is not positive\n");  // unreachable — eliminated
    }

    int v = getValue();
    printf("v = %d\n", v);  // prints 42
    return 0;
}
