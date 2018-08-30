rep = 20; % numero de repetições
amount = 0.1;

tab_acc=zeros(rep,1);

parfor l=1:rep
    disp(sprintf('Rodando Algoritmo de Partículas - Rep. %2.0f/%2.0f',l,rep))
    slabel = slabelgen(label,0.01);
    tic; owner = strwalk8gn(N,slabel,0.5,0.1); toc;
    [acc,kap] = stmwevalk(label,slabel,owner);
    tab_acc(l) = acc;
    disp(sprintf('Acerto: %0.4f',acc))
end
save tabs tab_acc;   
