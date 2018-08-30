kmin = 1;
kmax = 1000;
fwmin = zeros(1,23);
fwmax = ones(1,23);
disttype = 'euclidean';
slabtype = 1;

fitfunstrwalk = @(x)fitstrwalk32(x,img,imgslab,disttype);
if exist('k','var')==1 && exist('fw','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k fw]);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfunstrwalk,24,[],[],[],[],[kmin fwmin],[kmax fwmax],[],options);
k = round(gaout(1));
fw = gaout(2:24);
disp('FINAL: FW: ');
disp(sprintf('%0.2f  ',fw))
disp(sprintf('FINAL: K: %3.0f - Erro: %0.4f',k,fw,fval))
save(sprintf('%s-tabs_strwalk32',getenv('computername')),'k','fw','fval');