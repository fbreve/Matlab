% Fuzzy Territory Mark Walk
% Cada nó tem n potenciais, onde n é o número de partículas
% Probabilidade deterministica proporcional aos vizinhos do nó a ser
% visitado
% Usage: [owner, pot] = ftrwalk3(graph, npart, iter, pdet, deltav)
function [owner, pot] = ftrwalk3(graph, npart, iter, pdet, deltav)
    if (nargin < 5) || isempty(pdet),
        pdet = 0.600; % probabilidade de não explorar
    end
    if (nargin < 4) || isempty(deltav),
        deltav = 0.300; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    % tabela de potenciais de nós
    pot = ones(size(graph,1),npart)*potmax/npart;
    % tabela de potenciais acumulados
    potacc = ones(size(graph,1),npart)*potmax/npart;
    % definindo posição inicial das partículas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    % definindo potencial da partícula
    potpart = ones(npart,1)*potmin;
    % para cada iteração
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
            %if random('unif',0,1)<(pdet + i/iter*(1-pdet))
            if random('unif',0,1)<pdet
                % regra de probabilidade (proporcional ao potencial da
                % partícula nos vizinhos do nó a ser visitado)
                %prob = graph(partpos(j),:) .* (sum(graph .* (pot(:,j)*ones(size(graph,1),1)'),2) ./ sum(graph,2))';
                prob = graph(partpos(j),:) .* sum(graph .* (pot(:,j)*ones(size(graph,1),1)'),2)';
            else
                % regra de probabilidade
                prob = graph(partpos(j),:);
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo nó
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o nó sorteado
            k=1;
            while k<=size(graph,1) && roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            if k<=size(graph,1)
                partpos(j) = k;          
            else
                disp('Valor fora da roleta? Isso não deveria acontecer... resetando partícula')
                partpos(j) = ceil(random('unif',0,size(graph,1))); % partícula vai para nó escolhido aleatoriamente
            end 
            % calcula mudança de potencial do nó
            deltapotpart = deltav * potpart(j);
            % diminui todos os potenciais do nó
            pot(partpos(j),:) = pot(partpos(j),:) - deltapotpart/npart;
            % aumenta potencial do nó referente a partícula que está
            % nele
            pot(partpos(j),j) = pot(partpos(j),j) + deltapotpart; 
            % garantindo que nenhum potencial fique abaixo do mínimo
            pot(partpos(j),j) = pot(partpos(j),j) + sum(min(pot(partpos(j),:),potmin));
            pot(partpos(j),:) = max(pot(partpos(j),:),potmin);
            % atribui novo potencial para partícula
            potpart(j) = pot(partpos(j),j);
        end
    end
    [nil,owner] = max(pot,[],2);
end