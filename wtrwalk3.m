% Weighted Fuzzy Territory Mark Walk v.3
% Cada n� tem n potenciais, onde n � o n�mero de part�culas
% Choque quando part�cula visita n� que n�o � dominado por ela
% Potencial de part�cula usa medida de m�dia de potencial da part�cula em
% todos os n�s (tentativa de detectar comunidades de tamanhos diferentes)
% Usage: [owner, pot, log] = wtrwalk3(graph, npart, iter, pdet, deltav, deltap, probexp)
function [owner, pot, log] = wtrwalk3(graph, npart, iter, pdet, deltav, deltap, probexp)
    if (nargin < 7) || isempty(probexp),
        probexp = 20; % exponecial da probabilidade
    end
    if (nargin < 6) || isempty(deltap),
        deltap = 1.000; % exponecial da probabilidade
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.300; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 4) || isempty(pdet),
        pdet = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 3) || isempty(deltav),
        iter = 20000; % n�mero de itera��es
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    % tabela de potenciais de n�s
    pot = repmat(potmax/npart,size(graph,1),npart);
    % definindo posi��o inicial das part�culas
    partpos = random('unid',size(graph,1),npart,1);
    % definindo potencial da part�cula
    potpart = repmat(potmin,npart,1);
    % log
    log = zeros(iter,npart+1);
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            %if random('unif',0,1)<(pdet + i/iter*(1-pdet))
            if random('unif',0,1)<pdet
                % regra de probabilidade
                prob = graph(partpos(j),:) .* pot(:,j)';
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);
            end
            if probexp>0
                prob = prob.^(1+((i/iter)*probexp));
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo n�
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o n� sorteado
            k=1;
            while k<=size(graph,1) && roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            % indo para o n� sorteado
            if k>size(graph,1)
                disp('Valor fora da roleta? Isso n�o deveria acontecer...')
                k = random('unid',size(graph,1)); % part�cula vai para n� escolhido aleatoriamente
            end
            % calculando novos potenciais para n�
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*deltav/npart);
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,j) = pot(k,j) + sum(deltapotpart);
            % atribui novo potencial para part�cula
            % potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;
            potpart(j) = mean([mean(pot(:,j)).^2 pot(k,j)]);
            % verifica se houve choque
            if pot(k,j)>=max(pot(k,:))
                % se n�o houve choque muda para pr�ximo n�
                partpos(j) = k;
            end
        end
        log(i,:) = [i mean(pot)];
    end
    [nil,owner] = max(pot,[],2);
end