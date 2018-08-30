load 'network-datasets\polbooks.mat'
slabel = zeros(105,1);
slabel(1)=1;
slabel(2)=2;
slabel(31)=3;
owndegacc = zeros(105,3);
for i=1:1000
    display(sprintf('Iteração %i',i));
    [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 0.5, 0.1);
    owndegacc = owndegacc + owndeg;
end
owndeg = owndegacc ./ 1000;
save dmkd-polbooks.mat
overlapcolor;
dotgen;