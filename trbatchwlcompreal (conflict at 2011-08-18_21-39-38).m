rep = 20; % numero de repeti��es (conjuntos diferentes)
prep = 20; % repeti�oes dos algoritmos de part�culas (em cada conjunto)
amount = 0.10; % quantidade de elementos pr�-rotulados
qtalg = 6;
amwrlabmax = 21;
disttype = 'seuclidean';

% GPUstart
% spmd
%     GPUstart
% end

iter_acc = zeros(rep,qtalg);
% iter_kap = zeros(rep,qtalg);

tab_acc=zeros(amwrlabmax,qtalg);
tab_std_acc=zeros(amwrlabmax,qtalg);
tab_min_acc=zeros(amwrlabmax,qtalg);
tab_max_acc=zeros(amwrlabmax,qtalg);
% tab_kap=zeros(amwrlabmax,qtalg);
% tab_std_kap=zeros(amwrlabmax,qtalg);
% tab_min_kap=zeros(amwrlabmax,qtalg);
% tab_max_kap=zeros(amwrlabmax,qtalg);

for i=2:1:amwrlabmax
    amwrlab = i*0.05 - 0.05;
    for l=1:rep
                
        slabel = slabelgenwl(label,amount,amwrlab);
        
        %[label,slabel] = trreadlabelswl(y,idxLabs,l,amwrlab);

        disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - Consistency Method',amwrlab,l,rep))
        fitfunzhou = @(x)fitzhou(x,X,slabel,label,disttype);
        options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.05;0.1;0.2;0.35;0.5;0.75;1.0;2.0;3.5;5.0;7.5;10]);
        [gaout, fval] = ga(fitfunzhou,1,[],[],[],[],0,20,[],options);
        iter_acc(l,1) = fval;
        disp(sprintf('Consistency Method - %0.2f RE - Erro: %0.4f - Sigma: %0.4f',amwrlab,fval,gaout))
        
        disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - Label Propagation',amwrlab,l,rep))
        fitfunlabelprop = @(x)fitlabelprop(x,X,slabel,label,disttype);
        %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.5;1;2;3;4;5;6;7;8;9;10]);
        options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.05;0.1;0.2;0.35;0.5;0.75;1.0;2.0;3.5;5.0;7.5;10]);
        [gaout, fval] = ga(fitfunlabelprop,1,[],[],[],[],0,20,[],options);
        iter_acc(l,2) = fval;
        disp(sprintf('Label Propagation - %0.2f RE - Erro: %0.4f - Sigma: %0.4f',amwrlab,fval,gaout))

        disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - LNP',amwrlab,l,rep))
        fitfunlnp = @(x)fitlnp(x,X,slabel,label,disttype);
        options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',1,'Generations',3,'InitialPopulation',[1;2;3;4;5;6;7;8;9;10;20;30;40;50;60;70;80;90;100]);
        [gaout, fval] = ga(fitfunlnp,1,[],[],[],[],1,100,[],options);
        iter_acc(l,3) = fval;
        disp(sprintf('LNP - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,round(gaout)))
        
        disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - Particles',amwrlab,l,rep))       
        fitfunstrwalk = @(x)fitstrwalk8kk(x,X,slabel,label,disttype);
        options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
        [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);        
        %iter_acc(l,4) = fval;
        k = round(gaout);
%         pdet = gaout(2);
%         deltav = gaout(3);
        %disp(sprintf('Particles - %0.2f RE - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,fval,k, pdet, deltav))
        disp(sprintf('Particles - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,k))
        pdet=0.5; deltav=0.1;

        part = zeros(prep,1);
        part2 = zeros(prep,1);
        parfor j=1:prep
            [owner, pot, owndeg, distnode] = strwalk8k(X, slabel, k, disttype, pdet, deltav);
            part(j) = 1 - stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            part2(j) = 1 - stmwevalk(label,slabel,owner2);            
            disp(sprintf('Particles - %0.2f RE - Rep %3.0f/%3.0f - Erro: %0.4f - Erro2: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,j,prep,part(j),part2(j),k, pdet, deltav))
        end
        iter_acc(l,4) = mean(part);
        iter_acc(l,5) = mean(part2);
        disp(sprintf('Particles - %0.2f RE - Erro: %0.4f - Erro2: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,iter_acc(l,4),iter_acc(l,5),k, pdet, deltav))

%         disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - Particles 3',amwrlab,l,rep))       
%         fitfunstrwalk = @(x)fitstrwalk11(x,X,slabel,label,'euclidean');
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',5,'Generations',10,'InitialPopulation',[100, 0.1, 0.5]);
%         [gaout,fval] = ga(fitfunstrwalk,3,[],[],[],[],[1, 0.01, 0.05],[200, 0.99, 0.95],[],options);        
%         %iter_acc(l,4) = fval;
%         k = round(gaout(1));
%         pdet = gaout(2);
%         deltav = gaout(3);
%         disp(sprintf('Particles 3 - %0.2f RE - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,fval,k, pdet, deltav))
%        k=100; pdet=0.5; deltav=0.1;

        disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f r�tulos errados - Rep. %2.0f/%2.0f - Particles 3',amwrlab,l,rep))       
        fitfunstrwalk = @(x)fitstrwalk11(x,X,slabel,label,disttype);
        options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
        [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);     
        k = round(gaout);
        disp(sprintf('Particles 3 - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,k))
        pdet=0.5; deltav=0.1;

        part3 = zeros(prep,1);
        parfor j=1:prep
            [owner, pot, distnode] = strwalk11(X, slabel, k, disttype, pdet, deltav);
            part3(j) = 1 - stmwevalk(label,slabel,owner);
            disp(sprintf('Particles - %0.2f RE - Rep %3.0f/%3.0f - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,j,prep,part3(j),k, pdet, deltav))
        end
        iter_acc(l,6) = mean(part3);
        disp(sprintf('Particles 3 - %0.2f RE - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,iter_acc(l,6),k, pdet, deltav))        
        
%         owner = gpuzhou(X,slabel,7);
%         [iter_acc(l,1), iter_kap(l,1)] = stmwevalk(label,slabel,owner);
%         disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  CO: Err: %0.4f  Kap: %0.4f',amwrlab,l,rep,iter_acc(l,1),iter_kap(l,1)))
%         
%         owner = gpulabelprop(X,slabel,0.9);
%         [iter_acc(l,2), iter_kap(l,2)] = stmwevalk(label,slabel,owner);
%         disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  LP: Err: %0.4f  Kap: %0.4f',amwrlab,l,rep,iter_acc(l,2),iter_kap(l,2)))
% 
%         owner = gpulnp(X,slabel,29);
%         [iter_acc(l,3), iter_kap(l,3)] = stmwevalk(label,slabel,owner);
%         disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f LNP: Err: %0.4f  Kap: %0.4f',amwrlab,l,rep,iter_acc(l,3),iter_kap(l,3)))
%         
%         [owner, pot, owndeg, distnode] = strwalk8ke(X, slabel, 73, 0.29, 0.28);
%         [iter_acc(l,4), iter_kap(l,4)] = stmwevalk(label,slabel,owner);
%         disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  P1: Err: %0.4f  Kap: %0.4f',amwrlab,l,rep,iter_acc(l,4),iter_kap(l,4)))
% 
%         [nil,owner2] = max(owndeg,[],2);
%         [iter_acc(l,5), iter_kap(l,5)] = stmwevalk(label,slabel,owner2);
%         disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  P2: Err: %0.4f  Kap: %0.4f',amwrlab,l,rep,iter_acc(l,5),iter_kap(l,5)))

    disp(sprintf('COMP: Perc: %0.4f - Rep. %2.0f/%2.0f - Err: CO: %0.4f  LP: %0.4f  LNP: %0.4f  Part: %0.4f  Part2: %0.4f  Part3: %0.4f',amwrlab,l,rep,iter_acc(l,1),iter_acc(l,2),iter_acc(l,3),iter_acc(l,4),iter_acc(l,5),iter_acc(l,6)))
    
    end
    tab_acc(i,:)=mean(iter_acc);
    tab_std_acc(i,:)=std(iter_acc);
    tab_min_acc(i,:)=min(iter_acc);
    tab_max_acc(i,:)=max(iter_acc);
%     tab_kap(i,:)=mean(iter_kap);
%     tab_std_kap(i,:)=std(iter_kap);
%     tab_min_kap(i,:)=min(iter_kap);
%     tab_max_kap(i,:)=max(iter_kap);
%     save tabs tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;
%     disp(sprintf('FINAL: Perc: %0.4f  Err: CO: %0.4f  LP: %0.4f  LNP: %0.4f  P1: %0.4f  P2: %0.4f',amwrlab,tab_acc(i,1),tab_acc(i,2),tab_acc(i,3),tab_acc(i,4),tab_acc(i,5)))
%     disp(sprintf('FINAL: Perc: %0.4f  Kap: CO: %0.4f  LP: %0.4f  LNP: %0.4f  P1: %0.4f  P2: %0.4f',amwrlab,tab_kap(i,1),tab_kap(i,2),tab_kap(i,3),tab_kap(i,4),tab_kap(i,5)))
    save tabs_wlcompreal tab_acc tab_std_acc tab_min_acc tab_max_acc;
    disp(sprintf('FINAL: Perc: %0.4f  Err: CO: %0.4f  LP: %0.4f  LNP: %0.4f  Part: %0.4f  Part2: %0.4f  Part3: %0.4f',amwrlab,tab_acc(i,1),tab_acc(i,2),tab_acc(i,3),tab_acc(i,4),tab_acc(i,5),tab_acc(i,6)))
end

