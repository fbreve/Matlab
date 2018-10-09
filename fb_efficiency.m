% Computes efficiency of adjacency matrix A
% Use: E = fb_efficiency(A)
% Fabricio Breve - 25/09/2018
%
% Efficiency definition from:
% Zanin, Massimiliano. "On alternative formulations of the small-world 
% metric in complex networks." arXiv preprint arXiv:1505.03689 (2015).

function E = fb_efficiency(A)
n = size(A,1);
G = digraph(A);  % this is for digraphs, for graphs use G = graph(A);
D = distances(G,'Method','unweighted');
invD = 1./D;
invD(invD==Inf)=0;
suminvD = sum(invD(:));
E = (1/(n*(n-1)))*suminvD;
end