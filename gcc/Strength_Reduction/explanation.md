# Strength Reduction

**Strength Reduction** is a compiler optimization where expensive operations (like multiplication or division) are replaced with equivalent but cheaper operations (like addition, subtraction, or bit shifting).

### How it Works
The compiler identifies instances where a complex operation can be rewritten using simpler ones. For example, multiplying an integer by 2 is equivalent to shifting its bits to the left by one position (`x * 2` becomes `x << 1`).

### Benefits
- **Faster Execution**: Simpler operations generally take fewer CPU cycles than complex ones.
- **Reduced Power Consumption**: Cheaper operations often require less energy to execute.

### Example
**Before Optimization:**
```c
int y = x * 8;
int z = a / 4;
```

**After Strength Reduction:**
```c
int y = x << 3; // Shift left by 3
int z = a >> 2; // Shift right by 2
```
