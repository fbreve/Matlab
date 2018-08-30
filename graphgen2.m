% Gerador de grafo sem peso, conectado
% Baseado nas regras gera��o usadas em: "Comparing community structure identification"
% de Leon Danon, Albert D�?az-Guilera1, Jordi Duch2 and Alex Arenas.
% Journal of Statistical Mechanics: An IOP and SISSA journal Theory and
% Experiment, 2008.
% Uso: [graph, label] = graphgen2(csize,zout,k)
% Par�metros:
% csize = vetor com n elementos onde n � o n�mero de comunidades a serem geradas e os valores indicam quantos elementos tem cada comunidade
% zout = m�dia de conex�es externas dos v�rtices da rede
% k = grau m�dio da rede
% Sa�da:
% grafo = matriz de adjac�ncias do grafo gerado
% label = vetor com os labels de cada n� do grafo gerado
function [graph, label] = graphgen2(csize,zout,k)
%disp(sprintf('Zout/k: %.4f',zout/k))
graph = zeros(sum(csize));
label = zeros(sum(csize),1);

% construindo vetor com label de cada n�
c=1;
for i=1:size(csize,2)
    for j=1:csize(i)
        label(c)=i;
        c = c + 1;
    end   
end

% conectando cada v�rtice com o v�rtice de �ndice vizinho
for i=1:(sum(csize)-1)
    graph(i,i+1)=1;
    graph(i+1,i)=1;
end
graph(1,sum(csize))=1;
graph(sum(csize),1)=1;

% calculando total de liga��es internas e externas
tout = round(zout*sum(csize)*0.5);
tin  = round((k*sum(csize)*0.5)-tout);

% descontando liga��es j� feitas com a regra do vizinho
tout = tout - size(csize,2);
tin  = tin  - (sum(csize) - size(csize,2));

% criar conex�es at� zerar totais
while (tout>0 || tin>0)
    % gerando par aleat�rio de n�s
    node = ceil(random('unif',0,sum(csize),2,1));
    % se ainda n�o h� conex�o entre eles
    if graph(node(1),node(2))==0 && node(1)~=node(2)
        % se s�o do mesmo grupo
        if label(node(1))==label(node(2)) 
            % se ainda s�o necess�rias conex�es internas
            if tin>0
                graph(node(1),node(2))=1;
                graph(node(2),node(1))=1;
                tin = tin - 1;
            end
        % se s�o de grupos diferentes
        else
            % se ainda s�o necess�rias conex�es externas
            if tout>0
                graph(node(1),node(2))=1;
                graph(node(2),node(1))=1;
                tout = tout - 1;
            end
        end
    end
end;