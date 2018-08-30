kmin = 1;
kmax = 2000;
disttype = 'euclidean';
slabtype = 1;

fitfunstrwalk = @(x)fitstrwalk30(x,img,imgslab,gt,disttype);
if exist('k','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',k);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfunstrwalk,1,[],[],[],[],kmin,kmax,[],options);
k = round(gaout(1));
disp(sprintf('FINAL: K: %3.0f - Erro: %0.4f',k,fval))
save(sprintf('%s-tabs_strwalk28',getenv('computername')),'k','dm','fval');