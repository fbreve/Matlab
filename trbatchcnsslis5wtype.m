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
if exist('tab_fval','var')==0 
    tab_fval = zeros(50,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

for i=i_start:1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);
    if wtype>0
        fw = fwgen(img, imgslab, wtype);
    else
        fw = ones(1,20);
    end
    err = zeros(2001,1);
    parfor ki=1:2001
        owner = cnsslis5(img, imgslab, fw, ki-1, disttype);
        imgres = own2img(owner,img,0);
        err(ki) = imgeval(imgres, gt, imgslab);
    end
    [fval,k] = min(err);
    k = k-1;
    tab_k(i) = k;
    tab_fval(i) = fval;
    save(sprintf('tabs_cnsslis5fw-wtype%i-%s',wtype,getenv('computername')),'tab_k','tab_fval');
 
    % teste com valores otimizados
    tstart = tic;
    owner = cnsslis5(img, imgslab, fw, k, disttype);
    telapsed = toc(tstart);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    % imprime resultados na tela
    fprintf('Erro: %0.4f  Tempo: %8.2f  K: %4.0f\n',y,telapsed,k);
    % grave imagem
    imwrite(imgres,sprintf('res/imgcnsslis5wtype%i-%s-%s-err%0.4f-k%i.png',wtype,imgname,getenv('computername'),y,k));
    dlmwrite(sprintf('res/imgcnsslis5wtype%i-%s-%s-err%0.4f-k%i.txt',wtype,imgname,getenv('computername'),y,k),[wtype y telapsed k fw]);
end