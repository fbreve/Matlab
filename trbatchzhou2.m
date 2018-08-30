rep = 100; % numero de repetições
isize = 10;
tab_acc = zeros(isize,1);
tab_std_acc = zeros(isize,1);
tab_min_acc = zeros(isize,1);
tab_max_acc = zeros(isize,1);
iter_acc = zeros(rep,1);
tab_kap = zeros(isize,1);
tab_std_kap = zeros(isize,1);
tab_min_kap = zeros(isize,1);
tab_max_kap = zeros(isize,1);
iter_kap = zeros(rep,1);
ind_x=1;
for i=0.5:0.5:5
    parfor l=1:rep
        slabel = slabelgen(label,l*(1/rep)*0.1);
        owner = zhou(X,slabel,2,10000,0.99,i);
        [iter_acc(l),iter_kap(l)] = stmwevalk(label,slabel,owner);
        %disp(sprintf('Sigma: %2.2f  Acerto: %0.4f  Kappa: %0.4f',i,acc,k))
    end
    tab_acc(ind_x)=mean(iter_acc);
    tab_std_acc(ind_x)=std(iter_acc);
    tab_min_acc(ind_x)=min(iter_acc);
    tab_max_acc(ind_x)=max(iter_acc);
    tab_kap(ind_x)=mean(iter_kap);
    tab_std_kap(ind_x)=std(iter_kap);
    tab_min_kap(ind_x)=min(iter_kap);
    tab_max_kap(ind_x)=max(iter_kap);    
    disp(sprintf('Sigma: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f  Mínimo: %0.4f  Máximo: %0.4f',i,tab_acc(ind_x),tab_std_acc(ind_x),tab_min_acc(ind_x),tab_max_acc(ind_x)))
    disp(sprintf('Sigma: %0.4f   Kappa Médio: %0.4f  Desv. Pad.: %0.4f  Mínimo: %0.4f  Máximo: %0.4f',i,tab_kap(ind_x),tab_std_kap(ind_x),tab_min_kap(ind_x),tab_max_kap(ind_x)))
    %save tabs tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;
    ind_x = ind_x + 1;
end