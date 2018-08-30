% Semi-Supervised Territory Mark Walk v.36
% Derivado de strwalk8.m (v.8)
% Distância medida com k-vizinhos (v.8k)
% Tabela de distâncias do time (v.26)
% Ajuste final com colaboração de vizinhos (v.28)
% Vetor para escalar cada entrada (v.29)
% Trabalha na primeira fase com imagem redimensionada para 1/9 do tamanho
% original. Traz de volta a tabela de distâncias individual. Inclui ExR, ExB, e ExG.
% Exclui desvios padrões (v.35)
% Incorpora mudanças de cnsslis9 (v36)
%
% Usage: [owner, owner2, pot, owndeg] = strwalk35(img, imgslab, fw, k, disttype, valpha, pgrd, deltav, deltap, dexp, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% disttype  - use 'euclidean', 'seuclidean', etc.
% texture   - 0 - do not use texture information; 1 - use texture information
% valpha    - Default: 2000 (lower it to stop earlier, accuracy may be lower)
% pgrd      - check p_grd in [1]
% deltav    - check delta_v in [1]
% deltap    - Default: 1 (leave it on default to match equations in [1])
% dexp      - Default: 2 (leave it on default to match equations in [1])
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% owndeg    - fuzzy output as in [2], each line is a data item, each column pertinence to a class
%
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gonçalves; Pedrycz, Witold; Liu, Jiming,
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning,"
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang.
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [owner, pot, owndeg] = strwalk36(img, imgslab, fw, k, disttype, valpha, pgrd, deltav, deltap, dexp, maxiter)
if (nargin < 11) || isempty(maxiter)
    maxiter = 500000; % número de iterações
end
if (nargin < 10) || isempty(dexp)
    dexp = 2; % exponencial de probabilidade
end
if (nargin < 9) || isempty(deltap)
    deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
end
if (nargin < 8) || isempty(deltav)
    deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
end
if (nargin < 7) || isempty(pgrd)
    pgrd = 0.500; % probabilidade de não explorar
end
if (nargin < 6) || isempty(valpha)
    valpha = 2;
end
if (nargin < 5) || isempty(disttype)
    disttype = 'euclidean'; % distância euclidiana não normalizada
end
if (nargin < 4) || isempty(k)
    k = 8; % quantidade de vizinhos mais próximos
end
if (nargin < 3) || isempty(fw)
    fw = [1 1 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
    %fw = ones(1,9);
end
% tratamento da entrada
k = uint16(k);

% constantes
potmax = 1.000; % potencial máximo
potmin = 0.000; % potencial mínimo
sigma = 0.5;

if k>0
    % reduzindo imagem
    rs_img = imresize(img,1/3,'bicubic');
    otherlabels = [1:63 65:127 129:254];
    if isempty(intersect(unique(imgslab),otherlabels)) % se há apenas duas classes
        rs_imgslab = imresize(imgslab,1/3,'bilinear');
        rs_imgslab(rs_imgslab<64 & rs_imgslab>0) = 64;
        rs_imgslab(rs_imgslab<128 & rs_imgslab>64) = 64;
        rs_imgslab(rs_imgslab>128) = 255;
    else % mais de duas classes
        rs_imgslab = imresize(imgslab,1/3,'nearest');
    end
    
    [rs_dim,qtnode,X,slabel,nodeval,nclass] = getFeatures(rs_img,rs_imgslab,fw);
    
    %disp('Parte 1: Criando vizinhança...')
    % já estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
    
    indval = find(nodeval);
    Xval = X(indval,:);
    qtnodeval = size(indval,1);
    slabelval = slabel(indval);
    
    npart = sum(slabelval>0); % quantidade de partículas
    
    stopmax = round((qtnodeval/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência
    
    % encontrando k-vizinhos mais próximos
    %disp('Encontrando k-vizinhos mais próximos...')
    KNN = uint32(knnsearch(Xval,Xval,'K',k+1,'NSMethod','kdtree','Distance',disttype));
    clear XVal;
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo
    KNN(:,end+1:end+k) = 0; % adicionando mais k espaços para vizinhança recíproca
    knns = repmat(k,qtnodeval,1); % vetor com a quantidade de vizinhos de cada nó
    for i=1:qtnodeval
        %KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        KNN(sub2ind(size(KNN),KNN(i,1:k),(knns(KNN(i,1:k))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,1:k))=knns(KNN(i,1:k))+1; % aumentando contador de vizinhos nos nós que tiveram vizinhos adicionados
        if max(knns)==size(KNN,2) % se algum nó atingiu o limite de colunas da matriz de vizinhança recíproca teremos de aumentá-la
            % portanto vamos aumenta-la em 10% + 1 (para garantir no caso do tamanho ser menor que 10)
            % convém que o aumento seja de várias colunas de uma vez, pois
            % é uma operação custosa, mas não muitas para não ocupar muita
            % memória
            KNN(:,max(knns)+1:round(max(knns)*1.1)+1) = zeros(qtnodeval,round(max(knns)*0.1)+1);
        end
    end
    % removendo duplicatas
    for i=1:qtnodeval
        knnrow = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN
    end
    clear knnrow;
    KNN = KNN(:,1:max(knns)); % eliminando colunas que não tem vizinhos válidos
    %disp('Caminhando com as partículas...')
    % definindo classe de cada partícula
    partclass = slabelval(slabelval>0);
    % definindo nó casa da partícul
    partnode = uint32(find(slabelval>0));
    % definindo potencial da partícula em 1
    potpart = repmat(potmax,npart,1);
    % ajustando todas as distâncias na máxima possível
    distnode = repmat(min(intmax('uint8'),uint8(qtnodeval-1)),qtnodeval,npart);
    % ajustando para zero a distância de cada partícula para seu
    % respectivo nó casa
    distnode(sub2ind(size(distnode),partnode',1:npart)) = 0;
    % inicializando tabela de potenciais com tudo igual
    potval = repmat(potmax/nclass,qtnodeval,nclass);
    % zerando potenciais dos nós rotulados
    potval(partnode,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1
    potval(sub2ind(size(potval),partnode,slabelval(partnode))) = 1;
    owndeg = repmat(realmin,qtnodeval,nclass);
    %disp('Parte 1: Partículas caminhando...')
    [potval, owndeg] = strwalk8kloop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partnode, partclass, potpart, slabelval, knns, distnode, KNN, potval, owndeg);
    clear KNN distnode slabelval;
    
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
    
    pot = repmat([1 0],qtnode,1);
    pot(indval,:)=potval;
    
    clear potval ownerval;
end

[dim,qtnode,X,slabel,nodeval,nclass] = getFeatures(img,imgslab,fw);
% Redimensionar matriz de potenciais
% (antes de redimensionar é preciso passar para matriz de 3 dimensões e
% depois voltar para o formato anterior)
if k>0
    pot = reshape(imresize(reshape(pot,rs_dim(1),rs_dim(2),nclass),[dim(1) dim(2)],'bilinear'),qtnode,nclass);
else
    pot = repmat(1/nclass,qtnode,nclass);
end

% encontrando nos rotulados
labelednodes = find(slabel>0);
% zerando potenciais dos nós rotulados
pot(labelednodes,:) = 0;
% ajustando potencial da classe respectiva do nó rotulado para 1
pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;

% PARTE 2!
%disp('Parte 2: Encontrando vizinhos...');
if k>0
    indefnodesb = max(pot,[],2) < 1; % vetor onde 1 é nó indefinido e 0 é definido
else
    indefnodesb = nodeval;
end
indefnodes = uint32(find(indefnodesb)); % lista de nós indefinidos
indefnodesc = size(indefnodes,1); % contagem de nós indefinidos

if indefnodesc>0
    
    %fprintf('Parte 2: %i nós indefinidos. Pegando colaboração de pixels vizinhos\n',size(indefnodes,1))
    
    Ndist = zeros(size(X,1),8);
    Nlist = zeros(size(X,1),8,'uint32');
    Nsize = zeros(size(X,1),1,'uint8');
    % Pesos das ligações horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das ligações diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das ligações verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            if indefnodesb(ind1) || indefnodesb(ind2)
                p2addNeighbor;
            end
        end
    end
    % Peso das ligações diagonais (/)
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
    % aplicando Gaussiana nas distâncias
    Ndist = exp((-Ndist.^2)./(2*sigma^2));
    % constantes
    npart = indefnodesc; % quantidade de nós ainda não rotulados
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência
    % variável para guardar máximo potencial mais alto médio
    % chamando o arquivo mex do strwalk25
    %disp('Parte 2: Propagação de rótulos...');
    pot = strwalk25loop(maxiter, npart, nclass, stopmax, indefnodes, slabel, Nsize, Nlist, Ndist, pot);
    
    if k==0
        % zerando potenciais dos nós rotulados
        pot(labelednodes,:) = 0;
        % ajustando potencial da classe respectiva do nó rotulado para 1
        pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;
    end
    
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

% Atenção: Atributo Linha e HSV estão errados em todas as versões anteriores deste algoritmo!

% Dimensões da imagem
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
X = zscore(X) .* repmat(fw,qtnode,1);
% Converter imagem com rótulos em vetor de rótulos
slabelraw = reshape(imgslab,dim(1)*dim(2),1);
% montar vetor onde 0 é nó do fundo não considerado e 1 é nó válido
nodeval = zeros(qtnode,1);
nodeval(slabelraw~=0)=1;
% ajustar vetor de rótulos
slabel = zeros(qtnode,1,'uint16');
slabel(slabelraw==0)=1; % fundo não considerado
slabel(slabelraw==64)=1;  % c/ rótulo - fundo
otherlabels = [1:63 65:127 129:254];
olfound = intersect(unique(slabelraw),otherlabels);
if isempty(olfound) % se não outros rótulos, i.e., há apenas duas classes
    nclass=2;
else % se há mais rótulos
    nclass=size(olfound,1)+2;
    for i=1:nclass-2
        slabel(slabelraw==olfound(i)) = i+1;
    end
end
slabel(slabelraw==255)=nclass; % c/ rótulo - objeto
end