load 'network-datasets\dolphins.mat'
slabel = zeros(62,1);
slabel(31)=1;
slabel(39)=2;
slabel(46)=2;
slabel(38)=2;
slabel(11)=2;
slabel(55)=3;
slabel(57)=3;
owndegacc = zeros(62,3);
for i=1:1000
    display(sprintf('Iteração %i',i));
    [owner, pot, owndeg, distnode] = strwalk8g(dolphins, slabel, 0.5, 0.1, 1.0, 0.0);
    owndegacc = owndegacc + owndeg;
end
owndeg = owndegacc ./ 1000;
save dmkd-dolphins.mat
overlapcolor;
dotgendolphins;