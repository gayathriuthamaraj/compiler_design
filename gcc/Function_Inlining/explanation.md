# Function Inlining

## What is it?

Function Inlining is a compiler optimization where the body of a called function is substituted directly at the call site, replacing the function call instruction with the actual code of the function. This eliminates call overhead (saving/restoring registers, pushing/popping stack frames, branching to and from the callee), and crucially, it exposes the inlined body to the caller's context so that further optimizations — such as constant folding and dead code elimination — can apply across what were previously function boundaries.

## Source Code (`example.c`)

```c
static inline int square(int x) {
    return x * x;
}

int main() {
    int a = 6;
    int result = square(a);   // call to be inlined
    printf("square(%d) = %d\n", a, result);
}
```

`square` is marked `static inline`, hinting to the compiler that it should be inlined. GCC honors this and replaces the call with `a * a`, which — since `a = 6` is constant — folds to `36`.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

Even though `square` is declared `static inline`, at `-O0` GCC does **not** inline it. The function is emitted as a separate, callable procedure:

```asm
square:
    pushq  %rbp
    movq   %rsp, %rbp
    movl   %ecx, 16(%rbp)    ; store argument x
    movl   16(%rbp), %eax
    imull  %eax, %eax         ; x * x
    popq   %rbp
    ret
```

In `main`:
- `a = 6` stored at `-4(%rbp)`.
- `a` loaded into `%ecx` and `call square` emitted.
- Return value stored on stack; loaded again for `printf`.
- `result` occupies a separate stack slot (`-8(%rbp)`).

**Key observation:** A real function call to `square` exists, with full prologue/epilogue, `imull`, and two memory round-trips.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC inlines `square` at the call site and then constant-folds the result:

- The `square` function body disappears entirely from the assembly — **no function symbol emitted**.
- At the call site, `a = 6` is known, so `square(6) = 6 * 6 = 36` is computed at compile time.
- The value 36 is placed directly as an immediate for `printf`:

```asm
movl  $36, %r8d   ; result = 36
movl  $6,  %edx   ; a = 6
```

- No `call square`, no `imull`, no stack variables for `a` or `result`.
- Stack frame eliminated; 40 bytes shadow space only.
- `return 0` encoded as `movl $0, %eax`.

**Key optimization:** Full inlining of `square` + constant fold of `6 * 6 = 36` — zero function call overhead.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

The values are identical to `-O1` (`$36` and `$6`). The `square` symbol is still absent.

Improvements over `-O1`:

- `return 0` is `xorl %eax, %eax` — a smaller encoding.
- `main` placed in `.text.startup` section for cache locality of startup code.
- `.p2align 4` aligns `main` to a 16-byte boundary.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

Output is **identical to `-O2`**. Inlining was already complete at `-O1`, and the constants are already folded. No loops, multi-call sites, or complex control flow exist in this example for `-O3` to exploit.

---

## Summary Table

| Level | `square` function | Call in `main`       | `imull` present | `return 0` encoding | Notes |
|-------|-------------------|----------------------|-----------------|---------------------|-------|
| `-O0` | Separate function  | `call square`        | Yes             | `movl $0, %eax`     | No inlining |
| `-O1` | Eliminated        | Folded to `$36`      | No              | `movl $0, %eax`     | Inlined + constant folded |
| `-O2` | Eliminated        | Folded to `$36`      | No              | `xorl %eax, %eax`   | Startup section, alignment |
| `-O3` | Eliminated        | Folded to `$36`      | No              | `xorl %eax, %eax`   | Same as -O2 |

---

## Key Takeaway

Inlining activates at **-O1**: the `square` function body is substituted at the call site, and since `a = 6` is a compile-time constant, the multiplication `6 * 6` is immediately folded to `36`, leaving no calling overhead whatsoever. `-O2` and `-O3` refine code layout and return encoding but do not change the inlining decision, which was already made at `-O1`.
