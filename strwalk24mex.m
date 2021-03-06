% Semi-Supervised Territory Mark Walk v.8k
% Derivado de strwalk8.m (v.8)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Sem part�culas, n�s n�o-rotulados pegam colabora��o dos vizinhos a cada itera��o (v.23)
% Colabora��o dos vizinhos ponderada
% Usage: [owner, pot, owndeg, distnode] = strwalk8k(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
% INPUT:
% X         - Matrix where each line is a data item and each column is an attribute
% slabel    - vector where each element is the label of the corresponding
%             data item in X (use 1,2,3,... for labeled data items and 0
%             for unlabeled data items)
% k         - each node is connected to its k-neirest neighbors
% disttype  - use 'euclidean', 'seuclidean', etc.
% valpha    - lower it to stop earlier, accuracy may be lower
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
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gon�alves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [owner, pot] = strwalk24mex(X, slabel, k, disttype, valpha, nclass, maxiter)
    if (nargin < 7) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 6) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 5) || isempty(valpha),
        valpha = 20;
    end    
    if (nargin < 4) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    qtnode = size(X,1); % quantidade de n�s
    if (nargin < 3) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais pr�ximos
    end        
    npart = sum(slabel==0); % quantidade de part�culas
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia    
    % normalizar atributos se necess�rio
    if strcmp(disttype,'seuclidean')==1
        X = zscore(X);
        disttype='euclidean';
    end
    % encontrando k-vizinhos mais pr�ximos      
    [KNN,KNND] = knnsearch(X,X,'K',k+1,'NSMethod','kdtree','Distance',disttype);    
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo
    KNND = KNND(:,2:end);
    KNND = 1 - KNND./max(max(KNND)); % transformando dist�ncias em pesos de 0 a 1
    KNNR = zeros(qtnode,k); % criando matriz para vizinhan�a rec�proca, inicialmente com tamanho k
    KNNDR = zeros(qtnode,k);
    knns = zeros(qtnode,1); % vetor com a quantidade de vizinhos rec�procos de cada n�
    for i=1:qtnode
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        KNNDR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)')) = KNND(i,:);
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos n�s que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum n� atingiu o limite de colunas da matriz de vizinhan�a rec�proca teremos de aument�-la
            KNNR(:,max(knns)+1:max(knns)*2) = zeros(qtnode,max(knns));  % portanto vamos dobr�-la
            KNNDR(:,max(knns)+1:max(knns)*2) = zeros(qtnode,max(knns));
        end
    end
    KNN = [KNN KNNR];
    KNND = [KNND KNNDR];
    clear KNNR KNNDR;
    % removendo duplicatas    
    for i=1:qtnode
        [knnrow,ia] = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN
        KNND(i,1:knns(i)) = KNND(i,ia(1:end-1)); % elimina dist�ncias das duplicatas eliminadas
    end
    KNN = KNN(:,1:max(knns)); % eliminando colunas que n�o tem vizinhos v�lidos
    KNND = KNND(:,1:max(knns)); % eliminando colunas que n�o tem dist�ncias v�lidas
    % definindo n� casa da part�cula
    partnode = find(slabel==0);
    % lista de n�s rotulados
    labelednodes = find(slabel~=0);
    % ajustando todas as dist�ncias na m�xima poss�vel
    pot = repmat(1/nclass,qtnode,nclass);
    % zerando potenciais dos n�s rotulados
    pot(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para m�ximo
    pot(sub2ind(size(pot),labelednodes,slabel(slabel~=0))) = 1;
    pot = strwalk24loop(maxiter, npart, nclass, stopmax, partnode, slabel, knns, KNN, KNND, pot);
    [~,owner] = max(pot,[],2);
    pot = pot ./ repmat(sum(pot,2),1,nclass);
end

