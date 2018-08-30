% Fuzzy Territory Mark Walk v.6
% Baseado em ftrwalk5 e strwalk8
% Cada n� tem n potenciais, onde n � o n�mero de part�culas
% Valores fuzzy obtidos com contagem de visitas ponderada por potencial de
% part�cula (contando apenas visitas no movimento aleat�rio)
% v.6 -> calcula kernel de cada cluster, incorpora otimiza��es de strwalk8
% v.6 -> incorpora reset
% Usage: [owner, owner2, pot, owndeg, cmeans] = ftrwalk6(X, sigma, npart, iter, pdet, deltav, deltap)
function [owner, owner2, pot, owndeg, cmeans] = ftrwalk6(X, sigma, npart, iter, pdet, deltav, deltap)
    if (nargin < 4) || isempty(iter),
        iter = 200000; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end        
    if (nargin < 5) || isempty(pdet),
        pdet = 0.300; % probabilidade de n�o explorar
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.400; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 0.900; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end    % constantes
    knn = 0;
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
    qtnode = size(X,1); % quantidade de n�s
    ivconv = round(min(1000,qtnode/npart*10)); % qtde de itera��es para verificar converg�ncia
    W = squareform(pdist(X,'seuclidean').^2);  % gerando matriz de afinidade
    W = W/max(max(W)); % normalizando matriz de afinidade no intervalo [0 1]
    G1 = W <= sigma;  % gerando grafo com limiar sobre matriz de afinidade
    B = sort(W,2);  % ordenando matriz de afinidade
    G2 = W <= repmat(B(:,knn+1),1,qtnode);  % conectando k-vizinhos mais pr�ximos
    graph = G1 | G2 | G2';  % juntando grafo limiar com grafo k-vizinhos
    clear W G1 B G2;
    graph = graph - eye(qtnode);  % zerando diagonal do grafo    
    % tabela de potenciais de n�s
    pot = repmat(potmax/npart,qtnode,npart);
    % definindo posi��o inicial das part�culas
    partpos = unidrnd(qtnode,npart,1);
    % definindo potencial da part�cula
    potpart = repmat(potmin,npart,1);
    % definindo grau de propriedade
    owndeg = repmat(realmin,qtnode,npart);
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    maxmmpot = 0;    
    % para cada itera��o
    for i=1:iter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);
        for j=1:npart
            % calculando probabilidade de explora��o            
            if rndtb(j)<pdet
                % regra de probabilidade
                prob = cumsum(graph(partpos(j),:) .* pot(:,j)');
                movtype = 0;
            else
                % regra de probabilidade
                prob = cumsum(graph(partpos(j),:));
                movtype = 1;
            end
            % girando a roleta para sortear o novo n�
            roulettepick = unifrnd(0,prob(end));
            % descobrindo quem foi o n� sorteado
            k = find(prob>=roulettepick,1,'first');           
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,j) = owndeg(k,j) + potpart(j);
            end
            % calculando novos potenciais para n�
            deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(npart-1)));
            pot(k,:) = pot(k,:) - deltapotpart;
            pot(k,j) = pot(k,j) + sum(deltapotpart);
            % atribui novo potencial para part�cula
            potpart(j) = potpart(j) + (pot(k,j)-potpart(j))*deltap;                               
            % se n�o houve choque
            if pot(k,j)>=max(pot(k,:))
                % muda para n� alvo
                partpos(j) = k;
            end
            % reset de part�cula se estiver com menos de 10% de potencial
            if potpart(j)<(potmax-potmin)*0.001
                partpos(j) = unidrnd(qtnode,1,1);
                disp(sprintf('reset %2.0f',i))
            end
        end
        if mod(i,ivconv)==0
            mmpot = mean(max(pot,[],2));
            disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
            if mmpot>maxmmpot
                maxmmpot = mmpot;
                stopcnt = 0;
            else    
                stopcnt = stopcnt + 1;
                if stopcnt > 9                     
                    break;
                end
            end
        end        
    end
    [nil,owner] = max(pot,[],2);
    cmeans = (owndeg.^2./repmat(sum(owndeg.^2),qtnode,1))' * X;
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,npart);
    [nil,owner2] = max(owndeg,[],2);    
end