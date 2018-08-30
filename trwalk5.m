% Territory Mark Walk
% Modelo Original
% Usage: [owner, pot] = trwalk5(graph, npart, iter, pdet, deltav, deltap)
function [owner, pot] = trwalk5(graph, npart, iter, pdet, deltav, deltap)
    if (nargin < 6) || isempty(deltap),
        deltap = 0.400; % controle de velocidade de aumento/decremento do potencial da part�cula
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.400; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 4) || isempty(pdet),
        pdet = 0.400; % probabilidade de n�o explorar
    end
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.005; % potencial m�nimo
    % tabela de potenciais de n�s
    pot = repmat(potmin,size(graph,1),1);
    % tabela de donos de territ�rios
    owner = zeros(size(graph,1),1);
    % definindo posi��o inicial das part�culas
    partpos = random('unid',size(graph,1),npart,1);
    % definindo potencial da part�cula
    potpart = repmat(potmin,npart,1);
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            if random('unif',0,1)<pdet
                % regra de probabilidade
                prob = graph(partpos(j),:)' .* (owner==0 | owner==j);
            else
                % regra de probabilidade
                prob = graph(partpos(j),:)';
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo n�
            roulettpick = random('unid',roulettsize);
            % descobrindo quem foi o n� sorteado
            k=1;
            while roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            % Se n� n�o tem dono
            if owner(k)==0
                partpos(j) = k;                
                owner(k)=j;
            % se part�cula j� � dona do n�
            elseif owner(k)==j
                partpos(j) = k;                
                potpart(j) = potpart(j) + (potmax - potpart(j)) * deltap;
                pot(k) = potpart(j); 
            % se n� � de outra part�cula
            else
                potpart(j) = potpart(j) - (potpart(j) - potmin) * deltap;
                pot(k) = pot(k) - deltav;                
                % se potencial do v�rtice baixou pra menos do m�nimo
                if pot(k)<potmin
                    % resetar dono do n�
                    owner(k)=0;
                    pot(k)=potmin;
                end
                % verificar se potencial da part�cula � menor que m�nimo
                % (isso nunca acontecer�)
                %if potpart(j)<potmin
                %    potpart(j) = potmin;  % potencial setado pro m�nimo
                %    partpos(j) = ceil(random('unif',0,size(graph,1))); % part�cula vai para n� escolhido aleatoriamente
                %end            
            end
        end
    end
end