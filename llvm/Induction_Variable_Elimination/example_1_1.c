// Induction Variable Elimination Example
// LLVM eliminates redundant induction variables derived from the loop counter
// Compile: clang -O2 -S -emit-llvm -o iv_elim.ll example_1_1.c

#include <stdio.h>

int main() {
    int arr[10];
    int n = 10;

    // 'j' is a linear function of 'i' (j = i * 3) — an induction variable
    // LLVM eliminates j and computes it incrementally (j += 3 each iteration)
    for (int i = 0; i < n; i++) {
        int j = i * 3;   // induction variable derived from i
        arr[i] = j;
    }

    printf("arr[3] = %d\n", arr[3]);  // prints 9
    return 0;
}
