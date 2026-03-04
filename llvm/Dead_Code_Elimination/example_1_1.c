// Dead Code Elimination Example
// LLVM removes assignments whose results are never used
// Compile: clang -O1 -S -emit-llvm -o dce.ll example_1_1.c

int main() {
    int a = 5;
    int b = 20;      // b is computed but never used — dead code
    int c = a + 10;  // only c is used

    // 'b' assignment is dead — LLVM removes it entirely
    return c;  // returns 15
}
