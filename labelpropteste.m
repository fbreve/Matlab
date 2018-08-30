% Método "Label Propagation", de Zhu and Ghahramani (2002)
% Uso: owner = labelprop(X,slabel,sigma,disttype,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com rótulo numérico (>0) dos elementos pré-rotulados (0 para 
%          elementos não rotulados)
% nclass = número de classes
% iter = número de iterações
% sigma = largura do kernel gaussiano
function owner = labelpropteste(X,slabel,sigma,disttype,nclass,iter)
if (nargin < 6) || isempty(iter),
    iter = 10000; % número de iterações
end
if (nargin < 5) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 4) || isempty(disttype),
    disttype = 'euclidean';
end
qtnode = size(X,1);  % quantidade de elementos
%disp('Criando rede');
W = exp(gpuArray(single(-squareform(pdist(X,disttype).^2)/2*sigma^2))); % primeiro passo
%disp('Rede criada');
%W = W - eye(qtnode);  % zerando diagonal
D = diag(sum(W,2));
%D = diag(sum(W,2));
Y = gpuArray.zeros(qtnode,nclass,'single'); 
noch = 0; % conta a quantas iterações não houve mudança
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
[~,gowner] = max(Y,[],2);
owner = single(gowner);
DW = D\W;
clear D W;
YI = Y;
YTP = gpuArray(repmat(single(slabel~=0),1,nclass));
YTN = 1-YTP;
%disp('Iniciando iterações');
for j=1:iter  % terceiro passo - iterações
    Y = DW * Y;
    Y = YTP .* YI + YTN .* Y;
    ownerbak = owner;
    [~,gowner] = max(Y,[],2);
    owner = single(gowner);
    if isequal(owner,ownerbak)  % se não houve mudança
        noch = noch + 1;
        if noch>=100  % testa convergência
            break; 
        end
    else
        noch = 0;
    end
end
end