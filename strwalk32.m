% Semi-Supervised Territory Mark Walk v.32
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Tabela de distâncias do time (v.26)
% Ajuste final com colaboração de vizinhos (v.28)
% Vetor para escalar cada entrada (v.29)
% Vetor de escala criado automaticamente. ExR, ExG, ExB incluídos. (v.30)
% Aceita vetor de escala (v.32)
% Versão utilizada no artigo ICCSA2017
% Usage: [owner, owner2, potval, owndeg] = strwalk32(img, imgslab, k, fw, disttype, valpha, pgrd, deltav, deltap, dexp, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% fw        - vector of feature weights
% disttype  - use 'euclidean', 'seuclidean', etc.
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
% pgrd      - check p_grd in [1]
% deltav    - check delta_v in [1]
% deltap    - Default: 1 (leave it on default to match equations in [1])
% dexp      - Default: 2 (leave it on default to match equations in [1])
% nclass    - amount of classes on the problem
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
function [owner, owner2, potval, owndeg] = strwalk32(img, imgslab, k, fw, disttype, valpha, pgrd, deltav, deltap, dexp, maxiter)
    if (nargin < 11) || isempty(maxiter),
        maxiter = 500000; % número de iterações
    end
    if (nargin < 10) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 9) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 8) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 7) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de não explorar
    end
    if (nargin < 6) || isempty(valpha),
        valpha = 20;
    end      
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % distância euclidiana não normalizada
    end
    if (nargin < 4) || isempty(fw),
        fw = ones(1,23); % quantidade de vizinhos mais próximos
    end      
    if (nargin < 3) || isempty(k),
        k = 8; % quantidade de vizinhos mais próximos
    end
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,23);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiro e segundo elementos são as dimensões X e Y normalizadas no intervalo 0:1
    X(:,1:2) = [repmat(((1:dim(1))/dim(1))',dim(2),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)]; %CORRIGIDO!      
    % depois vem os 3 elementos RGB normalizados em 0:1    
    X(:,3:5) = imgvec;    
    % depois vem os 3 elementos HSV  CORRIGIDO!!
    imghsv = rgb2hsv(double(img)/255);
    X(:,6:8) = squeeze(reshape(imghsv,dim(1)*dim(2),1,3));    % corrigido!   
    % em seguida ExR, ExG, e ExB
    exr = 2.*double(img(:,:,1)) - double(img(:,:,2)) - double(img(:,:,3));
    exg = 2.*double(img(:,:,2)) - double(img(:,:,1)) - double(img(:,:,3));
    exb = 2.*double(img(:,:,3)) - double(img(:,:,1)) - double(img(:,:,2));
    imgex = cat(3, exr, exg, exb);
    clear exr exg exb;
    X(:,9:11) = squeeze(reshape(imgex,dim(1)*dim(2),1,3));
    % médias e desvios padrão de RGB e HSV
    h = fspecial('average', [3 3]);
    g = imfilter(img, h, 'replicate');
    j = stdfilt(img);
    X(:,12:14) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
    X(:,15:17) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)))/255;
    g = imfilter(imghsv, h, 'replicate');
    j = stdfilt(imghsv);
    X(:,18:20) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
    X(:,21:23) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)));
    % normalizando as colunas
    X = zscore(X) .* repmat(fw,qtnode,1);       
    
    slabel = reshape(double(imgslab),dim(1)*dim(2),1);
    slabel(slabel==0)=-1; % fundo
    slabel(slabel==64)=1;  % c/ rótulo - fundo
    slabel(slabel==255)=2; % c/ rótulo - objeto
    slabel(slabel==128)=0; % sem rótulo
    nclass = 2;

    indval = find(slabel>=0);  % pega só os índices dos pixels que não são do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels válidos (que não são do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de nós válidos (pixels válidos)
    slabelval = slabel(indval); % rótulos dos pixels válidos (não são do fundo ignorado)    
    
    %disp('Criando vizinhança...')
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    npart = sum(slabel>0); % quantidade de partículas (apenas nós rotulados e que não são do fundo ignorado)
    % já estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
   
    stopmax = round((qtnodeval/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência        
    
    % encontrando k-vizinhos mais próximos
    %disp('Encontrando k-vizinhos mais próximos...')
    KNN = knnsearch(Xval,Xval,'K',k+1,'NSMethod','kdtree','Distance',disttype);
    %KNN = knnsearch(X,X,'K',k+1,'Distance',disttype);
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo    
    %disp('Criando reciprocidade entre vizinhos...')    
    KNNR = zeros(qtnodeval,k); % criando matriz para vizinhança recíproca, inicialmente com tamanho k
    knns = zeros(qtnodeval,1); % vetor com a quantidade de vizinhos recíprocos de cada nó
    for i=1:qtnodeval
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos nós que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum nó atingiu o limite de colunas da matriz de vizinhança recíproca teremos de aumentá-la
            KNNR(:,max(knns)+1:max(knns)*2) = zeros(qtnodeval,max(knns));  % portanto vamos dobrá-la
        end
    end
    KNN = [KNN KNNR];
    clear KNNR;
    % removendo duplicatas    
    for i=1:qtnodeval
        knnrow = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN 
        KNN(i,knns(i)+1:end)=0; % preenche restante com zero
    end
    KNN = KNN(:,1:max(knns)); % eliminando colunas que não tem vizinhos válidos
      
    %disp('Caminhando com as partículas...')
    % definindo classe de cada partícula
    partclass = slabelval(slabelval>0);
    % definindo nó casa da partícula
    partnode = find(slabelval>0);
    % definindo potencial da partícula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as distâncias na máxima possível
    distnode = repmat(qtnodeval-1,qtnodeval,nclass);      
    % ajustando para zero a distância de cada partícula para seu
    % respectivo nó casa
    distnode(sub2ind(size(distnode),partnode,partclass)) = 0;    
    % inicializando tabela de potenciais com tudo igual
    potval = repmat(potmax/nclass,qtnodeval,nclass);
    % zerando potenciais dos nós rotulados
    potval(partnode,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1
    potval(sub2ind(size(potval),partnode,slabelval(partnode))) = 1;
    % colocando cada nó em sua casa
    partpos = partnode;           
    owndeg = repmat(realmin,qtnodeval,nclass);
    [potval, owndeg] = strwalk26loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabelval, knns, distnode, KNN, potval, owndeg);
    [~,ownerval] = max(potval,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);

    owner = slabel;
    owner(owner==-1)=1;
    pot = repmat([1 0],qtnode,1);
    owner(indval)=ownerval;
    
    pot(indval,:)=potval;
    owner2 = owner;
    
    % PARTE 2!
    indefnodes = uint32(find(max(pot,[],2)<0.9));
    indefnodesc = size(indefnodes,1);
    if indefnodesc>0
        
        %disp(sprintf('%i nós indefinidos. Pegando colaboração de pixels vizinhos',size(indefnodes,1)))
        
        Ndist = zeros(size(X,1),8);
        Nlist = zeros(size(X,1),8,'uint32');
        Nsize = zeros(size(X,1),1,'uint8');
        % Pesos das ligações horizontais
        for i=1:dim(1)
            for j=1:dim(2)-1
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1 + dim(1);
                p2addNeighbor;
            end
        end
        % Peso das ligações diagonais (\)
        for i=1:dim(1)-1
            for j=1:dim(2)-1
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1+dim(1)+1;
                p2addNeighbor;
            end
        end
        % Peso das ligações verticais
        for i=1:dim(1)-1
            for j=1:dim(2)
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1+1;
                p2addNeighbor;
            end
        end
        % Peso das ligações diagonais (/)
        for i=1:dim(1)-1
            for j=2:dim(2)
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1-dim(1)+1;
                p2addNeighbor;
            end
        end
        % Ajustando distâncias para intervalo 0 - 1 e invertendo (convertendo em peso de aresta);
        Ndist = 1 - Ndist/max(max(Ndist));
        % constantes
        npart = indefnodesc; % quantidade de nós ainda não rotulados
        stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência
        % lista de nós não rotulados
        partnode = indefnodes;
        % variável para guardar máximo potencial mais alto médio
        % chamando o arquivo mex do strwalk24
        pot = strwalk25loop(maxiter, npart, nclass, stopmax, uint32(partnode), uint16(slabel), uint8(Nsize), uint32(Nlist), Ndist, pot);
        [~,owner] = max(pot,[],2);
    end
    
    function p2addNeighbor
        Nsize(ind1) = Nsize(ind1) + 1;
        Nsize(ind2) = Nsize(ind2) + 1;
        Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
        Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
        Nlist(ind1,Nsize(ind1)) = ind2;
        Nlist(ind2,Nsize(ind2)) = ind1;
    end

end

