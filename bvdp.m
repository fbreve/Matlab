function xdot = bvdp(t,x,a,d,W)
    epsilon = 0.02;
    x=reshape(x,size(x,1)/2,2);
    coupx = W * x(:,1) - sum(W,2).* x(:,1);
    xdot=[x(:,1)-x(:,1).^3/3-x(:,2) + d*coupx;
        epsilon.*(x(:,1)+a)];
end