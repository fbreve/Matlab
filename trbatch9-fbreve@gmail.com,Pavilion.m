tab_acc = zeros(20,1);
tab_std_acc = zeros(20,1);
iter_acc = zeros(20,1);
ind_x=1;
%for i=0.00:0.05:1.00
for i=0.00:0.05:1.00
    parfor l=1:20
        %A=gendatb([250 250],i);
        %X = A.data;
        %label = A.nlab;
        %graph = mat2graph(X);
        %[owner,pot] = strwalk(X,slabel,3,100000,100,0.6,0.1,1,5);
        [owner, pot, distnode] = strwalk6(X, slabel, 2, 20000, i, 0.1, 1, 2);
        iter_acc(l) = stmweval(label,slabel,owner);
        %disp(sprintf('Ml: %0.4f  Pdet: %0.4f  Iteração: %2.0f  Acerto: %0.4f',i,j,l,iter_acc(l)))
    end
    tab_acc(ind_x)=mean(iter_acc);
    tab_std_acc(ind_x)=std(iter_acc);
    disp(sprintf('Pdet: %0.4f  Acerto Médio: %0.4f  Desv. Pad.: %0.4f',i,tab_acc(ind_x),tab_std_acc(ind_x)))
    save tab_acc tab_acc;
    save tab_std_acc tab_std_acc;
    ind_x = ind_x + 1;
end