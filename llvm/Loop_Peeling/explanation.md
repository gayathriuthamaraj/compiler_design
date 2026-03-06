# Loop Peeling (LP)

## What is it?

Loop Peeling is a loop transformation where the **first (or last) few iterations of a loop are extracted and executed separately**, before (or after) the main loop body.

This is useful when the loop contains a **special-case condition** that only applies to those boundary iterations. By peeling those iterations out:
- The condition is removed from the main loop body, simplifying it.
- The remaining loop can be vectorized or unrolled more aggressively.
- Memory access alignment can be improved for SIMD operations.

In LLVM, Loop Peeling is performed by the **`LoopPeel`** pass, activated at `-O3` when the loop analysis detects a profitable peel. It is also triggered automatically to improve alignment for auto-vectorization.

## Source Code (`example_1_1.c`)

```c
int arr[8] = {0};
for (int i = 0; i < 8; i++) {
    if (i > 0) {
        arr[i] = arr[i - 1] + i;  // depends on previous element
    } else {
        arr[i] = 0;               // base case for i = 0
    }
}
return arr[5];  // returns 0+1+2+3+4+5 = 15
```

The `i == 0` branch only applies to the very first iteration. Peeling `i = 0` out removes the `if (i > 0)` check from the main loop entirely.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, the loop is emitted literally with the full if-else inside:

- `alloca i32` for `i`, `alloca [8 x i32]` for `arr`.
- Every iteration checks `icmp sgt i32 %i, 0` — a conditional branch on every pass.
- `i = 0` path: `store i32 0, ptr arr[0]`.
- `i > 0` path: `load arr[i-1]` → `add nsw i32 %prev, %i` → `store arr[i]`.
- Full `load`/`store`/branch overhead on every iteration.

The conditional branch for `i == 0` runs all 8 iterations even though it only matters once.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, `mem2reg` and loop canonicalization apply. The `phi` node for `i` is introduced. Basic simplification may detect that the condition `i > 0` is always false on the first iteration and always true thereafter, but full loop peeling does not typically activate at `-O1`. The loop body is simplified but the conditional branch may still be present.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, LLVM applies more aggressive loop analysis. For this small constant-bound loop, LLVM may fully evaluate the result: `arr[5] = 0 + 1 + 2 + 3 + 4 + 5 = 15`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 15
}
```

The entire loop is unrolled or evaluated; the conditional check disappears.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the **`LoopPeel`** pass explicitly peels the first iteration:

- `i = 0` is executed separately: `arr[0] = 0`.
- The remaining loop `i = 1..7` no longer contains the `if (i > 0)` check — the body is uniformly `arr[i] = arr[i-1] + i`.
- This simplified loop is then a candidate for further unrolling or vectorization.
- For this constant-bound case: `ret i32 15`.

---

## Summary Table

| Level | `if (i > 0)` branch in loop | First iteration peeled | Conditional checks | Return Value |
|-------|------------------------------|------------------------|--------------------|--------------|
| `-O0` | Present every iteration | No | 8 runtime branches | Computed at runtime |
| `-O1` | Simplified | No | Reduced | Computed at runtime |
| `-O2` | Eliminated (fully evaluated) | Via unrolling | 0 | `ret i32 15` |
| `-O3` | Eliminated (peeled out) | Yes (explicit peel) | 0 in main loop | `ret i32 15` |

---

## Key Takeaway

Loop Peeling targets loops where **boundary iterations behave differently** from the general case. By peeling those iterations out at **-O3**, LLVM removes the boundary-condition check from the hot loop body, enabling further optimizations (vectorization, unrolling) on the now-uniform main loop. For this small constant example, `-O2` already evaluates the result statically, but in real-world code with runtime-sized arrays, Loop Peeling provides measurable speedups.
