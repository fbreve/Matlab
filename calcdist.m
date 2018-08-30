function D = calcdist(grafo)

% criando lista de dist�ncias, iniciando todas com -1
D=-ones(size(grafo,1),1)
% definindo v�rtice de refer�ncia
ref = ceil(random('unif',0,size(grafo,1)));
D(ref)=0;
% colocando v�rtice na fila para verificar vizinhos
queue=[ref,0];
while not(isempty(queue))
    % pegando valores de posi��o e dist�ncia do primeiro da fila
    aux_pos = queue(1,1)
    aux_dist = queue(1,2)
    % para cada v�rtice
    for i=1:size(grafo,1)
        % verificar se � vizinho do primeiro da fila
        if grafo(aux_pos,i)==1
            % verificar se dist�ncia j� foi calculada
            if D(i)==-1
                % calcular dist�ncia
                D(i)=aux_dist+1;
                % colocar na fila
                queue(end+1,:)=[i,aux_dist+1];
            end
        end
    end
    % removendo primeiro da fila
    queue(1,:)=[];
end