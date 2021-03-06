load tab_comp;
load 'uci-datasets\yeast'

rep = 1; % numero de repeti��es
subsetmax = 20;
isize=2;

iter_acc = zeros(rep,2);
iter_kap = zeros(rep,2);
iter_owndeg = zeros(size(X,1),max(label),rep);

tab_acc=zeros(subsetmax,isize);
tab_kap=zeros(subsetmax,isize);
tab_par = zeros(subsetmax,3);
%tab_owndeg = zeros(size(X,1),max(label),subsetmax);

options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',20,'Generations',50);

for subset=1:1:subsetmax
    slabel = slabelgen(label,50/1484);
    slabelupd = slabel;
    for j=1:26
        parfor i=1:rep
            [owner, pot, owndeg, distnode] = strwalk8k(X, slabelupd, 48, 0.48, 0.65);
            [acc1, kap1] = stmwevalk(label,slabel,owner);
            [~,owner2] = max(owndeg,[],2);
            [acc2, kap2] = stmwevalk(label,slabel,owner2);
            disp(sprintf('Subset: %02.0f TamConjRot: %02.0f  Itera��o: %03.0f  Acerto: %0.4f / %0.4f  Kappa: %0.4f / %0.4f',subset,j*50,i,acc1,acc2,kap1,kap2))
            iter_acc(i,:) = [acc1,acc2];
            iter_kap(i,:) = [kap1,kap2];
            iter_owndeg(:,:,i) = owndeg;            
        end
        tab_acc(subset,1)=mean(iter_acc(:,1));
        tab_acc(subset,2)=mean(iter_acc(:,2));
        tab_kap(subset,1)=mean(iter_kap(:,1));
        tab_kap(subset,2)=mean(iter_kap(:,2));
        tab_owndeg(:,:,subset) = mean(iter_owndeg,3);
        disp(sprintf('(D) Subset: %02.0f  TamConjRot: %02.0f  Acerto: %0.4f  Kappa: %0.4f',subset,j*50,tab_acc(subset,1),tab_kap(subset,1)))
        disp(sprintf('(F) Subset: %02.0f  TamConjRot: %02.0f  Acerto: %0.4f  Kappa: %0.4f',subset,j*50,tab_acc(subset,2),tab_kap(subset,2)))         
        owndeg = tab_owndeg(:,:,subset);
        [~,owner2] = max(owndeg,[],2);
        owndegsort = sort(owndeg,2,'descend');
        oi = owndegsort(:,2)./owndegsort(:,1) - 10*double(slabelupd~=0);
        oisort = sort(oi);
        slabelupd = slabelupd + (label .* (oi>=oisort(1434)));
    end      

    
    save tab_oi tab_acc tab_kap tab_owndeg tab_par;
end

