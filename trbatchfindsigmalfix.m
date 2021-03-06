rep = 20; % numero de repetições
xs = 20;
iter_err = zeros(rep,xs);
iter_err2 = zeros(rep,xs);
x=1;
for l=1:rep
    parfor i=1:xs
        sigma = i*0.25;
            %owner = zhou(X,slabel,4,10000,0.99,sigma);
            %owner = labelprop(X,slabel,2,10000,sigma);
            [owner, pot, owndeg, distnode] = strwalk8(X, slabel, sigma);
            iter_err(x,i) = 1 - stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            iter_err2(x,i) = 1 - stmwevalk(label,slabel,owner2);           
            disp(sprintf('Sigma: %2.2f Erro: %0.4f  Erro2: %0.4f',sigma,iter_err(x,i),iter_err2(x,i)))
    end
    disp(sprintf('Conj.: %3.0f de %3.0f completo',x,rep))
    x = x + 1;        
end
tab_err=mean(iter_err);
tab_std_err=std(iter_err);
tab_min_err=min(iter_err);
tab_max_err=max(iter_err);
tab_err2=mean(iter_err2);
tab_std_err2=std(iter_err2);
tab_min_err2=min(iter_err2);
tab_max_err2=max(iter_err2);
save tabs_findsigma tab_err tab_std_err tab_min_err tab_max_err tab_err2 tab_std_err2 tab_min_err2 tab_max_err2;