% M�todo Linear Neighborhood Propagation de Fei Wang et. al.
% Uso: owner = zhou(X,slabel,nclass,iter,alpha,k)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% iter = n�mero de itera��es
% alpha = no inteverlo [0 1], define quantidade relativa de informa��o vinda dos
%         vizinhos e da informa��o inicial
% k = n�mero de vizinhos mais pr�ximos na forma��o do grafo
function owner = lnp(X,slabel,nclass,iter,alpha,k)
qtnode = size(X,1);  % quantidade de elementos
[~,IX] = sort(squareform(pdist(X,'seuclidean').^2)); % �ndices dos vizinhos mais pr�ximos
IX = IX(2:k+1,:); % descartando �ndices que n�o ser�o necess�rios
W = zeros(qtnode); % inicializando matriz de adjac�ncia
parfor i=1:qtnode
   N = X(IX(:,i),:)'; % matriz onde cada coluna � um vizinho mais pr�ximo e cada linha um atributo
   Gp = ((X(1,:)' * ones(1,k)) - N);
   G = Gp' * Gp;
   G = G + 0.3 * trace(G) * eye(k); % regulariza��o extra para evitar G singular ou quase singular
   w = G \ ones(k,1); % resolver equa��o linear para encontrar pesos (mais eficiente que invers�o)
   w = w ./ sum(w); % normalizar pesos encontrados
   wi = zeros(1,qtnode); 
   wi(IX(:,i)) = w;
   W(i,:) = wi;   
end
Y = zeros(qtnode,nclass); 
noch = 0; % conta a quantas itera��es n�o houve mudan�a
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
F = Y;
[~,owner] = max(F,[],2);
for i=1:iter 
     F = alpha * W * F + (1 - alpha) * Y;
     ownerbak = owner;
     [~,owner] = max(F,[],2);
     if sum(ownerbak~=owner)==0  % se n�o houve mudan�a
         noch = noch + 1;
         if noch>=100  % testa converg�ncia
             break; 
         end
     else
         noch = 0;
     end
end
end