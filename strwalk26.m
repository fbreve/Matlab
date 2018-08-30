% Semi-Supervised Territory Mark Walk v.8k
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Tabela de distâncias do time (v.26)
% Usage: [owner, pot, owndeg] = strwalk26mex(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
% INPUT:
% X         - Matrix where each line is a data item and each column is an attribute
% slabel    - vector where each element is the label of the corresponding
%             data item in X (use 1,2,3,... for labeled data items and 0
%             for unlabeled data items)
% k         - each node is connected to its k-neirest neighbors
% disttype  - use 'euclidean', 'seuclidean', etc.
% valpha    - Default: 2000 (lower it to stop earlier, accuracy may be lower)
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
function [owner, pot, owndeg] = strwalk26(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
    if (nargin < 11) || isempty(maxiter),
        maxiter = 500000; % número de iterações
    end
    if (nargin < 10) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 9) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 8) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 7) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 6) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de não explorar
    end
    if (nargin < 5) || isempty(valpha),
        valpha = 20;
    end    
    if (nargin < 4) || isempty(disttype),
        disttype = 'euclidean'; % distância euclidiana não normalizada
    end    
    qtnode = size(X,1); % quantidade de nós
    if (nargin < 3) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais próximos
    end       
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    npart = sum(slabel~=0); % quantidade de partículas
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência    
    % normalizar atributos se necessário
    if strcmp(disttype,'seuclidean')==1
        X = zscore(X);
        disttype='euclidean';
    end
    % encontrando k-vizinhos mais próximos      
    disp('Encontrando k-vizinhos mais próximos...')
    KNN = knnsearch(X,X,'K',k+1,'NSMethod','kdtree','Distance',disttype);
    %KNN = knnsearch(X,X,'K',k+1,'Distance',disttype);
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo    
    disp('Criando reciprocidade entre vizinhos...')    
    KNNR = zeros(qtnode,k); % criando matriz para vizinhança recíproca, inicialmente com tamanho k
    knns = zeros(qtnode,1); % vetor com a quantidade de vizinhos recíprocos de cada nó
    for i=1:qtnode
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos nós que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum nó atingiu o limite de colunas da matriz de vizinhança recíproca teremos de aumentá-la
            KNNR(:,max(knns)+1:max(knns)*2) = zeros(qtnode,max(knns));  % portanto vamos dobrá-la
        end
    end
    KNN = [KNN KNNR];
    clear KNNR;
    % removendo duplicatas    
    for i=1:qtnode
        knnrow = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN e preenche restante com zero
    end
    KNN = KNN(:,1:max(knns)); % eliminando colunas que não tem vizinhos válidos
    disp('Caminhando com as partículas...')
    % definindo classe de cada partícula
    partclass = slabel(slabel~=0);
    % definindo nó casa da partícula
    partnode = find(slabel);
    % definindo potencial da partícula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as distâncias na máxima possível
    distnode = repmat(qtnode-1,qtnode,nclass);      
    % ajustando para zero a distância de cada partícula para seu
    % respectivo nó casa
    distnode(sub2ind(size(distnode),partnode,partclass)) = 0;    
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos nós rotulados
    pot(partnode,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1
    pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
    % colocando cada nó em sua casa
    partpos = partnode;           
    owndeg = repmat(realmin,qtnode,nclass);
    [pot, owndeg] = strwalk26loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabel, knns, distnode, KNN, pot, owndeg);
    [~,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);         
end

