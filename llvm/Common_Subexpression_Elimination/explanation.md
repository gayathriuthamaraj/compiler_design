# Common Subexpression Elimination (CSE)

## What is it?

Common Subexpression Elimination is a compiler optimization that detects when the same expression is computed more than once with the same operands, and replaces subsequent computations with the already-computed result. This avoids redundant arithmetic work.

In LLVM, CSE is performed via the **EarlyCSE** and **GVN** (Global Value Numbering) IR passes. Because LLVM IR uses SSA (Static Single Assignment) form — where each value is defined exactly once — identical computations are trivially detected by value equality, making CSE especially effective.

## Source Code (`example_1_1.c`)

```c
int a = 4, b = 5, c = 3;
int x = a * b + c;   // first occurrence of (a*b+c)
int y = a * b + c;   // redundant — identical expression
int z = x + y;
return z;
```

Here `a * b + c` is computed twice. CSE identifies this and reuses the result from the first computation instead of repeating the multiply and add.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, Clang emits unoptimized IR with the `noinline nounwind optnone` attributes. Every source statement maps literally to an alloca/store/load/compute sequence:

- Variables `a`, `b`, `c`, `x`, `y`, `z` each have their own `alloca i32` stack slot.
- `a * b + c` is computed **twice** in full:
  - First: `load a` → `load b` → `mul nsw` → `load c` → `add nsw` → `store` into `x`'s slot
  - Second: same `load` → `mul nsw` → `load` → `add nsw` sequence repeated → stored into `y`'s slot
- `z = x + y` is computed with explicit loads from both slots.
- No SSA-level value reuse; `mem2reg` has not been applied.

**Key observation:** Two separate `mul nsw i32` instructions appear for `a * b` — no elimination has occurred.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM applies **mem2reg** (promotes `alloca`s to SSA registers) along with **EarlyCSE** and constant folding. Because `a = 4`, `b = 5`, `c = 3` are compile-time constants:

- All arithmetic is evaluated at compile time: `a * b + c = 4 * 5 + 3 = 23`.
- `x` and `y` are both `23` — CSE identifies them as the same SSA value.
- `z = x + y = 23 + 23 = 46`.
- The entire function body collapses to a single instruction: `ret i32 46`.

No `alloca`, no `store`, no `load`, no `mul`, no `add` — all replaced by a constant return.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** for this example, since the constants were fully folded at the first optimization level:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 46
}
```

Additional function attributes are annotated: `mustprogress nofree norecurse nosync nounwind willreturn memory(none)`, reflecting LLVM's deeper analysis confirming the function has no side effects and always terminates with the same constant value.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 46`. The code is already completely optimized — there are no loops to vectorize or unroll, and no function calls to aggressively inline.

---

## Summary Table

| Level | `alloca`/`store`/`load` | Redundant `mul nsw` | IR Instructions | Return Value |
|-------|-------------------------|---------------------|-----------------|--------------|
| `-O0` | Yes (7 `alloca`s) | 2× `mul nsw` present | ~25 instructions | Computed at runtime |
| `-O1` | Eliminated | Eliminated | 1 (`ret i32 46`) | `ret i32 46` |
| `-O2` | Eliminated | Eliminated | 1 (`ret i32 46`) | `ret i32 46` |
| `-O3` | Eliminated | Eliminated | 1 (`ret i32 46`) | `ret i32 46` |

---

## Key Takeaway

CSE kicks in at **-O1** via LLVM's `EarlyCSE` and `GVN` passes. Because LLVM IR uses SSA form, identical expressions produce the same SSA value and are trivially deduplicated. Combined with constant folding at `-O1`, the redundant multiply vanishes entirely and the whole function reduces to a single `ret i32 46`.
