% Método do artigo "Learning with Local and Global Consistency" 
% Autores: Dengyong Zhou, Olivier Bousquet, Thomas Navin Lal, Jason Weston,
% e Bernard Schölkopf
% Uso: [owner,ownfuz] = zhoug(W,slabel,alpha,nclass,iter)
% W = matriz de adjacências
% slabel = vetor com rótulo numérico (>0) dos elementos pré-rotulados (0 para 
%          elementos não rotulados)
% nclass = número de classes
% iter = número de iterações
% alpha = no inteverlo [0 1], define quantidade relativa de informação vinda dos
%         vizinhos e da informação inicial
% sigma = ?
% Versão G - recebe grafo como entrada
function [owner,ownfuz] = zhoug(W,slabel,alpha,nclass,iter)
if (nargin < 5) || isempty(iter),
    iter = 10000; % número de iterações
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
noch = 0; % conta a quantas iterações não houve mudança
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
%disp('Iniciando iterações');
for i=1:iter  % terceiro passo - iterações
    F = alphaS * F + alphaY;
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
%[nil,owner] = max(F,[],2); % quarto passo
end