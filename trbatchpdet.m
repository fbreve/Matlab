rep = 100; % numero de repeti��es
xs = 11;
iter_acc = zeros(rep,xs);
iter_kap = zeros(rep,xs);
for l=1:rep
    %A = gendatb([1000 1000],0.8);
    %X = A.data;
    %label = A.nlab;
    %slabel = slabelgen(label,0.01);
    [graph, label] = graphgen3([32 32 32 32],8,16);
    parfor i=1:11
        pdet = (i-1)*0.1;
        %[owner, pot, owndeg, distnode] = strwalk8(X, slabel, 2, 10000, pdet, 0.1, 1.0, 0.2, 2);
        [owner, owner2, pot, owndeg] = ftrwalk6g(graph, 4, 200000, pdet, 0.4, 0.9);
        %[iter_acc(l,i),iter_kap(l,i)] = stmwevalk(label,slabel,owner2);
        iter_acc(l,i) = tmweval(label,owner2);        
    end
    disp(sprintf('Repeti��o %3.0f/%3.0f',l,rep))
    tab_acc=mean(iter_acc);
    tab_std_acc=std(iter_acc);
    tab_min_acc=min(iter_acc);
    tab_max_acc=max(iter_acc);
    tab_kap=mean(iter_kap);
    tab_std_kap=std(iter_kap);
    tab_min_kap=min(iter_kap);
    tab_max_kap=max(iter_kap);
    save tabs_pdet iter_acc iter_kap tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;
end