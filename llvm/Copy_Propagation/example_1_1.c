// Copy Propagation Example
// LLVM replaces copies of variables with the original variable
// Compile: clang -O1 -S -emit-llvm -o copy_prop.ll example_1_1.c

int main() {
    int a = 42;
    int b = a;    // b is a copy of a
    int c = b;    // c is a copy of b (which is a copy of a)

    // After copy propagation: c = a = 42; b and c are eliminated
    int result = c + 8;   // c gets replaced by a directly

    return result;  // returns 50
}
