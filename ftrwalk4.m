% Fuzzy Territory Mark Walk v.4
% Cada n� tem n potenciais, onde n � o n�mero de part�culas
% Valores finais s�o calculados pela m�dia de potencial dos vizinhos
% Usage: [owner, owndeg] = ftrwalk4(graph, npart, iter, pdet, deltav)
function [owner, owndeg] = ftrwalk4(graph, npart, iter, pdet, deltav)
    if (nargin < 5) || isempty(pdet),
        pdet = 0.600; % probabilidade de n�o explorar
    end
    if (nargin < 4) || isempty(deltav),
        deltav = 0.300; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    % tabela de potenciais de n�s
    pot = ones(size(graph,1),npart)*potmax/npart;
    % definindo posi��o inicial das part�culas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    % definindo potencial da part�cula
    potpart = ones(npart,1)*potmin;
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
            if k<=size(graph,1)
                partpos(j) = k;          
            else
                disp('Valor fora da roleta? Isso n�o deveria acontecer... resetando part�cula')
                partpos(j) = ceil(random('unif',0,size(graph,1))); % part�cula vai para n� escolhido aleatoriamente
            end 
            % calcula mudan�a de potencial do n�
            deltapotpart = deltav * potpart(j);
            % diminui todos os potenciais do n�
            pot(partpos(j),:) = pot(partpos(j),:) - deltapotpart/npart;
            % aumenta potencial do n� referente a part�cula que est�
            % nele
            pot(partpos(j),j) = pot(partpos(j),j) + deltapotpart; 
            % garantindo que nenhum potencial fique abaixo do m�nimo
            pot(partpos(j),j) = pot(partpos(j),j) + sum(min(pot(partpos(j),:),potmin));
            pot(partpos(j),:) = max(pot(partpos(j),:),potmin);
            % atribui novo potencial para part�cula
            potpart(j) = pot(partpos(j),j);           
        end
    end
    owndeg = (graph * pot) ./ (sum(graph,2) * ones(1,npart));
    [nil,owner] = max(owndeg,[],2);
end