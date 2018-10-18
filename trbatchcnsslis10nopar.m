imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

if exist('tab_y','var')==0
    tab_y = zeros(50,1);
end
if exist('tab_time','var')==0
    tab_time = zeros(50,1);
end

k = 10;
fw = [1 1 1 1 1 1 1 1 1];

for i=1:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %2.0f/50: - ',i);
    [img,imgslab,gt] = imgmsrcload(imgname);    
    tstart = tic;
    owner = cnsslis10(img, imgslab, fw, k);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    tab_y(i) = y;
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.4f  K: %4.0f\n',y,telapsed,k);
    % grave imagem
    %imwrite(imgres,sprintf('res/imgcnsslis10nopar-%s-%s-err%0.4f.png',imgname,getenv('computername'),y));
    %dlmwrite(sprintf('res/imgcnsslis10nopar-%s-%s-err%0.4f.txt',imgname,getenv('computername'),y),[y telapsed k]);
    save(sprintf('tabs_cnsslis10nopar-%s',getenv('computername')),'tab_y','tab_time');
end