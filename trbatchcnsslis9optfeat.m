fwmin = zeros(1,20);
fwmax = ones(1,20);

fitfuncnsslis = @(x)fitcnsslis9_20feat(x);
options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
IntCon = 1:20;
[gaout, fval] = ga(fitfuncnsslis,20,[],[],[],[],fwmin,fwmax,[],IntCon,options);
save(sprintf('res/tabs_cnsslis9_20feat-%s',getenv('computername')),'gaout','fval');