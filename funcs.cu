#include "gpusort.h"

int max(int a, int b) {
    return a > b ? a : b;
}

int min(int a, int b) {
    return a < b ? a : b;
}

__global__ void
GQSORT1(param *dparams, int *darray1, int *darray2, list *dplist, bool flip) {
	__shared__ int lt[blockDim.x], gt[blockDim.x], minpiv[blockDim.x], maxpiv[blockDim.x];
	int lt, gt, d;
	int pivot = dparams[blockIdx.x].pivot;
	int* darray = flip ? darray1 : darray2; 
    minpiv[threadIdx.x] = darray[dparams[blockIdx.x].start + threadIdx.x];
    maxpiv[threadIdx.x] = darray[dparams[blockIdx.x].start + threadIdx.x];
	for (int i = dparams[blockIdx.x].start + threadIdx.x;
	     i < dparams[blockIdx.x].end; i += blockDim.x) {
        d = darray[i];
		if (d < pivot) lt++;
		if (d > pivot) gt++;
        minpiv[threadIdx.x] = min(minpiv[threadIdx.x], d);
        maxpiv[threadIdx.x] = max(maxpiv[threadIdx.x], d);
	}
	lt[threadIdx.x] = lt;
	gt[threadIdx.x] = gt;
	__syncthreads();
	int lsum = 0, gsum = 0;
    //lt, gt store the end of every thread
	if (threadIdx.x == 0) {
		for (int i = 1; i < blockDim.x; i++) {
			/*lsum += lt[i];
			gsum += gt[i];
			lt[i] = lsum;
			gt[i] = gsum;*/
            lt[i] += lt[i-1];
            gt[i] += gt[i-1];
            minpiv[0] = min(minpiv[0], minpiv[i]);
            maxpiv[0] = max(maxpiv[0], maxpiv[i]);
		}
	}
	__syncthreads();
	dplist->left[threadIdx.x + blockIdx.x * blockDim.x] = lt[threadIdx.x];
	dplist->right[threadIdx.x + blockIdx.x * blockDim.x] = gt[threadIdx.x];
	dplist->blockleft[blockIdx.x] = lt[blockDim.x-1];
	dplist->blockright[blockIdx.x] = gt[blockDim.x-1];
    dplist->blockmin[blockIdx.x] = minpiv[0];
    dplist->blockmax[blockIdx.x] = maxpiv[0];
}

__global__ void
GQSORT2(param *dparams, int *darray1, int *darray2, list *dplist, bool flip) {
    // move the other elements to correct positions
	int* darray = flip ? darray1 : darray2;
	int* darray2 = flip ? darray2 : darray1;
	int lfrom, gfrom;
	lfrom = plist.blockleft[blockIdx.x] + plist.left[threadIdx.x + blockIdx.x * blockDim.x] - 1;
	gfrom = plist.blockright[blockIdx.x] - plist.right[threadIdx.x + blockIdx.x * blockDim.x];
	int i = dparams[blockIdx.x].start + threadIdx.x;
	for (; i < dparams[blockIdx.x].end; i += blockDim.x) {
		if (darray[i] < dparams[blockIdx.x].pivot) 
			darray2[lfrom--] = darray[i];
		if (darray[i] > dparams[blockIdx.x].pivot)
			darray2[gfrom++] = darray[i];
	}

    // fill the pivot
    if(dparams[blockIdx.x].last) {
        int pivot = dparams[blockIdx.x].pivot;
        lfrom = plist.blockleft[blockIdx.x] + plist.left[blockIdx.x * blockDim.x + blockDim.x - 1] + threadIdx.x;
        gfrom = plist.blockright[blockIdx.x] - plist.right[blockIdx.x * blockDim.x + blockDim.x - 1];
        while( lfrom < gfrom) {
            darray2[lfrom] = pivot;
        }
    }

	// return two sequence
    /*if(dparams[blockIdx.x].last) {
        int par = dparams[blockIdx.x].parent;
        dparams[par * 2].begin = 
    }*/
}

