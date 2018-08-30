% Matrix To Non-Weighted Graph
% Transforma uma matriz de atributos (onde cada linha � uma amostra e cada
% coluna � um atributo) em um grafo sem pesos atrav�s de dist�ncia euclidiana
% Usage: graph = mat2nwgraph(X,sigma)
function graph = mat2nwgraph(X,sigma)
    qtnode = size(X,1); % quantidade de n�s    
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    graph = W <= sigma;  % gerando grafo com limiar sobre matriz de afinidade
    graph = graph - eye(qtnode);  % zerando diagonal do grafo   
end