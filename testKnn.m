function [ Y ] = testKnn( Knn, features )

featureVector = reshape(features,[],size(features,3),1);
%reads colums and then rows

Y = predict(Knn,featureVector);


end

