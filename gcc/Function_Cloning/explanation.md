# Function Cloning

## What is it?

Function Cloning (also called interprocedural constant propagation or call-site specialization) is a compiler optimization where GCC creates a specialized copy of a function tailored to specific argument values known at particular call sites. By propagating constant arguments into the clone, the branch logic inside the function can be resolved at compile time, producing a simpler, faster version without affecting other call sites that use variable arguments.

## Source Code (`example.c`)

```c
int process(int value, int mode) {
    if (mode == 0) {
        return value * 2;
    } else {
        return value + 100;
    }
}

int main() {
    int r1 = process(10, 0);   // mode is constant 0
    int r2 = process(10, 1);   // mode is constant 1
    printf("r1 = %d, r2 = %d\n", r1, r2);
}
```

Both call sites pass constant `mode` values. GCC can specialize `process` for each and resolve the `if/else` branch entirely.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

The function is compiled as-is with full branching logic:

- `process` has a complete stack frame with `%rbp`.
- The `if (mode == 0)` test is emitted as a `cmpl $0, 24(%rbp)` / `jne .L2` branch.
- Two separate code paths exist: the `value * 2` path (`addl %eax, %eax`) and the `value + 100` path (`addl $100, %eax`).
- In `main`, two explicit calls `call process` appear, passing `(10, 0)` and `(10, 1)` through registers.
- Results are stored on the stack for `printf`.

```asm
; Inside process — full branch:
cmpl  $0, 24(%rbp)
jne   .L2
addl  %eax, %eax     ; value * 2
jmp   .L3
.L2:
addl  $100, %eax     ; value + 100
```

**Key observation:** Runtime branch, stack frame, two explicit `call process` instructions in `main`.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC applies interprocedural constant propagation and collapses the branch in `process`:

- The function `process` is still present as a symbol (it is `globl`), but the branching code is replaced with a branchless sequence using a conditional move:

```asm
process:
    leal  (%rcx,%rcx), %eax   ; pre-compute value * 2
    addl  $100, %ecx           ; pre-compute value + 100
    testl %edx, %edx
    cmovne %ecx, %eax          ; select based on mode: no branch!
    ret
```

- In `main`, the two call sites with constant arguments are evaluated entirely at compile time:
  - `process(10, 0)` → `10 * 2 = 20`
  - `process(10, 1)` → `10 + 100 = 110`
- Both calls are **inlined and folded away** — no `call process` in `main`:

```asm
movl  $110, %r8d   ; r2
movl  $20,  %edx   ; r1
```

- Stack frame in `main` eliminated; 40 bytes shadow space only.

**Key optimization:** Branch converted to `cmovne` in `process`; call sites folded to constants in `main`.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

The same branchless `process` and constant `main` from `-O1` are preserved:

```asm
; process: same cmovne sequence
; main: movl $110, movl $20 — unchanged
```

Improvements over `-O1`:

- `.p2align 4` added before `process` — aligns function entry to 16-byte boundary.
- `main` placed in `.text.startup` section.
- `return 0` uses `xorl %eax, %eax` instead of `movl $0, %eax`.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

Output is **identical to `-O2`**. The function body is already branchless, and the call sites are already folded. No loops or additional call sites exist for `-O3` passes (vectorization, aggressive inlining, profile-based unrolling) to transform.

---

## Summary Table

| Level | `process` body     | Branch in `process` | Calls in `main`       | `return 0` encoding | Notes |
|-------|--------------------|---------------------|-----------------------|---------------------|-------|
| `-O0` | Stack frame + jne  | `jne .L2` (branch)  | 2× `call process`     | `movl $0, %eax`     | Fully general function |
| `-O1` | No frame, cmovne   | `cmovne` (branchless)| Folded to $20, $110  | `movl $0, %eax`     | Specialized + folded |
| `-O2` | No frame, cmovne   | `cmovne` (branchless)| Folded to $20, $110  | `xorl %eax, %eax`   | Alignment, startup section |
| `-O3` | No frame, cmovne   | `cmovne` (branchless)| Folded to $20, $110  | `xorl %eax, %eax`   | Same as -O2 |

---

## Key Takeaway

The cloning/specialization effect is visible at **-O1**: the conditional branch inside `process` is eliminated by converting it to a branchless `cmovne`, and the constant call sites in `main` are folded down to immediate values with no actual call instruction emitted. `-O2` adds alignment and section directives; `-O3` finds no further opportunity in this example.
