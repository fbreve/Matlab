% Gerador de slabel heur�stico (n�s rotulados = classe, n�s n�o rotulados = 0)
% Uso: slabel = slabelheur(X)
% X = dataset
% Define os pontos mais remotos nas 4 dire��es (norte, sul, leste, oeste)
% de um problema de 2 dimens�es como sendo os n�s rotulados.
function slabel = slabelheur(X)
    qtnode = size(X,1);         % quantidade de n�s
    slabel = zeros(qtnode,1);       % vetor slabel
    [y,ind] = min(X(:,1));
    slabel(ind) = 1;
    [y,ind] = min(X(:,2));
    slabel(ind) = 2;
    [y,ind] = max(X(:,1));
    slabel(ind) = 3;
    [y,ind] = max(X(:,2));
    slabel(ind) = 4;
end
