rep = 1000;
amountmax = 25;
tab_orig = zeros(rep,1);
tab_recip = zeros(rep,1);
load('iris.dat');
label = iris(:,end);
load('Daniel\iris-daniel.mat')
KNNorig = irisKNN30orig;
KNNrecip = irisKNN30recip;
for j=1:amountmax
    amount = j*0.02;
    parfor i=1:rep
        slabel = slabelgen(label,amount);
        owner = strwalk8knnmex(KNNorig, slabel);
        tab_orig(i,j) = stmwevalk(label,slabel,owner);
        [owner, pot, owndeg] = strwalk8knnmex(KNNrecip, slabel);
        tab_recip(i,j) = stmwevalk(label,slabel,owner);    
        disp(sprintf('Amount: %0.2f Rep.: %i/%i  Acerto: %0.4f %0.4f',amount,i,rep,tab_orig(i,j),tab_recip(i,j)))
    end
    disp(sprintf('FINAL: Amount: %0.2f Acerto: %0.4f %0.4f',amount,mean(tab_orig(:,j)),mean(tab_recip(:,j))))
    save tabs_daniel tab_orig tab_recip    
end

