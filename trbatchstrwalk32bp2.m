kmin = 1;
kmax = 1000;
disttype = 'euclidean';
slabtype = 1;

fitfunstrwalk = @(x)fitstrwalk32bp2(x,img,imgslab,gt,fw,disttype);
if exist('k','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',k);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
IntCon = 1;    
[gaout, fval] = ga(fitfunstrwalk,1,[],[],[],[],kmin,kmax,[],IntCon,options);
k = gaout(1);
disp(sprintf('FINAL: K: %3.0f - Erro: %0.4f',k,fval))
save(sprintf('%s-tabs_strwalk32p2',getenv('computername')),'k','fval');