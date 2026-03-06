# Copy Propagation (CopyP)

## What is it?

Copy Propagation is a compiler optimization where a **copy of a variable** (an assignment like `b = a`) is replaced by the **original variable** everywhere the copy is used.

When the compiler sees `int b = a;`, it notes that `b` is simply an alias for `a`. Every subsequent read of `b` is replaced by a read of `a` directly. The now-unused copy variable can then be removed by **Dead Code Elimination** as a follow-on pass.

In LLVM, Copy Propagation is largely transparent because LLVM IR uses **SSA form** — each value is defined exactly once. When `mem2reg` promotes `alloca`s to SSA registers, copy chains (`c = b = a`) collapse automatically since intermediate `store`/`load` pairs become direct SSA value forwarding.

## Source Code (`example_1_1.c`)

```c
int a = 42;
int b = a;          // b is a copy of a
int c = b;          // c is a copy of b (which is a copy of a)
int result = c + 8; // after propagation: result = a + 8 = 50
return result;
```

After two-step propagation: `b → a`, `c → b → a`. All uses of `b` and `c` become direct uses of `a`, making `b` and `c` dead.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, Clang emits a full alloca/store/load chain for every variable:

- `alloca i32` slots for `a`, `b`, `c`, `result`.
- `store i32 42, ptr %a_slot` — stores the literal 42.
- `load` a → `store` into `b_slot` (copy 1).
- `load` b → `store` into `c_slot` (copy 2).
- `load` c → `add nsw i32 %c_val, 8` → `store` into `result_slot`.
- `load` result → `ret`.

All four variables occupy stack memory. The copy chain is faithfully preserved with explicit `load`/`store` pairs.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, **mem2reg** promotes all `alloca`s to SSA values. Once in SSA form, the copy chain `b = a`, `c = b` collapses:

- `a` holds the SSA constant `42`.
- `b` and `c` become the same SSA value as `a` — they are eliminated as redundant copies.
- `result = a + 8 = 42 + 8 = 50` — folded via Constant Propagation.
- Function becomes: `ret i32 50`.

No `alloca`s, no memory operations for `b` or `c`, no `add` instruction remaining.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — full copy elimination and constant folding already happened at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 50
}
```

Function attributes confirm side-effect freedom and constant return value.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 50`. There are no loops or calls to further optimize.

---

## Summary Table

| Level | Variables `b`, `c` in IR | Copy alloca/load/store | Runtime `add` | Return Value |
|-------|--------------------------|------------------------|---------------|--------------|
| `-O0` | Present (stack slots) | Full chain present | Present | Computed at runtime |
| `-O1` | Eliminated (SSA collapse) | Eliminated | Eliminated (folded) | `ret i32 50` |
| `-O2` | Eliminated | Eliminated | Eliminated | `ret i32 50` |
| `-O3` | Eliminated | Eliminated | Eliminated | `ret i32 50` |

---

## Key Takeaway

Copy Propagation in LLVM is essentially automatic once **mem2reg** runs. In SSA form, a "copy" (`b = a`) is simply two SSA names referring to the same definition — there is no actual copy instruction. The intermediate names are removed and all downstream uses point directly to the original definition. When combined with Constant Propagation, the chain collapses entirely at **-O1**, reducing the function to a single `ret i32 50`.
