% Import data from kddcup.data_10_percent
% Automatically generated 27-Mar-2012
 
% Define parameters
fileName='C:\Users\Fabricio\Documents\Doutorado\Simulações\Matlab\uci-datasets\kddcup.data_10_percent';
numHeaderLines=0;
formatString='%f%q%q%q%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%q';
numRows=494021;
 
% Read data from file
fid=fopen(fileName,'rt');
data=textscan(fid,formatString,numRows,'headerlines',numHeaderLines,'delimiter',',');
status=fclose(fid);

X = [];
col=0;
% de coluna em coluna
for i=1:size(data,2)-1
   % se a coluna for numérica, é só copiá-la (normalizando no intervalo
   % 0-1)
   if isnumeric(data{:,i})        
       if std(data{:,i})~=0
           col=col+1;
           X(:,col) = data{:,i} ./ max(data{:,i});
       end
   % se a coluna é categórica, vamos criar uma coluna numérica para cada
   % categoria
   else
       z = double(nominal(data{:,i}));
       for j=1:size(z,1)
           X(j,col+z(j))=1;
       end
       col = col + max(z);
   end
end
% a última coluna tem os labels
label = double(nominal(data{:,end}));