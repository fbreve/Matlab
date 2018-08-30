load 'uci-datasets\karate.mat'
slabel = zeros(34,1);
slabel(1)=1;
slabel(34)=2;
owndegacc = zeros(34,2);
for i=1:1000
    display(sprintf('Iteração %i',i));
    [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 0.5, 0.1);
    owndegacc = owndegacc + owndeg;
end
owndeg = owndegacc ./ 1000;
save tkdekarate.mat
overlapcolor;
dotgen;