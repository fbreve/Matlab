% Uso: X = img2feat(img)
function X = img2feat(img,texture)
    if (nargin < 2) || isempty(texture),
        texture = 0; % número de iterações
    end
    dim = size(img);    
    X = zeros(dim(1)*dim(2),8 + texture*6);
    imgvec = double(squeeze(reshape(img,dim(1)*dim(2),1,3)))/255;
    % primeiros 3 elementos serão RGB normalizado em 0:1    
    X(:,1:3) = imgvec;    
    % depois vem os 3 elementos HSV
    X(:,4:6) = rgb2hsv(imgvec);
    % sétimo e oitavo elementos são as dimensões X e Y normalizadas no intervalo 0:1
    X(:,7:8) = [repmat(((1:dim(2))/max(dim(1),dim(2)))',dim(1),1), reshape(repmat((1:dim(1))/max(dim(1),dim(2)),dim(2),1),dim(1)*dim(2),1)];   
    if texture==1
        h = fspecial('average', [3 3]);
        g = imfilter(img, h);
        j = stdfilt(img);
        X(:,9:11) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)))/255;
        X(:,12:14) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)))/255;
        g = imfilter(rgb2hsv(img), h);
        j = stdfilt(rgb2hsv(img));
        X(:,15:17) = double(squeeze(reshape(g,dim(1)*dim(2),1,3)));
        X(:,18:20) = double(squeeze(reshape(j,dim(1)*dim(2),1,3)));        
    end
end