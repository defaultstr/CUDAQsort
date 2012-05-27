#include "gpusort.h"
#define LENGTH 100000
#define MAX 1000000
#define MAXSEQ 10

void generateRandomArray(int *a, int l) {
    int i;
    srand((unsigned)time(NULL));
    for(i = 0; i < l; i ++)
        a[i] = rand()%MAX + 1;
}

int main(int argc, char **argv) {
    size_t size = LENGTH * sizeof(int);
    int host_Array[LENGTH];
    generateRandomArray(host_Array, l);

    int *device_prim_Array;
    int *device_auxi_Array;
    cudaMalloc((void**)&device_prim_Array, size);
    cudaMalloc((void**)&device_auxi_Array, size);
    cudaMemcpy(device_prim_Array, host_Array, size, cudaMemcpyHostToDevice);

    Init();
    GPUSORT(host_Array, LENGTH, device_prim_Array, device_auxi_Array);
    Destroy();

    cudaMemcpy(host_Array, device_prim_Array, size, cudaMemcpyDeviceToHost);
    cudaFree(device_prim_Array);
    cudaFree(device_auxi_Array);
}
