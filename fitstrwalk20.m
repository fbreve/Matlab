function y = fitstrwalk20(x,X,slabel,label,disttype,valpha,wl)
    k = round(x);
    owner = strwalk20mex(X, slabel, k, disttype, valpha, 0.5, 0.1);
    y = 1-stmwevalk(label,slabel,owner,wl);
end