function y = fitstrwalk36(x,img,imgslab,gt)
    k = x(1);
    tstart = tic;
    owner = strwalk36(img, imgslab, [], k);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);    
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);
end