# Compiler Optimization — Original vs Optimized Code

**Subject:** Compiler Design | **SEM 6**
**Compilers:** GCC and LLVM (Clang)

> For each optimization:
> - **Original Code** = what the programmer writes
> - **Optimized Code** = what the compiler internally produces (shown as equivalent C)
> - **Explanation** = what changed and why

---

---

## 1. Common Subexpression Elimination (CSE)

### GCC
**Compile:** `gcc -O2 -fdump-tree-optimized example.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int a = 4, b = 5, c = 3;
    int x = a * b + c;   // computed: 23
    int y = a * b + c;   // same expression, computed AGAIN
    int z = x + y;
    printf("x=%d, y=%d, z=%d\n", x, y, z);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // a*b+c = 23, computed ONCE; y reuses x; z = 46
    // GCC folds all constants and collapses to:
    printf("x=%d, y=%d, z=%d\n", 23, 23, 46);
    return 0;
}
```

**Explanation:** `a * b + c` was computed twice with unchanged operands. GCC computes it once, stores the result in `x`, and reuses it for `y`. One multiply and one add are eliminated.

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o cse.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int a = 4, b = 5, c = 3;
    int x = a * b + c;
    int y = a * b + c;   // redundant
    int z = x + y;
    return z;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int x = 23;   // 4*5+3, computed ONCE and folded
    int z = 46;   // x + x, also folded
    return 46;
}
```

**Explanation:** LLVM detects both expressions are identical and maps `y` to the same SSA value as `x`. With constant folding also applied, the entire function reduces to `return 46`.

---
---

## 2. Constant Folding

### GCC
**Compile:** `gcc -O1 -o const_fold example_1_1.c`

**Original Code:**
```c
int main() {
    int a = 3 + 4;
    int b = 2 * 8;
    int c = 100 / 5;
    int d = a + b + c;
    return d;
}
```

**Optimized Code (GCC internal equivalent):**
```c
int main() {
    return 43;   // all expressions folded at compile time; no arithmetic at runtime
}
```

**Explanation:** All operands are literal constants. GCC evaluates every expression at compile time. No add/mul/div instruction is generated — the binary simply contains `return 43`.

---

### LLVM
**Compile:** `clang -O1 -S -emit-llvm -o const_fold.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int a = 3 + 4;
    int b = 2 * 8;
    int c = 100 / 5;
    int d = a + b + c;
    return d;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 43;   // entire function replaced by single constant return
}
```

**Explanation:** LLVM's constant folding pass evaluates all constant expressions during compilation. The IR shows a single `ret i32 43` — no arithmetic runs at runtime.

---
---

## 3. Constant Propagation

### GCC
**Compile:** `gcc -O1 -o const_prop example.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int x = 10;
    int y = x + 5;   // uses variable x
    int z = y * 2;   // uses variable y
    printf("x=%d, y=%d, z=%d\n", x, y, z);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // x=10 propagated into y=15, z=30; all variables eliminated
    // GCC replaces every variable reference with its constant value:
    printf("x=%d, y=%d, z=%d\n", 10, 15, 30);
    return 0;
    // Assembly: pushes 10, 15, 30 as immediate literals — zero memory loads
}
```

**Explanation:** GCC knows `x = 10` is constant and never changes. It substitutes `10` for `x`, computes `y = 15`, then substitutes `15` for `y`, computes `z = 30`. All variable reads are replaced with literal values.

---

### LLVM
**Compile:** `clang -O1 -S -emit-llvm -o const_prop.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int x = 10;
    int y = x + 5;
    int z = y * 2;
    return z;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 30;   // x→10, y→15, z→30, all folded
}
```

**Explanation:** LLVM propagates `x = 10` into `y`, folds to `15`, propagates into `z`, folds to `30`. The final IR is `ret i32 30` — no loads, no arithmetic at runtime.

---
---

## 4. Copy Propagation

### GCC
**Compile:** `gcc -O1 -o copy_prop example.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int a = 42;
    int b = a;       // copy
    int c = b;       // copy of copy
    int result = c + 8;
    printf("result = %d\n", result);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // b and c are copies — eliminated entirely
    // a=42 constant, result = 42+8 = 50, fully folded
    printf("result = %d\n", 50);
    return 0;
}
```

**Explanation:** `b = a` and `c = b` are simple copies. GCC traces `c → b → a` and replaces all uses of `c` with `a` directly. The intermediate variables `b` and `c` are removed from the binary.

---

### LLVM
**Compile:** `clang -O1 -S -emit-llvm -o copy_prop.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int a = 42;
    int b = a;
    int c = b;
    int result = c + 8;
    return result;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 50;   // a=42, copies eliminated, 42+8=50 folded
}
```

**Explanation:** LLVM's SSA form makes copy propagation trivial — `b` and `c` are just aliases. After elimination and constant folding, the function collapses to `ret i32 50`.

---
---

## 5. Dead Code Elimination (DCE)

### GCC
**Compile:** `gcc -O1 -o dce example.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int a = 5;
    int b = 20;      // computed but NEVER used
    int c = a + 10;
    printf("c = %d\n", c);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // b = 20 → REMOVED (dead, never used)
    // a=5 constant → c = 5+10 = 15, fully folded
    printf("c = %d\n", 15);
    return 0;
}
```

**Explanation:** `b = 20` is assigned but `b` is never read or used anywhere. GCC's liveness analysis marks it dead and removes the assignment. No store instruction for `b` appears in the compiled output.

---

### LLVM
**Compile:** `clang -O1 -S -emit-llvm -o dce.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int a = 5;
    int b = 20;      // never used — dead
    int c = a + 10;
    return c;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 15;   // a=5, c=15, b eliminated, folded to return 15
}
```

**Explanation:** `b` is dead — it contributes nothing to the return value. LLVM removes it. Since `a = 5` is constant, `c = 15` is folded. Final IR: `ret i32 15`.

---
---

## 6. Function Cloning

### GCC
**Compile:** `gcc -O3 -o func_clone example.c`

**Original Code:**
```c
#include <stdio.h>
int process(int value, int mode) {
    if (mode == 0) return value * 2;
    else           return value + 100;
}
int main() {
    int r1 = process(10, 0);
    int r2 = process(10, 1);
    printf("r1=%d, r2=%d\n", r1, r2);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // process() cloned for mode=0 → value*2=20, and mode=1 → value+100=110
    // Both clones inlined with constant args → values folded directly
    printf("r1=%d, r2=%d\n", 20, 110);
    return 0;
}
```

**Explanation:** Both call sites pass constant `mode` values (0 and 1). GCC creates specialized clones with the branch resolved at compile time. Each clone has only the relevant code path — no runtime `if` check needed.

---

### LLVM
**Compile:** `clang -O3 -S -emit-llvm -o func_clone.ll example_1_1.c`

**Original Code:**
```c
int process(int value, int mode) {
    if (mode == 0) return value * 2;
    else           return value + 100;
}
int main() {
    int r1 = process(10, 0);
    int r2 = process(10, 1);
    return r1 + r2;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 130;   // r1=20, r2=110, inlined + folded entirely
}
```

**Explanation:** LLVM inlines and specializes [process()](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/llvm/Function_Cloning/example_1_1.c#5-13) at each call site using constant arguments. With `mode` known at compile time, branches are eliminated. Constant folding then reduces `r1=20, r2=110, total=130` to a single return.

---
---

## 7. Function Inlining

### GCC
**Compile:** `gcc -O2 -o func_inline example.c`

**Original Code:**
```c
#include <stdio.h>
static inline int square(int x) {
    return x * x;
}
int main() {
    int a = 6;
    int result = square(a);   // function call
    printf("square(%d) = %d\n", a, result);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // square(6) inlined → 6*6 → folded to 36
    // No function call. No intermediate variable. Constants passed directly:
    printf("square(%d) = %d\n", 6, 36);
    return 0;
}
```

**Explanation:** [square()](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Function_Inlining/example.c#7-11) is tiny. GCC replaces the function call with the body directly: `result = a * a`. No stack push, no jump instruction. Further, since `a = 6`, `result = 36` is folded.

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o func_inline.ll example_1_1.c`

**Original Code:**
```c
static inline int square(int x) {
    return x * x;
}
int main() {
    int a = 6;
    int result = square(a);
    return result;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 36;   // square(6) inlined → 6*6=36 → folded
}
```

**Explanation:** LLVM inlines [square()](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Function_Inlining/example.c#7-11) at the call site, replacing it with `a * a`. Since `a = 6` is constant, `6 * 6 = 36` is folded. Final IR: `ret i32 36`.

---
---

## 8. Induction Variable Elimination

### GCC
**Compile:** `gcc -O2 -o iv_elim example.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int arr[10], n = 10;
    for (int i = 0; i < n; i++) {
        int j = i * 3;   // multiply every iteration
        arr[i] = j;
    }
    printf("arr[3] = %d\n", arr[3]);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    int arr[10];
    int j = 0;           // induction variable — replaces i*3
    for (int i = 0; i < 10; i++) {
        arr[i] = j;
        j += 3;          // ADD replaces MUL every iteration
    }
    // arr[3] = 9, constant known after loop
    printf("arr[3] = %d\n", 9);
    return 0;
}
```

**Explanation:** `j = i * 3` computes a multiply per iteration. Since `j` increases by 3 each step, GCC replaces it with an accumulator `j += 3`. 10 multiplications → 10 additions (3–5x faster).

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o iv_elim.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int arr[10], n = 10;
    for (int i = 0; i < n; i++) {
        int j = i * 3;
        arr[i] = j;
    }
    return arr[3];
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int arr[10];
    int j = 0;
    for (int i = 0; i < 10; i++) {
        arr[i] = j;
        j += 3;   // strength-reduced: add replaces multiply
    }
    return arr[3];   // returns 9
}
```

**Explanation:** LLVM's Scalar Evolution (SCEV) analysis detects `j = i * 3` as a linear induction variable and replaces the multiply with an increment. The loop now uses only additions.

---
---

## 9. Loop Fusion

### GCC
**Compile:** `gcc -O3 -o loop_fusion example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int a[5], b[5];
    for (int i = 0; i < 5; i++) { a[i] = i * 2; }   // loop 1
    for (int i = 0; i < 5; i++) { b[i] = a[i] + 1; } // loop 2
    printf("a[2]=%d, b[2]=%d\n", a[2], b[2]);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    int a[5], b[5];
    for (int i = 0; i < 5; i++) {   // TWO loops FUSED into ONE
        a[i] = i * 2;
        b[i] = a[i] + 1;            // a[i] used immediately — optimal cache
    }
    // a[2]=4, b[2]=5 known after loop
    printf("a[2]=%d, b[2]=%d\n", 4, 5);
    return 0;
}
```

**Explanation:** Both loops iterate over the same range `i = 0..4`. GCC merges them into one loop body. This halves the loop overhead (one counter, one branch) and improves cache efficiency since `a[i]` is immediately used after being written.

---

### LLVM
**Compile:** `clang -O3 -S -emit-llvm -o loop_fusion.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int a[5], b[5];
    for (int i = 0; i < 5; i++) { a[i] = i * 2; }
    for (int i = 0; i < 5; i++) { b[i] = a[i] + 1; }
    return b[2];
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int a[5], b[5];
    for (int i = 0; i < 5; i++) {   // fused
        a[i] = i * 2;
        b[i] = a[i] + 1;
    }
    return b[2];   // returns 5
}
```

**Explanation:** LLVM fuses the two loops into one. The second loop's body is merged into the first loop's body, reducing iteration overhead by half and improving data locality.

---
---

## 10. Loop Invariant Code Motion (LICM)

### GCC
**Compile:** `gcc -O2 -o licm example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int arr[100], factor = 7, scale = 3;
    for (int i = 0; i < 100; i++) {
        arr[i] = i + factor * scale;   // factor*scale computed 100 times!
    }
    printf("arr[10] = %d\n", arr[10]);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    int arr[100];
    int inv = 21;               // factor*scale=7*3=21, folded & hoisted BEFORE loop
    for (int i = 0; i < 100; i++) {
        arr[i] = i + inv;       // loop body: only ADD, no MUL
    }
    // arr[10] = 10+21 = 31, known at compile time
    printf("arr[10] = %d\n", 31);
    return 0;
}
```

**Explanation:** `factor * scale` never changes inside the loop (both are loop-invariant). GCC hoists it before the loop. 99 redundant multiplications are eliminated — only 1 happens before the loop starts.

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o licm.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int arr[100], factor = 7, scale = 3;
    for (int i = 0; i < 100; i++) {
        arr[i] = i + factor * scale;
    }
    return arr[10];
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int arr[100];
    int inv = 21;               // 7*3 folded and hoisted
    for (int i = 0; i < 100; i++) {
        arr[i] = i + inv;
    }
    return arr[10];   // returns 31
}
```

**Explanation:** LLVM's LICM pass detects `factor * scale` as invariant. It hoists the computation (and folds it to `21`) before the loop. The loop body now has only an addition — no multiply at runtime.

---
---

## 11. Loop Peeling

### GCC
**Compile:** `gcc -O3 -o loop_peel example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int arr[8] = {0};
    for (int i = 0; i < 8; i++) {
        if (i > 0)
            arr[i] = arr[i-1] + i;   // general case
        else
            arr[i] = 0;              // only at i=0
    }
    printf("arr[5] = %d\n", arr[5]);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    int arr[8] = {0};
    arr[0] = 0;                    // PEELED — i=0 runs before the loop
    for (int i = 1; i < 8; i++) { // loop starts at i=1, NO if-else inside
        arr[i] = arr[i-1] + i;
    }
    // arr[5]=15, known after execution
    printf("arr[5] = %d\n", 15);
    return 0;
}
```

**Explanation:** The `if (i > 0)` check is only `false` at `i = 0`. GCC peels this first iteration: `arr[0] = 0` runs before the loop. The loop then starts at `i = 1` with the conditional branch completely removed.

---

### LLVM
**Compile:** `clang -O3 -S -emit-llvm -o loop_peel.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int arr[8] = {0};
    for (int i = 0; i < 8; i++) {
        if (i > 0)
            arr[i] = arr[i-1] + i;
        else
            arr[i] = 0;
    }
    return arr[5];
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int arr[8] = {0};
    arr[0] = 0;                    // peeled iteration
    for (int i = 1; i < 8; i++) { // clean loop, no branch
        arr[i] = arr[i-1] + i;
    }
    return arr[5];   // returns 15
}
```

**Explanation:** LLVM peels the boundary iteration `i = 0`. The remaining loop `i = 1..7` runs without any conditional branch. Array: `[0,1,3,6,10,15,21,28]`. `arr[5] = 15`.

---
---

## 12. Strength Reduction

### GCC
**Compile:** `gcc -O2 -o strength_red example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int x = 9;
    int a = x * 8;   // multiply
    int b = x * 4;   // multiply
    printf("a=%d, b=%d\n", a, b);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    // x=9 (constant); strength reduction applied:
    // 9*8 → 9<<3 = 72;  9*4 → 9<<2 = 36 — then constant folded
    printf("a=%d, b=%d\n", 72, 36);
    return 0;
}
```

**Explanation:** `8 = 2³` so `x * 8 = x << 3`. `4 = 2²` so `x * 4 = x << 2`. A multiply instruction takes 3–5 CPU cycles; a shift takes 1 cycle. GCC automatically applies this for power-of-2 multipliers.

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o strength_red.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int x = 9;
    int a = x * 8;
    int b = x * 4;
    return a + b;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    return 108;   // x=9, 9<<3=72, 9<<2=36, 72+36=108, all folded
}
```

**Explanation:** LLVM first applies strength reduction (`mul` → `shl`), then constant propagation (`x = 9`) and folding. The entire function collapses to `ret i32 108`.

---
---

## 13. Strength Reduction in Loops

### GCC
**Compile:** `gcc -O2 -o sr_loops example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int main() {
    int arr[10];
    for (int i = 0; i < 10; i++) {
        arr[i] = i * 5;   // MUL every iteration
    }
    printf("arr[4]=%d, arr[9]=%d\n", arr[4], arr[9]);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int main() {
    int arr[10];
    int t = 0;          // accumulator — replaces i*5
    for (int i = 0; i < 10; i++) {
        arr[i] = t;
        t += 5;         // ADD replaces MUL every iteration
    }
    // arr[4]=20, arr[9]=45 — values known after loop
    printf("arr[4]=%d, arr[9]=%d\n", 20, 45);
    return 0;
}
```

**Explanation:** `i * 5` grows by 5 each iteration. GCC replaces the per-iteration multiply with a running sum `t += 5`. 10 multiplications become 10 additions. Array: `[0,5,10,15,20,25,30,35,40,45]`.

---

### LLVM
**Compile:** `clang -O2 -S -emit-llvm -o sr_loops.ll example_1_1.c`

**Original Code:**
```c
int main() {
    int arr[10];
    for (int i = 0; i < 10; i++) {
        arr[i] = i * 5;
    }
    return arr[4] + arr[9];
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int main() {
    int arr[10];
    int t = 0;
    for (int i = 0; i < 10; i++) {
        arr[i] = t;
        t += 5;   // accumulator, no multiply
    }
    return arr[4] + arr[9];   // 20 + 45 = 65
}
```

**Explanation:** LLVM's SCEV analysis replaces `i * 5` with an incrementing accumulator. The loop body now contains only an add and a store — no multiply. Returns `65`.

---
---

## 14. Unreachable Code Elimination

### GCC
**Compile:** `gcc -O1 -o unreachable example_1_1.c`

**Original Code:**
```c
#include <stdio.h>
int getValue() {
    return 42;
    printf("never prints\n");  // UNREACHABLE (after return)
    return -1;                 // UNREACHABLE
}
int main() {
    int x = 1;
    if (x > 0) {
        printf("x is positive\n");
    } else {
        printf("x is not positive\n"); // UNREACHABLE (x always = 1)
    }
    int v = getValue();
    printf("v = %d\n", v);
    return 0;
}
```

**Optimized Code (GCC internal equivalent):**
```c
#include <stdio.h>
int getValue() {
    return 42;   // unreachable printf + return -1 REMOVED
}
int main() {
    // x=1: condition x>0 always true → else block REMOVED
    printf("x is positive\n");
    // getValue() may be inlined → v = 42 constant
    printf("v = %d\n", 42);
    return 0;
}
```

**Explanation:** Two types of unreachable code removed: (1) code after `return 42` in [getValue()](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Unreachable_Code_Elimination/example_1_1.c#7-13) — can never execute; (2) the `else` block in [main](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Copy_Propagation/example.c#7-18) — `x = 1` is always `> 0`, so the `else` is never reachable. GCC removes both.

---

### LLVM
**Compile:** `clang -O1 -S -emit-llvm -o unreachable.ll example_1_1.c`

**Original Code:**
```c
int getValue() {
    return 42;
    return -1;   // unreachable
}
int main() {
    int x = 1;
    int result = 0;
    if (x > 0) { result = 1; }    // always taken
    else        { result = -1; }  // UNREACHABLE
    int v = getValue();
    return v + result;
}
```

**Optimized Code (LLVM internal equivalent):**
```c
int getValue() {
    return 42;   // second return removed
}
int main() {
    return 43;   // else eliminated, v=42, result=1, folded to 43
}
```

**Explanation:** LLVM removes post-return dead code in [getValue()](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Unreachable_Code_Elimination/example_1_1.c#7-13). It propagates `x = 1`, evaluates `x > 0` as always true, eliminates the else block. With `v = 42` and `result = 1`, the entire main collapses to `ret i32 43`.

---
---

## Quick Reference Summary

| # | Optimization | Original (slow) | Optimized (fast) |
|---|---|---|---|
| 1 | CSE | `y = a*b+c` twice | `y = x` (reuse) |
| 2 | Constant Folding | `a = 3+4` | `a = 7` at compile time |
| 3 | Constant Propagation | `y = x + 5` (x=10) | `y = 15` directly |
| 4 | Copy Propagation | `b=a; c=b; c+8` | `a + 8` directly |
| 5 | Dead Code Elimination | `b = 20;` (unused) | `b = 20` removed |
| 6 | Function Cloning | [process(v, mode)](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/llvm/Function_Cloning/example_1_1.c#5-13) with branch | Two branchless clones |
| 7 | Function Inlining | [square(a)](file:///c:/SEM-6/COMPILER-DESIGN/compiler_design/gcc/Function_Inlining/example.c#7-11) call | `a * a` at call site |
| 8 | Induction Variable Elim | `j = i * 3` per iter | `j += 3` per iter |
| 9 | Loop Fusion | 2 loops, 0 to N | 1 merged loop |
| 10 | LICM | `f*s` inside loop | `f*s` hoisted before loop |
| 11 | Loop Peeling | `if(i>0)` check per iter | i=0 peeled; clean loop |
| 12 | Strength Reduction | `x * 8` (mul) | `x << 3` (shift) |
| 13 | SR in Loops | `i * 5` per iter | `t += 5` per iter |
| 14 | Unreachable Code | Dead branches kept | Dead branches removed |

---
*Compiler Design — SEM 6 | GCC + LLVM Optimization Examples*
