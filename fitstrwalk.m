function y = fitstrwalk(x,X,slabel,label)
    k = round(x(1));
    pdet = x(2);
    deltav = x(3);
    [~, ~, owndeg, ~] = strwalk8k(X, slabel, k, pdet, deltav);
    [~,owner2] = max(owndeg,[],2);
    y = 1-stmwevalk(label,slabel,owner2);
end