// Loop Invariant Code Motion (LICM) Example
// LLVM moves computations that don't change inside the loop to outside the loop
// Compile: clang -O2 -S -emit-llvm -o licm.ll example_1_1.c

int main() {
    int arr[100];
    int factor = 7;
    int scale  = 3;

    // (factor * scale) is loop-invariant — same value every iteration
    // LLVM hoists it out: int inv = factor * scale; computed ONCE before loop
    for (int i = 0; i < 100; i++) {
        arr[i] = i + factor * scale;   // factor * scale hoisted out
    }

    return arr[10];  // returns 10 + 21 = 31
}
