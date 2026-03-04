# Common Subexpression Elimination (CSE)

## What is it?

Common Subexpression Elimination is a compiler optimization that detects when the same expression is computed more than once with the same operands, and replaces subsequent computations with the already-computed result. This avoids redundant arithmetic work.

## Source Code (`example.c`)

```c
int a = 4, b = 5, c = 3;
int x = a * b + c;   // first occurrence of (a*b+c)
int y = a * b + c;   // redundant — identical expression
int z = x + y;
printf("x = %d, y = %d, z = %d\n", x, y, z);
```

Here `a * b + c` is computed twice. CSE identifies this and reuses the result from the first computation instead of repeating the multiply and add.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

The compiler emits naive, unoptimized code. Every statement in the source is translated literally:

- Variables `a`, `b`, `c` are stored on the stack (`-4(%rbp)`, `-8(%rbp)`, `-12(%rbp)`).
- `a * b + c` is computed **twice** in full:
  - First: `movl -4(%rbp), %eax` → `imull -8(%rbp), %eax` → `addl %edx, %eax` → stored at `-16(%rbp)` (x)
  - Second: same sequence of `imull` + `addl` repeated → stored at `-20(%rbp)` (y)
- `z = x + y` is computed explicitly and stored at `-24(%rbp)`.
- Each variable is loaded from the stack for the `printf` call.
- Stack frame is 64 bytes; `%rbp` is pushed and used as a frame pointer.

**Key observation:** Two separate `imull` instructions appear for the same expression — no elimination occurs.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

At `-O1`, GCC performs CSE along with constant folding and propagation. Because `a`, `b`, and `c` are compile-time constants (4, 5, 3), the compiler:

- Evaluates `a * b + c = 4 * 5 + 3 = 23` at compile time.
- Recognizes that `x` and `y` are identical, so `y = x = 23`.
- Computes `z = x + y = 23 + 23 = 46` at compile time.
- The entire computation is replaced by three immediate `movl` instructions:

```asm
movl  $46, %r9d   ; z
movl  $23, %r8d   ; y
movl  $23, %edx   ; x
```

- No stack frame (`%rbp` not pushed), no stack variables, no `imull` at all.
- Stack shrinks from 64 bytes to just 40 bytes (shadow space for Win64 ABI).
- **Return 0** is emitted as `movl $0, %eax`.

**Key optimization:** CSE + constant folding eliminates all arithmetic. The redundant `imull` is gone.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

At `-O2`, the computations are identical to `-O1` (the constants were already fully folded):

```asm
movl  $46, %r9d
movl  $23, %r8d
movl  $23, %edx
```

New improvements over `-O1`:

- `return 0` is emitted as `xorl %eax, %eax` instead of `movl $0, %eax`. This is a well-known idiom that is one byte smaller and avoids a load from the immediate encoding.
- The function is placed in the `.text.startup` section, grouping startup code for improved cache locality.
- `.p2align 4` aligns the function entry to a 16-byte boundary, improving instruction fetch performance.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

At `-O3`, the output is **identical to `-O2`** for this example. The code is already fully optimized — all values are compile-time constants, and there are no loops, branches, or function calls that would benefit from `-O3`-specific passes such as vectorization or loop unrolling.

```asm
movl  $46, %r9d
movl  $23, %r8d
movl  $23, %edx
```

---

## Summary Table

| Level | Redundant `imull` | Stack Frame | Arithmetic at Runtime | `return 0` encoding | Notes |
|-------|-------------------|-------------|----------------------|---------------------|-------|
| `-O0` | 2× `imull` present | Yes (64 B)  | Yes (loads + multiply) | `movl $0, %eax` | Literal translation |
| `-O1` | Eliminated        | No (40 B)   | No (all constants)    | `movl $0, %eax` | CSE + constant fold |
| `-O2` | Eliminated        | No (40 B)   | No                    | `xorl %eax, %eax` | Startup section, alignment |
| `-O3` | Eliminated        | No (40 B)   | No                    | `xorl %eax, %eax` | Same as -O2 |

---

## Key Takeaway

The core CSE transformation — eliminating the second `a * b + c` computation — happens at **-O1**. `-O2` and `-O3` add secondary improvements (better `return` encoding, function alignment, startup section placement) but the redundant subexpression was already removed at the first optimization level.
