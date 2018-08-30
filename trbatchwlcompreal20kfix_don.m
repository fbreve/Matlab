rep = 5; % numero de repetições (conjuntos diferentes)
prep = 20; % repetiçoes dos algoritmos de partículas (em cada conjunto)
amount =  0.10; %(40/178); % quantidade de elementos pré-rotulados
qtalg = 7;
amwrlabmax = 21;
disttype = 'seuclidean';
pdet=0.5; deltav=0.1;
valpha = 2000;
k = 10;

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

for i=1:1:amwrlabmax
    amwrlab = i*0.05 - 0.05;
    for l=1:rep
                
        slabel = slabelgenwl(label,amount,amwrlab);
        
        %[label,slabel] = trreadlabelswl(y,idxLabs,l,amwrlab);

%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - Consistency Method',amwrlab,l,rep))
%         fitfunzhou = @(x)fitzhou(x,X,slabel,label,disttype,1);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.05;0.1;0.2;0.35;0.5;0.75;1.0;2.0;3.5;5.0;7.5;10]);
%         [gaout, fval] = ga(fitfunzhou,1,[],[],[],[],0,20,[],options);
        owner = zhou(X,slabel,0.25);
        iter_acc(l,1) = 1 - stmwevalk(label,slabel,owner,1);
        disp(sprintf('Consistency Method - %0.2f RE - Erro: %0.4f',amwrlab,iter_acc(l,1)))
%         
%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - Label Propagation',amwrlab,l,rep))
%         fitfunlabelprop = @(x)fitlabelprop(x,X,slabel,label,disttype,1);
%         %options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.5;1;2;3;4;5;6;7;8;9;10]);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[0.05;0.1;0.2;0.35;0.5;0.75;1.0;2.0;3.5;5.0;7.5;10]);
%         [gaout, fval] = ga(fitfunlabelprop,1,[],[],[],[],0,20,[],options);
        owner = labelprop(X,slabel,0.25);
        iter_acc(l,2) = 1 - stmwevalk(label,slabel,owner,1);
        disp(sprintf('Label Propagation - %0.2f RE - Erro: %0.4f',amwrlab,iter_acc(l,2)))
% 
%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - LNP',amwrlab,l,rep))
%         fitfunlnp = @(x)fitlnp(x,X,slabel,label,disttype,1);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',1,'Generations',3,'InitialPopulation',[1;2;3;4;5;6;7;8;9;10;20;30;40;50;60;70;80;90;100]);
%         [gaout, fval] = ga(fitfunlnp,1,[],[],[],[],1,100,[],options);
        owner = lnp(X,slabel,5);
        iter_acc(l,3) = 1 - stmwevalk(label,slabel,owner,1);
        disp(sprintf('LNP - %0.2f RE - Erro: %0.4f',amwrlab,iter_acc(l,3)))
        
%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - Particles (8k)',amwrlab,l,rep))       
%         fitfunstrwalk = @(x)fitstrwalk8kk(x,X,slabel,label,disttype,valpha,1);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
%         [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);        
%         k = round(gaout);
%         disp(sprintf('Particles (8k) - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,k))      
        part = zeros(prep,1);
        part2 = zeros(prep,1);
        parfor j=1:prep
            [owner, pot, owndeg] = strwalk8kmex(X, slabel, k, disttype, valpha, pdet, deltav);
            part(j) = 1 - stmwevalk(label,slabel,owner,1);
            [~,owner2] = max(owndeg,[],2);
            part2(j) = 1 - stmwevalk(label,slabel,owner2,1);
            disp(sprintf('Particles (8k) - %0.2f RE - Rep %3.0f/%3.0f - Erro: %0.4f - Erro2: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,j,prep,part(j),part2(j),k, pdet, deltav))
        end
        iter_acc(l,4) = mean(part);
        iter_acc(l,5) = mean(part2);
        disp(sprintf('Particles (8k)   - %0.2f RE - Erro: %0.4f - Erro2: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,iter_acc(l,4),iter_acc(l,5),k, pdet, deltav))

%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - Particles (11)',amwrlab,l,rep))       
%         fitfunstrwalk = @(x)fitstrwalk11(x,X,slabel,label,disttype,valpha,1);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
%         [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);     
%         k = round(gaout);
%         disp(sprintf('Particles (11) - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,k))
        part3 = zeros(prep,1);
        parfor j=1:prep
            [owner, pot] = strwalk11mex(X, slabel, k, disttype, valpha, pdet, deltav);
            part3(j) = 1 - stmwevalk(label,slabel,owner,1);
            disp(sprintf('Particles (11) - %0.2f RE - Rep %3.0f/%3.0f - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,j,prep,part3(j),k, pdet, deltav))
        end
        iter_acc(l,6) = mean(part3);
        disp(sprintf('Particles (11) - %0.2f RE - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,iter_acc(l,6),k, pdet, deltav))   
        
%         disp(sprintf('Rodando Algoritmo Genético para %0.2f rótulos errados - Rep. %2.0f/%2.0f - Particles (20)',amwrlab,l,rep))       
%         fitfunstrwalk = @(x)fitstrwalk20(x,X,slabel,label,disttype,valpha,1);
%         options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
%         [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);     
%         k = round(gaout);
%         disp(sprintf('Particles (20) - %0.2f RE - Erro: %0.4f - K: %2.0f',amwrlab,fval,k))
        part4 = zeros(prep,1);
        parfor j=1:prep
            [owner, pot] = strwalk20mex(X, slabel, k, disttype, valpha, pdet, deltav);
            part4(j) = 1 - stmwevalk(label,slabel,owner,1);
            disp(sprintf('Particles (20) - %0.2f RE - Rep %3.0f/%3.0f - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,j,prep,part4(j),k, pdet, deltav))
        end
        iter_acc(l,7) = mean(part4);
        disp(sprintf('Particles (20) - %0.2f RE - Erro: %0.4f - K: %2.0f - Pgrd: %0.2f DeltaV: %0.2f',amwrlab,iter_acc(l,7),k, pdet, deltav))         
        
        disp(sprintf('COMP: Perc: %0.4f - Rep. %2.0f/%2.0f - Err: CO: %0.4f  LP: %0.4f  LNP: %0.4f  Part8k: %0.4f  Part8kWL: %0.4f  Part11: %0.4f  Part20: %0.4f',amwrlab,l,rep,iter_acc(l,1),iter_acc(l,2),iter_acc(l,3),iter_acc(l,4),iter_acc(l,5),iter_acc(l,6),iter_acc(l,7)))
    
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
    save tabs_wlcompreal20_don tab_acc tab_std_acc tab_min_acc tab_max_acc;
    disp(sprintf('FINAL: Perc: %0.4f  Err: CO: %0.4f  LP: %0.4f  LNP: %0.4f  Part8k: %0.4f  Part8kWL: %0.4f  Part11: %0.4f  Part20: %0.4f',amwrlab,tab_acc(i,1),tab_acc(i,2),tab_acc(i,3),tab_acc(i,4),tab_acc(i,5),tab_acc(i,6),tab_acc(i,7)))
end

