rep = 1000; % quantidade de repetições
qtnode = size(X,1);
qtclass = max(label);
disttype = 'seuclidean';

% Variáveis para saída fuzzy acumulada
cst_owndegacc = zeros(qtnode,qtclass); % Consistencia
lbp_owndegacc = zeros(qtnode,qtclass); % Label Propagation
%lnp_owndegacc = zeros(qtnode,qtclass); % Linear Neighborhood Propagation
prt_owndegacc = zeros(qtnode,qtclass); % Particles

% Parâmetros dos algoritmos
cst_sigma = 2; % Consistencia
lbp_sigma = 3; % Label Propagation
%lnp_k = 4;     % Linear Neighborhood Propagation
prt_k = 5;     % Particles

% Gerando grafos
cst_W = graphgensig(X,cst_sigma,disttype,1); % Consistencia
lbp_W = graphgensig(X,lbp_sigma,disttype,0); % Label Propagation
%lnp_W = graphgenlnp(X,lnp_k);     % Linear Neighborhood Propagation
prt_W = graphgenknn(X,prt_k,disttype);     % Particles
  
for i=1:rep
    display(sprintf('Iteração %i',i));
    slabel = slabelgen(label,0.1);
    [~,ownfuz] = zhoug(cst_W,slabel);
    cst_owndegacc = cst_owndegacc + ownfuz;
    [~,ownfuz] = labelpropg(lbp_W,slabel);
    lbp_owndegacc = lbp_owndegacc + ownfuz;
    %[~,ownfuz] = lnpg(lnp_W,slabel);
    %lnp_owndegacc = lnp_owndegacc + ownfuz;
    [~,~,ownfuz] = strwalk8g(prt_W,slabel,0.5,0.1);
    prt_owndegacc = prt_owndegacc + ownfuz;
end

cst_owndeg = cst_owndegacc ./ rep;
lbp_owndeg = lbp_owndegacc ./ rep;
%lnp_owndeg = lnp_owndegacc ./ rep;
prt_owndeg = prt_owndegacc ./ rep;

save owndeg cst_owndeg lbp_owndeg lnp_owndeg prt_owndeg
dotgen('walk-fuzz.dot',prt_W,prt_owndeg,1);
[~,owner] = max(prt_owndeg,[],2);
dotgen('walk-hard.dot',prt_W,owner,0);

%owndeg = owndegacc ./ 1000;

%overlapcolor;
%dotgen;