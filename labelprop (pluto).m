% M�todo "Label Propagation", de Zhu and Ghahramani (2002)
% Uso: owner = labelprop(X,slabel,sigma,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% sigma = largura do kernel gaussiano
function owner = labelprop(X,slabel,sigma,nclass,iter)
if (nargin < 5) || isempty(iter),
    iter = 10000; % n�mero de itera��es
end
if (nargin < 4) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
qtnode = size(X,1);  % quantidade de elementos
%disp('Criando rede');
W = exp(-squareform(pdist(X,'euclidean').^2)/2*sigma^2); % primeiro passo
%disp('Rede criada');
%W = W - eye(qtnode);  % zerando diagonal
D = diag(sum(W,2));
Y = zeros(qtnode,nclass); 
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
[~,owner] = max(Y,[],2);
DInv = sparse(D^(-1));
clear D;
DW = DInv * W;
clear DInv W;
YI = Y;
YTP = repmat(slabel~=0,1,nclass);
YTN = 1-YTP;
%disp('Iniciando itera��es');
for j=1:iter  % terceiro passo - itera��es
    Y = DW * Y;
    Y = YTP .* YI + YTN .* Y;
    ownerbak = owner;
    [~,owner] = max(Y,[],2);
    if sum(ownerbak~=owner)==0  % se n�o houve mudan�a
        noch = noch + 1;
        if noch>=100  % testa converg�ncia
            break; 
        end
    else
        noch = 0;
    end
end
end