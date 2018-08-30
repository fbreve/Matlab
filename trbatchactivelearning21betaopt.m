rep = 100; % numero de repetições
disttype = 'euclidean';
labpmax = 10;
betamax = 11;
k = 5;

% GPUstart
% spmd
%     GPUstart
% end

tab_acc=zeros(labpmax,betamax);
tab_std_acc=zeros(labpmax,betamax);
tab_min_acc=zeros(labpmax,betamax);
tab_max_acc=zeros(labpmax,betamax);

for i=1:1:labpmax
    labp = i*0.01;  
    for i2=1:1:betamax
        beta = (i2-1)*0.1;
        part = zeros(rep,1);
        parfor j=1:rep
            slabel = slabelgen(label,labp);
            [owner, slabel] = strwalk21mex(X, label, labp, k, disttype, beta);
            part(j) = stmwevalk(label,slabel,owner);                               
            disp(sprintf('Rotulados: %0.2f - Beta: %0.2f - Rep %3.0f/%3.0f - Acerto: %0.4f',labp,beta,j,rep,part(j)))
        end
        tab_acc(i,i2)    = mean(part);
        tab_std_acc(i,i2)= std(part);
        tab_min_acc(i,i2)= min(part);
        tab_max_acc(i,i2)= max(part);
        disp(sprintf('FINAL: Rotulados: %0.2f - Beta: %0.2f - Acerto: %0.4f',labp,beta,tab_acc(i,i2)))
    end
    save tabs_activelearning21beta tab_acc tab_std_acc tab_min_acc tab_max_acc;    
end

