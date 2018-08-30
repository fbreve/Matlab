rep = 100;
sizemax = 16;
amwrlabmax = 51;
iter_acc = zeros(rep,1);
iter_kap = zeros(rep,1);
iter_acc2 = zeros(rep,1);
iter_kap2 = zeros(rep,1);
tab_acc = zeros(sizemax,amwrlabmax);
tab_kap = zeros(sizemax,amwrlabmax);
tab_acc2 = zeros(sizemax,amwrlabmax);
tab_kap2 = zeros(sizemax,amwrlabmax);
for i=15:1:15
    for j=41:amwrlabmax
        amwrlab = j*0.02 - 0.02;
        parfor l=1:rep
            [graph, label] = graphgen3([16*i 16*i 16*i 16*i],2*i,8*i);
            slabel = slabelgenwl(label,0.10,amwrlab);
            %[owner, pot, owndeg, distnode] = strwalk8(X, slabel, 4, 500000, 0.5, 0.1, 1, 1, 2);
            [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 4, 500000, 0.5, 0.1, 1, 2);
            %owner = zhou(X,slabel,4,10000,0.99,10);
            [iter_acc(l),iter_kap(l)] = stmwevalk(label,slabel,owner);
            [nil,owner2] = max(owndeg,[],2);
            [iter_acc2(l),iter_kap2(l)] = stmwevalk(label,slabel,owner2);
            disp(sprintf('Tam.: %4.0f Rótulo Errado: %0.2f Iteração: %3.0f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',64*i,amwrlab,l,iter_acc(l),iter_kap(l),iter_acc2(l),iter_kap2(l)))
        end
        tab_acc(i,j) = mean(iter_acc);
        tab_kap(i,j) = mean(iter_kap);
        tab_acc2(i,j) = mean(iter_acc2);
        tab_kap2(i,j) = mean(iter_kap2);        
        disp(sprintf('MEDIA: Tam.: %4.0f Rótulo Errado: %0.2f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',64*i,amwrlab,tab_acc(i,j),tab_kap(i,j),tab_acc2(i,j),tab_kap2(i,j)))
        save tab_wlsize_gar tab_acc tab_kap tab_acc2 tab_kap2
    end   
end
