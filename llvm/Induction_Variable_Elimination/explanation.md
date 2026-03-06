# Induction Variable Elimination (IVE)

## What is it?

In a loop, a variable that changes by a **fixed amount each iteration** is an **induction variable**. The basic induction variable is the loop counter `i` (incremented by 1 each time). A **derived induction variable** is a variable expressed as a linear function of `i`, e.g., `j = i * 3`.

Induction Variable Elimination replaces the **expensive multiplication** `i * 3` inside the loop with a cheaper **incremental addition**: introduce `j = 0` before the loop, then `j += 3` each iteration. This gives identical results with only additions instead of multiplications per iteration.

In LLVM, this is driven by **SCEV** (Scalar Evolution) analysis, which automatically characterizes induction variables, and the **IndVarSimplify** and **LoopStrengthReduce** IR passes.

## Source Code (`example_1_1.c`)

```c
int arr[10];
int n = 10;
for (int i = 0; i < n; i++) {
    int j = i * 3;   // derived induction variable
    arr[i] = j;
}
return arr[3];  // returns 9
```

At each iteration: `j = i * 3`. LLVM replaces the `mul` with an accumulator that adds 3 each step.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, each iteration computes `j = i * 3` with a `mul nsw` instruction:

```llvm
%11 = load i32, ptr %4, align 4   ; load i
%12 = mul nsw i32 %11, 3          ; i * 3  ← multiplication every iteration
store i32 %12, ptr %5, align 4    ; store into j
```

- `alloca` slots for `i`, `j`, `n`, and `arr[10]`.
- `i` incremented with a `load` → `add nsw i32 %i, 1` → `store` pattern.
- `j = i * 3` is a separate `mul nsw` instruction on every iteration — 10 multiplications total.
- `icmp slt i32 %i, 10` performs the loop bound check.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM applies **mem2reg** and **IndVar simplification**. The loop is restructured into SSA form with `phi` nodes:

```llvm
%6 = phi i64 [ 0, %0 ], [ %10, %5 ]   ; loop counter i (as i64)
%8 = trunc i64 %6 to i32
%9 = mul i32 %8, 3                     ; still mul at -O1 (but using canonical induction var)
```

At `-O1`, the loop is canonicalized (using `i64` induction variable, `phi` node, `icmp eq` exit test) but the `mul i32 %8, 3` may still appear. `mem2reg` removes the `alloca`s for `i` and `j`, making the SSA structure explicit.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, LLVM's **LoopStrengthReduce** and further SCEV analysis eliminate the induction variable entirely. Since `arr[3] = 3 * 3 = 9` is computable at compile time:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 9
}
```

The entire loop is unrolled or evaluated at compile time. All `mul` instructions are eliminated. The constant array element `arr[3] = 9` is the sole output.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 9`. The result was already fully determined at compile time. For non-constant cases, `-O3` would additionally apply auto-vectorization to the loop body.

---

## Summary Table

| Level | `mul i32 %i, 3` per iteration | Loop structure | `alloca`s | Return Value |
|-------|-------------------------------|----------------|-----------|--------------|
| `-O0` | 10 `mul nsw` instructions | `load`/`store` branches | Yes | Computed at runtime |
| `-O1` | Canonicalized `mul` (1 per iter) | `phi`-based SSA loop | Eliminated | Computed at runtime |
| `-O2` | Eliminated entirely | Fully evaluated/unrolled | Eliminated | `ret i32 9` |
| `-O3` | Eliminated | Fully evaluated | Eliminated | `ret i32 9` |

---

## Key Takeaway

Induction Variable Elimination in LLVM is powered by **Scalar Evolution (SCEV)**, which mathematically characterizes how values evolve across loop iterations. At **-O1**, the loop is canonicalized into SSA `phi`-node form. At **-O2**, strength reduction on the derived induction variable replaces the `mul` with incremental `add`s — and for small constant-bound loops like this, LLVM evaluates the result entirely at compile time, reducing the function to a single `ret i32 9`.
