// Function Cloning Example
// LLVM creates specialized clones of a function for specific argument values
// Compile: clang -O3 -S -emit-llvm -o func_clone.ll example_1_1.c

// LLVM may clone this function for the constant call-sites (e.g., mode=0, mode=1)
int process(int value, int mode) {
    if (mode == 0) {
        return value * 2;
    } else {
        return value + 100;
    }
}

int main() {
    // LLVM clones process() with mode=0 and mode=1 specialized versions
    int r1 = process(10, 0);   // clone: return 10 * 2 = 20
    int r2 = process(10, 1);   // clone: return 10 + 100 = 110

    return r1 + r2;  // returns 130
}
