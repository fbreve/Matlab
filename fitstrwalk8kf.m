function y = fitstrwalk8kf(x,X,slabel,label,disttype)
    k = round(x(1));
    pdet = x(2);
    deltav = x(3);
    owner = strwalk8kf(X, slabel, k, disttype, pdet, deltav, 1, 2);
    y = 1-stmwevalk(label,slabel,owner);
end