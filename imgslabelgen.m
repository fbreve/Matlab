dim = size(imgslab);
randgrid = min(randi([0 99],dim(1),dim(2)),1);
gt = imgslab;
bg = find(imgslab==64);
fg = find(imgslab==255);
imgslab(bg) = imgslab(bg) + 64*uint8(randgrid(bg));
imgslab(fg) = imgslab(fg) - 127*uint8(randgrid(fg));