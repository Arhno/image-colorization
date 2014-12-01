function [ Y ] = testRF( RF, features )

featureVector = reshape(features,[],size(features,3),1);
%reads colums and then rows

Y = predict(RF,featureVector);


end

