qtnode = size(graph,1);
%a = unifrnd(0.79,0.99,qtnode,1);
%a = [0.99; 0.99];
%[coeff, score] = princomp(zscore(graph));
%a = 0.59 + 0.4 * mat2gray(score(:,1));
a = repmat(0.95,qtnode,1);
x0 = unifrnd(0,1,qtnode*2,1);
d = 0.1;
options = odeset('RelTol',1e-3,'AbsTol',1e-6);
[t,x] = ode45(@bvdp,[0:1:6000],x0,options,a,d,graph);
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