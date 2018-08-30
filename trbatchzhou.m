% GPUstart
% spmd
%     GPUstart
% end

subsetmax = 12;

tab_err = zeros(subsetmax,1);
tab_par = zeros(subsetmax,1);

options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',20,'Generations',50);

for subset=1:1:subsetmax
    [label, slabel] = trreadlabels(y,idxLabs,subset);
     
    disp(sprintf('Rodando Algoritmo Genético para Subset %02.0f - Consistency Method',subset))
    fitfunzhou = @(x)fitzhou(x,X,slabel,label);
    [gaout, fval] = ga(fitfunzhou,1,[],[],[],[],0,0.5,[],options);
    tab_err(subset) = fval;
    tab_par(subset) = gaout;
    disp(sprintf('Consistency Method - Subset: %02.0f  Sigma: %0.4f  Erro: %0.4f',subset,tab_par(subset),tab_err(subset)))   
      
    save tab_comp tab_err tab_par;
end

