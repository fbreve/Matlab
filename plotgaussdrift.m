[X, label] = gaussdrift(50000,100);
subplot(2,2,1);
scatterd(dataset(X(1:100,:),label(1:100)));
subplot(2,2,2);
scatterd(dataset(X(3001:3100,:),label(3001:3100)));
subplot(2,2,3);
scatterd(dataset(X(10001:10100,:),label(10001:10100)));
subplot(2,2,4);
scatterd(dataset(X(30001:30100,:),label(30001:30100)));