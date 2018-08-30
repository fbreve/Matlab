% Gerador de grafo com peso
% Uso: [graph, label] = wgraphgen2(csize,ml)
% Parâmetros:
% csize = vetor com n elementos onde n é o número de comunidades a serem
% ml = nível de mistura no intervalo [0 - 1]
%   onde 0 significa que peso será 1 intercluster e 0 intracluster
%   e 1 significa totalmente aleatório
%   valores intermediários significam valor aleatório elevado a ml
function [graph,label] = wgraphgen2(csize,ml)

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

for i=1:sum(csize)
    for j=i:sum(csize)
        if i==j
            graph(i,j)=0;
        elseif label(i)==label(j) 
            graph(i,j)=random('unif',0,1)^ml;
            graph(j,i)=graph(i,j);
        else
            graph(i,j)=1-random('unif',0,1)^ml;
            graph(j,i)=graph(i,j);
        end    
    end
end