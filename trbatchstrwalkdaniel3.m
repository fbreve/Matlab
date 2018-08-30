% pré-carregar tabdaniel.mat
% pré-caregar label da base de dados 
rep = 100;
knnconfamount = size(tabdaniel,2);
for j=1:12
    [label,slabel] = trreadlabels(y,idxLabs,j);
    for i=1:rep
        parfor j2=1:knnconfamount
            owner = strwalk8knnmex(tabdaniel{j2}, slabel);
            tab_res(j2,j,i) = stmwevalk(label,slabel,owner);
            disp(sprintf('Conf: %2.0f  Subconjunto: %2.0f  Rep.: %i/%i  Acerto: %0.4f',j2,j,i,rep,tab_res(j2,j,i)))
        end        
    end
    save tabs_daniel tab_res
end

