kmax = 1000;
dmmax = 500;
disttype = 'euclidean';
texture = 1;
slabtype = 1;

fitfunstrwalk = @(x)fitstrwalk28(x,img,imgslab,gt,disttype,texture,slabtype);
options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',20);
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfunstrwalk,2,[],[],[],[],[1 0],[kmax dmmax],[],options);
k = round(gaout(1));
dm = gaout(2);
disp(sprintf('FINAL: K: %3.0f - DM: %7.4f - Erro: %0.4f',k,dm,fval))
save(sprintf('%s-tabs_strwalk28',getenv('computername')),'k','dm','fval');