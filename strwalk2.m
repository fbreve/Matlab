% Semi-Supervised Territory Mark Walk v.2
% Derivado de strwalk.m
% Conta distância de de nós para o nó pré-rotulado mais próximo
% Usage: [owner, pot, distnode] = strwalk2(X, slabel, npart, iter, pdet, deltav, deltap, sigma)
function [owner, pot, distnode] = strwalk2(X, slabel, npart, iter, pdet, deltav, deltap, sigma)
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
    graph = exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2); % gerando grafo
    graph = graph - eye(qtnode);  % zerando diagonal do grafo
    % tabela de potenciais de nós
    pot = repmat(potmax/npart,qtnode,npart);
    % definindo potencial da partícula
    potpart = repmat(potmax,npart,1);
    % definindo hodômetro das partículas
    odopart = zeros(npart,1);
    % definindo tabela de distâncias dos nós
    distnode = ones(qtnode,npart);
    % verificando nós rotulados e ajustando potenciais de acordo
    for i=1:qtnode
        % se nó é pré-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            distnode(i,slabel(i))=0;
        end
    end
    % definindo posição inicial das partículas
    partpos=zeros(npart,1);
    for j=1:npart
        resetparticle;
    end
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:).*(1./(alpha.^distnode(:,j)))';  
                prob = graph(partpos(j),:).*(1-distnode(:,j))';  
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
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(npart-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,j) = pot(k,j) + sum(deltapotpart);            
            end
            % atribui novo potencial para partícula
            potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;
                      
            % se hodômetro da partícula + caminho entre nó atual e nó alvo
            % menor que distância do nó alvo
            if odopart(j)+(1-graph(partpos(j),k))<distnode(k,j)
                % atualizar distância do nó alvo
                distnode(k,j) = odopart(j)+(1-graph(partpos(j),k));
            end
            
            % se não houve choque
            if pot(k,j)>=max(pot(k,:))
                % atualiza hodômetro da partícula
                odopart(j) = odopart(j) + (1-graph(partpos(j),k));
                % se hodômetro da partícula maior que distância do nó alvo
                if(distnode(k,j)<odopart(j))
                    % ajustar hodômetro para distância do nó alvo
                    odopart(j) = distnode(k,j);
                end
                % muda para nó alvo
                partpos(j) = k;
            end
        end
    end
    [nil,owner] = max(pot,[],2);
    
    function resetparticle
        % se existe pelo menos um nó pré-rotulado para tal partícula
        if sum(slabel==j)>0
            t=j;  % colocar partícula em um dos nós rotulados
        else
            t=0;  % colocar partícula em qualquer nó não rotulado
        end
        % sortear um dos nós alvo
        roulettepick = random('unid',sum(slabel==t));
        m=0;
        while roulettepick>0
            m = m + 1;
            roulettepick = roulettepick - (slabel(m)==t);
        end
        partpos(j)=m;
    end
end

