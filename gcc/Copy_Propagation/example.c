// Copy Propagation Example
// GCC replaces copies of variables with the original variable
// Compile: gcc -O1 -o copy_prop example_1_1.c

#include <stdio.h>

int main() {
    int a = 42;
    int b = a;    // b is a copy of a
    int c = b;    // c is a copy of b (which is a copy of a)

    // After copy propagation: c = a = 42; b and c are eliminated
    int result = c + 8;   // c gets replaced by a directly

    printf("result = %d\n", result);  // prints 50
    return 0;
}
