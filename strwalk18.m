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
% Periodicamente elimina partícula que não domina seu nó casa (v.18)
% Volta a utilizar tabela de distância individual (v.18)
% Usage: [owner, pot, owndeg, distnode] = strwalk18(X, slabel, k, disttype, pdet, deltav, nclass, iter)
function [owner, pot, owndeg, distnode] = strwalk18(X, slabel, k, disttype, pdet, deltav, nclass, iter)
    if (nargin < 8) || isempty(iter),
        iter = 500000; % número de iterações
    end
    if (nargin < 7) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
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
    stopmax = round((qtnode/npart)*200); % qtde de iterações para verificar convergência    
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    graph = zeros(qtnode,'double');
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
    % conectando nós com mesmo label
    %graph = fSameLabelConnect(graph_dis,qtnode,slabel);  
    % tabela de potenciais de nós
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da partícula
    potpart = repmat(potmax,npart,1);
    % definindo tabela de distâncias dos nós
    distnode = repmat(qtnode-1,qtnode,npart);
    %distnode = repmat(qtnode-1,qtnode,nclass);
    %distnode = repmat(single(qtnode-1),qtnode,nclass);
    % criando tabela de classes de cada partícula
    partclass = zeros(npart,1);
    % criando tabela de posição das partículas
    partpos=zeros(npart,1);
    % criando célula para listas de vizinhos
    N = cell(qtnode,1);
    % verificando nós rotulados e ajustando potenciais de acordo  
    j=0;
    % nós que pertencem a cada partícula
    partnode = zeros(npart,1);
    for i=1:qtnode
        % se nó é pré-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            j = j + 1;
            partclass(j)=slabel(i);  % definindo classe da partícula
            partnode(j)=i;          % definindo nó da partícula
            distnode(i,j)=0;        % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva partícula
            %distnode(i,slabel(i))=0; % definindo distância do nó pré-rotulado para 0 na tabela de sua respectiva classe
            partpos(j)=i;            % definindo posição inicial da partícula para seu respectivo nó pré-rotulado
        end
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % definindo grau de propriedade
    potacc = repmat(realmin('single'),qtnode,nclass);  % não podemos usar 0, porque nós não visitados dariam divisão por 0
    for chi=1:npart;
        maxmmpot = 0;        
        for i=1:iter
            % para cada partícula
            rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
            roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
            for j=1:npart
                if partnode(j)==0
                    continue;
                end
                if rndtb(j)<pdet
                    % regra de probabilidade
                    prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^2)'.* pot(N{partpos(j)},partclass(j))');                    
                    %prob = cumsum((1./(1+distnode(N{partpos(j)},partclass(j))).^2)'.* pot(N{partpos(j)},partclass(j))');
                    % descobrindo quem foi o nó sorteado
                    k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                    
                else
                    k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                    % contador de visita (para calcular grau de propriedade)
                    potacc(k,partclass(j)) = potacc(k,partclass(j)) + potpart(j);
                end
                % se o nó não é pré-rotulado
                %if slabel(k)==0
                % calculando novos potenciais para nó
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
                %end
                % atribui novo potencial para partícula
                %potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                potpart(j) = pot(k,partclass(j)); % fixado o deltap em 1
                % se distância do nó alvo maior que distância do nó atual + 1
                if distnode(partpos(j),j)+1<distnode(k,j)
                %if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
                    % atualizar distância do nó alvo
                    distnode(k,j) = distnode(partpos(j),j)+1;
                    %distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
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
        
        % selecionando nó com menor potencial do próprio time
        owndeg = potacc ./ repmat(sum(potacc,2),1,nclass);
        partownowndeg = repmat(+Inf,npart,1);  % inicialmente todos são infinitos
        for i=1:npart
            if partnode(i)~=0 
                partownowndeg(i) = owndeg(partnode(i),slabel(partnode(i)));
            end
        end
        
        %ownowndeg = owndeg(sub2ind(size(owndeg),partnode(partnode~=0),slabel(slabel~=0)));
        
        % achar a partícula cujo nó que é o menos dominado por seu próprio time
        [partminownowndeg,indpartminownowndeg] = min(partownowndeg);       
        
        % se o nó selecionado tem domínio do time a que pertence, para tudo e termina
        if partminownowndeg==max(owndeg(partnode(indpartminownowndeg),:))
        %if minownowndeg>0.5
            break;
        end
              
        %disp(sprintf('Nó casa %1.0f da partícula %1.0f e classe %1.0f com dominância do próprio time em %0.4f. Casa abandonada!',partnode(indpartminownowndeg),indpartminownowndeg,slabel(partnode(indpartminownowndeg)),partminownowndeg))      
        
        %convertendo nó sem classe com maior potencial da classe cuja casa foi eliminada em novo nó casa da tal classe        
        %[nodencmaxowndeg,indnodencmaxowndeg] = max(owndeg(:,slabel(partnode(indpartminownowndeg))).*double(slabel==0));
        
        %disp(sprintf('Nó %1.0f (sem rótulo) com potencial %0.4f é o mais alto da classe %1.0f. Casa criada!',indnodencmaxowndeg,nodencmaxowndeg,slabel(partnode(indpartminownowndeg))))
                           
        %reiniciar tabela de distâncias da partícula que mudou de casa
        %distnode(:,indpartminownowndeg)=qtnode-1;  
        %distnode(slabel(partnode(indpartminownowndeg)),indpartminownowndeg)=0;
                     
        % colocando novo nó como rotulado
        %slabel(indnodencmaxowndeg) = slabel(partnode(indpartminownowndeg));

        % colocando nó abandonado como não rotulado
        %slabel(partnode(indpartminownowndeg)) = 0;        
        
        % colocando partícula na nova casa
        %partpos(indpartminownowndeg)=indnodencmaxowndeg;       
               
        % eliminando partícula
        partnode(indpartminownowndeg) = 0;       
        
        % resetar potencial acumulado
        potacc = repmat(realmin('single'),qtnode,nclass);
        
        % Refazer conexões de grafo (de mesma classe) e tabela de distâncias
        %graph = fSameLabelConnect(graph_dis,qtnode,slabel); 
        %[N, distnode] = fRebuildNandDistnode(qtnode,graph,partnode);
    end
    [~,owner] = max(pot,[],2);
    owndeg = potacc ./ repmat(sum(potacc,2),1,nclass);

%     function graph = fSameLabelConnect(graph,qtnode,slabel)
%         % conectando nós com mesmo label
%         for fi=1:qtnode
%             for fj=fi+1:qtnode
%                 if slabel(fi)~=0 && slabel(fi)==slabel(fj)
%                     graph(fi,fj)=1;
%                     graph(fj,fi)=1;
%                 end
%             end
%         end
%     end

%     function [N, distnode] = fRebuildNandDistnode(qtnode,graph,partnode)
%         N = cell(qtnode,1);
%         for fi=1:qtnode
%             N{fi} = find(graph(fi,:)==1); % criando lista de vizinhos
%         end
%         distnode = repmat(qtnode-1,qtnode,npart);
%         %distnode = repmat(qtnode-1,qtnode,nclass);
%         for fi=1:npart
%             if partnode~=0
%                 distnode(partnode(fi),fi)=0;
%             end
%         end        
%     end
end
