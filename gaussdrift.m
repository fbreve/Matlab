% Gera uma base de dados com "concept drift" utilizando 4 classes
% gaussianas se deslocando no sentindo horário
% Uso: [X, label] = gaussdrift(n,wnd)
% n = tamanho do conjunto de dados
% wnd = tamanho da janela do stream
function [X, label] = gaussdrift(n,wnd)
wnd = round(wnd/4)*4; % convertendo tamanho da janela é multiplo de 4 mais próximo
n = round(n/wnd)*wnd; % convertendo tamanho do conjunto em múltiplo do número de janelas mais próximo
groups = n/wnd; % definindo quantidade de grupos
gcn = wnd/4; % definindo quantidade de elementos por classe em cada grupo
mult = 3; % multiplicador para aumentar o diâmetro da órbita
X = zeros(n,2);
label = zeros(n,1);
for i=1:groups
    shift = (i/groups)*2*pi; % deslocamento em cada iteração
    c = (1:4)*0.5*pi + shift; % valores na faixa de 2*pi para serem passados às funções sin e cos
    x = mult*sin(c); % calculando eixo x dos centros
    y = mult*cos(c); % calculando eixo y dos centros
    A = gauss([gcn gcn gcn gcn],[x' y']); % gerando dados
    %A = gauss([gcn gcn gcn gcn],[-2,-2;-2,2;2,-2;2,2]); % gerando um grupo
    X((i-1)*wnd+1:i*wnd,:) = A.data;  % colocando dados do grupo em X
    label((i-1)*wnd+1:i*wnd) = A.nlab; % colocando labels do grupo em label
end