jettable = rgb2hsv(jet(1001));

qtnode = size(graph,1);

dotfile = fopen('walk.dot','w+');
fprintf(dotfile,'graph Walk {\n');

fontcolor = color<0.3;

for i=1:qtnode
    %fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3));
    %fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][width=%.4f][height=%.4f][fontcolor="0,0,%.1f"]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),0.75+color(i),0.75+color(i),fontcolor(i));
    
    % linha abaixo ainda não testada, acrescenta tamanho de fonte (p/ ser usado no IEEE-TKDE R2), acrescenta parâmetro fontsize
    fprintf(dotfile,'%i [fillcolor="%.4f,%.4f,%.4f"][style=filled][width=%.4f][height=%.4f][fontcolor="0,0,%.1f"][fontsize=25]\n',i,jettable(round(color(i)*1000)+1,1),jettable(round(color(i)*1000)+1,2),jettable(round(color(i)*1000)+1,3),0.75+color(i),0.75+color(i),fontcolor(i));
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