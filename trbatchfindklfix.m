rep = 20; % numero de repetições
kmax = 30;
iter_err = zeros(rep,kmax);
iter_err2 = zeros(rep,kmax);
tab_err = zeros(12,kmax);
tab_std_err = zeros(12,kmax);
tab_min_err = zeros(12,kmax);
tab_max_err = zeros(12,kmax);
tab_err2 = zeros(12,kmax);
tab_std_err2 = zeros(12,kmax);
tab_min_err2 = zeros(12,kmax);
tab_max_err2 = zeros(12,kmax);
x=1;
for j=1:12
    [label, slabel] = trreadlabels(y,idxLabs,j);
    for l=1:rep
        parfor k=1:kmax
            %owner = zhou(X,slabel,4,10000,0.99,sigma);
            %owner = labelprop(X,slabel,2,10000,sigma);
            [owner, pot, owndeg, distnode] = strwalk8k(X, slabel, k);
            iter_err(x,k) = 1 - stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            iter_err2(x,k) = 1 - stmwevalk(label,slabel,owner2);
            disp(sprintf('K: %02.0f Erro: %0.4f  Erro2: %0.4f',k,iter_err(x,k),iter_err2(x,k)))
        end
        disp(sprintf('Set: %02.0f Conj.: %3.0f de %3.0f - Total: %3.0f de %3.0f',j,l,rep,x,j*rep))
        x = x + 1;
    end
    tab_err(j,:)=mean(iter_err);
    tab_std_err(j,:)=std(iter_err);
    tab_min_err(j,:)=min(iter_err);
    tab_max_err(j,:)=max(iter_err);
    tab_err2(j,:)=mean(iter_err2);
    tab_std_err2(j,:)=std(iter_err2);
    tab_min_err2(j,:)=min(iter_err2);
    tab_max_err2(j,:)=max(iter_err2);
    save tabs_findsigma tab_err tab_std_err tab_min_err tab_max_err tab_err2 tab_std_err2 tab_min_err2 tab_max_err2;
end
