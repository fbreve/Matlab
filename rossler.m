function xdot = rossler(t,x,omega,k,W)
    a=.15; b=.2; c = 10;
    x=reshape(x,size(x,1)/3,3);
    %xdot=[-x(2)-x(3);
    %x(1)+a*x(2);
    %b+x(3)*(x(1)-c)];
    couplingx = W * x(:,1) - sum(W,2).* x(:,1);
    xdot=[-omega .* x(:,2)-x(:,3) + k * couplingx;
        omega .* x(:,1)+a.*x(:,2); 
        b+x(:,3).*(x(:,1)-c)];
end