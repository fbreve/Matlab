% definindo contadores de passagem da part�cula
cont = zeros(size(grafo,1),1);

% definindo posi��o inicial da part�cula
partpos = ceil(random('unif',0,size(grafo,1)));

for i=1:1000000
    % definindo o tamanho da roleta
    roulettsize = sum(grafo(partpos,:));
    % girando a roleta para sortear o novo n�
    roulettpick = random('unif',0,roulettsize);
    % descobrindo quem foi o n� sorteado
    j=1;
    while roulettpick>grafo(partpos,j)
        roulettpick = roulettpick - grafo(partpos,j);
        j = j + 1;
    end
    % log
    log(i) = grafo(partpos,j);
    % incrementando contador do n� sorteado
    cont(j) = cont(j) + 1;    
    % atualizando peso da aresta selecionada
    grafo(partpos,j) = grafo(partpos,j) - 0.001;
    if sum(grafo(:)) < 0
        break;
    end
    % sa�da na tela
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
    % mudando posi��o da part�cula para o pr�ximo n�
    partpos = j;
end