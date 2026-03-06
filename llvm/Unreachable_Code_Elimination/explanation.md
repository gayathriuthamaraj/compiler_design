# Unreachable Code Elimination (UCE)

## What is it?

Unreachable Code Elimination is a compiler optimization that detects and **removes code that can never be executed** under any circumstances.

Code becomes unreachable in two main ways:
1. **Post-return code** — instructions after a `return` statement can never run.
2. **Always-false branches** — when a conditional's value is a compile-time constant, the branch that can never be taken is dead.

In LLVM, this is performed by the **`-simplifycfg`** (Control Flow Graph simplification) pass, which removes unreachable basic blocks, and by **SCCP** which evaluates branch conditions statically and marks infeasible successors as unreachable.

## Source Code (`example_1_1.c`)

```c
int getValue() {
    return 42;
    return -1;   // UNREACHABLE — dead after the first return
}

int main() {
    int x = 1;
    int result = 0;
    if (x > 0) {
        result = 1;   // ALWAYS taken — x = 1 is always > 0
    } else {
        result = -1;  // UNREACHABLE — else branch is never executed
    }
    int v = getValue();
    return v + result;  // 42 + 1 = 43
}
```

Two sources of unreachable code: post-return (`return -1` in `getValue`) and an always-false branch (the `else` block in `main`).

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, **all** code is emitted, including the unreachable parts:

- `getValue()`: two separate `ret i32` instructions are present. The second `ret i32 -1` occupies an unreachable basic block that still appears in the IR.
- `main()`: the full if-else is compiled with both branches:
  - `icmp sgt i32 %x, 0` — runtime branch check.
  - True block: `store i32 1, ptr %result_slot`.
  - False block: `store i32 -1, ptr %result_slot` — **never executed, but still in the IR**.
- `call i32 @getValue()` is a genuine function call.

No dead code analysis has been performed; the binary includes dead instructions.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, **SimplifyCFG** and **SCCP** eliminate all unreachable code:

- `getValue()`: the second `return -1` is removed. The function becomes `ret i32 42`.
- `main()`: `x = 1` is a known constant. `x > 0` → `1 > 0` → always `true`. The `else` block is recognized as an **unreachable** basic block and eliminated entirely. No conditional branch remains.
- `getValue()` is inlined into `main`, folding `v = 42`.
- `result = 1` is a constant.
- `v + result = 42 + 1 = 43` — constant-folded.
- Function becomes: `ret i32 43`.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — all unreachable code was already removed at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 43
}
```

Additional function attributes confirm the function is pure and side-effect-free.

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 43`. No additional transformations apply.

---

## Summary Table

| Level | Post-return `ret -1` in `getValue` | Unreachable `else` block | Runtime branch | Return Value |
|-------|-------------------------------------|--------------------------|----------------|--------------|
| `-O0` | Present (dead basic block) | Present (never executed) | `icmp sgt` present | Computed at runtime |
| `-O1` | Removed | Removed | Eliminated | `ret i32 43` |
| `-O2` | Removed | Removed | Eliminated | `ret i32 43` |
| `-O3` | Removed | Removed | Eliminated | `ret i32 43` |

---

## Key Takeaway

Unreachable Code Elimination in LLVM activates at **-O1** via `SimplifyCFG` and `SCCP`. LLVM explicitly marks unreachable successors with the `unreachable` IR instruction, then removes them from the CFG. Two mechanisms combine here: post-return code is trivially unreachable at parse time, while infeasible branches require constant propagation to evaluate the condition statically. Removing dead branches directly reduces binary size and eliminates runtime branch mispredictions.
