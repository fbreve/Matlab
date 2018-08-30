% Gera grafo conectando k-vizinhos mais pr�ximos sem peso
% Uso: graph = graphgenknn(X,k,disttype)
% X = base de dados, cada linha um elemento, cada coluna um atributo
% k = quantidade de vizinhos a serem conectados
% disttype = tipo de dist�ncia
function graph = graphgenknn(X,k,disttype)
    qtnode = size(X,1);
    W = squareform(pdist(X,disttype).^2);  % gerando matriz de afinidade
    clear X;
    
%     B = sort(W,2);  % ordenando matriz de afinidade
%     BS = B(:,k+1);
%     clear B;
%     graph = W <= repmat(BS,1,qtnode);  % conectando k-vizinhos mais pr�ximos
%     clear BS W;
%     graph = graph | graph';
%     graph = graph - eye(qtnode);  % zerando diagonal do grafo
    
    graph = zeros(qtnode,'single');
    % eliminando a dist�ncia para o pr�prio elemento
    [~,ind] = min(W,[],2);
    for j=1:qtnode        
        W(j,ind(j))=+Inf;
    end
    % construindo grafo
    for i=1:k-1
        [~,ind] = min(W,[],2);
        for j=1:qtnode
            graph(j,ind(j))=1;
            graph(ind(j),j)=1;
            W(j,ind(j))=+Inf;
        end
    end
    % �ltimos vizinhos do grafo (n�o precisa atualizar W pq n�o ser� mais
    % usado)
    [~,ind] = min(W,[],2);
    clear W;
    for j=1:qtnode
        graph(j,ind(j))=1;
        graph(ind(j),j)=1;
    end
    clear ind;    
end