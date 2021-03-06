% M�todo do artigo "Learning with Local and Global Consistency" 
% Autores: Dengyong Zhou, Olivier Bousquet, Thomas Navin Lal, Jason Weston,
% e Bernard Sch�lkopf
% Uso: owner = zhou(X,slabel,nclass,iter,alpha,sigma)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% alpha = no inteverlo [0 1], define quantidade relativa de informa��o vinda dos
%         vizinhos e da informa��o inicial
% sigma = ?
function owner = zhou(X,slabel,nclass,iter,alpha,sigma)
qtnode = size(X,1);  % quantidade de elementos
W = exp(-squareform(pdist(X,'seuclidean').^2)/2*sigma^2); % primeiro passo
W = W - eye(qtnode);  % zerando diagonal
D = diag(sum(W,2));
S = D^(-1/2) * W * D^(-1/2); % segundo passo
clear W D;
Y = zeros(qtnode,nclass); 
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
F = Y;
[~,owner] = max(F,[],2);
for i=1:iter  % terceiro passo - itera��es
    F = alpha * S * F + (1 - alpha) * Y;
    ownerbak = owner;
    [~,owner] = max(F,[],2);
    if sum(ownerbak~=owner)==0  % se n�o houve mudan�a
        noch = noch + 1;
        if noch>=100  % testa converg�ncia
            break; 
        end
    else
        noch = 0;
    end
end
%[nil,owner] = max(F,[],2); % quarto passo
end