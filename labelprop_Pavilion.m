% M�todo "Label Propagation", de Zhu and Ghahramani (2002)
% Uso: owner = labelprop(X,slabel,nclass,iter,sigma)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% sigma = largura do kernel gaussiano
function owner = labelprop(X,slabel,nclass,iter,sigma)
qtnode = size(X,1);  % quantidade de elementos
W = exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2); % primeiro passo
%W = W - eye(qtnode);  % zerando diagonal
D = diag(sum(W,2));
Y = zeros(qtnode,nclass); 
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
[nil,owner] = max(Y,[],2);
for j=1:iter  % terceiro passo - itera��es
    Y = D^(-1) * W * Y;
    for i=1:qtnode
        if slabel(i)~=0
            Y(i,:)=0;
            Y(i,slabel(i))=1;
        end
    end
    ownerbak = owner;
    [nil,owner] = max(Y,[],2);
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