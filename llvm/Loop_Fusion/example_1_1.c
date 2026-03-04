// Loop Fusion Example
// LLVM merges two adjacent loops with the same range into one loop
// Compile: clang -O3 -S -emit-llvm -o loop_fusion.ll example_1_1.c

int main() {
    int a[5], b[5];

    // Before fusion: two separate loops
    // LLVM fuses them into a single loop body — improves cache efficiency
    for (int i = 0; i < 5; i++) {
        a[i] = i * 2;        // loop 1
    }
    for (int i = 0; i < 5; i++) {
        b[i] = a[i] + 1;     // loop 2 (fused with loop 1)
    }

    return b[2];  // returns 5  (a[2]=4, b[2]=4+1=5)
}
