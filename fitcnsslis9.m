function y = fitcnsslis9(x,img,imgslab,gt)
k = x(1);
owner = cnsslis9(img, imgslab, [], k);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end