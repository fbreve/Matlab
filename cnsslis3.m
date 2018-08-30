% Complex Networks Semi-Supervised Learning Image Segmentation v3
% Trabalha na primeira fase com imagem redimensionada para um 1/9 do tamanho
% original. Inclui ExR, ExB, e ExG. Exclui desvios padr�es (v2)
% N�o inclui vizinhan�a rec�proca (v3)
% Usage: [owner, pot] = cnsslis(img, imgslab, k, fw, disttype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% fw        - vector of feature weights
% disttype  - use 'euclidean', etc.
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot     

function [owner, pot] = cnsslis3(img, imgslab, fw, k, disttype, valpha, maxiter)
if (nargin < 7) || isempty(maxiter)
    maxiter = 500000; % n�mero de itera��es
end
if (nargin < 6) || isempty(valpha)
    valpha = 2;
end
if (nargin < 5) || isempty(disttype)
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
if (nargin < 4) || isempty(k)
    k = 8; % quantidade de vizinhos mais pr�ximos
end
if (nargin < 3) || isempty(fw)
    fw = ones(1,20);
end
% tratamento da entrada
k = uint16(k);

if k>0
    % reduzindo imagem
    rs_img = imresize(img,1/3,'bilinear');
    rs_imgslab = imresize(imgslab,1/3,'nearest');
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
    KNN = uint32(knnsearch(Xval,Xval(indnonlabeled,:),'K',k+1,'NSMethod','kdtree','Distance',disttype));
    clear XVal;
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo

    % ajustando todas as dist�ncias na m�xima poss�vel
    potval = repmat(0.5,qtnodeval,nclass);   
    % zerando potenciais dos n�s rotulados
    potval(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para m�ximo
    potval(sub2ind(size(potval),labelednodes,slabelval(labelednodes))) = 1;
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    potval = cnsslis3loop(maxiter,nnonlabeled,indnonlabeled,stopmax,potval,k,KNN);
    clear KNN slabelval;
           
    pot = repmat([1 0],qtnode,1);
    pot(indval,:)=potval;
    
    clear potval;
end

[dim,qtnode,X,slabel,~,nclass] = getFeatures(img,imgslab,fw);
% Redimensionar matriz de potenciais
% (antes de redimensionar � preciso passar para matriz de 3 dimens�es e
% depois voltar para o formato anterior)
if k>0
    pot = reshape(imresize(reshape(pot,rs_dim(1),rs_dim(2),2),[dim(1) dim(2)],'bilinear'),qtnode,2);
else
    pot = repmat(0.5,qtnode,nclass);
end

% encontrando nos rotulados
labelednodes = find(slabel>0);
% zerando potenciais dos n�s rotulados
pot(labelednodes,:) = 0;
% ajustando potencial da classe respectiva do n� rotulado para 1
pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;

% PARTE 2!
%disp('Parte 2: Encontrando vizinhos...');
indefnodesb = max(pot,[],2)<0.9; % vetor onde 1 � n� indefinido e 0 � definido
indefnodes = uint32(find(indefnodesb)); % lista de n�s indefinidos
indefnodesc = size(indefnodes,1); % contagem de n�s indefinidos
if indefnodesc>0
    
    %fprintf('Parte 2: %i n�s indefinidos. Pegando colabora��o de pixels vizinhos\n',size(indefnodes,1))
    
    Ndist = zeros(size(X,1),8);
    Nlist = zeros(size(X,1),8,'uint32');
    Nsize = zeros(size(X,1),1,'uint8');
    % Pesos das liga��es horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das liga��es diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das liga��es verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das liga��es diagonais (/)
    for i=1:dim(1)-1
        for j=2:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1-dim(1)+1;
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    clear X;
    % Ajustando dist�ncias para intervalo 0 - 1 e invertendo (convertendo em peso de aresta);
    Ndist = 1 - Ndist/max(max(Ndist));
    % constantes
    npart = indefnodesc; % quantidade de n�s ainda n�o rotulados
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    % chamando o arquivo mex do strwalk25
    %disp('Parte 2: Propaga��o de r�tulos...');
    pot = strwalk25loop(maxiter, npart, nclass, stopmax, indefnodes, slabel, Nsize, Nlist, Ndist, pot);
end
[~,owner] = max(pot,[],2);

    function p2addNeighbor
        Nsize(ind1) = Nsize(ind1) + 1;
        Nsize(ind2) = Nsize(ind2) + 1;
        Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
        Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
        Nlist(ind1,Nsize(ind1)) = ind2;
        Nlist(ind2,Nsize(ind2)) = ind1;
    end

end

function [dim,qtnode,X,slabel,nodeval,nclass] = getFeatures(img,imgslab,fw)

% Aten��o: Atributo Linha e HSV est�o errados em todas as vers�es anteriores deste algoritmo!

% Dimens�es da imagem
dim = size(img);
qtnode = dim(1)*dim(2);
X = zeros(qtnode,20);
% primeiro e segundo elementos s�o linha e coluna normalizadas no intervalo 0:1
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
% m�dias
h = fspecial('average', [3 3]);
g = imfilter(img, h,'replicate'); % adicionado replicate para que bordas n�o fiquem diferentes
X(:,12:14) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
g = imfilter(imghsv, h, 'replicate'); % adicionado replicate para que bordas n�o fiquem diferentes)
X(:,15:17) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
g = imfilter(imgex, h, 'replicate'); % adicionado replicate para que bordas n�o fiquem diferentes)
X(:,18:20) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
clear g imghsv imgex;
% s = stdfilt(img);
% X(:,18:20) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)))/255;
% s = stdfilt(rgb2hsv(img));
% X(:,21:23) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)));
% clear s;
% normalizando as colunas
X = zscore(X) .* repmat(fw,qtnode,1);
% Converter imagem com r�tulos em vetor de r�tulos
slabel = uint16(reshape(imgslab,dim(1)*dim(2),1));
% montar vetor onde 0 � n� do fundo n�o considerado e 1 � n� v�lido
nodeval = zeros(qtnode,1);
nodeval(slabel~=0)=1;
% ajustar vetor de r�tulos
slabel(slabel==0)=1; % fundo n�o considerado
slabel(slabel==64)=1;  % c/ r�tulo - fundo
slabel(slabel==255)=2; % c/ r�tulo - objeto
slabel(slabel==128)=0; % sem r�tulo
nclass = 2;
end