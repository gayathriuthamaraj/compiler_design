# Induction Variable Elimination (IVE)

## What is it?

Induction Variable Elimination is a compiler optimization targeting loops. An **induction variable** is a variable whose value changes by a fixed amount each loop iteration, typically as a linear function of the loop counter. When such a variable can be expressed incrementally (adding a constant each step instead of multiplying by the loop counter), the compiler replaces the expensive multiply with cheaper additions, and can eliminate the derived variable entirely if it is not needed outside the loop. At higher optimization levels, the loop itself may be vectorized or fully evaluated at compile time.

## Source Code (`example.c`)

```c
int arr[10];
int n = 10;

for (int i = 0; i < n; i++) {
    int j = i * 3;   // j is an induction variable: j = 0, 3, 6, 9, ...
    arr[i] = j;
}
printf("arr[3] = %d\n", arr[3]);  // prints 9
```

`j` is always `i * 3`. Rather than multiplying each iteration, the compiler can maintain `j` with an increment of 3 per cycle (`j += 3`), or eliminate `j` entirely by computing `arr[i]` directly. At the highest levels the whole loop is evaluated at compile time.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_o0.s`)

The loop runs in full with a multiply every iteration:

- `i` is stored on the stack at `-4(%rbp)`, `n` at `-8(%rbp)`.
- Each iteration: `j = i * 3` is computed as:
  ```asm
  movl  -4(%rbp), %edx      ; load i
  movl  %edx, %eax
  addl  %eax, %eax           ; eax = i * 2
  addl  %edx, %eax           ; eax = i * 2 + i = i * 3
  movl  %eax, -12(%rbp)     ; store j
  ```
  (GCC uses a strength-reduced `2×i + i` instead of `imull $3` even at -O0 for this simple multiplication.)
- `arr[i] = j` stores to the appropriate array slot.
- `i` incremented and compared with `n` each iteration.
- `arr[3]` = `-52(%rbp)` loaded explicitly for `printf`.

**Key observation:** Full loop body, index computation every iteration, all variables on the stack.

---

### `-O1` — Basic Optimizations (`example_o1.s`)

GCC discovers that the only observable side effect of the loop is the value of `arr[3]`, which equals `3 * 3 = 9`.

- The **entire loop is eliminated** — no loop instructions appear in the assembly at all.
- `arr[3]` is never written to memory; its value is constant-folded to `9`.
- `printf` is called with the immediate `$9`:

```asm
movl  $9, %edx
```

- Stack frame eliminated; 40 bytes shadow space only.
- `return 0` as `movl $0, %eax`.

**Key optimization:** Induction variable analysis + constant propagation combine to eliminate the entire array and loop.

---

### `-O2` — Additional Optimizations (`example_o2.s`)

At `-O2`, the compiler cannot statically fold the entire array in the general case (it preserves the loop for correctness when addressing is non-trivial), so it **vectorizes** the loop using SSE2 SIMD instructions instead:

- The array base is loaded into `%rax`, end pointer into `%rdx`.
- Vectors of initial values and increments are stored as constants in `.rdata`:
  ```asm
  .LC0:
      .long 0   ; packed pair [arr[0], arr[1]] starting values
      .long 1
  .LC1:
      .long 2   ; increment per-pair (step of 2 iterations)
      .long 2
  ```
- Each loop iteration processes **two array elements simultaneously** using 64-bit XMM operations:
  ```asm
  movdqa  %xmm0, %xmm1
  pslld   $1, %xmm1          ; multiply current pair by 2
  paddd   %xmm0, %xmm1       ; add original: effective ×3
  paddd   %xmm2, %xmm0       ; advance base by 2 steps
  movq    %xmm1, -8(%rax)    ; store 2 elements
  ```
- After the vectorized loop, `arr[3]` is read from `44(%rsp)` for `printf`.

**Key optimization:** SIMD vectorization — 2 elements per cycle, replacing the scalar multiply-per-element loop.

---

### `-O3` — Aggressive Optimizations (`example_o3.s`)

At `-O3`, GCC performs full interprocedural analysis and determines the result of `arr[3]` is always `9`:

- The loop is **completely eliminated** again (like `-O1`).
- `printf` is called with the hard-coded constant `$9`:

```asm
movl  $9, %edx
```

- Stack usage returns to 40 bytes; `xorl %eax, %eax` for return.

**Key optimization:** Aggressive constant propagation and loop inference fold the entire loop away.

---

## Summary Table

| Level | Loop present | Multiply per iteration | Vectorized | Result at runtime | Notes |
|-------|-------------|------------------------|------------|-------------------|-------|
| `-O0` | Yes          | Yes (2×i + i for ×3)  | No         | Computed in loop  | Fully literal |
| `-O1` | Eliminated   | No                     | No         | Constant $9       | Loop folded entirely |
| `-O2` | Yes (vectorized) | No (SIMD `pslld`+`paddd`)| Yes (SSE2) | Computed by vector | 2 elements/cycle |
| `-O3` | Eliminated   | No                     | No         | Constant $9       | Aggressive fold |

---

## Key Takeaway

This example illustrates three distinct optimization strategies across the levels:

- **-O1**: The compiler proves the only observable output (`arr[3] = 9`) is constant and eliminates the loop entirely.
- **-O2**: Without the aggressive folding of `-O1`/`-O3`, the compiler keeps the loop but transforms it into a SIMD vectorized loop that processes two elements per iteration using XMM registers, eliminating the per-element scalar multiply.
- **-O3**: Returns to full constant folding, eliminating the loop again as in `-O1`, but leveraging more aggressive inter-pass analysis.

The progression from scalar loop → loop elimination → SIMD vectorization → full fold demonstrates the increasing sophistication of GCC's induction variable and loop optimization passes.
