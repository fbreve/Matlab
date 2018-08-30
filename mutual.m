% Interface para o calculador de mutual information
% Andrea Lancichinetti et al 2009 New J. Phys. 11 033015
% Uso: mutualinf = mutual(label,owner)
function mutualinf = mutual(label,owner)
    nclass = max(label);
    [N,M] = size(label);
    fid = fopen('label.dat','w');
    writefile(label,fid,nclass,N,M)
    fclose(fid);
    fid = fopen('owner.dat','w');
    writefile(owner,fid,nclass,N,M)
    fclose(fid);    
    [~, result] = dos('..\mutual3\mutual label.dat owner.dat');
%     if exist('label.dat', 'file')
%         delete('label.dat');
%     end
%     if exist('owner.dat', 'file')
%         delete('owner.dat');
%     end
    mutualinf = textscan(result,'mutual3:\t%.6f');    
    mutualinf = mutualinf{1};    
end

function writefile(label,fid,nclass,N,M)
    for i=1:nclass
        for j=1:N
            for k=1:M
                if label(j,k)==i
                    fprintf(fid,'%u ',j);
                end                
            end
        end
        fprintf(fid,'\n');
    end
end