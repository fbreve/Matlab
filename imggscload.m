% USO: [img,imgslab,gt] = imgmsrcload(filename)
% Exemplo: [img,imgslab,gt] = imgmsrcload('sheep')
function [img,imgslab,gt] = imggscload(filename)
    if exist(['GSC/images/' filename '.jpg'],'file')
        img = imread(['GSC/images/' filename '.jpg']);   
    elseif exist(['GSC/images/' filename '.bmp'],'file')
        img = imread(['GSC/images/' filename '.bmp']);
    end
    if exist(['GSC/images-labels/' filename '-anno.png'],'file')
        imgslab = imread(['GSC/images-labels/' filename '-anno.png']);
    end
    imgslab(imgslab==0)=128;
    imgslab(imgslab==1)=255;
    imgslab(imgslab==2)=64;
    if exist(['GSC/images-gt/' filename '.png'],'file')
        gt = imread(['GSC/images-gt/' filename '.png']);
    end    
end