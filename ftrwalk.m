% Fuzzy Territory Mark Walk
% Marca quanto tempo cada partícula é dona de cada nó
% Usage: [ownertab, pot, ownch, logp, logn, lognc] = ftrwalk(graph, npart, iter, deltap, deltav, pdet, log)
function [ownertab, pot, ownch, logp, logn, lognc] = ftrwalk(graph, npart, iter, deltap, deltav, pdet, log)
    if (nargin < 7) || isempty(log),
        log = false; 
    end
    if (nargin < 6) || isempty(pdet),
        pdet = 0.400; % probabilidade de não explorar
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.400; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 4) || isempty(deltap),
        deltap = 0.400; % controle de velocidade de aumento/decremento do potencial da partícula
    end    
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.005; % potencial mínimo
    ownch  = 0.000;     % contagem de mudanças de dono
    % tabela de potenciais de nós
    pot = ones(size(graph,1),1)*potmin;
    % tabela de donos de territórios
    owner = zeros(size(graph,1),1);
    % tabela fuzzy de donos de territórios
    ownertab = zeros(size(graph,1),npart);
    % definindo posição inicial das partículas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    %partpos = [1 33 65 97];
    % definindo potencial da partícula
    potpart = ones(npart,1)*potmin;
    % logs de potenciais
    if (log)
        logp = zeros(iter,npart);
        logn = zeros(iter,1);
        lognc = zeros(iter,size(graph,1));
    end
    % para cada iteração
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % calculando probabilidade de exploração
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
            % girando a roleta para sortear o novo nó
            roulettpick = random('unif',0,roulettsize);
            % descobrindo quem foi o nó sorteado
            k=1;
            while roulettpick>prob(k)
                roulettpick = roulettpick - prob(k);
                k = k + 1;
            end
            partpos(j) = k;          
            % Se nó não tem dono
            if owner(partpos(j))==0
                owner(partpos(j))=j;
            % se partícula já é dona do nó
            elseif owner(partpos(j))==j
                potnew = potpart(j) + deltap * pot(partpos(j));
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
                potpart(j) = potnew;
                % se potencial do nó maior do que o máximo
                if pot(partpos(j))>potmax
                    pot(partpos(j)) = potmax;
                end
                % verificar se potencial da partícula é maior que máximo
                if potpart(j)>potmax
                    potpart(j) = potmax;  % potencial setado pro mínimo
                end                  
            % se nó é de outra partícula
            else
                potnew = potpart(j) - deltap * pot(partpos(j));
                pot(partpos(j)) = pot(partpos(j)) - deltav * potpart(j); 
                potpart(j) = potnew;                
                % se potencial do vértice baixou pra menos do mínimo
                if pot(partpos(j))<potmin
                    % trocar dono do nó
                    owner(partpos(j))=j;
                    pot(partpos(j))=potmin;
                    ownch = ownch + 1;
                end
                % verificar se potencial da partícula é menor que mínimo
                if potpart(j)<potmin
                    potpart(j) = potmin;  % potencial setado pro mínimo
                    partpos(j) = ceil(random('unif',0,size(graph,1))); % partícula vai para nó escolhido aleatoriamente
                end            
            end
        end
        % somar donos na tabela fuzzy
        % para cada nó
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