% Semi-Supervised Territory Mark Walk Evaluation
% Usage: accuracy] = stmweval(label,slabel,owner);
% label = real labels
% slabel = pre-labeled labels (0 = no label)
% owner = strwalk output
function accuracy = stmweval(label,slabel,owner)
    accuracy = sum(label==owner & slabel==0)/sum(slabel==0);
end