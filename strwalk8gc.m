% Semi-Supervised Territory Mark Walk v.8
% Derivado de strwalk7.m
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Aceita diretamente o grafo como entrada em vez de X (v.8g)
% Versão especial para medir complexidade (v.8gc)
% Usage: [totiter,tottime] = strwalk8gc(graph, slabel, nclass, iter, pdet, deltav, deltap, dexp)
function [totiter,tottime] = strwalk8gc(graph, slabel, nclass, iter, pdet, deltav, deltap, dexp)
    if (nargin < 8) || isempty(dexp),
        dexp = 2; % exponencial da probabilidade
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decermento do potencial da partícula
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.350; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.700; % probabilidade de não explorar
    end
    if (nargin < 4) || isempty(iter),
        iter = 200000; % número de iterações
    end
    tic;
    potmax = single(1.000); % potencial máximo
    potmin = single(0.000); % potencial mínimo
    qtnode = size(graph,1); % quantidade de nós
    npart = sum(slabel~=0); % quantidade de partículas
    % tabela de potenciais de nós
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da partícula
    potpart = repmat(potmax,npart,1);
    % definindo tabela de distâncias dos nós
    distnode = repmat(qtnode-1,qtnode,npart);
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
    % variável para guardar máximo potencial mais alto médio
    stopmax = round((qtnode/npart)*2); % qtde de iterações para verificar convergência
    maxmmpot = 0;
    for i=1:iter
        % para cada partícula
        rndtb = unifrnd(0,1,npart,1); % probabilidade de exploração
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart          
            % lista de vizinhos            
            if rndtb(j)<pdet
                % regra de probabilidade
                prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                % descobrindo quem foi o nó sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
            else
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
            end
            if slabel(k)==0
                % calculando novos potenciais para nó
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para partícula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                      
            % se distância do nó alvo maior que distância do nó atual + 1
            if distnode(partpos(j),j)+1<distnode(k,j)
                % atualizar distância do nó alvo
                distnode(k,j) = distnode(partpos(j),j)+1;
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
                    totiter = i;
                    tottime = toc;
                    break;
                end
            end
        end
    end
    %[~,owner] = max(pot,[],2);
    %owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end