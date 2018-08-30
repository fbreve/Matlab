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
% Aceita m�ltiplos r�tulos para cada n� (v.8go)
% Usage: [owner, pot, owndeg, distnode] = strwalk8go(graph, slabel, pdet, deltav, deltap, dexp, nclass, iter)
function [owner, pot, owndeg, distnode] = strwalk8go(graph, slabel, pdet, deltav, deltap, dexp, nclass, iter)
    if (nargin < 8) || isempty(iter),
        iter = 100000; % n�mero de itera��es
    end
    if (nargin < 7) || isempty(nclass),
        nclass = max(slabel); % quantidade de classes
    end
    if (nargin < 6) || isempty(dexp),
        dexp = 2; % exponencial de probabilidade
    end
    if (nargin < 5) || isempty(deltap),
        deltap = 1.0; % controle de velocidade de aumento/decremento do potencial da part�cula
    end
    if (nargin < 4) || isempty(deltav),
        deltav = 0.1; % controle de velocidade de aumento/decremento do potencial do v�rtice
    end
    if (nargin < 3) || isempty(pdet),
        pdet = 0.5; % probabilidade de n�o explorar
    end
    potmax = 1.000; % potencial m�ximo
    potmin = 0.000; % potencial m�nimo
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
    % definindo grau de propriedade
    owndeg = repmat(realmin,qtnode,nclass);  % n�o podemos usar 0, porque n�s n�o visitados dariam divis�o por 0
    % vari�vel para guardar m�ximo potencial mais alto m�dio
    %stopmax = round((qtnode/npart)*20); % qtde de itera��es para verificar converg�ncia
    %maxmmpot = 0;
    for i=1:iter
        % para cada part�cula
        rndtb = unifrnd(0,1,npart,1);  % probabilidade pdet
        roulettepick = unifrnd(0,1,npart,1);  % sorteio da roleta
        for j=1:npart
            if rndtb(j)<pdet
                % regra de probabilidade
                prob = cumsum((1./(1+distnode(N{partpos(j)},j)).^dexp)'.* pot(N{partpos(j)},partclass(j))');
                % descobrindo quem foi o n� sorteado
                k = N{partpos(j)}(find(prob>=(roulettepick(j)*prob(end)),1,'first'));
                movtype=0;
            else
                k = N{partpos(j)}(ceil(roulettepick(j)*size(N{partpos(j)},2)));
                movtype=1;
            end
            % contador de visita (para calcular grau de propriedade)
            if movtype==1
                owndeg(k,partclass(j)) = owndeg(k,partclass(j)) + potpart(j);
            end                 
            % se o n� n�o � pr�-rotulado
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
%         if mod(i,10)==0
%             mmpot = mean(max(pot,[],2));
%             %disp(sprintf('Iter: %5.0f  Meanpot: %0.4f',i,mmpot))
%             if mmpot>maxmmpot
%                 maxmmpot = mmpot;
%                 stopcnt = 0;
%             else    
%                 stopcnt = stopcnt + 1;
%                 if stopcnt > stopmax                     
%                     break;
%                 end
%             end
%         end
    end
    owndeg = owndeg ./ repmat(sum(owndeg,2),1,nclass);
    [~,owner] = sort(owndeg,2,'descend');
    owner = owner(:,1:2);
    owndegsort = sort(owndeg,2,'descend');
    overlap = owndegsort(:,2)./owndegsort(:,1);
    owner(:,2) = owner(:,2).* (overlap>0.5);
end