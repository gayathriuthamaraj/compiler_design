# Strength Reduction in Loops

**Strength Reduction in Loops** is a specific application of strength reduction that replaces expensive operations involving a loop induction variable (a variable that increases or decreases by a fixed amount in each iteration) with simpler operations.

### How it Works
When a loop contains a multiplication involving the induction variable (e.g., `i * constant`), the compiler can replace it with an addition. It creates a new temporary variable that is initialized outside the loop and incremented inside the loop.

### Benefits
- **Significant Performance Gains**: Replacing multiplication with addition inside a frequently executed loop body can lead to substantial speed improvements.
- **Reduces CPU Load**: Addition is one of the fastest operations a processor can perform.

### Example
**Before Optimization:**
```c
for (int i = 0; i < n; i++) {
    a[i] = i * 4; // Multiplication in every iteration
}
```

**After Strength Reduction:**
```c
int temp = 0;
for (int i = 0; i < n; i++) {
    a[i] = temp;
    temp += 4; // Replaced with addition
}
```
