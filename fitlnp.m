function y = fitlnp(k,X,slabel,label,disttype,wl)
    k = round(k);
    if gpuDeviceCount>0
        owner = gpulnp(X,slabel,k,disttype);
    else
        owner = lnp(X,slabel,k,disttype);
    end
    y = 1-stmwevalk(label,slabel,owner,wl);
end