t = zeros(10,2);
for i=1:10
    [owner,t(i,1),it] = zhoutime(X,label,slabel,2,100000,0.99,10);
    [owner,pot,t(i,2),it] = strwalktime(X,label,slabel,2,100000,100,0.6,0.1,1,7);
end