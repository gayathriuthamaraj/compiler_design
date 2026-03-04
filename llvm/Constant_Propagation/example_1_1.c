// Constant Propagation Example
// LLVM substitutes known constant values of variables into expressions
// Compile: clang -O1 -S -emit-llvm -o const_prop.ll example_1_1.c

int main() {
    int x = 10;           // x is a known constant
    int y = x + 5;        // propagated: y = 10 + 5 = 15
    int z = y * 2;        // propagated: z = 15 * 2 = 30

    // LLVM replaces all uses of x, y, z with their constant values
    return z;
}
