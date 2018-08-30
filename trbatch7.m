ind=1;
tab_acc = zeros(10,10);
tab_std_acc = zeros(10,10);
iter_acc = zeros(50,1);
ind_x=1;
ind_y=1;
for i=0.1:0.1:1.00
    for j=0.1:0.1:1.00
        parfor l=1:50
            [graph, label] = graphgen3([32 32 32 32],8,16);
            [owner, owner2, pot, owndeg] = ftrwalk6g(graph, 4, 200000, 0.6, j, i);
            iter_acc(l) = tmweval(label,owner2);
            disp(sprintf('Ml: %0.4f  Pdet: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,j,l,iter_acc(l)))
        end
        tab_acc(ind_x,ind_y)=mean(iter_acc);
        tab_std_acc(ind_x,ind_y)=std(iter_acc);
        disp(sprintf('DeltaP: %0.4f  DeltaV: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f',i,j,tab_acc(ind_x,ind_y),tab_std_acc(ind_x,ind_y)))
        save tab_acc tab_acc;
        save tab_std_acc tab_std_acc;
        ind_y = ind_y + 1;
    end
    ind_y = 1;
    ind_x = ind_x + 1;
end