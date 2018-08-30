rep=1000;
qtlabel = max(label);
sizeX = size(X,1);
tab_owndeg = zeros(sizeX,qtlabel,rep);
tab_acc = zeros(rep,1);
%tab_owndeg = zeros(34,2,rep);
parfor l=1:rep
    %slabel = slabelgen(label,0.05);
    slabel = slabelgen(label,0.1);
    [~, ~, ownd, ~] = strwalk8ko(X, slabel, 5, 'seuclidean', 0.5, 0.1, 1.0, 2.0, qtlabel, 200000);
    %[~, ~, owndeg, ~] = strwalk8(X, slabel, 0.02, 'euclidean', 0.5, 0.1, 1.0, 2.0, qtlabel, 100000);
    %[owner, pot, owndeg, distnode] = strwalk8g(graph, slabel, 2, 200000, 0.5, 0.1, 1.0, 2);
    tab_owndeg(:,:,l) = ownd;
    [~,owner] = max(ownd,[],2);
    tab_acc(l) = tmweval(label,owner)
    disp(sprintf('Repetição: %3.0f/%3.0f  Acerto: %0.4f',l,rep,tab_acc(l)))
end
owndeg_mean = mean(tab_owndeg,3);
owndeg_std = std(tab_owndeg,[],3);
acc_mean = mean(tab_acc);
acc_std = std(tab_acc);
acc = acc_mean;
owndeg = owndeg_mean;
[~,owner] = max(owndeg,[],2);
save tabs tab_owndeg tab_acc owndeg owner acc owndeg_mean owndeg_std acc_mean acc_std;
disp(sprintf('Concluído - Acerto: %0.4f  Desvio Padrão: %0.4f',acc_mean,acc_std))
% overlapcolor
% scatter(X(:,1),X(:,2),10+color*90,color)