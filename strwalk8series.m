% Semi-Supervised Territory Mark Walk v.8 (vers�o para gerar s�ries
% temporais)
% Derivado de strwalk7.m
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Aceita diretamente o grafo como entrada em vez de X (v.8g)
% Usage: [owner, pot, owndeg, distnode, s_itr, s_acc, s_pot, s_prt, s_dst]
% = strwalk8series(graph, label, slabel, nclass, iter, pdet, deltav,
% deltap, dexp)
function [owner, pot, owndeg, distnode, s_itr, s_acc, s_pot, s_prt] = strwalk8series(graph, label, slabel, nclass, iter, pdet, deltav, deltap, dexp)
    if (nargin < 9) || isempty(dexp),
        dexp = 2.0; % exponencial da probabilidade
    end
    if (nargin < 8) || isempty(deltap),
        deltap = 1.00; % controle de velocidade de aumento/decermento do potencial da part�cula
    end
    if (nargin < 7) || isempty(deltav),
        deltav = 0.35; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 6) || isempty(pdet),
        pdet = 0.70; % probabilidade de n�o explorar
    end
    if (nargin < 5) || isempty(iter),
        iter = 50000; % n�mero de itera��es
    end
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    qtnode = size(graph,1); % quantidade de n�s
    npart = sum(slabel~=0); % quantidade de part�culas
    % tabela de potenciais de n�s
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da part�cula
    potpart = repmat(potmax,npart,1);
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
    % definindo grau de propriedade
    owndeg = repmat(realmin,qtnode,nclass);  % n�o podemos usar 0, porque n�s n�o visitados dariam divis�o por 0
    % definindo series temporais
    s_itr = zeros(iter,1);
    s_acc = zeros(iter,1);
    s_pot = zeros(iter,1);
    s_prt = zeros(iter,1);
    s_dst = zeros(iter,1);    
    for i=1:iter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);
        for j=1:npart
            % calculando probabilidade de explora��o
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
            % girando a roleta para sortear o novo n�
            roulettepick = unifrnd(0,prob(end));
            % descobrindo quem foi o n� sorteado
            k = find(prob>=roulettepick,1,'first');           
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
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
                      
            % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
            if distnode(partpos(j),j)+1<distnode(k,j)
                % atualizar dist�ncia do n� alvo
                distnode(k,j) = distnode(partpos(j),j)+1;
            end
            
            % se n�o houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % muda para n� alvo
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