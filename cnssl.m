% Complex Networks Semi-Supervised Learning
% Usage: [owner, pot] = cnsslis5(img, imgslab, fw, k, disttype, valpha, maxiter)

function [owner, pot] = cnssl(X, slabel, k, disttype, valpha, nclass, maxiter)
if (nargin < 7) || isempty(maxiter)
    maxiter = 500000; % n�mero de itera��es
end
if (nargin < 6) || isempty(nclass)
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 5) || isempty(valpha)
    valpha = 20;
end
if (nargin < 4) || isempty(disttype)
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
qtnode = size(X,1); % quantidade de n�s
if (nargin < 3) || isempty(k)
    k = round(qtnode*0.05); % quantidade de vizinhos mais pr�ximos
end
% tratamento da entrada
k = uint16(k);

slabel = uint16(slabel);
k = uint16(k);
% constantes
npart = sum(slabel~=0); % quantidade de part�culas
stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
% normalizar atributos se necess�rio
if strcmp(disttype,'seuclidean')==1
    X = zscore(X);
    disttype='euclidean';
end
nnonlabeled = sum(slabel==0); % quantidade de n�s n�o rotulados

% lista de n�s n�o rotulados
indnonlabeled = uint32(find(slabel==0));
% lista de n�s rotulados
labelednodes = uint32(find(slabel>0));

% encontrando k-vizinhos mais pr�ximos
[KNN,KNND] = knnsearch(X,X(indnonlabeled,:),'K',k+1,'NSMethod','kdtree','Distance',disttype);
KNN = uint32(KNN);
clear X;
KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo
KNND = KNND(:,2:end);
KNND = 1./(1+KNND);
% ajustando todas as dist�ncias na m�xima poss�vel
pot = repmat(1/nclass,qtnode,nclass);
% zerando potenciais dos n�s rotulados
pot(labelednodes,:) = 0;
% ajustando potencial da classe respectiva do n� rotulado para m�ximo
pot(sub2ind(size(pot),labelednodes,slabel(labelednodes))) = 1;
% vari�vel para guardar m�ximo potencial mais alto m�dio
pot = cnsslis5loop(maxiter,nnonlabeled,indnonlabeled,stopmax,pot,k,KNN,KNND);
[~,owner] = max(pot,[],2);

end