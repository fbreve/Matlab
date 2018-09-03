imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

if exist('tab_k','var')==0
    tab_k = zeros(50,1);
end
if exist('tab_y','var')==0
    tab_y = zeros(50,1);
end
if exist('tab_fval','var')==0
    tab_fval = zeros(50,1);
end
if exist('tab_time','var')==0
    tab_time = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

kmin = 1;
kmax = 1000;

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);    
    
    fitfunstrwalk = @(x)fitstrwalk37(x,img,imgslab,gt);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',50,'InitialPopulation',[1;2;3;4;5;6;7;8;9;10;20;30;40;50;60;70;80;90;100;200;300;400;500;600;700;800;900;1000]);
    %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
    
    IntCon = 1; % define que o a variável 1 (a única) é inteira em vez de real
    [gaout, fval, exitflag, output] = ga(fitfunstrwalk,1,[],[],[],[],kmin,kmax,[],IntCon,options);
    
    k = gaout(1);
    fprintf('FINAL:  Erro: %0.4f  K: %4.0f\r\n',fval,k);
          
    tab_k(i) = k;
    tab_fval(i) = fval;
    
    % teste com valores otimizados
    tstart = tic;
    owner = strwalk37(img, imgslab, [], k);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);    
    tab_y(i) = y;
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);
    % grave imagem
    imwrite(imgres,sprintf('res/imgstrwalk37-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgstrwalk37-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[y telapsed k]);
    save(sprintf('res/tabs_strwalk37-%s',getenv('computername')),'tab_k','tab_fval','tab_y','tab_time');
end