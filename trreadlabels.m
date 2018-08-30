% Lê labels das amostras do livro de SSL e passa para o formato suportado
% pelos algoritmos strwalk
% Uso: [label,slabel] = trreadlabels(y,idxLabs,subset)
function [label,slabel] = trreadlabels(y,idxLabs,subset)
if sum(y==-1)>0
    y = y + (y==-1)*3;
else
    y = y + 1;
end
label = y;
slabel = zeros(size(y));
slabel(idxLabs(subset,:)) = y(idxLabs(subset,:));
end