// Function Inlining Example
// LLVM replaces a function call with the body of the function
// Compile: clang -O2 -S -emit-llvm -o func_inline.ll example_1_1.c

// LLVM will inline this small function at the call site
static inline int square(int x) {
    return x * x;
}

int main() {
    int a = 6;
    // After inlining: result = a * a = 36 (no function call overhead)
    int result = square(a);

    return result;  // returns 36
}
