% Territory Mark Walk
% Usage: [owner, pot, logp, logn, lognc] = trwalk3(graph, npart, iter)
function [owner, pot, logp, logn, lognc] = trwalk3(graph, npart, iter)
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
            % temperatura
            T = i/iter;
            %regra de probabilidade
            prob = (graph(partpos(j),:)' .* (0.5 + (0.5 - (owner~=j & owner~=0)) .* pot)).^T;
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
                %pot(partpos(j)) = potpart(j);
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
            % se part�cula j� � dona do n�
            elseif owner(partpos(j))==j
                potpart(j) = potpart(j) + (potmax-potpart(j)) * deltap;
                %pot(partpos(j)) = potpart(j);               
                pot(partpos(j)) = pot(partpos(j)) + deltav * potpart(j); 
            % se n� � de outra part�cula
            else
                potpart(j) = potpart(j) - (potpart(j)-potmin) * deltap;
                pot(partpos(j)) = pot(partpos(j)) - deltav * potpart(j);
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
            if pot(partpos(j))>potmax
                pot(partpos(j)) = potmax;
            end           
        end
        logp(i,:)=potpart;
        logn(i)=mean(pot);
        lognc(i,:)=pot;
    end
end