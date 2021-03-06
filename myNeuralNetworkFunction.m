function [Y,Xf,Af] = myNeuralNetworkFunction(X,~,~)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 27-Jun-2016 15:39:26.
%
% [Y] = myNeuralNetworkFunction(X,~,~) takes these arguments:
%
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 4xQ matrix, input #1 at timestep ts.
%
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 3xQ matrix, output #1 at timestep ts.
%
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1_xoffset = [4.3;2;1;0.1];
x1_step1_gain = [0.555555555555555;0.833333333333333;0.338983050847458;0.833333333333333];
x1_step1_ymin = -1;

% Layer 1
b1 = [-3.0165079133175725;2.0239591081835067;-1.2095990917485833;-1.0924124413028087;-0.40887678823958601;-0.62373079942363541;-1.2133950928984034;1.2822102928962289;1.3810783550410519;1.8880095480860439];
IW1_1 = [0.82923700981953319 -0.74400797342214975 0.91964000178309346 1.3317875484801089;-1.7668745903672531 -1.586485905503126 -0.38832651417587033 -0.21525312015258055;-0.069567614518951729 -0.17839030669663744 1.7229078703803067 2.7587157494362793;0.26146616377258847 -1.6591265553833194 1.669032110826286 -0.62393209136274674;1.3749535341793688 -1.8053540278051479 -0.13034736893601867 1.118177377466806;-0.013932670249574669 1.2712076723404502 -2.2182799291592938 -0.50057930127044459;-0.66863478671631915 -1.2352630610596753 -1.0749365281910441 1.6259033102476992;1.4518497371974237 -0.77148238384268186 -0.15467429375631436 2.3779512472048014;1.3141881270045435 1.3429090822628962 -1.9695098713080177 -1.2861880386065911;-0.067268418693219229 -0.60006529699925804 -2.0887999987797903 -1.993901485696725];

% Layer 2
b2 = [0.49528525046075905;0.17674645511601489;1.0097304312243365];
LW2_1 = [0.44165279275573277 0.28694424375459826 -0.076585915569164553 0.22992476329932623 -1.1778456473383545 1.9558406923043403 0.09447533835121881 -2.7704847171338058 0.65626817809177418 0.057907501857122665;0.62116109651133333 0.14604432589797067 -1.5912803060174885 0.33632631389068179 -0.41497943190144898 -0.77360897366707204 -0.23244716145451375 0.54370763961489432 0.55312649438740891 -0.068304194806204491;0.071739238516765572 0.45383132760277339 2.2640427748394707 1.2109021893383189 0.47810753288379204 -0.21974297635576037 0.42307462853179389 -0.097324978676922497 -1.4823152126643251 -1.5944269193047227];

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX, X = {X}; end;

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
    Q = size(X{1},2); % samples/series
else
    Q = 0;
end

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS
    
    % Input 1
    Xp1 = mapminmax_apply(X{1,ts},x1_step1_gain,x1_step1_xoffset,x1_step1_ymin);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = softmax_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Output 1
    Y{1,ts} = a2;
end

% Final Delay States
Xf = cell(1,0);
Af = cell(2,0);

% Format Output Arguments
if ~isCellX, Y = cell2mat(Y); end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings_gain,settings_xoffset,settings_ymin)
y = bsxfun(@minus,x,settings_xoffset);
y = bsxfun(@times,y,settings_gain);
y = bsxfun(@plus,y,settings_ymin);
end

% Competitive Soft Transfer Function
function a = softmax_apply(n)
nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);
numer = exp(n);
denom = sum(numer,1);
denom(denom == 0) = 1;
a = bsxfun(@rdivide,numer,denom);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n)
a = 2 ./ (1 + exp(-2*n)) - 1;
end
