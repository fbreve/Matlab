function y = fitstrwalk32b(x,img,imgslab,disttype,k,expo)
    fw = x;
    tstart = tic;
    y = 1 - strwalk32indint2(img, imgslab, k, fw, expo, disttype);
    telapsed = toc(tstart);
    disp([sprintf('Ind: %0.12f  Tempo: %8.2f  FW: ',1-y,telapsed) sprintf('%0.2f ',fw)])
    filename = ['fitstrwalk32b-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'Ind: %0.12f  Tempo: %8.2f  FW: ',1-y,telapsed);
    fprintf(fileID,'%0.4f ',fw);
    fprintf(fileID,'\r\n');
    fclose(fileID);
end