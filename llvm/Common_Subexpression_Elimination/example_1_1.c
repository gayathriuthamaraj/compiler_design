// Common Subexpression Elimination (CSE) Example
// LLVM eliminates repeated computation of (a * b + c)
// Compile: clang -O2 -S -emit-llvm -o cse.ll example_1_1.c

int main() {
    int a = 4, b = 5, c = 3;

    // (a * b + c) is computed twice — CSE reduces it to one computation
    int x = a * b + c;   // first occurrence
    int y = a * b + c;   // redundant — CSE replaces this with x

    int z = x + y;       // uses both results

    return z;
}