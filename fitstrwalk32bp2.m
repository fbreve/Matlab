function y = fitstrwalk32bp2(x,img,imgslab,gt,fw,disttype)
    k = x;
    tstart = tic;    
    owner = strwalk32(img, imgslab, k, fw, disttype);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-k%i.png',getenv('computername'),y,k));    
    disp(sprintf('Erro: %0.4f  K: %4.0f  Tempo: %8.2f',y,k,telapsed))
    filename = ['fitstrwalk32bp2-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'Erro: %0.4f  K: %4.0f  Tempo: %8.2f\r\n',y,k,telapsed);
    fclose(fileID);    
end