% Semi-Supervised Territory Mark Walk v.25
% Derivado de strwalk8.m (v.8k)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Vizinhança apenas entre os 8 vizinhos mais próximos (v.22)
% Arestas com peso proporcional à distância Euclidiana (v.22)
% Medida de distância considerando pesos (v.22)
% Sem partículas, cada pixel não rotulado pega colaboração dos vizinhos a
% cada iteração (v.25)
% Usage: [owner, pot] = strwalk25(img, imgslab, slabtype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image containing labels, each color is a different label
% slabtype  - 0 (default), 1 (Microsoft Research Cambridge images)
% valpha    - lower it to stop earlier, accuracy may be lower
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot       - final pertinence vectors of each node

function [owner, pot] = strwalk25(img, imgslab, slabtype, valpha, maxiter)
    if (nargin < 5) || isempty(maxiter),
        maxiter = 100000; % número de iterações
    end
    if (nargin < 4) || isempty(valpha),
        valpha = 20;
    end    
    if (nargin < 3) || isempty(slabtype),
        slabtype = 0;
    end        
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,6);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiros 3 elementos serão RGB normalizado em 0:1    
    X(:,1:3) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,4:6) = rgb2hsv(imgvec);   
    % normalizando as colunas
    X = zscore(X);
    % Converter imagem com rótulos em vetor de rótulos
    if slabtype==0 % cor mais clara (branco) é a não rotulada.
        slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);    
        labc=0;
        while max(slabel>labc)
            slabel(slabel==max(slabel)) = labc;
            labc = labc+1;
        end
        nclass = labc-1;        
    else % imagens do Microsoft Research Cambridge
        slabel = reshape(double(imgslab),dim(1)*dim(2),1);
        slabel(slabel==0)=1; % fundo
        slabel(slabel==64)=1;  % c/ rótulo - fundo
        slabel(slabel==255)=2; % c/ rótulo - objeto
        slabel(slabel==128)=0; % sem rótulo
        nclass = 2;
    end
    % Criar matriz de distância e lista de vizinhos
    % Índices estão no sentido horário do vetor de ligação
    Ndist = zeros(size(X,1),8);
    Nlist = zeros(size(X,1),8);
    Nsize = zeros(size(X,1),1);
    % Pesos das ligações horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);
            addNeighbor;
        end
    end
    % Peso das ligações diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            addNeighbor;    
        end
    end    
    % Peso das ligações verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            addNeighbor;        
        end
    end    
    % Peso das ligações diagonais (/)
    for i=1:dim(1)-1
        for j=2:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1-dim(1)+1;
            addNeighbor;       
        end
    end
    % Ajustando distâncias para intervalo 0 - 1 e invertendo (convertendo em peso de aresta);
    Ndist = 1 - Ndist/max(max(Ndist));
    % constantes
    npart = sum(slabel==0); % quantidade de nós não rotulados
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência    
    % lista de nós não rotulados
    partnode = find(slabel==0);
    % lista de nós rotulados
    labelednodes = find(slabel~=0);
    % ajustando todas as distâncias na máxima possível
    pot = repmat(1/nclass,qtnode,nclass);
    % zerando potenciais dos nós rotulados
    pot(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para máximo
    pot(sub2ind(size(pot),labelednodes,slabel(slabel~=0))) = 1;
    % variável para guardar máximo potencial mais alto médio
    % chamando o arquivo mex do strwalk24
    pot = strwalk25loop(maxiter, npart, nclass, stopmax, partnode, slabel, Nsize, Nlist, Ndist, pot);
    [~,owner] = max(pot,[],2);
    function addNeighbor
        Nsize(ind1) = Nsize(ind1) + 1;
        Nsize(ind2) = Nsize(ind2) + 1;
        Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
        Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
        Nlist(ind1,Nsize(ind1)) = ind2;
        Nlist(ind2,Nsize(ind2)) = ind1;
    end
end

