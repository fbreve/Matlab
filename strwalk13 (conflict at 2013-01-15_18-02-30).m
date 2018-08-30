% Semi-Supervised Territory Mark Walk v.8k
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Tabela de distâncias usa distância como medida pelo método OPF (v.13)
% Usage: [owner, pot, owndeg, distnode] = strwalk13(X, slabel, k, disttype, pdet, deltav, deltap, dexp, nclass, iter)
function [owner, pot, owndeg, distnode] = strwalk13(X, slabel, k, disttype, pdet, deltav, deltap, dexp, nclass, iter)
    if (nargin < 10) || isempty(iter),
        iter = 500000; % número de iterações
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
        deltav = 0.350; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.700; % probabilidade de não explorar
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
%     B = sort(W,2);  % ordenando matriz de afinidade
%     BS = B(:,k+1);
%     clear B;
%     graph = W <= repmat(BS,1,qtnode);  % conectando k-vizinhos mais próximos
%     clear BS W;
%     graph = graph | graph';
%     graph = graph - eye(qtnode);  % zerando diagonal do grafo
    graph = zeros(qtnode,'single');
    % eliminando a distância para o próprio elemento
    for j=1:qtnode        
        W(j,j)=NaN;
    end
    % guardando matriz de afinidade para usar na tabela de distância
    % valores normalizados de forma que a média da distância do primeiro
    % vizinho seja 1
    AfM = W./mean(min(W,[],2));
    % definindo tabela de distâncias dos nós
    distnode = repmat(max(max(AfM)),qtnode,npart);   
    % construindo grafo
    for i=1:k-1
        [~,ind] = min(W,[],2);
        for j=1:qtnode
            graph(j,ind(j))=1;
            graph(ind(j),j)=1;
            W(j,ind(j))=NaN;
        end
    end
    % últimos vizinhos do grafo (não precisa atualizar W pq não será mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    for j=1:qtnode
        graph(j,ind(j))=1;
        graph(ind(j),j)=1;
    end 
    clear ind;
    % tabela de potenciais de nós
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da partícula
    potpart = repmat(potmax,npart,1);
    % criando tabela de classes de cada partícula
    partclass = zeros(npart,1);
    % criando tabela de posição inicial das partículas
    partpos=zeros(npart,1);    
    % criando célula para listas de vizinhos
    N = cell(qtnode,1);   
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
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % definindo grau de propriedade
    owndeg = repmat(realmin,qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0
    % variável para guardar máximo potencial mais alto médio
    maxmmpot = 0;
    for i=1:iter
        % para cada partícula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart
            if rndtb(j)<pdet
                % regra de probabilidade
                %prob = cumsum(((1+distnode(N{partpos(j)},j)).^-dexp) .* pot(N{partpos(j)},partclass(j)) .* AfM(N{partpos(j)},partpos(j)));
                prob = cumsum(((1+distnode(N{partpos(j)},j)).^-dexp) .* pot(N{partpos(j)},partclass(j)));
                % descobrindo quem foi o nó sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                movtype=0;                
            else
                % regra de probabilidade
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                % prob = cumsum(AfM(N{partpos(j)},partpos(j)));
                % descobrindo quem foi o nó sorteado
                %k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                movtype=1;                
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
                      
            % máximo entre a distância (na tabela de distâncias) do nó atual e a distância no espaço de atributos entre nó atual e nó alvo
            distaux = max(distnode(partpos(j),j),AfM(partpos(j),k));
            if distaux<distnode(k,j)
                % atualizar distância do nó alvo
                distnode(k,j) = distaux;
            end
            
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
    [~,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

