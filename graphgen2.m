% Gerador de grafo sem peso, conectado
% Baseado nas regras geração usadas em: "Comparing community structure identification"
% de Leon Danon, Albert D´?az-Guilera1, Jordi Duch2 and Alex Arenas.
% Journal of Statistical Mechanics: An IOP and SISSA journal Theory and
% Experiment, 2008.
% Uso: [graph, label] = graphgen2(csize,zout,k)
% Parâmetros:
% csize = vetor com n elementos onde n é o número de comunidades a serem geradas e os valores indicam quantos elementos tem cada comunidade
% zout = média de conexões externas dos vértices da rede
% k = grau médio da rede
% Saída:
% grafo = matriz de adjacências do grafo gerado
% label = vetor com os labels de cada nó do grafo gerado
function [graph, label] = graphgen2(csize,zout,k)
%disp(sprintf('Zout/k: %.4f',zout/k))
graph = zeros(sum(csize));
label = zeros(sum(csize),1);

% construindo vetor com label de cada nó
c=1;
for i=1:size(csize,2)
    for j=1:csize(i)
        label(c)=i;
        c = c + 1;
    end   
end

% conectando cada vértice com o vértice de índice vizinho
for i=1:(sum(csize)-1)
    graph(i,i+1)=1;
    graph(i+1,i)=1;
end
graph(1,sum(csize))=1;
graph(sum(csize),1)=1;

% calculando total de ligações internas e externas
tout = round(zout*sum(csize)*0.5);
tin  = round((k*sum(csize)*0.5)-tout);

% descontando ligações já feitas com a regra do vizinho
tout = tout - size(csize,2);
tin  = tin  - (sum(csize) - size(csize,2));

% criar conexões até zerar totais
while (tout>0 || tin>0)
    % gerando par aleatório de nós
    node = ceil(random('unif',0,sum(csize),2,1));
    % se ainda não há conexão entre eles
    if graph(node(1),node(2))==0 && node(1)~=node(2)
        % se são do mesmo grupo
        if label(node(1))==label(node(2)) 
            % se ainda são necessárias conexões internas
            if tin>0
                graph(node(1),node(2))=1;
                graph(node(2),node(1))=1;
                tin = tin - 1;
            end
        % se são de grupos diferentes
        else
            % se ainda são necessárias conexões externas
            if tout>0
                graph(node(1),node(2))=1;
                graph(node(2),node(1))=1;
                tout = tout - 1;
            end
        end
    end
end;