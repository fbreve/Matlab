function y = fitcnsslis11(x,img,imgslab,gt,fwtype)
k = x(1);
owner = cnsslis11(img, imgslab, fwtype, k);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end