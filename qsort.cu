#define LENGTH 100000
#define MAX 1000000
#define MAXSEQ 10

void generateRandomArray(long *a, int l) {
    int i;
    srand((unsigned)time(NULL));
    for(i = 0; i < l; i ++)
        a[i] = rand()%MAX + 1;
}

void GPUQSORT(int size, long *prim_array, long *auxi_array) {
    long startpivot = (prim_array[0], prim_array[size/2], prim_array[size-1])/3;
    struct seq_piv
}

//Device Code
__device__ void QuickSortPhase1(long *prim_array, long *auxi_array, int size) {
    //blockDim.x,y,z threadIdx.x,y,z threadIdx.x,y,z
}
__device__ void QuickSortPhase2(long *prim_array, long *auxi_array, int size) {
    //blockDim.x,y,z threadIdx.x,y,z threadIdx.x,y,z
}

int main(int argc, char **argv) {
    size_t size = LENGTH * sizeof(long);
    long host_Array[LENGTH];
    generateRandomArray(host_Array, l);

    long *device_prim_Array;
    long *device_auxi_Array;
    cudaMalloc((void**)&device_prim_Array, size);
    cudaMalloc((void**)&device_auxi_Array, size);
    cudaMemcpy(device_prim_Array, host_Array, size, cudaMemcpyHostToDevice);
    //TODO
    int threadsPerBlock = 256;
    int blocksPerGrid = 111;

    cudaMemcpy(host_Array, device_prim_Array, size, cudaMemcpyDeviceToHost);
    cudaFree(device_prim_Array);
    cudaFree(device_auxi_Array);
}
