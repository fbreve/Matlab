ind=1;
tab_acc = zeros(21,20);
tab_std_acc = zeros(21,20);
iter_acc = zeros(4,1);
ind_x=1;
ind_y=1;
for i=0.00:0.05:1.00
    for j=0.05:0.05:1.00
        parfor l=1:4
            [graph, label] = graphgen3([32 32 32 32],8,16);
            [owner, pot] = wtrwalk2(graph, 4, 100000, i, j, 1.0, 20);
            iter_acc(l) = tmweval(label,owner);
            %disp(sprintf('Pdet: %0.4f  DeltaV: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,j,l,iter_acc(l)))
        end
        tab_acc(ind_x,ind_y)=mean(iter_acc);
        tab_std_acc(ind_x,ind_y)=std(iter_acc);
        disp(sprintf('Pdet: %0.4f  DeltaV: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f',i,j,tab_acc(ind_x,ind_y),tab_std_acc(ind_x,ind_y)))
        save tab_acc tab_acc;
        save tab_std_acc tab_std_acc;
        ind_y = ind_y + 1;
    end
    ind_y = 1;
    ind_x = ind_x + 1;
end