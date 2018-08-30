% Semi-Supervised Territory Mark Walk v.30
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
% Vetor de escala criado automaticamente. ExR, ExG, ExB inclu�dos. (v.30)
% Aceita vetor de escala (v.32)
% Aceita diretamente a lista de K-vizinhos mais pr�ximos (knn)
% Usage: [owner, owner2, potval, owndeg] = strwalk32(img, imgslab, X, KNN, knns, valpha, pgrd, deltav, deltap, dexp, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image with labeled/unlabeled pixel information
% X         - Attributes previously weighted (may be generated with
%             strwalk32indint.m)
% KNN       - Matrix of nearest neighbors (may be generated with
%             strwalk32indint.m)
% knns      - each element is the amount of neighbors of the corresponding
%             node (also generated with strwalk32indint.m)
% valpha    - Default: 20 (lower it to stop earlier, accuracy may be lower)
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
function [owner, owner2, potval, owndeg] = strwalk32knn(img, imgslab, X, KNN, knns, valpha, pgrd, deltav, deltap, dexp, maxiter)
    if (nargin < 11) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 10) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 9) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decremento do potencial da part�cula
    end
    if (nargin < 8) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 7) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 6) || isempty(valpha),
        valpha = 20;
    end      
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
   
    slabel = reshape(double(imgslab),dim(1)*dim(2),1);
    slabel(slabel==0)=-1; % fundo
    slabel(slabel==64)=1;  % c/ r�tulo - fundo
    slabel(slabel==255)=2; % c/ r�tulo - objeto
    slabel(slabel==128)=0; % sem r�tulo
    nclass = 2;

    indval = find(slabel>=0);  % pega s� os �ndices dos pixels que n�o s�o do fundo ignorado
    qtnodeval = size(indval,1); % quantidade de n�s v�lidos (pixels v�lidos)
    slabelval = slabel(indval); % r�tulos dos pixels v�lidos (n�o s�o do fundo ignorado)    
    
    %disp('Criando vizinhan�a...')
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel>0); % quantidade de part�culas (apenas n�s rotulados e que n�o s�o do fundo ignorado)   
    stopmax = round((qtnodeval/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia        
         
    %disp('Caminhando com as part�culas...')
    % definindo classe de cada part�cula
    partclass = slabelval(slabelval>0);
    % definindo n� casa da part�cula
    partnode = find(slabelval>0);
    % definindo potencial da part�cula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as dist�ncias na m�xima poss�vel
    distnode = repmat(qtnodeval-1,qtnodeval,nclass);      
    % ajustando para zero a dist�ncia de cada part�cula para seu
    % respectivo n� casa
    distnode(sub2ind(size(distnode),partnode,partclass)) = 0;    
    % inicializando tabela de potenciais com tudo igual
    potval = repmat(potmax/nclass,qtnodeval,nclass);
    % zerando potenciais dos n�s rotulados
    potval(partnode,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    potval(sub2ind(size(potval),partnode,slabelval(partnode))) = 1;
    % colocando cada n� em sua casa
    partpos = partnode;           
    owndeg = repmat(realmin,qtnodeval,nclass);
    [potval, owndeg] = strwalk26loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabelval, knns, distnode, KNN, potval, owndeg);
    [~,ownerval] = max(potval,[],2);
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);

    owner = slabel;
    owner(owner==-1)=1;
    pot = repmat([1 0],qtnode,1);
    owner(indval)=ownerval;
    
    pot(indval,:)=potval;
    owner2 = owner;
    
    % PARTE 2!
    indefnodes = find(max(pot,[],2)<0.9);
    indefnodesc = size(indefnodes,1);
    if indefnodesc>0
        
        %disp(sprintf('%i n�s indefinidos. Pegando colabora��o de pixels vizinhos',size(indefnodes,1)))
        
        Ndist = zeros(size(X,1),8);
        Nlist = zeros(size(X,1),8);
        Nsize = zeros(size(X,1),1);
        % Pesos das liga��es horizontais
        for i=1:dim(1)
            for j=1:dim(2)-1
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1 + dim(1);
                p2addNeighbor;
            end
        end
        % Peso das liga��es diagonais (\)
        for i=1:dim(1)-1
            for j=1:dim(2)-1
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1+dim(1)+1;
                p2addNeighbor;
            end
        end
        % Peso das liga��es verticais
        for i=1:dim(1)-1
            for j=1:dim(2)
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1+1;
                p2addNeighbor;
            end
        end
        % Peso das liga��es diagonais (/)
        for i=1:dim(1)-1
            for j=2:dim(2)
                ind1 = i+(j-1)*dim(1);
                ind2 = ind1-dim(1)+1;
                p2addNeighbor;
            end
        end
        % Ajustando dist�ncias para intervalo 0 - 1 e invertendo (convertendo em peso de aresta);
        Ndist = 1 - Ndist/max(max(Ndist));
        % constantes
        npart = indefnodesc; % quantidade de n�s ainda n�o rotulados
        stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia
        % lista de n�s n�o rotulados
        partnode = indefnodes;
        % vari�vel para guardar m�ximo potencial mais alto m�dio
        % chamando o arquivo mex do strwalk24
        pot = strwalk25loop(maxiter, npart, nclass, stopmax, partnode, slabel, Nsize, Nlist, Ndist, pot);
        [~,owner] = max(pot,[],2);
    end
    
    function p2addNeighbor
        Nsize(ind1) = Nsize(ind1) + 1;
        Nsize(ind2) = Nsize(ind2) + 1;
        Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));
        Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
        Nlist(ind1,Nsize(ind1)) = ind2;
        Nlist(ind2,Nsize(ind2)) = ind1;
    end

end

