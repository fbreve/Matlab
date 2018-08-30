% Matrix To Graph
% Transforma uma matriz de atributos (onde cada linha � uma amostra e cada
% coluna � um atributo) em um grafo atrav�s de dist�ncia euclidiana
% Usage: graph = mat2graph(X,sigma)
function graph = mat2graph(X,sigma)
    [l,c] = size(X);
    X = X - repmat(min(X),l,1);
    X = X ./ repmat(max(X),l,1);
    graph = exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2);
    graph = graph - eye(l);
    %graph = graph / max(max(graph));
    %graph = 1 - graph - eye(l);
end