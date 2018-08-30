ind=1;
tab_acc = zeros(16);
tab_std_acc = zeros(16);
tab_ownch = zeros(16);
tab_std_ownch = zeros(16);
iter_acc = zeros(10,1);
iter_ownch = zeros(10,1);
ind_x=1;
ind_y=1;
for i=0.05:0.05:0.80
    for j=0.05:0.05:0.80       
        for l=1:10
            [owner, pot, ownch] = trwalk4(graph, 4, 20000, i, j, false);
            iter_acc(l) = tmweval(label,owner);
            iter_ownch(l) = ownch;
            disp(sprintf('DeltaP: %0.4f  DeltaV: %0.4f  Iteração: %2.0f  Acerto: %0.4f  Troca de Donos: %0.4f',i,j,l,iter_acc(l),ownch))
        end
        tab_acc(ind_x,ind_y)=mean(iter_acc);
        tab_std_acc(ind_x,ind_y)=std(iter_acc);
        tab_ownch(ind_x,ind_y)=mean(iter_ownch);
        tab_std_ownch(ind_x,ind_y)=std(iter_ownch);
        disp(sprintf('DeltaP: %0.4f  DeltaV: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f  Troca de Donos Média: %0.4f  Desv. Pad. Mud.: %0.4f',i,j,tab_acc(ind_x,ind_y),tab_std_acc(ind_x,ind_y),tab_ownch(ind_x,ind_y),tab_std_ownch(ind_x,ind_y) ))
        save tab_acc tab_acc;
        save tab_std_acc tab_std_acc;
        save tab_ownch tab_ownch;
        save tab_std_ownch tab_std_ownch;
        ind_y = ind_y + 1;
    end
    ind_y = 1;
    ind_x = ind_x + 1;
end