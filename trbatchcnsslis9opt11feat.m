fwmin = zeros(1,11);
fwmax = ones(1,11);

fitfuncnsslis = @(x)fitcnsslis9_11feat(x);
options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
%IntCon = 1:11;
IntCon = [];
[gaout, fval] = ga(fitfuncnsslis,11,[],[],[],[],fwmin,fwmax,[],IntCon,options);
save(sprintf('res/tabs_cnsslis9_11feat-%s',getenv('computername')),'gaout','fval');