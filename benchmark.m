% Interface para o gerador de redes para benchmark de
% PHYSICAL REVIEW E 78, 046110.
% Uso: [graph,label] = benchmark(N,k,maxk,mu,t1,t2,minc,maxc,mu,on,om)
% -N		number of nodes
% -k		average degree
% -maxk		maximum degree
% -mu		mixing parameter
% -t1		minus exponent for the degree sequence
% -t2		minus exponent for the community size distribution
% -minc		minimum for the community sizes
% -maxc		maximum for the community sizes
% -on		number of overlapping nodes
% -om		number of memberships of the overlapping nodes
function [graph,label] = benchmark(N,k,maxk,mu,t1,t2,minc,maxc,on,om)
if (nargin < 10) || isempty(om),
    om = 2;
end
if (nargin < 9) || isempty(on),
    on = 0;
end
if (nargin < 8) || isempty(maxc),
    maxc = 50;
end
if (nargin < 7) || isempty(minc),
    minc = 10;
end
if (nargin < 6) || isempty(t2),
    t2 = 1;
end
if (nargin < 5) || isempty(t1),
    t1 = 2;
end
if (nargin < 4) || isempty(mu),
    mu = 0.1;
end
if (nargin < 3) || isempty(maxk),
    maxk = 50;
end
if (nargin < 2) || isempty(k),
    k = 20;
end
if (nargin < 1) || isempty(N),
    N = 1000;
end

removefiles;
[~,~] = dos(sprintf('..\\binary_networks\\benchmark -N %u -k %u -maxk %u -mu %0.16f -t1 %u -t2 %u -minc %u -maxc %u -on %u -om %u',N,k,maxk,mu,t1,t2,minc,maxc,on,om));

% montar o grafo
graph = zeros(N);
neighborlist = importdata('network.dat');
for i=1:size(neighborlist,1);
    graph(neighborlist(i,1),neighborlist(i,2))=1;
end
clear neighborlist;

% ler rótulos
fid = fopen('community.dat');
community = textscan(fid,'%u\t%u %u ',N);
label = zeros(N,om);
for i=1:om
    label(:,i) = community{i+1};
end
clear community;
fclose(fid);

removefiles;

end

function removefiles
if exist('network.dat', 'file')
    delete('network.dat');
end
if exist('community.dat', 'file')
    delete('community.dat');
end
if exist('statistics.dat', 'file')
    delete('statistics.dat');
end
end