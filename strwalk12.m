% Semi-Supervised Territory Mark Walk v.8k
% Derivado de strwalk8.m (v.8)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Tratamento de data streams (v.12)
% Usage: [owner, pot] = strwalk12(X, slabel, k, disttype, gmaxmult, pmax, pdet, deltav, deltap, nclass)
function [owner, pot] = strwalk12(X, slabel, k, disttype, gmaxmult, pmax, pdet, deltav, deltap, nclass)
if (nargin < 10) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
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
if (nargin < 6) || isempty(pmax),
    pmax = 100;
end
if (nargin < 5) || isempty(gmaxmult),
    gmaxmult = 10; 
end
if (nargin < 4) || isempty(disttype),
    disttype = 'euclidean'; % distância euclidiana não normalizada
end
if (nargin < 3) || isempty(k),
    k = 5; % quantidade de vizinhos mais próximos
end
% variáveis da versão 12 (data streams)
Xsize = size(X,1); % quantidade de nós
%pmax = 100; % quantidade máxima de partículas
gwnd = 100; % tamanho da janela de recebimento de dados
%gmaxmult = 10; % multiplicador para gerar tamanho máximo do grafo
gmax = gwnd*gmaxmult; % tamanho máximo do grafo
itwnd = round(100000/pmax); % intervalo de iterações entre cada grupo de dados
itlbl = itwnd * gmaxmult; % intervalo de iterações para rotular grupo de dados
gsize = 0; % tamanho atual do grafo
psize = 0; % tamanho atual do conjunto de partículas
pcnt = 1; % próxima partícula a ser substituída
owner = zeros(Xsize,1);
lelrd = 0; % último elemento lido
llbwr = 0; % último rótulo definido
Xwnd = zeros(gmax,size(X,2)); % dados que estão no grafo atualmente
GX = zeros(gmax,1); % vetor com índices de cada elemento que está no grafo
totiter = ceil(Xsize/gwnd)*itwnd + itwnd*(gmaxmult-1); % total de iterações
% constantes
potmax = 1.000; % potencial máximo
potmin = 0.000; % potencial mínimo
%npart = sum(slabel~=0); % quantidade de partículas
%stopmax = round((qtnode/npart)*20); % qtde de iterações para verificar convergência
% tabela de potenciais de nós
pot = repmat(potmax/nclass,gmax,nclass);
% definindo potencial da partícula
potpart = repmat(potmax,pmax,1);
% criando tabela de classes de cada partícula
partclass = zeros(pmax,1);
% criando tabela de posição inicial das partículas
partpos=zeros(pmax,1);
% definindo tabela de distâncias dos nós - Nos testes, piorou o resultado
%distnode = repmat(gmax-1,gmax,pmax);
for i=1:totiter
    % a cada intervalo de janela, devemos ler novos elementos
    if mod(i-1,itwnd)==0 && lelrd<Xsize        
        % tamanho da janela de novos elementos
        gnwnd = min(gwnd,Xsize - lelrd);
        % índice do primeiro e último nó
        nf = mod(lelrd,gmax)+1;
        nl = nf+gnwnd-1;
        % índice do primeiro e último elemento da janela
        ef = lelrd+1;
        el = lelrd+gnwnd;
        % se último elemento lido for maior que a quantidade máxima de
        % nós, temos de eliminar nós para ter espaço para os novos
        %disp(sprintf('Adicionando elementos %1.0f a %1.0f ao grafo',ef,el))
        if gsize < gmax
            gsize = gsize + gnwnd;
        end
        % movendo partículas de nós que serão eliminados
        for j=1:psize
            pmovc=0;
            % mudar esse código para mover partícula para nó mais dominado
            % da classe da partícula (Exceto os que serão excluídos)
            while partpos(j)>=nf && partpos(j)<=nl                
                partpos(j) = random('unid',size(N{j},2));
                potpart(j) = pot(partpos(j),partclass(j));
                % contador pra evitar loop infinito
                pmovc = pmovc + 1;
                if pmovc == 10
                    %disp(sprintf('Evitando loop infinito da partícula %1.0f',j))
                    break;
                end
            end
        end
        % copiando dados para a janela
        Xwnd(nf:nl,:) = X(ef:el,:);
        % copiando índices dos elementos em X para tabela de índices
        GX(nf:nl) = ef:el;
        % gerando matriz de afinidade
        W = squareform(pdist(Xwnd(1:gsize,:),disttype).^2); 
        graph = zeros(gsize,'single');
        % eliminando a distância para o próprio elemento
        for j=1:gsize
            W(j,j)=+Inf;
        end
        % construindo grafo
        % conectando k-vizinhos
        for l=1:k-1
            [~,ind] = min(W,[],2);
            for j=1:gsize
                graph(j,ind(j))=1;                
                W(j,ind(j))=+Inf;
            end
        end
        % conectando últimos vizinhos do grafo (não precisa atualizar W pq não será mais usado)
        [~,ind] = min(W,[],2);
        for j=1:gsize
            graph(j,ind(j))=1;            
        end
       % conectando nós com mesmo label - Nos testes piorou o resultado!
%        for l=1:gsize
%             for j=l+1:gsize
%                 if slabel(GX(l))~=0 && slabel(GX(l))==slabel(GX(j))
%                     graph(l,j)=1;
%                 end
%             end         
%         end
        % tornando ligações recíprocas (grafo não direcionado)
        graph = max(graph,graph');
        % criando célula para listas de vizinhos
        N = cell(gsize,1);
        for j=1:gsize
            N{j} = find(graph(j,:)==1); % criando lista de vizinhos
        end
        % ajustando potenciais dos novos nós
        pot(nf:nl,:) = repmat(potmax/nclass,gnwnd,nclass);
        % zerando tabela de distância de novos nós
        distnode(nf:nl,:)=gmax-1;
        for l=1:gnwnd
            if slabel(lelrd+l)~=0
                % ajustando potencial do nó rotulado para 1 em sua classe e 
                % 0 nas demais
                pot(nf-1+l,:) = 0;
                pot(nf-1+l,slabel(lelrd+l)) = 1;
                % criando partícula para o nó rotulado
                partclass(pcnt) = slabel(lelrd+l); % definindo rótulo da partícula
                %distnode(nf-1+l,partclass(pcnt))=0; % definindo distância do nó pré-rotulado para 0 na tabela de seu time                    
                partpos(pcnt) = nf-1+l; % definindo posição da partícula para o nó rotulado
                potpart(pcnt) = 1; % definindo potencial da partícula para nível máximo
                pcnt = pcnt + 1; % incrementa contador da próxima partícula a ser eliminada
                % se contador passou do limite de partículas, reiniciá-lo
                if pcnt>pmax 
                    pcnt=1; 
                end
                % aumenta tamanho do conjunto de partículas se ainda não chegou no máximo
                if psize<pmax 
                    psize = psize + 1; 
                end
            end
        end
        % incrementa contador de elementos já lidos   
        lelrd = lelrd + gnwnd;
    end
    % Movimentação de partículas
    rndtb = unifrnd(0,1,psize,1);  % probabilidade pdet
    roulettepick = unifrnd(0,1,psize,1);  % sorteio da roleta
    for j=1:psize
        if rndtb(j)<pdet
            % regra de probabilidade
            %prob = cumsum((1./(1+distnode(N{partpos(j)},partclass(j))).^2)'.* pot(N{partpos(j)},partclass(j))');
            prob = cumsum(pot(N{partpos(j)},partclass(j))');
            % descobrindo quem foi o nó sorteado
            k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
        else
            k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
        end
        % se o nó não é pré-rotulado
        if slabel(GX(k))==0
            % calculando novos potenciais para nó
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
        end
        % atribui novo potencial para partícula
        potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;

        % se distância do nó alvo maior que distância do nó atual + 1
        %if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
            % atualizar distância do nó alvo
        %    distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
        %end       
        
        % se não houve choque
        if pot(k,partclass(j))>=max(pot(k,:))
            % muda para nó alvo
            partpos(j) = k;
        end
    end
    % no intervalo de dados, rotular elementos
    if i>=itlbl && mod(i,itwnd)==0
        % tamanho da janela de elementos a rotular
        glwnd = min(gwnd,Xsize - llbwr);
        % índice do primeiro e último nó
        nf = mod(llbwr,gmax)+1;
        nl = nf+glwnd-1;
        % índice do primeiro e último elemento da janela
        ef = llbwr+1;
        el = llbwr+glwnd;
        % rotulando nós
        %disp(sprintf('Rotulando elementos %1.0f a %1.0f',ef,el))
        [~,owner(ef:el)] = max(pot(nf:nl,:),[],2);
        % incrmenta contador de nós já rotulados
        llbwr = llbwr + glwnd;
    end
end

end

