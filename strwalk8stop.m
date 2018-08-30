% Semi-Supervised Territory Mark Walk v.8 (com critério de parada para
% medir quantidade de iterações necessarias para classificação >= x%)
%
% Derivado de strwalk7.m
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Usage: [owner, pot, owndeg, distnode, t_iter] = strwalk8stop(X, label, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp)
function [owner, pot, owndeg, distnode, t_iter] = strwalk8stop(X, label, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp)
    if (nargin < 9) || isempty(sigma),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 8) || isempty(sigma),
        sigma = 3;
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % 
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
    end
    if (nargin < 4) || isempty(iter),
        iter = 100000; % número de iterações
    end
    % constantes
    knn = 5;
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    qtnode = size(X,1); % quantidade de nós
    npart = sum(slabel~=0); % quantidade de partículas
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    G1 = sparse(W <= sigma);  % gerando grafo com limiar sobre matriz de afinidade
    B = sort(W,2);  % ordenando matriz de afinidade
    G2 = sparse(W <= repmat(B(:,knn+1),1,qtnode));  % conectando k-vizinhos mais próximos
    graph = sparse(G1 | G2 | G2');  % juntando grafo limiar com grafo k-vizinhos
    graph = graph - sparse(eye(qtnode));  % zerando diagonal do grafo
    %graph = X;
    % tabela de potenciais de nós
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da partícula
    potpart = repmat(potmax,npart,1);
    % definindo hodômetro das partículas
    odopart = zeros(npart,1);
    % definindo tabela de distâncias dos nós
    distnode = repmat(qtnode-1,qtnode,npart);
    % criando tabela de classes de cada partícula
    partclass = zeros(npart,1);
    % criando tabela de posição inicial das partículas
    partpos=zeros(npart,1);    
    % verificando nós rotulados e ajustando potenciais de acordo
    j=0;
    for i=1:qtnode
        % se nó é pré-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            j = j + 1;
            partclass(j)=slabel(i);  % definindo classe da partícula
            distnode(i,j)=0;        % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva partícula
            partpos(j)=i;            % definindo posição inicial da partícula para seu respectivo nó pré-rotulado
        end
    end
    % definindo grau de propriedade
    owndeg = repmat(0,qtnode,nclass);   
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:).*(1./(alpha.^distnode(:,j)))';  
                prob = graph(partpos(j),:).*(1./(1+distnode(:,j)).^dexp)'.* pot(:,partclass(j))';
                movtype = 0;
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);   %.*pot(:,j)';
                movtype = 1;
            end
            % definindo tamanho da roleta
            roulettesize = sum(prob);
            % girando a roleta para sortear o novo nó
            roulettepick = random('unif',0,roulettesize);
            % descobrindo quem foi o nó sorteado
            k=1;
            while k<=size(graph,1) && roulettepick>prob(k)
                roulettepick = roulettepick - prob(k);
                k = k + 1;
            end
            % indo para o nó sorteado
            if k>qtnode
                disp('Valor fora da roleta? Isso não deveria acontecer...')
                k = random('unid',size(graph,1)); % partícula vai para nó escolhido aleatoriamente
            end
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
            end            
            % se o nó não é pré-rotulado
            if slabel(k)==0
                % calculando novos potenciais para nó
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para partícula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                      
            % se hodômetro da partícula + caminho entre nó atual e nó alvo
            % menor que distância do nó alvo
            if odopart(j)+1<distnode(k,j)
                % atualizar distância do nó alvo
                distnode(k,j) = odopart(j)+1;
            end
            
            % se não houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % atualiza hodômetro da partícula
                odopart(j) = odopart(j) + 1;
                % se hodômetro da partícula maior que distância do nó alvo
                if(distnode(k,j)<odopart(j))
                    % ajustar hodômetro para distância do nó alvo
                    odopart(j) = distnode(k,j);
                end
                % muda para nó alvo
                partpos(j) = k;
            end
        end
        % calcular acerto
        %[nil,owner] = max(pot,[],2);
        %[acc,k] = stmwevalk(label,slabel,owner);
        %if acc >= 0.90
        %    t_iter=i;
        %    break; 
        %end
        %disp(sprintf('%2.0f',i))
        % para usar critério de potencial
        if mean(max(pot,[],2)) >= 0.9
            t_iter=i;
            break; 
        end
        %disp(sprintf('%0.4f',mean(max(pot,[],2))))
    end
    [nil,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

