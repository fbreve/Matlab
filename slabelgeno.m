% Gerador de slabel (n�s rotulados = classe, n�s n�o rotulados = 0)
% Garante pelo menos 1 n� rotulado por classe
% slabel = slabelgen(label,amount);
% label = label list
% amount = [0 1] percentage of pre-labeled samples
% v. slabelgeno aceita m�ltiplos r�tulos por n�
% n�o pega pro conjunto rotulado n�s com mais de um r�tulo
% BUGS:
% 1) O primeiro rotulado de cada item (primeiro la�o for) ignora a
% informa��o do segundo r�tulo, ou seja, pode pegar n�s que tem mais de um
% r�tulo e eles ser�o considerados como tendo apenas um r�tulo.
% 2) O primeiro for tamb�m pode ocasionar um loop infinito se n�o houver
% nenhum n� com determinado label na posi��o 1, que � a �nica considerada.
% COMENTARIO: Complicado de resolver, visto que eliminar o bug 1 implica em aumentar a
% chance de loop infinito, e pra eliminar a chance de loop infinito teria
% de considerar n�s rotulados com mais de um label, ao menos no primeiro
% for.
% POSSIVEL SOLU��O: Deixar liberado o uso de n�s com dois r�tulos apenas no
% primeiro for, e passar a considerar ambos os r�tulos.
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