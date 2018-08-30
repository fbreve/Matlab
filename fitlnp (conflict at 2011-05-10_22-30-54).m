function y = fitlnp(k,X,slabel,label,disttype)
    k = round(k);
    owner = lnp(X,slabel,k,disttype);
    y = 1-stmwevalk(label,slabel,owner);
end