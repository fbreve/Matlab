% Semi-Supervised Territory Mark Walk v.7 (versão para gerar séries
% temporais)
% Derivado de strwalk6.m
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Usage: [owner, pot, distnode, s_itr, s_acc, s_pot, s_prt, s_dst] = strwalk7series(X, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp, label)
function [owner, pot, distnode, s_itr, s_acc, s_pot, s_prt, s_dst] = strwalk7series(X, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp, label)
    if (nargin < 8) || isempty(sigma),
        sigma = 3; % exponencial da probabilidade
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % exponecial da probabilidade
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
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    qtnode = size(X,1); % quantidade de nós
    npart = sum(slabel~=0); % quantidade de partículas
    %graph = round(exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2)); % gerando grafo
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    graph = W <= sigma;  % gerando grafo com limiar sobre matriz de afinidade
    %B = sort(W,2);  % ordenando matriz de afinidade
    %G2 = W <= repmat(B(:,knn+1),1,qtnode);  % conectando k-vizinhos mais próximos
    %graph = G1 | G2;  % juntando grafo limiar com grafo k-vizinhos
    graph = graph - eye(qtnode);  % zerando diagonal do grafo
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
    % definindo series temporais
    s_itr = zeros(iter,1);
    s_acc = zeros(iter,1);
    s_pot = zeros(iter,1);
    s_prt = zeros(iter,1);
    s_dst = zeros(iter,1);
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:).*(1./(alpha.^distnode(:,j)))';
                %
                prob = graph(partpos(j),:).*(1./(1+distnode(:,j)).^dexp)'.* pot(:,partclass(j))';  
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);   %.*pot(:,j)';
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
        % verificando donos
        [nil,owner] = max(pot,[],2);        
        % gravando series temporais
        s_itr(i) = i;
        s_acc(i) = stmweval(label,slabel,owner);
        s_pot(i) = mean(max(pot,[],2));
        s_prt(i) = mean(potpart);
        s_dst(i) = mean(odopart);
    end    
end

