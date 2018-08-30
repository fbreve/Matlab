%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
sigma = 0.03:0.03:3;
tab_err = zeros(100,1);
for i=1:100
    fprintf('Segmentando imagem com sigma=%0.2f  ',sigma(i));
    % teste de quantidade de iterações
    owner = cnsslis9(img, imgslab, [], k, sigma(i));
    % guardar imagem
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    fprintf('Erro: %0.4f\n',y);
    tab_err(i) = y;    
    %imwrite(imgres,sprintf('res/imgcnsslis9par-k-k%i-%s-err%0.4f.png',k(i),getenv('computername'),y));
    save(sprintf('tabs_cnsslis9par-k-%s',getenv('computername')),'tab_err');
end


