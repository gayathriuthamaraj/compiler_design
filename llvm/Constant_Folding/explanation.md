# Constant Folding (CF)

## What is it?

Constant Folding is a compiler optimization where expressions involving **only constant values** — values known at compile time — are evaluated by the compiler itself, before the program even runs.

Instead of generating machine instructions to calculate `3 + 4` at runtime, the compiler substitutes the expression with the pre-computed result `7`. This means no arithmetic operations happen at runtime; the values are baked directly into the compiled binary.

In LLVM, constant folding is applied at the IR level by the **ConstantFolding** pass and also inline during IR construction. It chains naturally with **Constant Propagation**: once one variable is folded, expressions depending on it can be folded in turn.

## Source Code (`example_1_1.c`)

```c
int a = 3 + 4;      // folded to 7
int b = 2 * 8;      // folded to 16
int c = 100 / 5;    // folded to 20
int d = a + b + c;  // folded to 43
return d;
```

Every sub-expression uses only literal constants, so the compiler can compute the final value `43` entirely at compile time.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, Clang emits a literal translation of the source with `noinline nounwind optnone`. No compile-time evaluation is performed:

- `alloca i32` slots are created for each of `a`, `b`, `c`, `d`.
- Arithmetic instructions are emitted for every expression:
  - `add nsw i32 3, 4` → stored as `a`
  - `mul nsw i32 2, 8` → stored as `b`
  - `sdiv i32 100, 5` → stored as `c`
  - Two `add nsw` instructions to compute `a + b + c` → stored as `d`
- Values are loaded from their stack slots before each operation.
- The function returns `d` via a load from its slot.

**Key observation:** Runtime `add`, `mul`, and `sdiv` instructions are present — no folding has occurred.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM applies **constant folding** and **mem2reg**. Because all operands are literal constants:

- `a = 3 + 4 = 7` — folded at compile time, no `add` instruction.
- `b = 2 * 8 = 16` — folded at compile time, no `mul` instruction.
- `c = 100 / 5 = 20` — folded at compile time, no `sdiv` instruction.
- `d = 7 + 16 + 20 = 43` — chain-folded at compile time.
- All `alloca`s eliminated by `mem2reg`.
- Entire function body becomes: `ret i32 43`.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — the full fold was already achieved at the first optimization level:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 43
}
```

Additional analysis attributes (`mustprogress nofree norecurse nosync nounwind willreturn memory(none)`) are added, confirming the function is pure and has no observable side effects.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 43`. There are no loops to vectorize, no function calls to inline further, and no additional folding possible.

---

## Summary Table

| Level | Runtime Arithmetic | `alloca`s | IR Instructions | Return Value |
|-------|--------------------|-----------|-----------------|--------------|
| `-O0` | `add`, `mul`, `sdiv` present | Yes (4 slots) | ~20 instructions | Computed at runtime |
| `-O1` | All eliminated | Eliminated | 1 (`ret i32 43`) | `ret i32 43` |
| `-O2` | All eliminated | Eliminated | 1 (`ret i32 43`) | `ret i32 43` |
| `-O3` | All eliminated | Eliminated | 1 (`ret i32 43`) | `ret i32 43` |

---

## Key Takeaway

Constant Folding is one of LLVM's earliest and most impactful passes: it activates at **-O1** and eliminates all runtime arithmetic on compile-time-known values. It also chains — because `a`, `b`, and `c` are all folded to constants, the dependent expression `d = a + b + c` can be folded in turn. The result is a function that compiles to a single `ret i32 43` instruction.
