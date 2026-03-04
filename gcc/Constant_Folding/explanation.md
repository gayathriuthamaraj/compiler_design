# Constant Folding

**Constant Folding** is a compiler optimization technique where the compiler evaluates expressions with constant operands at compile time rather than at runtime.

### How it Works
When the compiler encounters an expression like `3 + 5`, it recognizes that both operands are constants. Instead of generating machine code to perform the addition during execution, the compiler replaces the expression with the result `8`.

### Benefits
- **Improved Performance**: Reduces the number of arithmetic operations performed at runtime.
- **Code Size Reduction**: Can sometimes lead to smaller executable sizes by replacing complex expressions with single values.
- **Enables Further Optimizations**: Simplified expressions often reveal more opportunities for other optimizations like constant propagation or dead code elimination.

### Example
**Before Optimization:**
```c
int minutes_in_day = 24 * 60;
```

**After Constant Folding:**
```c
int minutes_in_day = 1440;
```
