rep = 100; % numero de repetições
isize = 10;

iter_acc = zeros(rep,4);
iter_kap = zeros(rep,4);

tab_acc=zeros(isize,4);
tab_std_acc=zeros(isize,4);
tab_min_acc=zeros(isize,4);
tab_max_acc=zeros(isize,4);
tab_kap=zeros(isize,4);
tab_std_kap=zeros(isize,4);
tab_min_kap=zeros(isize,4);
tab_max_kap=zeros(isize,4);

ind_x = 0;
for i=0.1:-0.01:0.01
    parfor l=1:rep
        slabel = slabelgen(label,i);
        %owner = zhou(X,slabel,2,10000,0.99,4);
        %[acc1,k1] = stmwevalk(label,slabel,owner);        
        %owner = labelprop(X,slabel,2,10000,6);
        %[acc2,k2] = stmwevalk(label,slabel,owner);       
        
        acc1=0;
        acc2=0;
        k1=0;
        k2=0;        
        
        [owner, pot, owndeg, distnode] = strwalk8(X, slabel, 10, 200000, 0.5, 0.1, 1.0, 18, 2.0);
        [acc3,k3] = stmwevalk(label,slabel,owner);
        [nil,owner2] = max(owndeg,[],2);
        [acc4,k4] = stmwevalk(label,slabel,owner2);
        disp(sprintf('Percent: %0.4f  Rep: %3.0f/%3.0f  Consistency: %0.4f  Label Prop: %0.4f  Particle: %0.4f  Particle2: %0.4f',i,l,rep,k1,k2,k3,k4))
        iter_acc(l,:) = [acc1,acc2,acc3,acc4];
        iter_kap(l,:) = [k1,k2,k3,k4];
    end
    ind_x = ind_x + 1;
    tab_acc(ind_x,:)=mean(iter_acc);
    tab_std_acc(ind_x,:)=std(iter_acc);
    tab_min_acc(ind_x,:)=min(iter_acc);
    tab_max_acc(ind_x,:)=max(iter_acc);
    tab_kap(ind_x,:)=mean(iter_kap);
    tab_std_kap(ind_x,:)=std(iter_kap);
    tab_min_kap(ind_x,:)=min(iter_kap);
    tab_max_kap(ind_x,:)=max(iter_kap);
    save tabs tab_acc tab_std_acc tab_min_acc tab_max_acc tab_kap tab_std_kap tab_min_kap tab_max_kap;
    disp(sprintf('FINAL: Percent: %0.4f  Consistency: %0.4f  Label Prop: %0.4f  Particle: %0.4f  Particle2: %0.4f',i,tab_kap(ind_x,1),tab_kap(ind_x,2),tab_kap(ind_x,3),tab_kap(ind_x,4)))
end

