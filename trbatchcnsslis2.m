kmin = 0;
kmax = 1000;
fwmin = zeros(1,20);
fwmax = ones(1,20);
disttype = 'euclidean';
slabtype = 1;

fitfuncnsslis = @(x)fitcnsslis2(x,img,imgslab,gt,disttype);
if exist('k','var')==1 && exist('fw','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k fw]);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
IntCon = 1;
[gaout, fval, exitflag, output] = ga(fitfuncnsslis,21,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
k = gaout(1);
fw = gaout(2:21);

fprintf('FINAL:  Erro: %0.4f  K: %4.0f  FW: ',fval,k);
fprintf('%0.4f ',fw);
fprintf('\r\n');
save(sprintf('tabs_strwalk35-%s',getenv('computername')),'k','fw','fval','exitflag','output');