% definindo contadores de passagem da part�cula
cont = zeros(size(grafo,1),1);   % n�s
arccount = zeros(size(grafo));

% definindo posi��o inicial da part�cula
partpos = ceil(random('unif',0,size(grafo,1)));

% iniciar log
log = 0;

for T=1:-0.00001:0
    % definindo o tamanho da roleta
    roulettsize = sum(T.^(1 -grafo(partpos,:)));
    % girando a roleta para sortear o novo n�
    roulettpick = random('unif',0,roulettsize);
    % descobrindo quem foi o n� sorteado
    j=1;
    while roulettpick>T^(1 - grafo(partpos,j))
        roulettpick = roulettpick - T^(1 - grafo(partpos,j));
        j = j + 1;
    end
    % incrementando contador do n� sorteado
    cont(j) = cont(j) + (1 - T);
    
    % incrementando contador do arco sorteado
    arccount(partpos,j) = arccount(partpos,j) + (1 - T);
     
    % mudando posi��o da part�cula para o pr�ximo n�
    partpos = j;
    % log
    if mod(log,100)==0
        for k=1:size(grafo,1)
            hist(log/100+1,:)=cont;
        end
    end
    log = log + 1;
end