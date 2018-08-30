iter_acc = zeros(100,1);
tab_acc=0;
tab_std_acc=0;
ind_x=1;
for l=1:100
    owner = kmeans(X,3);
    iter_acc(l) = tmweval(label,owner);
    disp(sprintf('iteração %3.0f Acerto: %0.4f',l,iter_acc(l)))
end
tab_acc=mean(iter_acc);
tab_std_acc=std(iter_acc);
disp(sprintf('Acerto Médio: %0.4f  Desv. Pad.: %0.4f',tab_acc,tab_std_acc))
save tab_acc tab_acc;
save tab_std_acc tab_std_acc;
