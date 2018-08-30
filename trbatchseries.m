rep = 100;
iter = 20000;
ts_acc = zeros(rep,5,iter);
ts_pot = zeros(rep,5,iter);
ts_prt = zeros(rep,5,iter);
mts_acc = zeros(5,iter);
mts_pot = zeros(5,iter);
mts_prt = zeros(5,iter);
j=1;
for i=1:rep
    %A = gendatb([500 500],1);
    %X = A.data;
    %label = A.nlab;
    [graph, label] = graphgen3([512 512 512 512],16,64);
    slabel = slabelgen(label,0.03125);
    parfor j=1:5
        pdet = (j-1)*0.25;
        [owner, pot, owndeg, distnode, s_itr, s_acc, s_pot, s_prt] = strwalk8series(graph, label, slabel, 4, iter, pdet, 0.35, 1.0, 2.0);
        ts_acc(i,j,:) = s_acc;
        ts_pot(i,j,:) = s_pot;
        ts_prt(i,j,:) = s_prt;
    end
    disp(sprintf('Repeti��o: %3.0f/%3.0f',i,rep))
    mts_acc(:,:) = mean(ts_acc);
    mts_pot(:,:) = mean(ts_pot);
    mts_prt(:,:) = mean(ts_prt);
    s_itr = 1:iter;
    save tab_series s_itr mts_acc mts_pot mts_prt
    save temp_series ts_acc ts_pot ts_prt
end
