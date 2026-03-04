// Constant Folding Example
// LLVM evaluates constant expressions at compile time
// Compile: clang -O1 -S -emit-llvm -o const_fold.ll example_1_1.c

int main() {
    // All of these are constant expressions — LLVM computes them at compile time
    int a = 3 + 4;          // folded to 7
    int b = 2 * 8;          // folded to 16
    int c = 100 / 5;        // folded to 20
    int d = a + b + c;      // further folded to 43

    return d;
}
