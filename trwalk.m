% Territory Mark Walk
% Usage: [owner, pot, logp, logn, lognc] = trwalk(graph, npart, iter)
function [owner, pot, logp, logn, lognc] = trwalk(graph, npart, iter)
    % constantes
    potmax = 1.000; % potencial m�ximo da part�cula
    potmin = 0.005; % potencial m�nimo da part�cula
    deltap = 0.1; % controle de velocidade de aumento/decremento do potencial da part�cula  
    deltav = 0.1; % controle de velocidade de aumento/decremento do potencial do v�rtice
    % tabela de potenciais de n�s
    pot = ones(size(graph,1),1)*potmin;
    % tabela de donos de territ�rios
    owner = zeros(size(graph,1),1);
    % definindo posi��o inicial das part�culas
    partpos = ceil(random('unif',zeros(npart,1),size(graph,1)));
    %partpos(1,:) = [1,1];
    %partpos(2,:) = [51,51];
    %partpos(3,:) = [101,101];
    %partpos(4,:) = [151,151];    
    % definindo potencial da part�cula
    potpart = ones(npart,1)*potmin;
    % logs de potenciais
    logp = zeros(iter,npart);
    logn = zeros(iter,1);
    lognc = zeros(iter,size(graph,1));
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        for j=1:npart
            % 40% probabil�stico, 60% determin�stico
            if random('unif',0,1)<0.6
                % selecionando n� (em que haja aresta) de maior potencial 
                % pr�prio ou menor potencial de outro
                [null,partpos(j)] = max(graph(partpos(j),:)'.*pot .* (1 - 2*(owner~=j)));
                % definindo tamanho da roleta
                %roulettsize = sum(graph(partpos(j),:).*(owner==0 | owner==j)');
                % girando a roleta para sortear o novo n�
                %roulettpick = random('unif',0,roulettsize);
                % descobrindo quem foi o n� sorteado
                %k=1;
                %while roulettpick>graph(partpos(j),k)*(owner(k)==0 || owner(k)==j)
                %    roulettpick = roulettpick - graph(partpos(j),k);
                %    k = k + 1;
                %end
                %partpos(j) = k;                                
            else
                % definindo tamanho da roleta
                roulettsize = sum(graph(partpos(j),:));
                % girando a roleta para sortear o novo n�
                roulettpick = random('unif',0,roulettsize);
                % descobrindo quem foi o n� sorteado
                k=1;
                while roulettpick>graph(partpos(j),k)
                    roulettpick = roulettpick - graph(partpos(j),k);
                    k = k + 1;
                end
                partpos(j) = k;
            end
            % Se n� n�o tem dono
            if owner(partpos(j))==0
                owner(partpos(j))=j;
                pot(partpos(j)) = potpart(j);
            % se part�cula j� � dona do n�
            elseif owner(partpos(j))==j
                potpart(j) = potpart(j) + (potmax-potpart(j))*deltap;
                pot(partpos(j))=potpart(j);               
                %pot(partpos(j)) = pot(partpos(j)) + (potmax-pot(partpos(j)))*deltav; 
            % se n� � de outra part�cula
            else
                potpart(j) = potpart(j) - (potpart(j)-potmin)*deltap;
                pot(partpos(j)) = pot(partpos(j))-(3*potmax-pot(partpos(j)))*deltav;
                %pot(partpos(j)) = pot(partpos(j)) - (potmax-pot(partpos(j)))*deltav; 
                % se potencial do v�rtice baixou pra menos do m�nimo
                if pot(partpos(j))<potmin
                    % resetar dono do n�
                    owner(partpos(j))=j;
                    pot(partpos(j))=potmin;
                end
            end
            % verificar se potencial da part�cula � menor que m�nimo
            if potpart(j)<potmin
                potpart(j) = potmin;  % potencial setado pro m�nimo
                partpos(j) = ceil(random('unif',0,size(graph,1))); % part�cula vai para n� escolhido aleatoriamente
            end
        end
        logp(i,:)=potpart;
        logn(i)=mean(pot);
        lognc(i,:)=pot;
    end
end