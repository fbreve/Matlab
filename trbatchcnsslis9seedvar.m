imgnames = {'21077' '24077' '37073' '65019' '69020' '86016' ...
    '106024' '124084' '153077' '153093' '181079' '189080' '208001' ...
    '209070'  '227092' '271008' '304074' '326038'  '376043' '388016' ...
    'banana1' 'banana2' 'banana3' 'book' 'bool' 'bush' 'ceramic' 'cross' ...
    'doll' 'elefant' 'flower' 'fullmoon' 'grave' 'llama' 'memorial' 'music' ...
    'person1' 'person2' 'person3' 'person4' 'person5' 'person6' 'person7' ...
    'person8' 'scissors' 'sheep' 'stone1' 'stone2' 'teddy' 'tennis'};

if exist('tab_y','var')==0
    tab_y = zeros(50,100,20);
end
if exist('tab_time','var')==0
    tab_time = zeros(50,100,20);
end

k = 10;
fw = [1 1 1 1 1 1 1 1 1];
sigma = 0.5;

for j=1:100
    p = 1 - j*0.01 + 0.01;
    for i=1:1:50
        parfor l=1:20
            imgname = imgnames{i};
            [img,imgslab,gt] = imgmsrcload(imgname);
            imgslabd = imgslabsr(imgslab,p);
            tstart = tic;
            owner = cnsslis9(img, imgslabd, fw, k, sigma);
            telapsed = toc(tstart);
            tab_time(i,j,l) = telapsed;
            imgres = own2img(owner,img,0);
            tab_y(i,j,l) = imgeval(imgres, gt, imgslabd); % regular error rate
            tab_y2(i,j,l) = imgeval(imgres, gt, imgslab); % error rate disregarding the changed nodes
            fprintf('Imagem %2.0f P: %0.2f Rep.: %2.0f/20 Erro: %0.4f Erro2: %0.4f Tempo: %8.4f\n',i,p,l,tab_y(i,j,l),tab_y2(i,j,l),tab_time(i,j,l));
        end                
    end
    save(sprintf('res/tabs_cnsslis9seedvar-%s',getenv('computername')),'tab_y','tab_y2','tab_time');
end