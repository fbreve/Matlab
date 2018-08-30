kmin = 0;
kmax = 2000;
fwmin = zeros(1,20);
fwmax = ones(1,20);
disttype = 'euclidean';
slabtype = 1;

fitfuncnsslis = @(x)fitcnsslis3(x,img,imgslab,gt,disttype);
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
save(sprintf('tabs_cnsslis3-%s',getenv('computername')),'k','fw','fval','exitflag','output');

% teste com valores otimizados
fprintf('Gerando imagem com valores otimizados...\n')
tstart = tic;
owner = cnsslis3(img, imgslab, fw, k, disttype);
telapsed = toc(tstart);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
% imprime resultados na tela
fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
fprintf('%0.2f ',fw);
fprintf('\n');
imwrite(imgres,sprintf('img/imgcnsslis3-%s-err%0.4f-k%i.png',getenv('computername'),y,k));
dlmwrite(sprintf('img/imgcnsslis3-%s-err%0.4f-k%i.txt',getenv('computername'),y,k),fw);
fprintf('Concluído.\n');