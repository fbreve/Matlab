imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

rep=100;
if exist('tab_y','var')==0
    tab_y = zeros(50,10,rep);
    tab_time = zeros(50,10,rep);
end

for h=1:rep
    fprintf('Reptição %i/%i\n',h,rep);
    for i=1:50
        imgname = imgnames{i};
        fprintf('Segmentando imagem %i/50: %s\n',i,imgname);
        [img,imgslab,gt] = imgmsrcload(imgname);
        for j=1:10
            stopcrit = 10^-j;
            tstart = tic;
            owner = cnsslis9stopcrit(img, imgslab, [], [], [], [], [], [], stopcrit);
            telapsed = toc(tstart);
            imgres = own2img(owner,img,0);
            tab_y(i,j,h) = imgeval(imgres, gt, imgslab);
            tab_time(i,j,h) = telapsed;
            % imprime resultados na tela
            fprintf('Erro: %0.4f  Tempo: %0.4f  StopCrit: %0.10f\n',tab_y(i,j),tab_time(i,j),stopcrit);
        end
        save(sprintf('res/tabs_cnsslis9stopcrit-%s',getenv('computername')),'tab_y');
    end
end