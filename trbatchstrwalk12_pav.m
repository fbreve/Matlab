if exist('tabs_strwalk12_pav.mat','file') 
    load tabs_strwalk12_pav;
end
rep = 4; % numero de repeti��es (conjuntos diferentes)
amount = 0.10; % quantidade de elementos pr�-rotulados
disttype = 'euclidean';
k = 5;
for i=1:1:6
    for j=1:10
        gmaxmult = i*2;
        pmax = j*20;
        parfor k=1:rep            
            [X, label] = gaussdrift(10000,100);
            slabel = slabelgen(label,0.1);
            tic;
            [owner, pot] = strwalk12(X, slabel, k, disttype, gmaxmult, pmax);
            tim(i,j,k) = toc;
            acc(i,j,k) = stmwevalk(label,slabel,owner);
            disp(sprintf('Gmaxmult: %2.0f  Pmax: %3.0f  Rep: %2.0f/%2.0f  Acerto: %0.4f  Tempo: %0.2f',gmaxmult,pmax,k,rep,acc(i,j,k),tim(i,j,k)))
        end
        save tabs_strwalk12_pav acc tim;
        disp(sprintf('FINAL: Gmaxmult: %2.0f  Pmax: %3.0f  Acerto: %0.4f  Tempo: %0.2f',gmaxmult,pmax,mean(acc(i,j,:),3),mean(tim(i,j,:),3)))
    end
end    