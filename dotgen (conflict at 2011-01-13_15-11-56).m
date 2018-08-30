% Gerador de arquivo .dot para uso no Graphviz
% Uso: dotgen(filename,graph,own,overlap)
% filename = nome do arquivo .dot
% graph = matriz de adjacências do grafo a ser plotado
% overlap = 0 se for para gerar grafo dos hard labels
% overlap = 1 se for para gerar grafo de nível de overlap
% own = owner ou owndeg
% -- owner = vetor com classe de cada elemento (de 1 a n)
% -- owndeg = matriz onde cada linha um elemento e cada coluna o grau de
% pertinência para cada classe.
function dotgen(filename,graph,own,overlap)

jettable = rgb2hsv(jet(1001));

qtnode = size(graph,1);

if overlap==0
    qtclass = max(own);
    color = own./qtclass;
else    
    owndegsort = sort(own,2,'descend');
    color = owndegsort(:,2)./owndegsort(:,1);
end

dotfile = fopen(filename,'w+');
fprintf(dotfile,'graph Walk {\n');

fontcolor = color<0.3;

for i=1:qtnode
    %fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3));
    %fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][width=%.4f][height=%.4f][fontcolor="0,0,%.1f"]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),0.75+color(i),0.75+color(i),fontcolor(i));
    
    % linha abaixo acrescenta tamanho de fonte (p/ ser usado no IEEE-TKDE R2), acrescenta parâmetro fontsize
    if overlap==1
        fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][width=%.4f][height=%.4f][fontcolor="0,0,%.1f"][fontsize=25]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),1+color(i),1+color(i),fontcolor(i));
        %fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][fontcolor="0,0,%.1f"]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),fontcolor(i));
    else
        fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][fontcolor="0,0,%.1f"][fontsize=25]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),fontcolor(i));
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