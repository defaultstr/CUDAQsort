#include "gpusort.h"
#include "funcs.cu"

void Init() {
}

void GPUSORT(int size, int *array, int *darray1, int *darray2) {
    bool flip = false;
    int worksize = 1, downsize = 0, paramsize = 0, totsize = size;
    int pivot = workset[0].pivot = (prim_array[0] + prim_array[size/2] + prim_array[size-1])/3;

    while(worksize > 0 && worksize + downsize < MAXSEQ) {
        int blocksize = totsize / MAXSEQ;
        for(int i = 0; i < worksize; i ++) {
            int blockcount = (totsize + blocksize)/blocksize;
            int parent = i, bstart;
            for(int j = 0; j < blockcount; j ++) {
                bstart = workset[i].start + j * blocksize;
                params[paramsize].begin = bstart;
                params[paramsize].end = bstart + blocksize;
                params[paramsize].pivot = pivot;
                params[paramsize].parent = i;
                params[paramsize].last = false;
                paramsize ++;
            }
            params[paramsize-1].end = workset[i].end;
            params[paramsize-1].last = true;
        }
        cudaMemcpy(dparams, params, paramsize * sizeof(param), cudaMemcpyHostToDevice);
        paramsize = GQSORT<<< TODO >>>(dparams, TODO); 
        cudaMemcpy(params, dparams, paramsize * sizeof(param), cudaMemcpyDeviceToHost);
        totsize = worksize = 0;
        sequence *temp;
        for(int i = 0; i < paramsize; i ++) {
            if(params[i].begin - params[i].end < size/MAXSEQ) {
                temp = doneset;
                donesize ++;
            } else {
                temp = workset;
                worksize ++;
                totsize += params[i].begin - params[i].end;
            }
            temp[i].begin = params[i].begin;
            temp[i].end = params[i].end;
            temp[i].pivot = params[i].pivot;
        }
    }
    int lqparamsize = 0;
    for(int i = 0; i < worksize; i ++) {
        lqparams[lqparamsize].begin = workset[i].begin;
        lqparams[lqparamsize].end = workset[i].end;
        lqparams[lqparamsize].flip = workset[i].flip;
        lqparams[lqparamsize].sbsize = sbsize;
    }
    cudaMemcpy(dlqparams, lqparams, lqparamsize * sizeof(lqparam), cudaMemcpyHostToDevice);
    LQSORT<<< TODO >>>(dlqparams, TODO);
    cudaMemcpy(lqparams, dlqparams, lqparamsize * sizeof(lqparam), cudaMemcpyDeviceToHost);
}
