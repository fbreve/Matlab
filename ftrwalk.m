% Fuzzy Territory Mark Walk
% Marca quanto tempo cada part�cula � dona de cada n�
% Usage: [ownertab, pot, ownch, logp, logn, lognc] = ftrwalk(graph, npart, iter, deltap, deltav, pdet, log)
function [ownertab, pot, ownch, logp, logn, lognc] = ftrwalk(graph, npart, iter, deltap, deltav, pdet, log)
    if (nargin < 7) || isempty(log),
        log = false; 
    end
    if (nargin < 6) || isempty(pdet),
        pdet = 0.400; % probabilidade de n�o explorar
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.400; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 4) || isempty(deltap),
        deltap = 0.400; % controle de velocidade de aumento/decremento do potencial da part�cula
    end    
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.005; % potencial m�nimo
    ownch  = 0.000;     % contagem de mudan�as de dono
    % tabela de potenciais de n�s
    pot = ones(size(graph,1),1)*potmin;
    % tabela de donos de territ�rios
    owner = zeros(size(graph,1),1);
    % tabela fuzzy de donos de territ�rios
    ownertab = zeros(size(graph,1),npart);
    % definindo posi��o inicial das part�culas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    %partpos = [1 33 65 97];
    % definindo potencial da part�cula
    potpart = ones(npart,1)*potmin;
    % logs de potenciais
    if (log)
        logp = zeros(iter,npart);
        logn = zeros(iter,1);
        lognc = zeros(iter,size(graph,1));
    end
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % calculando probabilidade de explora��o
            %if random('unif',0,1)<(pdet + i/iter*(1-pdet))
            if random('unif',0,1)<pdet
                % regra de probabilidade
                prob = graph(partpos(j),:)' .* pot .* (owner==0 | owner==j);
            else
                % regra de probabilidade
                prob = graph(partpos(j),:)';
            end
            % definindo tamanho da roleta
            roulettsize = sum(prob);
            % girando a roleta para sortear o novo n�
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o n� sorteado
            k=1;
            while roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            partpos(j) = k;          
            % Se n� n�o tem dono
            if owner(partpos(j))==0
                owner(partpos(j))=j;
            % se part�cula j� � dona do n�
            elseif owner(partpos(j))==j
                potnew = potpart(j) + deltap * pot(partpos(j));
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
                potpart(j) = potnew;
                % se potencial do n� maior do que o m�ximo
                if pot(partpos(j))>potmax
                    pot(partpos(j)) = potmax;
                end
                % verificar se potencial da part�cula � maior que m�ximo
                if potpart(j)>potmax
                    potpart(j) = potmax;  % potencial setado pro m�nimo
                end                  
            % se n� � de outra part�cula
            else
                potnew = potpart(j) - deltap * pot(partpos(j));
                pot(partpos(j)) = pot(partpos(j)) - deltav * potpart(j); 
                potpart(j) = potnew;                
                % se potencial do v�rtice baixou pra menos do m�nimo
                if pot(partpos(j))<potmin
                    % trocar dono do n�
                    owner(partpos(j))=j;
                    pot(partpos(j))=potmin;
                    ownch = ownch + 1;
                end
                % verificar se potencial da part�cula � menor que m�nimo
                if potpart(j)<potmin
                    potpart(j) = potmin;  % potencial setado pro m�nimo
                    partpos(j) = ceil(random('unif',0,size(graph,1))); % part�cula vai para n� escolhido aleatoriamente
                end            
            end
        end
        % somar donos na tabela fuzzy
        % para cada n�
        for j=1:size(graph,1)
            if owner(j)>0
                ownertab(j,owner(j))=ownertab(j,owner(j))+1;
            end
        end       
        if (log)
            logp(i,:)=potpart;
            logn(i)=mean(pot);
            lognc(i,:)=pot;        
        end
    end
    ownch = ownch / size(graph,1);
    % normalizar tabela fuzzy
    if i>iter/10 % eliminar transiente
        for j=1:size(graph,1)
            if owner(j)>0
                ownertab(j,:) = ownertab(j,:) ./ sum(ownertab(j,:));
            end
        end      
    end
end