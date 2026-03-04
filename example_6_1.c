void example1(int *arr, int n) { 

    for (int i = 1; i < n; i++) { 

        arr[i] = arr[i] + arr[i - 1]; 

    } 

} 
