% Script to measure complexity on individual images with fixed sizes and
% varying k
%
%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
k = 10:10:250;
tab_time = zeros(25,100);
tab_ph1iter = zeros(25,1);
tab_ph2iter = zeros(25,1);
tab_err = zeros(25,1);
for i=1:25
    fprintf('Segmentando imagem com k=%i\n',k(i));
    % teste de quantidade de iterações
    [owner,~,ph1_ttiter,ph2_ttiter] = cnsslis9(img, imgslab, fw, k(i));
    fprintf('Total de iterações - Fase 1: %i - Fase 2: %i\n',ph1_ttiter,ph2_ttiter);
    tab_ph1iter(i) = ph1_ttiter;
    tab_ph2iter(i) = ph2_ttiter;
    % guardar imagem
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    tab_err(i) = y;    
    imwrite(imgres,sprintf('res/imgcnsslis9complex3-k%i-%s-err%0.4f.png',k(i),getenv('computername'),y));
    save(sprintf('res/tabs_cnsslis9complex3-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','k','tab_err');
end
% teste de tempo
fprintf('Iniciando avaliação do tempo.\n');
for j=1:100   
    for i=1:25
        %f = @() cnsslis9(img, imgslab, fw, k(i));
        %tab_time(i,j)= timeit(f);
        tstart = tic;
        cnsslis9(img, imgslab, [], k(i));
        tab_time(i,j) = toc(tstart);        
        fprintf('K: %i - Teste %i/100 - Tempo: %0.4f\n',k(i),j,tab_time(i,j));
    end
    save(sprintf('res/tabs_cnsslis9complex3-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','k','tab_err');
end


