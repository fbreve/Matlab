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
if exist('tab_time','var')==0
    tab_time = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end
fw = [];

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);    
    err = zeros(301,1);
    parfor ki=1:301
        owner = strwalk36(img, imgslab, fw, ki-1);
        imgres = own2img(owner,img,0);
        err(ki) = imgeval(imgres, gt, imgslab);
    end
    [y,k] = min(err);
    k = k-1;
    tab_k(i) = k;
    tab_y(i) = y;
    % teste com valores otimizados
    tstart = tic;
    owner = strwalk36(img, imgslab, fw, k);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);
    % grave imagem
    imwrite(imgres,sprintf('res/imgstrwalk36-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgstrwalk36-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[y telapsed k]);
    save(sprintf('tabs_strwalk36-%s',getenv('computername')),'tab_k','tab_y','tab_time');
end;