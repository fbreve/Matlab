% Territory Mark Walk
% Usage: [owner, pot, logp, logn, lognc] = trwalk(graph, npart, iter)
function [owner, pot, logp, logn, lognc] = trwalk(graph, npart, iter)
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
    %partpos(1,:) = [1,1];
    %partpos(2,:) = [51,51];
    %partpos(3,:) = [101,101];
    %partpos(4,:) = [151,151];    
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
            % 40% probabilístico, 60% determinístico
            if random('unif',0,1)<0.6
                % selecionando nó (em que haja aresta) de maior potencial 
                % próprio ou menor potencial de outro
                [null,partpos(j)] = max(graph(partpos(j),:)'.*pot .* (1 - 2*(owner~=j)));
                % definindo tamanho da roleta
                %roulettsize = sum(graph(partpos(j),:).*(owner==0 | owner==j)');
                % girando a roleta para sortear o novo nó
                %roulettpick = random('unif',0,roulettsize);
                % descobrindo quem foi o nó sorteado
                %k=1;
                %while roulettpick>graph(partpos(j),k)*(owner(k)==0 || owner(k)==j)
                %    roulettpick = roulettpick - graph(partpos(j),k);
                %    k = k + 1;
                %end
                %partpos(j) = k;                                
            else
                % definindo tamanho da roleta
                roulettsize = sum(graph(partpos(j),:));
                % girando a roleta para sortear o novo nó
                roulettpick = random('unif',0,roulettsize);
                % descobrindo quem foi o nó sorteado
                k=1;
                while roulettpick>graph(partpos(j),k)
                    roulettpick = roulettpick - graph(partpos(j),k);
                    k = k + 1;
                end
                partpos(j) = k;
            end
            % Se nó não tem dono
            if owner(partpos(j))==0
                owner(partpos(j))=j;
                pot(partpos(j)) = potpart(j);
            % se partícula já é dona do nó
            elseif owner(partpos(j))==j
                potpart(j) = potpart(j) + (potmax-potpart(j))*deltap;
                pot(partpos(j))=potpart(j);               
                %pot(partpos(j)) = pot(partpos(j)) + (potmax-pot(partpos(j)))*deltav; 
            % se nó é de outra partícula
            else
                potpart(j) = potpart(j) - (potpart(j)-potmin)*deltap;
                pot(partpos(j)) = pot(partpos(j))-(3*potmax-pot(partpos(j)))*deltav;
                %pot(partpos(j)) = pot(partpos(j)) - (potmax-pot(partpos(j)))*deltav; 
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
        end
        logp(i,:)=potpart;
        logn(i)=mean(pot);
        lognc(i,:)=pot;
    end
end