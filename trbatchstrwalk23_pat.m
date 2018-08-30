rep = 200;
subsetmax = 12;
iter_err = zeros(rep,1);
tab_par = zeros(subsetmax,1);
tab_err = zeros(subsetmax,1);
for subset=1:1:subsetmax
    disp(sprintf('Rodando Algoritmo Gen�tico para Subset %02.0f',subset))
    [label, slabel] = trreadlabels(y,idxLabs,subset);
    fitfunstrwalk = @(x)fitstrwalk23(x,X,slabel,label,'euclidean'); 
    %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',10);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',50,'InitialPopulation',[2;4;6;8;10;15;20;25;30;40;50;60;70;80;90;100;125;150;175;200]);
    %gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
    [gaout, fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);
    tab_par(subset,:) = gaout;
    k = round(gaout(1));
    tab_err(subset)=fval;    
    disp(sprintf('FINAL: Subset: %02.0f - K: %02.0f - Erro: %0.4f',subset,k,fval))
    save tabs_strwalk23_pat tab_par tab_err;
end
