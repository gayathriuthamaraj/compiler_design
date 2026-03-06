# Loop Invariant Detection & Code Motion (LICM)

## What is it?

Loop Invariant Code Motion detects computations **inside a loop whose result does not change across any iteration** and **hoists** those computations **out of the loop** to run just once before it starts.

A computation is "loop invariant" if all its operands are either constants or defined outside the loop and never modified inside it. Computing such a value on every iteration is wasteful — the result is always the same.

In LLVM, LICM is implemented by the **`-licm`** pass (Loop Invariant Code Motion), one of the most impactful loop optimization passes. It operates on LLVM's loop representation after the loop is in canonical SSA form.

## Source Code (`example_1_1.c`)

```c
int arr[100];
int factor = 7;
int scale  = 3;
for (int i = 0; i < 100; i++) {
    arr[i] = i + factor * scale;   // factor * scale hoisted out
}
return arr[10];  // returns 10 + 21 = 31
```

`factor * scale = 7 * 3 = 21` is constant across all 100 iterations. Without optimization it multiplies 100 times; with LICM it multiplies once before the loop.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, the loop body contains the full multiplication on every iteration:

- `alloca` slots for `factor`, `scale`, `i`, and `arr[100]`.
- Inside the loop body:
  - `load i32, ptr %factor_slot` → `load i32, ptr %scale_slot` → `mul nsw i32 %factor, %scale` — executed **100 times**.
  - `load i32, ptr %i_slot` → `add nsw i32 %i, %product` → `store` to `arr[i]`.
- The `mul` for `factor * scale` is entirely inside the loop's basic block.

**Key observation:** `mul nsw i32 %factor, %scale` appears inside the loop body — 100 redundant multiplications.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, **mem2reg** and basic loop analysis apply. `factor = 7` and `scale = 3` are known constants, so `factor * scale = 21` is constant-folded before even considering LICM. The loop body is simplified:

- Loop counter promoted to `phi`-node SSA form.
- `arr[i] = i + 21` — the multiplication has been replaced by a compile-time constant `21`.
- The loop still iterates but the inner `mul` is gone (replaced by a constant).

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, LLVM's full **LICM** pass runs. For this example, `factor * scale` was already folded at `-O1`, so LICM confirms no further hoisting is needed. Since `arr[10] = 10 + 21 = 31` is computable at compile time for this all-constant input:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 31
}
```

The entire loop is eliminated; the result is fully computed at compile time.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 31`. For a non-constant input scenario, `-O3` would also apply **auto-vectorization** to process 4 or 8 array elements per iteration using SIMD (SSE/AVX), multiplying the throughput further.

---

## Summary Table

| Level | `mul` in loop body | LICM applied | Loop structure | Return Value |
|-------|--------------------|--------------|----------------|--------------|
| `-O0` | 100× `mul nsw` at runtime | No | `alloca`/`load`/`store` | Computed at runtime |
| `-O1` | 0× (constant-folded to 21) | Via folding | `phi`-based SSA | Computed at runtime |
| `-O2` | 0× (loop eliminated) | Confirmed | Fully evaluated | `ret i32 31` |
| `-O3` | 0× | Confirmed + vectorize | Fully evaluated | `ret i32 31` |

---

## Key Takeaway

LICM is one of LLVM's highest-impact loop passes, activating at **-O2**. By hoisting loop-invariant computations to the **loop preheader** (the block just before the loop), it converts O(n) repeated work into O(1) once-before-loop work. When operands are compile-time constants, LLVM goes further and constant-folds the invariant expression at `-O1`, making LICM's hoisting redundant. For real runtime-variable inputs, LICM's savings scale linearly with the loop trip count.
