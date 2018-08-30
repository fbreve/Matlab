% Territory Mark Walk Evaluation
% Verifica taxa de acerto da saída do algoritmo
% e reordena tabela de donos e tabela fuzzy de 
% acordo com tabela de equivalência gerada
% Usage: [accuracy, owner, owndeg] = tmwevaloverlap(label,owner,owndeg);
% label = real labels
% owner,owndeg = algorithm output
function [accuracy, owner, owndeg] = tmwevaloverlap(label,owner,owndeg)
    % Criando a matriz de confusão
    confmat = zeros(max(label));
    for i=1:size(owner,1)
        if owner(i)>0 
            confmat(label(i),owner(i)) = confmat(label(i),owner(i)) + 1;
        end
    end
    % Criando tabela de equivalência
    eqtab = zeros(max(label),1);
    for i=1:max(label)
        [y,l_vec]=max(confmat);
        [y,c]=max(y);
        l = l_vec(c);
        eqtab(l) = c;
        confmat(l,:) = -1;
        confmat(:,c) = -1;
    end
    % Computando precisão
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
    % ordenando owner e owndeg
    owner = eqtab(owner);
    owndeg = owndeg(:,eqtab);
end