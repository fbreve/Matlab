function y = fitcnsslis9_23feat(x,img,imgslab,gt)
k = x(1);
fw = x(2:24);
owner = cnsslis9_23feat(img, imgslab, fw, k);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end