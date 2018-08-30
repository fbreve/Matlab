% Gerador de grafo sem peso
% Baseado nas regras geração usadas em: "Comparing community structure identification"
% de Leon Danon, Albert D´?az-Guilera1, Jordi Duch2 and Alex Arenas.
% Journal of Statistical Mechanics: An IOP and SISSA journal Theory and
% Experiment, 2008.
% Uso: [graph, label] = graphgen3(csize,zout,k)
% Parâmetros:
% csize = vetor com n elementos onde n é o número de comunidades a serem geradas e os valores indicam quantos elementos tem cada comunidade
% zout = média de conexões externas dos vértices da rede
% k = grau médio da rede
% Saída:
% grafo = matriz de adjacências do grafo gerado
% label = vetor com os labels de cada nó do grafo gerado
function [graph, label] = graphgen3(csize,zout,k)
%total de elementos
totel = sum(csize);
% declara grafo
graph = zeros(totel);
% declara vetor de labels
label = zeros(totel,1);

% construindo vetor com label de cada nó
c=1;
for i=1:size(csize,2)
    for j=1:csize(i)
        label(c)=i;
        c = c + 1;
    end   
end

% conectando cada vértice com o vértice de índice vizinho
%for i=1:(sum(csize)-1)
%    graph(i,i+1)=1;
%    graph(i+1,i)=1;
%end
%graph(1,sum(csize))=1;
%graph(sum(csize),1)=1;

pin = (k-zout)./csize;
pout = zout./(totel-csize);
rzin = 0;
rzout = 0;

randtable = unifrnd(0,1,((totel.^2-totel)/2),1);
indrand = 1;

for i=1:totel
    for j=i+1:totel
        rand = randtable(indrand);
        indrand = indrand + 1;
        if label(i)==label(j) 
            if rand<pin(label(i))
                graph(i,j)=1;
                graph(j,i)=1;
                rzin=rzin+2;
            end
        else
            if rand<((pout(label(i))+pout(label(j)))/2)
                graph(i,j)=1;
                graph(j,i)=1;
                rzout=rzout+2;
            end            
        end
    end
end
rzin = rzin/sum(csize);
rzout = rzout/sum(csize);
k = rzin+rzout;
disp(sprintf('K= %0.4f  Zin: %0.4f  Zout: %0.4f  Zout/K= %0.4f',k,rzin,rzout,(rzout/k)))