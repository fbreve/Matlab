function y = fitcnsslis9_20feat(x)
fw = x;

imgnames = {'21077' '124084' '271008' '208001' 'llama' 'doll' 'person7' 'sheep' 'teddy'};

%imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
%    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
%    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
%    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
%    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
%    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
%    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

tab_err = zeros(9,1);
%tab_err = zeros(50,1);


for i=1:9
    imgname = imgnames{i};
    [img,imgslab,gt] = imgmsrcload(imgname);
    owner = cnsslis9_20feat(img, imgslab, fw);
    imgres = own2img(owner,img,0);
    tab_err(i) = imgeval(imgres, gt, imgslab);
end

y = mean(tab_err);
end