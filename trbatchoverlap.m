ind=1;
tab_owndeg = zeros(14,4);
tab_stddev = zeros(14,4);
iter = zeros(100,4);
ind_x=1;
for i=0:8
    parfor l=1:100
        [graph, label] = graphgen2([32 32 32 32],6,16);
        [graph, label] = addoverlapnode(graph,label,[16-i i 0 0]);
        [owner, pot, owndeg] = ftrwalk5(graph, 4, 50000, 0.5, 0.4, 0.9);
        [accuracy, owner, owndeg] = tmwevaloverlap(label,owner,owndeg);
        iter(l,:) = owndeg(129,:);
    end
    tab_owndeg(ind_x,:)=mean(iter);
    tab_stddev(ind_x,:)=std(iter);
    disp(sprintf('i: %d Deg: %0.4f %0.4f %0.4f %0.4f',i,tab_owndeg(ind_x,1),tab_owndeg(ind_x,2),tab_owndeg(ind_x,3),tab_owndeg(ind_x,4)))
    save tabs tab_owndeg tab_stddev
    ind_x = ind_x + 1;
end
for i=0:4
    parfor l=1:100
        [graph, label] = graphgen2([32 32 32 32],6,16);
        [graph, label] = addoverlapnode(graph,label,[8-i 4 4 i]);
        [owner, pot, owndeg] = ftrwalk5(graph, 4, 50000, 0.5, 0.4, 0.9);
        [accuracy, owner, owndeg] = tmwevaloverlap(label,owner,owndeg);
        iter(l,:) = owndeg(129,:);
    end
    tab_owndeg(ind_x,:)=mean(iter);
    tab_stddev(ind_x,:)=std(iter);
    disp(sprintf('i: %d Deg: %0.4f %0.4f %0.4f %0.4f',i,tab_owndeg(ind_x,1),tab_owndeg(ind_x,2),tab_owndeg(ind_x,3),tab_owndeg(ind_x,4)))
    save tabs tab_owndeg tab_stddev
    ind_x = ind_x + 1;
end