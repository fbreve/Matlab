
% -----------------------------------------------------------------------
%
%               Alternative small-worldness formulations
%
%                                                   V1.00
%

%		Input parameters:
%			AM:		Adjacency matrix of the network to be analysed
%					It should be unweighted
%
%			numRndNet:	Number of random networks for normalisation
%
%			w:		Parameter for weighting distances
%					Should normally be > 1 (e.g. 3)
%

%		Output:
%			SW:	Standard small-worldness
%
%			SWE:	Small-worldness based on efficiency
%
%			SWZ:	Small-worldness based on Z-Score
%
%			SWZl:	Log of SWZ
%
%			SWW:	Weighted small-worldness
%




function [SW, SWE, SWZ, SWZl, SWW] = AllSmallWorldness( AM, numRndNet, w )

    % First we ensure that the network has no self-loops
    AM = AM .* ( 1.0 - eye( size(AM, 1) ) );

    % Extract basic features
    numNodes = size(AM, 1);
    numLinks = sum( sum( AM ) );
    linkDensity = numLinks / ( numNodes * numNodes );

    % Create an ensemble of random networks
    rndNet = createRandomNetworks(numRndNet, numNodes, numLinks);




    % ----------- Calculating the main metrics 

    % Calculation of the CC
    CC = functionClusteringCoefficient( AM );
    CCrnd = zeros( numRndNet, 1 );
    for k = 1 : numRndNet
        CCrnd(k) = functionClusteringCoefficient( rndNet{k} );
    end

    % Calculation of L and all distances
    [L, dist] = functionL( AM );
    Lrnd = zeros( numRndNet, 1 );
    distrnd = {};
    for k = 1 : numRndNet
        [Lrnd(k), distrnd{k}] = functionL( rndNet{k} );
    end

    % Calculation of E
    E = functionE( dist, numNodes );
    Ernd = zeros( numRndNet, 1 );
    for k = 1 : numRndNet
        Ernd(k) = functionE( distrnd{k}, numNodes );
    end

    % Calculation of LW
    LW = functionLW( dist, numNodes, w );
    LWrnd = zeros( numRndNet, 1 );
    for k = 1 : numRndNet
        LWrnd(k) = functionLW( distrnd{k}, numNodes, w );
    end




    % ----------- Calculating the different small-worldness

    SW = CC ./ mean(CCrnd) ./ ( L ./ mean(Lrnd) );

    SWE = CC ./ mean(CCrnd) .* ( E ./ mean(Ernd) ); 

    %SWZ = ( CC - mean(CCrnd) ) ./ std( RRrnd ); changed by F.B. - apparently wrong in the original code
    SWZ = ( CC - mean(CCrnd) ) ./ std( CCrnd );
    SWZ = SWZ - ( L - mean(Lrnd) ) ./ std( Lrnd );

    SWZl = sign(SWZ) .* ( log10( abs( SWZ ) ) );

    SWW = CC ./ mean(CCrnd) ./ ( LW ./ mean(LWrnd) );
     

end







% -----------------------------------------------------------------------
%
%               Function for creating random equivalent networks
%
%		The method ensures that no self-link are present,
%		and that the network is connected


function rndNet = createRandomNetworks(numRndNet, numNodes, numLinks)

    rndNet = {};
    iter = 1;
    while iter <= numRndNet
        %rAM = rand(numNodes, numNodes); => too much RAM usage (F.B.)
        rAM = rand(numNodes, numNodes, 'single');
        rAM = rAM .* ( 1.0 - eye( size(rAM, 1) ) );
        [aX, bX] = sort( rAM(:), 'descend' );
        thr = aX( numLinks );
        rndNet{iter} = rAM >= thr;
        [S, C] = graphconncomp( sparse( rndNet{iter} ) );
        if S == 1
            iter = iter + 1;
        end
    end
    
end






% -----------------------------------------------------------------------
%
%               Function for calculating the CC
%


function CC = functionClusteringCoefficient( AM )

    AM = double( AM );
    SecondConn = AM * AM;
    Degree = sum( AM, 2 );
    NumTri = sum( (SecondConn .* AM), 2 );

    NumTTri = Degree .* Degree - Degree;

    M = size(AM);
    NumTTri = NumTTri + double(NumTTri == 0);
    LL = NumTri ./ NumTTri;
    CC = sum(LL) / M(1);

end




% -----------------------------------------------------------------------
%
%               Function for calculating L and all distances
%

function [L, dist] = functionL( AM )

    sparseAM = sparse( AM );
    [dist] = graphallshortestpaths( sparseAM );
    dist = dist(:);
    dist = dist( dist > 0 );
    
    L = mean( dist );

end



% -----------------------------------------------------------------------
%
%               Function for calculating E
%

function [E] = functionE( dist, numNodes )

    invDist = 1.0 ./ dist;
    E = sum( invDist ) / ( numNodes * (numNodes - 1) );

end



% -----------------------------------------------------------------------
%
%               Function for calculating LW
%

function [LW] = functionLW( dist, numNodes, w )

    dln = dist ./ log( numNodes );
    LW = 1.0 ./ ( numNodes * (numNodes - 1) ) .* sum( power( dln, w ) );

end

