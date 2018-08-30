% DESATUALIZADO, USAR VERSAO MEX

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
% Usage: [owner, pot] = strwalk20(X, slabel, k, disttype, pdet, deltav, deltap, dexp, nclass, maxiter)
function [owner, pot] = strwalk20(X, slabel, k, disttype, pdet, deltav, deltap, dexp, nclass, maxiter)
    if (nargin < 10) || isempty(maxiter),
        maxiter = 500000; % número de iterações
    end
    if (nargin < 9) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 8) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.1; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.5; % probabilidade de não explorar
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
    stopmax = round((qtnode/npart)*20); % qtde de iterações para verificar convergência    
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
    N = cell(qtnode,1);  
    for i=1:qtnode
        % se nó é pré-rotulado
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % definindo grau de propriedade
    potacc = zeros(qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0
    for ri=1:10
        % variável para guardar máximo potencial mais alto médio
        maxmmpot = 0;
        % definindo potencial da partícula em 1
        potpart = repmat(potmax,npart,1);       
        % ajustando todas as distâncias na máxima possível
        distnode = repmat(qtnode-1,qtnode,npart);
        % ajustando para zero a distância de cada partícula para seu
        % respectivo nó casa
        distnode(sub2ind(size(distnode),partnode',1:npart)) = 0;
        % inicializando tabela de potenciais com tudo igual
        pot = repmat(potmax/nclass,qtnode,nclass);
        % zerando potenciais dos nós rotulados
        pot(partnode,:) = 0;
        % ajustando potencial da classe respectiva do nó rotulado para 1
        pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
        % colocando cada nó em sua casa
        partpos = partnode;
        for i=1:maxiter            
            rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
            roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
            % para cada partícula
            for j=1:npart
                if rndtb(j)<pdet
                    % regra de probabilidade
                    prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                    %prob = cumsum((1./(1+distnode(N{partpos(j)},partclass(j))).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                    % descobrindo quem foi o nó sorteado
                    k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                else
                    k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                    % potencial acumulado
                end
                %potacc(k,partclass(j)) = potacc(k,partclass(j)) + potpart(j);
                % contador de visita (para calcular grau de propriedade)
                %if movtype==1
                %    owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
                %end
                % se o nó não é pré-rotulado
                %if slabel(k)==0
                % calculando novos potenciais para nó
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
                %end
                % atribui novo potencial para partícula
                potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                
                % se distância do nó alvo maior que distância do nó atual + 1
                if distnode(partpos(j),j)+1<distnode(k,j)
                    % atualizar distância do nó alvo
                    distnode(k,j) = distnode(partpos(j),j)+1;
                end
                
                
                % se distância do nó alvo maior que distância do nó atual + 1
                %if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
                %    % atualizar distância do nó alvo
                %    distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
                %end
                
                % se não houve choque
                if pot(k,partclass(j))>=max(pot(k,:))
                    % muda para nó alvo
                    partpos(j) = k;
                end
            end
            if mod(i,10)==0
                mmpot = mean(max(pot,[],2));
                %disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
                if mmpot>maxmmpot
                    maxmmpot = mmpot;
                    stopcnt = 0;
                else
                    stopcnt = stopcnt + 1;
                    if stopcnt > stopmax
                        break;
                    end
                end
            end
        end
        potacc = potacc + pot;
    end
    [~,owner] = max(potacc,[],2);
    %owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

