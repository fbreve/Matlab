function y = fitstrwalk8ke2(x,X,slabel,label)
    k = round(x(1));
    pdet = x(2);
    deltav = x(3);
    [~, ~, owndeg, ~] = strwalk8ke(X, slabel, k, pdet, deltav, 1, 2);
    [~,owner] = max(owndeg,[],2);
    y = 1-stmwevalk(label,slabel,owner);
end