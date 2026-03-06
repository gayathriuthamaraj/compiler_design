# Strength Reduction in Loops (SRL)

## What is it?

Strength Reduction in Loops is a specialized form of Strength Reduction applied to **expressions inside loop bodies where the multiplicand is the loop induction variable**.

When `i * constant` is computed on every iteration, the result grows by `constant` each step. Instead of executing a new multiplication per iteration, LLVM introduces a running **accumulator** variable that simply adds the constant each step:

- Before: `arr[i] = i * 5` → **1 multiply per iteration**.
- After: accumulator `t = 0`; each iteration `arr[i] = t; t += 5` → **1 add per iteration**.

Additions are 3–5× faster than multiplications on most hardware. The savings scale linearly with the loop trip count.

In LLVM, this is driven by the **`LoopStrengthReduce`** pass, powered by **SCEV** (Scalar Evolution) analysis which characterizes `i * 5` as a linear function of `i`.

## Source Code (`example_1_1.c`)

```c
int arr[10];
for (int i = 0; i < 10; i++) {
    arr[i] = i * 5;   // derived induction variable: multiply per iteration
}
return arr[4] + arr[9];  // 20 + 45 = 65
```

Without optimization: 10 `mul` instructions. With Strength Reduction: 10 `add` instructions using a step-5 accumulator.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, the loop body contains `mul nsw i32 %i, 5` on every iteration:

```llvm
%11 = load i32, ptr %i_slot, align 4
%12 = mul nsw i32 %11, 5        ; multiply every iteration
store i32 %12, ptr arr[i]
```

- `alloca i32` for `i`, `alloca [10 x i32]` for `arr`.
- `i` managed with explicit `load` → `add nsw 1` → `store` increment pattern.
- `icmp slt i32 %i, 10` loop bound check.
- 10 `mul nsw` instructions execute at runtime.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, **mem2reg** and loop canonicalization promote `i` to a `phi`-node. The loop is restructured in SSA form. The `mul i32 %i, 5` is simplified — LLVM may still emit a `mul` but using the canonical induction variable. Basic loop body simplification occurs.

For the final return `arr[4] + arr[9] = 20 + 45 = 65`: since all inputs are constants, LLVM may evaluate this at `-O1` already.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, LLVM's **LoopStrengthReduce** pass replaces the per-iteration multiply with an accumulator pattern. For this constant-bound small loop, LLVM evaluates the result fully at compile time:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 65
}
```

All loop instructions — including the `mul` — are eliminated. The constant `arr[4] + arr[9] = 20 + 45 = 65` is the sole output.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 65`. For runtime-variable arrays, `-O3` would additionally auto-vectorize the loop, processing 4–8 elements per iteration with SIMD instructions (SSE/AVX), compounding the speedup from strength reduction.

---

## Summary Table

| Level | Per-iteration `mul i32 %i, 5` | Accumulator `+=5` pattern | Loop fully evaluated | Return Value |
|-------|-------------------------------|---------------------------|----------------------|--------------|
| `-O0` | 10× `mul nsw` | No | No | Computed at runtime |
| `-O1` | Simplified (phi-based) | Partial | Possibly | Computed at runtime |
| `-O2` | Eliminated (LoopStrengthReduce) | Yes (or folded) | Yes | `ret i32 65` |
| `-O3` | Eliminated + vectorized | Yes | Yes | `ret i32 65` |

---

## Key Takeaway

Strength Reduction in Loops activates at **-O2** via LLVM's `LoopStrengthReduce` pass backed by SCEV. Unlike the plain Strength Reduction pass (which handles power-of-2 multiplies via shifts), this pass handles **any constant multiplier** by converting `i * K` to an incremental `+= K` accumulator. The savings per iteration are small but compound over thousands of loop iterations — making this critical in tight numerical or array-processing loops. For this constant example, LLVM goes further and evaluates everything at compile time, yielding `ret i32 65`.
