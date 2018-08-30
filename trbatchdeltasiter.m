% número de iterações com relação a deltas
rep = 100;
deltapmax = 20;
deltavmax = 20;
tab_totiter = zeros(deltapmax,deltavmax,'uint32');
for l=1:rep
    [graph, label] = graphgen3([32 32 32 32],4,16);
    slabel = slabelgen(label,0.10);
    for i=1:deltapmax
        parfor j=1:deltavmax
            deltap = i * 0.05;
            deltav = j * 0.05;
            totiter = strwalk8gc(graph, slabel, 4, 500000, 0.70, deltap, deltav, 2);
            disp(sprintf('Iteração: %u DeltaP: %0.2f DeltaV: %0.2f TotIter: %u',l,deltap,deltav,totiter))
            tab_totiter(i,j) = tab_totiter(i,j) + totiter;
        end        
    end
    save tab_totiter tab_totiter
end
tab_totiter  = tab_totiter ./ rep;
