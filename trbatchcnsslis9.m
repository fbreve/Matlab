imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

kmin = 1;
kmax = 2000;
k_initpop = [1 2 3 4 5 6 7 8 9 10 15 20 30 40 50 60 70 80 90 100 150 200 250 300 350 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1800 2000]';

if exist('tab_k','var')==0
    tab_k = zeros(50,1);
end
if exist('tab_y','var')==0
    tab_y = zeros(50,1);
end
if exist('tab_time','var')==0
    tab_time = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);    
    fitfuncnsslis = @(x)fitcnsslis9(x,img,imgslab,gt);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',10,'InitialPopulation',k_initpop);
    IntCon = 1;    
    [k, y] = ga(fitfuncnsslis,1,[],[],[],[],kmin,kmax,[],IntCon,options);    
    fprintf('Erro: %0.4f  K: %i\n',y,k);
    owner = cnsslis9(img, imgslab, [], 0);
    imgres = own2img(owner,img,0);
    err0 = imgeval(imgres, gt, imgslab);    
    fprintf('Erro: %0.4f  K: 0\n',err0);
    if err0<y
        k = 0;
        y = err0;
    end
    tab_k(i) = k;
    tab_y(i) = y;    
    % teste com valores otimizados
    tstart = tic;
    owner = cnsslis9(img, imgslab, [], k);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis9-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgcnsslis9-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[y telapsed k]);
    save(sprintf('tabs_cnsslis9-%s',getenv('computername')),'tab_k','tab_y','tab_time');
end;