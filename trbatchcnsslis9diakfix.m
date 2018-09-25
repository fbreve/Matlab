imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

if exist('tab_eval','var')==0
    tab_eval = zeros(50,6);   
end
if exist('tab_time','var')==0
    tab_time = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

k=10;

for i=1:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %2.0f/50: - ',i);
    [img,imgslab,gt] = imgdiaload(imgname,scribbleset);
    tstart = tic;
    owner = cnsslis9(img, imgslab, [], k);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    imgres = own2img(owner,img,0);
    [err, acc, tpr, spc, jaccard, dice] = imgeval2(imgres, gt, imgslab);
    tab_eval(i,:) = [err, acc, tpr, spc, jaccard, dice];
    % imprime resultados na tela
    fprintf('ACC: %0.4f  TPR: %0.4f SPC: %0.4f Jaccard: %0.4f Dice: %0.4f Tempo: %8.2f\n',acc,tpr,spc,jaccard,dice,telapsed);
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis9-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),err,k));
    dlmwrite(sprintf('res/imgcnsslis9-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),err,k),[err telapsed k]);
    save(sprintf('res/tabs_cnsslis9-%s',getenv('computername')),'tab_eval','tab_time');           
end