function y = fitzhou(sigma,X,slabel,label,disttype)
    owner = zhou(X,slabel,sigma,disttype);
    y = 1-stmwevalk(label,slabel,owner);
end