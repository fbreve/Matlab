% New Clustering Algorithm
% Sementes com potencial máximo, potencial vai se alastrando para vizinhança.
% Usage: [owner,pot] = newclust(graph, nclust, iter, delta)
function [owner,pot] = newclust(graph, nclust, iter, delta)
    % tabela de potenciais de nós
    pot = ones(size(graph,1),nclust)/nclust;
    % enchendo sementes
    pot(16,:) =  [1 0 0 0];
    pot(48,:) =  [0 1 0 0];
    pot(80,:) =  [0 0 1 0];
    pot(112,:) = [0 0 0 1];   
    % para cada iteração
    for i=1:iter             
        % novo potencial = potencial atual + diferença potencial vizinha *
        % delta
        pot = pot + ((graph * pot) ./ (sum(graph,2) * ones(1,4)) - pot) * delta;
        % achando o menor potencial dentre todas as sementes
        deltaseed = min([pot(16,:) pot(48,:) pot(80,:) pot(112,:)]);
        % diminuindo todos os potenciais pelo delta
        pot(16,:) =  pot(16,:)  - deltaseed;
        pot(48,:) =  pot(48,:)  - deltaseed;
        pot(80,:) =  pot(80,:)  - deltaseed;
        pot(112,:) = pot(112,:) - deltaseed;
        % aumentando potencial da semente
        pot(16,1) =  pot(16,1)  + deltaseed*nclust;
        pot(48,2) =  pot(48,2)  + deltaseed*nclust;
        pot(80,3) =  pot(80,3)  + deltaseed*nclust;
        pot(112,4) = pot(112,4) + deltaseed*nclust;
    end
    [nil,owner] = max(pot,[],2);
end