imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
'106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
'209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

disttype = 'euclidean';

if exist('tab_k','var')==0 
    tab_k = zeros(50,1);
end
if exist('tab_fw','var')==0 
    tab_fw = zeros(50,20);
end
if exist('tab_err','var')==0 
    tab_err = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);
    [k, fw] = kfwgen(img, imgslab);
    tstart = tic;
    owner = cnsslis5(img, imgslab, fw, k, disttype);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    err = imgeval(imgres, gt, imgslab);
    tab_err(i) = err;
    tab_k(i) = k;
    tab_fw(i,:) = fw;    
    save(sprintf('tabs_cnsslis5kfw-%s',getenv('computername')),'tab_k','tab_fw','tab_err');
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f  FW:',err,telapsed,k);
    fprintf('%0.2f ',fw);
    fprintf('\n');
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis-kfw-%s-%s-err%0.4f-k%i.png',imgname,getenv('computername'),err,k));
    dlmwrite(sprintf('res/imgcnsslis-kfw-%s-%s-err%0.4f-k%i.txt',imgname,getenv('computername'),y,k),[y telapsed k fw]);
end