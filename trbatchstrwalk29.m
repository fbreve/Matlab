kmin = 1;
kmax = 1000;
dmmin = zeros(1,20);
dmmax = ones(1,20);
disttype = 'euclidean';
slabtype = 1;

fitfunstrwalk = @(x)fitstrwalk29(x,img,imgslab,gt,disttype,slabtype);
if exist('k','var')==1 && exist('dm','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k dm]);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfunstrwalk,21,[],[],[],[],[kmin dmmin],[kmax dmmax],[],options);
k = round(gaout(1));
dm = gaout(2:21);
disp('FINAL: DM: ');
disp(sprintf('%0.2f  ',dm))
disp(sprintf('FINAL: K: %3.0f - Erro: %0.4f',k,dm,fval))
save(sprintf('%s-tabs_strwalk28',getenv('computername')),'k','dm','fval');