% Semi-Supervised Territory Mark Walk v.1
% Derivado de wtrwalk2.m
% n�s pr�-rotulados possuem potencial m�ximo e imut�vel para respectiva
% part�cula
% Usage: [owner, pot] = strwalk(X, slabel, npart, iter, reset, pdet, deltav, deltap, sigma)
function [owner, pot] = strwalk(X, slabel, npart, iter, reset, pdet, deltav, deltap, sigma)
    if (nargin < 9) || isempty(sigma),
        sigma = 10; % exponecial da probabilidade
    end
    if (nargin < 8) || isempty(deltap),
        deltap = 1.000; % exponecial da probabilidade
    end
    if (nargin < 7) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 6) || isempty(pdet),
        pdet = 0.600; % probabilidade de n�o explorar
    end
    if (nargin < 5) || isempty(reset),
        iter = 100; % n�mero de itera��es at� resetar
    end
    if (nargin < 4) || isempty(iter),
        iter = 100000; % n�mero de itera��es
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    qtnode = size(X,1); % quantidade de n�s
    graph = exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2); % gerando grafo
    graph = graph - eye(qtnode);  % zerando diagonal do grafo
    % tabela de potenciais de n�s
    pot = repmat(potmax/npart,qtnode,npart);
    % verificando n�s rotulados e ajustando potenciais de acordo
    for i=1:qtnode
        % se n� � pr�-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
        end
    end
    % definindo posi��o inicial das part�culas
    partpos=zeros(npart,1);
    for j=1:npart
        resetparticle;
    end
    % definindo potencial da part�cula
    potpart = repmat(potmax,npart,1);
    % definindo tabela de donos
    %[nil,owner] = max(pot,[],2);
    % teste de convergencia
    %noch = 0;
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            %if random('unif',0,1)<(pdet + i/iter*(1-pdet))
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = (graph(partpos(j),:).^(1+probexp+cos(i*(1/iter)*2*pi)*probexp)).*pot(:,j)';
                prob = graph(partpos(j),:).*pot(:,j)';
            else
                % regra de probabilidade
                %prob = graph(partpos(j),:).^(1+probexp+cos(i*(1/iter)*2*pi)*probexp);
                prob = graph(partpos(j),:);
            end
            %prob = prob.^(1+probexp+cos(i*(1/iter)*2*pi)*probexp);
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
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(npart-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,j) = pot(k,j) + sum(deltapotpart);            
            end
            % verifica se n�o � hora de resetar part�culas
            if mod(i,reset)~=0
                % atribui novo potencial para part�cula
                potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;
                % verifica se houve choque
                if pot(k,j)>=max(pot(k,:))
                    % se n�o houve choque muda para pr�ximo n�
                    partpos(j) = k;
                end
            else
                potpart(j) = 1;
                resetparticle;
            end
        end
        % teste de convergencia
%         ownerbak = owner;
%         [nil,owner] = max(pot,[],2);
%         if sum(ownerbak~=owner)==0  % se n�o houve mudan�a
%             noch = noch + 1;
%             if noch>=20000  % testa converg�ncia
%                 break;
%             end
%         else
%             noch = 0;
%         end
    end
    [nil,owner] = max(pot,[],2);
    
    function resetparticle
        % se existe pelo menos um n� pr�-rotulado para tal part�cula
        if sum(slabel==j)>0
            t=j;  % colocar part�cula em um dos n�s rotulados
        else
            t=0;  % colocar part�cula em qualquer n� n�o rotulado
        end
        % sortear um dos n�s alvo
        roulettepick = random('unid',sum(slabel==t));
        m=0;
        while roulettepick>0
            m = m + 1;
            roulettepick = roulettepick - (slabel(m)==t);
        end
        partpos(j)=m;
    end
end

