% Changed mean distance computation to efficiency computation as
% suggested on:
%
% Zanin, Massimiliano. "On alternative formulations of the small-world 
% metric in complex networks." arXiv preprint arXiv:1505.03689 (2015).
%
% Fabricio Breve - 25/09/2018

function [S,C,E] = fb_small_world_ness2(A,ER,CR,FLAG)

% SMALL_WORLD_NESS computes small-world-ness of graph
% [S,C,L] = SMALL_WORLD_NESS(A,LR,CR,FLAG) computes small-world-ness score S of
% graph described by adjacency matrix A, given mean shortest path
% length LR and mean clustering coefficient CR averaged over a random graph ensemble
% of the same (n,m) or (n,<k>) as A [vertices, edges or mean degree].
%
% FLAG is a number indicating which small-world-ness value to compute:
%   1 - raw form with Cws 
%   2 - raw form with transitivity C (no. of triangles)
%
% Also returns a 2 element array O  [C L], which are the mean clustering coefficient C 
% and mean shortest path length L of A.
%
% Mark Humphries 3/02/2017

% [L,P] = path_length3(A);
%[~,D] = reachdist(A);  % returns Distance matrix of all pairwise distances % replaced (F.B.)
E = fb_efficiency(A);
% calculate required form of C
switch FLAG
    case 1
        c = clustering_coef_bu(A);  % vector of each node's C_ws
        C = mean(c);  % mean C
    case 2
        C = clusttriang(A);
end

% Ls = L / LR;
% Cs =  C / CR;
% S = Cs / Ls;

S = (C / CR) * (E / ER);
