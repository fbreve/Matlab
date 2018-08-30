rep = 12;
deltavmax = 10;
pdetmax = 10;
iter_acc = zeros(rep,1);
iter_kap = zeros(rep,1);
iter_acc2 = zeros(rep,1);
iter_kap2 = zeros(rep,1);
tab_acc = zeros(deltavmax,pdetmax);
tab_kap = zeros(deltavmax,pdetmax);
tab_acc2 = zeros(deltavmax,pdetmax);
tab_kap2 = zeros(deltavmax,pdetmax);
for l=1:rep
    %[graph, label] = graphgen3([32 32 32 32],8,32);
    %slabel = slabelgen(label,0.10);
    [label, slabel] = trreadlabels(y,idxLabs,l);
    for i=1:deltavmax
        parfor j=1:pdetmax
            deltav = i * 0.05;
            pdet = 0.4 + j * 0.05 - 0.05;
            %[owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 4, 500000, pdet, deltav, 1.0, 2.0);
            [owner, pot, owndeg, distnode] = strwalk8k(X, slabel, 25, 2, 500000, pdet, deltav);
            [iter_acc,iter_kap] = stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            [iter_acc2,iter_kap2] = stmwevalk(label,slabel,owner2);
            disp(sprintf('Iteração: %3.0f DeltaV: %0.2f Pdet: %0.2f Acerto: %0.4f Kappa: %0.4f Acerto2: %0.4f Kappa2: %0.4f',l,deltav,pdet,iter_acc,iter_kap,iter_acc2,iter_kap2))
            tab_acc(i,j)  = tab_acc(i,j)  + iter_acc;
            tab_kap(i,j)  = tab_kap(i,j)  + iter_kap;
            tab_acc2(i,j) = tab_acc2(i,j) + iter_acc2;
            tab_kap2(i,j) = tab_kap2(i,j) + iter_kap2;            
        end        
    end
    save tab_deltavpdet tab_acc tab_kap tab_acc2 tab_kap2 l
end
tab_acc  = tab_acc  ./ rep;
tab_kap  = tab_kap  ./ rep;
tab_acc2 = tab_acc2 ./ rep;
tab_kap2 = tab_kap2 ./ rep;