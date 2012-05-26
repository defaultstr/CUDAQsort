#include "gpusort.h"

__global__ void
GQSORT1(param *dparams, int *darray1, int *darray2, plist *dplist, bool flip) {
	__shared__ int lt[blockDim.x], gt[blockDim.x];
	int lt, gt;
	int pivot = dparams[blockIdx.x].pivot;
	int* darray = flip ? darray1 : darray2;
	for (int i = dparams[blockIdx.x].start + threadIdx.x;
	     i < dparams[blockIdx.x].end; i += blockDim.x) {
		if (darray[i] < pivot) lt++;
		if (darray[i] >= pivot) gt++;
	}
	lt[threadIdx.x] = lt;
	gt[threadIdx.x] = gt;
	__syncthreads();
	int lsum = 0, gsum = 0;
	if (threadIdx.x == 0) {
		for (int i = 1; i < blockDim.x; i++) {
			lsum += lt[i];
			gsum += gt[i];
			lt[i] = lsum - lt[i];
			gt[i] = gsum - gt[i];
		}
	}
	__syncthreads();
	dplist->left[threadIdx.x + blockIdx.x * blockDim.x] = lt[threadIdx.x];
	dplist->right[threadIdx.x + blockIdx.x * blockDim.x] = gt[threadIdx.x];
	dplist->blockleft[blockIdx.x] = lsum;
	dplist->blockright[blockIdx.x] = gsum;
}

__global__ void
GQSORT2(param *dparams, int *darray1, int *darray2, plist *dplist, bool flip) {
	int* darray = flip ? darray1 : darray2;
	int* darray2 = flip ? darray2 : darray1;
	int lfrom, gfrom;
	lfrom = plist.blockleft[blockIdx.x] + plist.left[threadIdx.x + blockIdx.x * blockDim.x];
	gfrom = plist.blockright[blockIdx.x] - plist.right[threadIdx.x + blockIdx.x * blockDim.x];
	int i = dparams[blockIdx.x].start + threadIdx.x;
	for (; i < dparams[blockIdx.x].end; i += blockDim.x) {
		if (darray[i] < dparams[blockIdx.x].pivot) 
			darray2[lfrom++] = darray[i];
		if (darray[i] >= dparams[blockIdx.x].pivot)
			darray2[gfrom--] = darray[i];
	}
	
	//PART III?

}

