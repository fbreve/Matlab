GPUstart
spmd
    GPUstart
end

subsetmax = 12;
kmax = 50;

iter_err = zeros(kmax,1);
tab_err = zeros(subsetmax,1);
tab_par = zeros(subsetmax,1);

for subset=1:1:subsetmax
    [label, slabel] = trreadlabels(y,idxLabs,subset);
  
    disp(sprintf('Rodando LNP para Subset %02.0f - Linear Neighbor Propagation',subset))
    for k = 1:kmax
        owner = gpulnp(X,slabel,k);    
        iter_err(k) = 1-stmwevalk(label,slabel,owner);
        disp(sprintf('Linear NP - Subset: %02.0f  K: %2.0f  Erro: %0.4f',subset,k,iter_err(k)))
    end
    [~,ind] = min(iter_err);
   
    tab_err(subset) = iter_err(ind);
    tab_par(subset) = ind;
    
    disp(sprintf('Linear NP - Subset: %02.0f  K: %2.0f  Erro: %0.4f',subset,tab_par(subset),tab_err(subset)))   
    
    save tab_comp tab_err tab_par;
end

