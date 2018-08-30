function D = calcdist(grafo)

% criando lista de distâncias, iniciando todas com -1
D=-ones(size(grafo,1),1)
% definindo vértice de referência
ref = ceil(random('unif',0,size(grafo,1)));
D(ref)=0;
% colocando vértice na fila para verificar vizinhos
queue=[ref,0];
while not(isempty(queue))
    % pegando valores de posição e distância do primeiro da fila
    aux_pos = queue(1,1)
    aux_dist = queue(1,2)
    % para cada vértice
    for i=1:size(grafo,1)
        % verificar se é vizinho do primeiro da fila
        if grafo(aux_pos,i)==1
            % verificar se distância já foi calculada
            if D(i)==-1
                % calcular distância
                D(i)=aux_dist+1;
                % colocar na fila
                queue(end+1,:)=[i,aux_dist+1];
            end
        end
    end
    % removendo primeiro da fila
    queue(1,:)=[];
end