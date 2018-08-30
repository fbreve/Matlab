% Complex Networks Semi-Supervised Learning Image Segmentation v5
% Trabalha na primeira fase com imagem redimensionada para um 1/9 do tamanho
% original. Inclui ExR, ExB, e ExG. Exclui desvios padr�es (v2)
% N�o inclui vizinhan�a rec�proca (v3)
% Peso maior conforme a posi��o na lista de vizinhos mais pr�ximos (v4)
% Peso do vizinho de acordo com a Dist�ncia Euclidiana (v5)
% Mudan�as no c�lculo de dist�ncia da segunda fase (v5)
% 9 atributos (XY RGB V (de HSV) ExR ExG ExB (v8)
% Todo n� que n�o tem potencial maior totalmente definido (1) � considerado
% indeciso. Quando k=0, todos os n�s s�o considerados indecisos, inclusive rotulados (v8)
% Uso de gaussiana para calcular pesos (v9)
% Filtro bilinear para redimensionar tri-maps, aproximando em seguida os
% mistos para o rotulado predominante (v9)
% Usage: [owner, pot] = cnsslis9(img, imgslab, fw, k, sigma, disttype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented (24 bits, 3 channels - RGB)
% imgslab   - Image with labeled/unlabeled pixel information (0 is reserved
%             for ignored background, 64 - background class, 128 -
%             unlabeled pixels, 255 - foreground class. For multiclass use
%             [1~63; 65~127; 129~254] for other classes. (Obs: use only grayscale 8-bit indexed image)
% fw        - vector of feature weights
% k         - each node is connected to its k-neirest neighbors
% disttype  - use 'euclidean', etc.
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot

function G = teste(img, imgslab, fw, k, sigma, disttype, valpha, maxiter)
if (nargin < 8) || isempty(maxiter)
    maxiter = 500000; % n�mero de itera��es
end
if (nargin < 7) || isempty(valpha)
    valpha = 2;
end
if (nargin < 6) || isempty(disttype)
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
if (nargin < 5) || isempty(disttype)
    sigma = 0.5;
end
if (nargin < 4) || isempty(k)
    k = 10; % quantidade de vizinhos mais pr�ximos
end
if (nargin < 3) || isempty(fw)
    fw = ones(1,9);
    %fw = [1 1 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
end
% tratamento da entrada
k = uint16(k);

if k>0
    % reduzindo imagem
    rs_img = imresize(img,1/3,'bicubic');
    otherlabels = [1:63 65:127 129:254];    
    if isempty(intersect(unique(imgslab),otherlabels)) % se h� apenas duas classes
        rs_imgslab = imresize(imgslab,1/3,'bilinear');
        rs_imgslab(rs_imgslab<64 & rs_imgslab>0) = 64;
        rs_imgslab(rs_imgslab<128 & rs_imgslab>64) = 64;
        rs_imgslab(rs_imgslab>128) = 255;
    else % mais de duas classes
        rs_imgslab = imresize(imgslab,1/3,'nearest');
    end       
   
    [rs_dim,qtnode,X,slabel,nodeval,nclass] = getFeatures(rs_img,rs_imgslab,fw);
    
    % j� estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
    
    indval = find(nodeval);     % pega s� os �ndices dos pixels que n�o s�o do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels v�lidos (que n�o s�o do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de n�s v�lidos (pixels v�lidos)
    slabelval = slabel(indval); % r�tulos dos pixels v�lidos (n�o s�o do fundo ignorado)    
    
    nnonlabeled = sum(slabelval==0); % quantidade de n�s n�o rotulados
    
    stopmax = round((qtnodeval/nnonlabeled)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
    
    % lista de n�s n�o rotulados
    indnonlabeled = uint32(find(slabelval==0));
    % lista de n�s rotulados
    labelednodes = uint32(find(slabelval>0));
    
    % encontrando k-vizinhos mais pr�ximos
    [KNN,KNND] = knnsearch(Xval,Xval(indnonlabeled,:),'K',k+1,'NSMethod','kdtree','Distance',disttype);
    clear XVal;
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo

    G = digraph;
    [si,~] = size(KNN);
    for i=1:si
        G = addedge(G,i,KNN(i,:));
    end   
end
end

function [dim,qtnode,X,slabel,nodeval,nclass] = getFeatures(img,imgslab,fw)

% Aten��o: Atributo Linha e HSV est�o errados em todas as vers�es anteriores deste algoritmo!

% Dimens�es da imagem
dim = size(img);
qtnode = dim(1)*dim(2);
X = zeros(qtnode,9);
% primeiro e segundo elementos s�o linha e coluna normalizadas no intervalo 0:1
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
X = zscore(X) .* repmat(fw,qtnode,1);
% Converter imagem com r�tulos em vetor de r�tulos
slabelraw = reshape(imgslab,dim(1)*dim(2),1);
% montar vetor onde 0 � n� do fundo n�o considerado e 1 � n� v�lido
nodeval = zeros(qtnode,1);
nodeval(slabelraw~=0)=1;
% ajustar vetor de r�tulos
slabel = zeros(qtnode,1,'uint16');
slabel(slabelraw==0)=1; % fundo n�o considerado
slabel(slabelraw==64)=1;  % c/ r�tulo - fundo
otherlabels = [1:63 65:127 129:254];    
olfound = intersect(unique(slabelraw),otherlabels);
if isempty(olfound) % se n�o outros r�tulos, i.e., h� apenas duas classes
    nclass=2;
else % se h� mais r�tulos
    nclass=size(olfound,1)+2;
    for i=1:nclass-2
        slabel(slabelraw==olfound(i)) = i+1;
    end
end
slabel(slabelraw==255)=nclass; % c/ r�tulo - objeto
end