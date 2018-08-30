% Gerador de slabel (nós rotulados = classe, nós não rotulados = 0)
% Garante pelo menos 1 nó rotulado por classe
% Insere labels errados
% slabel = slabelgenwl(label,amount,amwrlab);
% label = label list
% amount = [0 1] percentage of pre-labeled samples
% amwrlab = [0 1] percentage of pre-labeled samples with wrong label
function slabel = slabelgenwl(label,amount,amwrlab)
    qtnode = size(label,1);         % quantidade de nós
    slabel = zeros(qtnode,1);       % vetor slabel
    plabc = round(qtnode*amount);   % quantidade de nós pré-rotulados
    qtclass = max(label);           % quantidade de classes
    pwrlab = round(plabc*amwrlab);  % quantidade de nós com label incorreto
    % garantindo um nó pré-rotulado para cada classe
    for i=1:qtclass  % para cada classe
        if plabc<=pwrlab
            break;
        end
        while 1 % repete até nó aleatório da classe desejada
            r = random('unid',qtnode); % escolhe nó aleatório
            if label(r)==i          % se nó aleatório é da classe desejada
                break;              
            end
        end
        slabel(r)=i; 
        plabc = plabc - 1;
    end
    % escolhendo demais nós pré-rotulados corretamente
    while plabc>pwrlab
        r = random('unid',qtnode);  % escolhe nó aleatório
        if slabel(r)==0             % se nó aleatório ainda não escolhido
            slabel(r) = label(r);   % nó passa a ser pré-rotulado
            plabc = plabc - 1;      
        end
    end
    % escolhendo nós pré-rotulados erroneamente
    while plabc>0
        r = random('unid',qtnode);  % escolhe nó aleatório
        if slabel(r)==0             % se nó ainda não escolhido
            wrlab = random('unid',qtclass-1);   % gera classe errada 
            if wrlab >= label(r)            
                wrlab = wrlab + 1;
            end
            slabel(r) = wrlab; % atribui classe errada
            plabc = plabc - 1;
        end       
    end
end
