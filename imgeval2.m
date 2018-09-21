% Avaliação de imagens segmentadas do Microsoft GrabCut dataset
% Uso: error = imgeval(imgres, gt, imgslab)
% imgres - imagem resultante da segmentação
% gt - ground truth
% imgslab - imagem 
% Returns:
% err - Error Rate
% acc - Classification Accuracy
% tpr - Sensitivity (Recall)
% spc - Specificity
% jaccard - Jaccard coefficient
% dice - Dice coefficient (F1 Score)
function [err, acc, tpr, spc, jaccard, dice] = imgeval2(imgres, gt, imgslab)
    totunlpix = sum(sum(imgslab==128 & gt~=128));
    toterrpix = sum(sum(abs(double(imgres)-double(gt))>1 & imgslab==128 & gt~=128));
    err = toterrpix/totunlpix;
    acc = 1 - err;
    ttp = sum(sum(imgslab==128 & gt==255));
    ttn = sum(sum(imgslab==128 & gt==0));
    tp = sum(sum(imgres==255 & imgslab==128 & gt==255)) / ttp;
    tn = sum(sum(imgres==0 & imgslab==128 & gt==0)) / ttn;
    fp = sum(sum(imgres==255 & imgslab==128 & gt==0)) / ttp;
    fn = sum(sum(imgres==0 & imgslab==128 & gt==255)) / ttn;
    tpr = tp / (tp + fn);        
    spc = tn / (tn + fp);
    jaccard = tp / (tp + fn + fp);
    dice = 2*tp / (2*tp + fn + fp);
end