% Semi-Supervised Territory Mark Walk v.8 (versão para gerar séries
% temporais)
% Derivado de strwalk7.m
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Aceita diretamente o grafo como entrada em vez de X (v.8g)
% Usage: [owner, pot, owndeg, distnode, s_itr, s_acc, s_pot, s_prt, s_dst]
% = strwalk8series(graph, label, slabel, nclass, iter, pdet, deltav,
% deltap, dexp)
function [owner, pot, owndeg, distnode, s_itr, s_acc, s_pot, s_prt] = strwalk8series(graph, label, slabel, nclass, iter, pdet, deltav, deltap, dexp)
    if (nargin < 9) || isempty(dexp),
        dexp = 2.0; % exponencial da probabilidade
    end
    if (nargin < 8) || isempty(deltap),
        deltap = 1.00; % controle de velocidade de aumento/decermento do potencial da partícula
    end
    if (nargin < 7) || isempty(deltav),
        deltav = 0.35; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 6) || isempty(pdet),
        pdet = 0.70; % probabilidade de não explorar
    end
    if (nargin < 5) || isempty(iter),
        iter = 50000; % número de iterações
    end
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
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
    owndeg = repmat(realmin,qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0
    % definindo series temporais
    s_itr = zeros(iter,1);
    s_acc = zeros(iter,1);
    s_pot = zeros(iter,1);
    s_prt = zeros(iter,1);
    s_dst = zeros(iter,1);    
    for i=1:iter
        % para cada partícula
        rndtb = unifrnd(0,1,npart,1);
        for j=1:npart
            % calculando probabilidade de exploração
            if rndtb(j)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:).*(1./(alpha.^distnode(:,j)))';  
                prob = cumsum(graph(partpos(j),:).*(1./(1+distnode(:,j)).^dexp)'.* pot(:,partclass(j))');
                movtype = 0;
            else
                % regra de probabilidade
                prob = cumsum(graph(partpos(j),:));   %.*pot(:,j)';
                movtype = 1;
            end
            % girando a roleta para sortear o novo nó
            roulettepick = unifrnd(0,prob(end));
            % descobrindo quem foi o nó sorteado
            k = find(prob>=roulettepick,1,'first');           
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
        % verificando donos
        [~,owner] = max(pot,[],2);        
        % gravando series temporais
        s_itr(i) = i;
        s_acc(i) = stmweval(label,slabel,owner);
        s_pot(i) = mean(max(pot,[],2));
        s_prt(i) = mean(potpart);  
    end
    [~,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end