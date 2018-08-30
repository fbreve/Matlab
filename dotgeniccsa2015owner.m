% Gerador de arquivo .dot para uso no Graphviz
% Uso: dotgen(filename,graph,own,overlap)
% filename = nome do arquivo .dot
% graph = matriz de adjacências do grafo a ser plotado
% own = owner ou owndeg
% -- owner = vetor com classe de cada elemento (de 1 a n)
% -- owndeg = matriz onde cada linha um elemento e cada coluna o grau de
% pertinência para cada classe.
% fontsize poderia ser parâmetro, 30 é bom para nós até 2 dígitos, 24 para 3
% dígitos.
function dotgeniccsa2015owner(filename,graph,owner)

qtnode = size(graph,1);

dotfile = fopen(filename,'w+');
fprintf(dotfile,'graph Walk {\n');
fprintf(dotfile,'start=0\n');

for i=1:qtnode
    if owner(i)==1
        fprintf(dotfile,'%i [fillcolor=yellow][style=filled][pos="%i,%i"][pin=true]\n',i,ceil(i/16),17-mod(i-1,16)+1);
    else
        fprintf(dotfile,'%i [fillcolor=blue][style=filled][fontcolor=white][pos="%i,%i"][pin=true]\n',i,ceil(i/16),17-mod(i-1,16)+1);
    end
    for j=i+1:qtnode
        if graph(i,j)==1
            fprintf(dotfile,'%i -- %i\n',i,j);
            %fprintf(dotfile,'%i -- %i [len=%1.4f][width=%1.4f][color="#%s%s%s"]\n',i,j,5*(1-graph(i,j)),1-graph(i,j),dec2hex(round((1-graph(i,j))*255),2),dec2hex(round((1-graph(i,j))*255),2),dec2hex(round((1-graph(i,j))*255),2));
            %fprintf(dotfile,'%i -- %i [width=%1.4f][color="#%s%s%s"]\n',i,j,1-graph(i,j),dec2hex(round((1-graph(i,j))*255),2),dec2hex(round((1-graph(i,j))*255),2),dec2hex(round((1-graph(i,j))*255),2));
        end
    end
end

fprintf(dotfile,'}\n');
fclose(dotfile);
end