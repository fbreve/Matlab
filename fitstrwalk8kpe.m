function y = fitstrwalk8kpe(x,X,slabel,label,disttype)
    k = round(x(1));
    pdet = x(2);
    dexp = x(3);
    owner = strwalk8k(X, slabel, k, disttype, pdet, 0.1, 1, dexp);
    y = 1-stmwevalk(label,slabel,owner);
end