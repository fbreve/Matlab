% Semi-Supervised Territory Mark Walk v.30
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
% Contar vizinhança intra-classe e inter-classe (v.32indint)
% Usage: [indint,KNN,knns,X] = strwalk32indint(img, imgslab, k, fw, disttype)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% fw        - vector of feature weights
% disttype  - use 'euclidean', 'seuclidean', etc.
% OUTPUT:
% indint    - indice of intraclass edges / total edges among a pair of 
%             labeled nodes [0 1]
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gonçalves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [indint,KNN,knns,X] = strwalk32indint(img, imgslab, k, fw, disttype)
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
    X = zeros(qtnode,6);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiro e segundo elementos são as dimensões X e Y normalizadas no intervalo 0:1
    X(:,1:2) = [repmat(((1:dim(2))/dim(2))',dim(1),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)];        
    % depois vem os 3 elementos RGB normalizados em 0:1    
    X(:,3:5) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,6:8) = rgb2hsv(imgvec);   
    % em seguida ExR, ExG, e ExB
    X(:,9) = X(:,3).*2 - X(:,4) - X(:,5);
    X(:,10) = X(:,4).*2 - X(:,3) - X(:,5);
    X(:,11) = X(:,5).*2 - X(:,3) - X(:,4);
    % médias e desvios padrão de RGB e HSV
    h = fspecial('average', [3 3]);
    g = imfilter(img, h);
    j = stdfilt(img);
    X(:,12:14) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
    X(:,15:17) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)))/255;
    g = imfilter(rgb2hsv(img), h);
    j = stdfilt(rgb2hsv(img));
    X(:,18:20) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
    X(:,21:23) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)));
    % normalizando as colunas
    X = zscore(X) .* repmat(fw,qtnode,1);
    
    slabel = reshape(double(imgslab),dim(1)*dim(2),1);
    slabel(slabel==0)=-1; % fundo
    slabel(slabel==64)=1;  % c/ rótulo - fundo
    slabel(slabel==255)=2; % c/ rótulo - objeto
    slabel(slabel==128)=0; % sem rótulo

    indval = find(slabel>=0);  % pega só os índices dos pixels que não são do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels válidos (que não são do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de nós válidos (pixels válidos)
    slabelval = slabel(indval); % rótulos dos pixels válidos (não são do fundo ignorado)    
          
    % já estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
     
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
    
    %intrac=0;
    %interc=0;
    
    %for i=1:qtnodeval
        %if slabelval(i)>0
        %    intrac = intrac + sum(slabelval(KNN(i,1:knns(i)))==slabelval(i));
        %    interc = interc + sum((slabelval(KNN(i,1:knns(i)))~=slabelval(i)) & slabelval(KNN(i,1:knns(i)))>0);
        %end
    %end    
    %indint = (intrac / (intrac+interc))^2;
    
    totedgnotlab = 0; % contador de arestas em nós não rotulados
    labeqnotlab = 0;  % contador de desequilíbrio nas arestas com nós rotulados nos nós não rotulados
    
    for i=1:qtnodeval
        if slabelval(i)==0
            totedgnotlab = totedgnotlab + knns(i);
            labeqnotlab = labeqnotlab + abs(sum(slabelval(KNN(i,1:knns(i)))==1)-sum(slabelval(KNN(i,1:knns(i)))==2));
        end
    end
    
    indint = labeqnotlab / totedgnotlab;
    
end

