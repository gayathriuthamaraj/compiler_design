#include <stdio.h>

void example1(int n) {
    int j = 0;
    for (int i = 0; i < n; i++) {
        printf("%d\n", j);
        j = j + 2;
    }
}
