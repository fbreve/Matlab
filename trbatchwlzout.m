rep = 100;
zoutmax = 16;
amwrlabmax = 51;
iter_acc = zeros(rep,1);
iter_kap = zeros(rep,1);
%iter_acc2 = zeros(rep,1);
%iter_kap2 = zeros(rep,1);
tab_acc = zeros(zoutmax,amwrlabmax);
tab_kap = zeros(zoutmax,amwrlabmax);
%tab_acc2 = zeros(zoutmax,amwrlabmax);
%tab_kap2 = zeros(zoutmax,amwrlabmax);
for i=[3, 12:1:zoutmax]
     %for j=1:amwrlabmax
    for j=1:1:amwrlabmax
        zout = i*2;
        amwrlab = j*0.02 - 0.02;
        parfor l=1:rep
            [graph, label] = graphgen3([128 128 128 128],zout,64);
            slabel = slabelgenwl(label,0.10,amwrlab);
            %[owner, pot, owndeg, distnode] = strwalk8(X, slabel, 4, 500000, 0.5, 0.1, 1, 1, 2);
            %[owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 4, 500000, 0.5, 0.1, 1, 2);
            owner = strwalk11g(graph, slabel);
            %owner = zhou(X,slabel,4,10000,0.99,10);
            [iter_acc(l),iter_kap(l)] = stmwevalk(label,slabel,owner);
            %[nil,owner2] = max(owndeg,[],2);
            %[iter_acc2(l),iter_kap2(l)] = stmwevalk(label,slabel,owner2);
            %disp(sprintf('Z_out: %0.2f Rótulo Errado: %0.2f Iteração: %3.0f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',zout,amwrlab,l,iter_acc(l),iter_kap(l),iter_acc2(l),iter_kap2(l)))
            disp(sprintf('Z_out: %0.2f Rótulo Errado: %0.2f Iteração: %3.0f Acerto: %0.4f Kappa: %0.4f',zout,amwrlab,l,iter_acc(l),iter_kap(l)))
        end
        tab_acc(i,j) = mean(iter_acc);
        tab_kap(i,j) = mean(iter_kap);
        %tab_acc2(i,j) = mean(iter_acc2);
        %tab_kap2(i,j) = mean(iter_kap2);        
        %disp(sprintf('MEDIA: Z_out: %0.2f Rótulo Errado: %0.2f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',zout,amwrlab,tab_acc(i,j),tab_kap(i,j),tab_acc2(i,j),tab_kap2(i,j)))
        disp(sprintf('MEDIA: Z_out: %0.2f Rótulo Errado: %0.2f Acerto: %0.4f Kappa: %0.4f',zout,amwrlab,tab_acc(i,j),tab_kap(i,j)))
        %save tab_wlzout tab_acc tab_kap tab_acc2 tab_kap2
        save tab_wlzout tab_acc tab_kap
    end   
end