rep = 100;
deltapmax = 20;
deltavmax = 20;
iter_acc = zeros(rep,1);
iter_kap = zeros(rep,1);
iter_acc2 = zeros(rep,1);
iter_kap2 = zeros(rep,1);
tab_acc = zeros(deltapmax,deltavmax);
tab_kap = zeros(deltapmax,deltavmax);
tab_acc2 = zeros(deltapmax,deltavmax);
tab_kap2 = zeros(deltapmax,deltavmax);
for l=1:rep
    [graph, label] = graphgen3([32 32 32 32],8,16);
    slabel = slabelgen(label,0.10);
    for i=1:deltapmax
        parfor j=1:deltavmax
            deltap = i * 0.05;
            deltav = j * 0.05;
            [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 4, 500000, 0.70, deltav, deltap, 2);
            [iter_acc,iter_kap] = stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            [iter_acc2,iter_kap2] = stmwevalk(label,slabel,owner2);
            disp(sprintf('Iteração: %3.0f DeltaP: %0.2f DeltaV: %0.2f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',l,deltap,deltav,iter_acc,iter_kap,iter_acc2,iter_kap2))
            tab_acc(i,j)  = tab_acc(i,j)  + iter_acc;
            tab_kap(i,j)  = tab_kap(i,j)  + iter_kap;
            tab_acc2(i,j) = tab_acc2(i,j) + iter_acc2;
            tab_kap2(i,j) = tab_kap2(i,j) + iter_kap2;            
        end        
    end
    save tab_deltas tab_acc tab_kap tab_acc2 tab_kap2 l
end
tab_acc  = tab_acc  ./ rep;
tab_kap  = tab_kap  ./ rep;
tab_acc2 = tab_acc2 ./ rep;
tab_kap2 = tab_kap2 ./ rep;