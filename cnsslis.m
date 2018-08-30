% Complex Networks Semi-Supervised Learning Image Segmentation
% Usage: [owner, pot] = cnsslis(img, imgslab, k, fw, disttype, valpha, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% fw        - vector of feature weights
% disttype  - use 'euclidean', etc.
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot       

function [owner, pot] = cnsslis(img, imgslab, k, fw, disttype, valpha, maxiter)
    if (nargin < 7) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 6) || isempty(valpha),
        valpha = 20;
    end      
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end
    if (nargin < 4) || isempty(fw),
        fw = ones(1,23); % quantidade de vizinhos mais pr�ximos
    end      
    if (nargin < 3) || isempty(k),
        k = 8; % quantidade de vizinhos mais pr�ximos
    end
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,23);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiro e segundo elementos s�o as dimens�es X e Y normalizadas no intervalo 0:1
    X(:,1:2) = [repmat(((1:dim(1))/dim(1))',dim(2),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)]; %corrigido!
    % depois vem os 3 elementos RGB normalizados em 0:1    
    X(:,3:5) = imgvec;    
    % depois vem os 3 elementos HSV
    imghsv = rgb2hsv(double(img)/255);
    X(:,6:8) = squeeze(reshape(imghsv,dim(1)*dim(2),1,3));    % corrigido!   
    % em seguida ExR, ExG, e ExB
    exr = 2.*double(img(:,:,1)) - double(img(:,:,2)) - double(img(:,:,3));
    exg = 2.*double(img(:,:,2)) - double(img(:,:,1)) - double(img(:,:,3));
    exb = 2.*double(img(:,:,3)) - double(img(:,:,1)) - double(img(:,:,2));
    imgex = cat(3, exr, exg, exb);
    clear exr exg exb;
    X(:,9:11) = squeeze(reshape(imgex,dim(1)*dim(2),1,3));
    % m�dias
    h = fspecial('average', [3 3]);
    g = imfilter(img, h,'replicate'); % adicionado replicate para que bordas n�o fiquem diferentes
    X(:,12:14) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
    s = stdfilt(img);
    X(:,15:17) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)))/255;
    g = imfilter(imghsv, h, 'replicate'); % adicionado replicate para que bordas n�o fiquem diferentes)                   
    X(:,18:20) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
    s = stdfilt(imghsv);
    X(:,21:23) = double(squeeze(reshape(s,dim(1)*dim(2),1,3)));            
    clear g imghsv imgex;       
    % normalizando as colunas
    X = zscore(X) .* repmat(fw,qtnode,1);       
    
    slabel = reshape(double(imgslab),dim(1)*dim(2),1);
    slabel(slabel==0)=-1; % fundo
    slabel(slabel==64)=1;  % c/ r�tulo - fundo
    slabel(slabel==255)=2; % c/ r�tulo - objeto
    slabel(slabel==128)=0; % sem r�tulo
    nclass = 2;

    indval = find(slabel>=0);   % pega s� os �ndices dos pixels que n�o s�o do fundo ignorado
    Xval = X(indval,:);         % cria lista de pixels v�lidos (que n�o s�o do fundo ignorado)
    qtnodeval = size(indval,1); % quantidade de n�s v�lidos (pixels v�lidos)
    slabelval = slabel(indval); % r�tulos dos pixels v�lidos (n�o s�o do fundo ignorado)    
    
    %disp('Criando vizinhan�a...')
    % constantes
    nnonlabeled = sum(slabel==0); % quantidade de n�s n�o rotulados
    % j� estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
   
    stopmax = round((qtnodeval/nnonlabeled)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia        
    
    % encontrando k-vizinhos mais pr�ximos
    %disp('Encontrando k-vizinhos mais pr�ximos...')
    KNN = knnsearch(Xval,Xval,'K',k+1,'NSMethod','kdtree','Distance',disttype);
    %KNN = knnsearch(X,X,'K',k+1,'Distance',disttype);
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo    
    %disp('Criando reciprocidade entre vizinhos...')    
    KNNR = zeros(qtnodeval,k); % criando matriz para vizinhan�a rec�proca, inicialmente com tamanho k
    knns = zeros(qtnodeval,1); % vetor com a quantidade de vizinhos rec�procos de cada n�
    for i=1:qtnodeval
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos n�s que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum n� atingiu o limite de colunas da matriz de vizinhan�a rec�proca teremos de aument�-la
            KNNR(:,max(knns)+1:round(max(knns)*1.1)+1) = zeros(qtnodeval,round(max(knns)*0.1)+1);  % portanto vamos aumenta-la em 10% + 1 (para garantir no caso do tamanho ser menor que 10)
        end
    end
    KNN = [KNN KNNR];
    clear KNNR;
    % removendo duplicatas    
    for i=1:qtnodeval
        knnrow = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN 
        KNN(i,knns(i)+1:end)=0; % preenche restante com zero
    end
    KNN = KNN(:,1:max(knns)); % eliminando colunas que n�o tem vizinhos v�lidos
      
    % lista de n�s n�o rotulados
    indnonlabeled = find(slabelval==0);
    % lista de n�s rotulados
    labelednodes = find(slabelval>0);
    % ajustando todas as dist�ncias na m�xima poss�vel
    potval = repmat(0.5,qtnodeval,nclass);   
    % zerando potenciais dos n�s rotulados
    potval(labelednodes,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para m�ximo
    potval(sub2ind(size(potval),labelednodes,slabelval(labelednodes))) = 1;
    % vari�vel para guardar m�ximo potencial mais alto m�dio
%    newpot = potval;
%    maxmmpot = 0;
    potval = cnsslisloop(maxiter,nnonlabeled,indnonlabeled,stopmax,potval,knns,KNN);
%     for i=1:maxiter
%         % para cada part�cula
%         %roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
%         for j=1:nnonlabeled
%             ppj = indnonlabeled(j);
%             newpot(ppj,:) = mean(potval(KNN(ppj,1:knns(ppj)),:));
%         end
%         potval = newpot;
%         if mod(i,10)==0
%             mmpot = mean(max(potval(indnonlabeled,:),[],2));
%             %if mod(i,10)==0
%             %    disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
%             %end
%             if mmpot-maxmmpot>0.0001
%                 maxmmpot = mmpot;
%                 stopcnt = 0;
%             else    
%                 stopcnt = stopcnt + 1;
%                 if stopcnt > stopmax                     
%                     break;
%                 end
%             end
%         end
%     end
    [~,ownerval] = max(potval,[],2);
    owner = slabel;
    owner(owner==-1)=1;
    owner(indval)=ownerval;
    pot(indval,:)=potval;
end

