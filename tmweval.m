% Territory Mark Walk Evaluation
% Usage: accuracy = tmweval(label,owner);
% label = real labels
% owner = tmwalk output
function accuracy = tmweval(label,owner)
    % Criando a matriz de confus�o    
    confmat = zeros(max(label));
    for i=1:size(owner,1)
        if owner(i)>0 
            confmat(label(i),owner(i)) = confmat(label(i),owner(i)) + 1;
        end
    end
    % Criando tabela de equival�ncia
    eqtab = zeros(max(label),1);
    for i=1:max(label)
        [y,l_vec]=max(confmat);
        [y,c]=max(y);
        l = l_vec(c);
        eqtab(l) = c;
        confmat(l,:) = -1;
        confmat(:,c) = -1;
    end
    % Computando precis�o
    correct = 0;
    wrong = 0;
    for i=1:size(owner,1)
        if owner(i)==eqtab(label(i)) 
            correct = correct + 1;
        else
            wrong = wrong + 1;
        end    
        accuracy = correct / (correct+wrong);
    end   
end