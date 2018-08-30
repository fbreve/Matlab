% M�todo do artigo "Learning with Local and Global Consistency" 
% Autores: Dengyong Zhou, Olivier Bousquet, Thomas Navin Lal, Jason Weston,
% e Bernard Sch�lkopf
% Uso: [owner,ownfuz] = zhoug(W,slabel,alpha,nclass,iter)
% W = matriz de adjac�ncias
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% alpha = no inteverlo [0 1], define quantidade relativa de informa��o vinda dos
%         vizinhos e da informa��o inicial
% sigma = ?
% Vers�o G - recebe grafo como entrada
function [owner,ownfuz] = zhoug(W,slabel,alpha,nclass,iter)
if (nargin < 5) || isempty(iter),
    iter = 10000; % n�mero de itera��es
end
if (nargin < 4) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 3) || isempty(alpha),
    alpha = 0.99;
end
qtnode = size(W,1);  % quantidade de elementos
D = diag(sum(W,2));
DInv = sparse(D^(-1/2));
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
%disp('Iniciando itera��es');
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
ownfuz = F ./ repmat(sum(F,2),1,nclass);
%[nil,owner] = max(F,[],2); % quarto passo
end