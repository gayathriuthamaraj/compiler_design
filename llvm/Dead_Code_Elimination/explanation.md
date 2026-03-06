# Dead Code Elimination (DCE)

## What is it?

Dead Code Elimination is a compiler optimization that identifies and **removes code whose result is never used** — code that has no effect on the program's observable output.

A "dead definition" is any assignment or computation whose result is never read. LLVM identifies dead definitions via **liveness analysis**: working backwards from the function's outputs, any value that never contributes (directly or indirectly) to a return value or side effect is considered dead and removed.

In LLVM, DCE is performed by the **DCE** and **ADCE** (Aggressive Dead Code Elimination) passes, and is also a natural side effect of **mem2reg** and constant folding at -O1.

## Source Code (`example_1_1.c`)

```c
int a = 5;       // live — used in computing c
int b = 20;      // DEAD — never read, never used
int c = a + 10;  // live — returned
return c;
```

`b = 20` is assigned but its value is never referenced. LLVM will remove the assignment entirely since it has no effect on the observable output `c`.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, Clang emits a literal translation including the dead assignment:

- `alloca i32` slots for `a`, `b`, `c`.
- `store i32 5, ptr %a_slot` — live.
- `store i32 20, ptr %b_slot` — **dead, but still emitted**.
- `load` a → `add nsw i32 5, 10` → `store` into `c_slot` — live.
- `load` c → `ret i32 %c_val`.

The dead `b = 20` appears as an `alloca` + `store` in the IR, consuming stack space even though `b` is never loaded again.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, **mem2reg** promotes variables to SSA form and the **DCE pass** removes dead definitions:

- `b` is recognized as a dead SSA value (no uses after its definition).
- The `alloca` and `store` for `b` are **completely removed**.
- `a = 5` is a constant → `c = 5 + 10 = 15` is folded at compile time.
- Function becomes: `ret i32 15`.

No `alloca`s, no dead stores, no runtime arithmetic.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — DCE already eliminated the dead variable at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 15
}
```

Additional attributes (`mustprogress nofree norecurse nosync nounwind willreturn memory(none)`) confirm the function is completely pure.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 15`. No further transformations are applicable.

---

## Summary Table

| Level | Dead variable `b` in IR | `b = 20` instruction | Runtime `add` | Return Value |
|-------|-------------------------|----------------------|---------------|--------------|
| `-O0` | Present (`alloca` + `store`) | Present | Present | Computed at runtime |
| `-O1` | Completely removed | Removed | Eliminated (folded) | `ret i32 15` |
| `-O2` | Completely removed | Removed | Eliminated | `ret i32 15` |
| `-O3` | Completely removed | Removed | Eliminated | `ret i32 15` |

---

## Key Takeaway

Dead Code Elimination activates at **-O1** in LLVM. Once `mem2reg` converts `alloca`s to SSA values, a dead variable has zero uses in the def-use graph — making it trivially removable. DCE is also a natural consequence of Constant Propagation: when a variable is folded into a constant and fully inlined, the original definition becomes dead and is swept away. The result is a binary with no wasted instructions or memory.
