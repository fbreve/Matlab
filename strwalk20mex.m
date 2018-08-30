% REMOVER VARIAVEIS DE RETORNO POT E DISTNODE
% Semi-Supervised Territory Mark Walk v.20
% Derivado de strwalk8.m (v.8k)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Sem potencial fixo, tabela de distância do time, 
% e nós com labels iguais conectados (v.11) 
% Nós rotulados dão prioridade pra k-vizinhos mais próximos com mesmo
% rótulo. Tabela de distância volta a ser individual. (v.20)
% Usage: [owner, pot, distnode] = strwalk20mex(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
function [owner, pot, distnode] = strwalk20mex(X, slabel, k, disttype, valpha, pgrd, deltav, deltap, dexp, nclass, maxiter)
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
        valpha = 2000;
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
    stopmax = round((qtnode/npart)*round(valpha*0.01)); % qtde de iterações para verificar convergência
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade   
    clear X;
    % aumentando distâncias para todos os elementos, exceto entre os
    % rotulados de mesmo rótulo
    W = W + (~((repmat(slabel,[1,size(slabel)]) == repmat(slabel,[1,size(slabel)])') & (repmat(slabel,[1,size(slabel)])~=0)))*max(max(W));
    % eliminando a distância para o próprio elemento
    W = W + eye(qtnode)*realmax;       
    % construindo grafo
    graph = zeros(qtnode,'double');    
    for i=1:k-1
        [~,ind] = min(W,[],2);
        graph(sub2ind(size(graph),1:qtnode,ind')) = 1;
        graph(sub2ind(size(graph),ind',1:qtnode)) = 1;
        W(sub2ind(size(W),1:qtnode,ind')) = +Inf;
        %for j=1:qtnode
        %    graph(j,ind(j))=1;
        %    graph(ind(j),j)=1;
        %    W(j,ind(j))=+Inf;
        %end
    end
    % últimos vizinhos do grafo (não precisa atualizar W pq não será mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    graph(sub2ind(size(graph),1:qtnode,ind'))=1;
    graph(sub2ind(size(graph),ind',1:qtnode))=1;
    %for j=1:qtnode        
    %    graph(j,ind(j))=1;
    %    graph(ind(j),j)=1;
    %end
    clear ind;
    % definindo classe de cada partícula
    partclass = slabel(slabel~=0);
    % definindo nó casa da partícula
    partnode = find(slabel);
    % criando célula para listas de vizinhos
    nsize = double(sum(graph));
    nlist = zeros(qtnode,max(nsize));
    for i=1:qtnode       
        nlist(i,1:nsize(i)) = find(graph(i,:)==1);
    end
    clear graph;
    % definindo grau de propriedade
    potacc = zeros(qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0
    % inicializando tabela de potenciais com tudo igual
    potini = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos nós rotulados
    potini(partnode,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1      
    potini(sub2ind(size(potini),partnode,slabel(partnode))) = 1;      
    for ri=1:10
        % ajustando potenciais para configuração inicial
        pot = potini;
        % definindo potencial da partícula em 1
        potpart = repmat(potmax,npart,1);       
        % ajustando todas as distâncias na máxima possível
        distnode = repmat(qtnode-1,qtnode,npart);
        % ajustando para zero a distância de cada partícula para seu
        % respectivo nó casa
        distnode(sub2ind(size(distnode),partnode',1:npart)) = 0;
        % colocando cada nó em sua casa
        partpos = partnode;
        pot = strwalk20loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabel, nsize, distnode, nlist, pot);
        potacc = potacc + pot;
    end
    [~,owner] = max(potacc,[],2);
    %owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

