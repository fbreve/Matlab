indint = zeros(1000,1);

for i=1:1000
    [indint(i)] = strwalk35teste(img, imgslab, fw, i);
    fprintf('K: %4.0f  Indice: %0.4f\n',i,indint(i));
end

save
