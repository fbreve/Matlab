function y = fitcnsslis10(x,img,imgslab,gt)
k = x(1);
owner = cnsslis10(img, imgslab, [], k);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end