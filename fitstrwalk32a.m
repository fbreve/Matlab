function y = fitstrwalk32a(x,img,imgslab,disttype)
    k = round(x(1));
    fw = x(2:24);
    tstart = tic;
    y = - strwalk32indint2(img, imgslab, k, fw, disttype);
    telapsed = toc(tstart);
    disp([sprintf('K: %4.0f  Ind: %12.4f  Tempo: %8.2f  FW: ',k,-y,telapsed) sprintf('%0.2f ',fw)])
    filename = ['fitstrwalk32a-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'K: %4.0f  Ind: %12.4f  Tempo: %8.2f  FW: ',k,-y,telapsed);
    fprintf(fileID,'%0.4f ',fw);
    fprintf(fileID,'\r\n');
    fclose(fileID);
end