function y = fitlabelprop(sigma,X,slabel,label,disttype,wl)
    if gpuDeviceCount>0    
        owner = gpulabelprop(X,slabel,sigma,disttype);
    else
        owner = labelprop(X,slabel,sigma,disttype);
    end
    y = 1-stmwevalk(label,slabel,owner,wl);
end