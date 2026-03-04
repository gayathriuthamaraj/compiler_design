// Unreachable Code Elimination Example
// LLVM removes code that can never be executed
// Compile: clang -O1 -S -emit-llvm -o unreachable.ll example_1_1.c

int getValue() {
    return 42;
    // Everything below is unreachable — LLVM removes it entirely
    return -1;  // unreachable dead return
}

int main() {
    int x = 1;
    int result = 0;

    if (x > 0) {
        result = 1;   // always taken — x=1 is always > 0
    } else {
        result = -1;  // unreachable — eliminated by LLVM
    }

    int v = getValue();
    return v + result;  // 42 + 1 = 43
}
