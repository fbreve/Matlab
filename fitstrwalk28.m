function y = fitstrwalk28(x,img,imgslab,gt,disttype,texture,slabtype)
    k = round(x(1));
    dm = x(2);
    owner = strwalk28(img, imgslab, dm, k, disttype, texture, slabtype);
    imgres = own2img(owner,img,0);
    y = imgeval(imgres, gt, imgslab);
    imwrite(imgres,sprintf('img-%s-k%i-dm%0.4f-err%0.4f.png',getenv('computername'),k,dm,y))
end