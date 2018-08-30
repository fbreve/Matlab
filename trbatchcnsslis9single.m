%fw = [1 1 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
fw = ones(1,9);
%fw = [1 1 0 0 0 7 0 0 0];
kmax = 300;
err = zeros(kmax+1,1);
parfor ki=1:kmax+1
    owner = cnsslis9(img, imgslab, fw, ki-1);
    imgres = own2img(owner,img,0,imgslab);    
    err(ki) = imgeval(imgres, gt, imgslab);
    fprintf('K: %i  Erro: %0.4f\n',ki-1,err(ki));
end
[~,k] = min(err);
k = k-1;
% teste com valores otimizados
tstart = tic;
owner = cnsslis9(img, imgslab, fw, k);
telapsed = toc(tstart);
imgres = own2img(owner,img,0,imgslab);
y = imgeval(imgres, gt, imgslab);
% imprime resultados na tela
fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);