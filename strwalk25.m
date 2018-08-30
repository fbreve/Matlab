% Semi-Supervised Territory Mark Walk v.25
% Derivado de strwalk8.m (v.8k)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Vizinhan�a apenas entre os 8 vizinhos mais pr�ximos (v.22)
% Arestas com peso proporcional � dist�ncia Euclidiana (v.22)
% Medida de dist�ncia considerando pesos (v.22)
% Sem part�culas, cada pixel n�o rotulado pega colabora��o dos vizinhos a
% cada itera��o (v.25)
% Usage: [owner, pot] = strwalk25(img, imgslab, slabtype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image containing labels, each color is a different label
% slabtype  - 0 (default), 1 (Microsoft Research Cambridge images)
% valpha    - lower it to stop earlier, accuracy may be lower
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot       - final pertinence vectors of each node

function [owner, pot] = strwalk25(img, imgslab, slabtype, valpha, maxiter)
    if (nargin < 5) || isempty(maxiter),
        maxiter = 100000; % n�mero de itera��es
    end
    if (nargin < 4) || isempty(valpha),
        valpha = 20;
    end    
    if (nargin < 3) || isempty(slabtype),
        slabtype = 0;
    end        
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,6);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiros 3 elementos ser�o RGB normalizado em 0:1    
    X(:,1:3) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,4:6) = rgb2hsv(imgvec);   
    % normalizando as colunas
    X = zscore(X);
    % Converter imagem com r�tulos em vetor de r�tulos
    if slabtype==0 % cor mais clara (branco) � a n�o rotulada.
        slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);    
        labc=0;
        while max(slabel>labc)
            slabel(slabel==max(slabel)) = labc;
            labc = labc+1;
        end
        nclass = labc-1;        
    else % imagens do Microsoft Research Cambridge
        slabel = reshape(double(imgslab),dim(1)*dim(2),1);
        slabel(slabel==0)=1; % fundo
        slabel(slabel==64)=1;  % c/ r�tulo - fundo
        slabel(slabel==255)=2; % c/ r�tulo - objeto
        slabel(slabel==128)=0; % sem r�tulo
        nclass = 2;
    end
    % Criar matriz de dist�ncia e lista de vizinhos
    % �ndices est�o no sentido hor�rio do vetor de liga��o
    Ndist = zeros(size(X,1),8);
    Nlist = zeros(size(X,1),8);
    Nsize = zeros(size(X,1),1);
    % Pesos das liga��es horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);
            addNeighbor;
        end
    end
    % Peso das liga��es diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            addNeighbor;    
        end
    end    
    % Peso das liga��es verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            addNeighbor;        
        end
    end    
    % Peso das liga��es diagonais (/)
    for i=1:dim(1)-1
        for j=2:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1-dim(1)+1;
            addNeighbor;       
        end
    end
    % Ajustando dist�ncias para intervalo 0 - 1 e invertendo (convertendo em peso de aresta);
    Ndist = 1 - Ndist/max(max(Ndist));
    % constantes
    npart = sum(slabel==0); % quantidade de n�s n�o rotulados
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia    
    % lista de n�s n�o rotulados
    partnode = find(slabel==0);
    % lista de n�s rotulados
    labelednodes = find(slabel~=0);
    % ajustando todas as dist�ncias na m�xima poss�vel
    pot = repmat(1/nclass,qtnode,nclass);
    % zerando potenciais dos n�s rotulados
    pot(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para m�ximo
    pot(sub2ind(size(pot),labelednodes,slabel(slabel~=0))) = 1;
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    % chamando o arquivo mex do strwalk24
    pot = strwalk25loop(maxiter, npart, nclass, stopmax, partnode, slabel, Nsize, Nlist, Ndist, pot);
    [~,owner] = max(pot,[],2);
    function addNeighbor
        Nsize(ind1) = Nsize(ind1) + 1;
        Nsize(ind2) = Nsize(ind2) + 1;
        Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
        Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
        Nlist(ind1,Nsize(ind1)) = ind2;
        Nlist(ind2,Nsize(ind2)) = ind1;
    end
end

