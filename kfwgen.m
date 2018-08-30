% Uso: fw = fwgen(img, imgslab)
function [k, fw] = kfwgen(img, imgslab)
    gt = imgslab;    
    dim = size(imgslab);
    imgrnd = rand(dim)>0.01;
    imgslab(imgslab==64 & imgrnd) = 128;
    imgslab(imgslab==255 & imgrnd) = 128;

    kmin = 0;
    kmax = 2000;
    fwmin = zeros(1,20);
    fwmax = ones(1,20);
    disttype = 'euclidean';
    fitfuncnsslis = @(x)fitcnsslis5(x,img,imgslab,gt,disttype);
    options = gaoptimset('Display','iter','UseParallel','always','FitnessLimit',0);
    IntCon = 1;
    gaout = ga(fitfuncnsslis,21,[],[],[],[],[kmin fwmin],[kmax fwmax],[],IntCon,options);
    k = gaout(1);
    fw = gaout(2:21);            
end
