function y = fitstrwalk8kk(x,X,slabel,label,disttype)
    k = round(x);
    owner = strwalk8k(X, slabel, k, disttype, 0.5, 0.1, 1, 2);
    y = 1-stmwevalk(label,slabel,owner);
end