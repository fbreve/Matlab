#include "mex.h"
/* Output Arguments */
static void b(double c[])
{
    c[0]=0;
    return;
}


void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )   
{ 
    double *a;
    a = mxGetPr(prhs[0]);
    b(a);
    return;   
}
