# Copy Propagation

## What is it?

Copy Propagation is a compiler optimization that replaces uses of a variable that was assigned by a simple copy (e.g., `b = a`) with the original source variable (`a`). By removing intermediate copies, the compiler exposes further optimizations such as dead code elimination and constant folding, since the redundant copy variables can often be discarded entirely.

## Source Code (`example.c`)

```c
int a = 42;
int b = a;    // b is a copy of a
int c = b;    // c is a copy of b (transitively a copy of a)
int result = c + 8;   // after propagation: result = a + 8 = 42 + 8 = 50
printf("result = %d\n", result);
```

The chain `a → b → c` means every use of `c` can be replaced by `a` (and since `a` is a constant, the whole expression collapses to 50).

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

All copies are materialized on the stack with no substitution:

- `a = 42` stored at `-4(%rbp)`.
- `b = a`: loads `-4(%rbp)` into `%eax`, stores at `-8(%rbp)`.
- `c = b`: loads `-8(%rbp)` into `%eax`, stores at `-12(%rbp)`.
- `result = c + 8`: loads `-12(%rbp)`, adds 8, stores at `-16(%rbp)`.
- Result loaded from stack for `printf`.

```asm
movl  $42, -4(%rbp)          ; a = 42
movl  -4(%rbp), %eax
movl  %eax, -8(%rbp)         ; b = a
movl  -8(%rbp), %eax
movl  %eax, -12(%rbp)        ; c = b
movl  -12(%rbp), %eax
addl  $8, %eax               ; result = c + 8
movl  %eax, -16(%rbp)
```

**Key observation:** Three stack slots for `a`, `b`, `c`, plus one for `result`. Four memory rounds-trips just to compute `42 + 8`.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC applies copy propagation followed by constant folding:

- `b = a` and `c = b` are recognized as trivial copies and eliminated.
- All uses of `b` and `c` are replaced with `a` (copy propagation).
- Since `a = 42` is a constant, `result = 42 + 8 = 50` is folded at compile time.
- The entire chain collapses to a single immediate:

```asm
movl  $50, %edx
```

- Stack frame entirely eliminated — no `%rbp`, no stack slots.
- Stack usage: 40 bytes (Win64 shadow space only).
- `return 0` encoded as `movl $0, %eax`.

**Key optimization:** Copies `b = a` and `c = b` are gone; the final `result` is a known constant.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

The constant `50` remains the same as `-O1`:

```asm
movl  $50, %edx
```

Improvements over `-O1`:

- `return 0` is now `xorl %eax, %eax` — a more compact and efficient instruction.
- Function placed in the `.text.startup` section for improved instruction cache grouping.
- `.p2align 4` aligns the function entry to a 16-byte boundary.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

Output is **identical to `-O2`**. Since there are no loops, branches, or multiple call sites, the aggressive passes of `-O3` (auto-vectorization, loop unrolling, inline heuristics) find nothing further to transform.

---

## Summary Table

| Level | Copy statements  | Stack Frame | Runtime Arithmetic | `return 0` encoding | Notes |
|-------|-----------------|-------------|-------------------|---------------------|-------|
| `-O0` | 3 stack copies  | Yes (48 B)  | Yes (`addl $8`)   | `movl $0, %eax`     | All copies materialized |
| `-O1` | Eliminated      | No (40 B)   | No (folded: 50)   | `movl $0, %eax`     | Copy prop + constant fold |
| `-O2` | Eliminated      | No (40 B)   | No                | `xorl %eax, %eax`   | Startup section, alignment |
| `-O3` | Eliminated      | No (40 B)   | No                | `xorl %eax, %eax`   | Same as -O2 |

---

## Key Takeaway

Copy propagation eliminates the intermediate variables `b` and `c` at **-O1**, freeing the constant value of `a` to propagate through and fold the final `result` to 50 at compile time. `-O2` and `-O3` contribute only structural improvements (alignment, section assignment, return encoding) on an already fully optimized body.
