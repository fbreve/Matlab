% n de 10% a 100%
if exist('tab_eval','var')==0
    tab_eval = zeros(10,5);   
end
if exist('tab_time','var')==0
    tab_time = zeros(10,1);
end
if exist('i_start','var')==0
    i_start = 1;
end
k=10;

for i=1:10
    rs_img = imresize(img,sqrt(i/10),'bicubic');
    fprintf('Tratando imagem com %i%% do tamanho original\n',i/10*100);    
    % teste de quantidade de iterações
    tstart = tic;
    [S,C,E,Crand_mean,Erand_mean] = cnsslis9smallworldness2(rs_img);
    telapsed = toc(tstart);
    tab_time(i) = telapsed;
    tab_eval(i,:) = [S,C,E,Crand_mean,Erand_mean];
    fprintf('S: %0.4f C: %0.4f E: %0.4f Tempo: %8.2f\n',S,C,E,telapsed);
    save(sprintf('res/tabs_cnsslis9smallworldness-%s',getenv('computername')),'tab_eval','tab_time');                  
end