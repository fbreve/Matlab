function grafo = graphmess(grafo)
for i=1:size(grafo)
    x=ceil(random('unif',0,300));
    y=ceil(random('unif',0,300));
    aux = grafo(:,x);
    grafo(:,x) = grafo(:,y);
    grafo(:,y) = aux;
    aux = grafo(x,:);
    grafo(x,:) = grafo(y,:);
    grafo(y,:) = aux;
end