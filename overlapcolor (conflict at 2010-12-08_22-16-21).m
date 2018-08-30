% obsoleto, usar dotgen

owndegsort = sort(owndeg,2,'descend');
color = owndegsort(:,2)./owndegsort(:,1);
%scatter(X(:,1),X(:,2),[],color)
%scatter(X(:,1),X(:,2),10+color*90,color)