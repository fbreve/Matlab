rep = 100; % numero de repeti��es
qtalg = 4;
disttype = 'euclidean';
labpmax = 10;
k = 5;

% GPUstart
% spmd
%     GPUstart
% end

tab_acc=zeros(labpmax,qtalg);
tab_std_acc=zeros(labpmax,qtalg);
tab_min_acc=zeros(labpmax,qtalg);
tab_max_acc=zeros(labpmax,qtalg);

for i=1:1:labpmax
    labp = i*0.01;  
%     disp(sprintf('Rodando Algoritmo Gen�tico para %0.2f dados rotulados',labp))       
%     slabel = slabelgen(label,labp);
%     fitfunstrwalk = @(x)fitstrwalk8kk(x,X,slabel,label,disttype,0);
%     options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
%     [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);        
%     k = round(gaout);
%     disp(sprintf('Part�culas Original - Rotulados: %0.2f - Erro: %0.4f - K: %2.0f',labp,fval,k))   
    part1 = zeros(rep,1);
    part2 = zeros(rep,1);
    part3 = zeros(rep,1);
    part4 = zeros(rep,1);
    parfor j=1:rep
        slabel = slabelgen(label,labp);
        owner = strwalk8kmex(X, slabel, k, disttype);
        part1(j) = stmwevalk(label,slabel,owner);
        %[owner, slabel] = strwalk14(X, label, labp, k, disttype);
        [owner, slabel] = strwalk14mex(X, label, labp, k, disttype);
        part2(j) = stmwevalk(label,slabel,owner);
        %[owner, slabel] = strwalk15(X, label, labp, k, disttype);
        [owner, slabel] = strwalk15mex(X, label, labp, k, disttype);
        part3(j) = stmwevalk(label,slabel,owner);                
        [owner, slabel] = strwalk21mex(X, label, labp, k, disttype);
        part4(j) = stmwevalk(label,slabel,owner);                               
        disp(sprintf('Rotulados: %0.2f - Rep %3.0f/%3.0f - Original / Active Learning v.14 / v.15 / v.21: %0.4f - %0.4f - %0.4f - %0.4f',labp,j,rep,part1(j),part2(j),part3(j),part4(j)))
    end   
    tab_acc(i,:)    =[mean(part1) mean(part2) mean(part3) mean(part4)];
    tab_std_acc(i,:)=[std(part1)  std(part2)  std(part3)  std(part4)];
    tab_min_acc(i,:)=[min(part1)  min(part2)  min(part3)  min(part4)];
    tab_max_acc(i,:)=[max(part1)  max(part2)  max(part3)  max(part4)];
    save tabs_activelearningcompreal_pat tab_acc tab_std_acc tab_min_acc tab_max_acc;
    disp(sprintf('FINAL: Rotulados: %0.2f - Original / Active Learning v.14 / v.15 / v.21: %0.4f - %0.4f - %0.4f - %0.4f',labp,tab_acc(i,1),tab_acc(i,2),tab_acc(i,3),tab_acc(i,4)))
end

