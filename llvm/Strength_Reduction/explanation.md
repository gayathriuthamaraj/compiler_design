# Strength Reduction (SR)

## What is it?

Strength Reduction is a compiler optimization that **replaces an expensive operation with an equivalent but cheaper operation** that produces the same result.

The most common substitution: multiplications or divisions by **powers of 2** are replaced with **bit shift** instructions:
- `x * 8`  → `x << 3` (left shift by 3, because 2³ = 8)
- `x * 4`  → `x << 2`
- `x / 4`  → `x >> 2`
- `x % 8`  → `x & 7`

Bit shifts are single-cycle CPU instructions — 3–5× faster than multiply or divide on most hardware.

In LLVM, Strength Reduction on arithmetic is applied during **IR construction** itself (via the `instcombine` pass) and confirmed by the **`-strength-reduce`** pass.

## Source Code (`example_1_1.c`)

```c
int x = 9;
int a = x * 8;   // replaced by: x << 3
int b = x * 4;   // replaced by: x << 2
return a + b;    // 72 + 36 = 108
```

Both multipliers (8 and 4) are powers of 2. LLVM replaces them with shift instructions at `-O1`.

---

## Optimization Progression: -O0 → -O1 → -O2 → -O3

### `-O0` — No Optimization (`example_O0.ll`)

At `-O0`, multiplications are emitted as `mul nsw` instructions — no substitution is made:

```llvm
%a = mul nsw i32 %x, 8   ; expensive multiply
%b = mul nsw i32 %x, 4   ; expensive multiply
```

- `alloca i32` slots for `x`, `a`, `b`.
- `x = 9` stored, then loaded before each multiply.
- Result stored and loaded for the final `add nsw`.
- No optimization of any kind is applied.

---

### `-O1` — Basic Optimizations (`example_O1.ll`)

At `-O1`, LLVM's **InstCombine** pass detects the power-of-2 multiplications and immediately substitutes shift instructions. Since `x = 9` is also a constant, the shifts are folded:

- `x * 8 = 9 * 8 = 72` — folded at compile time.
- `x * 4 = 9 * 4 = 36` — folded at compile time.
- `a + b = 72 + 36 = 108` — folded.
- Function becomes: `ret i32 108`.

Even for runtime-variable `x`, `-O1` would emit `shl i32 %x, 3` and `shl i32 %x, 2` instead of `mul`.

---

### `-O2` — Additional Optimizations (`example_O2.ll`)

At `-O2`, the output is **identical to `-O1`** — strength reduction and constant folding were fully achieved at `-O1`:

```llvm
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  ret i32 108
}
```

---

### `-O3` — Aggressive Optimizations (`example_O3.ll`)

At `-O3`, the output is **identical to `-O2`**: `ret i32 108`. No further transformations are applicable to this single-expression function.

---

## Summary Table

| Level | `mul nsw i32 %x, 8/4` | Shift instruction | Folded to constant | Return Value |
|-------|----------------------|-------------------|--------------------|--------------|
| `-O0` | Present (2× `mul`) | No | No | Computed at runtime |
| `-O1` | Replaced by `shl` | Yes → then folded | Yes (108) | `ret i32 108` |
| `-O2` | Eliminated | Folded | Yes | `ret i32 108` |
| `-O3` | Eliminated | Folded | Yes | `ret i32 108` |

---

## Key Takeaway

Strength Reduction for power-of-2 multiplications activates at **-O1** via LLVM's `InstCombine` pass. On CPUs where `imul` takes 3–5 cycles and `shl` takes 1 cycle, this is a concrete 3–5× speedup per multiply. For non-constant `x`, the optimization still applies — `mul i32 %x, 8` → `shl i32 %x, 3` — making it valuable in real-world code even without constant folding.
