% M�todo Linear Neighborhood Propagation de Fei Wang et. al.
% Uso: [owner,ownfuz] = lnpg(W,slabel,alpha,nclass,iter)
% W = matriz de adjac�ncias
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% alpha = no inteverlo [0 1], define quantidade relativa de informa��o vinda dos
%         vizinhos e da informa��o inicial
% vers�o G - recebe grafo como entrada
function [owner,ownfuz] = lnpg(W,slabel,alpha,nclass,iter)
if (nargin < 5) || isempty(iter),
    iter = 10000; % n�mero de itera��es
end
if (nargin < 4) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 3) || isempty(alpha),
    alpha = 0.99;
end
qtnode = size(W,1);  % quantidade de elementos e atributos
Y = zeros(qtnode,nclass);
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
F = Y;
[~,owner] = max(F,[],2);
alphaW = alpha * W;
clear W;
alphaY = (1 - alpha) * Y;
clear Y;
%disp('Iniciando itera��es')
for i=1:iter 
     F = alphaW * F + alphaY;
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
ownfuz = F ./ repmat(sum(F,2),1,nclass);
end