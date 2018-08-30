% Semi-Supervised Territory Mark Walk v.8k
% Derivado de strwalk8.m (v.8)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Tratamento de data streams (v.12)
% Usage: [owner, pot] = strwalk12(X, slabel, k, disttype, gmaxmult, pmax, pdet, deltav, deltap, nclass)
function [owner, pot] = strwalk12(X, slabel, k, disttype, gmaxmult, pmax, pdet, deltav, deltap, nclass)
if (nargin < 10) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 9) || isempty(deltap),
    deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da part�cula
end
if (nargin < 8) || isempty(deltav),
    deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
end
if (nargin < 7) || isempty(pdet),
    pdet = 0.500; % probabilidade de n�o explorar
end
if (nargin < 6) || isempty(pmax),
    pmax = 100;
end
if (nargin < 5) || isempty(gmaxmult),
    gmaxmult = 10; 
end
if (nargin < 4) || isempty(disttype),
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
if (nargin < 3) || isempty(k),
    k = 5; % quantidade de vizinhos mais pr�ximos
end
% vari�veis da vers�o 12 (data streams)
Xsize = size(X,1); % quantidade de n�s
%pmax = 100; % quantidade m�xima de part�culas
gwnd = 100; % tamanho da janela de recebimento de dados
%gmaxmult = 10; % multiplicador para gerar tamanho m�ximo do grafo
gmax = gwnd*gmaxmult; % tamanho m�ximo do grafo
itwnd = round(100000/pmax); % intervalo de itera��es entre cada grupo de dados
itlbl = itwnd * gmaxmult; % intervalo de itera��es para rotular grupo de dados
gsize = 0; % tamanho atual do grafo
psize = 0; % tamanho atual do conjunto de part�culas
pcnt = 1; % pr�xima part�cula a ser substitu�da
owner = zeros(Xsize,1);
lelrd = 0; % �ltimo elemento lido
llbwr = 0; % �ltimo r�tulo definido
Xwnd = zeros(gmax,size(X,2)); % dados que est�o no grafo atualmente
GX = zeros(gmax,1); % vetor com �ndices de cada elemento que est� no grafo
totiter = ceil(Xsize/gwnd)*itwnd + itwnd*(gmaxmult-1); % total de itera��es
% constantes
potmax = 1.000; % potencial m�ximo
potmin = 0.000; % potencial m�nimo
%npart = sum(slabel~=0); % quantidade de part�culas
%stopmax = round((qtnode/npart)*20); % qtde de itera��es para verificar converg�ncia
% tabela de potenciais de n�s
pot = repmat(potmax/nclass,gmax,nclass);
% definindo potencial da part�cula
potpart = repmat(potmax,pmax,1);
% criando tabela de classes de cada part�cula
partclass = zeros(pmax,1);
% criando tabela de posi��o inicial das part�culas
partpos=zeros(pmax,1);
% definindo tabela de dist�ncias dos n�s - Nos testes, piorou o resultado
%distnode = repmat(gmax-1,gmax,pmax);
for i=1:totiter
    % a cada intervalo de janela, devemos ler novos elementos
    if mod(i-1,itwnd)==0 && lelrd<Xsize        
        % tamanho da janela de novos elementos
        gnwnd = min(gwnd,Xsize - lelrd);
        % �ndice do primeiro e �ltimo n�
        nf = mod(lelrd,gmax)+1;
        nl = nf+gnwnd-1;
        % �ndice do primeiro e �ltimo elemento da janela
        ef = lelrd+1;
        el = lelrd+gnwnd;
        % se �ltimo elemento lido for maior que a quantidade m�xima de
        % n�s, temos de eliminar n�s para ter espa�o para os novos
        %disp(sprintf('Adicionando elementos %1.0f a %1.0f ao grafo',ef,el))
        if gsize < gmax
            gsize = gsize + gnwnd;
        end
        % movendo part�culas de n�s que ser�o eliminados
        for j=1:psize
            pmovc=0;
            % mudar esse c�digo para mover part�cula para n� mais dominado
            % da classe da part�cula (Exceto os que ser�o exclu�dos)
            while partpos(j)>=nf && partpos(j)<=nl                
                partpos(j) = random('unid',size(N{j},2));
                potpart(j) = pot(partpos(j),partclass(j));
                % contador pra evitar loop infinito
                pmovc = pmovc + 1;
                if pmovc == 10
                    %disp(sprintf('Evitando loop infinito da part�cula %1.0f',j))
                    break;
                end
            end
        end
        % copiando dados para a janela
        Xwnd(nf:nl,:) = X(ef:el,:);
        % copiando �ndices dos elementos em X para tabela de �ndices
        GX(nf:nl) = ef:el;
        % gerando matriz de afinidade
        W = squareform(pdist(Xwnd(1:gsize,:),disttype).^2); 
        graph = zeros(gsize,'single');
        % eliminando a dist�ncia para o pr�prio elemento
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
        % conectando �ltimos vizinhos do grafo (n�o precisa atualizar W pq n�o ser� mais usado)
        [~,ind] = min(W,[],2);
        for j=1:gsize
            graph(j,ind(j))=1;            
        end
       % conectando n�s com mesmo label - Nos testes piorou o resultado!
%        for l=1:gsize
%             for j=l+1:gsize
%                 if slabel(GX(l))~=0 && slabel(GX(l))==slabel(GX(j))
%                     graph(l,j)=1;
%                 end
%             end         
%         end
        % tornando liga��es rec�procas (grafo n�o direcionado)
        graph = max(graph,graph');
        % criando c�lula para listas de vizinhos
        N = cell(gsize,1);
        for j=1:gsize
            N{j} = find(graph(j,:)==1); % criando lista de vizinhos
        end
        % ajustando potenciais dos novos n�s
        pot(nf:nl,:) = repmat(potmax/nclass,gnwnd,nclass);
        % zerando tabela de dist�ncia de novos n�s
        distnode(nf:nl,:)=gmax-1;
        for l=1:gnwnd
            if slabel(lelrd+l)~=0
                % ajustando potencial do n� rotulado para 1 em sua classe e 
                % 0 nas demais
                pot(nf-1+l,:) = 0;
                pot(nf-1+l,slabel(lelrd+l)) = 1;
                % criando part�cula para o n� rotulado
                partclass(pcnt) = slabel(lelrd+l); % definindo r�tulo da part�cula
                %distnode(nf-1+l,partclass(pcnt))=0; % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de seu time                    
                partpos(pcnt) = nf-1+l; % definindo posi��o da part�cula para o n� rotulado
                potpart(pcnt) = 1; % definindo potencial da part�cula para n�vel m�ximo
                pcnt = pcnt + 1; % incrementa contador da pr�xima part�cula a ser eliminada
                % se contador passou do limite de part�culas, reinici�-lo
                if pcnt>pmax 
                    pcnt=1; 
                end
                % aumenta tamanho do conjunto de part�culas se ainda n�o chegou no m�ximo
                if psize<pmax 
                    psize = psize + 1; 
                end
            end
        end
        % incrementa contador de elementos j� lidos   
        lelrd = lelrd + gnwnd;
    end
    % Movimenta��o de part�culas
    rndtb = unifrnd(0,1,psize,1);  % probabilidade pdet
    roulettepick = unifrnd(0,1,psize,1);  % sorteio da roleta
    for j=1:psize
        if rndtb(j)<pdet
            % regra de probabilidade
            %prob = cumsum((1./(1+distnode(N{partpos(j)},partclass(j))).^2)'.* pot(N{partpos(j)},partclass(j))');
            prob = cumsum(pot(N{partpos(j)},partclass(j))');
            % descobrindo quem foi o n� sorteado
            k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
        else
            k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
        end
        % se o n� n�o � pr�-rotulado
        if slabel(GX(k))==0
            % calculando novos potenciais para n�
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
        end
        % atribui novo potencial para part�cula
        potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;

        % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
        %if distnode(partpos(j),partclass(j))+1<distnode(k,partclass(j))
            % atualizar dist�ncia do n� alvo
        %    distnode(k,partclass(j)) = distnode(partpos(j),partclass(j))+1;
        %end       
        
        % se n�o houve choque
        if pot(k,partclass(j))>=max(pot(k,:))
            % muda para n� alvo
            partpos(j) = k;
        end
    end
    % no intervalo de dados, rotular elementos
    if i>=itlbl && mod(i,itwnd)==0
        % tamanho da janela de elementos a rotular
        glwnd = min(gwnd,Xsize - llbwr);
        % �ndice do primeiro e �ltimo n�
        nf = mod(llbwr,gmax)+1;
        nl = nf+glwnd-1;
        % �ndice do primeiro e �ltimo elemento da janela
        ef = llbwr+1;
        el = llbwr+glwnd;
        % rotulando n�s
        %disp(sprintf('Rotulando elementos %1.0f a %1.0f',ef,el))
        [~,owner(ef:el)] = max(pot(nf:nl,:),[],2);
        % incrmenta contador de n�s j� rotulados
        llbwr = llbwr + glwnd;
    end
end

end

