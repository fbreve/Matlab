% Gerador de slabel (nós rotulados = classe, nós não rotulados = 0)
% Garante pelo menos 1 nó rotulado por classe
% slabel = slabelgen(label,amount);
% label = label list
% amount = [0 1] percentage of pre-labeled samples
% v. slabelgeno aceita múltiplos rótulos por nó
% não pega pro conjunto rotulado nós com mais de um rótulo
% BUGS:
% 1) O primeiro rotulado de cada item (primeiro laço for) ignora a
% informação do segundo rótulo, ou seja, pode pegar nós que tem mais de um
% rótulo e eles serão considerados como tendo apenas um rótulo.
% 2) O primeiro for também pode ocasionar um loop infinito se não houver
% nenhum nó com determinado label na posição 1, que é a única considerada.
% COMENTARIO: Complicado de resolver, visto que eliminar o bug 1 implica em aumentar a
% chance de loop infinito, e pra eliminar a chance de loop infinito teria
% de considerar nós rotulados com mais de um label, ao menos no primeiro
% for.
% POSSIVEL SOLUÇÃO: Deixar liberado o uso de nós com dois rótulos apenas no
% primeiro for, e passar a considerar ambos os rótulos.
function slabel = slabelgeno(label,amount)
    qtnode = size(label,1);    
    slabel = zeros(qtnode,1);
    plabc = round(qtnode*amount);
    qtclass = max(max(label));
    for i=1:qtclass
        while 1 
            r = random('unid',qtnode);    
            if label(r)==i 
                break;
            end
        end
        slabel(r,1)=label(r,1);
        plabc = plabc - 1;
    end
    while plabc>0
        r = random('unid',qtnode);
        if slabel(r,1)==0 && label(r,2)==0
            slabel(r,1) = label(r,1);
            plabc = plabc - 1;
        end
    end
end