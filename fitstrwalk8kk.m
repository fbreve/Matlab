function y = fitstrwalk8kk(x,X,slabel,label,disttype,valpha,wl)
    if (nargin < 4) || isempty(wl),
        wl = 0;
    end    
    k = round(x);
    owner = strwalk8kmex(X, slabel, k, disttype, valpha, 0.5, 0.1, 1, 2);
    y = 1-stmwevalk(label,slabel,owner,wl);
end