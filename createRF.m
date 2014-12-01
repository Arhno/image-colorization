function [ RF ] = createRF( imgFeatures, labels, NTrees )

%reshaping featureImage into a 2D array:
featureVector = reshape(imgFeatures,[],size(imgFeatures,3),1);
labels = labels(:);

featuresSubSample = featureVector(1:5:end, :);
labelsSubSample = labels(1:5:end);

RF = TreeBagger(NTrees, featuresSubSample, labelsSubSample,'OOBPred','On',  'NPrint', 1);


oobErrorBaggedEnsemble = oobError(RF);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

end

