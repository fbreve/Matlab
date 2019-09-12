% Método do artigo "Learning with Local and Global Consistency" 
% Autores: Dengyong Zhou, Olivier Bousquet, Thomas Navin Lal, Jason Weston,
% e Bernard Schölkopf
% Uso: owner = zhou(X,slabel,sigma,alpha,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com rótulo numérico (>0) dos elementos pré-rotulados (0 para 
%          elementos não rotulados)
% nclass = número de classes
% iter = número de iterações
% alpha = no inteverlo [0 1], define quantidade relativa de informação vinda dos
%         vizinhos e da informação inicial
% sigma = largura do kernel gaussiano
function owner = zhou(X,slabel,sigma,disttype,alpha,nclass,iter)
if (nargin < 7) || isempty(iter),
    iter = 10000; % número de iterações
end
if (nargin < 6) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 5) || isempty(alpha),
    alpha = 0.99;
end
if (nargin < 4) || isempty(disttype),
    disttype = 'euclidean';
end
qtnode = size(X,1);  % quantidade de elementos
%disp('Criando rede');
W = exp(-squareform(pdist(X,disttype).^2)/2*sigma^2); % primeiro passo
W = W - eye(qtnode);  % zerando diagonal
%disp('Rede criada');
D = diag(sum(W,2));
DInv = sparse(D^(-1/2));
clear D;
S = DInv * W * DInv; % segundo passo
clear W DInv;
Y = zeros(qtnode,nclass); 
labelednodes = find(slabel);
Y(sub2ind(size(Y),labelednodes,slabel(labelednodes))) = 1;
noch = 0; % conta a quantas iterações não houve mudança
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
%[nil,owner] = max(F,[],2); % quarto passo
end