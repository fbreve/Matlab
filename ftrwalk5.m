% Fuzzy Territory Mark Walk v.5
% Baseado em ftrwalk4 e strwalk7
% Cada n� tem n potenciais, onde n � o n�mero de part�culas
% Valores fuzzy obtidos com contagem de visitas ponderada por potencial de
% part�cula (contando apenas visitas no movimento aleat�rio)
% Usage: [owner, pot, owndeg] = ftrwalk5(graph, npart, iter, pdet, deltav, deltap)
function [owner, pot, owndeg] = ftrwalk5(graph, npart, iter, pdet, deltav, deltap)
    if (nargin < 5) || isempty(pdet),
        pdet = 0.600; % probabilidade de n�o explorar
    end
    if (nargin < 4) || isempty(deltav),
        deltav = 0.300; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    qtnode = size(graph,1); % quantidade de n�s   
    % tabela de potenciais de n�s
    pot = repmat(potmax/npart,qtnode,npart);
    % definindo posi��o inicial das part�culas
    partpos = ceil(random('unif',zeros(npart,1),qtnode));
    % definindo potencial da part�cula
    potpart = repmat(potmin,npart,1);
    % definindo grau de propriedade
    owndeg = repmat(0,qtnode,npart);
    % series temporais
    %s_pot = zeros(iter,1);
    %s_acc = zeros(iter,1);
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            %if random('unif',0,1)<(pdet + i/iter*(1-pdet))
            if random('unif',0,1)<pdet
                % regra de probabilidade
                %prob = graph(partpos(j),:) .* (pot(:,j)>=max(pot,[],2))';
                prob = graph(partpos(j),:) .* pot(:,j)';
                movtype = 0;
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);
                movtype = 1;
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo n�
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o n� sorteado
            k=1;
            while k<=qtnode && roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            if k>qtnode
                disp('Valor fora da roleta? Isso n�o deveria acontecer...')
                k = random('unid',size(graph,1)); % part�cula vai para n� escolhido aleatoriamente
            end
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,j) = owndeg(k,j) + potpart(j);
            end
            % calculando novos potenciais para n�
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(npart-1)));
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,j) = pot(k,j) + sum(deltapotpart);
            % atribui novo potencial para part�cula
            potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;                               
            % se n�o houve choque
            if pot(k,j)>=max(pot(k,:))
                % muda para n� alvo
                partpos(j) = k;
            end
        end
        %[nil,owner] = max(pot,[],2);
        %s_acc(i) = tmweval(label,owner);
        %s_pot(i) = mean(max(pot,[],2));
    end
    [nil,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,npart);
end