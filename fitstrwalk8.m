function y = fitstrwalk8(x,X,slabel,label)
    sigma = x(1);
    pdet = x(2);
    deltav = x(3);
    owner = strwalk8(X, slabel, sigma, 2, 500000, pdet, deltav, 1, 2);
    y = 1-stmwevalk(label,slabel,owner);
end