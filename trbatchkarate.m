rep = 1000;
load 'network-datasets\karate.mat'
slabel = zeros(34,1);
slabel(1)=1;
slabel(34)=2;
tabowndeg = zeros(34,2,rep);
parfor i=1:rep
    display(sprintf('Iteração %i',i));
    [owner, pot, owndeg, distnode] = strwalk8go(graph, slabel, 0.5, 0.1);
    tabowndeg(:,:,i) = owndeg;
end
save socokarate.mat
%owndeg = mean(tabowndeg,3);
%overlapcolor;
%dotgen('karate.dot',graph,owndeg,1);