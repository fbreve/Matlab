function y = fitstrwalk13(x,X,slabel,label,disttype,wl)
    if (nargin < 6) || isempty(wl),
        wl = 0;
    end    
    k = round(x);
    owner = strwalk13(X, slabel, k, disttype);
    y = 1-stmwevalk(label,slabel,owner,wl);
end