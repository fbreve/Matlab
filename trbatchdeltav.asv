rep = 20;
deltavmax = 20;
pdetmax = 21;
iter_acc = zeros(rep,1);
iter_kap = zeros(rep,1);
iter_acc2 = zeros(rep,1);
iter_kap2 = zeros(rep,1);
tab_acc = zeros(deltavmax,1);
tab_kap = zeros(deltavmax,1);
tab_acc2 = zeros(deltavmax,1);
tab_kap2 = zeros(deltavmax,1);
for l=1:rep
    [graph, label] = graphgen3([128 128 128 128],32,64);
    slabel = slabelgen(label,0.10);
    parfor i=1:deltavmax
        deltav = i * 0.05;
        [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 4, 500000, 0.7, 0.35, 0.35, 2);
        [iter_acc,iter_kap] = stmwevalk(label,slabel,owner);
        [~,owner2] = max(owndeg,[],2);
        [iter_acc2,iter_kap2] = stmwevalk(label,slabel,owner2);
        disp(sprintf('Iteração: %3.0f DeltaP: %0.2f Pdet: %0.2f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',l,deltap,pdet,iter_acc,iter_kap,iter_acc2,iter_kap2))
        tab_acc(i,j)  = tab_acc(i,j)  + iter_acc;
        tab_kap(i,j)  = tab_kap(i,j)  + iter_kap;
        tab_acc2(i,j) = tab_acc2(i,j) + iter_acc2;
        tab_kap2(i,j) = tab_kap2(i,j) + iter_kap2;
    end
    save tab_deltappdet tab_acc tab_kap tab_acc2 tab_kap2 l
end
tab_acc  = tab_acc  ./ rep;
tab_kap  = tab_kap  ./ rep;
tab_acc2 = tab_acc2 ./ rep;
tab_kap2 = tab_kap2 ./ rep;