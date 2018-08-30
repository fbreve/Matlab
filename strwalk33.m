% Semi-Supervised Territory Mark Walk v.33
% Derivado de strwalk29.m
% Ajuste final com colabora��o de vizinhos (v.28)
% Vetor para escalar cada entrada (v.29)
% Liga��o apenas com os 8 vizinhos mais pr�ximos (v.33)
% Movimenta��o considerando dist�ncia euclidiana entre atributos do n� casa
% da part�cula e n�s candidatos � visita (v.33)
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
% owner2    - vector of classes assigned to each data item (without the second part of the algorithm)
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
function [owner, pot, owndeg] = strwalk33(img, imgslab, dm, disttype, slabtype, valpha, pgrd, deltav, deltap, dexp, maxiter)
    if (nargin < 11) || isempty(maxiter)
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 10) || isempty(dexp)
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 9) || isempty(deltap)
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da part�cula
    end
    if (nargin < 8) || isempty(deltav)
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 7) || isempty(pgrd)
        pgrd = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 6) || isempty(valpha)
        valpha = 20;
    end
    if (nargin < 5) || isempty(slabtype)
        slabtype = 0; % dist�ncia euclidiana n�o normalizada
    end          
    if (nargin < 4) || isempty(disttype)
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    if (nargin < 3) || isempty(dm)
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
    clear h g j imgvec img;
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
    % Criar matriz de dist�ncia e lista de vizinhos
    % �ndices est�o no sentido hor�rio do vetor de liga��o
    Ndist = zeros(size(X,1),8);
    Nlist = zeros(size(X,1),8);
    Nsize = zeros(size(X,1),1);
    % Liga��es horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);            
            addNeighbor;
        end
    end
    % Liga��es diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            addNeighbor;    
        end
    end    
    % Liga��es verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            addNeighbor;        
        end
    end    
    % Liga��es diagonais (/)
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
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel>0); % quantidade de part�culas = quantidade de n�s rotulados

    indval = find(slabel>=0);
    qtnodeval = size(indval,1);   
    
    stopmax = round((qtnodeval/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia        
    
    % definindo classe de cada part�cula
    partclass = slabel(slabel>0);
    % definindo n� casa da part�cula
    partnode = find(slabel>0);
    % definindo potencial da part�cula em 1
    potpart = repmat(potmax,npart,1);       
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos n�s rotulados
    pot(partnode,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
    % colocando cada n� em sua casa
    partpos = partnode;
    owndeg = repmat(realmin,qtnode,nclass);
       
    disp('Caminhando com as part�culas...')    
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    maxmmpot = 0;
    for i=1:maxiter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pgrd
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart
            ppj = partpos(j);
            ndist = pdist2(X(partnode(j),:),X(Nlist(ppj,1:Nsize(ppj)),:));             
            if rndtb(j)<pgrd
                % regra de probabilidade                
                prob = cumsum((1 ./ ndist.^2) .* pot(Nlist(ppj,1:Nsize(ppj)),partclass(j))');                
                % descobrindo quem foi o n� sorteado
                k = Nlist(ppj,find(prob>=(roulettepick(j)*prob(end)),1,'first'));
            else
                prob = cumsum(1 ./ ndist.^2);
                k = Nlist(ppj,find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                % contador de visita (para calcular grau de propriedade)
                owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
            end           
            % se o n� n�o � pr�-rotulado
            if slabel(k)==0
                % calculando novos potenciais para n�
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para part�cula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                                 
            % se n�o houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % muda para n� alvo
                partpos(j) = k;
            end
        end
        if mod(i,10)==0
            mmpot = mean(max(pot(indval,:),[],2));
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
    [~,owner] = max(pot,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);

    if slabtype==1
        owner(slabel==-1)=1;
        %pot = repmat([1 0],qtnode,1);
    else
        owner(slabel==-1)=labc;
        %pot = ones(qtnode,nclass);
    end
    
    pot = pot(indval,:);
    
%    pot(indval,:)=potval;
%    owner2 = owner;
    
%     % PARTE 2!
%     indefnodes = find(max(pot,[],2)<0.9);
%     indefnodesc = size(indefnodes,1);
%     if indefnodesc>0     
%         %disp(sprintf('%i n�s indefinidos. Pegando colabora��o de pixels vizinhos',size(indefnodes,1)))
%         
%         % constantes
%         npart = indefnodesc; % quantidade de n�s ainda n�o rotulados
%         stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
%         % lista de n�s n�o rotulados
%         partnode = indefnodes;
%         % vari�vel para guardar m�ximo potencial mais alto m�dio
%         % chamando o arquivo mex do strwalk25
%         pot = strwalk25loop(maxiter, npart, nclass, stopmax, partnode, slabel, Nsize, Nlist, Ndist, pot);
%         [~,owner] = max(pot,[],2);
%     end
    
    function addNeighbor
        if slabel(ind1)>=0 && slabel(ind2)>=0
            Nsize(ind1) = Nsize(ind1) + 1;
            Nsize(ind2) = Nsize(ind2) + 1;
            Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
            Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
            Nlist(ind1,Nsize(ind1)) = ind2;
            Nlist(ind2,Nsize(ind2)) = ind1;
        end
    end

end

