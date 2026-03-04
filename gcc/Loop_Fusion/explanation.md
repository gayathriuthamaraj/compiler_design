# Loop Fusion

**Loop Fusion** (also known as loop jamming) is a compiler optimization that combines two or more adjacent loops that iterate over the same range into a single loop.

### How it Works
If two loops perform different operations but have the same iteration boundaries and no data dependencies that prevent merging, the compiler can "fuse" them.

### Benefits
- **Improved Cache Locality**: Reusing data within a single loop iteration instead of loading it twice (once for each loop) significantly improves cache performance.
- **Reduced Overhead**: Minimizes the overhead associated with loop control (initialization, testing, and incrementing loop variables).
- **Enables Further Loop Optimizations**: A single, larger loop might provide more opportunities for other optimizations like loop unrolling or vectorization.

### Example
**Before Optimization:**
```c
for (int i = 0; i < n; i++) {
    a[i] = b[i] + c[i];
}
for (int i = 0; i < n; i++) {
    d[i] = a[i] * 2;
}
```

**After Loop Fusion:**
```c
for (int i = 0; i < n; i++) {
    a[i] = b[i] + c[i];
    d[i] = a[i] * 2;
}
```
