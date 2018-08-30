/*=================================================================
 *
 *ESCALARES (int): maxiter, npart, nclass, stopmax
 *ESCALARES (double): pgrd, dexp, deltav, deltap
 *
 *VETORES: partpos, partclass, potpart, slabel, nsize
 *
 *MATRIZES: distnode, pot, nlist
 *
 *RETORNO: pot
 *=================================================================*/
#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	maxiter_IN      prhs[0]
#define	npart_IN        prhs[1]
#define	nclass_IN       prhs[2]
#define	stopmax_IN      prhs[3]
#define partnode_IN     prhs[4]
#define slabel_IN       prhs[5]
#define nsize_IN        prhs[6]
#define nlist_IN        prhs[7]
#define pot_IN          prhs[8]

/* Output Arguments */

#define	pot_OUT     	plhs[0]

static void strwalk23loop(
            int maxiter, 
            int npart, 
            int nclass, 
            int stopmax,
            double partnode[],
            double slabel[],
            double nsize[],
            double nlist[],
            double pot[],
            int qtnode,
            int neibmax
		   )
{
    // non-Windows users should probably use /dev/random or /dev/urandom instead of rand_s
    //unsigned int seed;
    //errno_t err;
    //err = rand_s(&seed);
    //if (err != 0) printf_s("The rand_s function failed!\n");
    //srand(seed);
    double maxmmpot = 0;
    int stopcnt = 0;
    double *prob = malloc(sizeof(double)*neibmax); // vetor de probabilidades de visitar vizinho    
    double *nc = malloc(sizeof(double)*nclass);
    double *newpot = malloc(sizeof(double)*qtnode*nclass);
    for(int i=0; i<qtnode*nclass; i++) newpot[i]=pot[i];
    for(int i=0; i<maxiter; i++)
    {
        for(int j=0; j<npart; j++)
        {
            //for(int i2=0; i2< (int) nsize[(int) partnode[j]-1]; i2++) prob[i2] = 1;
            //double probsum = nsize[(int) partnode[j]-1];
            
            // vamos encontrar o nó sorteado
            //double r = ((double) rand()) * probsum / RAND_MAX;
            //int k=0;
            //while(prob[k]<=r && k < nsize[(int) partnode[j]-1]-1)
            //{
            //    r -= prob[k];
            //    k++;
            //}
            // convertendo o índice de probabilidade sorteado no índice do nó sorteado
            //k = (int) nlist[(int) (k*qtnode + partnode[j]-1)];
            
            for(int i2=0; i2<nclass; i2++) nc[i2]=0;
            
            for(int i2=0; i2<nsize[(int) partnode[j]-1]; i2++)
                for(int i3=0; i3<nclass; i3++)
                    nc[i3] = nc[i3] + pot[(int) (i3*qtnode + nlist[(int) (i2*qtnode + partnode[j]-1)]-1)];
                        
            for(int i2=0; i2<nclass; i2++)
                newpot[(int) (i2*qtnode + partnode[j]-1)] = nc[i2] / nsize[(int) partnode[j]-1];
            // vamos testar convergência
        }
            
        for(int i=0; i<qtnode*nclass; i++) pot[i]=newpot[i];
        
        if (i % 10 == 0)
        {
            double mmpot = 0;
            for(int i2=0; i2<qtnode; i2++)
            {
                double mpot=0;
                for(int i3=0; i3<nclass; i3++)
                    if(pot[i3*qtnode + i2]>mpot) mpot = pot[i3*qtnode + i2];
                mmpot += mpot;
            }
            mmpot /= qtnode;
            /*
            if (i % 1000 == 0)
            {
                printf("Iter: %i  Meanpot: %0.4f\n",i,mmpot);
                mexEvalString("drawnow");
            }
             **/
            if (mmpot > maxmmpot)
            {
                maxmmpot = mmpot;
                stopcnt = 0;
            }
            else
            {
                stopcnt++;
                if (stopcnt > stopmax) break;
            }
        }
    }
    free(prob);
    return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
   
    int maxiter, npart, nclass, stopmax; // escalares int
    double *partnode, *slabel, *nsize;  // vetores de int
    double *nlist; // matrizes de int
    double *pot;  // matrizes de double
    int qtnode, neibmax;
    
    /* Check for proper number of arguments */
    
    
    if (nrhs != 9) { 
	    mexErrMsgTxt("9 argumentos de entrada requeridos."); 
    } else if (nlhs > 1) {
	    mexErrMsgTxt("Muitos argumentos de saída."); 
    }
    
    maxiter = (int) mxGetScalar(maxiter_IN);
    npart = (int) mxGetScalar(npart_IN);
    nclass = (int) mxGetScalar(nclass_IN);
    stopmax = (int) mxGetScalar(stopmax_IN);
    partnode = mxGetPr(partnode_IN);
    slabel = mxGetPr(slabel_IN);
    nsize = mxGetPr(nsize_IN);
    nlist = mxGetPr(nlist_IN);    
    pot = mxGetPr(pot_IN);
    
    qtnode = (int) mxGetM(slabel_IN);
    neibmax = (int) mxGetN(nlist_IN);  // quantidade máxima de vizinhos que um nó tem   
    
    /* Create a matrix for the return argument */ 
    pot_OUT = pot_IN;
        
    strwalk23loop(maxiter,npart,nclass,stopmax,partnode,slabel,nsize,nlist,pot,qtnode,neibmax);
    
    return;
    
}
