% USO: [img,imgslab,gt] = imgdiaload(filename)
% Exemplo: [img,imgslab,gt] = imgdiaload('sheep')
function [img,imgslab,gt] = imgdiaload(filename,scribbleset)
    scribbleset = num2str(scribbleset);
    if exist(['MSRC/data_GT/' filename '.jpg'],'file')
        img = imread(['MSRC/data_GT/' filename '.jpg']);   
    elseif exist(['MSRC/data_GT/' filename '.bmp'],'file')
        img = imread(['MSRC/data_GT/' filename '.bmp']);
    elseif exist(['MSRC/BSDS300-images/BSDS300/images/train/' filename '.jpg'],'file')
        img = imread(['MSRC/BSDS300-images/BSDS300/images/train/' filename '.jpg']);
    elseif exist(['MSRC/BSDS300-images/BSDS300/images/test/' filename '.jpg'],'file')
        img = imread(['MSRC/BSDS300-images/BSDS300/images/test/' filename '.jpg']);
    end
    if exist(['dataset-interactive-algorithms/scribbles-set-' scribbleset '/' filename '-anno.png'],'file')
        imgslab = imread(['dataset-interactive-algorithms/scribbles-set-' scribbleset '/' filename '-anno.png']);
    end
    imgslab(imgslab==0)=128;
    imgslab(imgslab==1)=255;
    imgslab(imgslab==2)=64;    
    if exist(['MSRC/boundary_GT/' filename '.bmp'],'file')
        gt = imread(['MSRC/boundary_GT/' filename '.bmp']);
    end 
end