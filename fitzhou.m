function y = fitzhou(sigma,X,slabel,label,disttype,wl)
    if gpuDeviceCount>0
        owner = gpuzhou(X,slabel,sigma,disttype);
    else
        owner = zhou(X,slabel,sigma,disttype);
    end
    y = 1-stmwevalk(label,slabel,owner,wl);
end