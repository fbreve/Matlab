imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

if exist('tab_y','var')==0
    tab_y = zeros(50,20);
end

for i=1:50
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);
    parfor j=1:20
        k=j*2;
        owner = cnsslis9(img, imgslab, [], k);
        imgres = own2img(owner,img,0);
        tab_y(i,j) = imgeval(imgres, gt, imgslab);
        % imprime resultados na tela
        fprintf('Erro: %0.4f  K: %2.0f\n',tab_y(i,j),k);
    end
    save(sprintf('res/tabs_cnsslis9kvar-%s',getenv('computername')),'tab_y');
end