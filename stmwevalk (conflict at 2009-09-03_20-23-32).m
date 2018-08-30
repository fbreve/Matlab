% Semi-Supervised Territory Mark Walk Evaluation
% including Kappa coefficient
% Usage: [acc,kap] = stmwevalk(label,slabel,owner);
% label = real labels
% slabel = pre-labeled labels (0 = no label)
% owner = strwalk output
function [acc,k] = stmwevalk(label,slabel,owner)
    acc = sum(label==owner & slabel==0)/sum(slabel==0);
    % calculando matriz de confusão
    c = zeros(max(label));
    for i=1:size(label,1)
        if slabel(i)==0
            c(label(i),owner(i)) = c(label(i),owner(i)) + 1;
        end
    end
    k = kappa(c);
end