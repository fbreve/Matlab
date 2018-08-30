% Semi-Supervised Territory Mark Walk v.11
% Derivado de strwalk8.m (v.8k)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Sem potencial fixo, tabela de dist�ncia do time, 
% e n�s com labels iguais conectados (v.11) 
% Usage: [owner, pot, distnode] = strwalk11mex(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
function [owner, pot, distnode] = strwalk11mex(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
    if (nargin < 11) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 10) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 9) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 8) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da part�cula
    end
    if (nargin < 7) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 6) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 5) || isempty(valpha),
        valpha = 2000;
    end    
    if (nargin < 4) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    qtnode = size(X,1); % quantidade de n�s
    if (nargin < 3) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais pr�ximos
    end   
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel~=0); % quantidade de part�culas
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    graph = zeros(qtnode,'double');
    % eliminando a dist�ncia para o pr�prio elemento
    W = W + eye(qtnode)*realmax; 
    % construindo grafo
    for i=1:k-1
        [~,ind] = min(W,[],2);
        graph(sub2ind(size(graph),1:qtnode,ind')) = 1;
        graph(sub2ind(size(graph),ind',1:qtnode)) = 1;
        W(sub2ind(size(W),1:qtnode,ind')) = +Inf;
    end
    % �ltimos vizinhos do grafo (n�o precisa atualizar W pq n�o ser� mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    graph(sub2ind(size(graph),1:qtnode,ind'))=1;
    graph(sub2ind(size(graph),ind',1:qtnode))=1;
    clear ind;
    % conectando n�s com mesmo label
    for i=1:qtnode
        for j=i+1:qtnode
            if slabel(i)~=0 && slabel(i)==slabel(j)
                graph(i,j)=1;
                graph(j,i)=1;
            end    
        end
    end    
    % definindo classe de cada part�cula
    partclass = slabel(slabel~=0);
    % definindo n� casa da part�cula
    partnode = find(slabel);
    % definindo potencial da part�cula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as dist�ncias na m�xima poss�vel
    distnode = repmat(qtnode-1,qtnode,npart);
    % ajustando para zero a dist�ncia de cada part�cula para seu
    % respectivo n� casa
    distnode(sub2ind(size(distnode),partnode,partclass)) = 0;
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos n�s rotulados
    pot(partnode,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
    % colocando cada n� em sua casa
    partpos = partnode;           
    % criando c�lula para listas de vizinhos
    nsize = double(sum(graph));
    nlist = zeros(qtnode,max(nsize));
    for i=1:qtnode       
        nlist(i,1:nsize(i)) = find(graph(i,:)==1);
    end
    clear graph;
    pot = strwalk11loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabel, nsize, distnode, nlist, pot);
    [~,owner] = max(pot,[],2);
end