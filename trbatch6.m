ind=1;
tab_acc = zeros(21,40);
tab_std_acc = zeros(21,40);
iter_acc = zeros(20,1);
ind_x=1;
ind_y=1;
for i=0.00:0.05:1.00
    for j=1:1:40
        parfor l=1:20
            [graph, label] = wgraphgen2([32 32 32 32],i);
            [owner, pot] = wtrwalk(graph, 4, 20000, 0.45, 0.3, j);
            iter_acc(l) = tmweval(label,owner);
            %disp(sprintf('Ml: %0.4f  Pdet: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,j,l,iter_acc(l)))
        end
        tab_acc(ind_x,ind_y)=mean(iter_acc);
        tab_std_acc(ind_x,ind_y)=std(iter_acc);
        disp(sprintf('Ml: %0.4f  probexp: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f',i,j,tab_acc(ind_x,ind_y),tab_std_acc(ind_x,ind_y)))
        save tab_acc tab_acc;
        save tab_std_acc tab_std_acc;
        ind_y = ind_y + 1;
    end
    ind_y = 1;
    ind_x = ind_x + 1;
end