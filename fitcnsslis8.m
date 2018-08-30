function y = fitcnsslis8(x,img,imgslab,gt,disttype)
k = x(1);
owner = cnsslis8(img, imgslab, [], k, disttype);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end