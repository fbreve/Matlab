kmin = 1;
kmax = 300;
disttype = 'euclidean';

if exist('tab_k','var')==0 
    tab_k = zeros(12,1);
end
if exist('tab_err','var')==0 
    tab_err = zeros(12,1);
end
if exist('i_start','var')==0
    i_start = 1;
end

iterk_err = zeros(100,1);

for i=i_start:1:12
    fprintf('Processando subconjunto %i/12... ',i);
    [label,slabel] = trreadlabels(y,idxLabs,i);
    parfor k=kmin:kmax
        [owner, pot] = cnssl(X, slabel, k, disttype);
        iterk_err(k) = 1-stmwevalk(label,slabel,owner);
    end
    [err,k] = min(iterk_err);
    fprintf('Erro: %0.4f  K: %i\n',err,k);
    
    tab_k(i) = k;
    tab_err(i) = err;
    
    save(sprintf('tabs_cnssl-%s',getenv('computername')),'tab_k','tab_err');
end
fprintf('Concluído. Erro Médio: %0.4f\n',mean(tab_err));