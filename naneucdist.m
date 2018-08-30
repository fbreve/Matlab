function d = naneucdist(XI, XJ) % euclidean distance, ignoring NaNs
[m,p] = size(XJ);
sqdx = (repmat(XI,m,1) - XJ) .^ 2;
pstar = sum(~isnan(sqdx),2); % correction for missing coords
pstar(pstar == 0) = NaN;
d = sqrt(nansum(sqdx,2) .* p ./ pstar);