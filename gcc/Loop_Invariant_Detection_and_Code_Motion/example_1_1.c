// Loop Invariant Code Motion (LICM) Example
// GCC moves computations that don't change inside the loop to outside the loop
// Compile: gcc -O2 -o licm example_1_1.c

#include <stdio.h>

int main() {
    int arr[100];
    int factor = 7;
    int scale  = 3;

    // (factor * scale) is loop-invariant — same value every iteration
    // GCC hoists it out: int inv = factor * scale; computed ONCE before loop
    for (int i = 0; i < 100; i++) {
        arr[i] = i + factor * scale;   // factor * scale hoisted out
    }

    printf("arr[10] = %d\n", arr[10]);  // 10 + 21 = 31
    return 0;
}
