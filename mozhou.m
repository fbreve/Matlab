% M�todo do artigo "Learning with Local and Global Consistency" 
% Autores: Dengyong Zhou, Olivier Bousquet, Thomas Navin Lal, Jason Weston,
% e Bernard Sch�lkopf
% Uso: owner = zhou(X,slabel,sigma,alpha,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% alpha = no inteverlo [0 1], define quantidade relativa de informa��o vinda dos
%         vizinhos e da informa��o inicial
% sigma = ?
% MO = Otimizado para ocupar menos mem�ria
function owner = mozhou(X,slabel,sigma,alpha,nclass,iter)
if (nargin < 6) || isempty(iter),
    iter = 10000; % n�mero de itera��es
end
if (nargin < 5) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 4) || isempty(alpha),
    alpha = 0.99;
end
qtnode = size(X,1);  % quantidade de elementos
disp('Criando rede');
W = exp(-squareform(pdist(X,'euclidean').^2)/2*sigma^2); % primeiro passo
W = W - eye(qtnode);  % zerando diagonal
disp('Rede criada');
D = single(diag(sum(W,2)));
DInv = sparse(double(D^(-1/2)));
clear D;
S = DInv * W * DInv; % segundo passo
clear W DInv;
Y = zeros(qtnode,nclass); 
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
F = Y;
[~,owner] = max(double(F),[],2);
alphaS = alpha * S;
clear S;
alphaY = (1 - alpha) * Y;
clear Y;
disp('Iniciando itera��es');
for i=1:iter  % terceiro passo - itera��es
    F = alphaS * F + alphaY;
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