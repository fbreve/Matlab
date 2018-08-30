% Método Linear Neighborhood Propagation de Fei Wang et. al.
% Uso: [owner,ownfuz] = lnpg(W,slabel,alpha,nclass,iter)
% W = matriz de adjacências
% slabel = vetor com rótulo numérico (>0) dos elementos pré-rotulados (0 para 
%          elementos não rotulados)
% nclass = número de classes
% iter = número de iterações
% alpha = no inteverlo [0 1], define quantidade relativa de informação vinda dos
%         vizinhos e da informação inicial
% versão G - recebe grafo como entrada
function [owner,ownfuz] = lnpg(W,slabel,alpha,nclass,iter)
if (nargin < 5) || isempty(iter),
    iter = 10000; % número de iterações
end
if (nargin < 4) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 3) || isempty(alpha),
    alpha = 0.99;
end
qtnode = size(W,1);  % quantidade de elementos e atributos
Y = zeros(qtnode,nclass);
noch = 0; % conta a quantas iterações não houve mudança
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
%disp('Iniciando iterações')
for i=1:iter 
     F = alphaW * F + alphaY;
     ownerbak = owner;
     [~,owner] = max(F,[],2);
     if sum(ownerbak~=owner)==0  % se não houve mudança
         noch = noch + 1;
         if noch>=100  % testa convergência
             break; 
         end
     else
         noch = 0;
     end
end
ownfuz = F ./ repmat(sum(F,2),1,nclass);
end