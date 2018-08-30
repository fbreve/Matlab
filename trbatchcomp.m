GPUstart
spmd
    GPUstart
end

load tab_comp;
load 'uci-datasets\yeast'

rep = 200; % numero de repeti��es
subsetmax = 20;
isize=5;

iter_acc = zeros(rep,2);
iter_kap = zeros(rep,2);
iter_owndeg = zeros(size(X,1),max(label),rep);

tab_acc=zeros(subsetmax,isize);
tab_kap=zeros(subsetmax,isize);
tab_par = zeros(subsetmax,6);
%tab_owndeg = zeros(size(X,1),max(label),subsetmax);

options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',20,'Generations',50);

for subset=13:1:subsetmax
    slabel = slabelgen(label,(100/1484));
    
    disp(sprintf('Rodando Algoritmo Gen�tico para Subset %02.0f - Consistency Method',subset))
    fitfunzhou = @(x)fitzhou(x,X,slabel,label);
    [gaout, fval] = ga(fitfunzhou,1,[],[],[],[],0,10,[],options);
    tab_par(subset,1) = gaout;
    owner = gpuzhou(X,slabel,gaout);
    [tab_acc(subset,1),tab_kap(subset,1)] = stmwevalk(label,slabel,owner);
    disp(sprintf('Consistency Method - Subset: %02.0f  Sigma: %0.4f  Acerto: %0.4f  Kappa: %0.4f',subset,gaout,tab_acc(subset,1),tab_kap(subset,1)))
    
    disp(sprintf('Rodando Algoritmo Gen�tico para Subset %02.0f - Label Propagation',subset))
    fitfunlabelprop = @(x)fitlabelprop(x,X,slabel,label);
    [gaout, fval] = ga(fitfunlabelprop,1,[],[],[],[],0,10,[],options);
    tab_par(subset,2) = gaout;    
    owner = gpulabelprop(X,slabel,gaout);
    [tab_acc(subset,2),tab_kap(subset,2)] = stmwevalk(label,slabel,owner);
    disp(sprintf('Label Propagation - Subset: %02.0f  Sigma: %0.4f  Acerto: %0.4f  Kappa: %0.4f',subset,gaout,tab_acc(subset,2),tab_kap(subset,2)))
    
    disp(sprintf('Rodando Algoritmo Gen�tico para Subset %02.0f - Linear Neighbor Propagation',subset))
    fitfunlnp = @(x)fitlnp(x,X,slabel,label);
    [gaout, fval] = ga(fitfunlnp,1,[],[],[],[],1,100,[],options);
    tab_par(subset,3) = gaout;    
    owner = gpulnp(X,slabel,round(gaout));
    [tab_acc(subset,3),tab_kap(subset,3)] = stmwevalk(label,slabel,owner);
    disp(sprintf('Linear NP - Subset: %02.0f  K: %0.4f  Acerto: %0.4f  Kappa: %0.4f',subset,gaout,tab_acc(subset,3),tab_kap(subset,3)))
    
    disp(sprintf('Rodando Algoritmo Gen�tico para Subset %02.0f - Part�culas',subset))
    fitfunstrwalk = @(x)fitstrwalk(x,X,slabel,label);
    gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
    tab_par(subset,4:6) = gaout;
    k = round(gaout(1));
    pdet = gaout(2);
    deltav = gaout(3);
    disp(sprintf('Valores otimizados: K: %02.0f  Pdet: %0.4f  DeltaV: %0.4f',k,pdet,deltav))
    parfor i=1:rep
        [owner, pot, owndeg, distnode] = strwalk8k(X, slabel, k, pdet, deltav);
        [acc4, kap4] = stmwevalk(label,slabel,owner);
        [~,owner2] = max(owndeg,[],2);
        [acc5, kap5] = stmwevalk(label,slabel,owner2);
        disp(sprintf('Part�culas - Subset: %02.0f  Itera��o: %03.0f  Acerto: %0.4f / %0.4f  Kappa: %0.4f / %0.4f',subset,i,acc4,acc5,kap4,kap5))
        iter_acc(i,:) = [acc4,acc5];
        iter_kap(i,:) = [kap4,kap5];
        iter_owndeg(:,:,i) = owndeg;
    end
    tab_acc(subset,4)=mean(iter_acc(:,1));
    tab_acc(subset,5)=mean(iter_acc(:,2));
    tab_kap(subset,4)=mean(iter_kap(:,1));
    tab_kap(subset,5)=mean(iter_kap(:,2));
    tab_owndeg(:,:,subset) = mean(iter_owndeg,3);

    disp(sprintf('Part�culas     - Subset: %02.0f  K: %0.4f  Acerto: %0.4f  Kappa: %0.4f',subset,gaout,tab_acc(subset,4),tab_kap(subset,4)))
    disp(sprintf('Part�culas (F) - Subset: %02.0f  K: %0.4f  Acerto: %0.4f  Kappa: %0.4f',subset,gaout,tab_acc(subset,5),tab_kap(subset,5)))
    
    disp(sprintf('Subset: %02.0f  Acerto: CM/LP/LNP/PART1/PART2: %0.4f / %0.4f / %0.4f / %0.4f / %0.4f',subset,tab_acc(subset,1),tab_acc(subset,2),tab_acc(subset,3),tab_acc(subset,4),tab_acc(subset,5)))
    disp(sprintf('Subset: %02.0f  Kappa:  CM/LP/LNP/PART1/PART2: %0.4f / %0.4f / %0.4f / %0.4f / %0.4f',subset,tab_kap(subset,1),tab_kap(subset,2),tab_kap(subset,3),tab_kap(subset,4),tab_kap(subset,5)))
   
    save tab_comp tab_acc tab_kap tab_owndeg;
end

