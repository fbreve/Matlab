imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
'106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
'209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

kmin = 0;
kmax = 2000;
fwmin = zeros(1,20);
fwmax = ones(1,20);
disttype = 'euclidean';
k_initpop = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 22 24 26 28 30 35 40 45 50 60 70 80 90 100]';
fw_initpop = ones(35,20);

if exist('tab_k','var')==0 
    tab_k = zeros(50,1);
end
if exist('tab_fw','var')==0 
    tab_fw = zeros(50,20);
end
if exist('tab_fval','var')==0 
    tab_fval = zeros(50,1);
end
if exist('tab_gen','var')==0 
    tab_gen = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);
    fitfuncnsslis = @(x)fitcnsslis5(x,img,imgslab,gt,disttype);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'InitialPopulation',[k_initpop fw_initpop]);
    IntCon = 1;
    [gaout, fval, exitflag, output] = ga(fitfuncnsslis,21,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
    k = gaout(1);
    fw = gaout(2:21);            
    fprintf('FINAL:  Erro: %0.4f  K: %4.0f  FW: ',fval,k);
    fprintf('%0.4f ',fw);
    fprintf('\n');

    tab_k(i) = k;
    tab_fw(i,1:20) = fw;
    tab_fval(i) = fval;
    tab_gen(i) = output.generations;
    
    save(sprintf('tabs_cnsslis5-%s',getenv('computername')),'tab_k','tab_fw','tab_fval','tab_gen');
 
    % teste com valores otimizados
    fprintf('Gerando imagem com valores otimizados...\n')
    tstart = tic;
    owner = cnsslis5(img, imgslab, fw, k, disttype);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW: ',y,telapsed,k);
    fprintf('%0.2f ',fw);
    fprintf('\n');
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis5-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgcnsslis5-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[telapsed k fw]);
    fprintf('Concluído.\n');
end