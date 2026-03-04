// Strength Reduction in Loops Example
// LLVM replaces multiplication inside loops with cheaper additions
// Compile: clang -O2 -S -emit-llvm -o sr_loops.ll example_1_1.c

#include <stdio.h>

int main() {
    int arr[10];

    // Original: arr[i] = i * 5  (multiply each iteration)
    // After SR: compiler uses a running sum — adds 5 each iteration instead
    for (int i = 0; i < 10; i++) {
        arr[i] = i * 5;   // i*5 replaced by: t=0; t+=5 each iteration
    }

    printf("arr[4] = %d, arr[9] = %d\n", arr[4], arr[9]);  // 20, 45
    return 0;
}
