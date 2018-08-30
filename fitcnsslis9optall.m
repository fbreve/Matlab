function y = fitcnsslis9optall(x,img,imgslab,gt)
k = x(1);
sigma = x(2);
fw = x(3:11);
owner = cnsslis9(img, imgslab, fw, k, sigma);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end