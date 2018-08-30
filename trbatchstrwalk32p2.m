disttype = 'euclidean';
slabtype = 1;
rep = 1000;
tab_erro = zeros(rep,1);
tab_tempo = zeros(rep,1);
tstart = tic;
[~,KNN,knns,X] = strwalk32indint(img, imgslab, k, fw, disttype);
telapsed = toc(tstart);
disp(sprintf('Rede montada - Tempo: %8.2f',telapsed));

parfor i=1:rep
    tstart(i) = tic;
    [owner, owner2, potval, owndeg] = strwalk32knn(img, imgslab, X, KNN, knns, 'euclidean');
    tab_tempo(i) = toc(tstart(i));
    imgres = own2img(owner,img,0);
    tab_erro(i) = imgeval(imgres,gt,imgslab);
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-iter%i.png',getenv('computername'),tab_erro(i),i));
    disp(sprintf('Erro: %0.4f  Tempo: %8.2f',tab_erro(i),tab_tempo(i)));   
    filename = ['img/fitstrwalk32p2-' getenv('computername') '.txt'];
    fileID = fopen(filename','a');
    fprintf(fileID,'Erro: %0.4f  Tempo: %8.2f  Iteração: %i',tab_erro(i),tab_tempo(i),i);
    fprintf(fileID,'\r\n');
    fclose(fileID);
end

disp(sprintf('FINAL: Erro Mínimo: %0.4f - Erro Médio: %0.4f - Tempo Médio: % 8.2f',min(tab_erro),mean(tab_erro),mean(tab_tempo)));
save(sprintf('%s-tabs_strwalk32p2',getenv('computername')),'tab_erro','tab_tempo');