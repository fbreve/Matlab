% Semi-Supervised Territory Mark Walk v.22
% Derivado de strwalk8.m (v.8k)
% Conta distância de de nós para o nó pré-rotulado mais próximo (v.2)
% Utiliza uma partícula por nó pré-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleatório e potencial x distancia (v.6)
% Saída fuzzy utilizando contagem de visitas pelo movimento aleatório
% ponderada pelo potencial da partícula (v.8)
% Distância medida com k-vizinhos (v.8k)
% Vizinhança apenas entre os 8 vizinhos mais próximos (v.22)
% Arestas com peso proporcional à distância Euclidiana (v.22)
% Medida de distância considerando pesos (v.22)
% Usage: [owner, pot] = strwalk22mex(img, imgslab, valpha, pgrd, deltav, dexp, maxiter)
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
% [1] Breve, Fabricio Aparecido; Zhao, Liang; Quiles, Marcos Gonçalves; Pedrycz, Witold; Liu, Jiming, 
% "Particle Competition and Cooperation in Networks for Semi-Supervised Learning," 
% Knowledge and Data Engineering, IEEE Transactions on , vol.24, no.9, pp.1686,1698, Sept. 2012
% doi: 10.1109/TKDE.2011.119
%
% [2] Breve, Fabricio Aparecido; ZHAO, Liang. 
% "Fuzzy community structure detection by particle competition and cooperation."
% Soft Computing (Berlin. Print). , v.17, p.659 - 673, 2013.
function [owner, pot] = strwalk22mex(img, imgslab, slabtype, valpha, pgrd, deltav, dexp, maxiter)
    if (nargin < 8) || isempty(maxiter),
        maxiter = 500000; % número de iterações
    end
    if (nargin < 7) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.100; % controle de velocidade de aumento/decremento do potencial do vértice
    end
    if (nargin < 5) || isempty(pgrd),
        pgrd = 0.500; % probabilidade de não explorar
    end
    if (nargin < 4) || isempty(valpha),
        valpha = 2000;
    end    
    if (nargin < 3) || isempty(slabtype),
        slabtype = 0;
    end        
    % Converter imagem de entrada para vetor de atributos
    dim = size(img);
    qtnode = dim(1)*dim(2);
    X = zeros(qtnode,6);   
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiros 3 elementos serão RGB normalizado em 0:1    
    X(:,1:3) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,4:6) = rgb2hsv(imgvec);
    % Converter imagem com rótulos em vetor de rótulos    
    if slabtype==0 % cor mais clara (branco) é a não rotulada.
        slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);    
        labc=0;
        while max(slabel>labc)
            slabel(slabel==max(slabel)) = labc;
            labc = labc+1;
        end
        nclass = labc-1;        
    else % imagens do Microsoft Research Cambridge
        slabel = reshape(double(imgslab),dim(1)*dim(2),1);
        slabel(slabel==64)=1;  % c/ rótulo - fundo
        slabel(slabel==255)=2; % c/ rótulo - objeto
        slabel(slabel==128)=0; % sem rótulo
        nclass = 2;
    end
    % Criar matriz de distância e lista de vizinhos
    % Índices estão no sentido horário do vetor de ligação
    Ndist = repmat(-1,size(X,1),8);
    Nlist = zeros(size(X,1),8);
    Nsize = zeros(size(X,1),1);
    % Pesos das ligações horizontais
    for i=1:dim(1)
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1 + dim(1);
            addNeighbor;
        end
    end
    % Peso das ligações diagonais (\)
    for i=1:dim(1)-1
        for j=1:dim(2)-1
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+dim(1)+1;
            addNeighbor;    
        end
    end    
    % Peso das ligações verticais
    for i=1:dim(1)-1
        for j=1:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1+1;
            addNeighbor;        
        end
    end    
    % Peso das ligações diagonais (/)
    for i=1:dim(1)-1
        for j=2:dim(2)
            ind1 = i+(j-1)*dim(1);
            ind2 = ind1-dim(1)+1;
            addNeighbor;       
        end
    end
    % Ajustando distâncias para intervalo 0 - 1;
    Ndist = Ndist/max(max(Ndist));
    % Colocando distâncias para vizinhos não existentes em 1
    Ndist(Ndist<0)=1;
    % constantes
    potmax = 1.000; % potencial máximo
    potmin = 0.000; % potencial mínimo
    npart = sum(slabel~=0); % quantidade de partículas
    stopmax = round((qtnode/npart)*round(valpha*0.1)); % qtde de iterações para verificar convergência    
    % definindo classe de cada partícula
    partclass = slabel(slabel~=0);
    % definindo nó casa da partícula
    partnode = find(slabel);
    % definindo potencial da partícula em 1
    potpart = repmat(potmax,npart,1);       
    % ajustando todas as distâncias na máxima possível
    distnode = repmat(qtnode-1,qtnode,npart);
    % ajustando para zero a distância de cada partícula para seu
    % respectivo nó casa
    distnode(sub2ind(size(distnode),partnode',1:npart)) = 0;
    % inicializando tabela de potenciais com tudo igual
    pot = repmat(potmax/nclass,qtnode,nclass);
    % zerando potenciais dos nós rotulados
    pot(partnode,:) = 0;
    % ajustando potencial da classe respectiva do nó rotulado para 1
    pot(sub2ind(size(pot),partnode,slabel(partnode))) = 1;
    % colocando cada nó em sua casa
    partpos = partnode;           
    pot = strwalk22loop(maxiter, npart, nclass, stopmax, pgrd, dexp, deltav, 1, potmin, partpos, partclass, potpart, slabel, Nsize, distnode, Nlist, Ndist, pot);
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

