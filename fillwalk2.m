% Fill Territory Mark Walk v.2
% N� passa seu label para um vizinho
% Em caso de choque n� volta ao estado vazio
% Em caso de refor�o nada acontece
% Usage: [owner, log] = fillwalk2(graph, npart, iter)
function [owner, log] = fillwalk2(graph, npart, iter)
    if (nargin < 3) || isempty(iter),
        iter = 20000; % n�mero de itera��es
    end
    % tabela de donos de n�s
    owner = zeros(size(graph,1),1);
    % definindo n�s que iniciam com labels
    i=1;
    while i<=npart
        r = random('unid',size(graph,1));
        if owner(r)==0
            owner(r)=i;
            i = i + 1;
        end
    end
    % pr�-alocando log
    log = zeros(iter,npart);
    % para cada itera��o
    for i=1:iter
        % para cada n�
        for j=1:size(graph,1)
            % verificando se n� em quest�o tem dono
            if owner(j)~=0
                % probabilidade 1 de "infectar" vizinhos e 0 p/ n�o-vizinhos
                prob = graph(j,:);
                % definindo tamanho da roleta
                roulettsize = sum(prob);
                % girando a roleta para sortear o novo n�
                roulettpick = random('unif',0,roulettsize);
                % descobrindo quem foi o n� sorteado
                k=1;
                while k<=size(graph,1) && roulettpick>prob(k)
                    roulettpick = roulettpick - prob(k);
                    k = k + 1;
                end
                % valor fora da roleta?
                if k>size(graph,1)
                    disp('Valor fora da roleta? Isso n�o deveria acontecer...')
                end 
                % se n� sorteado � vazio, infect�-lo
                if owner(k)==0
                    owner(k)=owner(j);
                % se houve colis�o
                elseif owner(k)~=owner(j)
                    owner(k)=0;
                end
            end
        end
        % log
        for j=1:npart
            log(i,j) = sum(owner==j);
        end
    end
end