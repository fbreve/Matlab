% Fill Territory Mark Walk v.2
% Nó passa seu label para um vizinho
% Em caso de choque nó volta ao estado vazio
% Em caso de reforço nada acontece
% Usage: [owner, log] = fillwalk3(graph, npart, iter)
function [owner, log] = fillwalk3(graph, npart, iter)
    if (nargin < 3) || isempty(iter),
        iter = 20000; % número de iterações
    end
    % quantidade de nós
    qtnode = size(graph,1);
    % tabela de donos de nós
    owner = zeros(qtnode,1);
    % definindo nós que iniciam com labels
    i=1;
    while i<=npart
        r = random('unid',qtnode);
        if owner(r)==0
            owner(r)=i;
            i = i + 1;
        end
    end
%     owner(1)=1;
%     owner(65)=2;
    % pré-alocando log
    log = zeros(iter,npart);
    % para cada iteração
    for i=1:iter
        % para cada nó
        for j=1:qtnode
            % verificando se nó em questão tem dono
            if owner(j)~=0
                % calculando probabilidade de infectar outro nó
                if random('unif',0,1) > sum(owner==j)/sum(owner~=0)
                    % escolher vizinho a ser "infectado"
                    % probabilidade 1 de "infectar" vizinhos e 0 p/ não-vizinhos
                    prob = graph(j,:);
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
                    % valor fora da roleta?
                    if k>qtnode
                        disp('Valor fora da roleta? Isso não deveria acontecer...')
                    end 
                    % se nó sorteado é vazio, infectá-lo
                    if owner(k)==0
                        owner(k)=owner(j);
                    % se houve colisão
                    elseif owner(k)~=owner(j)
                        owner(k)=0;
                        %owner(j)=0;
                    end
                end
            end
        end
        % log
        for j=1:npart
            log(i,j) = sum(owner==j);
        end
    end
end