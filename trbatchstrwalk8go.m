rep = 50; % numero de repetições (bases geradas diferentes)
amount = 0.10; % quantidade de elementos pré-rotulados
onmax = 11;
if exist('tabs_strwalk8go.mat','file') 
    load tabs_strwalk8go;
else
    tabmutual = zeros(onmax,rep);
end

N = 5000;  % 1000 e 5000
k = 20;
maxk = 50;
mu = 0.3; % 0.1 e 0;3
t1 = 2;
t2 = 1;
minc = 10; % 10 e 20
maxc = 50; % 50 e 100
om = 2;
for i=onmax:1:onmax
    for j=48:1:rep
        on = round((0.05*i-0.05) * N);
        [graph,label] = benchmark(N,k,maxk,mu,t1,t2,minc,maxc,on,om);
        slabel = slabelgeno(label,amount);
        owner = strwalk8go(graph, slabel, 0.5, 0.1);
        tabmutual(i,j) = mutual(label,owner);
        save tabs_strwalk8go tabmutual;
        disp(sprintf('Rep.: %2.0f  on: %2.0f  Mutual: %0.4f',j,on,tabmutual(i,j)))
    end
    disp(sprintf('FINAL: on: %2.0f  Mutual: %0.4f',on,mean(tabmutual(i,:))))
end    