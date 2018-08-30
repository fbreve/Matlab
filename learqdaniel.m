files = dir('*kn*');
cont = 1;
for file=files'
    filename = file.name;
    delimiter = ',';
    
    %% Format string for each line of text:
    %   column2: double (%f)
    %	column3: double (%f)
    %   column4: double (%f)
    %	column5: double (%f)
    %   column6: double (%f)
    %	column7: double (%f)
    %   column8: double (%f)
    %	column9: double (%f)
    %   column10: double (%f)
    %	column11: double (%f)
    %   column12: double (%f)
    %	column13: double (%f)
    %   column14: double (%f)
    %	column15: double (%f)
    %   column16: double (%f)
    %	column17: double (%f)
    %   column18: double (%f)
    %	column19: double (%f)
    %   column20: double (%f)
    %	column21: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%*s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    
    %% Open the text file.
    fileID = fopen(filename,'r');
    
    %% Read columns of data according to format string.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    
    %% Close the text file.
    fclose(fileID);
    
    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.
    
    %% Create output variable
    distMatrixL2 = [dataArray{1:end-1}];
    %% Clear temporary variables
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    distMatrixL2 = distMatrixL2 + 1; % arquivos do Daniel iniciam em 0, os meus em 1.
    
    tabdaniel{cont} = distMatrixL2;
        
    cont = cont + 1;
    
    save tabdaniel tabdaniel
end