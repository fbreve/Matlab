rep = 100; % numero de repetições
amount = 0.10;
classes = 6;
qtalg = 4;
amwrlabmax = 21; 

iter_acc = zeros(rep,qtalg);
iter_kap = zeros(rep,qtalg);

tab_acc=zeros(amwrlabmax,qtalg);
tab_std_acc=zeros(amwrlabmax,qtalg);
tab_min_acc=zeros(amwrlabmax,qtalg);
tab_max_acc=zeros(amwrlabmax,qtalg);
tab_kap=zeros(amwrlabmax,qtalg);
tab_std_kap=zeros(amwrlabmax,qtalg);
tab_min_kap=zeros(amwrlabmax,qtalg);
tab_max_kap=zeros(amwrlabmax,qtalg);

vet_acc = zeros(20,1);
vet_kap = zeros(20,1);      
vet2_acc = zeros(20,1);
vet2_kap = zeros(20,1);

for i=1:amwrlabmax
    amwrlab = i*0.05 - 0.05;
    for l=1:rep  
        slabel = slabelgenwl(label,amount,amwrlab);        
        parfor j=1:20
            owner = zhou(X,slabel,classes,10000,0.99,j);
            [vet_acc(j),vet_kap(j)] = stmwevalk(label,slabel,owner);
        end
        [iter_acc(l,1), ind1] = max(vet_acc);
        [iter_kap(l,1), ind2] = max(vet_kap);
        disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  CO: %0.4f  Sigma: %0.3f  %0.3f',amwrlab,l,rep,iter_kap(l,1),ind1,ind2))
        parfor j=1:20
            owner = labelprop(X,slabel,classes,10000,j);
            [vet_acc(j),vet_kap(j)] = stmwevalk(label,slabel,owner);
        end
        [iter_acc(l,2), ind1] = max(vet_acc);
        [iter_kap(l,2), ind2] = max(vet_kap);
        disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  LP: %0.4f  Sigma: %0.3f  %0.3f',amwrlab,l,rep,iter_kap(l,2),ind1,ind2))
        parfor j=1:20            
            [owner, pot, owndeg, distnode] = strwalk8(X, slabel, classes, 200000, 0.5, 0.1, 1.0, j*0.001, 2.0);
            [vet_acc(j),vet_kap(j)] = stmwevalk(label,slabel,owner);
            [nil,owner2] = max(owndeg,[],2);
            [vet2_acc(j),vet2_kap(j)] = stmwevalk(label,slabel,owner2);
        end
        [iter_acc(l,3),ind1] = max(vet_acc);
        [iter_kap(l,3),ind2] = max(vet_kap);
        [iter_acc(l,4),ind3] = max(vet2_acc);
        [iter_kap(l,4),ind4] = max(vet2_kap);
        disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  P1: %0.4f  Sigma: %0.3f  %0.3f',amwrlab,l,rep,iter_kap(l,3),ind1*0.001,ind2*0.001))
        disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  P2: %0.4f  Sigma: %0.3f  %0.3f',amwrlab,l,rep,iter_kap(l,4),ind3*0.001,ind4*0.001))
        disp(sprintf('Perc: %0.2f  Rep: %3.0f/%3.0f  CO: %0.4f  LP: %0.4f  P1: %0.4f  P2: %0.4f',amwrlab,l,rep,iter_kap(l,1),iter_kap(l,2),iter_kap(l,3),iter_kap(l,4)))

    end
    tab_acc(i,:)=mean(iter_acc);
    tab_std_acc(i,:)=std(iter_acc);
    tab_min_acc(i,:)=min(iter_acc);
    tab_max_acc(i,:)=max(iter_acc);
    tab_kap(i,:)=mean(iter_kap);
    tab_std_kap(i,:)=std(iter_kap);
    tab_min_kap(i,:)=min(iter_kap);
    tab_max_kap(i,:)=max(iter_kap);
    save tabs tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;
    disp(sprintf('FINAL: Perc: %0.4f  CO: %0.4f  LP: %0.4f  P1: %0.4f  P2: %0.4f',amwrlab,tab_kap(i,1),tab_kap(i,2),tab_kap(i,3),tab_kap(i,4)))
end

