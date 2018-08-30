% Semi-Supervised Territory Mark Walk v.9
% Derivado de strwalk8.m
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Heurística para formação da rede (v.9)
% Usage: [owner, pot, owndeg, distnode] = strwalk9(X, slabel, nclass, iter, pdet, deltav, deltap, dexp)
function [owner, pot, owndeg, distnode] = strwalk9(X, slabel, nclass, iter, pdet, deltav, deltap, dexp)
    if (nargin < 8) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
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
        iter = 200000; % número de iterações
    end
    % constantes
    knn = 5;
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    qtnode = size(X,1); % quantidade de nós
    npart = sum(slabel~=0); % quantidade de partículas
    ivconv = round(min(100,qtnode/npart)); % qtde de iterações para verificar convergência
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    slabelm = repmat(slabel,1,qtnode) .* (1-eye(qtnode)); % gerando matriz temporária
    sln = (slabelm==slabelm' & slabelm~=0); % tabela de conexões de nó com mesmo rótulo
    dln = (slabelm~=slabelm' & slabelm~=0); % tabela de conexões de nó com diferente rótulo
    mdsln = sum(sum(sln.*W))/sum(sum(sln)); % média de distância de nós com mesmo rótulo
    mddln = sum(sum(dln.*W))/sum(sum(dln)); % média de distância de nós com diferente rótulo
    sigma = mdsln * 0.25;
    G1 = W <= sigma;  % gerando grafo com limiar sobre matriz de afinidade
    B = sort(W,2);  % ordenando matriz de afinidade
    G2 = W <= repmat(B(:,knn+1),1,qtnode);  % conectando k-vizinhos mais próximos
    graph = G1 | G2 | G2';  % juntando grafo limiar com grafo k-vizinhos
    clear W G1 B G2 nsl dln mdsln mddln slabelm;
    graph = graph - eye(qtnode);  % zerando diagonal do grafo
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
    % variável para guardar máximo potencial mais alto médio
    maxmmpot = 0;
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
        if mod(i,ivconv)==0
            mmpot = mean(max(pot,[],2));
            %disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
            if mmpot>maxmmpot
                maxmmpot = mmpot;
                stopcnt = 0;
            else    
                stopcnt = stopcnt + 1;
                if stopcnt > 9                     
                    break;
                end
            end
        end
    end
    [nil,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

