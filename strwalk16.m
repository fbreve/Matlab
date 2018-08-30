% Semi-Supervised Territory Mark Walk v.16
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Active Learning (v.14)
% Usa informação de incerteza acumulada (v.16)
% Usage: [owner, slabel, pot, owndeg, distnode] = strwalk16(X, label, labp, k, disttype, pdet, deltav, deltap, dexp, nclass)
function [owner, slabel, pot, owndeg, distnode] = strwalk16(X, label, labp, k, disttype, pdet, deltav, deltap, dexp, nclass)
    if (nargin < 10) || isempty(nclass),
        nclass = max(label); % quantidade de classes
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
    if (nargin < 6) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
    end
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % distância euclidiana não normalizada
    end    
    qtnode = size(X,1); % quantidade de nós
    if (nargin < 4) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais próximos
    end    
    if (nargin < 3) || isempty(labp),
        labp = 0.1; % percentual de nós rotulados
    end    
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    npart = max(round(qtnode*labp),nclass);
    cnpart = nclass; % quantidade de partículas inicial é igual ao número de classes
    stopmax = round((qtnode/cnpart)*100); % qtde de iterações para verificar convergência    
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    graph = zeros(qtnode,'single');
    % eliminando a distância para o próprio elemento
    for j=1:qtnode        
        W(j,j)=+Inf;
    end
    % construindo grafo
    for i=1:k-1
        [~,ind] = min(W,[],2);
        for j=1:qtnode
            graph(j,ind(j))=1;
            graph(ind(j),j)=1;
            W(j,ind(j))=+Inf;
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
    % definindo tabela de distâncias dos nós
    distnode = repmat(qtnode-1,qtnode,npart);
    % criando tabela de classes de cada partícula
    partclass = zeros(npart,1);
    % criando tabela de posição inicial das partículas
    partpos=zeros(npart,1);    
    % criando célula para listas de vizinhos
    N = cell(qtnode,1);   
    % definindo potencial acumulado
    potacc = repmat(realmin,qtnode,nclass);    
    % rotulando apenas um elemento por classe   
    slabel = zeros(qtnode,1);
    for i=1:nclass
        while 1 
            r = random('unid',qtnode);    
            if label(r)==i 
                break;
            end
        end
        slabel(r)=i;
        pot(r,:)=0;
        pot(r,i)=1;        
        potacc(r,:)=0;      % potencial acumulado ajustado para 0 na classe de nós rotulados, evitando que sejam escolhidos como mais ambíguos
        potacc(r,i)=1;      % potencial acumulado ajustado para 1 na classe de nós rotulados, evitando que sejam escolhidos como mais ambíguos
        partclass(i)=i;     % definindo classe da partícula
        distnode(r,i)=0;    % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva partícula
        partpos(i)=r;       % definindo posição inicial da partícula para seu respectivo nó pré-rotulado
    end       
    for i=1:qtnode
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % definindo grau de propriedade
    owndeg = repmat(realmin,qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0  
    % variável para guardar máximo potencial mais alto médio
    maxmmpot = 0;
    while 1
        % para cada partícula
        rndtb = unifrnd(0,1,cnpart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,cnpart,1);  % sorteio da roleta
        for j=1:cnpart
            if rndtb(j)<pdet
                % regra de probabilidade
                prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                % descobrindo quem foi o nó sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                movtype=0;
            else
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                movtype=1;
            end
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
                if slabel(k)==0
                    potacc(k,partclass(j)) = potacc(k,partclass(j)) + potpart(j);
                end
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
        %if mod(i,10)==0
            mmpot = mean(max(pot,[],2));
            %disp(sprintf('Iter: %5.0f  Meanpot: %0.4f  Partículas: %2.0f',i,mmpot,cnpart))
            if mmpot>maxmmpot
                maxmmpot = mmpot;
                stopcnt = 0;
            else    
                stopcnt = stopcnt + 1;
                if stopcnt > stopmax                     
                    if cnpart < npart
                        % aumentando contador do número atual de partículas
                        cnpart = cnpart + 1;
                        % atualiza qtde de iterações para verificar convergência    
                        stopmax = round((qtnode/cnpart)*100); 
                        % descobrindo qual é o nó mais ambíguo
                        potsort = sort(potacc,2,'descend');
                        [~,ind] = max(potsort(:,2)./potsort(:,1));
                        % rotulando nó mais ambíguo
                        slabel(ind) = label(ind);
                        % ajustando potenciais do nó mais ambíguo
                        pot(ind,:)=0;
                        pot(ind,label(ind))=1;               
                        partclass(cnpart)=label(ind);     % definindo classe da partícula
                        distnode(ind,cnpart)=0;    % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva partícula
                        partpos(cnpart)=ind;       % definindo posição inicial da partícula para seu respectivo nó pré-rotulado                
                        stopcnt = 0;
                        maxmmpot = 0;
                        % reiniciando contagem de dominância acumulada
                        potacc = repmat(realmin,qtnode,nclass);
                        for i=1:qtnode
                            if slabel(i)~=0
                                potacc(i,:)=0;
                                potacc(i,label(i))=1;
                            end
                        end
                        %disp(sprintf('Iter %2.0f  CNPart: %2.0f  Nó: %2.0f',i,cnpart,ind))                        
                    else    
                        break;
                    end
                end
            end
            %if i/(iter*0.5) > (cnpart / npart)      
        %end
    end
    [~,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

