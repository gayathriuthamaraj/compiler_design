# Loop Invariant Detection and Code Motion

**Loop Invariant Detection and Code Motion** is an optimization that identifies expressions within a loop that yield the same value regardless of how many times the loop executes (loop invariants) and moves them outside the loop.

### How it Works
The compiler analyzes the code inside a loop to find computations whose operands do not change during loop iterations. These computations are hoisted out of the loop and placed in a "pre-header" block that executes only once before the loop begins.

### Benefits
- **Reduced Redundancy**: Eliminates repetitive computations inside the loop body.
- **Improved Performance**: Moving code out of the loop can lead to significant speedups, especially in loops with many iterations.

### Example
**Before Optimization:**
```c
for (int i = 0; i < n; i++) {
    double factor = sqrt(global_constant); // Compute sqrt in every iteration
    arr[i] *= factor;
}
```

**After Code Motion:**
```c
double factor = sqrt(global_constant); // Compute once outside the loop
for (int i = 0; i < n; i++) {
    arr[i] *= factor;
}
```
