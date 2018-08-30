kmin = 1;
kmax = 1000;
fwmin = zeros(1,23);
fwmax = ones(1,23);
disttype = 'euclidean';
slabtype = 1;
fitfuncnsslis = @(x)fitcnsslis(x,img,imgslab,gt,disttype);
if exist('k','var')==1 && exist('fw','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k fw]);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
IntCon = 1;    
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfuncnsslis,24,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
k = round(gaout(1));
fw = gaout(2:24);
disp([sprintf('FINAL: Erro: %0.4f K: %3.0f FW: ',fval,k) sprintf('%0.2f ',fw)]);
save(sprintf('%s-tabs_fitcnsslis',getenv('computername')),'k','fw','fval');