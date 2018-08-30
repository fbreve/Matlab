function y = fitstrwalk32(x,img,imgslab,disttype)
    k = round(x(1));
    fw = x(2:24);
    tstart = tic;
    y = 1 - strwalk32indint(img, imgslab, k, fw, disttype);
    telapsed = toc(tstart);
    disp([sprintf('K: %4.0f  Ind: %0.4f  Tempo: %8.2f  FW: ',k,1-y,telapsed) sprintf('%0.2f ',fw)])
    filename = ['fitstrwalk32-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'K: %4.0f  Ind: %0.8f  Tempo: %8.2f  FW: ',k,1-y,telapsed);
    fprintf(fileID,'%0.4f ',fw);
    fprintf(fileID,'\r\n');
    fclose(fileID);
end