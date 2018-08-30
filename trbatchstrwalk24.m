subsetmax = 12;
tab_par = zeros(subsetmax,1);
tab_err = zeros(subsetmax,1);
for subset=1:1:subsetmax
    disp(sprintf('Rodando Algoritmo Genético para Subset %02.0f',subset))
    [label, slabel] = trreadlabels(y,idxLabs,subset);
    fitfunstrwalk = @(x)fitstrwalk24(x,X,slabel,label,'euclidean'); 
    %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',10);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',50,'InitialPopulation',[1;2;3;4;5;6;7;8;9;10;15;20;30;40;60;80;100;120;160;200]);
    %gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
    [gaout, fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);
    tab_par(subset,:) = gaout;
    k = round(gaout(1));
    tab_err(subset)=fval;    
    disp(sprintf('FINAL: Subset: %02.0f - K: %02.0f - Erro: %0.4f',subset,k,fval))
    save tabs_strwalk24 tab_par tab_err;
end
