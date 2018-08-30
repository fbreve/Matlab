qtnode = size(graph,1);
omega = unifrnd(0.8,1.2,qtnode,1);
%omega = ones(qtnode,1);
x0 = unifrnd(0,10,qtnode*3,1);
k = 0.02;
options = odeset('RelTol',1e-3,'AbsTol',1e-6);
[t,x] = ode45(@rossler,[0:0.1:600],x0,options,omega,k,graph);
phase = atan2(x(:,qtnode+1:qtnode*2),x(:,1:qtnode));
phase_u = (phase(2:end,:) - phase(1:end-1,:)) < -pi;
phase_l = (phase(2:end,:) - phase(1:end-1,:)) > pi;
cycle = cumsum(phase_u-phase_l);
phase(2:end,:) = cycle*2*pi + phase(2:end,:);
clear cycle phase_u phase_l;

% for j=1:size(phase,2)
%     cycle_c = 0;
%     for i=2:size(phase,1)
%         if phase(i,j)-phase(i-1,j)<-6
%             cycle_c = cycle_c + 1;
%         elseif phase(i,j)-phase(i-1,j)>6
%             cycle_c = cycle_c - 1;
%         end
%         cycle(i,j) = cycle_c;
%     end
% end
% phase = phase + cycle*2*pi;
% clear cycle_c cycle;