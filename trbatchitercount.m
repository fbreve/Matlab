% Contagem de iterações com diferentes parâmetros de rede
rep = 200;
xs = 10;
tab_itr = zeros(xs,rep);
tab_tim = zeros(xs,rep);
tab_mean_itr = zeros(xs,1);
tab_std_itr = zeros(xs,1);
tab_min_itr = zeros(xs,1);
tab_max_itr = zeros(xs,1);
tab_mean_tim = zeros(xs,1);
tab_std_tim = zeros(xs,1);
tab_min_tim = zeros(xs,1);
tab_max_tim = zeros(xs,1);
for i=1:1:xs
    for l=1:rep
        %A = gendatb([sstep*i sstep*i],0.8);
        %X = A.data;
        %label = A.nlab;
        %slabel = slabelgen(label,0.05);
        %[graph, label] = graphgen3([128*i 128*i 128*i 128*i],32*i,64*i);
        [graph, label] = graphgen3([125*i 125*i 125*i 125*i],10,25);
        %slabel = slabelgen(label,0.05);        
        slabel = slabelgen(label,50/(i*500));
        [t_itr,t_tim] = strwalk8gc(graph, slabel, 4, 500000, 0.7, 0.35, 1.0, 2.0);
        tab_itr(i,l) = t_itr;
        tab_tim(i,l) = t_tim;
        disp(sprintf('Ponto: %u Iter: %u TotIter: %u  TotTime: %0.2f',i,l,t_itr,t_tim))
    end
    tab_mean_itr=mean(tab_itr,2);
    tab_std_itr=std(tab_itr,[],2);
    tab_min_itr=min(tab_itr,[],2);
    tab_max_itr=max(tab_itr,[],2);
    tab_mean_tim=mean(tab_tim,2);
    tab_std_tim=std(tab_tim,[],2);
    tab_min_tim=min(tab_tim,[],2);
    tab_max_tim=max(tab_tim,[],2);
    tab_res_itr = [tab_mean_itr tab_std_itr tab_min_itr tab_max_itr];
    tab_res_tim = [tab_mean_tim tab_std_tim tab_min_tim tab_max_tim];
    disp(sprintf('Ponto: %4.0f  Iter. Médio: %2.2f  Desv. Pad.: %2.2f  Mínimo: %2.0f  Máximo: %2.0f',i,tab_mean_itr(i),tab_std_itr(i),tab_min_itr(i),tab_max_itr(i)))
    disp(sprintf('Ponto: %4.0f  Tempo Médio: %2.2f  Desv. Pad.: %2.2f  Mínimo: %2.2f  Máximo: %2.2f',i,tab_mean_tim(i),tab_std_tim(i),tab_min_tim(i),tab_max_tim(i)))
    save tab_itercount tab_mean_itr tab_std_itr tab_min_itr tab_max_itr tab_mean_tim tab_std_tim tab_min_tim tab_max_tim tab_res_itr tab_res_tim;
end