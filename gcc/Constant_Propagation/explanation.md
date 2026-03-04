# Constant Propagation

## What is it?

Constant Propagation is a compiler optimization where variables that are assigned known constant values are replaced throughout the code by those constants. Once a variable is substituted, further constant folding can often evaluate entire expressions at compile time, eliminating all runtime arithmetic.

## Source Code (`example.c`)

```c
int x = 10;           // x is a known constant
int y = x + 5;        // propagated: y = 10 + 5 = 15
int z = y * 2;        // propagated: z = 15 * 2 = 30
printf("x=%d, y=%d, z=%d\n", x, y, z);
```

`x` is assigned a literal 10. Propagating that into the next line gives `y = 15`. Propagating `y` gives `z = 30`. All three values are known at compile time.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

Every statement is emitted literally with no constant substitution:

- `x = 10` is stored to `-4(%rbp)`.
- `y = x + 5` loads `x` from the stack, adds the immediate 5, stores to `-8(%rbp)`.
- `z = y * 2` loads `y` and emits `addl %eax, %eax` (a multiply-by-2 using addition), stores to `-12(%rbp)`.
- All three values are then loaded back from the stack for `printf`.
- Stack frame is 48 bytes; `%rbp` pushed and used as frame pointer.

```asm
movl  $10, -4(%rbp)       ; x = 10
movl  -4(%rbp), %eax
addl  $5, %eax            ; y = x + 5
movl  %eax, -8(%rbp)
movl  -8(%rbp), %eax
addl  %eax, %eax          ; z = y * 2
movl  %eax, -12(%rbp)
```

**Key observation:** Runtime loads and arithmetic present for every assignment. No propagation.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC performs constant propagation followed by constant folding:

- Substitutes `x = 10` → evaluates `y = 10 + 5 = 15` at compile time.
- Substitutes `y = 15` → evaluates `z = 15 * 2 = 30` at compile time.
- All three values are inlined directly as immediate operands for `printf`:

```asm
movl  $30, %r9d   ; z = 30
movl  $15, %r8d   ; y = 15
movl  $10, %edx   ; x = 10
```

- Stack frame eliminated entirely (no `%rbp` push, no stack variables).
- Stack usage reduced from 48 bytes to 40 bytes (Win64 shadow space only).
- `return 0` encoded as `movl $0, %eax`.

**Key optimization:** All three variables are propagated and folded — zero runtime arithmetic.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

The computed constants remain the same as `-O1`:

```asm
movl  $30, %r9d
movl  $15, %r8d
movl  $10, %edx
```

Improvements over `-O1`:

- `return 0` is now `xorl %eax, %eax` — a smaller, faster encoding (XOR of a register with itself is always 0, avoids a 5-byte immediate move).
- Function placed in `.text.startup` section for better cache grouping of startup routines.
- `.p2align 4` aligns the function to a 16-byte boundary for improved instruction fetch.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

Output is **identical to `-O2`**. The code is already at the minimum possible — three immediate loads and a single `printf` call. No loops, branches, or call sites exist that would unlock `-O3`-specific passes (vectorization, loop unrolling, interprocedural analysis).

---

## Summary Table

| Level | Runtime Arithmetic | Stack Frame | Variable Storage | `return 0` encoding | Notes |
|-------|--------------------|-------------|-----------------|---------------------|-------|
| `-O0` | Yes (add + add)    | Yes (48 B)  | Stack slots     | `movl $0, %eax`     | Literal translation |
| `-O1` | None               | No (40 B)   | Immediates only | `movl $0, %eax`     | Constants propagated and folded |
| `-O2` | None               | No (40 B)   | Immediates only | `xorl %eax, %eax`   | Startup section, alignment |
| `-O3` | None               | No (40 B)   | Immediates only | `xorl %eax, %eax`   | Same as -O2 |

---

## Key Takeaway

Constant propagation fully activates at **-O1**, where the compiler recognizes that `x`, `y`, and `z` are all compile-time constants and replaces every variable reference with its literal value. `-O2` and `-O3` refine the surrounding code structure (alignment, section placement, return encoding) but the propagation itself was already complete at `-O1`.
