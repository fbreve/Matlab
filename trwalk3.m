% Territory Mark Walk
% Usage: [owner, pot, logp, logn, lognc] = trwalk3(graph, npart, iter)
function [owner, pot, logp, logn, lognc] = trwalk3(graph, npart, iter)
    % constantes
    potmax = 1.000; % potencial máximo da partícula
    potmin = 0.005; % potencial mínimo da partícula
    deltap = 0.1; % controle de velocidade de aumento/decremento do potencial da partícula  
    deltav = 0.1; % controle de velocidade de aumento/decremento do potencial do vértice
    % tabela de potenciais de nós
    pot = ones(size(graph,1),1)*potmin;
    % tabela de donos de territórios
    owner = zeros(size(graph,1),1);
    % definindo posição inicial das partículas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    % definindo potencial da partícula
    potpart = ones(npart,1)*potmin;
    % logs de potenciais
    logp = zeros(iter,npart);
    logn = zeros(iter,1);
    lognc = zeros(iter,size(graph,1));    
    % para cada iteração
    for i=1:iter
        % para cada partícula
        for j=1:npart
            % temperatura
            T = i/iter;
            %regra de probabilidade
            prob = (graph(partpos(j),:)' .* (0.5 + (0.5 - (owner~=j & owner~=0)) .* pot)).^T;
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
                %pot(partpos(j)) = potpart(j);
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
            % se partícula já é dona do nó
            elseif owner(partpos(j))==j
                potpart(j) = potpart(j) + (potmax-potpart(j)) * deltap;
                %pot(partpos(j)) = potpart(j);               
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
            % se nó é de outra partícula
            else
                potpart(j) = potpart(j) - (potpart(j)-potmin) * deltap;
                pot(partpos(j)) = pot(partpos(j)) - deltav * potpart(j);
                % se potencial do vértice baixou pra menos do mínimo
                if pot(partpos(j))<potmin
                    % resetar dono do nó
                    owner(partpos(j))=j;
                    pot(partpos(j))=potmin;
                end
            end
            % verificar se potencial da partícula é menor que mínimo
            if potpart(j)<potmin
                potpart(j) = potmin;  % potencial setado pro mínimo
                partpos(j) = ceil(random('unif',0,size(graph,1))); % partícula vai para nó escolhido aleatoriamente
            end
            if pot(partpos(j))>potmax
                pot(partpos(j)) = potmax;
            end           
        end
        logp(i,:)=potpart;
        logn(i)=mean(pot);
        lognc(i,:)=pot;
    end
end