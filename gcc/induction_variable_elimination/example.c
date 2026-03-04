// Induction Variable Elimination Example
// GCC eliminates redundant induction variables derived from the loop counter
// Compile: gcc -O2 -o iv_elim example_1_1.c

#include <stdio.h>

int main() {
    int arr[10];
    int n = 10;

    // 'j' is a linear function of 'i' (j = i * 3) — an induction variable
    // GCC eliminates j and computes it incrementally (j += 3 each iteration)
    for (int i = 0; i < n; i++) {
        int j = i * 3;   // induction variable derived from i
        arr[i] = j;
    }

    printf("arr[3] = %d\n", arr[3]);  // prints 9
    return 0;
}
