# Function Inlining (FI)

## What is it?

Function Inlining is a compiler optimization where the compiler **replaces a function call with the body of the called function** directly at the call site.

Instead of the normal call sequence (push arguments, jump to function, execute body, return), LLVM pastes the function's IR directly where the call appears. This eliminates all function-call overhead and — crucially — enables further optimizations such as constant folding on the now-visible function body.

In LLVM, inlining is performed by the **`-inline`** pass (part of the default pass pipeline). LLVM uses a cost model based on instruction count to decide whether inlining is profitable. Small functions are always inlined at `-O2` and above.

## Source Code (`example_1_1.c`)

```c
static inline int square(int x) {
    return x * x;
}

int main() {
    int a = 6;
    int result = square(a);  // inlined: result = a * a = 36
    return result;
}
```

`square` is a tiny function with a single `mul` instruction. The `static inline` keyword is a programmer hint; LLVM makes the final decision based on its cost model.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, the `inline` hint is **ignored**. `square` is compiled as a separate function and called normally:

- `square` function: `alloca i32` for `x`, `load` → `mul nsw i32 %x, %x` → `ret`.
- `main`: `alloca i32` for `a` and `result`, `store i32 6` → `call i32 @square(i32 6)` → `store` return value → `load` → `ret`.
- A genuine function call with argument passing takes place at runtime.

**Key observation:** `call i32 @square` appears in the IR — the function has not been inlined.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM inlines `square` into `main`:

- The call `square(a)` is replaced with the body: `result = a * a`.
- Since `a = 6` is a known constant: `result = 6 * 6 = 36` — folded immediately.
- All `alloca`s are eliminated by `mem2reg`.
- Function becomes: `ret i32 36`.

`square` may or may not still appear as a separate function (if it has no remaining callers, it is also removed as dead code).

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — inlining and constant folding already achieved the final result at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 36
}
```

`square` is completely gone from the IR. `main` is fully self-contained.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 36`. Aggressive inlining is even more proactive, but this function was already fully optimized.

---

## Summary Table

| Level | `square` in IR | `call @square` in `main` | Runtime `mul` | Return Value |
|-------|----------------|--------------------------|---------------|--------------|
| `-O0` | Present (separate function) | Present | Present | Computed at runtime |
| `-O1` | Removed (inlined + dead) | Removed | Eliminated (folded) | `ret i32 36` |
| `-O2` | Removed | Removed | Eliminated | `ret i32 36` |
| `-O3` | Removed | Removed | Eliminated | `ret i32 36` |

---

## Key Takeaway

Function Inlining activates at **-O1** in LLVM for small functions. Once inlined, the callee's code is visible alongside the caller's context — enabling Constant Propagation and Constant Folding to eliminate the now-trivial arithmetic. For small utility functions like `square`, `abs`, `min`, and `max`, inlining effectively makes them zero-cost. LLVM balances code-size growth against speed gain automatically via its cost model.
