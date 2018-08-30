/*=================================================================
 *
 *ESCALARES (int): maxiter, nnonlabeled, stopmax
 *
 *VETORES: knns
 *
 *MATRIZES: potval, nlist
 *
 *RETORNO: potval
 *=================================================================*/
#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	maxiter_IN       prhs[0]
#define	nnonlabeled_IN   prhs[1]
#define indnonlabeled_IN prhs[2]
#define	stopmax_IN       prhs[3]
#define	potval_IN        prhs[4]
#define	k_IN             prhs[5]
#define	nlist_IN         prhs[6]
#define ndist_IN         prhs[7]

/* Output Arguments */

#define	potval_OUT     	 plhs[0]

static void cnsslisloop(
            int maxiter, 
            int nnonlabeled, 
            unsigned int indnonlabeled[],
            int stopmax,            
            double potval[],
            unsigned short int k,
            unsigned int nlist[],
            int qtnode,
            double ndist[]
		   )
{
    double maxmmpot = 0;
    int stopcnt = 0;    
    double *newpot = malloc(sizeof(double)*nnonlabeled*2);
    for(int i=0; i<maxiter; i++)
    {
        for(int j=0; j<nnonlabeled; j++)
        {            
            // inicialmente potenciais novos são zerados
            newpot[j] = 0;
            newpot[j + nnonlabeled] = 0;
            // peso acumulado de todos os vizinhos
            double accweight=0;
            // para cada vizinho do nó não rotulado
            for(int ki=0; ki<k; ki++)
            {           
                // vamos pegar um vizinho
                int neib = nlist[j + ki*nnonlabeled]-1;
                // vamos somar os potenciais dos vizinhos no novo potencial do nosso nó não rotulado
                // lembrar que em C acessa-se matriz por [LINHA + COLUNA * QTDE DE LINHAS]
                newpot[j] += potval[neib] * ndist[j + ki*nnonlabeled];
                newpot[j + nnonlabeled] += potval[neib + qtnode] * ndist[j + ki*nnonlabeled];
                accweight += ndist[j + ki*nnonlabeled];
            }
            // dividindo os potenciais acumulados pela quantidade de vizinhos, para obter a média
            newpot[j] /= accweight;
            newpot[j + nnonlabeled] /= accweight;
        }
        
        // colocar os novos potenciais na lista de potenciais
        for(int j=0; j<nnonlabeled; j++) 
        {
            int ppj = indnonlabeled[j]-1;
            potval[ppj] = newpot[j];
            potval[ppj + qtnode] = newpot[j + nnonlabeled];
        }
        
        // vamos testar convergência                 
        if (i % 10 == 0)
        {
            // variável para guardar a média de maior potencial
            double mmpot = 0;
            // para cada nó não rotulado
            for(int j=0; j<nnonlabeled; j++)
            {
                // vamos pegar o nó
                int ppj = indnonlabeled[j]-1;
                // se o primeiro potencial é maior, soma ele
                if(potval[ppj]>potval[ppj+qtnode]) mmpot += potval[ppj];
                // senão soma o segundo
                else mmpot += potval[ppj+qtnode];
            }
            // divide-se o potencial acumulado pela qtde de nós não rotulados, obtendo a média
            mmpot /= nnonlabeled;
            //printf("Iter: %i  Meanpot: %0.4f\n",i,mmpot);            
            // se da última maior média para a atual aumentou mais que 0.001
            if (mmpot - maxmmpot > 0.001)
            {                
                // vamos atualizar maior média
                maxmmpot = mmpot;
                // e zerar o contador
                stopcnt = 0;
            }               
            else
            {
                // incrementa o contador
                stopcnt++;
                // se chegou no limite, para
                if (stopcnt > stopmax) break;
            }
        }      
    }  
    
    free(newpot);
    return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{    
    int maxiter, nnonlabeled, stopmax; // escalares int
    unsigned short int k; // escalar de uint16       
    unsigned int *indnonlabeled, *nlist; // vetores de uint32
    double *potval, *ndist;  // matrizes de double
    int qtnode, neibmax;
    
    /* Check for proper number of arguments */
    
    
    if (nrhs != 8) { 
	    mexErrMsgTxt("8 argumentos de entrada requeridos."); 
    } else if (nlhs > 1) {
	    mexErrMsgTxt("Muitos argumentos de saída."); 
    }
    
    maxiter = (int) mxGetScalar(maxiter_IN);
    nnonlabeled = (int) mxGetScalar(nnonlabeled_IN);
    indnonlabeled = (unsigned int *) mxGetData(indnonlabeled_IN);
    stopmax = (int) mxGetScalar(stopmax_IN);   
    k = (unsigned short int) mxGetScalar(k_IN);                
    nlist = (unsigned int *) mxGetData(nlist_IN);    
    potval = mxGetPr(potval_IN);
    ndist = mxGetPr(ndist_IN);
    
    qtnode = (int) mxGetM(potval_IN);    
       
    /* Create a matrix for the return argument */ 
    potval_OUT = mxCreateSharedDataCopy(potval_IN);    
        
    cnsslisloop(maxiter,nnonlabeled,indnonlabeled,stopmax,potval,k,nlist,qtnode,ndist);
    
    return;
    
}
