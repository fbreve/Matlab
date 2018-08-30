% definindo posi��o inicial da part�cula
partpos = ceil(random('unif',0,size(grafo,1)));

for i=1:1:100
    % log
    log(i) = D(partpos);
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
    % mudando posi��o da part�cula para o pr�ximo n�
    partpos = j;
end