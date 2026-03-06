# Function Cloning (FC)

## What is it?

Function Cloning is a compiler optimization where LLVM creates **specialized copies** (clones) of a function, each tailored for a specific set of constant arguments used at a particular call site.

When a function is called with **constant arguments** at a known call site, LLVM can specialize the function body by substituting that constant directly. Branches whose conditions are now compile-time-known are resolved immediately, leaving a leaner function body with no runtime branching.

In LLVM, this is driven by the **`-ipsccp`** (Interprocedural Sparse Conditional Constant Propagation) and **`-function-attrs`** passes at `-O3`. It is closely related to Function Inlining — at aggressive levels, small clones are likely inlined entirely.

## Source Code (`example_1_1.c`)

```c
int process(int value, int mode) {
    if (mode == 0) {
        return value * 2;
    } else {
        return value + 100;
    }
}

int main() {
    int r1 = process(10, 0);   // mode is always 0 here
    int r2 = process(10, 1);   // mode is always 1 here
    return r1 + r2;            // 20 + 110 = 130
}
```

Both call sites pass **constant** `mode` values. LLVM can specialize `process` for each.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, `process` is compiled as a general function with the full branch:

- `alloca i32` for `value`, `mode`, and the return slot.
- At runtime, `mode` is loaded from the stack.
- `icmp eq i32 %mode, 0` — a runtime conditional branch is executed.
- Both branches (`value * 2` and `value + 100`) exist in the IR.
- `main()` calls `process(10, 0)` and `process(10, 1)` as genuine function calls with argument setup each time.

No specialization occurs; every call incurs full function-call overhead plus a runtime branch inside `process`.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM performs interprocedural constant propagation. Since `mode` is a compile-time constant at both call sites:

- The call `process(10, 0)`: `mode = 0` is propagated into `process` → the `if (mode == 0)` condition is always true → the else branch is eliminated → `r1 = 10 * 2 = 20`.
- The call `process(10, 1)`: `mode = 1` is propagated → the if-branch is eliminated → `r1 = 10 + 100 = 110`.
- `r1 + r2 = 20 + 110 = 130` — constant-folded.
- The function `process` may be inlined at both call sites.
- `main()` reduces to: `ret i32 130`.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — the specialization and constant folding already achieved the minimum at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 130
}
```

Additional analysis confirms pure function attributes. `process` may or may not be retained in the IR (if inlined everywhere, it is removed as a dead function).

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 130`. LLVM has fully inlined and specialized `process` at both call sites. Aggressive inlining means `process` disappears entirely from the binary.

---

## Summary Table

| Level | `process` function | Runtime branch in `process` | Call overhead | Return Value |
|-------|--------------------|-----------------------------|---------------|--------------|
| `-O0` | Present (general, branching) | Present (runtime `icmp`) | Full call setup | Computed at runtime |
| `-O1` | Inlined/specialized | Eliminated | Eliminated | `ret i32 130` |
| `-O2` | Eliminated | Eliminated | Eliminated | `ret i32 130` |
| `-O3` | Eliminated | Eliminated | Eliminated | `ret i32 130` |

---

## Key Takeaway

Function Cloning/Specialization in LLVM is most visible at **-O1** via interprocedural constant propagation. Once a constant argument is known at a call site, LLVM substitutes it into the callee, collapses branches, and often inlines the resulting single-path function entirely. The trade-off — slightly larger binary due to specialized copies — is outweighed by zero runtime branching at each call site.
