function y = fitstrwalk31(x,X,slabel,label,disttype)
    k = round(x(1));
    owner = strwalk31mex(X, slabel, k, disttype);
    y = 1-stmwevalk(label,slabel,owner);
end