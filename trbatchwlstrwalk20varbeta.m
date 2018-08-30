rep = 12; % numero de repetições (conjuntos diferentes)
prep = 20; % repetiçoes dos algoritmos de partículas (em cada conjunto)
amount = 0.1; % quantidade de elementos pré-rotulados
disttype = 'euclidean';
pdet=0.5; deltav=0.1;
valpha = 2000;
amwrlab = 0.35;
ibetamax = 11;

tab_acc=zeros(rep,ibetamax);
part4 = zeros(prep,1);
 
for i=1:rep
    %slabel = slabelgenwl(label,amount,amwrlab);
    [label,slabel] = trreadlabelswl(y,idxLabs,i,amwrlab);
    disp(sprintf('Rodando Algoritmo Genético - Rep. %2.0f/%2.0f - Particles (20)',i,rep))
    fitfunstrwalk = @(x)fitstrwalk20(x,X,slabel,label,disttype,valpha,1);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
    [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);     
    k = round(gaout);
    disp(sprintf('Particles (20) - Erro: %0.4f - K: %2.0f',fval,k))        
    for ibeta=1:ibetamax
        beta = 2^(ibeta-1);
        part4 = zeros(prep,1);
        parfor j=1:prep
            owner = strwalk20mexbeta(X, slabel, k, disttype, valpha, beta, pdet, deltav);
            part4(j) = 1 - stmwevalk(label,slabel,owner,1);
            % disp(sprintf('Particles (20) - Beta: %2.0f - Rep %3.0f/%3.0f - Erro: %0.4f - K: %2.0f',beta,j,prep,part4(j),k))
        end
        tab_acc(i,ibeta) = mean(part4);
        disp(sprintf('Particles (20) - Beta: %2.0f - Erro: %0.4f - Média Atual: %0.4f - K: %2.0f',beta,tab_acc(i,ibeta),mean(tab_acc(1:i,ibeta)),k))
    end    
    save tabs_wl20beta tab_acc;
end

