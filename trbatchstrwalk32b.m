k = 100;
fwmin = zeros(1,23);
fwmax = ones(1,23);
disttype = 'euclidean';

disp('Definindo o valor do expoente do índice...')
noexpoind = strwalk32indint2(img, imgslab, k, fwmax, 1, disttype);
expo = log(0.5)/log(noexpoind);
disp(sprintf('Índice sem expoente: %0.12f - Expoente: %16.4f',noexpoind,expo))

fitfunstrwalk = @(x)fitstrwalk32b(x,img,imgslab,disttype,k,expo);
if exist('fw','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',fw);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
end
%gaout = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[100, 0.99, 0.95],[],options);
[gaout, fval] = ga(fitfunstrwalk,23,[],[],[],[],fwmin,fwmax,[],options);
fw = gaout;
disp('FINAL: FW: ');
disp(sprintf('%0.2f  ',fw))
disp(sprintf('FINAL: Índice: %0.12f',1-fval))
save(sprintf('%s-tabs_strwalk32b',getenv('computername')),'k','fw','fval','expo','noexpoind');