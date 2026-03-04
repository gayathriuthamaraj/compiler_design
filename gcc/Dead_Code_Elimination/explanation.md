# Dead Code Elimination (DCE)

## What is it?

Dead Code Elimination is a compiler optimization that removes statements whose computed values are never used anywhere in the program. A variable or assignment is "dead" if its result cannot influence the program's observable output. Removing dead code reduces object-code size, lowers register pressure, and speeds up execution.

## Source Code (`example.c`)

```c
int a = 5;
int b = 20;      // b is computed but never referenced — dead assignment
int c = a + 10;  // c is used in printf
printf("c = %d\n", c);
```

The assignment `b = 20` is dead: `b` is written but never read. GCC's liveness analysis detects this and removes the assignment entirely.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

The dead assignment is emitted just as written in the source:

- `a = 5` stored at `-4(%rbp)`.
- `b = 20` stored at `-8(%rbp)` — **present even though unused**.
- `c = a + 10`: loads `-4(%rbp)`, adds 10, stores at `-12(%rbp)`.
- `c` loaded from stack for `printf`.

```asm
movl  $5,  -4(%rbp)     ; a = 5
movl  $20, -8(%rbp)     ; b = 20  ← dead code, still emitted
movl  -4(%rbp), %eax
addl  $10, %eax          ; c = a + 10
movl  %eax, -12(%rbp)
```

**Key observation:** `movl $20, -8(%rbp)` is a real instruction occupying space and time, yet its result is never consumed.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC performs liveness analysis and eliminates `b`:

- `b = 20` is identified as dead (no use of `b` reaches any read), and the instruction is **removed entirely**.
- `a = 5` feeds into `c = a + 10 = 15`, which is constant-folded.
- `printf` is called with the immediate `$15` — no stack frame, no variables:

```asm
movl  $15, %edx
```

- Stack reduced to 40 bytes (shadow space only), no `%rbp`.
- `return 0` encoded as `movl $0, %eax`.

**Key optimization:** Dead assignment `b = 20` is gone; `c` is folded to 15.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

The result is identical to `-O1` (already fully reduced):

```asm
movl  $15, %edx
```

Improvements over `-O1`:

- `return 0` is `xorl %eax, %eax` — a one-byte-shorter encoding.
- Function moved into `.text.startup` section for better cache grouping.
- `.p2align 4` aligns the function entry to a 16-byte boundary.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

Output is **identical to `-O2`**. The code is already minimal — a single immediate load and one `printf` call. No loops or complex control flow give `-O3`-specific passes anything to work on.

---

## Summary Table

| Level | Dead `b = 20` | Stack Frame | Runtime Arithmetic | `return 0` encoding | Notes |
|-------|--------------|-------------|-------------------|---------------------|-------|
| `-O0` | Present      | Yes (48 B)  | Yes (addl $10)    | `movl $0, %eax`     | Literal translation |
| `-O1` | Eliminated   | No (40 B)   | No (folded: 15)   | `movl $0, %eax`     | DCE + constant fold |
| `-O2` | Eliminated   | No (40 B)   | No                | `xorl %eax, %eax`   | Startup section, alignment |
| `-O3` | Eliminated   | No (40 B)   | No                | `xorl %eax, %eax`   | Same as -O2 |

---

## Key Takeaway

Dead Code Elimination fires at **-O1**, where liveness analysis proves that the assignment `b = 20` has no live uses and removes it from the generated code. The eliminated dead assignment also allows constant folding of `c` to complete. `-O2` and `-O3` add only structural polish (alignment, section placement, return encoding) on top of the already-clean `-O1` output.
