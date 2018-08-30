% Semi-Supervised Territory Mark Walk v.8
% Derivado de strwalk7.m
% Conta dist�ncia de de n�s para o n� pr�-rotulado mais pr�ximo (v.2)
% Utiliza uma part�cula por n� pr�-rotulado (v.3)
% Utiliza redes sem peso (V.5)
% Utiliza movimento aleat�rio e potencial x distancia (v.6)
% Forma grafo a partir de limiar definido na distancia euclidiana (v.7)
% Sa�da fuzzy utilizando contagem de visitas pelo movimento aleat�rio
% ponderada pelo potencial da part�cula (v.8)
% Aceita diretamente o grafo como entrada em vez de X (v.8g)
% Vers�o especial para medir complexidade (v.8gc)
% Usage: [totiter,tottime] = strwalk8gc(graph, slabel, nclass, iter, pdet, deltav, deltap, dexp)
function [totiter,tottime] = strwalk8gc(graph, slabel, nclass, iter, pdet, deltav, deltap, dexp)
    if (nargin < 8) || isempty(dexp),
        dexp = 2; % exponencial da probabilidade
    end
    if (nargin < 7) || isempty(deltap),
        deltap = 1.000; % controle de velocidade de aumento/decermento do potencial da part�cula
    end
    if (nargin < 6) || isempty(deltav),
        deltav = 0.350; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 5) || isempty(pdet),
        pdet = 0.700; % probabilidade de n�o explorar
    end
    if (nargin < 4) || isempty(iter),
        iter = 200000; % n�mero de itera��es
    end
    tic;
    potmax = single(1.000); % potencial m�ximo
    potmin = single(0.000); % potencial m�nimo
    qtnode = size(graph,1); % quantidade de n�s
    npart = sum(slabel~=0); % quantidade de part�culas
    % tabela de potenciais de n�s
    pot = repmat(potmax/nclass,qtnode,nclass);
    % definindo potencial da part�cula
    potpart = repmat(potmax,npart,1);
    % definindo tabela de dist�ncias dos n�s
    distnode = repmat(qtnode-1,qtnode,npart);
    % criando tabela de classes de cada part�cula
    partclass = zeros(npart,1);
    % criando tabela de posi��o inicial das part�culas
    partpos=zeros(npart,1);
    % criando c�lula para listas de vizinhos
    N = cell(qtnode,1);        
    % verificando n�s rotulados e ajustando potenciais de acordo
    j=0;
    for i=1:qtnode
        % se n� � pr�-rotulado
        if slabel(i)~=0
            pot(i,:)=0;
            pot(i,slabel(i))=1;
            j = j + 1;
            partclass(j)=slabel(i);  % definindo classe da part�cula
            distnode(i,j)=0;        % definindo dist�ncia do n� pr�-rotulado para 0 na tabela de sua respectiva part�cula
            partpos(j)=i;            % definindo posi��o inicial da part�cula para seu respectivo n� pr�-rotulado
        end
        N{i} = find(graph(i,:)==1); % criando lista de vizinhos
    end
    clear graph;
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    stopmax = round((qtnode/npart)*2); % qtde de itera��es para verificar converg�ncia
    maxmmpot = 0;
    for i=1:iter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1); % probabilidade de explora��o
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart          
            % lista de vizinhos            
            if rndtb(j)<pdet
                % regra de probabilidade
                prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                % descobrindo quem foi o n� sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
            else
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
            end
            if slabel(k)==0
                % calculando novos potenciais para n�
                deltapotpart = pot(k,:) - max(potmin,pot(k,:) - potpart(j)*(deltav/(nclass-1)));
                pot(k,:) = pot(k,:) - deltapotpart;
                pot(k,partclass(j)) = pot(k,partclass(j)) + sum(deltapotpart);
            end
            % atribui novo potencial para part�cula
            potpart(j) = potpart(j) + (pot(k,partclass(j))-potpart(j))*deltap;
                      
            % se dist�ncia do n� alvo maior que dist�ncia do n� atual + 1
            if distnode(partpos(j),j)+1<distnode(k,j)
                % atualizar dist�ncia do n� alvo
                distnode(k,j) = distnode(partpos(j),j)+1;
            end
            
            % se n�o houve choque
            if pot(k,partclass(j))>=max(pot(k,:))
                % muda para n� alvo
                partpos(j) = k;
            end
        end
        if mod(i,10)==0
            mmpot = mean(max(pot,[],2));
            %disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
            if mmpot>maxmmpot
                maxmmpot = mmpot;
                stopcnt = 0;
            else    
                stopcnt = stopcnt + 1;
                if stopcnt > stopmax                     
                    totiter = i;
                    tottime = toc;
                    break;
                end
            end
        end
    end
    %[~,owner] = max(pot,[],2);
    %owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
end