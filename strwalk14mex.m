% Semi-Supervised Territory Mark Walk v.14
% Derivado de strwalk8.m (v.8)
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Dist�ncia medida com k-vizinhos (v.8k)
% Active Learning (v.14)
% Usage: [owner, slabel, pot, owndeg, distnode] = strwalk14mex(X, label, labp, k, disttype, valpha, pdet, deltav, deltap, dexp, nclass)
function [owner, slabel, pot, owndeg, distnode] = strwalk14mex(X, label, labp, k, disttype, valpha, pdet, deltav, deltap, dexp, nclass)
    if (nargin < 11) || isempty(nclass),
        nclass = max(label); % quantidade de classes
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
    if (nargin < 7) || isempty(pdet),
        pdet = 0.500; % probabilidade de n�o explorar
    end
    if (nargin < 6) || isempty(valpha),
        valpha = 2000;
    end        
    if (nargin < 5) || isempty(disttype),
        disttype = 'euclidean'; % dist�ncia euclidiana n�o normalizada
    end    
    qtnode = size(X,1); % quantidade de n�s
    if (nargin < 4) || isempty(k),
        k = round(qtnode*0.05); % quantidade de vizinhos mais pr�ximos
    end
    if (nargin < 3) || isempty(labp),
        labp = 0.1; % percentual de n�s rotulados
    end
% constantes
potmax = 1.000; % potencial m�ximo
potmin = 0.000; % potencial m�nimo
npart = max(round(qtnode*labp),nclass);
cnpart = nclass; % quantidade de part�culas inicial � igual ao n�mero de classes
valpha = round(valpha / (npart-cnpart+1));
stopmax = round((qtnode/cnpart) * valpha); % qtde de itera��es para verificar converg�ncia 
W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
clear X;
graph = zeros(qtnode,'single');
% eliminando a dist�ncia para o pr�prio elemento
W = W + eye(qtnode)*realmax;
% construindo grafo
for i=1:k-1
    [~,ind] = min(W,[],2);
    graph(sub2ind(size(graph),1:qtnode,ind')) = 1;
    graph(sub2ind(size(graph),ind',1:qtnode)) = 1;
    W(sub2ind(size(W),1:qtnode,ind')) = +Inf;
end
% �ltimos vizinhos do grafo (n�o precisa atualizar W pq n�o ser� mais
% usado)
[~,ind] = min(W,[],2);
clear W;
graph(sub2ind(size(graph),1:qtnode,ind'))=1;
graph(sub2ind(size(graph),ind',1:qtnode))=1;
clear ind;
% rotulando apenas um elemento por classe
slabel = zeros(qtnode,1);
for i=1:nclass
    while 1
        r = random('unid',qtnode);
        if label(r)==i
            break;
        end
    end
    slabel(r)=i;
end
% definindo classe de cada part�cula
partclass = zeros(npart,1);
partclass(1:cnpart) = slabel(slabel~=0);
% definindo n� casa da part�cula
partnode = zeros(npart,1);
partnode(1:cnpart) = find(slabel);
% definindo potencial da part�cula em 1
potpart = repmat(potmax,npart,1);
% ajustando todas as dist�ncias na m�xima poss�vel
distnode = repmat(qtnode-1,qtnode,npart);
% ajustando para zero a dist�ncia de cada part�cula para seu
% respectivo n� casa
distnode(sub2ind(size(distnode),partnode(1:cnpart)',1:cnpart)) = 0;
% inicializando tabela de potenciais com tudo igual
pot = repmat(potmax/nclass,qtnode,nclass);
% zerando potenciais dos n�s rotulados
pot(partnode(1:cnpart),:) = 0;
% ajustando potencial da classe respectiva do n� rotulado para 1
pot(sub2ind(size(pot),partnode(1:cnpart),slabel(partnode(1:cnpart)))) = 1;
% colocando cada n� em sua casa
partpos = partnode;
% criando c�lula para listas de vizinhos
nsize = double(sum(graph));
nlist = zeros(qtnode,max(nsize));
for i=1:qtnode
    nlist(i,1:nsize(i)) = find(graph(i,:)==1);
end
clear graph;
% definindo grau de propriedade
owndeg = repmat(realmin,qtnode,nclass);  % n�o podemos usar 0, porque n�s n�o visitados dariam divis�o por 0
while 1
    [pot, owndeg, distnode] = strwalk21loop(cnpart, nclass, stopmax, pdet, dexp, deltav, deltap, potmin, partpos, partclass, potpart, slabel, nsize, distnode, nlist, pot, owndeg);
    if cnpart < npart
        % aumentando contador do n�mero atual de part�culas
        cnpart = cnpart + 1;
        % atualiza qtde de itera��es para verificar converg�ncia
        stopmax = round((qtnode/cnpart)*valpha);
        % descobrindo qual � o n� mais amb�guo
        potsort = sort(pot,2,'descend');
        [~,ind] = max(potsort(:,2)./potsort(:,1));
        % rotulando n� mais amb�guo
        slabel(ind) = label(ind);
        % ajustando potenciais do n� mais amb�guo
        pot(ind,:)=0;
        pot(ind,label(ind))=1;
        partclass(cnpart)=label(ind);     % definindo classe da part�cula
        distnode(ind,cnpart)=0;           % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de sua respectiva part�cula
        partpos(cnpart)=ind;              % definindo posi��o inicial da part�cula para seu respectivo n� pr�-rotulado
        %disp(sprintf('Iter %2.0f  CNPart: %2.0f  N�: %2.0f',i,cnpart,ind))
    else
        break;
    end
end
[~,owner] = max(pot,[],2);
owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end

