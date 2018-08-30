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
#include <float.h>
#include "mex.h"

/* Input Arguments */

#define	maxiter_IN      prhs[0]
#define	npart_IN        prhs[1]
#define	nclass_IN       prhs[2]
#define	stopmax_IN      prhs[3]
#define	pgrd_IN         prhs[4]
#define	dexp_IN         prhs[5]
#define	deltav_IN       prhs[6]
#define	deltap_IN       prhs[7]
#define potmin_IN       prhs[8]
#define partpos_IN      prhs[9]
#define partclass_IN 	prhs[10]
#define potpart_IN      prhs[11]
#define slabel_IN       prhs[12]
#define nsize_IN        prhs[13]
#define distnode_IN     prhs[14]
#define nlist_IN        prhs[15]
#define ndist_IN        prhs[16]
#define pot_IN          prhs[17]


/* Output Arguments */

#define	pot_OUT     	plhs[0]

static void strwalk22loop(
            int maxiter, 
            int npart, 
            int nclass, 
            int stopmax,
            double pgrd,
            double dexp,
            double deltav,
            double deltap,
            double potmin,
            double partpos[],
            double partclass[],
            double potpart[],
            double slabel[],
            double nsize[],
            double distnode[],
            double nlist[],
            double ndist[],
            double pot[],
            int qtnode,
            int neibmax
            //double	yp[],
		   //double	*t,
 		   //double	y[]
		   )
{
    // non-Windows users should probably use /dev/random or /dev/urandom instead of rand_s
    unsigned int seed;
    errno_t err;
    err = rand_s(&seed);
    if (err != 0) printf_s("The rand_s function failed!\n");
    srand(seed);
    double maxmmpot = 0;
    int stopcnt = 0;
    double *prob = malloc(sizeof(double)*neibmax); // vetor de probabilidades de visitar vizinho    
    for(int i=0; i<maxiter; i++)
    {
        for(int j=0; j<npart; j++)
        {
            double r = ((double) rand()) / RAND_MAX;
            double probsum = 0;
            int greedymov;
            //printf("%0.4f\n",r);            
            if (r < pgrd) // movimento guloso
            {
                greedymov=1;
                //printf("movimento guloso\n");                
                for(int i2=0; i2< (int) nsize[(int) partpos[j]-1]; i2++)
                {
                    prob[i2] = DBL_MIN + 
                            pot[(int) ((partclass[j]-1)*qtnode + nlist[(int)(qtnode * i2 + partpos[j]-1)]-1)] * 
                            (1 / pow(1+distnode[(int) (j * qtnode + nlist[(int)(qtnode * i2 + partpos[j]-1)]-1)],dexp)) *
                            (1 - ndist[(int) (qtnode * i2 + partpos[j]-1)]);
                    probsum += prob[i2];
                    //printf("%0.10f\n",prob[i2]);
                }               
            }
            else // movimento aleat�rio        
            {
                greedymov=0;
                //printf("movimento aleat�rio\n");                
                for(int i2=0; i2< (int) nsize[(int) partpos[j]-1]; i2++) 
                {
                    prob[i2] = (1 - ndist[(int) (qtnode * i2 + partpos[j]-1)]);
                    probsum += prob[i2];
                }
            }
            // vamos encontrar o n� sorteado
            r = ((double) rand()) * probsum / RAND_MAX;
            //printf("ProbSum: %0.4f\n",probsum);           
            //printf("r:       %0.4f\n",r);
            //printf("%0.4f  %0.4f  %i  %i   %i\n", probsum,r,(int) nsize[(int) partpos[j]-1],(int) partpos[j]-1,j);
            int nt=0;
            while(prob[nt]<=r && nt < nsize[(int) partpos[j]-1]-1)
            {
                r -= prob[nt];
                nt++;
            }            
            
            //printf("K Sorteado: %i de %i\n",k,(int) nsize[(int) partpos[j]-1]);
            // convertendo o �ndice de probabilidade sorteado no �ndice do n� sorteado
            int k = (int) nlist[(int) (nt*qtnode + partpos[j]-1)];
            //printf("Vizinho sorteado: %i\n",k);
                        
            // se o n� n�o � rotulado vamos ajustar os potenciais
            if (slabel[k-1]==0)
            {
                // valor a ser retirado de cada potencial de outras classes
                double deltapotpartind = potpart[j] * (deltav/(nclass-1));
                // valor total a ser acrescentado no potencial da classe da part�cula
                double deltapotpart = potpart[j] * deltav;
                for(int i2=0; i2<nclass; i2++)
                {                                        
                    if (i2==partclass[j]-1) continue; // n�o fazer para a classe da part�cula
                    pot[(int) (i2*qtnode + k-1)] -= deltapotpartind;                        
                    // se o potencial ficou abaixo de zero
                    if(pot[(int) (i2*qtnode + k-1)]<0)
                    {
                        // tira o que passou abaixo de zero do deltapotpart
                        deltapotpart += pot[(int) (i2*qtnode + k-1)];
                        // e zera o potencial que estava abaixo de zero
                        pot[(int) (i2*qtnode + k-1)] = 0;
                    }                    
                }
                // agora acrescenta o deltapotpart no potencial da classe da part�cula
                pot[(int) ((partclass[j]-1) * qtnode + k-1)] += deltapotpart;
            }                              
           
            // atribui novo potencial para part�cula
            potpart[j] += (pot[(int) ((partclass[j]-1) * qtnode + k-1)] - potpart[j]) * deltap;
            //printf("%0.4f\n",potpart[j]);
            
            // se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
            //printf("%i\n",(int) distnode[(int) (j*qtnode + k-1)]);             
            if (distnode[(int) (j * qtnode + partpos[j]-1)] + ndist[(int) (nt*qtnode + partpos[j]-1)] < distnode[(int) (j*qtnode + k-1)])                
                
                // atualizar dist�ncia do n� alvo
                distnode[(int) (j*qtnode + k-1)] = distnode[(int) (j*qtnode + partpos[j]-1)] + ndist[(int) (nt*qtnode + partpos[j]-1)];                
            
            // se n�o houve choque, atualizar posi��o da part�cula            
            // primeiro temos que encontrar o valor m�ximo de potencial do n� alvo
            double maxpot = 0;
            for(int i2=0; i2<nclass; i2++)
                if(pot[(int) (i2 * qtnode + k-1)] > maxpot)
                    maxpot = pot[(int) (i2 * qtnode + k-1)];
            
            // se o valor m�ximo for o da classe da part�cula, a part�cula vai para o n� alvo
            if (pot[(int) ((partclass[j]-1) * qtnode + k-1)] >= maxpot)
                partpos[j] = k;
        }
        // vamos testar converg�ncia
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
            if (i % 1000 == 0) 
            {
                printf("Iter: %i  Meanpot: %0.4f\n",i,mmpot);
                mexEvalString("drawnow");
            }
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
    double pgrd, dexp, deltav, deltap, potmin;  // escalares double
    double *partpos, *partclass, *potpart, *slabel, *nsize;  // vetores de int
    double *distnode, *nlist; // matrizes de int
    double *pot, *owndeg, *ndist;  // matrizes de double
    int qtnode, neibmax;
    
    /* Check for proper number of arguments */
    
    
    if (nrhs != 18) { 
	    mexErrMsgTxt("18 argumentos de entrada requeridos."); 
    } else if (nlhs > 1) {
	    mexErrMsgTxt("Muitos argumentos de sa�da."); 
    }
    
    maxiter = (int) mxGetScalar(maxiter_IN);
    npart = (int) mxGetScalar(npart_IN);
    nclass = (int) mxGetScalar(nclass_IN);
    stopmax = (int) mxGetScalar(stopmax_IN);
    pgrd = mxGetScalar(pgrd_IN);
    dexp = mxGetScalar(dexp_IN);
    deltav = mxGetScalar(deltav_IN);
    deltap = mxGetScalar(deltap_IN);
    potmin = mxGetScalar(potmin_IN);
    partpos = mxGetPr(partpos_IN);
    partclass = mxGetPr(partclass_IN);
    potpart = mxGetPr(potpart_IN);
    slabel = mxGetPr(slabel_IN);
    nsize = mxGetPr(nsize_IN);
    distnode = mxGetPr(distnode_IN);
    nlist = mxGetPr(nlist_IN);    
    ndist = mxGetPr(ndist_IN);
    pot = mxGetPr(pot_IN);
    
    qtnode = (int) mxGetM(slabel_IN);
    neibmax = (int) mxGetN(nlist_IN);  // quantidade m�xima de vizinhos que um n� tem   
    
    /* Create a matrix for the return argument */ 
    pot_OUT = pot_IN;
        
    strwalk22loop(maxiter,npart,nclass,stopmax,pgrd,dexp,deltav,deltap,potmin,partpos,partclass,potpart,slabel,nsize,distnode,nlist,ndist,pot,qtnode,neibmax);
    
    return;
    
}
