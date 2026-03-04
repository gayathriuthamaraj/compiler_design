# Loop Peeling

**Loop Peeling** is a loop transformation technique where the first (or last) few iterations of a loop are removed and executed separately before (or after) the main loop.

### How it Works
The compiler "peels" one or more iterations from the beginning or end of a loop body. This simplifies the remaining loop by removing special cases that only apply to those specific iterations.

### Benefits
- **Elimination of Conditional Checks**: If a condition inside the loop only changes after the first iteration, peeling the first iteration allows the compiler to remove that conditional check from the main loop.
- **Improved Alignment**: Can be used to align memory accesses within the loop for better SIMD (Single Instruction, Multiple Data) performance.
- **Enables Other Optimizations**: Simplifying the loop body often makes it easier for other optimizations like loop unrolling or vectorization to be applied.

### Example
**Before Optimization:**
```c
for (int i = 0; i < n; i++) {
    if (i == 0) {
        process_first(a[i]);
    } else {
        process_rest(a[i]);
    }
}
```

**After Loop Peeling:**
```c
if (n > 0) {
    process_first(a[0]); // Peeled iteration
    for (int i = 1; i < n; i++) {
        process_rest(a[i]); // Main loop (simpler)
    }
}
```
