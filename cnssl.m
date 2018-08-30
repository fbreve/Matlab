% Complex Networks Semi-Supervised Learning
% Usage: [owner, pot] = cnsslis5(img, imgslab, fw, k, disttype, valpha, maxiter)

function [owner, pot] = cnssl(X, slabel, k, disttype, valpha, nclass, maxiter)
if (nargin < 7) || isempty(maxiter)
    maxiter = 500000; % número de iterações
end
if (nargin < 6) || isempty(nclass)
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 5) || isempty(valpha)
    valpha = 20;
end
if (nargin < 4) || isempty(disttype)
    disttype = 'euclidean'; % distância euclidiana não normalizada
end
qtnode = size(X,1); % quantidade de nós
if (nargin < 3) || isempty(k)
    k = round(qtnode*0.05); % quantidade de vizinhos mais próximos
end
% tratamento da entrada
k = uint16(k);

slabel = uint16(slabel);
k = uint16(k);
% constantes
npart = sum(slabel~=0); % quantidade de partículas
stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência
% normalizar atributos se necessário
if strcmp(disttype,'seuclidean')==1
    X = zscore(X);
    disttype='euclidean';
end
nnonlabeled = sum(slabel==0); % quantidade de nós não rotulados

% lista de nós não rotulados
indnonlabeled = uint32(find(slabel==0));
% lista de nós rotulados
labelednodes = uint32(find(slabel>0));

% encontrando k-vizinhos mais próximos
[KNN,KNND] = knnsearch(X,X(indnonlabeled,:),'K',k+1,'NSMethod','kdtree','Distance',disttype);
KNN = uint32(KNN);
clear X;
KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo
KNND = KNND(:,2:end);
KNND = 1./(1+KNND);
% ajustando todas as distâncias na máxima possível
pot = repmat(1/nclass,qtnode,nclass);
% zerando potenciais dos nós rotulados
pot(labelednodes,:) = 0;
% ajustando potencial da classe respectiva do nó rotulado para máximo
pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;
% variável para guardar máximo potencial mais alto médio
pot = cnsslis5loop(maxiter,nnonlabeled,indnonlabeled,stopmax,pot,k,KNN,KNND);
[~,owner] = max(pot,[],2);

end