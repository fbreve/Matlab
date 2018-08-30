rep = 100; % numero de repetições
qtalg = 5;
disttype = 'euclidean';
labpmax = 10;
k = 5;

% GPUstart
% spmd
%     GPUstart
% end

cp_tab_acc = zeros(labpmax,qtalg);
cp_tab_std_acc = zeros(labpmax,qtalg);
cp_tab_min_acc = zeros(labpmax,qtalg);
cp_tab_max_acc = zeros(labpmax,qtalg);

% os melhores beta
[cp_tab_acc(:,4),indmax] = max(tab_acc,[],2);
cp_tab_max_acc(:,4) = tab_max_acc(sub2ind(size(tab_max_acc),1:10,indmax'))';
cp_tab_min_acc(:,4) = tab_min_acc(sub2ind(size(tab_min_acc),1:10,indmax'))';
cp_tab_std_acc(:,4) = tab_std_acc(sub2ind(size(tab_std_acc),1:10,indmax'))';

% os piores beta 
[cp_tab_acc(:,5),indmin] = min(tab_acc,[],2);
cp_tab_max_acc(:,5) = tab_max_acc(sub2ind(size(tab_max_acc),1:10,indmin'))';
cp_tab_min_acc(:,5) = tab_min_acc(sub2ind(size(tab_min_acc),1:10,indmin'))';
cp_tab_std_acc(:,5) = tab_std_acc(sub2ind(size(tab_std_acc),1:10,indmin'))';


for i=1:1:labpmax
    labp = i*0.01;  
%     disp(sprintf('Rodando Algoritmo Genético para %0.2f dados rotulados',labp))       
%     slabel = slabelgen(label,labp);
%     fitfunstrwalk = @(x)fitstrwalk8kk(x,X,slabel,label,disttype,0);
%     options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0,'StallGenLimit',2,'Generations',5,'InitialPopulation',[1;2;4;6;8;12;15;20;30;40;50;75;100;125;150;175;200;250;300]);
%     [gaout,fval] = ga(fitfunstrwalk,1,[],[],[],[],1,300,[],options);        
%     k = round(gaout);
%     disp(sprintf('Partículas Original - Rotulados: %0.2f - Erro: %0.4f - K: %2.0f',labp,fval,k))
    part1 = zeros(rep,1);
    part2 = zeros(rep,1);
    part3 = zeros(rep,1);
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
    end   
    cp_tab_acc(i,1:3)     = [mean(part1) mean(part2) mean(part3)];
    cp_tab_std_acc(i,1:3) = [std(part1)  std(part2)  std(part3)];
    cp_tab_min_acc(i,1:3) = [min(part1)  min(part2)  min(part3)];
    cp_tab_max_acc(i,1:3) = [max(part1)  max(part2)  max(part3)];
    save tabs_activelearningcompreal cp_tab_acc cp_tab_std_acc cp_tab_min_acc cp_tab_max_acc;
    disp(sprintf('FINAL: Rotulados: %0.2f - Original / AL v.14 / v.15 / v.21: %0.4f - %0.4f - %0.4f - %0.4f - %0.4f',labp,cp_tab_acc(i,1),cp_tab_acc(i,2),cp_tab_acc(i,3),cp_tab_acc(i,4),cp_tab_acc(i,5)))
end

