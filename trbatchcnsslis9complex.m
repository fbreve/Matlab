% Script to measure complexity on individual images with optimal k (not
% used on article)
% 
%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');

tab_time = zeros(10,10);
tab_ph1iter = zeros(10,1);
tab_ph2iter = zeros(10,1);
tab_k = zeros(10,1);
tab_err = zeros(10,1);
for i=1:10
    rs_img = imresize(img,sqrt(i/10),'bicubic');
    rs_imgslab = imresize(imgslab,sqrt(i/10),'nearest');
    rs_gt = imresize(gt,sqrt(i/10),'nearest');
    err = zeros(300,1);
    fprintf('Tratando imagem com %i%% do tamanho original\n',i/10*100);
    parfor ki=1:300
        owner = cnsslis9(rs_img, rs_imgslab, [], ki);
        imgres = own2img(owner,rs_img,0);
        err(ki) = imgeval(imgres, rs_gt, rs_imgslab);
        fprintf('K: %i  Erro: %0.8f\n',ki,err(ki));
    end
    [y,k] = min(err);
    fprintf('K ótimo: %i  Erro: %0.8f\n',k,min(err));
    tab_k(i) = k;
    tab_err(i) = y;
    % teste de quantidade de iterações
    [owner,~,ph1_ttiter,ph2_ttiter] = cnsslis9complex(rs_img, rs_imgslab, [], k);
    fprintf('Total de iterações - Fase 1: %i - Fase 2: %i\n',ph1_ttiter,ph2_ttiter);
    tab_ph1iter(i) = ph1_ttiter;
    tab_ph2iter(i) = ph2_ttiter;
    % guardar imagem ótima
    imgres = own2img(owner,rs_img,0);
    imwrite(imgres,sprintf('res/imgcnsslis9complex-%i%%-%s-err%0.4f-k%i.png',i/10*100,getenv('computername'),y,k));    
    save(sprintf('tabs_cnsslis9complex-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_k','tab_err');
end
% teste de tempo
fprintf('Iniciando avaliação do tempo.\n');
for i=1:10
    rs_img = imresize(img,sqrt(i/10),'bicubic');
    rs_imgslab = imresize(imgslab,sqrt(i/10),'nearest');
    rs_gt = imresize(gt,sqrt(i/10),'nearest');    
    k = tab_k(i);
    f = @() cnsslis9(rs_img, rs_imgslab, [], k);
    for j=1:10
        tab_time(i,j)= timeit(f);
        fprintf('Imagem com %i%% do tamanho original - Teste %i/10 - Tempo: %0.4f\n',i/10*100,j,tab_time(i,j));
    end
    save(sprintf('tabs_cnsslis9complex-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_k','tab_err');
end


