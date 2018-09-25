% cnsslis9smallworldness computes small-world-ness of a graph generated
% from img (resized to 1/3) similar to a graph generated by cnsslis9 in its
% first phase
% Use: [S_ws,C_ws,L_ws,S_trans,C_trans,L_trans] = cnsslis9smallworldness(img, fw, k, disttype)
% Output:
% S_ws - Cws 
% S_trans - transitivity C (no. of triangles)
% C and L are the mean clustering coefficient C and mean shortest path length L of A.
function [S,C,E] = cnsslis9smallworldness2(img, fw, k, disttype)
if (nargin < 4) || isempty(disttype)
    disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
end
if (nargin < 3) || isempty(k)
    k = 10; % quantidade de vizinhos mais pr�ximos
end
if (nargin < 2) || isempty(fw)
    fw = ones(1,9);
    %fw = [1 1 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
end
% tratamento da entrada
k = uint16(k);

rs_img = imresize(img,1/3,'bicubic');
[qtnode,X] = getFeatures(rs_img,fw);

clear rs_img;

% j� estamos normalizando de qualquer forma
if strcmp(disttype,'seuclidean')==1
    disttype='euclidean';
end

% encontrando k-vizinhos mais pr�ximos
KNN = knnsearch(X,X,'K',k+1,'NSMethod','kdtree','Distance',disttype);
KNN = uint32(KNN);
clear X;
KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo

A = zeros(qtnode,qtnode,'single');
for i=1:qtnode
    A(i,KNN(i,:))=1;
end

clear KNN;

% analysis parameters
%Num_ER_repeats = 100;  % to estimate C and L numerically for E-R random graph
%Num_S_repeats = 1000; % to get P-value for S; min P = 0.001 for 1000 samples
Num_ER_repeats = 20;

FLAG_Cws = 1;
FLAG_Ctransitive = 2;

% get its basic properties
n = size(A,1);  % number of nodes
%k = sum(A);  % degree distribution of undirected network % that would be to undirect graphs (F.B.)
%m = sum(k)/2; % that would be to undirect graphs (F.B.)
m = n*k; % I've changed to sum(k) for directed graphs (F.B.)
%K = mean(k); % mean degree of network % I don't need this (F.B.)

[Erand,Crand] = fb_NullModel_L_C(n,m,Num_ER_repeats,FLAG_Ctransitive);

% Note: if using a different random graph null model, e.g. the
% configuration model, then use this form

% compute small-world-ness using mean value over Monte-Carlo realisations

% NB: some path lengths in L will be INF if the ER network was not fully
% connected: we disregard these here as the dolphin network is fully
% connected.
%Lrand_mean = mean(Lrand(Lrand < inf));

%[S_ws,C_ws,E_ws] = fb_small_world_ness2(A,mean(Erand),mean(Crand),FLAG_Cws);  % Using WS clustering coefficient
[S,C,E] = fb_small_world_ness2(A,mean(Erand),mean(Crand),FLAG_Ctransitive);  %  Using transitive clustering coefficient

end

function [qtnode,X] = getFeatures(img,fw)
% Dimens�es da imagem
dim = size(img);
qtnode = dim(1)*dim(2);
X = zeros(qtnode,9);
% primeiro e segundo elementos s�o linha e coluna normalizadas no intervalo 0:1
X(:,1:2) = [repmat(((1:dim(1))/dim(1))',dim(2),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)];
% depois vem os 3 elementos RGB normalizados em 0:1
imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
X(:,3:5) = imgvec;
% depois vem os 3 elementos HSV
imghsv = rgb2hsv(double(img)/255);
X(:,6) = squeeze(reshape(imghsv(:,:,3),dim(1)*dim(2),1,1));
% em seguida ExR, ExG, e ExB
exr = 2.*double(img(:,:,1)) - double(img(:,:,2)) - double(img(:,:,3));
exg = 2.*double(img(:,:,2)) - double(img(:,:,1)) - double(img(:,:,3));
exb = 2.*double(img(:,:,3)) - double(img(:,:,1)) - double(img(:,:,2));
imgex = cat(3, exr, exg, exb);
clear exr exg exb;
X(:,7:9) = squeeze(reshape(imgex,dim(1)*dim(2),1,3));
X = zscore(X) .* repmat(fw,qtnode,1);
end