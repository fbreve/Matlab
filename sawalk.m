% definindo contadores de passagem da partícula
cont = zeros(size(grafo,1),1);   % nós
arccount = zeros(size(grafo));

% definindo posição inicial da partícula
partpos = ceil(random('unif',0,size(grafo,1)));

% iniciar log
log = 0;

for T=1:-0.00001:0
    % definindo o tamanho da roleta
    roulettsize = sum(T.^(1 -grafo(partpos,:)));
    % girando a roleta para sortear o novo nó
    roulettpick = random('unif',0,roulettsize);
    % descobrindo quem foi o nó sorteado
    j=1;
    while roulettpick>T^(1 - grafo(partpos,j))
        roulettpick = roulettpick - T^(1 - grafo(partpos,j));
        j = j + 1;
    end
    % incrementando contador do nó sorteado
    cont(j) = cont(j) + (1 - T);
    
    % incrementando contador do arco sorteado
    arccount(partpos,j) = arccount(partpos,j) + (1 - T);
     
    % mudando posição da partícula para o próximo nó
    partpos = j;
    % log
    if mod(log,100)==0
        for k=1:size(grafo,1)
            hist(log/100+1,:)=cont;
        end
    end
    log = log + 1;
end