% Uso: fw = fwgen(img, imgslab, wtype)
function fw = fwgen(img, imgslab, wtype)
dim = size(img);
qtnode = dim(1)*dim(2);
X = zeros(qtnode,20);
% primeiro e segundo elementos são linha e coluna normalizadas no intervalo 0:1
X(:,1:2) = [repmat(((1:dim(1))/dim(1))',dim(2),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)]; 
% depois vem os 3 elementos RGB normalizados em 0:1
imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
X(:,3:5) = imgvec;
% depois vem os 3 elementos HSV
imghsv = rgb2hsv(double(img)/255);
X(:,6:8) = squeeze(reshape(imghsv,dim(1)*dim(2),1,3));
% em seguida ExR, ExG, e ExB
exr = 2.*double(img(:,:,1)) - double(img(:,:,2)) - double(img(:,:,3));
exg = 2.*double(img(:,:,2)) - double(img(:,:,1)) - double(img(:,:,3));
exb = 2.*double(img(:,:,3)) - double(img(:,:,1)) - double(img(:,:,2));
imgex = cat(3, exr, exg, exb);
clear exr exg exb;
X(:,9:11) = squeeze(reshape(imgex,dim(1)*dim(2),1,3));
% médias
h = fspecial('average', [3 3]);
g = imfilter(img, h,'replicate'); % adicionado replicate para que bordas não fiquem diferentes
X(:,12:14) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
g = imfilter(imghsv, h, 'replicate'); % adicionado replicate para que bordas não fiquem diferentes)
X(:,15:17) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
g = imfilter(imgex, h, 'replicate'); % adicionado replicate para que bordas não fiquem diferentes)
X(:,18:20) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
clear g imghsv imgex;
% s = stdfilt(img);
% X(:,18:20) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)))/255;
% s = stdfilt(rgb2hsv(img));
% X(:,21:23) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)));
% clear s;
% normalizando as colunas
X = zscore(X);
% Converter imagem com rótulos em vetor de rótulos
slabel = uint16(reshape(imgslab,dim(1)*dim(2),1));
% ajustar vetor de rótulos
slabel(slabel==0)=-1; % fundo não considerado
slabel(slabel==64)=1;  % c/ rótulo - fundo
slabel(slabel==255)=2; % c/ rótulo - objeto
slabel(slabel==128)=0; % sem rótulo

if wtype>=3
    slabelc1 = sum(slabel==1);
    slabelc2 = sum(slabel==2);
    histc1 = zeros(20,10);
    histc2 = zeros(20,10);
    for i=1:20
        [~,centers] = hist(X(:,i));
        if wtype==3
            histc1(i,:) = hist(X(slabel==1,i),centers);
            histc2(i,:) = hist(X(slabel==2,i),centers);
        else
            histc1(i,:) = cumsum(hist(X(slabel==1,i),centers));
            histc2(i,:) = cumsum(hist(X(slabel==2,i),centers));
        end
        histc1(i,:) = histc1(i,:) ./ slabelc1;
        histc2(i,:) = histc2(i,:) ./ slabelc2;
    end
    fw = sum(abs(histc1-histc2),2)';
else
    fw = abs(mean(X(slabel==1,:))-mean(X(slabel==2,:)));
    if wtype==2
        fwstd = std(X(slabel==1,:))+std(X(slabel==2,:));
        fw = fw./fwstd;
    end
end
        
end
