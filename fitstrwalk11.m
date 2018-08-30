function y = fitstrwalk11(x,X,slabel,label,disttype,valpha,wl)
    k = round(x);
    owner = strwalk11mex(X, slabel, k, disttype, valpha, 0.5, 0.1);
    y = 1-stmwevalk(label,slabel,owner,wl);
end