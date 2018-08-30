function y = fitcnsslis(x,img,imgslab,gt,disttype)
    k = x(1);
    fw = x(2:24);
    tstart = tic;
    owner = cnsslis(img, imgslab, k, fw, disttype);
    telapsed = toc(tstart);    
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-k%i.png',getenv('computername'),y,k));    
    disp([sprintf('Erro: %0.4f Tempo: %8.2f K: %4.0f FW: ',y,telapsed,k) sprintf('%0.2f ',fw)])
    filename = ['fitcnsslis-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'Erro: %0.4f Tempo: %8.2f K: %4.0f FW: ',y,telapsed,k);       
    fprintf(fileID,'%0.4f ',fw);
    fprintf(fileID,'\r\n');    
    fclose(fileID);    
end