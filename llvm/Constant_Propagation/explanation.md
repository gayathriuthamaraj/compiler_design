# Constant Propagation (CP)

## What is it?

Constant Propagation is a compiler optimization where the compiler **tracks variables that hold a constant value** and **substitutes that constant directly** wherever the variable is read — since the value is fully known at compile time.

Instead of loading a variable from memory at runtime, the compiler replaces all uses of the variable with the actual constant it holds. Constant Propagation is typically paired with **Constant Folding**: propagation feeds known constants into expressions, and then folding evaluates those expressions at compile time.

In LLVM, Constant Propagation is driven by the **SCCP** (Sparse Conditional Constant Propagation) pass, which tracks constant-ness through the SSA def-use chain and propagates values across branches.

## Source Code (`example_1_1.c`)

```c
int x = 10;     // x is a known constant
int y = x + 5;  // propagated: y = 10 + 5 = 15
int z = y * 2;  // propagated: z = 15 * 2 = 30
return z;
```

`x` is initialized to `10` and never changed. LLVM propagates `x = 10` into the expression for `y`, folds `10 + 5 = 15`, then propagates `y = 15` into `z`, and folds `15 * 2 = 30`.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, Clang emits a literal, unoptimized translation. Every variable has its own `alloca i32` slot:

- `x = 10`: `store i32 10, ptr %x_slot`
- `y = x + 5`: `load` x → `add nsw i32 %x_val, 5` → `store` result into `y_slot`
- `z = y * 2`: `load` y → `mul nsw i32 %y_val, 2` → `store` result into `z_slot`
- Return: `load` z → `ret i32 %z_val`

Runtime `load`, `add nsw`, and `mul nsw` instructions are all present. `x`, `y`, and `z` are stored and retrieved from stack memory.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM applies **mem2reg** and **SCCP** (Constant Propagation):

- `x = 10` — known constant, propagated into all uses.
- `y = 10 + 5 = 15` — expression folded after propagation; no `add` at runtime.
- `z = 15 * 2 = 30` — chain-folded; no `mul` at runtime.
- All `alloca`s eliminated by `mem2reg`.
- Entire function body becomes: `ret i32 30`.

No memory operations, no arithmetic — just a single return of the compile-time constant `30`.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — constant propagation already reduced everything to a single return at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 30
}
```

Function attributes `mustprogress nofree norecurse nosync willreturn memory(none)` confirm the function is provably side-effect-free and always returns the same value.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 30`. No additional transformations are possible on this already-fully-optimized function.

---

## Summary Table

| Level | Variables in Memory | Runtime `add`/`mul` | IR Instructions | Return Value |
|-------|---------------------|---------------------|-----------------|--------------|
| `-O0` | `x`, `y`, `z` all on stack | Present | ~12 instructions | Computed at runtime |
| `-O1` | All eliminated | Eliminated | 1 (`ret i32 30`) | `ret i32 30` |
| `-O2` | All eliminated | Eliminated | 1 (`ret i32 30`) | `ret i32 30` |
| `-O3` | All eliminated | Eliminated | 1 (`ret i32 30`) | `ret i32 30` |

---

## Key Takeaway

Constant Propagation works by following the **def-use chain** in SSA form: once a variable is known to hold a constant, every use of it is replaced. LLVM's SCCP pass propagates through chains of definitions (`x → y → z`) in a single forward pass. Combined with Constant Folding, this collapses entire functions to a single `ret` instruction at **-O1**, eliminating all memory accesses and arithmetic.
