imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

kmin = 0;
kmax = 250;
sigmamin = 0.001;
sigmamax = 2.000;
fwmin = zeros(1,9);
fwmax = ones(1,9);
fw_initpop = repmat([1 1 1 1 1 1 1 1 1],30,1);
k_initpop = [0 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 35 40 45 50 55 60 70 80 90 100 150 200]';
sigma_initpop = repmat(0.5,30,1);

if exist('tab_k','var')==0
    tab_k = zeros(50,1);
end
if exist('tab_sigma','var')==0
    tab_sigma = zeros(50,1);
end
if exist('tab_fw','var')==0
    tab_fw = zeros(50,9);
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
    fitfuncnsslis = @(x)fitcnsslis9optall(x,img,imgslab,gt);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k_initpop sigma_initpop fw_initpop]);
    IntCon = 1;    
    [x, y] = ga(fitfuncnsslis,11,[],[],[],[],[kmin sigmamin fwmin],[kmax sigmamax fwmax],[],IntCon,options);    
    k = x(1);
    sigma = x(2);
    fw = x(3:11);
    fprintf('Erro: %0.4f  K: %i  Sigma: %0.4f FW: ',y,k,sigma);
    fprintf('%0.4f ',fw);
    fprintf('\n');
    tab_k(i) = k;
    tab_sigma(i) = sigma;
    tab_fw(i,:) = fw;
    tab_y(i) = y;    
    % teste com valores otimizados
    tstart = tic;
    owner = cnsslis9(img, imgslab, fw, k, sigma);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  Sigma: %0.4f  FW: ',y,telapsed,k,sigma);
    fprintf('%0.4f ',fw);
    fprintf('\n');   
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis9optall-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgcnsslis9optall-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[y telapsed k sigma fw]);
    save(sprintf('tabs_cnsslis9optall-%s',getenv('computername')),'tab_k','tab_y','tab_time','tab_sigma','tab_fw');
end;