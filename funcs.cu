#include "gpusort.h"

/* parameters */
/* dparams : the blocks
darray1 : the first array1
darray2 : the first array2
flip : if true, use darray1, else use darray2 */
__global__ void
GQSORT(param *dparams, int *darray1, int *darray2, bool flip) {
}

/* parameters */
/* dparams : the blocks
darray1 : the first array1
darray2 : the first array2
flip : if true, use darray1, else use darray2 */
__global__ void
LQSORT(param *dlqparams, int *darray1, int *drray2, bool flip) {
}
