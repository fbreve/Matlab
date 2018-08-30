function y = fitstrwalk29(x,img,imgslab,gt,disttype,slabtype)
    k = round(x(1));
    dm = x(2:21);
    owner = strwalk29(img, imgslab, dm, k, disttype, slabtype);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    imwrite(imgres,sprintf('img/img-%s-err%0.4f-k%i.png',getenv('computername'),y,k));
    dlmwrite(sprintf('img/img-%s-err%0.4f-k%i.txt',getenv('computername'),y,k),dm);
end