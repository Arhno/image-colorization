function [ Y ] = testRF( RF, features, V )

featureVector = reshape(features,[],size(features,3),1);

featureVector = featureVector*V;
%reads colums and then rows

Y = predict(RF,featureVector);


end

