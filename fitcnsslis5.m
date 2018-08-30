function y = fitcnsslis5(x,img,imgslab,gt,disttype)
    k = x(1);
    fw = x(2:21);
    %tstart = tic;
    owner = cnsslis5(img, imgslab, fw, k, disttype);
    %telapsed = toc(tstart);    
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    %fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
    %fprintf('%0.2f ',fw);
    %fprintf('\n');
    % imprime resultados no arquivo          
    %filename = ['fitcnsslis4-galog-' imgname '-' getenv('computername') '.txt'];
    %fileID = fopen(filename,'a');
    %fprintf(fileID,'Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
    %fprintf(fileID,'%0.4f ',fw);
    %fprintf(fileID,'\r\n');
    %fclose(fileID);                    
    % Como o algoritmo é estocástico, é desnecessário gravar as imagens de
    % cada teste, pois elas podem ser geradas no final.
    %imwrite(imgres,sprintf('img/imgcnsslis3-%s-err%0.4f-k%i.png',getenv('computername'),y,k));
    %dlmwrite(sprintf('img/imgcnsslis3-%s-err%0.4f-k%i.txt',getenv('computername'),y,k),fw);    
end