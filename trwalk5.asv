% Territory Mark Walk
% Modelo Original
% Usage: [owner, pot] = trwalk5(graph, npart, iter, pdet, deltav, deltap)
function [owner, pot] = trwalk5(graph, npart, iter, pdet, deltav, deltap)
    if (nargin < 6) || isempty(deltap),
        deltap = 0.400; % controle de velocidade de aumento/decremento do potencial da partícula
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.400; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 4) || isempty(pdet),
        pdet = 0.400; % probabilidade de não explorar
    end
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.005; % potencial mínimo
    % tabela de potenciais de nós
    pot = repmat(potmin,size(graph,1),1);
    % tabela de donos de territórios
    owner = zeros(size(graph,1),1);
    % definindo posição inicial das partículas
    partpos = random('unid',size(graph,1),npart,1);
    % definindo potencial da partícula
    potpart = repmat(potmin,npart,1);
    % para cada iteração
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
            if random('unif',0,1)<pdet
                % regra de probabilidade
                prob = graph(partpos(j),:)' .* (owner==0 | owner==j);
            else
                % regra de probabilidade
                prob = graph(partpos(j),:)';
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo nó
            roulettpick = random('unid',roulettsize);
            % descobrindo quem foi o nó sorteado
            k=1;
            while roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            % Se nó não tem dono
            if owner(k)==0
                partpos(j) = k;                
                owner(k)=j;
            % se partícula já é dona do nó
            elseif owner(k)==j
                partpos(j) = k;                
                potpart(j) = potpart(j) + (potmax - potpart(j)) * deltap;
                pot(k) = potpart(j); 
            % se nó é de outra partícula
            else
                potpart(j) = potpart(j) - (potpart(j) - potmin) * deltap;
                pot(k) = pot(k) - deltav;                
                % se potencial do vértice baixou pra menos do mínimo
                if pot(k)<potmin
                    % resetar dono do nó
                    owner(k)=0;
                    pot(k)=potmin;
                end
                % verificar se potencial da partícula é menor que mínimo
                % (isso nunca acontecerá)
                %if potpart(j)<potmin
                %    potpart(j) = potmin;  % potencial setado pro mínimo
                %    partpos(j) = ceil(random('unif',0,size(graph,1))); % partícula vai para nó escolhido aleatoriamente
                %end            
            end
        end
    end
end