rep = 200; % numero de repetições
csize = 250; % tamanho da classe
isize=5;

tab_tim = zeros(rep,4);

for irep=1:1:rep
    
    A = gauss([csize csize csize csize],[-2,-2;-2,2;2,-2;2,2]);
    X = A.data;
    label = A.nlab;
    clear A;
    slabel = slabelgen(label,50/(csize*4));
       
    disp(sprintf('Repetição %02.0f de %02.0f',irep,rep))
    
    disp('Consistency');
    tic;
    mozhou(X,slabel,3);
    tab_tim(irep,1) = toc;
    disp(sprintf('Consistency: %02.0f segundos',tab_tim(irep,1)))
     
    disp('Label Propagation');
    tic;
    molabelprop(X,slabel,3);
    tab_tim(irep,2) = toc;
    disp(sprintf('Label Propagation: %02.0f segundos',tab_tim(irep,2)))
    
    disp('Linear Neighborhood Propagation');
    tic;
    molnp(X,slabel,25);
    tab_tim(irep,3) = toc;
    disp(sprintf('LNP: %02.0f segundos',tab_tim(irep,3)))
       
    disp('Particles');
    tic;
    mostrwalk8kef3(X, slabel, 25); toc;
    tab_tim(irep,4) = toc;
    disp(sprintf('Particles: %02.0f segundos',tab_tim(irep,4)))    
    
    disp(sprintf('Repetição: %02.0f  CM/LP/LNP/PART: %0.4f / %0.4f / %0.4f / %0.4f',irep,tab_tim(irep,1),tab_tim(irep,2),tab_tim(irep,3),tab_tim(irep,4)))
   
    save tab_time tab_tim;
end

