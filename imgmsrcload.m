% USO: [img,imgslab,gt] = imgmsrcload(filename)
% Exemplo: [img,imgslab,gt] = imgmsrcload('sheep')
function [img,imgslab,gt] = imgmsrcload(filename)
    if exist(['MSRC/data_GT/' filename '.jpg'],'file')
        img = imread(['MSRC/data_GT/' filename '.jpg']);   
    elseif exist(['MSRC/data_GT/' filename '.bmp'],'file')
        img = imread(['MSRC/data_GT/' filename '.bmp']);
    elseif exist(['MSRC/BSDS300-images/BSDS300/images/train/' filename '.jpg'],'file')
        img = imread(['MSRC/BSDS300-images/BSDS300/images/train/' filename '.jpg']);
    elseif exist(['MSRC/BSDS300-images/BSDS300/images/test/' filename '.jpg'],'file')
        img = imread(['MSRC/BSDS300-images/BSDS300/images/test/' filename '.jpg']);
    end
    if exist(['MSRC/boundary_GT_lasso/' filename '.bmp'],'file')
        imgslab = imread(['MSRC/boundary_GT_lasso/' filename '.bmp']);
    end
    if exist(['MSRC/boundary_GT/' filename '.bmp'],'file')
        gt = imread(['MSRC/boundary_GT/' filename '.bmp']);
    end
    
end