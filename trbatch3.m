ind=1;
tab_acc = zeros(33,1);
tab_std_acc = zeros(33,1);
iter_acc = zeros(100,1);
ind_x=1;
for i=0.00:0.25:8.00
    for l=1:100
        [graph, label] = nwgraphgen2([32 32 32 32],i,16);
        [owner, pot] = ftrwalk2(graph, 4, 20000, 0.4, 0.4);
        iter_acc(l) = tmweval(label,owner);
        disp(sprintf('z_out: %0.4f  z_out/k: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,i/16,l,iter_acc(l)))
    end
    tab_acc(ind_x)=mean(iter_acc);
    tab_std_acc(ind_x)=std(iter_acc);
    disp(sprintf('z_out: %0.4f  z_out/k: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f',i,i/16,tab_acc(ind_x),tab_std_acc(ind_x)))
    save tab_acc tab_acc;
    save tab_std_acc tab_std_acc;
    ind_x = ind_x + 1;
end