function y = fitcnsslis5feat(x,img,imgslab,gt,disttype,fw)
k = x(1);
owner = cnsslis5(img, imgslab, fw, k, disttype);
imgres = own2img(owner,img,0);
y = imgeval(imgres, gt, imgslab);
end