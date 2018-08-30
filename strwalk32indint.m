% Semi-Supervised Territory Mark Walk v.30
% Derivado de strwalk8.m (v.8)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Tabela de dist�ncias do time (v.26)
% Ajuste final com colabora��o de vizinhos (v.28)
% Vetor para escalar cada entrada (v.29)
% Vetor de escala criado automaticamente. ExR, ExG, ExB inclu�dos. (v.30)
% Contar vizinhan�a intra-classe e inter-classe (v.32indint)
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
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gon�alves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [indint,KNN,knns,X] = strwalk32indint(img, imgslab, k, fw, disttype)
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    if (nargin < 4) || isempty(fw),
        fw = ones(1,23); % quantidade de vizinhos mais pr�ximos
    end    
    if (nargin < 3) || isempty(k),
        k = 8; % quantidade de vizinhos mais pr�ximos
    end
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,6);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiro e segundo elementos s�o as dimens�es X e Y normalizadas no intervalo 0:1
    X(:,1:2) = [repmat(((1:dim(2))/dim(2))',dim(1),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)];        
    % depois vem os 3 elementos RGB normalizados em 0:1    
    X(:,3:5) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,6:8) = rgb2hsv(imgvec);   
    % em seguida ExR, ExG, e ExB
    X(:,9) = X(:,3).*2 - X(:,4) - X(:,5);
    X(:,10) = X(:,4).*2 - X(:,3) - X(:,5);
    X(:,11) = X(:,5).*2 - X(:,3) - X(:,4);
    % m�dias e desvios padr�o de RGB e HSV
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
    slabel(slabel==64)=1;  % c/ r�tulo - fundo
    slabel(slabel==255)=2; % c/ r�tulo - objeto
    slabel(slabel==128)=0; % sem r�tulo

    indval = find(slabel>=0);  % pega s� os �ndices dos pixels que n�o s�o do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels v�lidos (que n�o s�o do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de n�s v�lidos (pixels v�lidos)
    slabelval = slabel(indval); % r�tulos dos pixels v�lidos (n�o s�o do fundo ignorado)    
          
    % j� estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
     
    % encontrando k-vizinhos mais pr�ximos
    %disp('Encontrando k-vizinhos mais pr�ximos...')
    KNN = knnsearch(Xval,Xval,'K',k+1,'NSMethod','kdtree','Distance',disttype);
    %KNN = knnsearch(X,X,'K',k+1,'Distance',disttype);
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo    
    %disp('Criando reciprocidade entre vizinhos...')    
    KNNR = zeros(qtnodeval,k); % criando matriz para vizinhan�a rec�proca, inicialmente com tamanho k
    knns = zeros(qtnodeval,1); % vetor com a quantidade de vizinhos rec�procos de cada n�
    for i=1:qtnodeval
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos n�s que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum n� atingiu o limite de colunas da matriz de vizinhan�a rec�proca teremos de aument�-la
            KNNR(:,max(knns)+1:max(knns)*2) = zeros(qtnodeval,max(knns));  % portanto vamos dobr�-la
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
    KNN = KNN(:,1:max(knns)); % eliminando colunas que n�o tem vizinhos v�lidos
    
    %intrac=0;
    %interc=0;
    
    %for i=1:qtnodeval
        %if slabelval(i)>0
        %    intrac = intrac + sum(slabelval(KNN(i,1:knns(i)))==slabelval(i));
        %    interc = interc + sum((slabelval(KNN(i,1:knns(i)))~=slabelval(i)) & slabelval(KNN(i,1:knns(i)))>0);
        %end
    %end    
    %indint = (intrac / (intrac+interc))^2;
    
    totedgnotlab = 0; % contador de arestas em n�s n�o rotulados
    labeqnotlab = 0;  % contador de desequil�brio nas arestas com n�s rotulados nos n�s n�o rotulados
    
    for i=1:qtnodeval
        if slabelval(i)==0
            totedgnotlab = totedgnotlab + knns(i);
            labeqnotlab = labeqnotlab + abs(sum(slabelval(KNN(i,1:knns(i)))==1)-sum(slabelval(KNN(i,1:knns(i)))==2));
        end
    end
    
    indint = labeqnotlab / totedgnotlab;
    
end

