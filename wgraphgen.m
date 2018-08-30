%function [graph,label] = wgraphgen(csize,wc,wl)
function [graph,label] = wgraphgen(csize,wc,wl)

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
            graph(i,j)=random('unif',wc,1);
            graph(j,i)=graph(i,j);
        else
            graph(i,j)=random('unif',0,wl);
            graph(j,i)=graph(i,j);
        end    
    end
end