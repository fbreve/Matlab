imgnames = {'21077' '124084' '271008' '208001' 'llama' 'doll' 'person7' 'sheep' 'teddy'};

kmin = 1;
kmax = 1000;
fwmin = zeros(1,23);
fwmax = ones(1,23);

if exist('tab_k','var')==0
    tab_k = zeros(9,1);
end
if exist('tab_y','var')==0
    tab_y = zeros(9,1);
end
if exist('tab_fw','var')==0
    tab_fw = zeros(9,23);
end
if exist('i_start','var')==0
    i_start = 1;
end

for i=i_start:1:9
    imgname = imgnames{i};
    fprintf('Segmentando imagem %i/9: %s\n',i,imgname);
    [img,imgslab,gt] = imgmsrcload(imgname);              
    fitfuncnsslis = @(x)fitcnsslis9_23feat(x,img,imgslab,gt);    
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);        
    IntCon = 1;        
    [gaout, fval] = ga(fitfuncnsslis,24,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
    tab_k(i) = gaout(1);
    tab_fw(i,:) = gaout(2:24);
    tab_y(i) = fval;    
    save(sprintf('res/tabs_cnsslis9_23feat-%s',getenv('computername')),'tab_k','tab_y','tab_fw');
end