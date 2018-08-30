% Gerador de slabel (n�s rotulados = classe, n�s n�o rotulados = 0)
% Garante pelo menos 1 n� rotulado por classe
% Insere labels errados
% slabel = slabelgenwl(label,amount,amwrlab);
% label = label list
% amount = [0 1] percentage of pre-labeled samples
% amwrlab = [0 1] percentage of pre-labeled samples with wrong label
function slabel = slabelgenwl(label,amount,amwrlab)
    qtnode = size(label,1);         % quantidade de n�s
    slabel = zeros(qtnode,1);       % vetor slabel
    plabc = round(qtnode*amount);   % quantidade de n�s pr�-rotulados
    qtclass = max(label);           % quantidade de classes
    pwrlab = round(plabc*amwrlab);  % quantidade de n�s com label incorreto
    % garantindo um n� pr�-rotulado para cada classe
    for i=1:qtclass  % para cada classe
        if plabc<=pwrlab
            break;
        end
        while 1 % repete at� n� aleat�rio da classe desejada
            r = random('unid',qtnode); % escolhe n� aleat�rio
            if label(r)==i          % se n� aleat�rio � da classe desejada
                break;              
            end
        end
        slabel(r)=i; 
        plabc = plabc - 1;
    end
    % escolhendo demais n�s pr�-rotulados corretamente
    while plabc>pwrlab
        r = random('unid',qtnode);  % escolhe n� aleat�rio
        if slabel(r)==0             % se n� aleat�rio ainda n�o escolhido
            slabel(r) = label(r);   % n� passa a ser pr�-rotulado
            plabc = plabc - 1;      
        end
    end
    % escolhendo n�s pr�-rotulados erroneamente
    while plabc>0
        r = random('unid',qtnode);  % escolhe n� aleat�rio
        if slabel(r)==0             % se n� ainda n�o escolhido
            wrlab = random('unid',qtclass-1);   % gera classe errada 
            if wrlab >= label(r)            
                wrlab = wrlab + 1;
            end
            slabel(r) = wrlab; % atribui classe errada
            plabc = plabc - 1;
        end       
    end
end
