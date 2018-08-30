% Semi-Supervised Territory Mark Walk v.11
% Derivado de strwalk8.m (v.8k)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Sem potencial fixo, tabela de dist�ncia do time, 
% e n�s com labels iguais conectados (v.11)
% Periodicamente elimina part�cula que n�o domina seu n� casa (v.18)
% Volta a utilizar tabela de dist�ncia individual (v.18)
% Usage: [owner, pot, owndeg, distnode] = strwalk18(X, slabel, k, disttype, pdet, deltav, nclass, iter)
function [owner, pot, owndeg, distnode] = strwalk18(X, slabel, k, disttype, pdet, deltav, nclass, iter)
    if (nargin < 8) || isempty(iter),
        iter = 500000; % n�mero de itera��es
    end
    if (nargin < 7) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 4) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    qtnode = size(X,1); % quantidade de n�s
    if (nargin < 3) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais pr�ximos
    end    
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel~=0); % quantidade de part�culas
    stopmax = round((qtnode/npart)*200); % qtde de itera��es para verificar converg�ncia    
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    graph = zeros(qtnode,'double');
    % eliminando a dist�ncia para o pr�prio elemento
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
    % �ltimos vizinhos do grafo (n�o precisa atualizar W pq n�o ser� mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    for j=1:qtnode
        graph(j,ind(j))=1;
        graph(ind(j),j)=1;
    end
    clear ind;
    % conectando n�s com mesmo label
    %graph = fSameLabelConnect(graph_dis,qtnode,slabel);  
    % tabela de potenciais de n�s
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da part�cula
    potpart = repmat(potmax,npart,1);
    % definindo tabela de dist�ncias dos n�s
    distnode = repmat(qtnode-1,qtnode,npart);
    %distnode = repmat(qtnode-1,qtnode,nclass);
    %distnode = repmat(single(qtnode-1),qtnode,nclass);
    % criando tabela de classes de cada part�cula
    partclass = zeros(npart,1);
    % criando tabela de posi��o das part�culas
    partpos=zeros(npart,1);
    % criando c�lula para listas de vizinhos
    N = cell(qtnode,1);
    % verificando n�s rotulados e ajustando potenciais de acordo  
    j=0;
    % n�s que pertencem a cada part�cula
    partnode = zeros(npart,1);
    for i=1:qtnode
        % se n� � pr�-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            j = j + 1;
            partclass(j)=slabel(i);  % definindo classe da part�cula
            partnode(j)=i;          % definindo n� da part�cula
            distnode(i,j)=0;        % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de sua respectiva part�cula
            %distnode(i,slabel(i))=0; % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de sua respectiva classe
            partpos(j)=i;            % definindo posi��o inicial da part�cula para seu respectivo n� pr�-rotulado
        end
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % definindo grau de propriedade
    potacc = repmat(realmin('single'),qtnode,nclass);  % n�o podemos usar 0, porque n�s n�o visitados dariam divis�o por 0
    for chi=1:npart;
        maxmmpot = 0;        
        for i=1:iter
            % para cada part�cula
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
                    % descobrindo quem foi o n� sorteado
                    k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                    
                else
                    k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                    % contador de visita (para calcular grau de propriedade)
                    potacc(k,partclass(j)) = potacc(k,partclass(j)) + potpart(j);
                end
                % se o n� n�o � pr�-rotulado
                %if slabel(k)==0
                % calculando novos potenciais para n�
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
                %end
                % atribui novo potencial para part�cula
                %potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                potpart(j) = pot(k,partclass(j)); % fixado o deltap em 1
                % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
                if distnode(partpos(j),j)+1<distnode(k,j)
                %if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
                    % atualizar dist�ncia do n� alvo
                    distnode(k,j) = distnode(partpos(j),j)+1;
                    %distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
                end
               
                % se n�o houve choque
                if pot(k,partclass(j))>=max(pot(k,:))
                    % muda para n� alvo
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
        
        % selecionando n� com menor potencial do pr�prio time
        owndeg = potacc ./ repmat(sum(potacc,2),1,nclass);
        partownowndeg = repmat(+Inf,npart,1);  % inicialmente todos s�o infinitos
        for i=1:npart
            if partnode(i)~=0 
                partownowndeg(i) = owndeg(partnode(i),slabel(partnode(i)));
            end
        end
        
        %ownowndeg = owndeg(sub2ind(size(owndeg),partnode(partnode~=0),slabel(slabel~=0)));
        
        % achar a part�cula cujo n� que � o menos dominado por seu pr�prio time
        [partminownowndeg,indpartminownowndeg] = min(partownowndeg);       
        
        % se o n� selecionado tem dom�nio do time a que pertence, para tudo e termina
        if partminownowndeg==max(owndeg(partnode(indpartminownowndeg),:))
        %if minownowndeg>0.5
            break;
        end
              
        %disp(sprintf('N� casa %1.0f da part�cula %1.0f e classe %1.0f com domin�ncia do pr�prio time em %0.4f. Casa abandonada!',partnode(indpartminownowndeg),indpartminownowndeg,slabel(partnode(indpartminownowndeg)),partminownowndeg))      
        
        %convertendo n� sem classe com maior potencial da classe cuja casa foi eliminada em novo n� casa da tal classe        
        %[nodencmaxowndeg,indnodencmaxowndeg] = max(owndeg(:,slabel(partnode(indpartminownowndeg))).*double(slabel==0));
        
        %disp(sprintf('N� %1.0f (sem r�tulo) com potencial %0.4f � o mais alto da classe %1.0f. Casa criada!',indnodencmaxowndeg,nodencmaxowndeg,slabel(partnode(indpartminownowndeg))))
                           
        %reiniciar tabela de dist�ncias da part�cula que mudou de casa
        %distnode(:,indpartminownowndeg)=qtnode-1;  
        %distnode(slabel(partnode(indpartminownowndeg)),indpartminownowndeg)=0;
                     
        % colocando novo n� como rotulado
        %slabel(indnodencmaxowndeg) = slabel(partnode(indpartminownowndeg));

        % colocando n� abandonado como n�o rotulado
        %slabel(partnode(indpartminownowndeg)) = 0;        
        
        % colocando part�cula na nova casa
        %partpos(indpartminownowndeg)=indnodencmaxowndeg;       
               
        % eliminando part�cula
        partnode(indpartminownowndeg) = 0;       
        
        % resetar potencial acumulado
        potacc = repmat(realmin('single'),qtnode,nclass);
        
        % Refazer conex�es de grafo (de mesma classe) e tabela de dist�ncias
        %graph = fSameLabelConnect(graph_dis,qtnode,slabel); 
        %[N, distnode] = fRebuildNandDistnode(qtnode,graph,partnode);
    end
    [~,owner] = max(pot,[],2);
    owndeg = potacc ./ repmat(sum(potacc,2),1,nclass);

%     function graph = fSameLabelConnect(graph,qtnode,slabel)
%         % conectando n�s com mesmo label
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
