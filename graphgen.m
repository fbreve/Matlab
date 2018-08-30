% Gerador de grafo sem peso
% Uso: [graph, label] = graphgen(csize,wc,wl)
% Par�metros:
% csize = vetor com n elementos onde n � o n�mero de comunidades a serem geradas e os valores indicam quantos elementos tem cada comunidade
% wc = probabilidade de conex�o entre cada par de v�rtices de uma mesma comunidade
% wl = probabilidade de conex�o entre cada par de v�rtices de comunidades diferentes
% Sa�da:
% grafo = matriz de adjac�ncias do grafo gerado
% label = vetor com os labels de cada n� do grafo gerado
function [graph, label] = graphgen(csize,wc,wl)

graph = zeros(sum(csize));
label = zeros(sum(csize),1);
randmat = random('unif',0,1,sum(csize));

% construindo vetor com label de cada n�
c=1;
for i=1:size(csize,2)
    for j=1:csize(i)
        label(c)=i;
        c = c + 1;
    end   
end

% construindo grafo
for i=1:sum(csize)
    for j=i:sum(csize)
        if label(i)==label(j) 
            if randmat(i,j)<=wc && i~=j
                graph(i,j)=1;
                graph(j,i)=1;
            end
        elseif randmat(i,j)<=wl
            graph(i,j)=1;
            graph(j,i)=1;           
        end
    end
end