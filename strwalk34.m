% Semi-Supervised Territory Mark Walk v.29
% Derivado de strwalk8.m (v.8)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Tabela de dist�ncias do time (v.26)
% Ajuste final com colabora��o de vizinhos (v.28)
% Vetor para escalar cada entrada (v.29)
% Vers�o utilizada em:
% BREVE, Fabricio Aparecido; QUILES, Marcos Gon�alves; ZHAO, Liang. "Interactive Image Segmentation using Particle Competition and Cooperation"
% In: The International Joint Conference on Neural Networks (IJCNN2015), 2015, Killarney, Irlanda. 
% Proceedings of the International Joint Conference on Neural Networks (IJCNN2015), 2015. p.1 - 8.
%
% Usage: [owner, owner2, pot, owndeg] = strwalk28(img, imgslab, dm, k, disttype, texture, slabtype, valpha, pgrd, deltav, deltap, dexp, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% k         - each node is connected to its k-neirest neighbors
% disttype  - use 'euclidean', 'seuclidean', etc.
% texture   - 0 - do not use texture information; 1 - use texture information
% slabtype  - 0 - default (white pixels are unlabeled pixels, colored are the classes) 
%             1 - Microsoft GrabCut dataset standard
% valpha    - Default: 2000 (lower it to stop earlier, accuracy may be lower)
% pgrd      - check p_grd in [1]
% deltav    - check delta_v in [1]
% deltap    - Default: 1 (leave it on default to match equations in [1])
% dexp      - Default: 2 (leave it on default to match equations in [1])
% nclass    - amount of classes on the problem
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% owndeg    - fuzzy output as in [2], each line is a data item, each column pertinence to a class
%
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gon�alves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [owner, pot, owndeg] = strwalk34(img, imgslab, dm, k, disttype, slabtype, valpha, pgrd, deltav, dexp, maxiter)
    if (nargin < 11) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 10) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 9) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 8) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 7) || isempty(valpha),
        valpha = 200;
    end
    if (nargin < 6) || isempty(slabtype),
        slabtype = 0; % dist�ncia euclidiana n�o normalizada
    end          
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    if (nargin < 4) || isempty(k),
        k = 8; % quantidade de vizinhos mais pr�ximos
    end
    if (nargin < 3) || isempty(dm),
        dm = ones(1,20);
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
    % s�timo e oitavo elementos s�o as dimens�es X e Y normalizadas no intervalo 0:1
    X(:,7:8) = [repmat(((1:dim(2))/dim(2))',dim(1),1), reshape(repmat((1:dim(1))/dim(1),dim(2),1),dim(1)*dim(2),1)];
    h = fspecial('average', [3 3]);
    g = imfilter(img, h);
    j = stdfilt(img);
    X(:,9:11) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
    X(:,12:14) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)))/255;
    g = imfilter(rgb2hsv(img), h);
    j = stdfilt(rgb2hsv(img));
    X(:,15:17) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
    X(:,18:20) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)));    
    % normalizando as colunas
    X = zscore(X) .* repmat(dm,qtnode,1);
    % Converter imagem com r�tulos em vetor de r�tulos       
    if slabtype==0 % cor mais clara (branco) � a n�o rotulada.
        slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);   
        slabel(slabel==0)=-1; % fundo
        labc=0;        
        while max(slabel>labc)
            slabel(slabel==max(slabel)) = labc;
            labc = labc+1;
        end
        nclass = labc-1;        
    else % imagens do Microsoft Research Cambridge
        slabel = reshape(double(imgslab),dim(1)*dim(2),1);
        slabel(slabel==0)=-1; % fundo
        slabel(slabel==64)=1;  % c/ r�tulo - fundo
        slabel(slabel==255)=2; % c/ r�tulo - objeto
        slabel(slabel==128)=0; % sem r�tulo
        nclass = 2;
    end    
    disp('Criando vizinhan�a...')        
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel==0); % quantidade de part�culas
    % j� estamos normalizando de qualquer forma
    if strcmp(disttype,'seuclidean')==1
        disttype='euclidean';
    end
     
    indval = find(slabel>=0);
    Xval = X(indval,:);
    qtnodeval = size(indval,1);
    slabelval = slabel(indval);

    
    stopmax = round((qtnodeval/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia        
    
    % encontrando k-vizinhos mais pr�ximos
    disp('Encontrando k-vizinhos mais pr�ximos...')
    KNN = knnsearch(Xval,Xval,'K',k+1,'NSMethod','kdtree','Distance',disttype);
    %KNN = knnsearch(X,X,'K',k+1,'Distance',disttype);
    KNN = KNN(:,2:end); % eliminando o elemento como vizinho de si mesmo    
    disp('Criando reciprocidade entre vizinhos...')    
    KNNR = zeros(qtnodeval,k); % criando matriz para vizinhan�a rec�proca, inicialmente com tamanho k
    knns = zeros(qtnodeval,1); % vetor com a quantidade de vizinhos rec�procos de cada n�
    for i=1:qtnodeval
        KNNR(sub2ind(size(KNNR),KNN(i,:),(knns(KNN(i,:))+1)'))=i; % adicionando i como vizinho dos vizinhos de i (criando reciprocidade)
        knns(KNN(i,:))=knns(KNN(i,:))+1; % aumentando contador de vizinhos nos n�s que tiveram vizinhos adicionados
        if max(knns)==size(KNNR,2) % se algum n� atingiu o limite de colunas da matriz de vizinhan�a rec�proca teremos de aument�-la
            KNNR(:,max(knns)+1:max(knns)*2) = zeros(qtnodeval,max(knns));  % portanto vamos dobr�-la
        end
    end
    KNN = [KNN KNNR];
    clear KNNR;
    % removendo duplicatas    
    for i=1:qtnodeval
        knnrow = unique(KNN(i,:),'stable'); % remove as duplicatas
        knns(i) = size(knnrow,2)-1; % atualiza quantidade de vizinhos (e descarta o zero no final)
        KNN(i,1:knns(i)) = knnrow(1:end-1); % copia para matriz KNN e preenche restante com zero
    end
    KNN = KNN(:,1:max(knns)); % eliminando colunas que n�o tem vizinhos v�lidos
    disp('Preparando tabelas...')
    % definindo n� casa da part�cula
    partnode = find(slabelval==0);
    lbldnode = find(slabelval>0);
    % ajustando todas as dist�ncias na m�xima poss�vel
    distnode = repmat(qtnodeval-1,qtnodeval,npart);
    % ajustando para zero a dist�ncia de cada part�cula para seu
    % respectivo n� casa
    distnode(:,partnode)=0;
    % inicializando tabela de potenciais com tudo igual
    potval = repmat(potmax/nclass,qtnodeval,nclass);
    % zerando potenciais dos n�s rotulados
    potval(lbldnode,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    potval(sub2ind(size(potval),lbldnode,slabelval(lbldnode))) = 1;
    % colocando cada n� em sua casa
    partpos = partnode;           
    owndeg = repmat(realmin,qtnodeval,nclass);
    disp('Caminhando com as part�culas...')
    maxmmpot = 0;
    for i=1:maxiter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart
            ppj = partpos(j);
            if rndtb(j)<pgrd
                % regra de probabilidade                
                prob = cumsum(1./(1+distnode(KNN(ppj,1:knns(ppj)),j)).^dexp);
                % descobrindo quem foi o n� sorteado
                k = KNN(ppj,find(prob>=(roulettepick(j)*prob(end)),1,'first'));
            else
                k = KNN(ppj,ceil(roulettepick(j)*knns(ppj)));
                % contador de visita (para calcular grau de propriedade)
                owndeg(partnode(j),:) = owndeg(partnode(j),:) + potval(k,:);
            end           
            % calculando novos potenciais para n�
            potval(partnode(j),:) = potval(partnode(j),:) .* (1-deltav) + potval(k,:) .* deltav;
                                 
            % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
            if distnode(ppj,j)+1<distnode(k,j)
                % atualizar dist�ncia do n� alvo
                distnode(k,j) = distnode(ppj,j)+1;
            end
            
            partpos(j) = k;
            
        end
        if mod(i,10)==0
            mmpot = mean(max(potval,[],2));
            fprintf('Iter: %5.0f  Meanpot: %0.4f\n',i,mmpot)
            if mmpot>maxmmpot
                maxmmpot = mmpot;
                stopcnt = 0;
            else    
                stopcnt = stopcnt + 1;
                if stopcnt > stopmax                     
                    break;
                end
            end
        end
    end
    
    
    [~,ownerval] = max(potval,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);

    owner = slabel;
    if slabtype==1
        owner(owner==-1)=1;
        pot = repmat([1 0],qtnode,1);
    else
        owner(owner==-1)=labc;
        pot = ones(qtnode,nclass);
    end
    owner(indval)=ownerval;
    
    pot(indval,:)=potval;
end

