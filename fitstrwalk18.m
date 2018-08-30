function y = fitstrwalk18(x,X,slabel,label,disttype,wl)
    k = round(x);
    owner = strwalk18(X, slabel, k, disttype, 0.5, 0.1);
    y = 1-stmwevalk(label,slabel,owner,wl);
end