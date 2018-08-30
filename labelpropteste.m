% M�todo "Label Propagation", de Zhu and Ghahramani (2002)
% Uso: owner = labelprop(X,slabel,sigma,disttype,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% sigma = largura do kernel gaussiano
function owner = labelpropteste(X,slabel,sigma,disttype,nclass,iter)
if (nargin < 6) || isempty(iter),
    iter = 10000; % n�mero de itera��es
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
noch = 0; % conta a quantas itera��es n�o houve mudan�a
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
%disp('Iniciando itera��es');
for j=1:iter  % terceiro passo - itera��es
    Y = DW * Y;
    Y = YTP .* YI + YTN .* Y;
    ownerbak = owner;
    [~,gowner] = max(Y,[],2);
    owner = single(gowner);
    if isequal(owner,ownerbak)  % se n�o houve mudan�a
        noch = noch + 1;
        if noch>=100  % testa converg�ncia
            break; 
        end
    else
        noch = 0;
    end
end
end