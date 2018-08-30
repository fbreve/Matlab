% Gerador de grafo para o
% M�todo Linear Neighborhood Propagation de Fei Wang et. al.
% Uso: W = graphgenlnp(X,k,nclass)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com r�tulo num�rico (>0) dos elementos pr�-rotulados (0 para 
%          elementos n�o rotulados)
% nclass = n�mero de classes
% k = n�mero de vizinhos mais pr�ximos na forma��o do grafo
function W = graphgenlnp(X,k)
[qtnode,qtfeat] = size(X);  % quantidade de elementos e atributos
disp('Calculando dist�ncias')
[~,IX] = sort(squareform(pdist(X,'euclidean').^2)); % �ndices dos vizinhos mais pr�ximos
IX = IX(2:k+1,:); % descartando �ndices que n�o ser�o necess�rios
disp('Montando rede')
W = zeros(qtnode); % inicializando matriz de adjac�ncia
parfor i=1:qtnode
   N = X(IX(:,i),:)'; % matriz onde cada coluna � um vizinho mais pr�ximo e cada linha um atributo
   % Matriz de Gram pelo artigo antigo
   Gp = ((X(i,:)' * ones(1,k)) - N);
   G = Gp' * Gp;
   % Matriz de Gram pelos artigos novos (d� os mesmos valores)
%    for l=1:k
%         for j=1:k            
%             G(l,j) = (X(i,:)'-N(:,l))' * (X(i,:)'-N(:,j));
%         end
%    end
   if k>qtfeat
        G = G + 0.1 * trace(G) * eye(k); % regulariza��o extra para evitar G singular ou quase singular
   end
   % Solu��o de m�nimos quadrados fechada (lenta) - artigo + antigo
   %one = ones(k,1);
   %GInv = G^-1;
   %w = (GInv * one) / (one' * GInv * one);
   % Solu��o por resolu��o de equa��o linear - artigo + antigo   
%    w = G \ ones(k,1); % resolver equa��o linear para encontrar pesos (mais eficiente que invers�o)
%    w = w ./ sum(w); % normalizar pesos encontrados
   % Solu��o por minimiza��o
   options = optimset('LargeScale','off','Display','off');
   w = quadprog(G,ones(1,k),[],[],ones(1,k),1,zeros(k,1),ones(k,1),[],options);
   % fim solu��o
   wi = zeros(1,qtnode); 
   wi(IX(:,i)) = w;
   W(i,:) = wi;    
end
