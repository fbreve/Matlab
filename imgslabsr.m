% function to reduce seeds in images from the Grabcut dataset
%
% Use: imgslabd = imgslabsr(imgslab,p)

function imgslabd = imgslabsr(imgslab,p)
    [m,n] = size(imgslab);
    imrand = rand(m,n)<p;
    imgslabd = imgslab;
    imgslabd((imgslabd==64 | imgslab==255) & imrand==0) = 128;
end