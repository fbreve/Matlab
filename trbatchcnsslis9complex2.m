% Script to measure complexity on individual images with fixed k and
% varying sizes
%
%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
k=10;
tab_time = zeros(10,100);
tab_ph1iter = zeros(10,1);
tab_ph2iter = zeros(10,1);
tab_err = zeros(10,1);
for i=1:10
    rs_img = imresize(img,sqrt(i/10),'bicubic');
    rs_imgslab = imresize(imgslab,sqrt(i/10),'nearest');
    rs_gt = imresize(gt,sqrt(i/10),'nearest');
    fprintf('Tratando imagem com %i%% do tamanho original\n',i/10*100);    
    % teste de quantidade de iterações
    [owner,~,ph1_ttiter,ph2_ttiter] = cnsslis9(rs_img, rs_imgslab, [], k);
    fprintf('Total de iterações - Fase 1: %i - Fase 2: %i\n',ph1_ttiter,ph2_ttiter);
    tab_ph1iter(i) = ph1_ttiter;
    tab_ph2iter(i) = ph2_ttiter;
    % guardar imagem ótima
    imgres = own2img(owner,rs_img,0);
    y = imgeval(imgres, rs_gt, rs_imgslab);
    tab_err(i) = y;    
    imwrite(imgres,sprintf('res/imgcnsslis9complex2-%i%%-%s-err%0.4f-k%i.png',i/10*100,getenv('computername'),y,k));
    % teste de tempo
    save(sprintf('res/tabs_cnsslis9complex2-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_err');
end
% teste de tempo
fprintf('Iniciando avaliação do tempo.\n');
for j=1:100
    for i=1:10
        rs_img = imresize(img,sqrt(i/10),'bicubic');
        rs_imgslab = imresize(imgslab,sqrt(i/10),'nearest');
        rs_gt = imresize(gt,sqrt(i/10),'nearest');    
        f = @() cnsslis9(rs_img, rs_imgslab, [], k);
        tab_time(i,j)= timeit(f);
        fprintf('Imagem com %i%% do tamanho original - Teste %i/100 - Tempo: %0.4f\n',i/10*100,j,tab_time(i,j));
    end
    save(sprintf('res/tabs_cnsslis9complex2-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_err');
end


