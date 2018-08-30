function y = fitstrwalk(x,X,slabel,label)
    k = round(x(1));
    pdet = x(2);
    deltav = x(3);
    owner = strwalk8k(X, slabel, k, pdet, deltav, 1, 2);
    y = 1-stmwevalk(label,slabel,owner);
end