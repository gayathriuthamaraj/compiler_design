// Loop Peeling Example
// LLVM peels the first (or last) few iterations to handle boundary conditions
// Compile: clang -O3 -S -emit-llvm -o loop_peel.ll example_1_1.c

int main() {
    int arr[8] = {0};

    // LLVM may peel the first iteration (i=0) separately to remove the
    // conditional check (i > 0) inside the loop body for the general case
    for (int i = 0; i < 8; i++) {
        if (i > 0) {
            arr[i] = arr[i - 1] + i;  // depends on previous element
        } else {
            arr[i] = 0;               // peeled: base case for i=0
        }
    }

    return arr[5];  // returns 0+1+2+3+4+5 = 15
}
