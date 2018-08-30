% Gera grafo conectando vizinhos com peso dado por kernel Gaussiano
% Uso: W = graphgensig(X,sigma)
% X = base de dados, cada linha um elemento, cada coluna um atributo
% Sigma = largura do kernel Gaussiano
function W = graphgensig(X,sigma,disttype,zeradiag)
    qtnode = size(X,1);
    W = exp(-squareform(pdist(X,disttype).^2)/2*sigma^2); % primeiro passo
    if zeradiag
        W = W - eye(qtnode);  % zerando diagonal
    end
end