[img,imgslab,gt] = imgmsrcload(imgname);
kmin = 0;
kmax = 2000;
fwmin = zeros(1,20);
fwmax = ones(1,20);
disttype = 'euclidean';
slabtype = 1;
k_initpop = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 22 24 26 28 30 35 40 45 50 60 70 80 90 100]';
fw_initpop = ones(35,20);
fitfuncnsslis = @(x)fitcnsslis4(x,img,imgslab,gt,disttype,imgname);
if exist('k','var')==1 && exist('fw','var')==1
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k fw]);
else    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k_initpop fw_initpop]);
end
IntCon = 1;
[gaout, fval, exitflag, output] = ga(fitfuncnsslis,21,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
k = gaout(1);
fw = gaout(2:21);

fprintf('FINAL:  Erro: %0.4f  K: %4.0f  FW: ',fval,k);
fprintf('%0.4f ',fw);
fprintf('\r\n');
save(sprintf('tabs_cnsslis4-%s-%s',imgname,getenv('computername')),'k','fw','fval','exitflag','output');

% teste com valores otimizados
fprintf('Gerando imagem com valores otimizados...\n')
tstart = tic;
owner = cnsslis4(img, imgslab, fw, k, disttype);
telapsed = toc(tstart);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
% imprime resultados na tela
fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
fprintf('%0.2f ',fw);
fprintf('\n');
imwrite(imgres,sprintf('img/imgcnsslis4-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
dlmwrite(sprintf('img/imgcnsslis4-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),fw);
fprintf('Concluído.\n');