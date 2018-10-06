%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
k=10;
tab_time = zeros(10,100);
tab_ph1iter = zeros(10,1);
tab_ph2iter = zeros(10,1);
tab_err = zeros(10,1);
for i=1:10
    rs_img = imresize(img,sqrt(i),'bicubic');
    % add a few amount of gaussian noise to simulate camera sensor noise
    % otherwise, enlarged images would look like a bunch of flat patches
    rs_img = imnoise(rs_img,'gaussian',0,0.001); 
    rs_imgslab = imresize(imgslab,sqrt(i),'nearest');
    rs_gt = imresize(gt,sqrt(i),'nearest');
    fprintf('Tratando imagem com %i vezes o tamanho original\n',i);
    % teste de quantidade de iterações
    tstart = tic;
    [owner,~,ph1_ttiter,ph2_ttiter] = cnsslis9complex(rs_img, rs_imgslab, [], k);
    telapsed = toc(tstart);
    fprintf('Total de iterações - Fase 1: %i - Fase 2: %i - Tempo: %0.2f\n',ph1_ttiter,ph2_ttiter,telapsed);
    tab_ph1iter(i) = ph1_ttiter;
    tab_ph2iter(i) = ph2_ttiter;
    tab_time(i,1) = telapsed;
    % guardar imagem ótima
    imgres = own2img(owner,rs_img,0);
    y = imgeval(imgres, rs_gt, rs_imgslab);
    tab_err(i) = y;    
    imwrite(imgres,sprintf('res/imgcnsslis9largescale-%ix-%s.png',i,getenv('computername')));
    save(sprintf('res/tabs_cnsslis9largescale-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_err');
end
% teste de tempo
fprintf('Iniciando avaliação do tempo.\n');
for j=2:10
    for i=1:10
        rs_img = imresize(img,sqrt(i),'bicubic');
        rs_img = imnoise(rs_img,'gaussian',0,0.001);
        rs_imgslab = imresize(imgslab,sqrt(i),'nearest');
        rs_gt = imresize(gt,sqrt(i),'nearest');    
        tstart = tic;
        cnsslis9(rs_img, rs_imgslab, [], k);
        tab_time(i,j) = toc(start);
        fprintf('Imagem com %i vezes o tamanho original - Teste %i/10 - Tempo: %0.4f\n',i,j,tab_time(i,j));
    end
    save(sprintf('res/tabs_cnsslis9largescale-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_err');
end


