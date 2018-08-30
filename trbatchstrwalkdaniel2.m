% pré-carregar tabdaniel.mat
% pré-caregar label da base de dados 
rep = 1000;
knnconfamount = size(tabdaniel,2);
labamountmax = 25;
for j=1:labamountmax
    amount = j*0.02;
    for i=1:rep
        slabel = slabelgen(label,amount);
        parfor j2=1:knnconfamount
            owner = strwalk8knnmex(tabdaniel{j2}, slabel);
            tab_res(j2,j,i) = stmwevalk(label,slabel,owner);
            disp(sprintf('Conf: %2.0f LabProp: %0.2f Rep.: %i/%i  Acerto: %0.4f',j2,amount,i,rep,tab_res(j2,j,i)))
        end        
    end
    save tabs_daniel tab_res
end

