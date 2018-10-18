%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
tab_time = zeros(10,10);
tab_ph1iter = zeros(10,1);
tab_ph2iter = zeros(10,1);
tab_err = zeros(10,1);
if exist('i_start','var')==0
    i_start = 1;
end
for j=i_start:10
    for i=1:10
        k = i*10;
        if j==1
            fprintf('Tratando imagem com k=%4.0f\n',k);
            % teste de quantidade de iterações
            tstart = tic;
            [owner,~,ph1_ttiter,ph2_ttiter] = cnsslis9(rs_img, rs_imgslab, [], k);
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
        else
            tstart = tic;
            cnsslis9(rs_img, rs_imgslab, [], k);
            tab_time(i,j) = toc(tstart);
            fprintf('Imagem com k=%4.0f - Teste %i/10 - Tempo: %0.4f\n',k,j,tab_time(i,j));
        end
        save(sprintf('res/tabs_cnsslis9largescale-%s',getenv('computername')),'tab_time','tab_ph1iter','tab_ph2iter','tab_err');
    end
end


