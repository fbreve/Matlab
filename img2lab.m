% Utilize branco RGB(255,255,255) para nós sem rótulo e cores diferentes
% para cada rótulo de nós rotulados.
% Uso: slabel = img2lab(img)
function slabel = img2lab(imgslab,type)    
    if (nargin < 2) || isempty(type),
        type = 0;
    end
    dim = size(imgslab);
    if ndims(imgslab)==3
        slabel = reshape(double(imgslab(:,:,1))*256*256+double(imgslab(:,:,2))*256+double(imgslab(:,:,3)),dim(1)*dim(2),1);
    else
        slabel = reshape(double(imgslab),dim(1)*dim(2),1);
    end
    if type==0   
        labc=0;
        while max(slabel>labc)
            slabel(slabel==max(slabel)) = labc;
            labc = labc+1;
        end
    else % imagens do Microsoft Research Cambridge
        slabel(slabel==0)=1; % fundo
        slabel(slabel==64)=1;  % c/ rótulo - fundo
        slabel(slabel==255)=2; % c/ rótulo - objeto
        slabel(slabel==128)=0; % sem rótulo
    end        
end