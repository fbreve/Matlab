% Changed random graph generation from 'undirect' to 'directed' (F.B.)
% Changed mean distance computation to efficiency computation (F.B.) as
% suggested on:
%
% Zanin, Massimiliano. "On alternative formulations of the small-world 
% metric in complex networks." arXiv preprint arXiv:1505.03689 (2015).
function [Erand,Crand] = fb_NullModel_L_C(n,m,Nrepeats,FLAG)

% NULLMODEL_L_C Monte Carlo estimates of path-length and clustering of an ER random graph
% [C,L] = NULLMODEL_L_C(N,M,R,FLAG) for N nodes and M edges,
% creates R realisations of an Erdos-Renyi random graph (N,M), and
% computes the shortest path-length L and clustering coefficient C 
% for each one
%
% FLAG is a number indicating which clustering coefficient to compute:
%   1 - Cws 
%   2 - transitivity C (no. of triangles)

% Mark Humphries 3/2/2017

Erand = zeros(1,Nrepeats);
Crand = zeros(1,Nrepeats);

for iE = 1:Nrepeats
    %fprintf('Building NullModel %2.0f of %2.0f: ',iE,Nrepeats)
    %ER = random_graph(n,0,m,'undirected');  % make E-R random graph
    ER = random_graph(n,0,m,'directed');  % make E-R random graph
    %[~,D] = reachdist(ER);  % returns Distance matrix of all pairwise distances
    %Lrand(iE) = mean(D(:));    
    Erand(iE) = fb_efficiency(ER);
    %fprintf('Efficiency: %0.4f ',Erand(iE))
    
%     if isinf(Lrand(iE))
%         keyboard
%     end
    
%     calculate required form of C
    switch FLAG
        case 1
            c = clustering_coef_bu(ER);  % vector of each node's C_ws
            Crand(iE) = mean(c);  % mean C
        case 2
            Crand(iE) = clusttriang(ER);
    end    
    %fprintf('Clustering Coefficient: %0.4f\n',Crand(iE))
    fprintf('.');
end
fprintf('\n');
end