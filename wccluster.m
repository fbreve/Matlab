qtnode = size(graph,1);
%A = unifrnd(1.1,1.2,qtnode,1);
A = repmat(1.2,qtnode,1);
x0 = unifrnd(0.01,0.1,qtnode*2,1);
k = 0.03;
options = odeset('RelTol',1e-3,'AbsTol',1e-6);
[t,x] = ode45(@wc,0:0.1:1200,x0,options,A,k,graph);

%phase = atan2(x(:,qtnode+1:qtnode*2),x(:,1:qtnode));
%phase_u = (phase(2:end,:) - phase(1:end-1,:)) < -pi;
%phase_l = (phase(2:end,:) - phase(1:end-1,:)) > pi;
%cycle = cumsum(phase_u-phase_l);
%phase(2:end,:) = cycle*2*pi + phase(2:end,:);
%clear cycle phase_u phase_l;