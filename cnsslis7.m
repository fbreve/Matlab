% Complex Networks Semi-Supervised Learning Image Segmentation v7
% Trabalha na primeira fase com imagem redimensionada para um 1/9 do tamanho
% original. Inclui ExR, ExB, e ExG. Exclui desvios padr�es (v2)
% N�o inclui vizinhan�a rec�proca (v3)
% Peso maior conforme a posi��o na lista de vizinhos mais pr�ximos (v4)
% Peso do vizinho de acordo com a Dist�ncia Euclidiana (v5)
% Mudan�as no c�lculo de dist�ncia da segunda fase (v5)
% fase intermedi�ria com imagem em tamanho real (v7)
% Usage: [owner, pot] = cnsslis5(img, imgslab, fw, k, disttype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% fw        - vector of feature weights
% k1         - each node is connected to its k-neirest neighbors (first phase)
% k2         - each node is connected to its k-neirest neighbors (second phase)
% disttype  - use 'euclidean', etc.
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot     

function [owner, pot] = cnsslis7(img, imgslab, fw, k1, k2, disttype, valpha, maxiter)
if (nargin < 8) || isempty(maxiter)
    maxiter = 500000; % n�mero de itera��es
end
if (nargin < 7) || isempty(valpha)
    valpha = 2;
end
if (nargin < 6) || isempty(disttype)
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
if (nargin < 5) || isempty(k2)
    k2 = 8; % quantidade de vizinhos mais pr�ximos
end
if (nargin < 4) || isempty(k1)
    k1 = 8; % quantidade de vizinhos mais pr�ximos
end
if (nargin < 3) || isempty(fw)
    fw = ones(1,20);
end
% tratamento da entrada
k1 = uint16(k1);
k2 = uint16(k2);

    % j� estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end       
    
if k1>0
    % reduzindo imagem
    rs_img = imresize(img,1/3,'bilinear');
    rs_imgslab = imresize(imgslab,1/3,'nearest');
    [rs_dim,qtnode,X,slabel,nodeval] = getFeatures(rs_img,rs_imgslab,fw);
    pot = lp(1,qtnode,X,slabel,nodeval,k1,disttype,valpha,maxiter,[]);
    % Redimensionar matriz de potenciais
    % (antes de redimensionar � preciso passar para matriz de 3 dimens�es e
    % depois voltar para o formato anterior)        
end
[dim,qtnode,X,slabel,nodeval] = getFeatures(img,imgslab,fw);
if k2>0
    if k1>0
        pot = reshape(imresize(reshape(pot,rs_dim(1),rs_dim(2),2),[dim(1) dim(2)],'bilinear'),qtnode,2);
        pot = lp(2,qtnode,X,slabel,nodeval,k2,disttype,valpha,maxiter,pot);
    else
        % se a primeira fase foi pulada, n�o h� um conjunto pot criado,
        % ent�o a chamada � igual a de primeira fase
        pot = lp(1,qtnode,X,slabel,nodeval,k2,disttype,valpha,maxiter,[]);
    end
end

% terceira fase (antiga segunda)

% se duas fases anteriores n�o foram rodadas, precisamos criar pot
if (k1==0 && k2==0)
    pot = repmat(0.5,qtnode,nclass);    
elseif k2==0 % se apenas segunda fase n�o foi rodada, precisamos redimensionar pot
    pot = reshape(imresize(reshape(pot,rs_dim(1),rs_dim(2),2),[dim(1) dim(2)],'bilinear'),qtnode,2);
end
% se segunda fase n�o foi rodada, precisamos ajustar pot dos n�s rotulados
if k2==0 
    % encontrando nos rotulados
    labelednodes = find(slabel>0);
    % zerando potenciais dos n�s rotulados
    pot(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;
end

% PARTE 3
indefnodesb = max(pot,[],2)<0.99; % vetor onde 1 � n� indefinido e 0 � definido
indefnodes = uint32(find(indefnodesb)); % lista de n�s indefinidos
indefnodesc = size(indefnodes,1); % contagem de n�s indefinidos
if indefnodesc>0       
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
    Ndist = 1./(1+Ndist);
    % constantes
    npart = indefnodesc; % quantidade de n�s ainda n�o rotulados
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    % chamando o arquivo mex do strwalk25
    %disp('Parte 2: Propaga��o de r�tulos...');
    pot = strwalk25loop(maxiter, npart, 2, stopmax, indefnodes, slabel, Nsize, Nlist, Ndist, pot);
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


function pot = lp(phase,qtnode,X,slabel,nodeval,k,disttype,valpha,maxiter,pot)
    indval = find(nodeval);     % pega s� os �ndices dos pixels que n�o s�o do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels v�lidos (que n�o s�o do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de n�s v�lidos (pixels v�lidos)
    slabelval = slabel(indval); % r�tulos dos pixels v�lidos (n�o s�o do fundo ignorado)          
    % lista de n�s n�o rotulados
    if phase==1        
        potval = repmat(0.5,qtnodeval,2);
        indnonlabeled = uint32(find(slabelval==0));        
    else
        % se estamos na segunda fase vamos tratar apenas os n�s indecisos
        potval = pot(indval,:);
        indnonlabeled = uint32(find(slabelval==0 & max(potval,[],2)<0.99));
    end
    nnonlabeled = size(indnonlabeled,1); % quantidade de n�s n�o rotulados   
    % lista de n�s rotulados
    labelednodes = uint32(find(slabelval>0));
    stopmax = round((qtnodeval/nnonlabeled)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
    
    % encontrando k-vizinhos mais pr�ximos
    [KNN,KNND] = knnsearch(Xval,Xval(indnonlabeled,:),'K',k+1,'NSMethod','kdtree','Distance',disttype);
    KNN = uint32(KNN);
    clear XVal;
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo
    KNND = KNND(:,2:end); 
    KNND = 1./(1+KNND);
   % zerando potenciais dos n�s rotulados
    potval(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para m�ximo
    potval(sub2ind(size(potval),labelednodes,slabelval(labelednodes))) = 1;
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    potval = cnsslis5loop(maxiter,nnonlabeled,indnonlabeled,stopmax,potval,k,KNN,KNND);
    clear KNN slabelval KNNND;
           
    pot = repmat([1 0],qtnode,1);
    pot(indval,:)=potval;
    
    clear potval;
end

function [dim,qtnode,X,slabel,nodeval] = getFeatures(img,imgslab,fw)

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
end
