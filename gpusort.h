#ifndef GPUSORT_H
#define GPUSORT_H

struct sequence {
    int begin;
    int end;
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

sequence *workset;
sequence *doneset;
param *params;
param *dparams;

#endif
