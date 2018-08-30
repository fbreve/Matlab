% DESATUALIZADO! USAR VERSÃO MEX!
% Semi-Supervised Territory Mark Walk v.14
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Active Learning (v.14)
% Usage: [owner, slabel, pot, owndeg, distnode] = strwalk14(X, label, labp, k, disttype, valpha, pdet, deltav, deltap, dexp, nclass)
function [owner, slabel, pot, owndeg, distnode] = strwalk14(X, label, labp, k, disttype, valpha, pdet, deltav, deltap, dexp, nclass)
    if (nargin < 11) || isempty(nclass),
        nclass = max(label); % quantidade de classes
    end
    if (nargin < 10) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 9) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 8) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 7) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
    end
    if (nargin < 6) || isempty(valpha),
        valpha = 2000;
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
    valpha = round(valpha / (npart-cnpart));
    stopmax = round((qtnode/cnpart) * valpha); % qtde de iterações para verificar convergência   
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    graph = zeros(qtnode,'single');
    % eliminando a distância para o próprio elemento
    W = W + eye(qtnode)*realmax; 
    % construindo grafo
    for i=1:k-1
        [~,ind] = min(W,[],2);
        graph(sub2ind(size(graph),1:qtnode,ind')) = 1;
        graph(sub2ind(size(graph),ind',1:qtnode)) = 1;
        W(sub2ind(size(W),1:qtnode,ind')) = +Inf;
    end
    % últimos vizinhos do grafo (não precisa atualizar W pq não será mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    graph(sub2ind(size(graph),1:qtnode,ind'))=1;
    graph(sub2ind(size(graph),ind',1:qtnode))=1;
    clear ind;
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
    end
    % definindo classe de cada partícula
    partclass = zeros(npart,1);
    partclass(1:cnpart) = slabel(slabel~=0);
    % definindo nó casa da partícula
    partnode = zeros(npart,1);
    partnode(1:cnpart) = find(slabel);
    % definindo potencial da partícula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as distâncias na máxima possível
    distnode = repmat(qtnode-1,qtnode,npart);
    % ajustando para zero a distância de cada partícula para seu
    % respectivo nó casa
    distnode(sub2ind(size(distnode),partnode(1:cnpart)',1:cnpart)) = 0;
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos nós rotulados
    pot(partnode(1:cnpart),:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1
    pot(sub2ind(size(pot),partnode(1:cnpart),slabel(partnode(1:cnpart)))) = 1;
    % colocando cada nó em sua casa
    partpos = partnode;
    % criando célula para listas de vizinhos
    N = cell(qtnode,1);           
    % verificando nós rotulados e ajustando potenciais de acordo      
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
                        stopmax = round((qtnode/cnpart)*valpha); 
                        % descobrindo qual é o nó mais ambíguo
                        potsort = sort(pot,2,'descend');
                        [~,ind] = max(potsort(:,2)./potsort(:,1));
                        % rotulando nó mais ambíguo
                        slabel(ind) = label(ind);
                        % ajustando potenciais do nó mais ambíguo
                        pot(ind,:)=0;
                        pot(ind,label(ind))=1;               
                        partclass(cnpart)=label(ind);     % definindo classe da partícula
                        distnode(ind,cnpart)=0;           % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva partícula
                        partpos(cnpart)=ind;              % definindo posição inicial da partícula para seu respectivo nó pré-rotulado                
                        stopcnt = 0;
                        maxmmpot = 0;
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

