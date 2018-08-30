% definindo contadores de passagem da part�cula
cont = zeros(size(grafo,1),1);   % n�s

% definindo posi��o inicial da part�cula
partpos = ceil(random('unif',0,size(grafo,1)));

% iniciar log
log = 0;

for i=1:100000
    % definindo o tamanho da roleta
    roulettsize = sum(grafo(partpos,:));
    % girando a roleta para sortear o novo n�
    roulettpick = random('unif',0,roulettsize);
    % descobrindo quem foi o n� sorteado
    j=1;
    while roulettpick>(grafo(partpos,j))
        roulettpick = roulettpick - grafo(partpos,j);
        j = j + 1;
    end
    % incrementando contador do n� sorteado
    cont(j) = cont(j) + 1;
    
    % atualizando pesos
    grafo(partpos,:) = grafo(partpos,:) - 0.001/size(grafo,1);
    grafo(partpos,j) = grafo(partpos,j) + 0.001;
    
    % aplicando restri��es de intervalo [0-1]
    for i2 = 1:size(grafo,1)
        if grafo(partpos,i2)>1 
            grafo(partpos,:)= grafo(partpos,:) - grafo(partpos,i2) + 1;
        end
    end
    for i2 = 1:size(grafo,1)
        if grafo(partpos,i2)<0
            grafo(partpos,i2)=0;
        end        
    end
       
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