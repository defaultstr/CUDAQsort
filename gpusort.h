#ifndef GPUSORT_H
#define GPUSORT_H

struct sequence {
    int begin;
    int orgbegin;
    int end;
    int orgend;
    int maxlpiv;
    int minlpiv;
    int maxrpiv;
    int minrpiv;
    int pivot;
    bool flip;
};

struct param {
    int begin;
    int end;
    int pivot;
    int parent;
    bool last;
};

struct lqparam {
    int begin;
    int end;
    bool flip;
    int sbsize;
}

struct list {
	int left[MAXTHREADS * MAXBLOCKS];
	int right[MAXTHREADS * MAXBLOCKS];
	int blockleft[MAXBLOCKS];
	int blockright[MAXBLOCKS];
    int blockmax[MAXBLOCKS];
    int blockmin[MAXBLOCKS];
}

sequence *workset;
sequence *doneset;
param *params;
param *dparams;
list *plist;
list *dplist;

int Init();
void GPUSORT(int size, int *array, int *darray1, int *darray2);
void Destroy();

#endif
