#include "gpusort.h"
#include "funcs.cu"

int median(int a, int b, int c) {
    if(a < b) {
        if(b < c) return b;
        else if(a < c) return c;
        else return a;
    } else {
        if(c > a) return a;
        else if(c > b) return c;
        else return b;
    }
}

int Init() {    
    if(cudaMallocHost((void **)&workset, MAXBLOCKS*sizeof(sequence)) != cudaSuccess) return -1;
    if(cudaMallocHost((void **)&doneset, MAXBLOCKS*sizeof(sequence)) != cudaSuccess) return -2;
    if(cudaMallocHost((void **)&params, MAXBLOCKS*sizeof(param)) != cudaSuccess) return -3;
    if(cudaMallocHost((void **)&plist, sizeof(list)) != cudaSuccess) return -4;
    if(cudaMalloc((void **)&dparams, MAXBLOCKS*sizeof(param)) != cudaSuccess) return -5;
    if(cudaMalloc((void **)&dplist, sizeof(list)) != cudaSuccess) return -6;
    return 0;
}

void GPUSORT(int size, int *array, int *darray1, int *darray2) {
    bool flip = true;
    int worksize = 1, donesize = 0, paramsize = 0, totsize = size;
    int pivot = workset[0].pivot = median(darray1[0], darray1[size/2], darray1[size-1]), index;

    while(worksize > 0 && worksize + donesize < MAXSEQ) {
        int blocksize = totsize / MAXSEQ;
        for(int i = 0; i < worksize; i ++) {
            if(workset[i].end - workset[i].begin < size/MAXSEQ) continue;
            int blockcount = (totsize + blocksize)/blocksize;
            int parent = i, bstart;
            for(int j = 0; j < blockcount; j ++) {
                bstart = workset[i].start + j * blocksize;
                params[paramsize].begin = bstart;
                params[paramsize].end = bstart + blocksize;
                params[paramsize].pivot = workset[i].pivot;
                params[paramsize].parent = i;
                params[paramsize].last = false;
                paramsize ++;
            }
            params[paramsize-1].end = workset[i].end;
            params[paramsize-1].last = true;
        }
        cudaMemcpy(dparams, params, paramsize * sizeof(param), cudaMemcpyHostToDevice);
        GQSORT1<<< TODO >>>(dparams, TODO); 
        cudaMemcpy(plist, dplist, sizeof(list), cudaMemcpyDeviceToHost);
		for(int i = 0; i < paramsize; i ++) {
			int l = plist->blockleft[i];
			int r = plist->blockright[i];
			plist->blockleft[i] = workset[params[i].parent].begin;
			plist->blockright[i] = workset[parms[i].parent].end;
			workset[params[i].parent].begin += l;
			workset[params[i].parent].end -= r;
            workset[params[i].parent].maxrpiv = max(workset[params[i].parent].maxrpiv, plist->blockmax[i]);
            workset[params[i].parent].minlpiv = min(workset[params[i].parent].minlpiv, plist->blockmin[i]);
            workset[params[i].parent].maxlpiv = min(workset[params[i].parent].maxlpiv, workset[params[i].parent].pivot);
            workset[params[i].parent].minrpiv = max(workset[params[i].parent].minrpiv, workset[params[i].parent].pivot);
		}
        GQSORT2<<< TODO >>>(dparams, TODO); 
        flip = !flip;
        int oldworksize = worksize, *darray = flip ? darray1 : darray2, b, e;
        totsize = 0, paramsize =0, worksize = 0;
        for(int i = 0; i < oldworksize; i ++) {
            if(workset[i].begin - workset[i].orgbegin < size/MAXSEQ) {
                b = doneset[donesize].begin = workset[i].orgbegin;
                e = doneset[donesize].end = workset[i].begin;
                doneset[donesize].pivot = (workset[i].maxlpiv + workset[i].minlpiv)/2;
                doneset[donesize].flip = flip;
                donesize ++;
            } else {
                totsize += workset[i].begin - workset[i].orgbegin;
                b = params[worksize].begin = workset[i].begin;
                e = params[worksize].end = workset[i].end;
                params[worksize].pivot = (workset[i].maxlpiv + workset[i].minpiv)/2;
                worksize ++;
            }
            if(workset[i].orgend - workset[i].end < size/MAXSEQ) {
                b = doneset[donesize].begin = workset[i].end;
                e = doneset[donesize].end = workset[i].orgend;
                doneset[donesize].pivot = (workset[i].maxlpiv + workset[i].minlpiv)/2;
                doneset[donesize].flip = flip;
                donesize ++;
            } else {
                totsize += workset[i].end - workset[i].orgend;
                b = params[worksize].begin = workset[i].end;
                e = params[worksize].end = workset[i].orgend;
                params[worksize].pivot = (workset[i].maxlpiv + workset[i].minpiv)/2;
                worksize ++;
            }
        }
        for(int i = 0; i < worksize; i ++) {
            workset[i].orgbegin = workset[i].begin = params[i].begin;
            workset[i].orgend = workset[i].end = params[i].begin;
            workset[i].pivot = params[i].pivot;
            workset[i].flip = flip;
        }
    }
    int lqparamsize = 0;
    for(int i = 0; i < worksize; i ++) {
        lqparams[lqparamsize].begin = workset[i].begin;
        lqparams[lqparamsize].end = workset[i].end;
        lqparams[lqparamsize].flip = workset[i].flip;
        lqparams[lqparamsize].sbsize = sbsize;
        lqparamsize ++;
    }
    for(int i = 0; i < donesize; i ++) {
        lqparams[lqparamsize].begin = doneset[i].begin;
        lqparams[lqparamsize].end = doneset[i].end;
        lqparams[lqparamsize].flip = doneset[i].flip;
        lqparams[lqparamsize].sbsize = sbsize;
        lqparamsize ++;
    }
    cudaMemcpy(dlqparams, lqparams, lqparamsize * sizeof(lqparam), cudaMemcpyHostToDevice);
    LQSORT<<< TODO >>>(dlqparams, TODO);
    cudaMemcpy(lqparams, dlqparams, lqparamsize * sizeof(lqparam), cudaMemcpyDeviceToHost);
}

void Destroy() {    
    cudaFreeHost(workset);
    cudaFreeHost(doneset);
    cudaFreeHost(params);
    cudaFree(dparams);
    cudaFree(dplist);
}
