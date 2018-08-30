function fw = cnsslis9fwgen(img, imgslab)
img = imresize(img,1/3,'bilinear');
imgslab = imresize(imgslab,1/3,'bilinear');
imgslab(imgslab<64 & imgslab>0) = 64;
imgslab(imgslab<128 & imgslab>64) = 64;
imgslab(imgslab>128) = 255;

dim = size(img);
qtnode = dim(1)*dim(2);
X = zeros(qtnode,9);
% primeiro e segundo elementos são linha e coluna normalizadas no intervalo 0:1
X(:,1:2) = [repmat(((1:dim(1))/dim(1))',dim(2),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)];
% depois vem os 3 elementos RGB normalizados em 0:1
imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
X(:,3:5) = imgvec;
% depois vem os 3 elementos HSV
imghsv = rgb2hsv(double(img)/255);
X(:,6) = squeeze(reshape(imghsv(:,:,3),dim(1)*dim(2),1,1));
% em seguida ExR, ExG, e ExB
exr = 2.*double(img(:,:,1)) - double(img(:,:,2)) - double(img(:,:,3));
exg = 2.*double(img(:,:,2)) - double(img(:,:,1)) - double(img(:,:,3));
exb = 2.*double(img(:,:,3)) - double(img(:,:,1)) - double(img(:,:,2));
imgex = cat(3, exr, exg, exb);
clear exr exg exb;
X(:,7:9) = squeeze(reshape(imgex,dim(1)*dim(2),1,3));
X = zscore(X);
% Converter imagem com rótulos em vetor de rótulos
slabel = uint16(reshape(imgslab,dim(1)*dim(2),1));
% ajustar vetor de rótulos
slabel(slabel==0)=-1; % fundo não considerado
slabel(slabel==64)=1;  % c/ rótulo - fundo
slabel(slabel==255)=2; % c/ rótulo - objeto
slabel(slabel==128)=0; % sem rótulo

ffun = @(x)fitfun(x,X,slabel);
options = gaoptimset('Display','iter','UseParallel','always');
fw = ga(ffun,9,[],[],[],[],zeros(9,1),ones(9,1),[],options);
end

function y = fitfun(x,X,slabel)
fw = x;
fw = fw/max(fw);
X = X .* repmat(fw,size(X,1),1);
X1 = X(slabel==1,:);
X2 = X(slabel==2,:);
clear X;
DI = mean(mean(pdist2(X1,X1,'euclidean','Smallest',10))) + mean(mean(pdist2(X2,X2,'euclidean','Smallest',10)));
DE = mean(mean(pdist2(X1,X2,'euclidean','Smallest',20)));
y = DI-DE;
end