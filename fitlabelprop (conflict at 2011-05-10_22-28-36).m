function y = fitlabelprop(sigma,X,slabel,label,disttype)
    owner = labelprop(X,slabel,sigma,disttype);
    y = 1-stmwevalk(label,slabel,owner);
end