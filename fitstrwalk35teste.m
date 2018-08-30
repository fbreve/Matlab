function y = fitstrwalk35teste(x,img,imgslab,gt,disttype)
    k = x(1); % remover, pois IntCon no trbatch já manda somente inteiros   
    fw = x(2:12);
    tstart = tic;
    owner = strwalk35teste(img, imgslab, fw, k, disttype);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);    
    disp([sprintf('Erro: %0.4f Tempo: %8.2f K: %4.0f FW: ',y,telapsed,k) sprintf('%0.2f ',fw)])
    filename = ['fitstrwalk35-' getenv('computername') '.txt'];
    fileID = fopen(filename,'a');
    fprintf(fileID,'Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
    fprintf(fileID,'%0.4f ',fw);
    fprintf(fileID,'\r\n');
    fclose(fileID);                    
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-k%i.png',getenv('computername'),y,k));
    dlmwrite(sprintf('img/img-%s-err%0.4f-k%i.txt',getenv('computername'),y,k),fw);
end