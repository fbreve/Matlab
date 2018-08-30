% Adiciona um nó overlap ao grafo passado como parâmetro
% Uso: graph = addoverlapnode(graph,label,connect);
% graph = grafo existente
% label = labels do grafo existente
% connect = vetor onde cada elemento é a quantidade de ligações do nó
% overlap com a comunidade correspondente ao índice

function [graph,label] = addoverlapnode(graph,label,connect)
% guarda tamanho original do grafo
graphorgsize = size(graph,1); 
% define o índice do novo nó
newnode = graphorgsize+1;
% acresenta linha e coluna na matriz de adjacências correspondente ao novo
% nó
graph(newnode,:) = 0;
graph(:,newnode) = 0;
% atribuindo label do novo nó para comunidade com qual ele tem mais
% ligações
[nil,label(newnode)] = max(connect);
% enquanto não adicionar todas as conexões necessárias
while sum(connect)>0
    % gerando par para nó overlap
    node = ceil(random('unif',0,graphorgsize));
    % verificando se já há conexão com tal nó e se ainda são necessárias
    % ligações com a comunidade dele
    if graph(newnode,node)==0 && connect(label(node))>0
        % adicionando conexões no grafo
        graph(newnode,node)=1;
        graph(node,newnode)=1;
        % descontando 1 no número de ligações necessárias
        connect(label(node)) = connect(label(node))-1;
    end
end