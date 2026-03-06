# Loop Fusion (LF)

## What is it?

Loop Fusion (also called "Loop Jamming") is a compiler optimization that **merges two or more adjacent loops with the same iteration range into a single loop**.

Benefits of fusion:
- **Reduced loop overhead**: each loop has setup/teardown cost (counter init, comparison, branch). One loop means half the overhead.
- **Better cache locality**: when two loops access the same data, merging them keeps that data hot in cache between the two operations.
- **Improved instruction-level parallelism**: the CPU pipeline can overlap operations from both original loops.

In LLVM, Loop Fusion is performed by the **LoopFusePass** at `-O3`. Safety checks ensure no fusion happens when data dependencies would change the program's behavior.

## Source Code (`example_1_1.c`)

```c
int a[5], b[5];
for (int i = 0; i < 5; i++) {
    a[i] = i * 2;        // Loop 1: fills a = [0, 2, 4, 6, 8]
}
for (int i = 0; i < 5; i++) {
    b[i] = a[i] + 1;     // Loop 2: fills b using a = [1, 3, 5, 7, 9]
}
return b[2];  // returns 5
```

Both loops iterate over the same range `[0, 5)`. Loop 2 reads `a[i]` immediately after Loop 1 writes it, so they can be safely fused into one pass.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, the two loops are emitted as two completely separate control-flow structures:

- **Loop 1**: `alloca` for counter `i`, `icmp slt i32 %i, 5` exit test, `mul nsw i32 %i, 2` inside the body, store to `a[i]`, `add nsw i32 %i, 1` increment.
- **Loop 2**: separate `alloca` for second `i`, identical loop structure, `load a[i]` → `add nsw i32, 1` → `store b[i]`.
- Two completely independent loop structures in the IR, each with its own preheader, body, and exit blocks.

Cache performance suffers because `a[]` may be partially evicted between Loop 1's completion and Loop 2's start.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, `mem2reg` removes the `alloca`s for the loop counters and promotes them to `phi` nodes. The loops are canonicalized but remain separate. Basic constant propagation may simplify the body expressions, but the two loop structures are not yet merged.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, LLVM performs further loop analysis. For this small constant-bound loop with constant inputs, LLVM may evaluate the result statically. `b[2] = a[2] + 1 = (2 * 2) + 1 = 5`. The entire computation is foldable:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 5
}
```

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, LLVM's **LoopFusePass** has the opportunity to merge loops when they remain as distinct loops. For non-constant cases, the two loops would be merged into one body; here, the constant inputs mean the result is still fully folded to `ret i32 5`. Auto-vectorization (`-O3` feature) would also apply to non-constant loop bodies, processing multiple elements per iteration using SIMD.

---

## Summary Table

| Level | Loop count | Cache behavior | `mul`/`add` at runtime | Return Value |
|-------|------------|----------------|------------------------|--------------|
| `-O0` | 2 separate loops | Poor (potential eviction) | 10 runtime ops | Computed at runtime |
| `-O1` | 2 (canonicalized, `phi`-based) | Slightly better | Reduced | Computed at runtime |
| `-O2` | Fully evaluated | N/A | Eliminated | `ret i32 5` |
| `-O3` | Fused (or fully evaluated) | Optimal | Eliminated | `ret i32 5` |

---

## Key Takeaway

Loop Fusion activates in LLVM at **-O3** via the `LoopFusePass`. For this constant-range example, `-O2` already folds the answer to `ret i32 5` — but for real-world arrays of non-constant data, `-O3`'s fusion would reduce iteration count by half, halve loop overhead, and dramatically improve data locality by processing both `a[i]` and `b[i]` in the same cache line within a single iteration.
