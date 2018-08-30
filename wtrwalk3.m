% Weighted Fuzzy Territory Mark Walk v.3
% Cada nó tem n potenciais, onde n é o número de partículas
% Choque quando partícula visita nó que não é dominado por ela
% Potencial de partícula usa medida de média de potencial da partícula em
% todos os nós (tentativa de detectar comunidades de tamanhos diferentes)
% Usage: [owner, pot, log] = wtrwalk3(graph, npart, iter, pdet, deltav, deltap, probexp)
function [owner, pot, log] = wtrwalk3(graph, npart, iter, pdet, deltav, deltap, probexp)
    if (nargin < 7) || isempty(probexp),
        probexp = 20; % exponecial da probabilidade
    end
    if (nargin < 6) || isempty(deltap),
        deltap = 1.000; % exponecial da probabilidade
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.300; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 4) || isempty(pdet),
        pdet = 0.500; % probabilidade de não explorar
    end
    if (nargin < 3) || isempty(deltav),
        iter = 20000; % número de iterações
    end
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    % tabela de potenciais de nós
    pot = repmat(potmax/npart,size(graph,1),npart);
    % definindo posição inicial das partículas
    partpos = random('unid',size(graph,1),npart,1);
    % definindo potencial da partícula
    potpart = repmat(potmin,npart,1);
    % log
    log = zeros(iter,npart+1);
    % para cada iteração
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
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
            % girando a roleta para sortear o novo nó
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o nó sorteado
            k=1;
            while k<=size(graph,1) && roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            % indo para o nó sorteado
            if k>size(graph,1)
                disp('Valor fora da roleta? Isso não deveria acontecer...')
                k = random('unid',size(graph,1)); % partícula vai para nó escolhido aleatoriamente
            end
            % calculando novos potenciais para nó
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*deltav/npart);
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,j) = pot(k,j) + sum(deltapotpart);
            % atribui novo potencial para partícula
            % potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;
            potpart(j) = mean([mean(pot(:,j)).^2 pot(k,j)]);
            % verifica se houve choque
            if pot(k,j)>=max(pot(k,:))
                % se não houve choque muda para próximo nó
                partpos(j) = k;
            end
        end
        log(i,:) = [i mean(pot)];
    end
    [nil,owner] = max(pot,[],2);
end