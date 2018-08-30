% Semi-Supervised Territory Mark Walk v.7 (vers�o para gerar s�ries
% temporais)
% Derivado de strwalk6.m
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Usage: [owner, pot, distnode, s_itr, s_acc, s_pot, s_prt, s_dst] = strwalk7series(X, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp, label)
function [owner, pot, distnode, s_itr, s_acc, s_pot, s_prt, s_dst] = strwalk7series(X, slabel, nclass, iter, pdet, deltav, deltap, sigma, dexp, label)
    if (nargin < 8) || isempty(sigma),
        sigma = 3; % exponencial da probabilidade
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % exponecial da probabilidade
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 4) || isempty(iter),
        iter = 100000; % n�mero de itera��es
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    qtnode = size(X,1); % quantidade de n�s
    npart = sum(slabel~=0); % quantidade de part�culas
    %graph = round(exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2)); % gerando grafo
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    graph = W <= sigma;  % gerando grafo com limiar sobre matriz de afinidade
    %B = sort(W,2);  % ordenando matriz de afinidade
    %G2 = W <= repmat(B(:,knn+1),1,qtnode);  % conectando k-vizinhos mais pr�ximos
    %graph = G1 | G2;  % juntando grafo limiar com grafo k-vizinhos
    graph = graph - eye(qtnode);  % zerando diagonal do grafo
    %graph = X;
    % tabela de potenciais de n�s
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da part�cula
    potpart = repmat(potmax,npart,1);
    % definindo hod�metro das part�culas
    odopart = zeros(npart,1);
    % definindo tabela de dist�ncias dos n�s
    distnode = repmat(qtnode-1,qtnode,npart);
    % criando tabela de classes de cada part�cula
    partclass = zeros(npart,1);
    % criando tabela de posi��o inicial das part�culas
    partpos=zeros(npart,1);    
    % verificando n�s rotulados e ajustando potenciais de acordo
    j=0;
    for i=1:qtnode
        % se n� � pr�-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            j = j + 1;
            partclass(j)=slabel(i);  % definindo classe da part�cula
            distnode(i,j)=0;        % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de sua respectiva part�cula
            partpos(j)=i;            % definindo posi��o inicial da part�cula para seu respectivo n� pr�-rotulado
        end
    end
    % definindo series temporais
    s_itr = zeros(iter,1);
    s_acc = zeros(iter,1);
    s_pot = zeros(iter,1);
    s_prt = zeros(iter,1);
    s_dst = zeros(iter,1);
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:).*(1./(alpha.^distnode(:,j)))';
                %
                prob = graph(partpos(j),:).*(1./(1+distnode(:,j)).^dexp)'.* pot(:,partclass(j))';  
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);   %.*pot(:,j)';
            end
            % definindo tamanho da roleta
            roulettesize = sum(prob);
            % girando a roleta para sortear o novo n�
            roulettepick = random('unif',0,roulettesize);
            % descobrindo quem foi o n� sorteado
            k=1;
            while k<=size(graph,1) && roulettepick>prob(k)
                roulettepick = roulettepick - prob(k);
                k = k + 1;
            end
            % indo para o n� sorteado
            if k>qtnode
                disp('Valor fora da roleta? Isso n�o deveria acontecer...')
                k = random('unid',size(graph,1)); % part�cula vai para n� escolhido aleatoriamente
            end
            % se o n� n�o � pr�-rotulado
            if slabel(k)==0
                % calculando novos potenciais para n�
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para part�cula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                      
            % se hod�metro da part�cula + caminho entre n� atual e n� alvo
            % menor que dist�ncia do n� alvo
            if odopart(j)+1<distnode(k,j)
                % atualizar dist�ncia do n� alvo
                distnode(k,j) = odopart(j)+1;
            end
            
            % se n�o houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % atualiza hod�metro da part�cula
                odopart(j) = odopart(j) + 1;
                % se hod�metro da part�cula maior que dist�ncia do n� alvo
                if(distnode(k,j)<odopart(j))
                    % ajustar hod�metro para dist�ncia do n� alvo
                    odopart(j) = distnode(k,j);
                end
                % muda para n� alvo
                partpos(j) = k;
            end          
        end
        % verificando donos
        [nil,owner] = max(pot,[],2);        
        % gravando series temporais
        s_itr(i) = i;
        s_acc(i) = stmweval(label,slabel,owner);
        s_pot(i) = mean(max(pot,[],2));
        s_prt(i) = mean(potpart);
        s_dst(i) = mean(odopart);
    end    
end

