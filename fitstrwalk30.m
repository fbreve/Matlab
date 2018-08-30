function y = fitstrwalk30(x,img,imgslab,gt,wtype,disttype)
    k = round(x(1));    
    owner = strwalk30(img, imgslab, k, wtype, disttype);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-k%i-wtype%i.png',getenv('computername'),y,k,wtype));    
end