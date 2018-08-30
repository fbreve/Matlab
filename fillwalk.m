% definindo contadores de passagem da partícula
cont = zeros(size(grafo,1),1);

% definindo posição inicial da partícula
partpos = ceil(random('unif',0,size(grafo,1)));

for i=1:1000000
    % definindo o tamanho da roleta
    roulettsize = sum(grafo(partpos,:));
    % girando a roleta para sortear o novo nó
    roulettpick = random('unif',0,roulettsize);
    % descobrindo quem foi o nó sorteado
    j=1;
    while roulettpick>grafo(partpos,j)
        roulettpick = roulettpick - grafo(partpos,j);
        j = j + 1;
    end
    % log
    log(i) = grafo(partpos,j);
    % incrementando contador do nó sorteado
    cont(j) = cont(j) + 1;    
    % atualizando peso da aresta selecionada
    grafo(partpos,j) = grafo(partpos,j) - 0.001;
    if sum(grafo(:)) < 0
        break;
    end
    % saída na tela
    if rem(i,1000) == 0
        grafo
    end
    % log
    %if rem(log,100)==0
        for k=1:size(grafo,1)
            hist(i,:)=cont;
        end
    %end
    log = log + 1;
    % mudando posição da partícula para o próximo nó
    partpos = j;
end