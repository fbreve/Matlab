rep = 200; % numero de repetições
tab_acc = zeros(11,1);
for l=1:rep
    [graph, label] = graphgen2([32 32 32 32],8,16);    
    parfor i=0:10
        [owner, pot] = ftrwalk5(graph, 4, 50000, i*0.1, 0.4, 0.9);
        tab_acc(i+1,l) = tmweval(label,owner);
    end
    disp(sprintf('Repetição: %3.0f',l))
    save tab_acc tab_acc;
end