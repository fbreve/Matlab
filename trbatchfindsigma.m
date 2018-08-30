rep = 1; % numero de repetições
xs = 20;
iter_acc = zeros(rep*10,xs);
iter_kap = zeros(rep*10,xs);
x=1;
for p=0.01:0.01:0.1
    for l=1:rep
        slabel = slabelgen(label,p);
        parfor i=1:xs
            sigma = i;
            owner = zhou(X,slabel,4,10000,0.99,sigma);
            %owner = labelprop(X,slabel,2,10000,sigma);
            %[owner, pot, owndeg, distnode] = strwalk8(X, slabel, 10, 200000, 0.5, 0.1, 1.0, sigma, 2);
            [iter_acc(x,i),iter_kap(x,i)] = stmwevalk(label,slabel,owner);
            disp(sprintf('Sigma: %2.2f  Acerto: %0.4f  Kappa: %0.4f',sigma,iter_acc(x,i),iter_kap(x,i)))
        end
        disp(sprintf('Conj.: %3.0f de %3.0f completo',x,xs*rep))
        x = x + 1;        
    end
end
tab_acc=mean(iter_acc);
tab_std_acc=std(iter_acc);
tab_min_acc=min(iter_acc);
tab_max_acc=max(iter_acc);
tab_kap=mean(iter_kap);
tab_std_kap=std(iter_kap);
tab_min_kap=min(iter_kap);
tab_max_kap=max(iter_kap);
save tabs_findsigma tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;