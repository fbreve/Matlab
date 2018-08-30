rep=100;
%tab_owndeg = zeros(size(X),max(label),rep);
tab_owndeg = zeros(34,2,rep);
parfor l=1:100
    %slabel = slabelgen(label,0.05);
    %[owner, pot, owndeg, distnode] = strwalk8(X, slabel, 4, 200000, 0.5, 0.1, 1.0, 1, 2);
    [owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 2, 200000, 0.5, 0.1, 1.0, 2);
    tab_owndeg(:,:,l) = owndeg;
    disp(sprintf('Repetição: %3.0f/%3.0f',l,rep))
end
mean_owndeg = mean(tab_owndeg,3);
owndeg=mean_owndeg;
disp('Concluído')
save tabs owndeg;
