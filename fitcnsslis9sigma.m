function y = fitcnsslis9sigma(x,img,imgslab,gt)
k = x(1);
sigma = x(2);
owner = cnsslis9(img, imgslab, [], k, sigma);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end