% Método Linear Neighborhood Propagation de Fei Wang et. al.
% Uso: owner = lnp(X,slabel,k,alpha,nclass,iter)
% X = vetor de atributos (linha = elementos, coluna = atributos)
% slabel = vetor com rótulo numérico (>0) dos elementos pré-rotulados (0 para 
%          elementos não rotulados)
% nclass = número de classes
% iter = número de iterações
% alpha = no inteverlo [0 1], define quantidade relativa de informação vinda dos
%         vizinhos e da informação inicial
% k = número de vizinhos mais próximos na formação do grafo
function owner = molnp(X,slabel,k,alpha,nclass,iter)
if (nargin < 6) || isempty(iter),
    iter = 10000; % número de iterações
end
if (nargin < 5) || isempty(nclass),
    nclass = max(slabel); % quantidade de classes
end
if (nargin < 4) || isempty(alpha),
    alpha = 0.99;
end
[qtnode,qtfeat] = size(X);  % quantidade de elementos e atributos
disp('Calculando distâncias')
[~,IX] = sort(squareform(pdist(single(X),'euclidean').^2)); % índices dos vizinhos mais próximos
IX = IX(2:k+1,:); % descartando índices que não serão necessários
disp('Montando rede')
W = zeros(qtnode); % inicializando matriz de adjacência
parfor i=1:qtnode
   N = X(IX(:,i),:)'; % matriz onde cada coluna é um vizinho mais próximo e cada linha um atributo
   % Matriz de Gram pelo artigo antigo
   Gp = ((X(i,:)' * ones(1,k)) - N);
   G = Gp' * Gp;
   % Matriz de Gram pelos artigos novos (dá os mesmos valores)
%    for l=1:k
%         for j=1:k            
%             G(l,j) = (X(i,:)'-N(:,l))' * (X(i,:)'-N(:,j));
%         end
%    end
   if k>qtfeat
        G = G + 0.1 * trace(G) * eye(k); % regularização extra para evitar G singular ou quase singular
   end
   % Solução de mínimos quadrados fechada (lenta) - artigo + antigo
   %one = ones(k,1);
   %GInv = G^-1;
   %w = (GInv * one) / (one' * GInv * one);
   % Solução por resolução de equação linear - artigo + antigo   
%    w = G \ ones(k,1); % resolver equação linear para encontrar pesos (mais eficiente que inversão)
%    w = w ./ sum(w); % normalizar pesos encontrados
   % Solução por minimização
   options = optimset('LargeScale','off','Display','off');
   w = quadprog(G,ones(1,k),[],[],ones(1,k),1,zeros(k,1),ones(k,1),[],options);
   % fim solução
   wi = zeros(1,qtnode); 
   wi(IX(:,i)) = w;
   W(i,:) = wi;    
end
clear N Gp G w wi;
disp('Rede montada')
Y = zeros(qtnode,nclass);
noch = 0; % conta a quantas iterações não houve mudança
for i=1:qtnode
    if slabel(i)~=0
        Y(i,slabel(i))=1;
    end
end
F = Y;
[~,owner] = max(F,[],2);
alphaW = alpha * W;
clear W;
alphaY = (1 - alpha) * Y;
clear Y;
disp('Iniciando iterações')
for i=1:iter 
     F = alphaW * F + alphaY;
     ownerbak = owner;
     [~,owner] = max(F,[],2);
     if sum(ownerbak~=owner)==0  % se não houve mudança
         noch = noch + 1;
         if noch>=100  % testa convergência
             break; 
         end
     else
         noch = 0;
     end
end
end