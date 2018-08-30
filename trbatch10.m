tab_zhou_acc = zeros(50,10);
tab_part_acc = zeros(50,10);
tab_part_std = zeros(50,10);
iter_part_acc = zeros(20,1);
ind_x=1;
for i=1:1:50
    %A=gendatb([250 250],i);
    %X = A.data;
    %label = A.nlab;
    slabel = zeros(150,1);
    slabel(i)=1;
    slabel(50+i)=2;
    slabel(100+i)=3;
    for j=1:1:10    
        owner = zhou(X,slabel,3,1000,0.99,j);
        tab_zhou_acc(ind_x,j) = stmweval(label,slabel,owner);
        parfor l=1:20
            [owner,pot] = strwalk(X,slabel,3,100000,500,0.6,0.1,1,j);
            iter_part_acc(l) = stmweval(label,slabel,owner);            
            %disp(sprintf('Ml: %0.4f  Pdet: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,j,l,iter_acc(l)))
        end
        tab_part_acc(ind_x,j)=mean(iter_part_acc);
        tab_part_std(ind_x,j)=std(iter_part_acc);
        disp(sprintf('Conjunto: %2.0f  Sigma: %1.0f  Acerto PART: %0.4f  Acerto ZHOU: %0.4f  Desv. Pad. PART: %0.4f',i,j,tab_part_acc(ind_x,j),tab_zhou_acc(ind_x,j),tab_part_std(ind_x,j)))
    end
    save tab_zhou_acc tab_zhou_acc;
  
    save tab_part_acc tab_part_acc;
    save tab_part_std tab_part_std;    
    ind_x = ind_x + 1;
end
