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
    fprintf('Calculando small-world-ness da imagem %2.0f/50: - ',i);
    [img,imgslab,gt] = imgmsrcload(imgname);
    tstart = tic;
    [S_ws,C_ws,L_ws,S_trans,C_trans,L_trans] = cnsslis9smallworldness(img);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    tab_eval(i,:) = [S_ws,C_ws,L_ws,S_trans,C_trans,L_trans];
    % imprime resultados na tela
    fprintf('S_ws: %0.4f C_ws: %0.4f L_ws: %0.4f S_trans: %0.4f C_trans: %0.4f L_trans: %0.4f Tempo: %8.2f\n',S_ws,C_ws,L_ws,S_trans,C_trans,L_trans,telapsed);
    % grave imagem
    save(sprintf('res/tabs_cnsslis9smallworldness-%s',getenv('computername')),'tab_eval','tab_time');           
end