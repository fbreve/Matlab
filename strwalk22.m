% DESATUALIZADA, USAR VERSAO MEX
% Semi-Supervised Territory Mark Walk v.22
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
% Usage: [owner, pot] = strwalk22(img, imgslab, valpha, pgrd, deltav, dexp, maxiter)
% INPUT:
% img       - Image to be segmented
% imgslab   - Image containing labels, each color is a different label
% valpha    - lower it to stop earlier, accuracy may be lower
% pgrd      - check p_grd in [1]
% deltav    - check delta_v in [1]
% deltap    - Default: 1 (leave it on default to match equations in [1])
% dexp      - Default: 2 (leave it on default to match equations in [1])
% maxiter   - maximum amount of iterations
% OUTPUT:
% owner     - vector of classes assigned to each data item
% pot       - final ownership vectors of each node
%
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gon�alves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [owner, pot] = strwalk22(img, imgslab, valpha, pgrd, deltav, dexp, maxiter)
    if (nargin < 7) || isempty(maxiter),
        maxiter = 500000; % n�mero de itera��es
    end
    if (nargin < 6) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 5) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 4) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 3) || isempty(valpha),
        valpha = 2000;
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
    % Converter imagem com r�tulos em vetor de r�tulos
    slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);
    labc=0;
    while max(slabel>labc)
        slabel(slabel==max(slabel)) = labc;
        labc = labc+1;
    end
    nclass = labc-1;
    % Criar matriz de dist�ncia e lista de vizinhos
    % �ndices est�o no sentido hor�rio do vetor de liga��o
    Ndist = repmat(-1,size(X,1),8);
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
    % Ajustando dist�ncias para intervalo 0 - 1;
    Ndist = Ndist/max(max(Ndist));
    % Colocando dist�ncias para vizinhos n�o existentes em 1
    Ndist(Ndist<0)=1;
    % constantes
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    npart = sum(slabel~=0); % quantidade de part�culas
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de itera��es para verificar converg�ncia    
    % definindo classe de cada part�cula
    partclass = slabel(slabel~=0);
    % definindo n� casa da part�cula
    partnode = find(slabel);
    % definindo potencial da part�cula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as dist�ncias na m�xima poss�vel
    distnode = repmat(qtnode-1,qtnode,npart);
    % ajustando para zero a dist�ncia de cada part�cula para seu
    % respectivo n� casa
    distnode(sub2ind(size(distnode),partnode',1:npart)) = 0;
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos n�s rotulados
    pot(partnode,:) = 0;
    % ajustando potencial da classe respectiva do n� rotulado para 1
    pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
    % colocando cada n� em sua casa
    partpos = partnode;           
  % vari�vel para guardar m�ximo potencial mais alto m�dio
    maxmmpot = 0;
    for i=1:maxiter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta        
        for j=1:npart
            ppj = partpos(j); % n� atual
            if rndtb(j)<pgrd                         
                prob = cumsum(((1+distnode(Nlist(ppj,1:Nsize(ppj)),j)).^-dexp)' .* pot(Nlist(ppj,1:Nsize(ppj)),partclass(j))' .* (1-Ndist(ppj,1:Nsize(ppj))));
            else
                prob = cumsum(1-Ndist(ppj,1:Nsize(ppj)));
            end            
            % descobrindo quem foi o n� sorteado
            nt = find(prob>=(roulettepick(j)*prob(end)),1,'first'); % �ndice do vizinho alvo na lista de vizinhos do n� atual
            k = Nlist(ppj,nt); % �ndice do vizinho alvo no vetor de n�s
            % se o n� n�o � pr�-rotulado
            if slabel(k)==0
                % calculando novos potenciais para n�
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para part�cula
            potpart(j) = pot(k,partclass(j));
                      
            % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
            if distnode(ppj,j)+Ndist(ppj,nt) < distnode(k,j)
                % atualizar dist�ncia do n� alvo
                distnode(k,j) = distnode(ppj,j) + Ndist(ppj,nt);
            end
            
            % se n�o houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % muda para n� alvo
                partpos(j) = k;
            end
        end
        if mod(i,10)==0
            mmpot = mean(max(pot,[],2));
            disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
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
    
    function addNeighbor
            Nsize(ind1) = Nsize(ind1) + 1;
            Nsize(ind2) = Nsize(ind2) + 1;            
            Ndist(ind1,Nsize(ind1)) = norm(X(ind1,:)-X(ind2,:));            
            Ndist(ind2,Nsize(ind2)) = Ndist(ind1,Nsize(ind1));
            Nlist(ind1,Nsize(ind1)) = ind2;
            Nlist(ind2,Nsize(ind2)) = ind1;
    end   
end

