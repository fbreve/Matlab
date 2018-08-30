rep = 200;
subsetmax = 12;
iter_err = zeros(rep,1);
iter_err2 = zeros(rep,1);
tab_par = zeros(subsetmax,3);
tab_err = zeros(subsetmax,1);
tab_std_err = zeros(subsetmax,1);
tab_min_err = zeros(subsetmax,1);
tab_max_err = zeros(subsetmax,1);
tab_err2 = zeros(subsetmax,1);
tab_std_err2 = zeros(subsetmax,1);
tab_min_err2 = zeros(subsetmax,1);
tab_max_err2 = zeros(subsetmax,1);
for subset=1:1:subsetmax
    disp(sprintf('Rodando Algoritmo Genético para Subset %02.0f',subset))
    [label, slabel] = trreadlabels(y,idxLabs,subset);
    %fitfunstrwalk = @(x)fitstrwalk8k(x,X,slabel,label,'euclidean'); 
    fitfunstrwalk = @(x)fitstrwalk31(x,X,slabel,label,'euclidean'); 
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',50);
    %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',1,'Generations',5,'InitialPopulation',[1;2;3;4;5;6;7;8;9;10;20;30;40;50;60;70;80;90;100]);
    %gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
    gaout = ga(fitfunstrwalk,1,[],[],[],[],1,100,[],options);
    tab_par(subset,:) = gaout;
    k = round(gaout(1));
    %pdet = gaout(2);
    %deltav = gaout(3);
    %disp(sprintf('Valores otimizados: K: %02.0f  Pdet: %0.4f  DeltaV: %0.4f',k,pdet,deltav))
    disp(sprintf('Valor otimizado: K: %02.0f',k))
    parfor i=1:rep
        %[owner, pot, owndeg, distnode] = strwalk8k(X, slabel, k, pdet, deltav, 'euclidean'); 
        [owner, pot, owndeg] = strwalk31mex(X, slabel, k, 'euclidean'); 
        iter_err(i) = 1 - stmwevalk(label,slabel,owner);
        [~,owner2] = max(owndeg,[],2);
        iter_err2(i) = 1 - stmwevalk(label,slabel,owner2);
        disp(sprintf('Subset: %02.0f  Iteração: %03.0f  Erro: %0.4f  Erro2: %0.4f',subset,i,iter_err(i),iter_err2(i)))
    end
    tab_err(subset)=mean(iter_err);
    tab_std_err(subset)=std(iter_err);
    tab_min_err(subset)=min(iter_err);
    tab_max_err(subset)=max(iter_err);
    tab_err2(subset)=mean(iter_err2);
    tab_std_err2(subset)=std(iter_err2);
    tab_min_err2(subset)=min(iter_err2);
    tab_max_err2(subset)=max(iter_err2);
    disp(sprintf('FINAL: Subset: %02.0f Erro: %0.4f  Erro2: %0.4f',subset,tab_err(subset),tab_err2(subset)))
    save tabs_strwalk31 tab_par tab_err tab_std_err tab_min_err tab_max_err tab_err2 tab_std_err2 tab_min_err2 tab_max_err2;
end
