% Semi-Supervised Territory Mark Walk v.11
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
% versão que aceita grafos prontos como entrada (v.11g)
% Usage: [owner, pot, distnode] = strwalk11g(graph, slabel, pdet, deltav, deltap, dexp, nclass, iter)
function [owner, pot, distnode] = strwalk11g(graph, slabel, pdet, deltav, deltap, dexp, nclass, iter)
    if (nargin < 8) || isempty(iter),
        iter = 500000; % número de iterações
    end
    if (nargin < 7) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 6) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 5) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 4) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 3) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
    end
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    qtnode = size(graph,1); % quantidade de nós
    npart = sum(slabel~=0); % quantidade de partículas
    stopmax = round((qtnode/npart)*200); % qtde de iterações para verificar convergência    
    % conectando nós com mesmo label
    for i=1:qtnode
        for j=i+1:qtnode
            if slabel(i)~=0 && slabel(i)==slabel(j)
                graph(i,j)=1;
                graph(j,i)=1;
            end    
        end
    end    
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
            distnode(i,slabel(i))=0; % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva classe
            partpos(j)=i;            % definindo posição inicial da partícula para seu respectivo nó pré-rotulado            
        end
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % variável para guardar máximo potencial mais alto médio
    maxmmpot = 0;
    for i=1:iter
        % para cada partícula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart
            if rndtb(j)<pdet
                % regra de probabilidade
                %prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                prob = cumsum((1./(1+distnode(N{partpos(j)},partclass(j))).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                % descobrindo quem foi o nó sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                %movtype=0;
            else
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                %movtype=1;
            end
            % calculando novos potenciais para nó
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            % atribui novo potencial para partícula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;                                 
            % se distância do nó alvo maior que distância do nó atual + 1
            if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
                % atualizar distância do nó alvo
                distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
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
end

