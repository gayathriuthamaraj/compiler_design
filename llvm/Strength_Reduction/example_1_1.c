// Strength Reduction Example
// LLVM replaces expensive operations with cheaper equivalent operations
// Compile: clang -O2 -S -emit-llvm -o strength_red.ll example_1_1.c

int main() {
    int x = 9;

    // Multiplication by power-of-2 replaced by left shift
    // x * 8  --> x << 3  (cheaper on hardware)
    int a = x * 8;

    // Division by power-of-2 replaced by right shift
    // x * 4  --> x << 2
    int b = x * 4;

    return a + b;  // 72 + 36 = 108
}
