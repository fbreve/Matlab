% Script to find best k testing all values from 1 to 200
%
%gt = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-gt.png');
%imgslab = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270-scribble.png');
%img = imread('i:\Users\Fabricio\Documents\Doutorado\Simulações\Resultados\Segmentação\cnsslis9\outras\IMG_5270.jpg');
k = 1:200;
tab_err = zeros(200,1);
parfor i=1:200
    %fprintf('Segmentando imagem com k=%i  ',k(i));
    % teste de quantidade de iterações
    owner = cnsslis9(img, imgslab, fw, k(i));
    % guardar imagem
    imgres = own2img(owner,img,0,imgslab);
    tab_err(i) = imgeval(imgres, gt, imgslab);
    fprintf('K: %i - Erro: %0.8f\n',k(i),tab_err(i));
    %imwrite(imgres,sprintf('res/imgcnsslis9par-k-k%i-%s-err%0.4f.png',k(i),getenv('computername'),y));    
end
save(sprintf('res/tabs_cnsslis9par-k-%s',getenv('computername')),'tab_err');
