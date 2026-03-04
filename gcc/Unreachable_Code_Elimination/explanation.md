# Unreachable Code Elimination

**Unreachable Code Elimination** is a compiler optimization that identifies and removes code that can never be executed during the program's runtime.

### How it Works
The compiler performs control-flow analysis to determine which parts of the code are reachable from the program's entry point. If a block of code has no execution path leading to it (e.g., code following an unconditional `return` or `break`, or inside an `if` block with a constant `false` condition), it is considered "unreachable."

### Benefits
- **Reduced Executable Size**: Removing dead code makes the final binary smaller.
- **Improved Instruction Cache Usage**: By removing unused code, the active code can be packed more tightly in the instruction cache, potentially improving performance.
- **Cleaner Code Structure**: Can indirectly help other optimizations by simplifying the control-flow graph.

### Example
**Before Optimization:**
```c
int compute() {
    return 10;
    printf("This will never print\n"); // Unreachable code
}
```

**After Unreachable Code Elimination:**
```c
int compute() {
    return 10;
}
```
