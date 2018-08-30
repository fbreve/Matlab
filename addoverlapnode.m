% Adiciona um n� overlap ao grafo passado como par�metro
% Uso: graph = addoverlapnode(graph,label,connect);
% graph = grafo existente
% label = labels do grafo existente
% connect = vetor onde cada elemento � a quantidade de liga��es do n�
% overlap com a comunidade correspondente ao �ndice

function [graph,label] = addoverlapnode(graph,label,connect)
% guarda tamanho original do grafo
graphorgsize = size(graph,1); 
% define o �ndice do novo n�
newnode = graphorgsize+1;
% acresenta linha e coluna na matriz de adjac�ncias correspondente ao novo
% n�
graph(newnode,:) = 0;
graph(:,newnode) = 0;
% atribuindo label do novo n� para comunidade com qual ele tem mais
% liga��es
[nil,label(newnode)] = max(connect);
% enquanto n�o adicionar todas as conex�es necess�rias
while sum(connect)>0
    % gerando par para n� overlap
    node = ceil(random('unif',0,graphorgsize));
    % verificando se j� h� conex�o com tal n� e se ainda s�o necess�rias
    % liga��es com a comunidade dele
    if graph(newnode,node)==0 && connect(label(node))>0
        % adicionando conex�es no grafo
        graph(newnode,node)=1;
        graph(node,newnode)=1;
        % descontando 1 no n�mero de liga��es necess�rias
        connect(label(node)) = connect(label(node))-1;
    end
end