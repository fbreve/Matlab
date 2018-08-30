function xdot = wc(t,x,A,k,W)
    x=reshape(x,size(x,1)/2,2);
    couplingx = W * x(:,1) - sum(W,2).* x(:,1);
    couplingy = W * x(:,2) - sum(W,2).* x(:,2);    
    xdot=[-x(:,1) + 1 ./ (1 + exp(-((x(:,1) -2.5 .* x(:,2) + A .* cos(t) - 0.2) ./ 0.025))) + k * couplingx;
        -0.01 .* x(:,2) + 1 ./ (1 + exp(-((0.6 .* x(:,1) - 0.15) ./ 0.025))) + k * couplingy];
end